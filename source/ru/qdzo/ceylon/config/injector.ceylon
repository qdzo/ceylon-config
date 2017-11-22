import ceylon.language.meta {
    annotations
}
import ceylon.language.meta.declaration {
    ValueDeclaration,
    OpenType,
    OpenClassOrInterfaceType
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

"annotation to mark functions that require
 environment variables for their proper work"
shared annotation EnvironmentAnnotation environment(String envName)
        => EnvironmentAnnotation(envName);

"annotation to mark fields that optionally may be configured
 from environment"
shared final annotation
class OptionalEnvironmentAnnotation(shared String envName) satisfies
        OptionalAnnotation<OptionalEnvironmentAnnotation, ValueDeclaration> {}


"annotation to mark functions that require
 environment variables for their proper work"
shared annotation OptionalEnvironmentAnnotation optionalEnvironment(String envName)
        => OptionalEnvironmentAnnotation(envName);


shared T createType<T>() {
    value type = `T`;
    "Type to configurate should be a class"
    assert(is Class<T> type);

    value strictFields = [
        for (attr in type.declaration.memberDeclarations<ValueDeclaration>())
            if(exists env = annotations(`EnvironmentAnnotation`, attr))
            env.envName -> attr
    ];

    value optionalFields = [
        for (attr in type.declaration.memberDeclarations<ValueDeclaration>())
            if(exists env = annotations(`OptionalEnvironmentAnnotation`, attr))
            env.envName -> attr
    ];

    function parsePamam(String envName, ValueDeclaration attrDecl) {
        OpenType openType = attrDecl.openType;
        assert(is OpenClassOrInterfaceType openType);

        if(`class Integer` == openType.declaration){
            return attrDecl.name -> [envName, env.getIntegerOrNull(envName)];
        }
        if(`class Float` == openType.declaration){
            return attrDecl.name -> [envName, env.getFloatOrNull(envName)];
        }
        if(`class Boolean` == openType.declaration){
            return attrDecl.name -> [envName, env.getBooleanOrNull(envName)];
        }
        if(`interface Date` == openType.declaration){
            return attrDecl.name -> [envName, env.getDateOrNull(envName)];
        }
        if(`interface Time` == openType.declaration){
            return attrDecl.name -> [envName, env.getTimeOrNull(envName)];
        }
        if(`interface DateTime` == openType.declaration){
            return attrDecl.name -> [envName, env.getDateTimeOrNull(envName)];
        }
        if(`class String` == openType.declaration){
            return attrDecl.name -> [envName, env.getStringOrNull(envName)];
        }
//        if(`class Integer?` == openType.declaration){
//            return   attrDecl.name -> [envName, env.getIntegerOrNull(envName)];
//        }
//        if(`class Float?` == openType.declaration){
//            return   attrDecl.name -> [envName, env.getFloatOrNull(envName)];
//        }
//        if(`class Boolean?` == openType.declaration){
//            return   attrDecl.name -> [envName, env.getBooleanOrNull(envName)];
//        }
//        if(`interface Date?` == openType.declaration){
//            return   attrDecl.name -> [envName, env.getDateOrNull(envName)];
//        }
//        if(`interface Time?` == openType.declaration){
//            return   attrDecl.name -> [envName, env.getTimeOrNull(envName)];
//        }
//        if(`interface DateTime?` == openType.declaration){
//            return   attrDecl.name -> [envName, env.getDateTimeOrNull(envName)];
//        }
//        if(`class String?` == openType.declaration){
//            return   attrDecl.name -> [envName, env.getStringOrNull(envName)];
//        }
        print("OPEN_TYPE: ``openType``");
        return attrDecl.name -> [envName, null];
    }

    value params  = [for (envName -> attr in strictFields)
                        parsePamam(envName, attr)];

    if(nonempty undefinedParams = params.select((p)=> ! p.item[1] exists)){
        throw AssertionError("[``", ".join(undefinedParams.map((k->v)=> v[0]))``] - variable(s) should be specified in environment");
    }

    value optionalParams  = [for (envName -> attr in optionalFields)
                                parsePamam(envName, attr)];

    value args = concatenate(params, optionalParams).map((k->v) => k->v[1]);
    return type.namedApply(args);
}

//        case(is Type<Integer?>) attrDecl.name -> env.getIntegerOrNull(envName)
//        case(is Type<Float?>) attrDecl.name -> env.getFloatOrNull(envName)
//        case(is Type<Boolean?>) attrDecl.name -> env.getBoolean?(envName)
//        case(is Type<Date?>) attrDecl.name -> env.getDateOrNull(envName)
//        case(is Type<Time?>) attrDecl.name -> env.getTimeOrNull(envName)
//        case(is Type<DateTime?>) attrDecl.name -> env.getDateTimeOrNull(envName)
//        case(is Type<String?>) attrDecl.name -> env.getStringOrNull(envName)
// ----------------------------------------------------------------
