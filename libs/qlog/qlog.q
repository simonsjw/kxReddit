
\d .qlog

// @kind readme
// @author simon.j.watson@gmail.com
// @name .qlog/README.md
// @category qlog
// The qlog namespace contains functions related to setting up and running logs for the system.  
// It contains the following items:
//      - .qlog.buildMap
//      - .qlog.logMsg
//      - .qlog.logger
// @end


// @kind function 
// @fileoverview Logger - a dictionary of functions where each function defines a method of logging in a particular way
// methods are:
// * `psink   -   log to a file
// * `pStd    -   log to STDOUT (with error and fatal messages going to STDERR)
// * `pConsole -   log to console
// * `pSystemD -   log to journalctl in systemD for integration with Linux system logging. 
logger:(enlist `pSink)!(enlist {z: hopen z; neg[z] raze ("[",string x,"]: ",(string .z.P)," ",y);hclose[z]});       // create `pSink    - a prototype function logging log state x with message y to file z.
logger[`pStd]:{[x;y;z]                                                                                              // create `pStd     - a prototype function logging ERROR and FATAL messages to STDERR and everything else to STDOUT.
    outStates:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL!(-1;-1;-1;-1;-2;-2);
    outStates[x] raze ("[",(string x),"]: ",string .z.P," ",y);
    };
logger[`pConsole]:{[x;y;z]0N! raze ("[",(string x),"]: ",string .z.P," ",y)};                                       // create `pConsole - a prototype function logging messages to the console.
logger[`pSystemD]:{[x;y;z]                                                                                          // create `pSystemD - a prototype function logging to journalctl in systemD for integration with Linux system logging. 
    SystemDLogState:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL!("debug";"debug";"info";"warning";"err";"err");
    system "logger -p local0.",SystemDLogState[x]," \"",y,"\"";};

// @kind function 
// @fileoverview buildMap builds a static logging function from settings given in .dbSettings.logSinks
// @param none
// @returns none
// @example Initialise logging. 
// // When the function is called, a logging function .qlog.logMap is created and used by .qlog.logMsg to set logging targets for each log level. 
// 
// .qlog.buildMap[];
// 
// /=>lvl  | fns                                                                                                                                                                                           
// /=>-----| --------------------------------------------------------------------------------------------------------
// /=>INFO | ,{[x;y;z]
// /=>         SystemDLogState:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL!("debug";"debug";"info";"warning";"err";"err");
// /=>         system "logger -p local0.",SystemDLogState[x]," '",y,"'"}[`INFO;;`]     
// /=>WARN | (::;{[x;y;z]
// /=>            SystemDLogState:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL!("debug";"debug";"info";"warning";"err";"err");
// /=>            system "logger -p local0.",SystemDLogState[x]," '",y,"'"}[`WARN;;`]) 
// /=>ERROR| (::;{[x;y;z]
// /=>            SystemDLogState:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL!("debug";"debug";"info";"warning";"err";"err");
// /=>            system "logger -p local0.",SystemDLogState[x]," '",y,"'"}[`ERROR;;`])
// /=>FATAL| (::;{[x;y;z]
// /=>            SystemDLogState:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL!("debug";"debug";"info";"warning";"err";"err");
// /=>            system "logger -p local0.",SystemDLogState[x]," '",y,"'"}[`FATAL;;`])
// /=>DEBUG| (::;{z: hopen z; neg[z] raze ("[",string x,"]: ",(string .z.P)," ",y);hclose[z]}[`DEBUG;;`:/import/log.txt]) 
buildMap:{                                                                                                          // Given logging requirements specified in database settings .dbSettings.logSinks, use the logging object to create a function .qlog.logMsg
    .qlog.logMap:([lvl:()];fns:());                                                                                 // this function will log individual log messages to targets specified for each log level. 
    LogFnBuilder:{[logSink]
        fn:{.qlog.logMap[x]:(enlist .qlog.logMap[x][`fns],.qlog.logger[y][x;;z])};
        fn[;logSink[`sinkType];logSink[`sinkTgt]]'[logSink[`lvls]]
        };
    LogFnBuilder':[.dbSttngs.logSinks];
    }

// @kind function 
// @fileoverview logMsg uses the logging instructions created in .qlog.buildMap to log to set targets by log level according to the map. 
// @param lvl {symbol} The log level for the message.
// @param msg {string} The message for the log.
// @returns none
logMsg:{[lvl;msg]
    fn:{x[y]}[;msg];
    fn each .qlog.logMap[lvl][`fns];
    };

\d .

ERROR:{[msg].qlog.logMsg[`SILENT;msg]};                                                                             // build an easily identified helper function to capture each log message in the code. 
DEBUG:{[msg].qlog.logMsg[`DEBUG;msg]};
INFO:{[msg].qlog.logMsg[`INFO;msg]};
WARN:{[msg].qlog.logMsg[`WARN;msg]};
ERROR:{[msg].qlog.logMsg[`ERROR;msg]};
FATAL:{[msg].qlog.logMsg[`FATAL;msg]};


