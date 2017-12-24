import ceylon.collection {
    HashMap
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

    get(Object key) => envVars[key];

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

    "Get `String` value for given key or null if value is not present or can not be parsed"
    shared String? getStringOrNull(Object key){
        try {
            return getString(key);
        } catch(AssertionError ae) {
            return null;
        }
    }

    "Get `Integer` value for given key or null if value is not present or can not be parsed"
    shared Integer? getIntegerOrNull(Object key){
        try {
            return getInteger(key);
        } catch(AssertionError ae) {
            return null;
        }
    }

    "Get `Float` value for given key or null if value is not present or can not be parsed"
    shared Float? getFloatOrNull(Object key){
        try {
            return getFloat(key);
        } catch(AssertionError ae) {
            return null;
        }
    }

    "Get `Date` value for given key or null if value is not present or can not be parsed"
    shared Date? getDateOrNull(Object key){
        try {
            return getDate(key);
        } catch(AssertionError ae) {
            return null;
        }
    }

    "Get `Time` value for given key or null if value is not present or can not be parsed"
    shared Time? getTimeOrNull(Object key){
        try {
            return getTime(key);
        } catch(AssertionError ae) {
            return null;
        }
    }

    "Get `DateTime` value for given key or null if value is not present or can not be parsed"
    shared DateTime? getDateTimeOrNull(Object key){
        try {
            return getDateTime(key);
        } catch(AssertionError ae) {
            return null;
        }
    }

    "Get `Boolean` value for given key or null if value is not present or can not be parsed"
    shared Boolean? getBooleanOrNull(Object key){
        try {
            return getBoolean(key);
        } catch(AssertionError ae) {
            return null;
        }
    }

/*
    shared String? reactive(Object key)() => // TODO think about this
            process.propertyValue(key.string)
            else  process.environmentVariableValue(key.string)
            else process.namedArgumentValue(key.string)
            else envVars[key.string];
*/

    iterator() => envVars.iterator();

    equals(Object that) =>
            if (is Environment that)
            then envVars==that.envVars
            else false;

    hash => envVars.hash;

}
