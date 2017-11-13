shared abstract class Loader() {
    shared formal Map<String, String> load;
    equals(Object that) => switch (that)
        case (is Loader) load==that.load
        else false;
    hash => load.hash;
}


"Transforms keys to unified format.
 From `SCREAM_CASE` and `kebab-case` to `dot.case`"
shared String sanitize(String key) {
    value newKey =
           key.lowercased
          .replace("_", ".")
          .replace("-", ".");
    if(newKey != key) {
        log.info("Warn: key ``key`` has been corrected to ``newKey``");
        return newKey;
    }
  return key;
}
