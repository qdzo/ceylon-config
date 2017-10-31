import ceylon.interop.java {
    CeylonIterable
}

import java.lang {
    System
}
import ceylon.collection {
    HashMap
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
