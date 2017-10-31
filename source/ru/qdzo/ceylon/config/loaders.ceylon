import ceylon.collection {
    HashMap,
    ArrayList,
    MutableMap
}
import ceylon.file {
    File,
    parsePath,
    lines,
    current
}
import ceylon.interop.java {
    CeylonIterable
}
import ceylon.json {
    parseJson = parse,
    JsonObject = Object,
    JsonVisitor = Visitor,
    JsonValue = Value,
    JsonArray = Array,
    visit
}
import ceylon.language.meta {
    type
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

object systemEnvLoader extends Loader() {
    load => let(javaEntries = CeylonIterable(System.getenv().entrySet()))
            HashMap { *javaEntries.map((entry) => entry.key.string -> entry.\ivalue.string) };
}

object systemPropsLoader extends Loader() {
    load => let(javaEntries = CeylonIterable(System.properties.entrySet()))
         HashMap { *javaEntries.map((entry) => entry.key.string -> entry.\ivalue.string) };
}

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

class JsonFileLoader(String filename) extends Loader() {
    "filename should ends with .json extension"
    assert(filename.endsWith(".json"));
    
    shared actual Map<String,String> load {
        if(is File file = parsePath(filename).resource) {
            value fileContent = "\n".join(lines(file));
            if(is JsonObject json = parseJson(fileContent)) {
                value builder = JsonConfigBuilder();
                visit(json, builder);
                return builder.props2;
            }

        }
        return nothing;
    }
}


shared class JsonConfigBuilder() satisfies JsonVisitor {

    ArrayList<JsonValue> stack = ArrayList<JsonValue>();
    variable Integer onArray = 0;
    ArrayList<String> pathStack = ArrayList<String>();
    MutableMap<String, String> props = HashMap<String, String> {};

    //variable Value? current = null;
    variable String? currentKey = null;

    shared Map<String, String> props2 {
        if(pathStack.size == 0, !currentKey exists) {
            return props;
        } else  {
            assert(false);
        }
    }

    void putPropValue(String val) {
        if(exists ck = currentKey){
            props.put(".".join(pathStack.chain({ck})), val);
        }
    }

    "The constructed [[Value]]."
    throws(`class AssertionError`,
        "The builder has not yet seen enough input to return a fully formed JSON value.")
    shared JsonValue result {
        if (stack.size == 1,
            ! currentKey exists) {
            return stack.pop();
        } else {
            throw AssertionError("currenyKey=``currentKey else "null" ``, stack=``stack``");
        }
    }

    void addToCurrent(JsonValue v) {
        value current = stack.last;
        switch(current)
        case (is JsonObject) {
            if (exists ck=currentKey) {
                if (exists old = current.put(ck, v)) {
                    throw AssertionError("duplicate key ``ck``");
                }
                currentKey = null;
            } else {
                "value within object without key"
                assert(false);
            }
        }
        case (is JsonArray) {
            current.add(v);
        }
        case (is Null) {

        }
        else {
            throw AssertionError("cannot add value to ``type(current)``");
        }
    }

    void push(JsonValue v) {
        if (stack.empty) {
            stack.push(v);
        }
        if (v is JsonObject|JsonArray) {
            stack.push(v);
        }
    }

    void pop() {
        stack.pop();
    }

    shared actual void onStartObject() {
        if(onArray == 0, exists ck = currentKey) {
            pathStack.push(ck);
        }
        JsonObject newObj = JsonObject{};
        addToCurrent(newObj);
        push(newObj);
    }
    shared actual void onKey(String key) {
        this.currentKey = key;
    }

    shared actual void onEndObject() {
        if(onArray == 0) {
            pathStack.pop();
        }
        pop();
    }
    shared actual void onStartArray() {
        onArray++;
        JsonArray newArray = JsonArray();
        addToCurrent(newArray);
        push(newArray);
    }

    shared actual void onEndArray() {
        if(onArray > 0) {
            onArray--;
        }
        pop();
    }
    shared actual void onNumber(Integer|Float num) {
        putPropValue(num.string);
        addToCurrent(num);
        push(num);
    }
    shared actual void onBoolean(Boolean bool) {
        putPropValue(bool.string);
        addToCurrent(bool);
        push(bool);
    }
    shared actual void onNull() {
//        putPropValue("null");
        addToCurrent(null);
        push(null);
    }

    shared actual void onString(String string) {
        putPropValue(string);
        addToCurrent(string);
        push(string);
    }
}
