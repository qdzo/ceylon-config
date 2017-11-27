import ceylon.toml {
    TomlTable,
    parseToml
}

import ru.qdzo.ceylon.config {
    Loader,
    flattenMap,
    sanitizeVar
}

"Loads config.toml stored in same dir where application starts"
shared TomlFileLoader defaultTomlConfigLoader = TomlFileLoader("config.toml");

"Loads variables from toml config.
 all nested path converts to plain with `dot` separator"
shared class TomlFileLoader(String filename)
        extends FileLoader(filename, TomlLoader) {}

"Loads variables from toml config.
 all nested path converts to plain with `dot` separator"
shared class TomlLoader(String tomlAsString) extends Loader() {

    shared actual Map<String,String> load {
        if(is TomlTable toml = parseToml(tomlAsString)) { // TODO maybe parseToml move to TomlFileLoader
            return map(flattenMap(toml, []).map(sanitizeVar));
        }
        log.warn("TomlLoader: not load: Toml should be with correct structure\n``tomlAsString``");
        return emptyMap;
    }
}
