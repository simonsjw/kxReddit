
\d .hBr

// @kind function
// @fileoverview allColTypes returns the types of every element in each feature of the datatable.
// @param x {table} A table to be analysed
// @return array {(string; (int))[]} an array of tuples where each sub list contains the name of a column and the data types found in that column.
allColTypes:{[testTbl]{(y;distinct type each x[y])}[testTbl;] each cols testTbl};

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

// @kind function
// @fileoverview logInit sets up logging to a local file and to systemctl. 
// @param logPath {hsym} The file path to the local log file.
// @return null {null} no value is returned.
logInit:{[logPath]                                                                                                      // set up logging (event types: SILENT DEBUG INFO WARN ERROR FATAL)
    .log4q.a[hopen logPath;`SILENT`DEBUG`INFO`WARN`ERROR`FATAL];                                                                     // Add log to file.   
//     .log4q.a[(-334;{[x;y] system "logger -p local0.emerg ",y;}); `FATAL];                                               // Add log to systemctl. (map FATAL to emerg)
//     .log4q.a[(-334;{[x;y] system "logger -p local0.err ",y;}); `ERROR];                                                 // Add log to systemctl. (map ERROR to err)
//     .log4q.a[(-334;{[x;y] system "logger -p local0.warning ",y;}); `WARN];                                              // Add log to systemctl. (map WARN to warning)
//     .log4q.a[(-334;{[x;y] system "logger -p local0.info ",y;}); `INFO];                                                 // Add log to systemctl. (map INFO to info)
//     .log4q.a[(-334;{[x;y] system "logger -p local0.debug ",y;}); `DEBUG`SILENT];                                        // Add log to systemctl. (map DEBUG to debug. Note that SILENT is also mapped to DEBUG)                                             
    
    };


logFmtFull:{
    .log4q.fm: "%c\t[%p]:H=%h:PID[%i]:%d:%t:%f: %m\r\n";
    };

logFmtDefault:{
    .log4q.fm: "%c\t[%p]:PID[%i]: %m\r\n";
    };

\d .