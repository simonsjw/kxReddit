//load libraries & database

\d .pDataLoader

importData:{[mnth;tempTbl;sinkTbl]
    `DEBUG[raze string "[kxReddit][.pDataLoader.ingest.SetDefaultColmns] Set the formats for the column defaults listed in tblProcessManager. {mnth:",mnth," sinkTbl:",sinkTbl,"}"];
    tempTbl:.pDataLoader.ingest.SetDefaultColmns[mnth;tempTbl];             
    `DEBUG[raze string "[kxReddit][.pDataLoader.ingest.setUnknownColmns] Apply formatting to columns where default is not specified. {mnth:",mnth," sinkTbl:",sinkTbl,"}"];
    tempTbl:.pDataLoader.ingest.setUnknownColmns[mnth;tempTbl];    
    `DEBUG[raze string "[kxReddit][.pDataLoader.ingest.writeNewDataToDisk] Write the new data in .tmp.importTbl to disk. {mnth:",mnth," sinkTbl:",sinkTbl,"}"];
    .pDataLoader.ingest.writeNewDataToDisk[tempTbl;sinkTbl];                                                            
    };

GetPartLsts: {[inlst;sinkTbl]
    `DEBUG[raze string "[kxReddit] Create the unique symbol to hold the table. {sinkTbl:", sinkTbl,"}"];
    .tmp.importTbl:`$".tmp.",(string sinkTbl),"_",(string first -1?0Ng);   
    `DEBUG[raze string "[kxReddit] Create an empty table.{.tmp.importTbl:",.tmp.importTbl,"}"];
    .tmp.importTbl set flip (distinct (raze key each inlst))!();                      
    `DEBUG[raze string "[kxReddit] Copy records into the table."];
    .tmp.importTbl set (.tmp.importTbl[] uj/ ((flip each) (enlist each) each inlst));    
    `DEBUG["[kxReddit] Ensure that the column order is consistant."];
    colSet: asc cols .tmp.importTbl;    
    .tmp.importTbl set ?[.tmp.importTbl;();0b;(colSet)!(colSet)];
    `DEBUG["[kxReddit][.dbSttngs.partitionCol] Get the partition column."];
    pc: .dbSttngs.partitionCol[sinkTbl];    
    `DEBUG["[kxReddit][.tmp.importTbl] Get the partition by looking at that column."];
    mnth:{"m"$"P"$ string `long$x}[first .tmp.importTbl[pc]];     
    `DEBUG[raze string "[kxReddit][.pDataLoader.importData] Transform data and copy to splayed partitioned table.{partition:",mnth,"}"];
    .pDataLoader.importData[mnth;.tmp.importTbl;sinkTbl];
    };

ItterGetLst:{[x;sinkTbl]
    `INFO["[kxReddit] ItterGetLst receives a set of JSON data no more than the bites specified in .Q.fsn."];
    lst:: .j.k each x; 
    .pDataLoader.GetPartLsts[lst;sinkTbl];
    };

processRedditFile:{[source;sinkTbl]
    `INFO["[kxReddit][.fT.redditFileInfo] Generate file info from file name and path."];
    fileInfo: .fT.redditFileInfo source;
    pFilePath: hsym `$("/" sv ((string .fileStrct.dbdir);("." sv (fileInfo[`year];fileInfo[`month]));string sinkTbl));
    `INFO["[kxReddit][.fT.fExists .fT.nukeDir] If the file exists then delete it."];
    $[.fT.fExists[pFilePath];.fT.nukeDir[pFilePath];];
    `DEBUG["[kxReddit][.pDataLoader.ItterGetLst] Itterate through chunks of JSON."];
    ItterGetLstWithTbl:.pDataLoader.ItterGetLst[;sinkTbl];                                                              // ItterGetLstWithTbl is an alias of .pDataLoader.ItterGetLst where the table in the second argument is fixed the sinkTbl.
    .Q.fsn[ItterGetLstWithTbl;source;.dbSttngs.importChunkSize[sinkTbl]];                                               // .Q.fsn takes a big file (given in the second argument) and breaks it into chunks not bigger than the 3rd
    };                                                                                                                  // argument by going to the first \n found before going over that 3rd argument size. It then passes each chunk to the function defined in the first argument. 
                                                                                                                        // Each 'chunk' is a vector of elements delimited by \n. Here tVals itterates (I did not say loops!) over that \n delimited vector of elements.
\d .





