/**************************************************************************************************
* Program Name   : CloseRTF.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to close RTF files automatically while execution to avoid SAS errors in log
******************************************************************************************************/


/* Use DDE to make the request to Microsoft Word */
filename word dde 'winword|system';

data _null_;
   file word;

/* The following PUT statements execute Microsoft Word commands */
   put '[FileClose 2]'; 
   put '[FileExit 2]'; 
run; 

/* Test file */

ods rtf file="O:\Users\Balaji.M\myfile.rtf";

proc tabulate data=sashelp.class;
   class age sex;
   table age,sex;
run;

ods rtf close;