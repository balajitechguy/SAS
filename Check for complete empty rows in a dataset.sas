/**************************************************************************************************
* Program Name   : CheckEmpty.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to detect empty rows in a dataset
******************************************************************************************************/

proc sort data=mylib.cm(encoding=any) out=cm;
by subject;
run;

proc contents data=cm out=test;
run;

proc sql;
select distinct name into :var separated by "," from test where upcase(name) ^= "SUBJECT";
quit;

proc sql;
select distinct count(name) into :c from test where upcase(name) ^= "SUBJECT";
quit;

data empty;
set cm;
if cmiss(&var) = &c then output empty;
run;