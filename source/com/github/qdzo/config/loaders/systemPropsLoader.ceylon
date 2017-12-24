import ceylon.interop.java {
    CeylonIterable
}

import java.lang {
    System
}

import com.github.qdzo.config {
    Loader,
    sanitizeVar
}

"Loads variables from java system properties"
shared object systemPropsLoader extends Loader() {
    load => let(javaPrors = CeylonIterable(System.properties.entrySet()))
                map { for(prop in javaPrors)
                          sanitizeVar(prop.key.string -> prop.\ivalue) };
}
