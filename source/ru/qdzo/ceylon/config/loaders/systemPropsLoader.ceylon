import ceylon.interop.java {
    CeylonIterable
}
import ru.qdzo.ceylon.config {
    Loader,
    sanitize
}
import java.lang {
    System
}
import ceylon.collection {
    HashMap
}

"Loads variables from java system properties"
shared object systemPropsLoader extends Loader() {
    load => let(javaEntries = CeylonIterable(System.properties.entrySet()))
    HashMap { *javaEntries.map((entry) => sanitize(entry.key.string) -> entry.\ivalue.string) };
}
