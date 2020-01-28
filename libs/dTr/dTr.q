
\d .hBr

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
// @fileoverview floatToDateTime takes float elements in a column and transforms them to datetime.
// @param column {sym} A column to be transformed.
// @param tbl {sym} A table the column belongs to.
// @returns {`d:table} A dictionary containing a handler for the table just modified.
floatToDateTime:{[colmn;tbl]
//  col (symbol) is a column in table tbl (string).
//  This function changes floating values to an equivalent UTC date/time.
    tbl:![tbl;();0b;(enlist colmn)!enlist (mmu;"P";(string;(mmu;"j";(tbl;enlist colmn))))];
    :(enlist `d)!(enlist tbl)
    };


// @kind function 
// @fileoverview floatToDateTime_checked changes floating values to an equivalent UTC date/time if the UTC date/time
//  is between 2005.01.01 and 2100.01.01. It does this by checking the first 10 values in the
//  given table which are not null values.
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