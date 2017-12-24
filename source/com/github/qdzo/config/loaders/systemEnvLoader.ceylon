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

"Loads variables from system environment variables"
shared object systemEnvLoader extends Loader() {
    load => let(jEnvVars = CeylonIterable(System.getenv().entrySet()))
                map { for(entry in jEnvVars)
                          sanitizeVar(entry.key.string -> entry.\ivalue) };
}
