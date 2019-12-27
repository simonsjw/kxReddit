// @fileOverview Enter a description here...

\d .qlog

//x: error level; y: message; z: target 
// @returns {Type} Enter a return description here...

logger:(enlist `pSink)!(enlist {z: hopen z; neg[z] raze ("[",string x,"]: ",(string .z.P)," ",y);hclose[z]});
logger[`pStd]:{[x;y;z]
    outStates:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL!(-1;-1;-1;-1;-2;-2);
    outStates[x] raze ("[",(string x),"]: ",string .z.P," ",y);
    };

logger[`pConsole]:{[x;y;z]0N! raze ("[",(string x),"]: ",string .z.P," ",y)};
logger[`pSystemD]:{[x;y;z]
    SystemDLogState:`SILENT`DEBUG`INFO`WARN`ERROR`FATAL!("debug";"debug";"info";"warning";"err";"err");
    system "logger -p local0.",SystemDLogState[x]," '",y,"'"};


buildMap:{
    .qlog.logMap:([lvl:()];fns:());
    0N!.qlog.logMap
    LogFnBuilder:{[logSink]
        fn:{.qlog.logMap[x]:(enlist .qlog.logMap[x][`fns],.qlog.logger[y][x;;z])};
        fnItr:fn[;logSink[`sinkType];logSink[`sinkTgt]];
        fnItr'[logSink[`lvls]]
        };
    LogFnBuilder':[.dbSttngs.logSinks];
    }

// logMsg:{[lvl;msg]
//     0N!lvl;
//     0N!.qlog.logMap[lvl][`fns];
//     fn:{x[y]};
//     fnI:fn[;msg];
//     fnI each .qlog.logMap[lvl][`fns];
//     };
logMsg:{[lvl;msg]
    fn:{x[y]}[;msg];
    fn each .qlog.logMap[lvl][`fns];
    };

\d .

.qlog.buildMap[];
.qlog.logMsg[`INFO;"Simon"]


