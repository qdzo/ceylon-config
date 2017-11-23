import ceylon.file {
    parsePath,
    lines,
    File
}
import ceylon.toml {
    TomlTable,
    parseToml
}

import ru.qdzo.ceylon.config {
    Loader,
    sanitize
}

"Loads config.toml stored in same dir where application starts"
shared TomlFileLoader defaultTomlConfigLoader = TomlFileLoader("config.toml");

"Loads variables from toml config.
 all nested path converts to plain with `dot` separator"
shared class TomlFileLoader extends Loader {
    Loader loader;
    shared new (String filename) extends Loader() {
        "filename should ends with .toml extension"
        assert(filename.endsWith(".toml"));
        assert(is File file = parsePath(filename).resource);
        value fileContent = "\n".join(lines(file));
        loader = TomlLoader(fileContent);
    }

    shared actual Map<String,String> load => loader.load;
}

"Loads variables from toml config.
 all nested path converts to plain with `dot` separator"
shared class TomlLoader(String tomlAsString) extends Loader() {

    shared actual Map<String,String> load {
        if(is TomlTable toml = parseToml(tomlAsString)) { // TODO maybe parseToml move to TomlFileLoader
            return toPlainPath(toml, []);
        }
        log.warn("TomlLoader: not load: Toml should be with correct structure\n``tomlAsString``");
        return emptyMap;
    }

    "convert nested objects to plain path with `.`(dot) separator
     *NOTE:* Array will be converted to string"
    Map<String,String> toPlainPath(TomlTable toml, [String*] path) => map (
        toml.flatMap((key -> item) {
            switch(item)
            case (is TomlTable) {
                return toPlainPath(item, path.append([key]));
            }
            else {
                value pathKey = ".".join(path.append([key]));
                return { sanitize(pathKey) -> item.string };
            }
        }));
}
