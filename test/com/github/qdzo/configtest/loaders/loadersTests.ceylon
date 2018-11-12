import ceylon.interop.java {
    CeylonIterable
}
import ceylon.test {
    test,
    assertEquals
}

import com.github.qdzo.config.loaders {
    systemPropsLoader,
    systemEnvLoader,
    JsonFileLoader,
    TomlFileLoader
}

import java.lang {
    System
}

test
shared void systemPropsLoaderShouldLoadRightPropsSize() {
    value sysProps = systemPropsLoader.load;
    value expectedSize = System.properties.size();
    assertEquals(sysProps.size, expectedSize);
}

test
shared void systemEnvLoaderShouldLoadRightVarsSize() {
    value sysEnv = systemEnvLoader.load;
    value expectedSysEnv = CeylonIterable(System.getenv().keySet());
    value uniqSanitizedExpectedSysEnv = set(expectedSysEnv.map((k) => k.toLowerCase()));
    value expectedSize = uniqSanitizedExpectedSysEnv.size;
    assertEquals(sysEnv.size, expectedSize);
}

test
shared void jsonLoaderShouldLoadVars() {
     value loader = JsonFileLoader("./resource/com/github/qdzo/configtest/config.json");
     value vars = loader.load;
     assertEquals("JsonLoader",            vars["name"]);
     assertEquals("1.0.0",                 vars["version"]);
     assertEquals("01.11.17",              vars["info.day"]);
     assertEquals("00.17",                 vars["info.time"]);
     assertEquals("[\"one\",{\"one\":1}]", vars["info.other"]);
}

test
shared void tomlLoaderShouldLoadVars() {
    value loader = TomlFileLoader("./resource/com/github/qdzo/configtest/config.toml");
    value vars = loader.load;
    assertEquals("Bob",       vars["user.name"]);
    assertEquals("80",        vars["user.age"]);
    assertEquals("private",   vars["server.db"]);
    assertEquals("bob",       vars["server.user"]);
    assertEquals("secret",    vars["server.pass"]);
    assertEquals("3500",      vars["server.port"]);
    assertEquals("ghost.net", vars["server.host"]);
}
