import ru.qdzo.ceylon.config {
    Loader
}

"Custom file loader that loads needed config file.
 Can load json or toml files.
 *NOTE* need correct file extension."
shared class CustomConfigFileLoader(String filename) extends Loader() {
    shared actual Map<String,String> load =>
            if(filename.endsWith(".json")) then
                JsonFileLoader(filename).load
            else if(filename.endsWith(".toml")) then
                TomlFileLoader(filename).load
            else emptyMap; // TODO maybe add logs here
}