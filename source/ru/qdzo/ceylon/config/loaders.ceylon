import ceylon.interop.java {
    CeylonIterable
}

import java.lang {
    System
}
import ceylon.collection {
    HashMap
}

Map<String, String> readJsonFile() => map {""->""};
Map<String, String> readTomlFile() => map {""->""};
Map<String, String> readPropertiesFile() => map {""->""};
Map<String, String> readProfileFile() => map {""->""};
Map<String, String> readCustomConfigFile() => map {""->""};
Map<String, String> readCmdParams() => map {""->""};

Map<String, String> readSystemEnv() =>
        let(javaEntries = CeylonIterable(System.getenv().entrySet()))
        HashMap { *javaEntries.map((entry) => entry.key.string -> entry.\ivalue.string) };

Map<String, String> readSystemProps() =>
        let(javaEntries = CeylonIterable(System.properties.entrySet()))
        HashMap { *javaEntries.map((entry) => entry.key.string -> entry.\ivalue.string) };

