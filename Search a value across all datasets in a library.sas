/**************************************************************************************************
* Program Name   : Valuesearch.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use search to a value across all datasets in a library
* Macro Description: lib:-library location
					 col:- column name EX:USUBJID
					 value:- value of the column to search
******************************************************************************************************/
dm 'odsresults; clear';
options nonotes;
/* Get a list of all the datasets in the library */
%macro search_ds(lib=,col=,val=);
proc contents data=&lib.._all_ out=column_info noprint;
run;
 
data column_info;
	set column_info;
	if upcase(libname)=%upcase("&lib.") & upcase(name)=%upcase("&col.") then output;
run;
 
proc sql noprint;
	select memname
	into :dslist separated by ' '
	from column_info;
quit;
 
/* Loop through each dataset and search for the column value */
%do i=1 %to %sysfunc(countw(&dslist.));
    %let ds=%scan(&dslist.,&i.);
    %let obs_count=0;
    proc sql noprint;
    select count(*) into :obs_count 
    from mylib.&ds.
    where &col. = &val.;
    quit; 
    %if &obs_count ne 0 %then %do;
    title &ds.;
    proc sql;
    select *
    from mylib.&ds.
    where &col. = &val.;
    quit;
    %end;
%end;
%mend search_ds;
options notes;