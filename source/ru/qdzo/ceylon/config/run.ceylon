import ceylon.time {
    Date,
    Time,
    DateTime,
    now
}

import ru.qdzo.ceylon.config.loaders {
    MapLoader
}

"Run the module `ru.qdzo.ceylon.config`."

// requireEnv ("user.home", "date")
shared void run() {
//    addLogWriter(writeSimpleLog);
//   env.each(print);
    // value hello = ";";
    // print(env.getFloat("java.class.version"));
    // checkEnvRequirements();
    value e = Environment({
        MapLoader {
            "db"-> map {
                "host" -> "net",
                "port" -> 8080
            },
            "start" -> map {
                "date"-> now().date(),
                "time"-> now().time(),
                "dateTime" -> now().dateTime(),
                "price" -> 7.0,
                "coins" -> {1, 3 ,4 ,5 ,6}
            }
        }
    });
    print(configure<SomeConfig>(e));
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

        environment("start.datetime")
        shared DateTime startDateTime,

        environment("start.price")
        shared Float startPrice,

        environment("start.coins")
        shared [Integer*] coins
        ) {
    string => "SomeConfig[ "+
            " host=``host``"+
            " port=``port``"+
            " startDate=``startDate``"+
            " startTime=``startTime``"+
            " startDateTime=``startDateTime``"+
            " startPrice=``startPrice``"+
            " coins=``coins``"+
    " ]";
}
