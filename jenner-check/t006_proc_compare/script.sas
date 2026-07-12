/**************************************************************************************************
* Program Name   : Ignorespace.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program used to ignore spaces while a proc compare process

******************************************************************************************************/

/* mock caller: chk1/chk2 with a value that differs only by extra
   whitespace, to exercise the array-driven COMPRESS(...,'s') space
   normalization before PROC COMPARE runs (the macro's %dev./%val.
   parameters had no caller in the source repo) */
data chk1;
	id=1; name="Balaji  M"; output;
	id=2; name="Anita K";   output;
run;

data chk2;
	id=1; name="Balaji M";  output;
	id=2; name="Anita  K";  output;
run;

%macro space(dev=,val=);

data dev;
    set &dev.;
	array chk _character_;
   do over chk;
       chk=compress(chk,'a0'x,'s');
   end;
run;

data val;
    set &val.;
	array chk _character_;
   do over chk;
       chk=compress(chk,'a0'x,'s');
   end;
run;

proc compare base=dev compare=val;
run;

%mend space;

%space(dev=chk1 , val=chk2);
