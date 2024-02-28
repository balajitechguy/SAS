/**************************************************************************************************
* Program Name   : CLOSEWINDOWS.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program used to close all opened windows in windows at once using SAS

******************************************************************************************************/
/*Location of script file */
filename bat 'O:\Users\Balaji.M\close.bat';
 
/*Include the application name below to close windows at once*/
data _null_;
file bat;
input;
put _infile_;
datalines;
taskkill /f /im msedge.exe /T > nul
taskkill /f /im excel.exe /T > nul
taskkill /f /im winword.exe /T > nul
taskkill /f /im explorer.exe /T > nul
taskkill /f /im sas.exe /T > nul
;
run;

/*To execute script file using SAS*/
options noxwait noxsync;
data _null_;
X 'O:\Users\Balaji.M\close.bat';
run;
