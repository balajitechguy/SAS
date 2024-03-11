/**************************************************************************************************
* Program Name   : Dynamicaxiscaling.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program used to generate max and by macro variable for dynamic axiscale
******************************************************************************************************/

options mprint mlogic symbolgen;
%macro axiscale();

%do i=1 %to %sysfunc(countw(&paramcd)); 
%let paramcd_ = %scan(&paramcd,&i,"$");

/*Find max value*/
proc sort data=final out=max;
by paramcd maxval;

data _null_;
	set max(keep=paramn paramcd maxval where=(paramcd="&paramcd_"));
	by paramcd maxval;
	if last.paramcd then output;
	call symputx("max",maxval,"G");
/*Compute max and by value*/
	unit=&max/10; 
	grade=floor(log10(unit)); 
	sunit=unit/(10**grade); 
	if sunit<sqrt(2) then interval=10**grade*1; 
	else if sunit<sqrt(10) then interval=10**grade*2; 
	else if sunit<sqrt(50) then interval=10**grade*5; 
	else interval=10**grade*10;
	maxscale=ceil(&max/interval)*interval; 
/*Assign Global max and by macro variable*/
	%global &paramcd_.max &paramcd_.by;
	call symputx("&paramcd_.max",put(maxscale,best.),"G"); 
	call symputx("&paramcd_.by",put(interval,best.),"G"); 
run; 

%end;

%mend axiscale; 

%axiscale;

