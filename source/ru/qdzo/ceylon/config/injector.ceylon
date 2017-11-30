import ceylon.collection {
    partition,
    HashMap,
    MutableMap
}
import ceylon.language.meta {
    annotations,
    type
}
import ceylon.language.meta.declaration {
    ValueDeclaration,
    OpenType,
    OpenClassOrInterfaceType,
    ClassOrInterfaceDeclaration
}
import ceylon.language.meta.model {
    Class
}
import ceylon.time {
    Date,
    Time,
    DateTime
}
import ceylon.time.iso8601 {
    parseDate,
    parseTime,
    parseDateTime
}

"annotation to mark fields that will be configured
 from environment"
shared final annotation
class EnvironmentAnnotation(shared String envName) satisfies
        OptionalAnnotation<EnvironmentAnnotation, ValueDeclaration> {}

"annotation to mark attributes(fields) that require
 environment variables for their proper work"
shared annotation EnvironmentAnnotation environment(String envName)
        => EnvironmentAnnotation(envName);

Boolean isWrappedWithBrackets(String str)
        => (str.startsWith("[") && str.endsWith("]")) ||
           (str.startsWith("{") && str.endsWith("}"));

"Splits string by comma and trims results"
String[] splitByComma(String str)
        => str.split(','.equals)*.trim(' '.equals);

"Removes one char from start and end of string"
String trimFirstAndLastChars(String str)
        => str[1..(str.size - 2)];

String[] splitStringList(String str) {
    if(str.contains(",")) {
        if(isWrappedWithBrackets(str)){
            return splitByComma(trimFirstAndLastChars(str));
        } else {
            return splitByComma(str);
        }
    }
    return [];
}

Integer? parseInteger(String str)
        => if(is Integer i = Integer.parse(str))
           then i else null;

Float? parseFloat(String str)
        => if(is Float f = Float.parse(str))
           then f else null;

Boolean? parseBoolean(String str)
        => if(is Boolean b = Boolean.parse(str))
           then b else null;

shared Anything narrowSequence(ClassOrInterfaceDeclaration openType, [Anything*] args)  {
    value xType = type(args.first);
    assert(is {Anything*} ret = `function Iterable.narrow`.memberInvoke(args, [xType]));
    return ret.sequence();
    // if(openType == `class Integer`) {
    //     return args.narrow<Integer>().sequence();
    // } else if(openType == `class Float`) {
    //     return args.narrow<Float>().sequence();
    // } else if(openType == `class Boolean`) {
    //     return args.narrow<Boolean>().sequence();
    // } else if(openType == `class String`) {
    //     return args.narrow<String>().sequence();
    // } else if(openType == `interface Date`) {
    //     return args.narrow<Date>().sequence();
    // } else if(openType == `interface Time`) {
    //     return args.narrow<Time>().sequence();
    // } else if(openType == `interface DateTime`) {
    //     return args.narrow<DateTime>().sequence();
    // }
    // throw Exception("Not supported type ``openType``");
}

shared alias TypeParser => Anything(String);

MutableMap<ClassOrInterfaceDeclaration, TypeParser>
typeParsers = HashMap<ClassOrInterfaceDeclaration, TypeParser> {
    `class Integer` -> parseInteger,
    `class Float` -> parseFloat,
    `class Boolean` -> parseBoolean,
    `class String` -> String,
    `interface Date` -> parseDate,
    `interface Time` -> parseTime,
    `interface DateTime` -> parseDateTime
};

shared void
registerTypeParser(
        ClassOrInterfaceDeclaration decl,
        TypeParser typeParser) {
    typeParsers.put(decl, typeParser);
}

shared void
unregisterTypeParser(
        ClassOrInterfaceDeclaration decl) {
    typeParsers.remove(decl);
}

shared T configure<out T>(Environment environment = env) {
    value configuredType = `T`;
    "Type to configurate should be a class"
    assert(is Class<T> configuredType);

    <String->ValueDeclaration>[]
    envVarNameToFieldDeclaration = [
        for (declaration in configuredType.declaration.memberDeclarations<ValueDeclaration>())
            if(exists annotation = annotations(`EnvironmentAnnotation`, declaration))
                annotation.envName -> declaration
    ];

    value [strictFields, optionalFields]
            = partition(envVarNameToFieldDeclaration,
                        forItem(ValueDeclaration.defaulted));

    function fillParam(<String->ValueDeclaration> envVarNameToFieldDecl) {

        value varName -> fieldDecl = envVarNameToFieldDecl;
        OpenType openType = fieldDecl.openType;
        assert(is OpenClassOrInterfaceType openType);
        
        if(openType.declaration in {`interface Sequential`, `interface Iterable`},
            is OpenClassOrInterfaceType typeParameterOpenType = openType.typeArgumentList.first){
            for (decl->parse in typeParsers) {
                if(decl == typeParameterOpenType.declaration,
                    exists var = environment[varName]) {
                    value list = splitStringList(var);
                    value res = list.collect(parse);
                    value sequence = narrowSequence(decl, res);
                    print(res);
                    return fieldDecl.name -> [varName, sequence];
                }
            }

        } else {
            for (decl->parse in typeParsers) {
                if(decl == openType.declaration,
                    exists var = environment[varName]){
                    return fieldDecl.name -> [varName, parse(var)];
                }
            }
        }
        
        print("OPEN_TYPE: ``openType``");
        return fieldDecl.name -> [varName, null];
    }

    value params = strictFields.collect(fillParam);

    if(nonempty unspecified = [for (_->[name, val] in params) if(is Null val) name]) {
        throw AssertionError( "[``", ".join(unspecified)``] - variable(s) should be specified in environment");
    }

    value optionalParams  = optionalFields.collect(fillParam);

    value args = concatenate(params, optionalParams).map((k->v) => k->v[1]);
    
    log.info("args: ``args.string``");
    return configuredType.namedApply(args);
}

