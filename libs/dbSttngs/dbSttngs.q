//@TODO check the hdb is imported! (needed for writing new dbTable).


\d .dbSttngs

// @kind readme
// @author simon.j.watson@gmail.com
// @name .dSttngs/README.md
// @category .dbSttngs
// # .dSttngs
// The dSttngs namespace contains items for initialising the hdb.
// It contains the following items:
//  - .dSttngs.dbStucture
//  - .dSttngs.build
// 
// ## .dSttngs.dbStructure
// The dbStructure function sets up objects containing information about the database. 
// They are: 
// |function &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;|example &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp;|description &nbsp; &nbsp;|
// |--------|-------|-----------|
// |fileStruct.dbDir|hsym `` ` ``$"/import/redditdb"|a file handler pointing to the directory in which the hdb resides. |
// |fileStruct.inputDir|hsym `` ` ``$"/import"|a file handler pointing to the directory in which any source data objects can be imported from. |
// |partitionCol|(enlist ```RS)!(enlist `` ` ``created)|a dictionary with table names as keys and then the partition field for those tables as values. |
// |dbSettings.importChunkSize|(enlist `` ` ``RS)!(enlist 1300000)|a dictionary with table names as keys and the number of bits per import as values. |
// |dbSettings.removeCols|(enlist `` ` ``RS)!(enlist `` ` ``created_utc)|a dictionary with table names as keys and the columns to be removed before writing to disk as values. |
//
// Each of these values can be overridden at the command line 
//
// An example of an argument to set up the 3 kinds of log sinks possible:
//     .dbSttngs.logSinks:([name:("Console";"SystemD";"Logfile")] sinkType:`pConsole`pSystemD`pSink; sinkTgt:(hsym `$"";hsym `$"";hsym `$":/import/log.txt");lvls:(`SILENT`DEBUG`INFO`WARN`ERROR`FATAL;`INFO`WARN`ERROR`FATAL;`DEBUG`INFO`WARN`ERROR`FATAL));
//
// The function does not take or return arguments. 
//
// ## .dSttngs.build
// The script loads the hdb prior to setting up the namespace since it needs to remove and rebuild elements of it.
// The table built in this process is tblProcessManager. 
//  - tblProcessManager.process  The name of the process that each element in the table belongs to. The elements are used in these groups.
//  - tblProcessManager.args     The arguments (usually the table and column to be manipulated in a function from fn and arguments to drive that function).
//  - tblProcessManager.fn       A function or functions to be carried out with the arguments provided in column args.
//  - tblProcessManager.note     A note on any issues related to the use of that element 
//  - tblProcessManager.recDate  The date the element was committed to disk.
//  - tblProcessManager.recID    A unique identifier for each element in the table.
//
// The function does not take or return arguments. 
//
// @end


