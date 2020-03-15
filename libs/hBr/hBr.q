
\d .hBr

// @kind readme
// @author simon.j.watson@gmail.com
// @name .dataTransform/README.md
// @category .dataTransform
// .hBr (homeBrew) contains tools related to manipulating data types with the intention of transforming mixed data columns to single kx compliant data types. 
// @end

// @kind function
// @fileoverview tcf runs a function in a try catch block (with finally).
// @param t {function} The function being run. 
// @param c {function} A function ran when an error is 'caught'.
// @param f {function} A function always ran after the try & catch. 
// @return array {(string; (int))[]} an array of tuples where each sub list contains the name of a column and the data types found in that column.
tcf:{[t;c;f]                                                                                        // https://stackoverflow.com/questions/56648511/exception-error-handling-in-q-kdb-alternative-of-try-catch-finallyjava-try/56654799#56654799
    r:@[(1b;)value@;t;@[(1b;)c@;;(0b;)::]];
    f[]; 
    $[r 0;r 1;'`$r 1]}

// @kind function
// @fileoverview allColTypes returns the types of every element in each feature of the datatable.
// @param x {table} A table to be analysed
// @return array {(string; (int))[]} an array of tuples where each sub list contains the name of a column and the data types found in that column.
allColTypes:{[testTbl]{(y;distinct type each x[y])}[testTbl;] each cols testTbl};


// @kind function 
// @fileoverview falseToNull takes false elements in a column and transforms them to null (0b to 0n).
// @param column {sym} A column to be transformed.
// @param tbl {sym} A table the column belongs to.
// @returns {`d:table} A dictionary containing a handler for the table just modified.
falseToNull:{[colmn;tbl]
    tbl:![tbl;enlist ((\:;~); colmn;0b);0b;(enlist colmn)!enlist (#;(count;`i);(enlist;0n))];
    :(enlist `d)!(enlist tbl)
    };

// @kind function 
// @fileoverview dictToJSON takes dictionary elements in a column and transforms them to JSON.
// @param column {sym} A column to be transformed.
// @param tbl {sym} A table the column belongs to.
// @returns {`d:table} A dictionary containing a handler for the table just modified.
dictToJSON:{[colmn;tbl]
    tbl:![tbl;();0b;(enlist colmn)!enlist (each;`.j.j; colmn)];
    :(enlist `d)!(enlist tbl)
    };

// @kind function 
// @fileoverview floatToDateTime takes a number or a number in a string elements in a column and transforms them to datetime.
// @param column {sym} A column to be transformed.
// @param tbl {sym} A table the column belongs to.
// @returns {`d:table} A dictionary containing a handler for the table just modified.
floatToDateTime:{[colmn;tbl]
//  col (symbol) is a column in table tbl (string).
//  This function changes floating values to an equivalent UTC date/time.
    $[(type tbl[colmn])~0h;
        tbl:![tbl;();0b;(enlist colmn)!enlist (mmu;"P";(tbl;enlist colmn))];
        tbl:![tbl;();0b;(enlist colmn)!enlist (mmu;"P";(string;(mmu;"j";(tbl;enlist colmn))))]];
    :(enlist `d)!(enlist tbl)
    };


// @kind function 
// @fileoverview floatToDateTime_checked changes floating values to an equivalent UTC date/time if the UTC date/time
//  is between 2005.01.01 and 2100.01.01. It does this by checking the first 10 values in the
//  given table which are not null values. It does not work on floats in strings. 
//  *******************************************************************************
//  ** this function assumes all values are either a float or a null (0n) term.  **
//  ** If not, apply falseToNull or similar to clean first before applying this. **
//  *******************************************************************************
// @param column {sym} A column to be transformed.
// @param tbl {sym} A table the column belongs to.
// @returns {`d:table} A dictionary containing a handler for the table just modified.
floatToDateTime_checked:{[colmn;tbl]
    x:"P"$/: string each "j"$/: ?[tbl;enlist (not;(=;colmn;0n));0b;(enlist colmn)!enlist (#;10;colmn)][colmn];
    $[not 0b in ({(x<2100.01.01) and (x>2005.01.01)} each x);
        tbl:![tbl;();0b;(enlist colmn)!enlist (mmu;"P";(string;(mmu;"j";(tbl;enlist colmn))))];];
    :(enlist `d)!(enlist tbl)
    };

// @kind function 
// @fileoverview cleanCharSymWTest first converts all 'false'(0b) boolean types to "". 
// It then changes strings to symbols if the count of unique records is less than the percentage (0-1) in .dbSttngs.defaultSymbolRatio of the total count.
// (not including zero length strings). 
// Finally, it removes any lists of empty symbols. 
// @param column {sym} A column to be transformed.
// @param tbl {sym} A table the column belongs to.
// @returns {dictionary(`d:table;`r: float} A dictionary containing a handler for the table just modified and `r, the ratio of distinct to duplicate record count. 
cleanCharSymWTest:{[colmn;tbl]
    tbl:![tbl;enlist (each;any;(=;colmn;0n));0b;(enlist colmn)!enlist (string;colmn)];
    r:(count (?[tbl;enlist (not;((\:;~);colmn;""));1b;(enlist colmn)!enlist colmn]))%(count (?[tbl;enlist (not;((\:;~);colmn;""));0b;(enlist colmn)!enlist colmn]));
    $[r<.dbState.dbSettings.defaultSymbolRatio;tbl:![tbl;();0b;(enlist colmn)!enlist (mmu;enlist`;(tbl;enlist colmn))];];
    ![tbl;enlist (~\:;colmn;`symbol$());0b;(enlist colmn)!enlist (first;`$())];
    :(`d`r)!(tbl;r)
    };

// @kind function 
// @fileoverview cleanCharSym first converts all 'false'(0b) boolean types to "". 
// It then changes strings to symbols regardless of how much duplication there is in the elements of the list being transformed. (See .preProcess.cleanChar if you need something with a threshold.)
// Finally, it removes any lists of empty symbols. 
// @param column {sym} A column to be transformed.
// @param tbl {sym} A table the column belongs to.
// @returns {dictionary(`d:table;`r: float} A dictionary containing a handler for the table just modified and `r, the ratio of distinct to duplicate record count. 
cleanCharSym:{[colmn;tbl]
    tbl:![tbl;enlist (each;any;(=;colmn;0n));0b;(enlist colmn)!enlist (string;colmn)];
    r:(count (?[tbl;enlist (not;((\:;~);colmn;""));1b;(enlist colmn)!enlist colmn]))%(count (?[tbl;enlist (not;((\:;~);colmn;""));0b;(enlist colmn)!enlist colmn]));
    tbl:![tbl;();0b;(enlist colmn)!enlist (mmu;enlist`;(tbl;enlist colmn))];
    ![tbl;enlist (~\:;colmn;`symbol$());0b;(enlist colmn)!enlist (first;`$())];
    :(`d`r)!(tbl;r)
    };

// @kind function 
// @fileoverview cleanChar converts all 'false'(0b) boolean types to "". 
// @param column {sym} A column to be transformed.
// @param tbl {sym} A table the column belongs to.
// @returns {`d:table} A dictionary containing a handler for the table just modified.
cleanChar:{[colmn;tbl]
    vals:distinct tbl[colmn];
    allNulls:((count vals)=1)&(vals[0]~ 0n);
    $[allNulls;
        ![tbl;();0b;(enlist colmn)!enlist (string; colmn)];
        ![tbl;enlist ((';not;=);(each;type;colmn);10);0b;(enlist colmn)!enlist (string; colmn)]];
    :(enlist `d)!(enlist tbl)
    };

\d .