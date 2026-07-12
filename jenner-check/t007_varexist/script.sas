/**************************************************************************************************
* Program Name   : Simple method to check if variable exists in a dataset
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use check existence of variable in a dataset
******************************************************************************************************/

/* mock caller: a WORK.ex dataset with usubjid + epoch, so %varexist(in=ex)
   has a real dataset to inspect via dictionary.columns (the repo had no
   caller for this macro) */
data ex;
	usubjid="S001"; epoch="TREATMENT"; output;
	usubjid="S002"; epoch="TREATMENT"; output;
	usubjid="S003"; epoch="FOLLOWUP";  output;
run;

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
