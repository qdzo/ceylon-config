"When variable is not found in Environment"
shared class EnvironmentVariableNotFoundException(String varName)
        extends Exception("Variable(s) [``varName``] not found in environment") { }



"When variable can't be parsed or coerced to specific type"
shared class
EnvironmentVariableParseException(
        Object varName,
        Object parsingVal,
        String parsingAsType,
        Throwable? cause = null)
        extends Exception(
    "Variable with name [``varName.string``] "
    + " can't be parsed as ``parsingAsType``: ``parsingVal``",
    cause) {}