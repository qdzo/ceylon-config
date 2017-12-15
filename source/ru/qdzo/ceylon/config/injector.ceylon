import ceylon.collection {
    partition
}
import ceylon.language.meta {
    annotations
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
class EnvVarAnnotation(shared String envName) satisfies
        OptionalAnnotation<EnvVarAnnotation, ValueDeclaration> {}

"annotation to mark attributes(fields) that require
 environment variables for their proper work"
shared annotation EnvVarAnnotation envvar(String envName)
        => EnvVarAnnotation(envName);

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

Map<ClassOrInterfaceDeclaration, Anything(String)> typeParsers = map {
    `class Integer` -> parseInteger,
    `class Float` -> parseFloat,
    `class Boolean` -> parseBoolean,
    `class String` -> String,
    `interface Date` -> parseDate,
    `interface Time` -> parseTime,
    `interface DateTime` -> parseDateTime
};

"Instantiate class with values taken from environment variables.
 Given class need to annotate it's fields with `envVar` annotation"
throws(`class AssertionError`, "when some of the variables not exists in the environment")
shared T configure<out T>(Environment environment = env) {
    value configuredType = `T`;
    "Type to configurate should be a class"
    assert(is Class<T> configuredType);

    <String->ValueDeclaration>[]
    envVarNameToFieldDeclaration = [
        for (declaration in configuredType.declaration.memberDeclarations<ValueDeclaration>())
            if(exists annotation = annotations(`EnvVarAnnotation`, declaration))
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
                    // tuple() is hack function - it narrows collection type-argument without meta-model.
                    value res = list.collect(parse).tuple();
                    return fieldDecl.name -> [varName, res];
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
        
        log.error("UNKNOWN OPEN_TYPE: ``openType``");
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

