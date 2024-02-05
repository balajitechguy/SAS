/**************************************************************************************************
* Program Name   : Columnsearch.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use find the column presence across all datasets in a library
******************************************************************************************************/
/* Define the library containing the datasets */
libname mylib 'C:\Users\balajim\Desktop\MY CODES' access=readonly;

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
