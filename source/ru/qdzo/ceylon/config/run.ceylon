"Run the module `ru.qdzo.ceylon.config`."

shared void run() {
//    env.each(print);
    print(env.getFloat("java.class.version"));
}
