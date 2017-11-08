import ceylon.collection {
    HashMap
}
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

variable Set<Loader> _loaders = set {
//    readJsonFile,
//    readTomlFile,
//    readProfileFile,
//    systemEnvLoader,
//    readCustomConfigFile,
    cmdParamsLoader,
    systemPropsLoader
};

"registers loader  with lowest priority"
shared void registerLoader(Loader loader) {
    _loaders = set(_loaders.follow(loader));
}

"registers loader  with lowest priority"
shared void unregisterLoader(Loader loader) {
    _loaders = set(_loaders.filter(not(loader.equals)));
}

shared Set<Loader> loaders = _loaders;

"Crates environment singleton on first usage"
shared late Environment env = Environment();

shared sealed class Environment() satisfies Map<String, String> {

    late Map<String, String> envVars = initEnv();

    Map<String, String> initEnv() {
        variable Map<String, String> tempMap = HashMap {};
        for (loader in loaders) {
            tempMap = tempMap.patch(loader.load);
        }
        return tempMap;
    }

    defines(Object key) => get(key) exists;

    get(Object key) => envVars[key.string];

    shared String? reactive(Object key)() => // TODO think about this
            process.propertyValue(key.string)
            else  process.environmentVariableValue(key.string)
            else process.namedArgumentValue(key.string)
            else envVars[key.string];

    iterator() => envVars.iterator();

    equals(Object that) =>
            if (is Environment that)
            then envVars==that.envVars
            else false;

    hash => envVars.hash;

}
