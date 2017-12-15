import ru.qdzo.ceylon.config.loaders {
    cmdParamsLoader,
    systemPropsLoader,
    CustomConfigFileLoader,
    systemEnvLoader,
    JsonFileLoader,
    TomlFileLoader
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

Set<Loader> _loaders = set {
    defaultJsonConfigLoader,
    defaultTomlConfigLoader,
    profileJsonConfigLoader,
    profileTomlConfigLoader,
    systemEnvLoader,
    customConfigFileLoader,
    cmdParamsLoader,
    systemPropsLoader
};

shared Set<Loader> loaders = _loaders;

"Loads config.json stored in same dir where application starts"
shared Loader defaultJsonConfigLoader = JsonFileLoader("config.json");

"Loads config.toml stored in same dir where application starts"
shared Loader defaultTomlConfigLoader = TomlFileLoader("config.toml");

"Loads `/config/${PROFILE}/config.json` file"
shared Loader profileJsonConfigLoader =
        JsonFileLoader(profileJsonConfigFileName else "");

"Loads `/config/${PROFILE}/config.toml` file"
shared Loader profileTomlConfigLoader =
        TomlFileLoader(profileTomlConfigFileName else "");

"Loads config file specified by `--config` cmd parameter"
shared Loader customConfigFileLoader =
        CustomConfigFileLoader(customConfigFileName else "");

String? customConfigFileName = process.namedArgumentValue("config");

String? profileDir =>
        if (exists profile = process.environmentVariableValue("PROFILE"))
        then "config/``profile``"
        else null;

String? profileJsonConfigFileName =>
        if (exists dir = profileDir)
        then "``dir``/config.json"
        else null;

String? profileTomlConfigFileName =>
        if (exists dir = profileDir)
        then "``dir``/config.toml"
        else null;
