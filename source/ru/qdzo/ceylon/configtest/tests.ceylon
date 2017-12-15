import ceylon.language {
    createMap=map
}
import ceylon.test {
    test,
    assertEquals,
    assertThatException
}
import ceylon.time {
    Date,
    Time,
    DateTime,
    createDate=date,
    createTime=time,
    createDateTime=dateTime,
    now
}

import ru.qdzo.ceylon.config {
    sanitizeKey,
    Loader,
    Environment,
    envVar,
    configure
}
import ru.qdzo.ceylon.config.loaders {
    MapLoader
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


class SomeConfig(
        envVar ("db.host")
        shared String host,

        envVar ("db.port")
        shared Integer port,

        envVar ("start.date")
        shared Date startDate,

        envVar ("start.time")
        shared Time startTime,

        envVar ("start.datetime")
        shared DateTime startDateTime,

        envVar ("start.rank")
        shared Float startRank,

        envVar ("start.ports")
        shared [Integer*] ports,

        envVar ("start.hosts")
        shared [String*] hosts,

        envVar ("floats")
        shared {Float*} floats,
        shared String? desc = null
        ) {

    shared actual Boolean equals(Object that) {
        if (is SomeConfig that) {
            return host==that.host &&
                port==that.port &&
                startDate==that.startDate &&
                startTime==that.startTime &&
                startDateTime==that.startDateTime &&
                startRank==that.startRank &&
                ports==that.ports &&
                hosts==that.hosts &&
                floats.sequence() ==that.floats.sequence();
        }
        else {
            return false;
        }
    }

    shared actual Integer hash {
        variable value hash = 1;
        hash = 31*hash + host.hash;
        hash = 31*hash + port;
        hash = 31*hash + startDate.hash;
        hash = 31*hash + startTime.hash;
        hash = 31*hash + startDateTime.hash;
        hash = 31*hash + startRank.hash;
        hash = 31*hash + ports.hash;
        hash = 31*hash + hosts.hash;
        hash = 31*hash + floats.hash;
        return hash;
    }
     }

test
shared void injectorShouldInjectValues() {
    value d = now().date();
    value t = now().time();
    value dt = now().dateTime();

    value e = Environment({
        MapLoader {
            "db"-> map {
                "host" -> "net",
                "port" -> 8080
            },
            "start" -> map {
                "date"-> d,
                "time"-> t,
                "dateTime" -> dt,
                "rank" -> 7.0,
                "ports" -> {80, 3000, 22, 8080, 5000},
                "hosts" -> {"ya.ru", "github.com", "gmail.ru"}
            },
            "floats"->{1.0, 2.1, 3.0, 4.7}
        }
    });
    assertEquals {
        actual = configure<SomeConfig>(e);
        expected = SomeConfig {
            host = "net";
            port = 8080;
            startDate = d;
            startTime = t;
            startDateTime = dt;
            startRank = 7.0;
            ports = [80, 3000, 22, 8080, 5000];
            hosts = ["ya.ru", "github.com", "gmail.ru"];
            floats = [1.0, 2.1, 3.0, 4.7];
        };
    };
}

