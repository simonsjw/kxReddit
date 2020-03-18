\d .pDataLoader

// @kind function
// @fileoverview ingest.SetDefaultColmns sets the relevant features to process into columns in an hdb given a target datatable.
// The function uses settings in tblProcessManager to determine the needed columns and their target data type.
// If the colmn is found in the dictionary and the values don't match, the function isn't executed. This enables 'overloading' of functions.
// @param dataTbl {table} the table to be restructured
// @return array {table} the table after being restructured
ingest.SetDefaultColmns:{[dataTbl;sinkTbl;allRecs]
// select the relevant features to process via default data processing methods prior to import. 
// @TODO this function needs refactoring so in general a dictionary of any key value pairs is applied.
// @TODO: change fn so that it takes argments for columns and table and checks against those in a dictionary in the args column in the tblProcessManager.
    lstCol:raze {(count x[`fn])#x[`colmn]} each allRecs;                                            // get a list of columns needing action (same column more than once of more than one action).
    lstCast:raze {(count x[`fn])#x[`casting]} each allRecs;                                         // get a list of any types needed for casting.
    lstFn: raze allRecs[`fn];                                                                       // get a list of functions to be applied to the columns.
    lstTbl:raze {(count x[`fn])#x[`tbl]} each allRecs;                                              // get a list of the sink table this will ultimately be applied to. 
    
    applyFunction:{[defaultColSettings;dataTbl]
        fnString:defaultColSettings[`lstFn];
        $[defaultColSettings[`lstFn]~"castFn";;fn: value fnString];                                                                        // perform update
        `DEBUG[raze string "[kxReddit][.ingest.SetDefaultColmns][applyFunction] fn:",fnString,";col:",defaultColSettings[`lstCol],"; rec count:", count dataTbl[defaultColSettings[`lstCol]]];
        $[defaultColSettings[`lstFn]~"castFn";   
            .[  // Try Catch on attempt to format column.
                {[casting;castingCol;tbl] ![tbl;();0b;(enlist castingCol)!enlist (mmu;casting;castingCol)]};
                (defaultColSettings[`lstCast]; defaultColSettings[`lstCol];dataTbl);
                `DEBUG["casting not applied. Column datatype:", string type dataTbl[defaultColSettings[`lstCol]]]
                ];  
            dataTbl:(fn [defaultColSettings[`lstCol];dataTbl])[`d]
            ];
//         dataTbl: eRsltDict[`d];
        :dataTbl
        };
    
    applyFunction[;dataTbl] each ([]lstTbl;lstCol;lstFn;lstCast);                                   // Create a table from each of the lists generated above and each row of the table for execution.
    :dataTbl
    };

// @kind function
// @fileoverview ingest.setUnknownColmns captures the columns not specified in tblProcessManager and stores them as key
// value pairs in a column 'swamp'.
// @param dataTbl {table} the table to be restructured
// @return array {table} the table after being restructured
ingest.setUnknownColmns:{[dataTbl;sinkTbl;allRecs]
    lstCol:raze {(count x[`fn])#x[`colmn]} each allRecs;
    lstUnknownCols:asc (cols dataTbl) where not (cols dataTbl) in lstCol;
    `DEBUG[raze string "[kxReddit][.ingest.setUnknownColmn] Unknown columns (lstUnknownCols): ",lstUnknownCols,"."];
    unknownsTbl:?[dataTbl;();0b;(lstUnknownCols)!(lstUnknownCols)];
    `DEBUG["[kxReddit][.ingest.setUnknownColmn] building the swamp column (undocumented fields)."];
    // Add those to dataTbl.
    ls:{(enlist((flip y)[;x]))}[;unknownsTbl] each  til count unknownsTbl;
    ![dataTbl;();0b;(enlist `swamp)!(enlist `ls)];
    //now drop the unneeded columns
    ![dataTbl;();0b;lstUnknownCols]; 
    //now rename columns. 
    
    
// build the swampKey column - a column containing keys to the swamp.
// Add those to dataTbl.
//     ls:{cols first x} each (dataTbl[`swamp]);
//     ![dataTbl;();0b;(enlist `swampKeys)!(enlist `ls)];
    :dataTbl
    }

// @kind function
// @fileoverview ingest.writeNewDataToDisk writes a given table to a given sink table on disk. 
// @param tempTbl {table} The table to be written to disk
// @param dataTbl {table} the target table being written to.
// @return null
ingest.writeNewDataToDisk:{[tempTbl;sinkTbl]
    d:.fileStrct.dbDir;
    p:`$string("m"$first ?[tempTbl;();0b;()][.dbSttngs.partitionCol[sinkTbl]]);
    y:("." vs string p)[0];
    d:hsym `$raze string d,"/",y;
    f:.dbSttngs.partitionCol[sinkTbl];
    t:hsym `$ raze string d,"/", p,"/",sinkTbl,"/";
    d:hsym `$ raze string d,"/", p;                                                                // set the sym file location as within the table folder (so monthly). 

    allCols: cols tempTbl[];                                    
    otherCols: asc allCols where ((not (allCols = f)) and (not (allCols = `swamp)));               // set the sort order of the table to be laid down so that the partitioned column is up front, swamp is last and everything else is in between.
//     otherCols: asc allCols where ((not (allCols = f)) and (not (allCols = `swamp)) and (not (allCols = `swampKeys)));
    allCols:f,otherCols,`swamp;
//     allCols:f,otherCols,`swamp`swampKeys;
    `DEBUG[raze string "[kxReddit][ingest.writeNewDataToDisk] Perform upsert of columns. {allCols:",(sv[";";string allCols]),"}"];
    t upsert .Q.en[d;?[tempTbl;();0b;(allCols)!(allCols)]];
    };

\d .
