\d .pDataLoader

// @kind function
// @fileoverview ingest.SetDefaultColmns sets the relevant features to process into columns in an hdb given a target datatable.
// The function uses settings in tblProcessManager to determine the needed columns and their target data type.
// If the colmn is found in the dictionary and the values don't match, the function isn't executed. This enables 'overloading' of functions.
// @param mnth {month} The month (and year) of the partition the table will be added to.
// @param dataTbl {table} the table to be restructured
// @return array {table} the table after being restructured
ingest.SetDefaultColmns:{[mnth;dataTbl]
// select the relevant features to process via default data processing methods prior to import. 
// @TODO this function needs refactoring so in general a dictionary of any key value pares is applied.
// @TODO: change fn so that it takes argments for columns and table and checks against those in a dictionary in the args column in the tblProcessManager.
    allRecs:?[`tblProcessManager;(enlist (=;`process;enlist `ingestion));0b;`tbl`colmn`fn`casting!((each;{x[`tbl]};`args);(each;{x[`colmn]};`args);`fn;(each;{x[`casting]};`args))];
    lstCol:raze {(count x[`fn])#x[`colmn]} each allRecs;
    lstCast:raze {(count x[`fn])#x[`casting]} each allRecs;
    lstFn: raze allRecs[`fn];
    lstTbl:raze {(count x[`fn])#x[`tbl]} each allRecs;

    applyFunction:{[defaultColSettings;dataTbl]
        fnString:defaultColSettings[`lstFn];
        fn: value fnString;                                                                           // perform update
        `DEBUG[raze string "[kxReddit][.ingest.SetDefaultColmns][applyFunction] fn:",fnString,";col:",defaultColSettings[`lstCol]];
        $[defaultColSettings[`lstFn]~".hBr.castFn";
            eRsltDict:fn [defaultColSettings[`lstCol];dataTbl;defaultColSettings[`lstCast]];
            eRsltDict:fn [defaultColSettings[`lstCol];dataTbl]
            ];
        dataTbl: eRsltDict[`d];
        
        :dataTbl
        };
    
    applyFunction[;dataTbl] each ([]lstTbl;lstCol;lstFn;lstCast);
    :dataTbl
    };

// @kind function
// @fileoverview ingest.setUnknownColmns captures the columns not specified in tblProcessManager and stores them as key
// value pairs in a column 'swamp'.
// @param mnth {month} The month (and year) of the partition the table will be added to.
// @param dataTbl {table} the table to be restructured
// @return array {table} the table after being restructured
ingest.setUnknownColmns:{[mnth;dataTbl]
    allRecs:?[`tblProcessManager;(enlist (=;`process;enlist `ingestion));0b;`tbl`colmn`fn!((each;{x[`tbl]};`args);(each;{x[`colmn]};`args);`fn)];
    lstCol:raze {(count x[`fn])#x[`colmn]} each allRecs;
    lstUnknownCols:asc (cols dataTbl) where not (cols dataTbl) in lstCol;
    unknownsTbl:?[dataTbl;();0b;(lstUnknownCols)!(lstUnknownCols)];
    `DEBUG["[kxReddit][.ingest.setUnknownColmn] building the swamp column (undocumented fields)."];
    // Add those to dataTbl.
    ls:{(enlist((flip y)[;x]))}[;unknownsTbl] each  til count unknownsTbl;
    ![dataTbl;();0b;(enlist `swamp)!(enlist `ls)];
    //now drop the unneeded columns
    ![dataTbl;();0b;lstUnknownCols];    
//  build the swampKey column - a column containing keys to the swamp.
//  Add those to dataTbl.
//     ls:{cols first x} each (dataTbl[`swamp]);
//     ![dataTbl;();0b;(enlist `swampKeys)!(enlist `ls)];
    :dataTbl
    }

// @kind function
// @fileoverview ingest.writeNewDataToDisk writes a given table to a given sink table on disk. The table is deleted
// from memory after being written to disk.
// @param tempTbl {table} The table to be written to disk
// @param dataTbl {table} the target table being written to.
// @return null
ingest.writeNewDataToDisk:{[tempTbl;sinkTbl]
    d:.fileStrct.dbdir;

    p:`$string((first distinct select "m"$created from tempTbl)[.dbSttngs.partitionCol[sinkTbl]]);
    f:.dbSttngs.partitionCol[sinkTbl];
    t:hsym `$ raze string d,"/", p,"/",sinkTbl,"/";
    // set the sort order of the table to be laid down so that the partitioned column is up front, swamp is last and everything else is in between.
    allCols: cols tempTbl[];
 
    otherCols: asc allCols where ((not (allCols = f)) and (not (allCols = `swamp)));    
//     otherCols: asc allCols where ((not (allCols = f)) and (not (allCols = `swamp)) and (not (allCols = `swampKeys)));
    allCols:f,otherCols,`swamp;
//     allCols:f,otherCols,`swamp`swampKeys;
    `DEBUG[raze string "[kxReddit][ingest.writeNewDataToDisk] Perform upsert of columns. {allCols:",(sv[";";string allCols]),"}"];
    t upsert .Q.en[d;?[tempTbl;();0b;(allCols)!(allCols)]];
    };

\d .
