import ceylon.time {
    Date,
    Time,
    DateTime
}

"Run the module `ru.qdzo.ceylon.config`."

// requireEnv ("user.home", "date")
shared void run() {
//    addLogWriter(writeSimpleLog);
//   env.each(print);
    // value hello = ";";
    // print(env.getFloat("java.class.version"));
    // checkEnvRequirements();
    print(configure<SomeConfig>());
}

class SomeConfig(
        environment("db.host")
        shared String host,

        environment("db.port")
        shared Integer port,

        environment("start.date")
        shared Date startDate,

        environment("start.time")
        shared Time startTime,

        environment("start.dateTime")
        shared DateTime startDateTime,

        environment("start.price")
        shared Float startPrice
        ) {
    string => "SomeConfig[host=``host``, port=``port``]";
}
