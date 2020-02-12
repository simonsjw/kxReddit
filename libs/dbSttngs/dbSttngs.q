//@TODO check the hdb is imported! (needed for writing new dbTable).


\d .dbSttngs
dbStructure:{
    .fileStrct.dbdir: hsym `$"/import/redditdb";
    .fileStrct.inputdir: hsym `$"/import";
    .dbSttngs.partitionCol: (enlist `RS)!(enlist `created);
    .dbSttngs.importChunkSize: (enlist `RS)!(enlist 1300000);
    .dbSttngs.removeCols: (enlist`RS)!(enlist `created_utc);
    .dbSttngs.defaultSymbolRatio: 0.7;
//     .dbSttngs.logSinks:([name:("Console";"SystemD";"Logfile")] sinkType:`pConsole`pSystemD`pSink; sinkTgt:(hsym `$"";hsym `$"";hsym `$":/import/log.txt");lvls:(`SILENT`DEBUG`INFO`WARN`ERROR`FATAL;`INFO`WARN`ERROR`FATAL;`DEBUG`INFO`WARN`ERROR`FATAL));
    .dbSttngs.logSinks:([name:("SystemD";"Logfile")] sinkType:`pSystemD`pSink; sinkTgt:(;hsym `$"";hsym `$":/import/log.txt");lvls:(`INFO`WARN`ERROR`FATAL;`DEBUG));
    };

// @kind function
// @fileoverview Function creates the ProcessManager table, containing default values, with no input arguments. 
// This table is used to control the normalising of data as it is written to disk. 
// @returns {null} The tblProcessManager table is written to disk prior to function exiting.  
build:{

    $[() ~ key `:/import/redditdb/tblProcessManager;;system "rm /import/redditdb/tblProcessManager"];
    
    delete tblProcessManager from `.; 
    `tblProcessManager set ([process: `$(); args:()] fn:(); note:string(); recDate:`timestamp$();recID:`guid$());

    args:(`tbl`colmn!`RS`name;
        `tbl`colmn!`RS`author_flair_text;
        `tbl`colmn!`RS`author_flair_css_class;
        `tbl`colmn!`RS`link_flair_text;
        `tbl`colmn!`RS`link_flair_css_class;
        `tbl`colmn`casting!`RS`num_comments`float;
        `tbl`colmn`casting!`RS`score`float;     
        `tbl`colmn`casting!`RS`ups`float;
        `tbl`colmn`casting!`RS`downs`float;
        `tbl`colmn`casting!`RS`over_18`boolean;
        `tbl`colmn`casting!`RS`stickied`boolean;
        `tbl`colmn!`RS`selftext;
        `tbl`colmn!`RS`distinguished;
        `tbl`colmn!`RS`subreddit;
        `tbl`colmn!`RS`domain;
        `tbl`colmn!`RS`subreddit_id;
        `tbl`colmn!`RS`author;
        `tbl`colmn!`RS`edited;
        `tbl`colmn!`RS`created;
        `tbl`colmn!`RS`retrieved_on;
        `tbl`colmn!`RS`title);
    fn:(enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.castFn";
        enlist ".hBr.castFn";
        enlist ".hBr.castFn";
        enlist ".hBr.castFn";
        enlist ".hBr.castFn";
        enlist ".hBr.castFn";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanCharSym";
        (".hBr.falseToNull";".hBr.floatToDateTime");
        enlist ".hBr.floatToDateTime";
        enlist ".hBr.floatToDateTime";
        enlist ".hBr.cleanChar");
                                                                                                                        // create a list for each column and then build a table based on those lists.
    nRows: count args;
    process:nRows#`ingestion;
    note:nRows#"";
    recDate: nRows#.z.p;
    recID:(neg nRows)?0Ng;
    
    `:/import/redditdb/tblProcessManager set (`tblProcessManager upsert ([process;args]fn;note;recDate;recID));
    };

\d .
