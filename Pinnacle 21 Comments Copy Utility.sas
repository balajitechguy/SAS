/**************************************************************************************************
* Program Name   : Pinnacle 21 Comments Copy Utility.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to copy user comments from one P21 file to another. User can pass two P21 files old
				   and new in thier respective macro variable. Final results will be printed in the result viewer so that user 
				   can copy paste into the latest P21 file.
*Macro variable	 : old_pinnacle:- Provide path for old p21 file 
				   new_pinnacle:- Provide path for new p21 file 
*How does it work? :  Basically two P21 excel files are imported and then arranged and finally merged. The comments from old P21
						file are carry forwarded and printed in the result viewer.
******************************************************************************************************/

/*Setup */
options nosource;
%if DMS=%sysfunc(getoption(dms)) %then %do;
%macro closevts;
    %do i=1 %to 10; 
        data _null_;
            dm 'next VIEWTABLE:; end;'; 
        run;
    %end; 
%mend;
%closevts
proc delete data=work._all_;run;
dm 'odsresults; clear';
dm "log" clear continue;
%end;
options source;

/*Mention path of old and new pinnacle OCV paths*/
%let old_pinnacle=O:\Users\Balaji.M\Pinnacle Comments\SDTM_OCV_OLD.xlsx;
%let new_pinnacle=O:\Users\Balaji.M\Pinnacle Comments\SDTM_OCV_NEW.xlsx;

/*Import old pinnacle file*/
proc import datafile="&old_pinnacle" out=oldpin(rename=(a=data_old b=id_old c=message_old d=severity_old 
	e=found_old)) dbms=xlsx replace;sheet="Issue Summary";getnames=NO;datarow=5;
run;

/*Import new pinnacle file*/
proc import datafile="&new_pinnacle" out=newpin(rename=(a=data_new b=id_new c=message_new d=severity_new 
	e=found_new)) dbms=xlsx  replace; sheet="Issue Summary";getnames=NO;datarow=5;
run;

/*Generate sequence variable on old pinnacle dataset*/
data oldpin_;
	set oldpin;
	retain _variable;
	if not missing(data_old) then _variable=data_old;
	else data_old=_variable;
	a=data_old;
	b=id_old;
	c=message_old;
	drop _variable;
data oldpin_;
	set oldpin_;
	by data_old notsorted;
	retain seq 0;
	if first.data_old then seq=seq+1;
	else seq=seq;
proc sort;
	by a b c;
run;

/*Generate sequence variable on new pinnacle dataset*/
data newpin_;
	set newpin;
	retain _variable;
	if not missing(data_new) then _variable=data_new;
	else data_new=_variable;
	a=data_new;
	b=id_new;
	c=message_new;
	drop _variable;
data newpin_;
	set newpin_;
	by data_new notsorted;
	retain seq 0;
	if first.data_new then seq=seq+1;
	else seq=seq;
proc sort;
	by a b c;
run;

/*Merge old and new pinnacle files to extract comments from old file*/
data pin;
	retain data_new id_new message_new severity_new found_new severity_new found_new f;
	merge oldpin_(in=x) newpin_(in=y);
	by  a b c;
/*	Remove comments of dataset which is present only in old*/
	if not missing(f) and missing(data_new) then delete;
	if missing(f) and missing(data_new) then delete;
	keep data_new id_new message_new severity_new found_new severity_new found_new f seq;
proc sort;
	by seq data_new id_new message_new;
run;

/*Print user comments*/
proc sql;
	title "COMMENTS";
	select f
	from pin;
quit;
