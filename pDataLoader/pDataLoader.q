//load libraries & database

\d .pDataLoader

importData:{[mnth;tempTbl;sinkTbl]
    tempTbl:.pDataLoader.ingest.SetDefaultColmns[mnth;tempTbl];                                                         // Set the formats for the column defaults listed in tblProcessManager.
    tempTbl:.pDataLoader.ingest.setUnknownColmns[mnth;tempTbl];                                                         // Apply formatting to columns where default is not specified.
    .pDataLoader.ingest.writeNewDataToDisk[tempTbl;sinkTbl];                                                            // Write the new data in .tmp.importTbl to disk.
    };

GetPartLsts: {[inlst;sinkTbl]
    .tmp.importTbl:`$".tmp.",(string sinkTbl),"_",(string first -1?0Ng);                                                // create the unique symbol to hold the table.
    .tmp.importTbl set flip (distinct (raze key each inlst))!();                                                        // create an empty table.
    .tmp.importTbl set (.tmp.importTbl[] uj/ ((flip each) (enlist each) each inlst));                                   // copy records into the table
    colSet: asc cols .tmp.importTbl;                                                                                    // ensure that the column order is consistant.
    .tmp.importTbl set ?[.tmp.importTbl;();0b;(colSet)!(colSet)];
    
    pc: .dbSttngs.partitionCol[sinkTbl];                                                                                // get the partition column.
    mnth:{"m"$"P"$ string `long$x}[first .tmp.importTbl[pc]];                                                           // get the partition by looking at that column.
    
    .pDataLoader.importData[mnth;.tmp.importTbl;sinkTbl];                                                               // transform data and copy to splayed partitioned table.
    };

ItterGetLst:{[x;sinkTbl]
    lst:: .j.k each x;                                                                                                  // ItterGetLst receives a set of JSON data not greater than the number of bites specified in .Q.fsn
    .pDataLoader.GetPartLsts[lst;sinkTbl]
    };

processRedditFile:{[source;sinkTbl]
    fileInfo: .fT.redditFileInfo source;
    pFilePath: hsym `$("/" sv ((string .fileStrct.dbdir);("." sv (fileInfo[`year];fileInfo[`month]));string sinkTbl));
    $[.fT.fExists[pFilePath];.fT.nukeDir[pFilePath];];
    
    ItterGetLstWithTbl:.pDataLoader.ItterGetLst[;sinkTbl];
    .Q.fsn[ItterGetLstWithTbl;source;.dbSttngs.importChunkSize[sinkTbl]]                                                // .Q.fsn takes a big file (given in the second argument) and breaks it into chunks not bigger than the 3rd
    };                                                                                                                  // argument by going to the first \n found before going over that 3rd argument size. It then passes each chunk to the function defined in the first argument. 
                                                                                                                        // Each 'chunk' is a vector of elements delimited by \n. Here tVals itterates (I did not say loops!) over that \n delimited vector of elements.
\d .





