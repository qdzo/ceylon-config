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
    Loader
}

"Loads config.toml stored in same dir where application starts"
shared TomlFileLoader defaultTomlConfigLoader = TomlFileLoader("config.toml");

"Loads variables from toml config.
 all nested path converts to plain with `dot` separator"
shared class TomlFileLoader(String filename) extends Loader() {
    "filename should ends with .toml extension"
    assert(filename.endsWith(".toml"));

    shared actual Map<String,String> load {
        if(is File file = parsePath(filename).resource) {
            value fileContent = "\n".join(lines(file));
            "Toml file should be with correct structure"
            assert (is TomlTable toml = parseToml(fileContent));
            return toPlainPath(toml, []);
        }
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
                return { pathKey -> item.string };
            }
        }));
}
