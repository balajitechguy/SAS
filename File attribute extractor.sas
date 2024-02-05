/**************************************************************************************************
* Program Name   : FileAttribute.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to extract file attributes
* Usecase		 : If user wants to find the files with no data Ex: RTF, PDF using the file size attributes
* Macro Description : directory:- location were all files are located
					  extension:- Ex:RTF, PDF, .SAS etc
					  dataset:- final dataset with all file attributes details
******************************************************************************************************/

 
%macro fileattrib (directory, extension, dataset);                                                                                                                   
 
data &dataSet(drop=fid ff filrfb rc); 
retain file date size_kb;
%let bb=%sysfunc(filename(filrf,&directory));
 
%let did=%sysfunc(dopen(&filrf));
 
%let flname=;
 
%let memcount=%sysfunc(dnum(&did));
 
%if &memcount > 0 %then %do i=1 %to &memcount;
 
    %let flname&i=%qsysfunc(dread(&did,&i));
 
  %if %scan(&&flname&i,-1,.) = &extension or &extension = all %then %do;
 
     filrfb='temp';
 
     ff=filename(filrfb,"&directory\&&flname&i");
 
     fid=fopen(filrfb);
 
     date=finfo(fid,'Last Modified');  
 
     size=finfo(fid,'File Size (bytes)');  
     size_kb=round(input(Size,8.)/1024);
 
     file=symget("flname&i");   
 
     output;  
 
     rc=fclose(fid);      
     drop size;
  %end;
 
%end;   
 
%let rc=%sysfunc(dclose(&did));  
 
run;
 
%mend fileattrib;
%fileattrib (directory=O:\Users\Balaji.M, extension=sas, dataset=info);