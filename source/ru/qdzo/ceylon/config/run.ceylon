"Run the module `ru.qdzo.ceylon.config`."

shared void run() {
    env.readSystemProps().each(print);
}
