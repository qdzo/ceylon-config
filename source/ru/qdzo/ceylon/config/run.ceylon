"Run the module `ru.qdzo.ceylon.config`."

shared void run() {
//    env.each(print);
//    systemEnvLoader.load.each(print);
//    cmdParamsLoader.load.each(print);
//    JsonFileLoader("config.json").load.each(print);
    TomlFileLoader("config.toml").load.each(print);
}
