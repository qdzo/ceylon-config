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


    throws(`class VariableNotFoundException`)
    String getOrThrowIfNotFound(Object key){
        if(exists val = get(key)){
            return val;
        }
        throw VariableNotFoundException(key.string);
    }

    "Get `String` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class VariableNotFoundException`)
    shared String getString(Object key){
        return getOrThrowIfNotFound(key);
    }

    "Get `Integer` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class VariableNotFoundException`)
    throws(`class ParseException`)
    shared Integer getInteger(Object key){
        String val = getOrThrowIfNotFound(key);

        switch(intOrException = Integer.parse(val))
        case (is ParseException) {
            throw ParseException("Variable with name [``key.string``] can't be parsed: ``intOrException.message``");
        }
        else {
            return intOrException;
        }
    }

    "Get `Float` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class VariableNotFoundException`)
    throws(`class ParseException`)
    shared Float getFloat(Object key){
        String val = getOrThrowIfNotFound(key);

        switch(floatOrException = Float.parse(val))
        case (is ParseException) { throw ParseException("Variable with name [``key.string``] can't be parsed: ``floatOrException.message``"); }
        else { return floatOrException; }
    }

    "Get `Date` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class VariableNotFoundException`)
    shared Date getDate(Object key){
        String val = getOrThrowIfNotFound(key);
        // REVIEW: If parseDate throws internally exceptions (Vitaly 08.02.18)
        switch(dateOrNull = parseDate(val))
        case (is Null) { throw ParseException("Variable with name [``key.string``] can't be parsed as Date: ``val``"); }
        else { return dateOrNull; }
    }

    "Get `Time` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class VariableNotFoundException`)
    shared Time getTime(Object key){
        String val = getOrThrowIfNotFound(key);
        // REVIEW: If parseTime throws internally exceptions (Vitaly 08.02.18)
        switch(timeOrNull = parseTime(val))
        case (is Null) { throw ParseException("Variable with name [``key.string``] can't be parsed as Time: ``val``"); }
        else { return timeOrNull; }
    }

    "Get `DateTime` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class VariableNotFoundException`)
    shared DateTime getDateTime(Object key){
        // REVIEW: If parseDateTime throws internally exceptions (Vitaly 08.02.18)
        String val = getOrThrowIfNotFound(key);
        switch(dateTimeOrNull = parseDateTime(val))
        case (is Null) { throw ParseException("Variable with name [``key.string``] can't be parsed as DateTime: ``val``"); }
        else { return dateTimeOrNull; }
    }

    "Get `Boolean` value for given key.
     throws error if value not present or it can not be parsed"
    throws(`class VariableNotFoundException`)
    throws(`class ParseException`)
    shared Boolean getBoolean(Object key){
        String val = getOrThrowIfNotFound(key);
        switch(booleanOrException = Boolean.parse(val))
        case (is ParseException) { throw ParseException("Variable with name [``key.string``] can't be parsed: ``booleanOrException.message``"); }
        else { return booleanOrException; }
    }

    "Get `String` value for given key or null if value is not present or can not be parsed"
    shared String? getStringOrNull(Object key){
        try {
            return getString(key);
        } catch(VariableNotFoundException|ParseException e) {
            log.warn(e.message);
            return null;
        }
    }

    "Get `Integer` value for given key or null if value is not present or can not be parsed"
    shared Integer? getIntegerOrNull(Object key){
        try {
            return getInteger(key);
        } catch(VariableNotFoundException|ParseException e) {
            log.warn(e.message);
            return null;
        }
    }

    "Get `Float` value for given key or null if value is not present or can not be parsed"
    shared Float? getFloatOrNull(Object key){
        try {
            return getFloat(key);
        } catch(VariableNotFoundException|ParseException e) {
            log.warn(e.message);
            return null;
        }
    }

    "Get `Date` value for given key or null if value is not present or can not be parsed"
    shared Date? getDateOrNull(Object key){
        try {
            return getDate(key);
        } catch(VariableNotFoundException|ParseException e) {
            log.warn(e.message);
            return null;
        }
    }

    "Get `Time` value for given key or null if value is not present or can not be parsed"
    shared Time? getTimeOrNull(Object key){
        try {
            return getTime(key);
        } catch(VariableNotFoundException|ParseException e) {
            log.warn(e.message);
            return null;
        }
    }

    "Get `DateTime` value for given key or null if value is not present or can not be parsed"
    shared DateTime? getDateTimeOrNull(Object key){
        try {
            return getDateTime(key);
        } catch(VariableNotFoundException|ParseException e) {
            log.warn(e.message);
            return null;
        }
    }

    "Get `Boolean` value for given key or null if value is not present or can not be parsed"
    shared Boolean? getBooleanOrNull(Object key){
        try {
            return getBoolean(key);
        } catch(VariableNotFoundException|ParseException e) {
            log.warn(e.message);
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

shared class VariableNotFoundException(String varName)
        extends Exception("Variable [``varName``] not found in environment") { }
