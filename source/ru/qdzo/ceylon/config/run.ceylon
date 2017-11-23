
"Run the module `ru.qdzo.ceylon.config`."

// requireEnv ("user.home", "date")
shared void run() {
//    addLogWriter(writeSimpleLog);
   env.each(print);
    // value hello = ";";
    // print(env.getFloat("java.class.version"));
    // checkEnvRequirements();
    print(configure<SomeConfig>());
}

class SomeConfig(
        environment("db.host")
        shared String host,
        environment("db.port")
        shared Integer port
        ) {
    string => "SomeConfig[host=``host``, port=``port``]";
}
