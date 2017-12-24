import com.github.qdzo.config {
    Loader,
    sanitizeVar
}

"Loads variables from command parameters"
shared object cmdParamsLoader extends Loader() {

  <String->String>? extractNamedArg(String namedArg) {
    String[2]? nameVal = namedArg
          .trimLeading('-'.equals)
          .split('='.equals)
          .paired.first;
    if(exists nameVal) {
        return sanitizeVar(Entry(*nameVal));
    }
    return null;
  }

    /*
      get indexed sequence of args. each index is an arg-position in cmd.
      search pairs in which 1st element starts with hyphen
      and 2nd element folowing the 1st and not starts with hyphen.
      example: '--name Victory'
    */
    {<String->String>*} geatherSeparateNamedArgs({<Integer->String>*} args)
          => { for(i->arg in args)
                   if(arg.startsWith("-"),
                      exists _->val = args.find(forKey((i+1).equals)),
                      !val.startsWith("-"))
                       sanitizeVar(arg.trimLeading('-'.equals) -> val) };

    /*
      split cmd-params into 2 categories:
      1. 'one-word' parameter (ex: --run=main, -port=80)
      2. splitted parameters (ex: -e, -port main, --run main)
      gather them separately to param-entries and merge.
    */
    shared actual Map<String, String> load {
        value indexedArgs = process.arguments.indexed;
        value argsAsOneWord = indexedArgs.filter((_->arg) => arg.startsWith("-") && arg.contains("="));
        value otherArgs = indexedArgs.filter((entry) => !entry in argsAsOneWord);
        return map(
             indexedArgs*.item
            .map(extractNamedArg).coalesced
            .chain(geatherSeparateNamedArgs(otherArgs))
        );
    }
}
