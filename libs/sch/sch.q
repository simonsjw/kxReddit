\d .sch

// @kind function
// @fileoverview .sch.check compares the metadata of a table to an expected schema and reports back a dictionary on the difference. The dictionary consists of 3 key value pairs
// @desc + - the columns found in the table that are not in the schema
// @desc - - the columns expected given the schema but not found in the table.
// @desc ? - the columns expected by the schema which have differences. These are returned as a dictionary with the column with differences as a key then a value consisting of a list containing the found value then the expected value.
// @param tbl {table} the table to be tested.
// @param schema {table} the expected schema of the table.
// @example schema
// testT: `colB xasc ([]colA:`w`e`r`t;colB:("never";"say";"never";"again");colC:1 2 3 4;
//     colD:("a";"b";"c";"d");
//     colG:(`a`b!(34;45);`a`b!(34;45);`a`b!(34;45);`a`b!(34;45));
//     colH:(`a`b!((1;2;3);(2;1;3));`a`b!((1;2;3);(2;1;3));`a`b!((1;2;3);(2;1;3));`a`b!((1;2;3);(2;1;3)));
//     colI:(enlist `a`b!((1;2;3);(2;1;3));enlist `a`b!((1;2;3);(2;1;3));enlist `a`b!((1;2;3);(2;1;3));enlist `a`b!((1;2;3);(2;1;3)))
//     );
//
// schema:([c:`colA`colC`colD`colE`colF`colG`colH`colI]t:("sjcFB   ");f:````````;a:`s```````);
//
// .sch.check[`testT;schema];
check:{[tbl;schema]
    mTbl: meta tbl;
    clst: ((0!mTbl)[`c] where (0!mTbl)[`c] in (0!schema)[`c]) cross (`t`f`a);
    clst:clst where ({[x;tbl;schTbl]($[tbl[x[0]][x[1]]~schTbl[x[0]][x[1]];0b;1b])}[;mTbl;schema] each clst);
    :(
        (`$"+"; `$"-";`$"?")!
        (
            enlist ((0!mTbl)[`c]) where (not {[x;tbl]x in (0!tbl)[`c]}[;schema] each (0!mTbl)[`c]);
            enlist ((0!schema)[`c]) where (not {[x;tbl]x in (0!tbl)[`c]}[;mTbl] each (0!schema)[`c]);
            enlist (clst)!({[x;tbl;schTbl](tbl[x[0]][x[1]];schTbl[x[0]][x[1]])}[;mTbl;schema] each clst))
        );

    }
\d .


