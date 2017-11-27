import ceylon.test {
    test,
    assertEquals,
    assertThatException
}
import ru.qdzo.ceylon.config {
    sanitizeKey,
    Loader,
    Environment
}

import ceylon.language { createMap = map }
import ceylon.time {
    Date,
    Time,
    DateTime,
    createDate = date,
    createTime = time,
    createDateTime = dateTime
}

test
shared void sanitizeShouldWork() {
    value keys = [
        "CEYLON_HOME",
        "ceylon-home",
        "ceylon-Home",
        "Ceylon_HoMe"
    ];
    for(sanitized in keys.map(sanitizeKey)){
        assertEquals(sanitized, "ceylon.home");
    }
}


test
shared void environmentShouldOverrideVariablesInRightOrder() {
    object firstLoader extends Loader() {
        load => createMap {"key" -> "first"};
    }
    object secondLoader extends Loader() {
        load => createMap {"key" -> "second"};
    }

    value env = Environment({firstLoader, secondLoader});
    assert(exists val = env["key"]);
    assertEquals(val, "second");
}

Environment testEnv = Environment {
    object extends Loader() {
        load => createMap {
            "string" -> "first",
            "integer" -> "10",
            "float" -> "11.1",
            "boolean" -> "true",
            "date" -> "2017-11-15",
            "time" -> "19:44:54.301",
            "datetime" -> "2017-11-15T19:44:54.303"
        };
    }
};

test
shared void shouldParseStrings() {
    String str = testEnv.getString("string");
    Integer int = testEnv.getInteger("integer");
    Float flt = testEnv.getFloat("float");
    Boolean bool = testEnv.getBoolean("boolean");
    Date date = testEnv.getDate("date");
    Time time = testEnv.getTime("time");
    DateTime dateTime = testEnv.getDateTime("datetime");
    assertEquals(str, "first");
    assertEquals(int, 10);
    assertEquals(flt, 11.1);
    assertEquals(bool, true);
    assertEquals(date, createDate(2017, 11, 15));
    assertEquals(time, createTime(19, 44, 54, 301));
    assertEquals(dateTime, createDateTime(2017, 11, 15, 19, 44, 54, 303));
}

test
shared void shouldThrowExceptionOnGettingNonExistentVariable() {
    // non existing keys
    assertThatException((){
        testEnv.getString("str");
    });
    assertThatException((){
        testEnv.getInteger("int");
    });
    assertThatException((){
        testEnv.getFloat("flt");
    });
    assertThatException((){
        testEnv.getBoolean("bool");
    });
    assertThatException((){
        testEnv.getDate("dat");
    });
    assertThatException((){
        testEnv.getTime("tim");
    });
    assertThatException((){
        testEnv.getDateTime("dattim");
    });

}

test
shared void shouldThrowExceptionOnGettingWrongVariableType() {
    assertThatException((){
        testEnv.getInteger("float");
    });
    assertThatException((){
        testEnv.getFloat("boolean");
    });
    assertThatException((){
        testEnv.getBoolean("string");
    });
    assertThatException((){
        testEnv.getDate("time");
    });
    assertThatException((){
        testEnv.getTime("datetime");
    });
    assertThatException((){
        testEnv.getDateTime("date");
    });
}

test
shared void shouldParseStrings2() {
    assert(is String str = testEnv.getStringOrNull("string"));
    assert(is Integer int = testEnv.getIntegerOrNull("integer"));
    assert(is Float flt = testEnv.getFloatOrNull("float"));
    assert(is Boolean bool = testEnv.getBooleanOrNull("boolean"));
    assert(is Date date = testEnv.getDateOrNull("date"));
    assert(is Time time = testEnv.getTimeOrNull("time"));
    assert(is DateTime dateTime = testEnv.getDateTimeOrNull("datetime"));
    assertEquals(str, "first");
    assertEquals(int, 10);
    assertEquals(flt, 11.1);
    assertEquals(bool, true);
    assertEquals(date, createDate(2017, 11, 15));
    assertEquals(time, createTime(19, 44, 54, 301));
    assertEquals(dateTime, createDateTime(2017, 11, 15, 19, 44, 54, 303));
}

test
shared void shouldReturnNullOnGettingNonExistentVariable() {
    // non existing keys
    assert(is Null str = testEnv.getStringOrNull("str"));
    assert(is Null int = testEnv.getIntegerOrNull("int"));
    assert(is Null flt = testEnv.getFloatOrNull("flt"));
    assert(is Null bool = testEnv.getBooleanOrNull("bool"));
    assert(is Null dat = testEnv.getDateOrNull("dat"));
    assert(is Null tim = testEnv.getTimeOrNull("tim"));
    assert(is Null dattim = testEnv.getDateTimeOrNull("dattim"));
}

test
shared void shouldReturnNullOnGettingWrongVariableType() {
    assert(is Null int = testEnv.getIntegerOrNull("float"));
    assert(is Null flt = testEnv.getFloatOrNull("boolean"));
    assert(is Null boo = testEnv.getBooleanOrNull("string"));
    assert(is Null dat = testEnv.getDateOrNull("time"));
    assert(is Null tim = testEnv.getTimeOrNull("datetime"));
    assert(is Null dattim = testEnv.getDateTimeOrNull("date"));
}
