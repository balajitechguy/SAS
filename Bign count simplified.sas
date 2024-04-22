/**************************************************************************************************
* Program Name   : Bign_counter.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to generate subject counts from adsl dataset with dummy treatment groups 
				   in below example Drug C is counted with dummy values for testing purpose.
*Macro variable	 : data:- Input Dataset
				   var:-  Variables used for counting and sorting purpose should be included
				   trts:- treatment group start numeric value
				   trte:- treatment group end numeric value
******************************************************************************************************/

data sample_adsl;
	trta="Placebo";trtan=0;usubjid="A1";output;
	trta="Drug A";trtan=1;usubjid="B2";output;
	trta="Drug B";trtan=2;usubjid="C3";output;
	trta="Placebo";trtan=0;usubjid="D4";output;
	trta="Drug A";trtan=1;usubjid="E5";output;
run;

%macro count(data=,var=,trts=,trte=);
proc sql noprint;
	create table count as select &var. from &data. order by &var.;
	%do i=&trts. %to &trte.;
	%global bign&i.;
		select count(distinct usubjid) into: bign&i. from count where trtan=&i;
		%put  bign&i. &&bign&i.;
	%end;
quit;
%mend count;

%count(data=sample_adsl,var=%str(trtan,trta,usubjid),trts=0,trte=3);




