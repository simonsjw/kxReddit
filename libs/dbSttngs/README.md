// @kind readme
// @author simon.j.watson@gmail.com
// @name .dSttngs/README.md
// @category .dbSttngs
// # .dSttngs
// The dSttngs namespace contains items for initialising the hdb.
// It contains the following items:
//  - .dSttngs.dbStucture
//  - .dSttngs.build
// 
// ## .dSttngs.dbStructure
// The dbStructure function sets up objects containing information about the database. 
// They are: 
// |function &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;|example &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp;|description &nbsp; &nbsp;|
// |--------|-------|-----------|
// |fileStruct.dbdir|hsym `` ` ``$"/import/redditdb"|a file handler pointing to the directory in which the hdb resides. |
// |fileStruct.inputdir|hsym `` ` ``$"/import"|a file handler pointing to the directory in which any source data objects can be imported from. |
// |partitionCol|(enlist ```RS)!(enlist `` ` ``created)|a dictionary with table names as keys and then the partition field for those tables as values. |
// |dbSettings.importChunkSize|(enlist `` ` ``RS)!(enlist 1300000)|a dictionary with table names as keys and the number of bits per import as values. |
// |dbSettings.removeCols|(enlist `` ` ``RS)!(enlist `` ` ``created_utc)|a dictionary with table names as keys and the columns to be removed before writing to disk as values. |
//
// The function does not take or return arguments. 
//
// ## .dSttngs.build
// The script loads the hdb prior to setting up the namespace since it needs to remove and rebuild elements of it.
// The table built in this process is tblProcessManager. 
//  - tblProcessManager.process  The name of the process that each element in the table belongs to. The elements are used in these groups.
//  - tblProcessManager.args     The arguments (usually the table and column to be manipulated in a function from fn and arguments to drive that function).
//  - tblProcessManager.fn       A function or functions to be carried out with the arguments provided in column args.
//  - tblProcessManager.note     A note on any issues related to the use of that element 
//  - tblProcessManager.recDate  The date the element was committed to disk.
//  - tblProcessManager.recID    A unique identifier for each element in the table.
//
// The function does not take or return arguments. 
//
// @end
