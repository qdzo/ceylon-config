
"Run the module `ru.qdzo.ceylon.config`."

// requireEnv ("user.home", "date")
shared void run() {
//    addLogWriter(writeSimpleLog);
   env.each(print);
    // value hello = ";";
    // print(env.getFloat("java.class.version"));
    // checkEnvRequirements();
}
