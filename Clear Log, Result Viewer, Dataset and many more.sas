/**************************************************************************************************
* Program Name   : Essential_utility.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to clear sas log, result viewer, datasets. It can also close opened datasets automatically
				  using VIEWTABLE option in the display management feature avaialable in sas
******************************************************************************************************/
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