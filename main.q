
qhome: hsym `$"/home/simon/developer/data/workspace/__nouser__/reddit";                  // set the qhome path. 

loadRel:{[qhome;relPath]
    qhome: string qhome;
    qhome:(-1*((count qhome)-1))#qhome;
    relPath: string relPath;
    relPath:(-1*((count relPath)-1))#relPath;
    
    sPath:"l ", ("/" sv ( qhome; relPath));
    system sPath, .z.x 0; 
    };

libPths:(hsym `$"kxReddit/libs/dbmaint/dbmaint.q";                                      // load up the library paths relative to home. 
    hsym `$"kxReddit/libs/dbSttngs/dbSttngs.q";
    hsym `$"kxReddit/libs/dTr/dTr.q";
    hsym `$"kxReddit/libs/fT/fT.q";
    hsym `$"kxReddit/libs/hBr/hBr.q";
    hsym `$"kxReddit/libs/qlog/qlog.q"
    );

// load each library.
loadRel[qhome;] each libPths;

prPths:(hsym `$"kxReddit/pDataLoader/ingst/ingst.q";                                    // load up the process paths relative to home. 
    hsym `$"kxReddit/pDataLoader/pDataLoader.q"
    );

loadRel[qhome;] each prPths;                                                            // load each library.


// load hdb.
\l /import/redditdb

.dbSttngs.dbStructure[];                                                                // load database structure.
.dbSttngs.build[];
.qlog.buildMap[];                                                                       // initialise the logger. 

// .dTr.infltFiles[.fileStrct.inputdir];                                                // check input directory for zipped files and unzip them.

sinkTbl:`RS;
source: hsym `$"/import/RS_2014-11";

DEBUG[raze string "[kxReddit][.pDataLoader.processRedditFile] Attempting import. {source:",source," sinkTbl:",sinkTbl,"}"];
.pDataLoader.processRedditFile[source;sinkTbl];

