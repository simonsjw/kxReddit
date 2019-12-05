// set the qhome path. 
qhome: hsym `$"/home/simon/developer/data/workspace/__nouser__/reddit"


loadRel:{[qhome;relPath]
    qhome: string qhome;
    qhome:(-1*((count qhome)-1))#qhome;
    relPath: string relPath;
    relPath:(-1*((count relPath)-1))#relPath;
    
    sPath:"l ", ("/" sv ( qhome; relPath));
    system sPath, .z.x 0; 
    }

// load up the library paths relative to home. 
libPths:(hsym `$"kxReddit/libs/dbmaint/dbmaint.q";
    hsym `$"kxReddit/libs/dbSttngs/dbSttngs.q";
    hsym `$"kxReddit/libs/dTr/dTr.q";
    hsym `$"kxReddit/libs/fT/fT.q";
    hsym `$"kxReddit/libs/hBr/hBr.q";
    hsym `$"kxReddit/libs/log4q/log4q.q"
    );

// load each library.
loadRel[qhome;] each libPths;

// load up the process paths relative to home. 
prPths:(hsym `$"kxReddit/pDataLoader/ingst/ingst.q";
    hsym `$"kxReddit/pDataLoader/pDataLoader.q"
    );

// load each library.
loadRel[qhome;] each prPths;

// load hdb.
\l /import/redditdb


// load database structure.
.dbSttngs.dbStructure[];
.dbSttngs.build[];


sinkTbl:`RS;
source: hsym `$"/import/RS_2014-11";


.pDataLoader.processRedditFile[source;sinkTbl];



    
    
    