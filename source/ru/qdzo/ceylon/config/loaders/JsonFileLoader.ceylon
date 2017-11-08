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
    Loader
}

"Loads variables from json config.
 all nested path converts to plain with `dot` separator"
shared class JsonFileLoader(String filename) extends Loader() {
    "filename should ends with .json extension"
    assert(filename.endsWith(".json"));

    shared actual Map<String,String> load {
        if(is File file = parsePath(filename).resource) {
            value fileContent = "\n".join(lines(file));
            "Json file should be with correct structure"
            assert(is JsonObject json = parseJson(fileContent));
            return toPlainPath(json, []);
        }
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
                return { pathKey -> (item?.string else "") };
            }
        }));
}
