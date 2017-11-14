import ceylon.logging {
    Logger,
    Priority,
    infoPriority = info,
    warnPriority = warn
}
import ceylon.language.meta.declaration {
    Module,
    Package
}


Logger log = object satisfies Logger {

    shared actual Module|Package category => `module`;

    shared actual variable Priority priority
    = (process.namedArgumentPresent("d"))
          then infoPriority
          else warnPriority;

    shared actual
    void log(Priority priority,
            String|String() message,
            Throwable? throwable) {

        // TODO add real logger
        if(priority >= this.priority) {
            print(if(is String message)
                  then message
                  else message());
        }
    }
};
