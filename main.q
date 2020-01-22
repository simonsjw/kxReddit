
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


// load process manager.
load [hsym `$"/import/redditdb/tblProcessManager"];

.dbSttngs.dbStructure[];                                                                // load database structure.
.qlog.buildMap[];                                                                       // initialise the logger. 

// .dbSttngs.build[];                                                                   // rebuild tblProcessManager


folder: hsym `$"/import/test";
getSinkName:{`$x [til 2]}
fn:.pDataLoader.processRedditFile;

DEBUG[raze string "[kxReddit][.pDataLoader.processRedditFile] Attempting import. {source folder ",folder,"}"];
.fT.infltFilesRunFunc[folder;fn;getSinkName];