dbStructure:{
    
    .fileStrct.dbDir: $[`nulArg `cmdArgs[`dbDir];
        hsym `$"/import/redditdb";
        hsym `$`cmdArgs[`dbDir]];                                                                                       // Note we can't log this setting until after the logger is setup. 

    pathLog: ((-1*(-1+(count string .fileStrct.dbDir)))#(string .fileStrct.dbDir)),"/log.txt"; 
    defaultLogSttngs:([name:("SystemD";"Logfile")]                                                                      // set up log sinks
        sinkType:`pSystemD`pSink; 
        sinkTgt:(hsym `$"";hsym `$pathLog);
        lvls:(`INFO`WARN`ERROR`FATAL`DEBUG;`INFO`WARN`ERROR`FATAL`DEBUG));
    
    .dbSttngs.logSinks: $[`nulArg `cmdArgs[`logSinks];
        defaultLogSttngs;
        eval parse `cmdArgs[`logSinks]];
    .qlog.buildMap[];                                                                                                   // initialise the logger. 
    
    `INFO[raze "[kxReddit][.dbSttings] .fileStrct.dbDir: ",string .fileStrct.dbDir];                                    // Now log previous variables.
    `INFO["[kxReddit][.dbSttings] .dbSttngs.logSinks set."];  
    
    .fileStrct.inputDir: $[`nulArg `cmdArgs[`inputDir];
        hsym `$"/import";
        hsym `$`cmdArgs[`inputDir]];
    `INFO[raze "[kxReddit][.dbSttings] .fileStrct.inputDir: ", string .fileStrct.inputDir];
    
    .dbSttngs.partitionCol: $[`nulArg `cmdArgs[`partitionCol];
        `RS`RC!`created_utc`created_utc;
        eval parse `cmdArgs[`partitionCol]];
    `INFO[raze "[kxReddit][.dbSttings] .dbSttngs.partitionCol: ", raze ("," sv string each key .dbSttngs.partitionCol),"!",("," sv string each value .dbSttngs.partitionCol)];
    
    .dbSttngs.importChunkSize: $[`nulArg `cmdArgs[`importChunkSize];
        `RS`RC!(1300000;1300000);
        eval parse `cmdArgs[`importChunkSize]];
    `INFO["[kxReddit][.dbSttings] .dbSttngs.importChunkSize: ", raze ("," sv string each key .dbSttngs.importChunkSize),"!",("," sv string each value .dbSttngs.importChunkSize)];
    
    .dbSttngs.removeCols: $[`nulArg `cmdArgs[`removeCols];
        `RS`RC!`none`none;
        eval parse `cmdArgs[`removeCols]];
    `INFO["[kxReddit][.dbSttings] .dbSttngs.removeCols: ", raze ("," sv string each key .dbSttngs.removeCols),"!",("," sv string each value .dbSttngs.removeCols)];
    
    .dbSttngs.defaultSymbolRatio:$[`nulArg `cmdArgs[`defaultSymbolRatio];
        0.7;
        "F"$`cmdArgs[`defaultSymbolRatio]];
    `INFO["[kxReddit][.dbSttings] .dbSttngs.defaultSymbolRatio: ",string .dbSttngs.defaultSymbolRatio];
    
    schRC:([c:`author`author_flair_css_class`author_flair_text`body`controversiality`created_utc`distinguished`id`link_id`parent_id`retrieved_on`score`subreddit`subreddit_id`swamp]
            t:"sCCCfpCCsspfCs ";f:```````````````;a:```````````````);
    
    schRS:([c:`author`author_flair_css_class`author_flair_text`created_utc`distinguished`domain`link_flair_css_class`link_flair_text`num_comments`over_18`score`selftext`stickied`subreddit`subreddit_id`title`swamp]
            t:"sCCpCCCCfbfCbCsC ";f:`````````````````;a:`````````````````);
    
    .dbSttngs.defaultSchemaLib:(`RC`RS)!(schRC;schRS);

    pathTblProcessManager: ((-1*(-1+(count string .fileStrct.dbDir)))#(string .fileStrct.dbDir)),"/tblProcessManager";  // tblProcessManager is in the root of the database directories. This can't be changed. 
    $[() ~ key (hsym `$pathTblProcessManager);                                                                          // load process manager or create if it does not exist. 
        .dbSttngs.build[];
        load [hsym `$pathTblProcessManager]];
    `INFO["[kxReddit][.dbSttings] pathTblProcessManager: ",pathTblProcessManager];
    
    };

// @kind function
// @fileoverview Function creates the tblProcessManager table, containing default values, with no input arguments. It puts it in the .fileStrct.dbDir directory. 
// This table is used to control the normalising of data as it is written to disk. 
// @returns {null} The tblProcessManager table is written to disk prior to function exiting.  
build:{
    pathTblProcessManager: ((-1*(-1+(count string .fileStrct.dbDir)))#(string .fileStrct.dbDir)),"/tblProcessManager";
    $[() ~ key (hsym `$pathTblProcessManager);;system ("rm ",pathTblProcessManager)];
    
    delete tblProcessManager from `.; 
    `tblProcessManager set ([process: `$(); args:()] fn:(); note:string(); recDate:`timestamp$();recID:`guid$());
//RC: `gilded
    
//RS: `author`author_flair_css_class`author_flair_text`created_utc`distinguished`domain`edited`gilded`id`is_self`link_flair_css_class`link_flair_text`media`media_embed`num_comments
    //`over_18`permalink`score`secure_media`secure_media_embed`selftext`stickied`subreddit`subreddit_id`thumbnail`title`url


    args:(`tbl`colmn!`RS`author_flair_text;             /
        `tbl`colmn!`RS`author_flair_css_class;          /
        `tbl`colmn!`RS`link_flair_text;                 /
        `tbl`colmn!`RS`link_flair_css_class;            /
        `tbl`colmn`casting!(`RS;`num_comments;"F");     /
        `tbl`colmn`casting!(`RS;`score;"F");            /
        `tbl`colmn`casting!(`RS;`over_18;"B");          /
        `tbl`colmn`casting!(`RS;`stickied;"B");         /
        `tbl`colmn!`RS`created_utc;                     /
        `tbl`colmn!`RS`selftext;                        /
        `tbl`colmn!`RS`distinguished;                   /
        `tbl`colmn!`RS`subreddit;                       /
        `tbl`colmn!`RS`domain;                          /
        `tbl`colmn!`RS`subreddit_id;                    /
        `tbl`colmn!`RS`author;                          /            
        `tbl`colmn!`RS`title;                           /
        
        `tbl`colmn!`RC`author_flair_text;               /
        `tbl`colmn!`RC`author;                          /
        `tbl`colmn!`RC`author_flair_css_class;          /
        `tbl`colmn!`RC`id;                              /
        `tbl`colmn!`RC`retrieved_on;                    / 
        `tbl`colmn!`RC`subreddit;                       /
        `tbl`colmn!`RC`distinguished;                   /
        `tbl`colmn!`RC`parent_id;                       /
        `tbl`colmn!`RC`body;                            /
        `tbl`colmn`casting!(`RC;`controversiality;"F"); /           
        `tbl`colmn!`RC`subreddit_id;                    /
        `tbl`colmn!`RC`link_id;                         /
        `tbl`colmn`casting!(`RC;`score;"F");            /
        `tbl`colmn!`RC`created_utc                      /
        );
    
    fn:(
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist "castFn";
        enlist "castFn";
        enlist "castFn";
        enlist "castFn";
        enlist ".hBr.floatToDateTime";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanChar";
        
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.floatToDateTime";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanChar";
        enlist "castFn";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanCharSym";
        enlist "castFn";
        enlist ".hBr.floatToDateTime"
        );
                                                                                                                        // create a list for each column and then build a table based on those lists.
    nRows: count args;
    process:nRows#`ingestion;
    note:nRows#"";
    recDate: nRows#.z.p;
    recID:(neg nRows)?0Ng;
    `tblProcessManager upsert ([process;args]fn;note;recDate;recID);
     save (hsym `$pathTblProcessManager);
    };

\d .
