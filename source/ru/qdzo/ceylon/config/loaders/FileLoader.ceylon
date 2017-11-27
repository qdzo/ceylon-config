import ru.qdzo.ceylon.config {
    Loader,
    readFile,
    emptyLoader
}

"Reads file content and then put it to given stringLoader.
 If file not exists or empty print warning and load no vars"
shared class FileLoader extends Loader {
    Loader loader;
    shared new (String filename, Loader(String) stringLoader)
            extends Loader() {
        if(exists content = readFile(filename)) {
            loader = stringLoader(content);
        } else {
            log.warn("FileLoader: File ``filename`` does not exists or empty");
            loader = emptyLoader;
        }
    }
    shared actual Map<String,String> load => loader.load;
}
