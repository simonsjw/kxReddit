
// get arguments passed at command line
cmdArgs:.Q.opt .z.x;
// accepted arguments:
// -------------------
// located in main_loader (here)
//      `qhome                  -   filepath (string): Set location of library. ; eg. "/import/reddit"
//      `import                 -   boolean (string): If true (1) then run .fT.infltFilesRunFunc, inflate zip and import data; eg. 1
// located in .dbSttngs.dbStructure
//      `dbDir                  -   filepath (string): The root directory that each HDB is stored in.; eg. "/import/redditdb" 
//      `logSinks               -   table (string): The settings for logging in a table (passed via eval parse noting \ is the escape for ".).; eg. "([name:(\"SystemD\";\"Logfile\")] sinkType:`pSystemD`pSink; sinkTgt:(hsym `$\"\";hsym `$\"/import/\");lvls:(`INFO`WARN`ERROR`FATAL`DEBUG;`INFO`WARN`ERROR`FATAL`DEBUG))"
//      `inputDir               -   filepath (string): The directory where zipped folders for import are left.; eg. "/import"
//      `partitionCol           -   dictionary (string): the columns to be used as partition values (passed as table/column pairs).; eg. "`RS`RC!`created_utc`created_utc"
//      `importChunkSize        -   dictionary (string): the size (in bits) of the chunks of file streamed to be split into records. Needs to be bigger than the largest possible record. (passed as table/value pairs).; eg. "`RS`RC!(1300000;1300000)"
//      `removeCols             -   dictionary (string): the columns to be removed from data if found. (passed as table/column pairs).; eg. "`RS`RC!`rubbishData`rubbishData"
//      `defaultSymbolRatio     -   float (string): the threshold under which a column is set to syms which are enumerated. The threshold is the ratio of number of distinct records to number of records (with nulls removed). It is used in formatting functions in .hBr (currently only cleanCharSymWTest).; eg. "0.7"
//      


$[cmdArgs[`qhome]~();                                                                   // set the qhome path. This is the root directory of the scripts. 
    qhome: hsym `$"/home/simon/developer/data/workspace/__nouser__/kxReddit_local"; 
    qhome: hsym `$args[`qhome]];

// ####################################################################################
// Load filepaths relative to qhome. 
// ####################################################################################

loadRel:{[qhome;relPath]
    qhome: string qhome;
    qhome:(-1*((count qhome)-1))#qhome;
    relPath: string relPath;
    relPath:(-1*((count relPath)-1))#relPath;
    
    sPath:"l ", ("/" sv ( qhome; relPath));
    system sPath, .z.x 0; 
    };

libPths:(hsym `$"kxReddit/libs/dbmaint/dbmaint.q";                                       
    hsym `$"kxReddit/libs/dbSttngs/dbSttngs.q";
    hsym `$"kxReddit/libs/fT/fT.q";
    hsym `$"kxReddit/libs/hBr/hBr.q";
    hsym `$"kxReddit/libs/qlog/qlog.q"
    );

prPths:(hsym `$"kxReddit/pDataLoader/ingst/ingst.q";                                    // load up the process paths relative to home. 
    hsym `$"kxReddit/pDataLoader/pDataLoader.q"
    );

loadRel[qhome;] each libPths;                                                           // load each library.
loadRel[qhome;] each prPths;                                                            // load each method. 

.dbSttngs.dbStructure[];                                                                // load database structure. If  the table tblProcessManager does not exist, it is created with default settings. 

// ####################################################################################

if[("B"$cmdArgs[`import])~1b;     
    getSinkName:{`$x [til 2]};                                                          // build a function to profide the table sink name given an input string. 
    fn:.pDataLoader.processRedditFile;                                                  // provide the function to be applied to the folder after unzipping. 
    DEBUG[raze string "[kxReddit][.pDataLoader.processRedditFile] Attempting import. {source folder ",.fileStrct.inputDir,"}"];
    .fT.infltFilesRunFunc[.fileStrct.inputDir;fn;getSinkName];
    ]                              // Carry out the unzipping and apply hte function with argument each time. 


