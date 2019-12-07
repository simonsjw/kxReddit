//load libraries & database

\d .pDataLoader

    importData:{[mnth;tempTbl;sinkTbl]
        DEBUG "[kxReddit]{.pDataLoader.ingest.SetDefaultColmns} Set the formats for the column defaults listed in tblProcessManager.";
        tempTbl:.pDataLoader.ingest.SetDefaultColmns[mnth;tempTbl];             
        DEBUG "[kxReddit]{.pDataLoader.ingest.setUnknownColmns} Apply formatting to columns where default is not specified.";
        tempTbl:.pDataLoader.ingest.setUnknownColmns[mnth;tempTbl];    
        DEBUG "[kxReddit]{.pDataLoader.ingest.writeNewDataToDisk) Write the new data in .tmp.importTbl to disk.";
        .pDataLoader.ingest.writeNewDataToDisk[tempTbl;sinkTbl];                                                            
        };

    GetPartLsts: {[inlst;sinkTbl]
        DEBUG "[kxReddit] Create the unique symbol to hold the table.";
        .tmp.importTbl:`$".tmp.",(string sinkTbl),"_",(string first -1?0Ng);   
        DEBUG "[kxReddit] Create an empty table.";
        .tmp.importTbl set flip (distinct (raze key each inlst))!();                      
        DEBUG "[kxReddit] Copy records into the table.";
        .tmp.importTbl set (.tmp.importTbl[] uj/ ((flip each) (enlist each) each inlst));    
        DEBUG "[kxReddit] Ensure that the column order is consistant.";
        colSet: asc cols .tmp.importTbl;    
        .tmp.importTbl set ?[.tmp.importTbl;();0b;(colSet)!(colSet)];
        DEBUG "[kxReddit]{.dbSttngs.partitionCol} Get the partition column.";
        pc: .dbSttngs.partitionCol[sinkTbl];    
        DEBUG "[kxReddit]{.tmp.importTbl} Get the partition by looking at that column.";
        mnth:{"m"$"P"$ string `long$x}[first .tmp.importTbl[pc]];     
        DEBUG ("[kxReddit] Partition: %1";mnth);
        DEBUG "[kxReddit]{.pDataLoader.importData} Transform data and copy to splayed partitioned table.";
        .pDataLoader.importData[mnth;.tmp.importTbl;sinkTbl];
        };

    ItterGetLst:{[x;sinkTbl]
        DEBUG ("[kxReddit] ItterGetLst receives a set of JSON data not greater than the number of bites specified in .Q.fsn.(%1)";.dbSttngs.importChunkSize[sinkTbl]);
        lst:: .j.k each x; 
        .pDataLoader.GetPartLsts[lst;sinkTbl]
        };

    processRedditFile:{[source;sinkTbl]
        INFO "test";
        INFO ("[kxReddit]{.fT.redditFileInfo} Generate file info from file name and path at %1"; string source);
        fileInfo: .fT.redditFileInfo source;
        pFilePath: hsym `$("/" sv ((string .fileStrct.dbdir);("." sv (fileInfo[`year];fileInfo[`month]));string sinkTbl));
        INFO "[kxReddit]{.fT.fExists;.fT.nukeDir} If the file exists, delete it.";
        $[.fT.fExists[pFilePath];.fT.nukeDir[pFilePath];];
        DEBUG "[kxReddit]{.pDataLoader.ItterGetLst} Itterate through chunks of JSON.";
        ItterGetLstWithTbl:.pDataLoader.ItterGetLst[;sinkTbl];
        .Q.fsn[ItterGetLstWithTbl;source;.dbSttngs.importChunkSize[sinkTbl]]                                                // .Q.fsn takes a big file (given in the second argument) and breaks it into chunks not bigger than the 3rd
        };                                                                                                                  // argument by going to the first \n found before going over that 3rd argument size. It then passes each chunk to the function defined in the first argument. 
                                                                                                                            // Each 'chunk' is a vector of elements delimited by \n. Here tVals itterates (I did not say loops!) over that \n delimited vector of elements.
\d .





