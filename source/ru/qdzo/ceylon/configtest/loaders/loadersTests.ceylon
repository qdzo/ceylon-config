import ru.qdzo.ceylon.config.loaders {
    systemPropsLoader,
    systemEnvLoader,
    JsonFileLoader,
    TomlFileLoader
}
import ceylon.test {
    test,
    assertEquals
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
    value expectedSize = System.getenv().size();
    assertEquals(sysEnv.size, expectedSize);
}

test
shared void jsonLoaderShouldLoadVars() {
     value loader = JsonFileLoader("./resource/ru/qdzo/ceylon/configtest/config.json");
     value vars = loader.load;
     assertEquals("JsonLoader",            vars["name"]);
     assertEquals("1.0.0",                 vars["version"]);
     assertEquals("01.11.17",              vars["info.day"]);
     assertEquals("00.17",                 vars["info.time"]);
     assertEquals("[\"one\",{\"one\":1}]", vars["info.other"]);
}

test
shared void tomlLoaderShouldLoadVars() {
    value loader = TomlFileLoader("./resource/ru/qdzo/ceylon/configtest/config.toml");
    value vars = loader.load;
    assertEquals("Bob",       vars["user.name"]);
    assertEquals("80",        vars["user.age"]);
    assertEquals("private",   vars["server.db"]);
    assertEquals("bob",       vars["server.user"]);
    assertEquals("secret",    vars["server.pass"]);
    assertEquals("3500",      vars["server.port"]);
    assertEquals("ghost.net", vars["server.host"]);
}
