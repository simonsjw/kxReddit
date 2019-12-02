//load libraries & database

\d .pDataLoader

importData:{[mnth;tempTbl;sinkTbl]
    tempTbl:.io.ingest.SetDefaultColmns[mnth;tempTbl];                                                                  // Set the formats for the column defaults listed in tblProcessManager.
    tempTbl:.io.ingest.setUnknownColmns[mnth;tempTbl];                                                                  // Apply formatting to columns where default is not specified.
    .io.ingest.writeNewDataToDisk[tempTbl;sinkTbl];                                                                     // Write the new data in .tmp.importTbl to disk.
    };

GetPartLsts: {[inlst;sinkTbl]
    .tmp.importTbl:`$".tmp.",(string sinkTbl),"_",(string first -1?0Ng);                                                // create the unique symbol to hold the table.
    .tmp.importTbl set flip (distinct (raze key each inlst))!();                                                        // create an empty table.
    .tmp.importTbl set (.tmp.importTbl[] uj/ ((flip each) (enlist each) each inlst));                                   // copy records into the table
    colSet: asc cols .tmp.importTbl;                                                                                    // ensure that the column order is consistant.
    .tmp.importTbl set ?[.tmp.importTbl;();0b;(colSet)!(colSet)];
    
    pc: .dbSttngs.partitionCol[sinkTbl];                                                                                // get the partition column.
    mnth:{"m"$"P"$ string `long$x}[first .tmp.importTbl[pc]];                                                           // get the partition by looking at that column.
    
    .io.importData[mnth;.tmp.importTbl;sinkTbl];                                                                        // transform data and copy to splayed partitioned table.
    };

ItterGetLst:{[x;sinkTbl]
    lst:: .j.k each x;                                                                                                  // ItterGetLst receives a set of JSON data not greater than the number of bites specified in .Q.fsn
    .io.GetPartLsts[lst;sinkTbl]
    };

processRedditFile:{[source;sinkTbl]
    fileInfo: .hBr.redditFileInfo source;
    pFilePath: hsym `$("/" sv ((string .fileStrct.dbdir);("." sv (fileInfo[`year];fileInfo[`month]));string sinkTbl));
    $[.hBr.fExists[pFilePath];.hBr.nukeDir[pFilePath];];
    
    ItterGetLstWithTbl:.io.ItterGetLst[;sinkTbl];
    .Q.fsn[ItterGetLstWithTbl;source;.dbSttngs.importChunkSize[sinkTbl]]
    };

\d .


