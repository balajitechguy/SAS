/**************************************************************************************************
* Program Name   : Runtimecheck.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to check the runtime of sas program during execution
******************************************************************************************************/

/* Start timer */
%let _timer_start = %sysfunc(datetime());

*SAS CODE STARTS;
%macro set_same_dataset(data);
    %do i = 1 %to 100;
        data same_dataset&i;
            set &data.;
        run;
    %end;
%mend set_same_dataset;
%set_same_dataset(sashelp.class);
*SAS CODE ENDS;

/* Stop timer */
data _null_;
  dur = datetime() - &_timer_start;
  put 30*'-' / ' TOTAL DURATION:' dur time13.2 / 30*'-';
run;