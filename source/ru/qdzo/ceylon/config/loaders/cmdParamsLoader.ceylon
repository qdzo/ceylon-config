import ru.qdzo.ceylon.config {
    Loader
}

"Loads variables from command parameters"
shared object cmdParamsLoader extends Loader() {
    <String->String>? extractNamedArg(String namedArg) {
        String[2]? nameVal = namedArg.trimLeading('-'.equals).split('='.equals).paired.first;
        return if(exists nameVal) then nameVal[0] -> nameVal[1] else null;
    }

    {<String->String>*} geatherSeparateNamedArgs({<Integer->String>*} args) =>
            { for(i->arg in args)
            if(arg.startsWith("-"),
                exists _->val = args.find(forKey((i+1).equals)),
                !val.startsWith("-"))
            arg.trimLeading('-'.equals) -> val };

    shared actual Map<String, String> load {
        value indexedArgs = process.arguments.indexed;
        value argsAsOneWord = indexedArgs.filter((_->arg) => arg.startsWith("-") && arg.contains("="));
        value otherArgs = indexedArgs.filter((entry) => !entry in argsAsOneWord);
        return map(indexedArgs*.item
            .map(extractNamedArg).coalesced
            .chain(geatherSeparateNamedArgs(otherArgs)));
    }
}
