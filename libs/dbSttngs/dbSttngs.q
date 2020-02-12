//@TODO check the hdb is imported! (needed for writing new dbTable).


\d .dbSttngs
dbStructure:{
    .fileStrct.dbdir: hsym `$"/import/redditdb";
    .fileStrct.inputdir: hsym `$"/import";
    .dbSttngs.partitionCol: `RS`RC!`created_utc`created_utc;
    .dbSttngs.importChunkSize: `RS`RC!(1300000;1300000);
    .dbSttngs.removeCols: `RS`RC!`none`none;
    .dbSttngs.defaultSymbolRatio: 0.7;
//     .dbSttngs.logSinks:([name:("Console";"SystemD";"Logfile")] sinkType:`pConsole`pSystemD`pSink; sinkTgt:(hsym `$"";hsym `$"";hsym `$":/import/log.txt");lvls:(`SILENT`DEBUG`INFO`WARN`ERROR`FATAL;`INFO`WARN`ERROR`FATAL;`DEBUG`INFO`WARN`ERROR`FATAL));

    .dbSttngs.logSinks:([name:("SystemD";"Logfile")] sinkType:`pSystemD`pSink; sinkTgt:(hsym `$"";hsym `$":/import/log.txt");lvls:(`INFO`WARN`ERROR`FATAL;`DEBUG));

    };

// @kind function
// @fileoverview Function creates the ProcessManager table, containing default values, with no input arguments. 
// This table is used to control the normalising of data as it is written to disk. 
// @returns {null} The tblProcessManager table is written to disk prior to function exiting.  
build:{

    $[() ~ key `:/import/redditdb/tblProcessManager;;system "rm /import/redditdb/tblProcessManager"];
    
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
        `tbl`colmn`casting!(`RS;`created_utc;"P");      /
        `tbl`colmn!`RS`selftext;                        /
        `tbl`colmn!`RS`distinguished;                   /
        `tbl`colmn!`RS`subreddit;                       /
        `tbl`colmn!`RS`domain;                          /
        `tbl`colmn!`RS`subreddit_id;                    /
        `tbl`colmn!`RS`author;                          /
        `tbl`colmn!`RS`edited;                          /                 
        `tbl`colmn!`RS`title;                           /
        
        `tbl`colmn!`RC`author_flair_text;               /
        `tbl`colmn!`RC`author;                          /
        `tbl`colmn!`RC`author_flair_css_class;          /
        `tbl`colmn!`RC`id;                              /
        `tbl`colmn!`RC`retrieved_on;                    /
        `tbl`colmn`casting!(`RC;`edited;"B");           /
        `tbl`colmn!`RC`subreddit;                       /
        `tbl`colmn!`RC`distinguished;                   /
        `tbl`colmn!`RC`parent_id;                       /
        `tbl`colmn!`RC`body;                            /
        `tbl`colmn`casting!(`RC;`controversiality;"F"); /           
        `tbl`colmn!`RC`subreddit_id;                    /
        `tbl`colmn!`RC`link_id;                         /
        `tbl`colmn`casting!(`RC;`score;"F")             /
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
        enlist "castFn";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanCharSym";
        (".hBr.falseToNull";".hBr.floatToDateTime");
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.floatToDateTime";
        enlist "castFn";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanChar";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanChar";
        enlist "castFn";
        enlist ".hBr.cleanCharSym";
        enlist ".hBr.cleanCharSym";
        enlist "castFn"
        );
                                                                                                                        // create a list for each column and then build a table based on those lists.
    nRows: count args;
    process:nRows#`ingestion;
    note:nRows#"";
    recDate: nRows#.z.p;
    recID:(neg nRows)?0Ng;
    `tblProcessManager upsert ([process;args]fn;note;recDate;recID);
     save `:/import/redditdb/tblProcessManager
    };

\d .
