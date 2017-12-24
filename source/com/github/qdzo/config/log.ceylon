import ceylon.logging {
    Logger,
    addLogWriter,
    writeSimpleLog,
    logger
}


// assignment fiction
Anything a = addLogWriter(writeSimpleLog);

Logger log = logger(`module`);
