import ceylon.test {
    test,
    assertEquals,
    assertThatException
}
import ru.qdzo.ceylon.config {
    sanitize,
    Loader,
    Environment
}

import ceylon.language { createMap = map }

test
shared void sanitizeShouldWork() {
    value keys = [
        "CEYLON_HOME",
        "ceylon-home",
        "ceylon-Home",
        "Ceylon_HoMe"
    ];
    for(sanitized in keys.map(sanitize)){
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

test
shared void shouldParseStrings() {
    object loader extends Loader() {
        load => createMap {
            "string" -> "first",
            "integer" -> "10",
            "float" -> "11.1",
            "boolean" -> "true" // TODO add date/time/datetime
        };
    }

    value env = Environment({loader});
    String str = env.getString("string");
    Integer int = env.getInteger("integer");
    Float flt = env.getFloat("float");
    Boolean bool = env.getBoolean("boolean");
    assertEquals(str, "first");
    assertEquals(int, 10);
    assertEquals(flt, 11.1);
    assertEquals(bool, true);

    // non existing keys
    assertThatException((){
        env.getString("str");
    });
    assertThatException((){
        env.getInteger("int");
    });
    assertThatException((){
        env.getFloat("flt");
    });
    assertThatException((){
        env.getBoolean("bool");
    });

    // wrong type values
    assertThatException((){
        env.getInteger("float");
    });
    assertThatException((){
        env.getFloat("boolean");
    });
    assertThatException((){
        env.getBoolean("string");
    });
}
