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
                "ports" -> {80, 3000, 22, 8080, 5000},
                "hosts" -> {"ya.ru", "github.com", "gmail.ru"},
                "coins"->{1.0, 2.1, 3.0, 4.7}
            }
        }
    });
    print(configure<SomeConfig>(e));
}

class SomeConfig(
        envvar("db.host")
        shared String host,

        envvar("db.port")
        shared Integer port,

        envvar("start.date")
        shared Date startDate,

        envvar("start.time")
        shared Time startTime,

        envvar("start.datetime")
        shared DateTime startDateTime,

        envvar("start.price")
        shared Float startPrice,

        envvar("start.ports")
        shared [Integer*] ports,

        envvar("start.hosts")
        shared [String*] hosts,

        envvar("start.coins")
        shared {Float*} coins,
        shared String? desc = null
        ) {
    string => "SomeConfig[ "+
            " host=``host``"+
            " port=``port``"+
            " startDate=``startDate``"+
            " startTime=``startTime``"+
            " startDateTime=``startDateTime``"+
            " startPrice=``startPrice``"+
            " ports=``ports``"+
            " hosts=``hosts``"+
            " coins=``coins``"+
            " ]";
}
