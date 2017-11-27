import ru.qdzo.ceylon.config {
    Loader,
    sanitizeVar,
    flattenMap
}

"Ad-hoc loader from plain string to string entries"
shared class MapLoader({<String->Anything>*} envs) extends Loader() {
    load => map(flattenMap(map(envs), []).map(sanitizeVar));
}