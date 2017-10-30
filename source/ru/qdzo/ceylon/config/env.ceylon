/*
  env[] object
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
    readJsonFile,
    readTomlFile,
    readPropertiesFile,
    readProfileFile,
    readCustomConfigFile,
    readCmdParams,
    readSystemEnv,
    readSystemProps
};

"Crates environment singleton on first usage"
shared late Environment env = Environment();
shared sealed class Environment() satisfies Map<String, String> {

    late Map<String, String> envVars = initEnv();

    Map<String, String> initEnv() {
        assert(exists firstLoader = loaders.first);
        return loaders.rest.fold(firstLoader(), (envMap, loader) => envMap.patch(loader()));
    }

    shared actual Boolean defines(Object key) => get(key) exists;

    shared actual String? get(Object key) => envVars[key.string];

    shared String? reactive(Object key)() => // TODO think about this
            process.propertyValue(key.string)
            else  process.environmentVariableValue(key.string)
            else process.namedArgumentValue(key.string)
            else envVars[key.string];

    shared actual Iterator<String->String> iterator() => envVars.iterator();

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
