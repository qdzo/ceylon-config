import ceylon.file {
    parsePath,
    lines,
    File
}
import ceylon.json {
    JsonObject,
    parseJson = parse
}
import ru.qdzo.ceylon.config {
    Loader,
    sanitize
}

"Loads config.json stored in same dir where application starts"
shared JsonFileLoader defaultJsonConfigLoader = JsonFileLoader("config.json");

"Loads variables from json config.
 all nested path converts to plain with `dot` separator"
shared class JsonFileLoader extends Loader {
    Loader loader;
    shared new (String filename) extends Loader() {
        "filename should ends with .json extension"
        assert(filename.endsWith(".json"));
        "file should exists ``filename``"
        assert(is File file = parsePath(filename).resource);
        value fileContent = "\n".join(lines(file));
        loader = JsonLoader(fileContent);
    }
    shared actual Map<String,String> load => loader.load;
}

"Loads variables from json config.
 all nested path converts to plain with `dot` separator"
shared class JsonLoader(String jsonString) extends Loader() {

    shared actual Map<String,String> load {
        if(is JsonObject json = parseJson(jsonString)) { // TODO maybe parseJson move to JsonFileLoader
            return toPlainPath(json, []);
        }
        log.warn("Json should be with correct structure: ``jsonString``");
        return emptyMap;
    }

    "convert nested objects to plain path with `.`(dot) separator
     *NOTE:* Array will be converted to string"
    Map<String,String> toPlainPath(JsonObject json, [String*] path) => map (
        json.flatMap((key -> item) {
            switch(item)
            case (is JsonObject) {
                return toPlainPath(item, path.append([key]));
            }
            else {
                value pathKey = ".".join(path.append([key]));
                return { sanitize(pathKey) -> (item?.string else "") };
            }
        }));
}
