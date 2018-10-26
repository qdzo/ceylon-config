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


    throws(`class EnvironmentVariableNotFoundException`)
    String getOrThrowIfNotFound(Object key){
        if(exists val = get(sanitizeKey(key.string))){
            return val;
        }
        throw EnvironmentVariableNotFoundException(key.string);
    }

    "Get `String` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class EnvironmentVariableNotFoundException`)
    shared String getString(Object key){
        return getOrThrowIfNotFound(key);
    }

    "Get `Integer` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class EnvironmentVariableNotFoundException`)
    throws(`class EnvironmentVariableParseException`)
    shared Integer getInteger(Object key){
        String val = getOrThrowIfNotFound(key);

        switch(intOrException = Integer.parse(val))
        case (is ParseException) {
            throw EnvironmentVariableParseException(key, val, "Integer", intOrException);
        }
        else {
            return intOrException;
        }
    }

    "Get `Float` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class EnvironmentVariableNotFoundException`)
    throws(`class EnvironmentVariableParseException`)
    shared Float getFloat(Object key){
        String val = getOrThrowIfNotFound(key);

        switch(floatOrException = Float.parse(val))
        case (is ParseException) {
            throw EnvironmentVariableParseException(key, val, "Float", floatOrException);
        }
        else { return floatOrException; }
    }

    "Get `Date` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class EnvironmentVariableNotFoundException`)
    throws(`class EnvironmentVariableParseException`)
    shared Date getDate(Object key){
        String val = getOrThrowIfNotFound(key);
        // REVIEW: If parseDate throws internally exceptions (Vitaly 08.02.18)
        switch(dateOrNull = parseDate(val))
        case (is Null) {
            throw EnvironmentVariableParseException(key, val, "Date");
        }
        else { return dateOrNull; }
    }

    "Get `Time` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class EnvironmentVariableNotFoundException`)
    throws(`class EnvironmentVariableParseException`)
    shared Time getTime(Object key){
        String val = getOrThrowIfNotFound(key);
        // REVIEW: If parseTime throws internally exceptions (Vitaly 08.02.18)
        switch(timeOrNull = parseTime(val))
        case (is Null) {
            throw EnvironmentVariableParseException(key, val, "Time");
        }
        else { return timeOrNull; }
    }

    "Get `DateTime` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class EnvironmentVariableNotFoundException`)
    throws(`class EnvironmentVariableParseException`)
    shared DateTime getDateTime(Object key){
        // REVIEW: If parseDateTime throws internally exceptions (Vitaly 08.02.18)
        String val = getOrThrowIfNotFound(key);
        switch(dateTimeOrNull = parseDateTime(val))
        case (is Null) {
            throw EnvironmentVariableParseException(key, val, "DateTime");
        }
        else { return dateTimeOrNull; }
    }

    "Get `Boolean` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class EnvironmentVariableNotFoundException`)
    throws(`class EnvironmentVariableParseException`)
    shared Boolean getBoolean(Object key){
        String val = getOrThrowIfNotFound(key);
        switch(booleanOrException = Boolean.parse(val))
        case (is ParseException) {
            throw EnvironmentVariableParseException(key, val, "Boolean", booleanOrException);
        }
        else { return booleanOrException; }
    }

    "Try do some action. If get exception - log it and return null"
    T? tryDo<T>(T() fn) {
        try {
            return fn();
        } catch(EnvironmentVariableNotFoundException|EnvironmentVariableParseException e) {
            log.warn(e.message);
            return null;
        }
    }

    "Get `String` value for given key or null if value is not present or can not be parsed"
    shared String? getStringOrNull(Object key) => tryDo(() => getString(key));

    "Get `Integer` value for given key or null if value is not present or can not be parsed"
    shared Integer? getIntegerOrNull(Object key)=> tryDo(() => getInteger(key));

    "Get `Float` value for given key or null if value is not present or can not be parsed"
    shared Float? getFloatOrNull(Object key)=> tryDo(() => getFloat(key));

    "Get `Date` value for given key or null if value is not present or can not be parsed"
    shared Date? getDateOrNull(Object key)=> tryDo(() => getDate(key));

    "Get `Time` value for given key or null if value is not present or can not be parsed"
    shared Time? getTimeOrNull(Object key)=> tryDo(() => getTime(key));

    "Get `DateTime` value for given key or null if value is not present or can not be parsed"
    shared DateTime? getDateTimeOrNull(Object key) => tryDo(() => getDateTime(key));

    "Get `Boolean` value for given key or null if value is not present or can not be parsed"
    shared Boolean? getBooleanOrNull(Object key)=> tryDo(() => getBoolean(key));

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
