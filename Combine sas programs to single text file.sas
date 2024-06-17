/**************************************************************************************************
* Program Name   : Combinesas.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to generate a single text file out of all sas programs
* Macro Variable : inpath:- directory location were all sas progams are located
				   outpath:- directory to store the combined text file
				   combinefilename:- combined text file name
******************************************************************************************************/
%let inpath=O:\Users\Balaji.M\Comb\;
%let outpath=O:\Users\Balaji.M\Comb\;
%let combfilename=COMBINED;


filename _dir_ "%bquote(&inpath)";
data filenames(keep=filenames);
  length filenames $1000.;
  handle=dopen( '_dir_' );
  if handle > 0 then do;
   count=dnum(handle);
   do i=1 to count;
    filenames=%str("&inpath")||dread(handle,i);
    output filenames;
   end;
  end;
  rc=dclose(handle);
run;

proc sort data=filenames;
by filenames;
where index(filenames,".sas")>0;
run;

proc sql noprint;
select distinct cats('''',filenames,'''') into : file separated by ',' from filenames;
quit;
%put &file;

filename in (&file.);
data all ;
  infile in truncover dsd ;
  input id :$20. ;
  length line $32767;
  line=_infile_;
run;

data _null_;
  file "&outpath.&combfilename..txt" ;
  set all;
  len = lengthn(line);
  put line $varying32767. len;
run;
