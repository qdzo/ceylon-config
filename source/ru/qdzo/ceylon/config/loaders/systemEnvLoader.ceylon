import ceylon.interop.java {
    CeylonIterable
}
import ru.qdzo.ceylon.config {
    Loader,
    sanitize
}
import ceylon.collection {
    HashMap
}
import java.lang {
    System
}

"Loads variables from system environment variables"
shared object systemEnvLoader extends Loader() {
    load => let(javaEntries = CeylonIterable(System.getenv().entrySet()))
    HashMap { *javaEntries.map((entry) => sanitize(entry.key.string) -> entry.\ivalue.string) };
}
