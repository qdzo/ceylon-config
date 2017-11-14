import ru.qdzo.ceylon.config.loaders {
    systemPropsLoader,
    systemEnvLoader
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

