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
    load => let(javaPrors = CeylonIterable(System.properties.entrySet()))
    HashMap { for(prop in javaPrors) sanitize(prop.key.string) -> prop.\ivalue.string };
}
