
\d .fQry

// @kind readme
// @author simon.j.watson@gmail.com
// @name .fQry/README.md
// @category functional Query
// The homeBrew namespace contains internal functions to aid Kdb object manipulation.  
// It contains the following item:
//      - .fQry.fQry
// @end

// @kind function 
// @fileoverview fQry returns a functional select statement given a qSQL statement. 
// @param x {string} A valid qSQL statement.
// @returns {string} A valid functional select statement equivalent to the given qSQL statement.
// @example Build a functional select given a qsql statement.
// // A functional select is returned given a select qsql statement. 
// 
// .hdb.fQry "select count i by date from dxTrade where product=`Spot"
// 
// /=>"?[dxTrade;enlist (=;`product;enlist`Spot);(enlist`date)!enlist`date;(enlist`x)!enlist (count;`i)]"
fQry:{
    tidy:{ssr/[;("\"~~";"~~\"");("";"")] $[","=first x;1_x;x]};

    strBrk:{y,(";" sv x),z};

    kreplace:{[x] $[`=qval:.q?x;x;"~~",string[qval],"~~"]};                                                             //replace k representation with equivalent q keyword
    funcK:{$[0=t:type x;.z.s each x;t<100h;x;kreplace x]};

    ereplace:{"~~enlist",(.Q.s1 first x),"~~"};                                                                         //replace eg ,`FD`ABC`DEF with "enlist`FD`ABC`DEF"
    ereptest:{((0=type x) & (1=count x) & (11=type first x)) | ((11=type x)&(1=count x))};
    funcEn:{$[ereptest x;ereplace x;0=type x;.z.s each x;x]};
    basic:{tidy .Q.s1 funcK funcEn x};
    addbraks:{"(",x,")"};

    stringify:{$[(0=type x) & 1=count x;"enlist ";""],basic x};                                                         // Where clause needs to be a list of where clauses, so if only one where clause need to enlist.

    ab:{                                                                                                                // If a dictionary apply to both, keys and values
        $[(0=count x) | -1=type x;
        .Q.s1 x;99=type x;
        (addbraks stringify key x),"!",stringify value x;stringify x]};

        inner:{[x]
         idxs:2 3 4 5 6 inter ainds:til count x;
         x:@[x;idxs;'[ab;eval]];
         if[6 in idxs;x[6]:ssr/[;("hopen";"hclose");("iasc";"idesc")] x[6]];

         //for select statements within select statements
         x[1]:$[-11=type x 1;x 1;[idxs,:1;.z.s x 1]];
         x:@[x;ainds except idxs;string];
         x[0],strBrk[1_x;"[";"]"]
         };

        write:{                                                                                                         // Call the write statement to do the conversion.
            [x]inner parse x
            };
    :write[x]
    };


\d .