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

import com.github.qdzo.config {
    sanitizeKey,
    Loader,
    Environment,
    envVar,
    configure
}
import com.github.qdzo.config.loaders {
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
    String str = testEnv.requireString("string");
    Integer int = testEnv.requireInteger("integer");
    Float flt = testEnv.requireFloat("float");
    Boolean bool = testEnv.requireBoolean("boolean");
    Date date = testEnv.requireDate("date");
    Time time = testEnv.requireTime("time");
    DateTime dateTime = testEnv.requireDateTime("datetime");
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
        testEnv.requireString("str");
    });
    assertThatException((){
        testEnv.requireInteger("int");
    });
    assertThatException((){
        testEnv.requireFloat("flt");
    });
    assertThatException((){
        testEnv.requireBoolean("bool");
    });
    assertThatException((){
        testEnv.requireDate("dat");
    });
    assertThatException((){
        testEnv.requireTime("tim");
    });
    assertThatException((){
        testEnv.requireDateTime("dattim");
    });

}

test
shared void shouldThrowExceptionOnGettingWrongVariableType() {
    assertThatException((){
        testEnv.requireInteger("float");
    });
    assertThatException((){
        testEnv.requireFloat("boolean");
    });
    assertThatException((){
        testEnv.requireBoolean("string");
    });
    assertThatException((){
        testEnv.requireDate("time");
    });
    assertThatException((){
        testEnv.requireTime("datetime");
    });
    assertThatException((){
        testEnv.requireDateTime("date");
    });
}

test
shared void shouldParseStrings2() {
    assert(is String str = testEnv.getString("string"));
    assert(is Integer int = testEnv.getInteger("integer"));
    assert(is Float flt = testEnv.getFloat("float"));
    assert(is Boolean bool = testEnv.getBoolean("boolean"));
    assert(is Date date = testEnv.getDate("date"));
    assert(is Time time = testEnv.getTime("time"));
    assert(is DateTime dateTime = testEnv.getDateTime("datetime"));
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
    assert(is Null str = testEnv.getString("str"));
    assert(is Null int = testEnv.getInteger("int"));
    assert(is Null flt = testEnv.getFloat("flt"));
    assert(is Null bool = testEnv.getBoolean("bool"));
    assert(is Null dat = testEnv.getDate("dat"));
    assert(is Null tim = testEnv.getTime("tim"));
    assert(is Null dattim = testEnv.getDateTime("dattim"));
}

test
shared void shouldReturnNullOnGettingWrongVariableType() {
    assert(is Null int = testEnv.getInteger("float"));
    assert(is Null flt = testEnv.getFloat("boolean"));
    assert(is Null boo = testEnv.getBoolean("string"));
    assert(is Null dat = testEnv.getDate("time"));
    assert(is Null tim = testEnv.getTime("datetime"));
    assert(is Null dattim = testEnv.getDateTime("date"));
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

