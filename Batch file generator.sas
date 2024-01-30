/**************************************************************************************************
* Program Name   : Batchfilegenerator.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to generate a batch file which can run all programs simultaneously
* Macro Variable : sourcepath:- directory location were all sas progams are located
				   batch_file_name:- batch file name  
******************************************************************************************************/

/*SourcePath - Program path and the batch file output path*/
%let SourcePath = C:\Users\balajim\Desktop\MY CODES;
%let batch_file_name=batch_all.bat;
/*
Reads the .sas files in &location.
*/
%macro GetFilenames(location);
 filename _dir_ "%bquote(&location.)";
 data filenames(keep=memname);
 length memname $100.;
  handle=dopen( '_dir_' );
  if handle > 0 then do;
   count=dnum(handle);
   do i=1 to count;
    memname=dread(handle,i);
    output filenames;
   end;
  end;
  rc=dclose(handle);
  run;
  data filenames;
  set filenames;
  where index(memname,".sas")>1 & index(memname,"batch")<1;
 run;

 filename _dir_ clear;
%mend;

%GetFilenames(&SourcePath.);

/*To reset all content */
data empty;
	stop;
run;

filename outfile "&SourcePath.\&batch_file_name.";

data _null_;
	set empty;
	file outfile;
	put;
run;

data pg_list__;
	set filenames;
	program1=strip(cats('"',memname,'"'));
	memname=strip(memname);
	if index(program1,"Check_all_logs")>1 then delete;
run;

proc sql noprint; select count(program1) into :pg_count from pg_list__; quit;

%put "Total No of programs=&pg_count";

/*Copy all content*/
data pg_list_;
	file "&SourcePath.\&batch_file_name." ;
	put '@echo off';
	put 'echo This batch file will run all programs in directory';
	put 'pause';
run;

data _null_;
	set pg_list__;
	file "&SourcePath.\&batch_file_name." mod ;
	put 'call "D:\Program Files\SASHome\SASFoundation\9.4\SAS.exe" -sysin ' program1;
	if flag="NO" then do;
	put '::call "D:\Program Files\SASHome\SASFoundation\9.4\SAS.exe" -sysin ' program1;
	end;
run;

data _null_;
	file "&SourcePath.\&batch_file_name." mod ;
	put 'call "D:\Program Files\SASHome\SASFoundation\9.4\sas.exe" -sysin "Check_all_logs.sas " ';
run;
