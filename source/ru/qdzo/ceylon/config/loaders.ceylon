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
Map<String, String> readPropertiesFile() => map {""->""};
Map<String, String> readProfileFile() => map {""->""};
Map<String, String> readCustomConfigFile() => map {""->""};
Map<String, String> readCmdParams() => map {""->""};

object systemEnvLoader extends Loader() {
    load => let(javaEntries = CeylonIterable(System.getenv().entrySet()))
            HashMap { *javaEntries.map((entry) => entry.key.string -> entry.\ivalue.string) };
}

object systemPropsLoader extends Loader() {
    load => let(javaEntries = CeylonIterable(System.properties.entrySet()))
         HashMap { *javaEntries.map((entry) => entry.key.string -> entry.\ivalue.string) };
}

object cmdParamsLoader extends Loader() {
    load => HashMap { };
}
//value args = arguments;
//for (i in 0:args.size) {
//            assert (exists arg = args[i]);
//            if (arg.startsWith("-``name``=")) {
//                return arg.removeInitial("-``name``=");
//            }
//            if (arg.startsWith("--``name``=")) {
//                return arg.removeInitial("--``name``=");
//            }
//            if (arg == "-" + name ||
//                arg == "--" + name) {
//                return
//                if (exists next = args[i+1],
//                    !next.startsWith("-"))
//                then next
//                else null;
//            }
//        }
//        else {
//            return null;
//        }
//    }
