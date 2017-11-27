import ru.qdzo.ceylon.config {
    Loader,
    sanitizeVar
}

"Ad-hoc loader from plain string to string entries"
shared class MapLoader({<String->String>*} envs) extends Loader() {
    load => map(envs.map(sanitizeVar));
}