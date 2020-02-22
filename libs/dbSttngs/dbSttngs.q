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
// |fileStruct.dbdir|hsym `` ` ``$"/import/redditdb"|a file handler pointing to the directory in which the hdb resides. |
// |fileStruct.inputdir|hsym `` ` ``$"/import"|a file handler pointing to the directory in which any source data objects can be imported from. |
// |partitionCol|(enlist ```RS)!(enlist `` ` ``created)|a dictionary with table names as keys and then the partition field for those tables as values. |
// |dbSettings.importChunkSize|(enlist `` ` ``RS)!(enlist 1300000)|a dictionary with table names as keys and the number of bits per import as values. |
// |dbSettings.removeCols|(enlist `` ` ``RS)!(enlist `` ` ``created_utc)|a dictionary with table names as keys and the columns to be removed before writing to disk as values. |
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
