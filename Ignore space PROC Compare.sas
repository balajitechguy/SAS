/**************************************************************************************************
* Program Name   : Ignorespace.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program used to ignore spaces while a proc compare process

******************************************************************************************************/
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