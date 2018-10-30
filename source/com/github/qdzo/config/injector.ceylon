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
    ClassOrInterfaceDeclaration,
    OpenUnion
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
shared annotation EnvVarAnnotation envVar(String envName)
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

// special typeParsers - order - from more specific to more generic
Map<ClassOrInterfaceDeclaration, Anything(String)> typeParsers = map {
    `class Float` -> parseFloat,
    `class Integer` -> parseInteger,
    `class Boolean` -> parseBoolean,
    `interface Date` -> parseDate,
    `interface Time` -> parseTime,
    `interface DateTime` -> parseDateTime,
    `class String` -> String
};

"Try convert string to one of given types:

  - union-type of common-data-types
  - sequence-type of common-data-types
  - common-data-types

  > PS: common-data-types - that have [[typeParsers]]"
Anything tryConvertStringToOpenType(String stringValue, OpenType openType) {

    switch(openType)
    case (is OpenClassOrInterfaceType) {
        return if(openType.declaration in {`interface Sequential`, `interface Iterable`})
        then tryConvertStringToSequeceOpenType(stringValue, openType)
        else tryConvertStringToOneOfOpenType(stringValue, openType);
    }
    case (is OpenUnion) {
        return tryConvertUnionTypesWithSpecialOrder(stringValue, openType.caseTypes);
    }
    else {
        log.warn("Not suppported openType: ``openType``");
        return null;
    }
}

"Try convert string to sequence-type of common-data-types

  > PS: common-data-types - that have [[typeParsers]]"
Anything tryConvertStringToSequeceOpenType(
        String stringValue, OpenClassOrInterfaceType openType) {

    value res = [
        for (stringElement in splitStringList(stringValue))
        if(exists typeArg = openType.typeArgumentList.first)
        tryConvertStringToOpenType(stringElement, typeArg)
    ];
    return res.tuple();
    // tuple() is hack fn - it narrows collection type-argument without meta-model.
}

"
 union types (example: `Integer|String` and `String|Union`)
 can have different order - and we potentially can build wrong values.
 in this way we we need special order specified parsers -> generic parsers"
Anything tryConvertUnionTypesWithSpecialOrder(
        String stringValue, List<OpenType> caseTypes) {

    value classOrIntefacaes =
            caseTypes.narrow<OpenClassOrInterfaceType>()*.declaration;

    for (decl->parse in typeParsers) {
        if(decl in classOrIntefacaes,
            exists res = parse(stringValue)) {
            return res;
        }
    }
    log.warn("Can't convert string ``stringValue`` to one of Union type: ``caseTypes``");
    return null;
}

"Try convert string to one of common-data-type, that have [[typeParsers]].

  > PS: common-data-types - that have `typeParsers`"
Anything tryConvertStringToOneOfOpenType(String stringValue, OpenClassOrInterfaceType openType) {
    if(exists parse = typeParsers[openType.declaration]) {
        return parse(stringValue);
    }
    log.warn("Can't convert string ``stringValue`` to  ``openType``");
    return null;
}


"Sanitized Environment Variable Name. (example: 'db.name', 'server.port')"
alias EnvVarName => String;

"Object field name"
alias FieldName => String;

"Instantiate class with values taken from environment variables.
 Given class need to annotate it's fields with `envVar` annotation"
throws(`class EnvironmentVariableNotFoundException`,
    "when some of the variables not exists in the environment")
shared T configure<out T>(Environment environment = env) {

    value configuredType = `T`;
    "Type to configurate should be a class"
    assert(is Class<T> configuredType);

    <EnvVarName->ValueDeclaration>[]
    envVarNameToFieldDeclaration = [
        for (declaration in configuredType.declaration.memberDeclarations<ValueDeclaration>())
            if(exists annotation = annotations(`EnvVarAnnotation`, declaration))
                sanitizeKey(annotation.envName) -> declaration
    ];

    value [optionalFields, strictFields]
            = partition(envVarNameToFieldDeclaration,
                        forItem(ValueDeclaration.defaulted));

    value params = strictFields.collect(fillParam(environment));

    if(nonempty unspecified =
            [for (_->[name, val] in params) if(is Null val) name]) {
        throw EnvironmentVariableNotFoundException(", ".join(unspecified));
    }

    value optionalParams  = optionalFields.collect(fillParam(environment));

    value args = concatenate(params, optionalParams).map((k->v) => k->v[1]);

    log.info("args: ``args.string``");
    return configuredType.namedApply(args);
}

FieldName->[EnvVarName, Anything]
fillParam (Environment environment)(<String->ValueDeclaration> envVarNameToFieldDecl) {

    value varName -> fieldDecl = envVarNameToFieldDecl;
    OpenType openType = fieldDecl.openType;
    value envVarValue = environment.get(varName);

    if(is Null envVarValue) {
        log.error("Environment variable [``varName``] not found");
        return fieldDecl.name -> [varName, null];
    }

    value convertedValue = tryConvertStringToOpenType(envVarValue, openType);

    if(is Null convertedValue) {
        log.error("Can't convert [``envVarValue``] to ``openType``");
    }

    return fieldDecl.name -> [varName, convertedValue];
}
