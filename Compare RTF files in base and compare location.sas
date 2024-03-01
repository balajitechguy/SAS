/**************************************************************************************************
* Program Name   : RTFCOMPARE.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program used to compare rtf files in base and compare location for value level changes
******************************************************************************************************/
/*INPUT THE BASE AND COMPARE DIRECTORY INFORMATION*/
%let basedir=O:\Users\Balaji.M\RTF Comp\BASE;
%let comparedir=O:\Users\Balaji.M\RTF Comp\COMP;
%let macropt= mprint mlogic symbolgen;

/*SETUP PROCESS*/
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

options nomprint nomlogic nosymbolgen;
%macro info(loc=,dir=);
/*To get list of all rtf files in basedir and comparedir*/
data filenames_&dir.;
	length fref $8 fname_rtf $200;
	did = filename(fref,"&loc");
	did = dopen(fref);
	do i = 1 to dnum(did);
	  fname_rtf = dread(did,i);
	  output;
	end;
	did = dclose(did);
	did = filename(fref);
/*To keep only rtf files*/
	if index(fname_rtf,".rtf")>0;
	keep fname_rtf;

	proc sort;by fname_rtf;
run;

%mend info;
%info(loc=&basedir,dir=basedir);
%info(loc=&comparedir,dir=comparedir);

/*	To check for new rtf files comparing the base and compare directory*/
data both newfiles;
	merge filenames_basedir(in=a) filenames_comparedir(in=b);
	by fname_rtf;
	if a and b then output both;
	if b and not a then output newfiles;
run;

/*Generate macro variables for base and compare directory files*/
proc sql noprint;
	%global lst;
	select count(*) into :newobs from newfiles; 
	select fname_rtf into :lst separated by '$' from both;
	select tranwrd(fname_rtf,".rtf","$") into :lst1 separated by '' from both;
quit;

/*Remove temporary datasets*/
proc sql noprint;
  drop table filenames_basedir,filenames_comparedir,both;
quit;

/*Comparison of files which are present in both base and compare location*/
%macro comp;	

	%do i=1 %to %sysfunc(countw(&lst1));
    %let lst_=%scan(&lst,&i,"$");
	%put &lst_;
	%let lst1_=%scan(&lst1,&i,"$");

/*Read base rtf file into sas dataset*/
DATA base_&lst1_;
	length string filename $32767.;		
	INFILE "&basedir\&lst_" lrecl=32767  end=eof ;
	INPUT;
	filename="&lst_";
	string=_infile_;
	base_code=string;
	n=_n_;

	proc sort;by n string;
RUN;

/*Read compare rtf file into sas dataset*/
DATA compare_&lst1_;
	length string filename $32767.;		
	INFILE "&comparedir\&lst_" lrecl=32767  end=eof ;
	INPUT;
	filename="&lst_";
	string=_infile_;
	compare_code=string;
	n=_n_;

	proc sort;by n string;
RUN;

/*To check value level changes between base and compare files*/
DATA mismatch_&lst1_;
	retain base_code compare_code n;
	merge base_&lst1_(in=a) compare_&lst1_(in=b);
	by n;
	if base_code ne compare_code then flag="MISMATCH";
	if flag="MISMATCH" then output;
	drop string;
run;

proc sql noprint;select count(*)into:obs from  mismatch_&lst1_; quit;

/*Delete irrelevant datasets*/
%if &obs=0 %then %do;
proc delete data= base_&lst1_  compare_&lst1_ mismatch_&lst1_;
run;
%end;

%if &obs ne 0  %then %do;
proc delete data= base_&lst1_  compare_&lst1_;
run;
%end;

/*Set all datasets which contains rtf files with value level mismatch*/
data issuefiles_code;
	set mismatch_:;
run;

/*Contains a list of unique rtf files with mismatches*/
proc sql noprint;
	create table rtf_issue_files as select distinct filename from issuefiles_code;
quit;

/*Keep essential files at end of the list*/
%if %sysfunc(countw(&lst1))=&i. %then %do;
proc datasets library=work nolist;save issuefiles_code rtf_issue_files newfiles;
quit;

title "RTF FILES WITH MISMATCHES";
proc sql;select * from rtf_issue_files;
quit;
%end;

%if %sysfunc(countw(&lst1))=&i. and &newobs ne 0 %then %do;
title "RTF FILES PRESENT ONLY IN COMPARE LOCATION";
proc sql;select fname_rtf as filename from newfiles;
quit;
%end;

%end;
%mend comp;

/*Call macro to iterate over all rtf files*/
%comp;

