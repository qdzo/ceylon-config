import ceylon.logging {
    Logger,
    Priority,
    infoPriority = info
}
import ceylon.language.meta.declaration {
    Module,
    Package
}



Logger log = object satisfies Logger {
    shared actual Module|Package category => `module`;
    shared actual void log(
            Priority priority,
            String|String() message,
            Throwable? throwable) {
        // TODO add real logger
       print(if(is String message)
             then message
             else message());
    }
    shared actual variable Priority priority = infoPriority;
};
