/**************************************************************************************************
* Program Name   : Validate sort order of a dataset
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to check sort order of a dataset 
******************************************************************************************************/
proc sort data=sashelp.class out=class;
	by name age;
run;

proc contents data=class out=class_contents noprint;run;

proc print data=class_contents;
	var memname name sorted sortedby;
run;