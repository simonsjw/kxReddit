// load libraries
\l /home/simon/developer/data/workspace/__nouser__/simon/reddit/libs/dbmaint/dbmaint.q
\l /home/simon/developer/data/workspace/__nouser__/simon/reddit/libs/dbSttngs/dbSttngs.q
\l /home/simon/developer/data/workspace/__nouser__/simon/reddit/libs/dTr/dTr.q
\l /home/simon/developer/data/workspace/__nouser__/simon/reddit/libs/fT/fT.q
\l /home/simon/developer/data/workspace/__nouser__/simon/reddit/libs/hBr/hBr.q
\l /home/simon/developer/data/workspace/__nouser__/simon/reddit/libs/log4q/log4q.q

// load DataLoader process.
\l /home/simon/developer/data/workspace/__nouser__/simon/reddit/pDataLoader/ingst/ingst.q
\l /home/simon/developer/data/workspace/__nouser__/simon/reddit/pDataLoader/pDataLoader.q

// load hdb
\l /import/redditdb

// load database structure.
.dbSttngs.dbStructure[];
.dbSttngs.build[];

// .Q.fsn takes a big file (given in the second argument) and breaks it into chunks not bigger than the 3rd
// argument by going to the first \n found before going over that 3rd argument size. It then passes each chunk to the function defined in the first argument. 
// Each 'chunk' is a vector of elements delimited by \n. Here tVals itterates (I did not say loops!) over that \n delimited vector of elements.


// // if the partition exists, then delete it. 
// exists:{[fileHandle] not () ~ key fileHandle}
// $[.hb.exists[hsym `$"/import/RS_201334-11s"];;]
sinkTbl:`RS;
source: hsym `$"/import/RS_2014-11s";


.io.processRedditFile[source;sinkTbl];



    
    
    