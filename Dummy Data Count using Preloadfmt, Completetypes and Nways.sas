/**************************************************************************************************
* Program Name   : Dummycount.sas
* Author         : Balaji.M
* SAS Version    : SAS 9.4 or higher
* Description    : This SAS program is use to count data which is not present in dataset using preloadfmt, nway and completetypes
******************************************************************************************************/

/*Dummy Dataset with no female values*/
data class;
  set sashelp.class;
  where sex = "M";
  count = 1;
run;

/*Format*/
proc format;
  value $sex
    "F"="Female"
    "M"="Male"
  ;
run;

/*N count*/
proc means data = class2 nway completetypes;
  class sex/ preloadfmt;
  var count;
  output n=count out = result2;
  format sex $sex.;
run;