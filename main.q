
qhome: hsym `$"/home/simon/developer/data/workspace/__nouser__/reddit"                  // set the qhome path. 

loadRel:{[qhome;relPath]
    qhome: string qhome;
    qhome:(-1*((count qhome)-1))#qhome;
    relPath: string relPath;
    relPath:(-1*((count relPath)-1))#relPath;
    
    sPath:"l ", ("/" sv ( qhome; relPath));
    system sPath, .z.x 0; 
    }

libPths:(hsym `$"kxReddit/libs/dbmaint/dbmaint.q";                                      // load up the library paths relative to home. 
    hsym `$"kxReddit/libs/dbSttngs/dbSttngs.q";
    hsym `$"kxReddit/libs/dTr/dTr.q";
    hsym `$"kxReddit/libs/fT/fT.q";
    hsym `$"kxReddit/libs/hBr/hBr.q";
    hsym `$"kxReddit/libs/log4q/log4q.q"
    );

// load each library.
loadRel[qhome;] each libPths;

prPths:(hsym `$"kxReddit/pDataLoader/ingst/ingst.q";                                    // load up the process paths relative to home. 
    hsym `$"kxReddit/pDataLoader/pDataLoader.q"
    );

loadRel[qhome;] each prPths;                                                            // load each library.

.hBr.logInit[`:/import/kxLog.log];                                                       // Initialise the logger.

// load hdb.
\l /import/redditdb

.dbSttngs.dbStructure[];                                                                // load database structure.
// .dbSttngs.build[];

sinkTbl:`RS;
source: hsym `$"/import/RS_2014-11";

INFO ("[kxReddit]{.pDataLoader.processRedditFile} Attempting import of %1 to %2 .";(string source;string sinkTbl))
.pDataLoader.processRedditFile[source;sinkTbl];


