clear 
cls
cd "C:\Users\XPS\Documents\labor econ\project1"

log using Project1.log, replace 

use "shiw20 (1).dta"


gen female = (sex == 2)  
drop if q ==2
drop if q ==3
drop if qual >=4
gen blue_collar = (qual ==1)
gen white_collar = (qual ==2)
gen manager = (qual ==3)
gen part_time = (partime==2)
gen north = (area3==1)
gen centre = (area3 ==2)
gen south = (area3 ==3)
gen eta2 = (eta^2)
gen married = (staciv ==2)
replace nfigli = 0 if missing(nfigli)
replace ylnm = 0 if missing(ylnm)
gen total_income = ylnm + ylm
gen log_income = log(total_income)

// Descriptive Statistic 
estpost tabstat total_income eta studio married nfigli oretot blue_collar white_collar manager north centre south part_time  if female == 0, statistics(mean sd) columns(statistics)
est store male_stats

estpost tabstat total_income eta studio married nfigli oretot blue_collar white_collar manager north centre south part_time if female == 1, statistics(mean sd) columns(statistics)
est store female_stats

esttab male_stats female_stats using "gender_stats_side_by_side1.tex", ///
    cells("mean(fmt(2)) sd(fmt(2))") noobs replace label ///
    title("Summary Statistics by Gender") ///
    mtitles("Male" "Female") ///
    booktabs
 
 tabstat yl1 ,by (female) s(mean sd median)
 
// OLS regression 
 
 ssc inst outreg2
 reg log_income female, r
 estimates store firstcol 
outreg2 firstcol using "Project3.tex", replace

reg log_income female studio eta eta2 oretot part_time blue_collar white_collar manager north centre south married nfigli,r 
estimates store secondcol 
outreg2 secondcol using "Project3.tex", append
 
 // Blinder_Oaxaca decomposition 
 
 ssc install oaxaca
 
  oaxaca log_income eta eta2 studio oretot part_time married nfigli north  south  blue_collar white_collar , r by(female) noisily
  outreg2 ao using "aoxaca2.tex", replace
  
// compare regions

* Northern Region
oaxaca log_income eta eta2 studio oretot part_time married nfigli blue_collar white_collar if area3 == 1, r by(female)  

* Central Region
oaxaca log_income eta eta2 studio oretot part_time married nfigli blue_collar white_collar if area3 == 2, r by(female)  

* Southern Region
oaxaca log_income eta eta2 studio oretot part_time married nfigli blue_collar white_collar if area3 == 3, r by(female)  

log close 
