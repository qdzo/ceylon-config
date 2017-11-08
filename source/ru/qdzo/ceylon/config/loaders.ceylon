import ceylon.collection {
    HashMap
}
import ceylon.file {
    File,
    parsePath,
    lines
}
import ceylon.interop.java {
    CeylonIterable
}
import ceylon.json {
    parseJson=parse,
    JsonObject=Object
}

import java.lang {
    System
}


shared abstract class Loader() {
    shared formal Map<String, String> load;
    equals(Object that) => switch (that)
        case (is Loader) load==that.load
        else false;
    hash => load.hash;
}

Map<String, String> readJsonFile() => map {""->""};
Map<String, String> readTomlFile() => map {""->""};
Map<String, String> readProfileFile() => map {""->""};
Map<String, String> readCustomConfigFile() => map {""->""};

"Loads variables from system environment variables"
object systemEnvLoader extends Loader() {
    load => let(javaEntries = CeylonIterable(System.getenv().entrySet()))
            HashMap { *javaEntries.map((entry) => entry.key.string -> entry.\ivalue.string) };
}

"Loads variables from java system properties"
object systemPropsLoader extends Loader() {
    load => let(javaEntries = CeylonIterable(System.properties.entrySet()))
         HashMap { *javaEntries.map((entry) => entry.key.string -> entry.\ivalue.string) };
}

"Loads variables from  command parameters"
object cmdParamsLoader extends Loader() {
    <String->String>? extractNamedArg(String namedArg) {
        String[2]? nameVal = namedArg.trimLeading('-'.equals).split('='.equals).paired.first;
        return if(exists nameVal) then nameVal[0] -> nameVal[1] else null;
    }
    
    {<String->String>*} geatherSeparateNamedArgs({<Integer->String>*} args) =>
            { for(i->arg in args)
            if(arg.startsWith("-"),
                exists _->val = args.find(forKey((i+1).equals)),
                !val.startsWith("-"))
            arg.trimLeading('-'.equals) -> val };

    shared actual Map<String, String> load {
        value indexedArgs = process.arguments.indexed;
        value argsAsOneWord = indexedArgs.filter((_->arg) => arg.startsWith("-") && arg.contains("="));
        value otherArgs = indexedArgs.filter((entry) => !entry in argsAsOneWord);
        return map(indexedArgs*.item
            .map(extractNamedArg).coalesced
            .chain(geatherSeparateNamedArgs(otherArgs)));
    }
}

"Loads variables from json config.
 all nested path converts to plain with `dot` separator"
class JsonFileLoader(String filename) extends Loader() {
    "filename should ends with .json extension"
    assert(filename.endsWith(".json"));
    "Json file should exists ``filename``"
    assert(is File file = parsePath(filename).resource);

    shared actual Map<String,String> load {
        value fileContent = "\n".join(lines(file));
        "Json file should be with correct structure"
        assert(is JsonObject json = parseJson(fileContent));
        return toPlainPath(json, []);
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

"Loads variables from toml config.
 all nested path converts to plain with `dot` separator"
class TomlFileLoader(String filename) extends Loader() {
    "filename should ends with .toml extension"
    assert(filename.endsWith(".toml"));
    "Toml file should exists ``filename``"
    assert(is File file = parsePath(filename).resource);

    shared actual Map<String,String> load {
        value fileContent = "\n".join(lines(file));
        "Toml file should be with correct structure"
        assert(is JsonObject json = parseJson(fileContent));
        return toPlainPath(json, "");
    }

    String joinPath(String one, String two) => one + "." + two;

    "convert nested objects to plain path with `.`(dot) separator
     *NOTE:* Array will be converted to string"
    Map<String,String> toPlainPath(JsonObject json, String path) => map (
        json.flatMap((key -> item) {
            switch(item)
            case (is JsonObject) {
                return toPlainPath(item, joinPath(path, key));
            }
            else {
                return { key -> (item?.string else "") };
            }
        }));
}
