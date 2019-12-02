
\d .fT

// @kind function
// @fileoverview fExists returns a True if the file specified in a file handle exists. Otherwise, it returns False.
// @param x {hsym} A file/folder handle
// @return exists? {bool} True or False depending on whether the file exists. 
fExists:{[fileHandle] not () ~ key fileHandle}; 

// @kind function
// @fileoverview nukeDir removes a directory from the file system even if it contains something. 
// @param dirTarget {hsym} A file/folder handle
// @throws Error rank thrown if the directory is empty. 
// @return null
nukeDir:{[dirTarget]
        / diR gets recursive dir listing
        diR:{$[11h=type d:key x;raze x,.z.s each` sv/:x,/:d;d]};
        / hide power behind nuke
        nuke:(hdel each desc diR @); / desc sort!
        nuke[dirTarget];
    }

// @kind function 
// @fileoverview redditFileInfo returns information about a file path given a 
// @param x {string} A valid file path.
// @returns {dict(dir:string[]); file:string; year:string; month:string} A dictionary of features derived from a file
// name.
// @desc dict.dir a list corresponding to each level of the nested file path of the file.
// @desc dict.file the name of the file
// @desc dict.year the year that the information relates to given the file name
// @desc dict.month the month that the information relates to given the file name
// @example file data.
// // Return the data for a file given a file handler. 
// fHandle: hsym `$"/import/RS_2014-11";
// .hBr.redditFileInfo fHandle
// 
// /=> `dir`file`year`month!((enlist "import");"RS_2014-11";"2014";"11")
redditFileInfo:{[source]
    comp:("/" vs string source);
    comp: 1 _ comp;
    file: last comp;
    dir: ((count comp)-1) # comp;
    year: ("_" vs file)[1][til 4];
    month: ("_" vs file)[1][5 + (til 2)];
    :(`dir`file`year`month)!(dir;file;year;month)
    };

\d .