import ceylon.test {
    test,
    assertEquals
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

