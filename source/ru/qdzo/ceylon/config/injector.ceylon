import ceylon.collection {
    partition,
    HashMap,
    MutableMap
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


"annotation to mark fields that will be configured
 from environment"
shared final annotation
class EnvironmentAnnotation(shared String envName) satisfies
        OptionalAnnotation<EnvironmentAnnotation, ValueDeclaration> {}

"annotation to mark attributes(fields) that require
 environment variables for their proper work"
shared annotation EnvironmentAnnotation environment(String envName)
        => EnvironmentAnnotation(envName);

shared alias TypeParser => Anything(Environment, String);

MutableMap<ClassOrInterfaceDeclaration, TypeParser>
typeParsers
        = HashMap<ClassOrInterfaceDeclaration, TypeParser> {
    `class Integer` -> ((Environment e, String s) => e.getIntegerOrNull(s)),
    `class Float` -> ((Environment e, String s) => e.getFloatOrNull(s)),
    `class Boolean` -> ((Environment e, String s) => e.getBooleanOrNull(s)),
    `interface Date` -> ((Environment e, String s) => e.getDateOrNull(s)),
    `interface Time` -> ((Environment e, String s) => e.getTimeOrNull(s)),
    `interface DateTime` -> ((Environment e, String s) => e.getDateTimeOrNull(s)),
    `class String` -> ((Environment e, String s) => e.getStringOrNull(s))
};


shared void registerTypeParser(ClassOrInterfaceDeclaration decl, TypeParser typeParser) {
    typeParsers.put(decl, typeParser);
}

shared void unregisterTypeParser(ClassOrInterfaceDeclaration decl) {
    typeParsers.remove(decl);
}

shared T configure<out T>(Environment environment = env) {
    value type = `T`;
    "Type to configurate should be a class"
    assert(is Class<T> type);

    <String->ValueDeclaration>[]
    envVarNameToFieldDeclaration = [
        for (declaration in type.declaration.memberDeclarations<ValueDeclaration>())
            if(exists annotation = annotations(`EnvironmentAnnotation`, declaration))
                annotation.envName -> declaration
    ];

    value [strictFields, optionalFields]
            = partition(envVarNameToFieldDeclaration, forItem(ValueDeclaration.defaulted));

    function fillParam(<String->ValueDeclaration> envVarNameToFieldDecl) {
        
        value varName -> fieldDecl = envVarNameToFieldDecl;
        OpenType openType = fieldDecl.openType;
        assert(is OpenClassOrInterfaceType openType);
        for (decl->parse in typeParsers) {
            if(decl == openType.declaration){
                return fieldDecl.name -> [varName, parse(environment, varName)];
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
    return type.namedApply(args);
}

