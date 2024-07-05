/**************************************************************************************************
* Program Name   : Print user specified error in log
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to print user specified error in log for better debugging 
******************************************************************************************************/
/*Check for partial dates*/
proc sql noprint;
	create table pardate as select distinct rfstdtc, rficdtc, &dtc., v8s, v15s, vmaxe from &in.1a 
	where (length(rfstdtc) not in (1,10,19)) or 
	      (length(rficdtc) not in (1,10,19)) or 
	      (length(&dtc.) not in (1,10,19)) or 
	      (length(v8s) not in (1,10,19)) or 
	      (length(v15s) not in (1,10,19)) or 
	      (length(vmaxe) not in (1,10,19)); 
	select count(*) into :obsp from pardate;
quit;

%if &obsp gt 1 %then %do;
data _null_; 
	putlog "ERROR: PARTIAL DATES FOUND CHECK";
run;
%end;