/**************************************************************************************************
* Program Name   : Keywordsearch.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to search a keyword across all sas programs in a directory
* Macro Variable : path:- directory location
				   pgnm:- program common name EX:figure,table,listing,etc. 
				   searhcstring:- the keyword intended to search
******************************************************************************************************/

/*SETUP PROCESS*/
option nomprint nomlogic nosymbolgen nonotes nosource;
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
dm "log" clear continue;
%end;
options source;

/*MACRO BEGINS*/
%MACRO SEARCH(path=,pgnm=,searchstring=);
option NOXWAIT NOXSYNC;
filename ren pipe "dir ""&path.\&pgnm*.sas"" /b /s";
%put &path.;
%let obs_count=0;
*dirinfo is a SAS data set that saves all the file information for the 
searching folder; 
data dirinfo; 
	infile ren pad;
	input wholename $250.;
	format filename $250.;
	filename=tranwrd(upcase(scan(wholename,-1,'\')),".SAS","");
	/*Filtering out irrelevant folders*/
	if index(upcase(wholename),"ARCHIVE") or index(upcase(wholename),"SFTP") or index(upcase(wholename),"VAL") then flag="IGNORE";
	if index(filename,%upcase("&pgnm."))>0 & flag^="IGNORE" then output;
	drop flag;
run;

proc sql noprint;select count(*)into:obs_dir from dirinfo; quit; 


%if &obs_dir^=0 %then %do;
*To count number of program files;
data _null_;
	set dirinfo end=end;
	num=cats(_n_);
	call symput("m"||num,cats(wholename));
	call symput("n"||num,cats(filename)); 
	if end then call symput("file_ct",num); 
run;

%do i=1 %to &file_ct.;
*sasfile_&i. is the SAS data set that saves the SAS program codes;
data sasfile_&i.;
	infile "&&m&i"
	delimiter = '@@' missover dsd lrecl=32767 firstobs=1 TERMSTR=CRLF;
	informat all $char5000. ;
	input all $; 
	all=upcase(all);
run;

data sasfile_&i.;
	length wholename $32767. filename $50. all $32767.;
	wholename="&&m&i";
	filename="&&n&i";
	set sasfile_&i.;
	line_no=_n_;
run;

*contain_string_sasfile_&i. contains the SAS codes that have the search string; 
data contain_string_sasfile_&i.;
	set sasfile_&i.;
	if index(all,%upcase("&searchstring.")) >0 then output contain_string_sasfile_&i.;
run;

proc sql noprint;select count(*)into:obs from contain_string_sasfile_&i.; quit;

/*Delete irrelevant datasets*/
%if &obs=0 %then %do;
proc delete data=contain_string_sasfile_&i. sasfile_&i.;;
run;
%end;

%end;

*search_result is the SAS data set that contains all the search_results;
data search_result;
	set contain_string_sasfile_:;
run;
proc sort data=search_result;by wholename line_no;run;

proc sql noprint;select count(*)into:obs_count from search_result; quit;

proc datasets library=work nolist;save search_result dirinfo;
quit;

%end;

%if &obs_count=0 or &obs_dir=0 %then %do;
data search_result;
	MESSAGE="DESIRED RESULTS NOT FOUND";
run;
%end; 

%MEND SEARCH;

%search(path=%str(C:\Users\balajim\Desktop\MY CODES)
,pgnm=figure
,searchstring=individual);

