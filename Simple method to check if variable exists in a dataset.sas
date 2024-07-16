/**************************************************************************************************
* Program Name   : Simple method to check if variable exists in a dataset
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use check existence of variable in a dataset
******************************************************************************************************/

%macro varexist(in=);

/*Check for epoch variable existence*/
proc sql noprint;
	create table varexist as select * from dictionary.columns
	where upcase(libname)="WORK" and upcase(memname)=%upcase("&in") and upcase(name)="EPOCH";
	select count(*) into:varcount from varexist;
quit;

%if &varcount gt 0 %then %do;
proc sort data=&in. out=&in.1(drop=epoch);
	by usubjid;
run;
%end;

%if &varcount eq 0 %then %do;
proc sort data=&in. out=&in.1;
	by usubjid;
run;
%end;

%mend varexist;

%varexist(in=ex);