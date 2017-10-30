import ceylon.collection {
    HashMap
}
import ceylon.interop.java {
    CeylonIterable
}

import java.lang {
    System
}

/*
  env[]
  Environment();
    loads config.json
    loads config.toml
    loads config.properties
    profiles files?
    custom config file
    cmd params
    ENV
    system properties
*/


shared void registerLoader(Map<String,String>() loader) {
    loaders = set(loaders.follow(loader));
}
variable Set<Map<String,String>()> loaders = set {
    readJsonFile(),
    readTomlFile(),
    readPropertiesFile(),
    readProfileFile(),
    readCustomConfigFile(),
    readCmdParams(),
    readSystemEnv(),
    readSystemProps(),
};
"Crates environment singleton on first usage"
shared late Environment env = Environment();
shared sealed class Environment() satisfies Map<String, String> {

    late Map<String, String> envVars = initEnv();
    shared actual Boolean defines(Object key) => get(key) exists;

    shared actual String? get(Object key) =>
            process.propertyValue(key.string)
            else  process.environmentVariableValue(key.string)
            else process.namedArgumentValue(key.string)
            else envVars[key.string];

    shared actual Iterator<String->String> iterator() => envVars.iterator(); // TODO add true iterator. with property/environment/args

    Map<String, String> initEnv() {
        return readJsonFile()
            .patch(readTomlFile())
            .patch(readPropertiesFile())
            .patch(readProfileFile())
            .patch(readCustomConfigFile())
            .patch(readCmdParams())
            .patch(readSystemEnv())
            .patch(readSystemProps());
    };
    
    shared actual Boolean equals(Object that) {
        if (is Environment that) {
            return envVars==that.envVars;
        }
        else {
            return false;
        }
    }

    shared actual Integer hash => envVars.hash;

}
