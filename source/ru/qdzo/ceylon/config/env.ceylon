import ru.qdzo.ceylon.config.loaders {
    cmdParamsLoader,
    systemPropsLoader,
    defaultJsonConfigLoader,
    defaultTomlConfigLoader,
    CustomConfigLoader,
    systemEnvLoader
}
/*
    loads config.json
    loads config.toml
    loads profile configs
    loads ENV vars
    loads custom config file
    loads cmd params
    loads system properties
*/

"Creates environment singleton on first usage"
shared late Environment env = Environment(loaders);


variable Set<Loader> _loaders = set {
    defaultJsonConfigLoader,
    defaultTomlConfigLoader,
    CustomConfigLoader(profileJsonConfig else ""),
    CustomConfigLoader(profileTomlConfig else ""),
    systemEnvLoader,
    CustomConfigLoader(process.namedArgumentValue("config") else ""),
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

String? profileJsonConfig =>
        let(profile = process.environmentVariableValue("PROFILE"))
        if (exists profile)
        then "env/``profile``/config.json"
        else null;

String? profileTomlConfig =>
        let(profile = process.environmentVariableValue("PROFILE"))
        if (exists profile)
        then "env/``profile``/config.toml"
        else null;

