import ceylon.collection {
    HashMap
}
import ru.qdzo.ceylon.config.loaders {
    cmdParamsLoader,
    systemPropsLoader,
    defaultJsonConfigLoader,
    defaultTomlConfigLoader,
    CustomConfigLoader,
    systemEnvLoader
}
import ceylon.time {
    Date,
    Time,
    DateTime
}
import ceylon.time.iso8601 {
    parseDateTime,
    parseTime,
    parseDate
}
"Presents config-map of different configuration sources.
 Load environment variables from loaders.
 The later loader have higher priority and can override previously setted variable"
shared class Environment({Loader*} loaders) satisfies Map<String, String> {

    late Map<String, String> envVars = initEnv();

    Map<String, String> initEnv() {
        variable Map<String, String> tempMap = HashMap {};
        for (loader in loaders) {
            tempMap = tempMap.patch(loader.load);
        }
        return tempMap;
    }

    defines(Object key) => get(key) exists;

    get(Object key) => envVars[key.string];

    "Get `String` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class AssertionError`)
    shared String getString(Object key){
        assert(exists val = get(key));
        return val;
    }

    "Get `Integer` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class AssertionError`)
    shared Integer getInteger(Object key){
        assert(exists val = get(key));
        assert(is Integer intVal = Integer.parse(val));
        return intVal;
    }

    "Get `Float` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class AssertionError`)
    shared Float getFloat(Object key){
        assert(exists val = get(key));
        assert(is Float floatVal = Float.parse(val));
        return floatVal;
    }

    "Get `Date` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class AssertionError`)
    shared Date getDate(Object key){
        assert(exists val = get(key));
        assert(is Date dateVal = parseDate(val));
        return dateVal;
    }

    "Get `Time` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class AssertionError`)
    shared Time getTime(Object key){
        assert(exists val = get(key));
        assert(is Time timeVal = parseTime(val));
        return timeVal;
    }

    "Get `DateTime` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class AssertionError`)
    shared DateTime getDateTime(Object key){
        assert(exists val = get(key));
        assert(is DateTime dateTimeVal = parseDateTime(val));
        return dateTimeVal;
    }

    "Get `Boolean` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class AssertionError`)
    shared Boolean getBoolean(Object key){
        assert(exists val = get(key));
        assert(is Boolean booleanVal = Boolean.parse(val));
        return booleanVal;
    }

    shared String? reactive(Object key)() => // TODO think about this
            process.propertyValue(key.string)
            else  process.environmentVariableValue(key.string)
            else process.namedArgumentValue(key.string)
            else envVars[key.string];

    iterator() => envVars.iterator();

    equals(Object that) =>
            if (is Environment that)
            then envVars==that.envVars
            else false;

    hash => envVars.hash;

}