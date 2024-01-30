/**************************************************************************************************
* Program Name   : Columnsearch.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use search to a column across all datasets in a library and print respective datasets in the log
******************************************************************************************************/
/* Define the library containing the datasets */
libname mylib 'O:\Eisai\projects\e2086\a001-001\biostats\csr\dev\data\sds' access=readonly;

/* Specify the column name to search for */
%let column_name = USUBJID;

/* Create a macro variable to store the datasets containing the column */
%let datasets = ;

/* Use proc sql to loop through the datasets in the library */
proc sql noprint;
  select memname into :datasets separated by " "
  from dictionary.columns
  where libname="MYLIB" and upcase(name)="&column_name";
quit;

 

/* Print the list of datasets containing the column */
%put Datasets containing &column_name: &datasets;
