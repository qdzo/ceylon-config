import ceylon.json {
    JsonObject,
    parseJson=parse
}

import ru.qdzo.ceylon.config {
    Loader,
    readFile,
    flattenMap,
    sanitizeVar
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
        assert(exists fileContent = readFile(filename));
        loader = JsonLoader(fileContent);
    }
    shared actual Map<String,String> load => loader.load;
}

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
