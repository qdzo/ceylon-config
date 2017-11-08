import ru.qdzo.ceylon.config {
    Loader
}
shared class CustomConfigLoader(String filename) extends Loader() {
    shared actual Map<String,String> load =>
            if(filename.endsWith(".json")) then
                JsonFileLoader(filename).load
            else if(filename.endsWith(".toml")) then
                TomlFileLoader(filename).load
            else emptyMap; // TODO maybe add logs here
}