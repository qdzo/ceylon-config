import ceylon.file {
    parsePath,
    lines,
    File
}
"Template class for creating custom config-loaders"
shared abstract class Loader() {
    shared formal Map<String, String> load;
    equals(Object that) => switch (that)
        case (is Loader) load==that.load
        else false;
    hash => load.hash;
}

"Used as stab loader"
shared object emptyLoader extends Loader() {
    shared actual Map<String,String> load => emptyMap;
}


"Sanitize var entry"
shared <String->String>
sanitizeVar(<String->Anything> entry)
        => sanitizeKey(entry.key) -> sanitizeVal(entry.item);

"Transforms keys to unified format.
 From `SCREAM_CASE` and `kebab-case` to `dot.case`"
shared String sanitizeKey(String key) {
    value newKey =
           key.lowercased
          .replace("_", ".")
          .replace("-", ".");
    if(newKey != key) {
        log.info("sanitizeKey: Warn, key ``key`` has been corrected to ``newKey``");
        return newKey;
    }
  return key;
}

shared String sanitizeVal(Anything item) {
    if(is String item) {
        return item;
    }
    log.info("sanitizeVal: Warn, val ``item else ""`` has been converted to string");
    return item?.string else "";
}

"Reads file content. Returns null if there no such file"
shared String? readFile(String filename) {
    if(is File file = parsePath(filename).resource){
        return "\n".join(lines(file));
    } else {
        log.warn("readFile: file ``filename`` does not exists");
        return null;
    }
}


"convert nested objects to plain map with full path separated by `.`(dot)
 *NOTE:* Array will not be touched and nested maps in array too."
shared Map<String, Anything>
flattenMap(Map<String, Anything> m, [String*] path) => map (
    m.flatMap((key -> item) {
        switch(item)
        case (is Map<String, Anything>) {
            return flattenMap(item, path.append([key]));
        }
        else {
            value pathKey = ".".join(path.append([key]));
            return { pathKey -> item };
        }
    }));
