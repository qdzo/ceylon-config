import ceylon.json {
    JsonObject,
    parseJson=parse
}

import ru.qdzo.ceylon.config {
    Loader,
    flattenMap,
    sanitizeVar
}

"Loads variables from json config.
 all nested path converts to plain with `dot` separator"
shared class JsonFileLoader(String filename)
        extends FileLoader(filename, JsonLoader) {}

"Loads variables from json config.
 all nested path converts to plain with `dot` separator"
shared class JsonLoader(String jsonString) extends Loader() {

    shared actual Map<String,String> load {
        if(is JsonObject json = parseJson(jsonString)) { // TODO maybe parseJson move to JsonFileLoader
            return map(flattenMap(json, []).map(sanitizeVar));
        }
        log.warn("Json should be with correct structure: ``jsonString``");
        return emptyMap;
    }
}
