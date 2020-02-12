//load libraries & database

\d .pDataLoader

importData:{[tempTbl;sinkTbl]
    allRecs:?[`tblProcessManager;(enlist (=;`process;enlist `ingestion));0b;`tbl`colmn`fn`casting!((each;{x[`tbl]};`args);(each;{x[`colmn]};`args);`fn;(each;{x[`casting]};`args))];
    allRecs: select from allRecs where (tbl=sinkTbl);                                               // get only the records for the target sinkTbl.
    `DEBUG[raze string "[kxReddit][.pDataLoader.ingest.SetDefaultColmns] Set the formats for the column defaults listed in tblProcessManager. {sinkTbl:",sinkTbl,"}"];
    tempTbl:.pDataLoader.ingest.SetDefaultColmns[tempTbl;sinkTbl;allRecs];             
    `DEBUG[raze string "[kxReddit][.pDataLoader.ingest.setUnknownColmns] Apply formatting to columns where default is not specified. {sinkTbl:",sinkTbl,"}"];
    tempTbl:.pDataLoader.ingest.setUnknownColmns[tempTbl;sinkTbl;allRecs];    
    `DEBUG[raze string "[kxReddit][.pDataLoader.ingest.writeNewDataToDisk] Write the new data in .tmp.importTbl to disk. {sinkTbl:",sinkTbl,"}"];
    .pDataLoader.ingest.writeNewDataToDisk[tempTbl;sinkTbl];                                                            
    };

GetPartLsts: {[inlst;sinkTbl]
    `DEBUG[raze string "[kxReddit] Create the unique symbol to hold the table. {sinkTbl:", sinkTbl,"}"];
    tmpname: (string sinkTbl),"__",(string first -1?0Ng);
    .tmp.importTbl:`$".tmp.",tmpname;   
    `DEBUG[raze string "[kxReddit] Create an empty table.{.tmp.importTbl:",.tmp.importTbl,"}"];
    .tmp.importTbl set flip (distinct (raze key each inlst))!();                      
    `DEBUG[raze string "[kxReddit] Copy records into the table."];
    .tmp.importTbl set (.tmp.importTbl[] uj/ ((flip each) (enlist each) each inlst));    
    `DEBUG["[kxReddit] Ensure that the column order is consistant."];
    colSet: asc cols .tmp.importTbl;    
    .tmp.importTbl set ?[.tmp.importTbl;();0b;(colSet)!(colSet)];
    `DEBUG["[kxReddit][.dbSttngs.partitionCol] Get the partition column."];
    pc: .dbSttngs.partitionCol[sinkTbl];         
    `DEBUG[raze string "[kxReddit][.pDataLoader.importData] Transform data and copy to splayed partitioned table."];
    .pDataLoader.importData[.tmp.importTbl;sinkTbl];
    `DEBUG["[kxReddit] Drop the tempTbl ",tmpname," from .tmp."];
    drp:![`.tmp;();0b;](),;                                                                                             // The table is deleted from memory after being written to disk.
    drp[`$tmpname];                                                                                                     // delete the objects in the tmp namespace and then the table specifically. 
    };

ItterGetLst:{[x;sinkTbl]
    lst:: .j.k each x; 
    .pDataLoader.GetPartLsts[lst;sinkTbl];
    };

processRedditFile:{[source;sinkTbl]
    `INFO["[kxReddit][.fT.redditFileInfo] Generate file info from file name and path."];
    fileInfo: .fT.redditFileInfo source;
    pFilePath: hsym `$("/" sv ((string .fileStrct.dbdir);fileInfo[`year];("." sv (fileInfo[`year];fileInfo[`month]));string `RS));
    `DEBUG["[kxReddit][.fT.fExists .fT.nukeDir] If the file exists then delete it."];
    $[.fT.fExists[pFilePath];.fT.nukeDir[pFilePath];];
    `DEBUG["[kxReddit][.pDataLoader.ItterGetLst] receiving a set of JSON data no more than ",(string .dbSttngs.importChunkSize[sinkTbl])," bits for table ", string sinkTbl];
    .Q.fsn[.pDataLoader.ItterGetLst[;sinkTbl];source;.dbSttngs.importChunkSize[sinkTbl]];                                               // .Q.fsn takes a big file (given in the second argument) and breaks it into chunks not bigger than the 3rd
    };                                                                                                                  // argument by going to the first \n found before going over that 3rd argument size. It then passes each chunk to the function defined in the first argument. 
                                                                                                                        // Each 'chunk' is a vector of elements delimited by \n. Here tVals itterates (I did not say loops!) over that \n delimited vector of elements.
\d .





