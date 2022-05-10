/* required package */
*ssc install outreg2, replace
*ssc install estout, replace
*ssc install reghdfe, replace
*ssc install asdoc, replace

cd "D:\Dropbox\Silvia_Rigissa_Sofoklis\Comparative_Advantage\jhr\code_for_submission"
use data_students.dta, clear
*use D:\Dropbox\Silvia_Rigissa_Sofoklis\Comparative_Advantage\02_data_modified\student_level_final_decode_wage_2.dta, clear

noi:di ""
noi:di "#===============#"
noi:di "#  Main Tables  #"
noi:di "#===============#"
noi:di "" 	


	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Table 1     #" 
	noi:di "#----------------#"
	noi:di "" 
	
	/* Panel A */
	local vars  scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_AncientGreek 

		preserve
		tempname postMeans
		tempfile means
		postfile `postMeans' ///
			str100 varname maleMeans femaleMeans diffMeans pMeans using "`means'", replace
		foreach v of local vars {
			local name: variable label `v'
			ttest `v', by(female)
			post `postMeans' ("`name'") (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
		}
		postclose `postMeans'

		use `means', clear
		format *Means %9.3f
		list

		/* make latex table */
		*listtab * using Table_1_PanA.doc, replace // 
		asdoc list, replace save(Table_1_PanA) dec(3)
		listtab * using Table_1_PanA.tex, rstyle(tabular) replace // 
		restore
	
	/* Panel B */
	local vars STEM_sub nonSTEM_sub STEM_sub_mean_class nonSTEM_sub_mean_class  perc_rank_abs_adv  
	preserve
	label variable STEM_sub "Own Grade in STEM"
	label variable nonSTEM_sub "Own Grade in non-STEM"
	label variable STEM_non_STEM_sub "Student Abs STEM Adv"

		tempname postMeans
		tempfile means
		postfile `postMeans' ///
			str100 varname maleMeans femaleMeans diffMeans pMeans using "`means'", replace
		foreach v of local vars {
			local name: variable label `v'
			ttest `v', by(female)
			post `postMeans' ("`name'") (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
		}
		postclose `postMeans'

		use `means', clear
		format *Means %9.3f
		list

		/* make latex table */
		*listtab * using Table_1_PanB.doc, replace //
		asdoc list, replace save(Table_1_PanB.doc) dec(3)
		listtab * using Table_1_PanB.tex,  rstyle(tabular) replace //
		restore

	/* Panel C */
	preserve		
	local vars  track_11_2 stem_application econbusin_application health_application humanities_applied 

		tempname postMeans
		tempfile means
		postfile `postMeans' ///
			str100 varname maleMeans femaleMeans diffMeans pMeans using "`means'", replace
		foreach v of local vars {
			local name: variable label `v'
			ttest `v', by(female)
			post `postMeans' ("`name'") (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
		}
		postclose `postMeans'

		use `means', clear
		format *Means %9.3f
		list

		/* make latex table */
		*listtab * using Table_1_PanC.doc, replace // 
		asdoc list, replace save(Table_1_PanC.doc) dec(3)
		listtab * using Table_1_PanC.tex, rstyle(tabular) replace // 
		restore

	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Table 2     #" 
	noi:di "#----------------#"
	noi:di ""  
	
	preserve
	use data_class.dta, clear

		eststo clear
		foreach y in class_ability_mean class_ability_median prop_female_class female_peer_ability male_peer_ability female_peer_STEMability male_peer_STEMability female_peer_nonSTEMability male_peer_nonSTEMability{
		eststo: reg `y' class_number_1 class_number_2 class_number_3 class_number_4 class_number_5 i.idschoolcohort, cluster(schoolid)
		estadd local studentFE "-"
		estadd local schoolFE "Y"
		quietly summ `y'
		loc mymean: di %8.2f r(mean) 	
		estadd loc mD `mymean', replace	
		test class_number_1 class_number_2 class_number_3 class_number_4 class_number_5 
		loc myF: di %8.2f `r(F)'
		estadd loc myF `myF', replace	
		loc myP: di %8.2f `r(p)'
		estadd loc myP `myP', replace	
		quietly summ class_number
		loc mymean: di %8.2f r(mean) 
		estadd loc mDC `mymean', replace		
		}	
		noisily: esttab , keep(class_number_*) b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) label s(N mD mDC schoolFE myF myP, ///
			label("Obs." "Mean of Y" "Av. N. of classes per school" "School x Year FE" "F-Stat. Model" "P-value of F-model") fmt(%12.0gc))	

		esttab using Table_2.rtf, replace label modelwidth(6) keep(class_number_*) r2 mtitles("Class Av. GPA" "Class Median GPA" ///
			"Prop. Female" "Av. GPA Female" "Av. GPA Male" "Av. STEM  GPA Female" "Av. STEM  GPA Male" "Av. non-STEM  GPA Female" "Av. non-STEM  GPA Male") ///
			b(3) se(3) s(N mD schoolFE myF myP, ///
			label("Obs." "Mean of Y" "School x Year FE" "F-Stat. for joint significance" "P-value for joint significance") ///
			fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01) nonotes nogap ///
			prehead(`"{\rtf1\mac\deff0 {\fonttbl\f0\fnil Times New Roman;}"' `"{\info {\author .}{\company .}{\title .}{\creatim\yr2022\mo4\dy7\hr11\min21}}"' `"\deflang1033\plain\fs24"' `"{\footer\pard\qc\plain\f0\fs24\chpgn\par}"' `"\lndscpsxn\pgwsxn16840\pghsxn11901"' `"{"')

	restore
	
	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Table 3     #" 
	noi:di "#----------------#"
	noi:di ""  
	
	/* Drop outliers and clean missing observation*/
drop if abs_adv_stem>3 | abs_adv_stem<=0
drop if missing(track_11_2)
drop if missing(female)
drop if missing(STEM_sub )
drop if missing(nonSTEM_sub )
drop if missing(STEM_sub_mean_class )
drop if missing(nonSTEM_sub_mean_class)
drop if missing(class_STEM_nonSTEM)
drop if missing(STEM_sub_mean_class)
drop if missing(nonSTEM_sub_mean_class)
drop if missing(abs_adv_stem )

/* create raw gender gaps */
foreach y in track_11_2 stem_application stem_admitted{
quietly reg `y' female, cluster (idschoolcohort)
gen gg_`y'=_b[female]
}

/* compute rank within school*/
egen rank_abs_adv_school=rank(abs_adv_stem), by(idschoolcohort) track
egen N_school=count(rank_abs_adv_school), by(idschoolcohort)
gen perc_rank_abs_adv_school=round((rank_abs_adv_school-1)/(N_school-1),0.05)
tab perc_rank_abs_adv_school, sum(abs_adv_stem)
label variable perc_rank_abs_adv_school "\shortstack{Cohort Comparative\\in STEM advantage}  "

/* compute rank wrt male and female only*/
gen male=female==0
egen N_f=sum(female), by(idclass)
egen N_m=sum(male), by(idclass)

egen rank_abs_adv_female=rank(abs_adv_stem) if female==1, by(idclass) track
gen perc_rank_female=(rank_abs_adv_female - 1)/(N_f-1) if female==1

egen rank_abs_adv_male=rank(abs_adv_stem) if female==0, by(idclass) track
gen perc_rank_male=(rank_abs_adv_male - 1)/(N_m-1) if female==0

gen 	perc_rank_gender=. 
replace perc_rank_gender=perc_rank_male 	if !missing(perc_rank_male) // female==0 | 
replace perc_rank_gender=perc_rank_female 	if !missing(perc_rank_female) // female==1

la variable perc_rank_gender "\shortstack{Comparative STEM Adv. \\same gender classmates} " 

/* compute rank wrt different definition of STEM*/
gen abs_adv_class_stem=abs_adv_stem_class 

gen abs_adv_stem_3=abs_adv_stem^3
la variable abs_adv_stem_3 "$\text{STEM advantage}^3$"
gen abs_adv_stem_4=abs_adv_stem^4
la variable abs_adv_stem_4 "$\text{STEM advantage}^4$"
gen abs_adv_stem_5=abs_adv_stem^5
la variable abs_adv_stem_5 "$\text{STEM advantage}^5$"
gen abs_adv_stem_6=abs_adv_stem^6	

gen Female=female
label variable perc_rank_abs_adv "Comparative STEM Advantage"
gen perc_rank_abs_adv_fema=perc_rank_abs_adv*female
label variable perc_rank_abs_adv_fema "\shortstack{Comparative STEM Advantage\\ $\times$ Female}"

xtile _abs_dummy_adv_stem=abs_adv_stem, nq(10)
tab _abs_dummy_adv_stem, sum(abs_adv_stem)
tab _abs_dummy_adv_stem, gen(_abs_dummy_adv_stem_)

/* PANEL A */
eststo clear
*** linear
eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv  ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quadratic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear: _abs_dummy_adv_stem_
eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
di %8.2f r(p)
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

	
esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
		keep(*perc_rank_abs_adv*) 
		
esttab using Table_3_panelA.rtf, title({STEM Track in Grade 11}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

/* PANEL B */
label variable perc_rank_abs_adv_fema "\shortstack{Comparative STEM Advantage\\ $\times$ Female}"
eststo clear
*** linear
eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace	
*** quadratic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear
eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_class_stem ///
						i._abs_dummy_adv_stem_* ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema 	i._abs_dummy_adv_stem_*#c.female $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
		keep(*perc_rank_abs_adv*)  
		
esttab using Table_3_panelB.rtf, title({Application for STEM University Degree}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 2   #" 
	noi:di "#----------------------#"
	noi:di ""
 
eststo clear
foreach y in track_11_2 stem_application{ //stem_admitted{
eststo: reghdfe `y' Female abs_adv_stem  class_STEM_nonSTEM, ///
				absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes" 
estadd local controls "No"
quietly summ `y'
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_`y'
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

***
eststo: reghdfe `y' Female abs_adv_stem  class_STEM_nonSTEM c.abs_adv_stem#c.female  ///
				c.class_STEM_nonSTEM#c.female, ///
				absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "No"
quietly summ `y'
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_`y'
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
***
}	

esttab using Table_A2.rtf, mgroup("STEM Track in Grade 11" "Applied for STEM University Degree", pattern(1 0 1 0)) replace label modelwidth(6) r2 ///
	keep(Female abs_adv_stem c.abs_adv_stem#c.female class_STEM_nonSTEM c.class_STEM_nonSTEM#c.female) ///
	nomtitle b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 3   #" 
	noi:di "#----------------------#"
	noi:di ""

gen cardinal_comparative_STEM_adv=abs_adv_stem/class_STEM_nonSTEM
	label variable cardinal_comparative_STEM_adv "Cardinal Comparative STEM Adv."

eststo clear
foreach y in track_11_2 stem_application { //  stem_admitted{
eststo: reghdfe `y' Female cardinal_comparative_STEM_adv $studentcovariate, ///
				absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes" 
estadd local controls "No"
quietly summ `y'
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_`y'
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

***
eststo: reghdfe `y' Female cardinal_comparative_STEM_adv c.cardinal_comparative_STEM_adv#c.Female $studentcovariate, ///
				absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "No"
quietly summ `y'
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_`y'
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
***
}	

esttab using Table_A3.rtf, mgroup("STEM Track in Grade 11" "Applied for STEM University Degree", pattern(1 0 1 0)) replace label modelwidth(6) r2 ///
	keep(cardinal_comparative_STEM_adv c.cardinal_comparative_STEM_adv#c.Female) ///
	nomtitle b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01) nonotes 


	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Table 4     #" 
	noi:di "#----------------#"
	noi:di "" 
 	
merge 1:1  studentid using student_perform_11.dta
drop _merge
merge 1:1  studentid using student_perform_12.dta
drop _merge

egen STEM_sub_11=rmean( Algebra_11  Chemistry_11 Physics_11)
egen nonSTEM_sub_11=rmean(ModernGreek_11 GreekLiterature_11 AncientGreek_11)

egen STEM_sub_12=rmean( Algebra_12  Chemistry_12 Physics_12)
egen nonSTEM_sub_12=rmean(ModernGreek_12 GreekLiterature_12 AncientGreek_12)
	
replace STEM_sub_12=. if missing(STEM_sub_11)

*1] PANEL A	
eststo clear
*** linear
eststo: reghdfe STEM_sub_11 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv  ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_11
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** quadratic
eststo: reghdfe STEM_sub_11 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_11
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** cubic
eststo: reghdfe STEM_sub_11 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_11
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** quartic
eststo: reghdfe STEM_sub_11 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_11
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** quintic
eststo: reghdfe STEM_sub_11 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_11
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** non-linear: _abs_dummy_adv_stem_
eststo: reghdfe STEM_sub_11 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
di %8.2f r(p)
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ STEM_sub_11
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace

esttab using Table_4_panelA.rtf, title({STEM Performance in Grade 11}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

*] PANEL B
eststo clear
*** linear
eststo: reghdfe STEM_sub_12 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv  ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_12
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** quadratic
eststo: reghdfe STEM_sub_12 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_12
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** cubic
eststo: reghdfe STEM_sub_12 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_12
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** quartic
eststo: reghdfe STEM_sub_12 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_12
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** quintic
eststo: reghdfe STEM_sub_12 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ STEM_sub_12
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
*** non-linear: _abs_dummy_adv_stem_
eststo: reghdfe STEM_sub_12 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
di %8.2f r(p)
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ STEM_sub_12
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
	
esttab using Table_4_panelB.rtf, title({STEM Performance in Grade 12}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)
	
	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Table 5     #" 
	noi:di "#----------------#"
	noi:di "" 
gen perc_rank_gender_fema= perc_rank_gender*female 
	label variable perc_rank_gender "\shortstack{Comparative STEM Advantage same \ Gender Classmates}"
	label variable perc_rank_gender_fema "\shortstack{Comparative STEM Advantage same \ Gender Classmates $\times$ Female}"

*1] panel A
eststo clear
*** linear
eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_gender ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quadratic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_gender ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema  $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_gender ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema  $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_gender ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_gender ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear
eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_gender abs_adv_class_stem ///
						i._abs_dummy_adv_stem_* ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema  $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

esttab using Table_5_panelA.rtf, title({STEM Track in Grade 11}) replace label modelwidth(6) keep(*perc_rank_gender*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

*] PANEL B
label variable perc_rank_gender_fema "\shortstack{Comparative STEM Advantage\\ $\times$ Female}"
eststo clear
*** linear
eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_gender  ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema  $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace	
*** quadratic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_gender ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_gender ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema  $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_gender ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_gender ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear
eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_gender abs_adv_class_stem ///
						i._abs_dummy_adv_stem_*  ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_gender_fema  $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

esttab using Table_5_panelB.rtf, title({Application for STEM University Degree}) replace label modelwidth(6) keep(*perc_rank_gender*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Table 6     #" 
	noi:di "#----------------#"
	noi:di ""
	
gen perc_rank_school=perc_rank_abs_adv_school
gen perc_rank_school_fema= perc_rank_school*female
	label variable perc_rank_school "Cohort Comparative STEM Advantage  "
	label variable perc_rank_school_fema "\shortstack{Cohort Comparative STEM Advantage \\ $\times$ Female}  "

egen prop_female_class_=mean(female), by (idclass)
label variable prop_female_class_ "Prop of girls in classroom"
	
	
*1] PANEL A
eststo clear
*** linear
eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quadratic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear
eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem i._abs_dummy_adv_stem_* ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)		
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

esttab using Table_6_panelA.rtf, title({STEM Track in Grade 11}) replace label modelwidth(6) keep(*perc_rank_school*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

*] PANEL B	
eststo clear
*** linear
eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace	
*** quadratic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem  ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear
eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_school abs_adv_class_stem i._abs_dummy_adv_stem_* ///
						STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_school_fema c.abs_adv_class_stem#c.female ///
						c.STEM_sub_mean_classmates#c.female ///
						c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female prop_female_class_ $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year) vce(cluster idschoolcohort)		
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
****			

esttab using Table_6_panelB.rtf, title({Application for STEM University Degree}) replace label modelwidth(6) keep(*perc_rank_school*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 4   #" 
	noi:di "#----------------------#"
	noi:di ""

bysort classid: egen class_mean_abs_adv=mean(abs_adv_stem)

*] PANEL A
		eststo clear
		*** linear
		eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv  ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** quadratic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate ///
								c.abs_adv_stem_2#c.Female, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** cubic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
								STEM_sub nonSTEM_sub perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate ///
								c.abs_adv_stem_2#c.Female ///
								c.abs_adv_stem_3#c.Female , ///
								absorb(schoolid##year) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** quartic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
								STEM_sub nonSTEM_sub perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate ///
								c.abs_adv_stem_2#c.Female ///
								c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** quintic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
								STEM_sub nonSTEM_sub perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate ///
								c.abs_adv_stem_2#c.Female ///
								c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
								c.abs_adv_stem_5#c.Female, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)	
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** non-linear: _abs_dummy_adv_stem_
		eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate ///
								i._abs_dummy_adv_stem_*#c.female, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)	
		di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
		test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
		di %8.2f r(p)
		estadd local schoolyearFE "Yes"	
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace

			
		esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
				keep(*perc_rank_abs_adv*)    

esttab using Table_A4_panelA.rtf, title({STEM Track in Grade 11}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)				
		
*] PANEL B
	eststo clear
	*** linear
	eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace	
	*** quadratic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate ///
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** cubic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female , ///
							absorb(schoolid##year) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quartic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quintic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
							c.abs_adv_stem_5#c.Female, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** non-linear
	eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_class_stem ///
							i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema 	i._abs_dummy_adv_stem_*#c.female c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female $studentcovariate, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)		
	estadd local schoolyearFE "Yes"	
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace

	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)  				

esttab using Table_A4_panelB.rtf, title({Application for STEM University Degree}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)	

	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 5   #" 
	noi:di "#----------------------#"
	noi:di ""

bysort classid: egen class_sd_abs_adv=sd(abs_adv_stem)	
	
*] PANEL Appendix
		eststo clear
		*** linear
		eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv  ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** quadratic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate ///
								c.abs_adv_stem_2#c.Female, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** cubic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
								STEM_sub nonSTEM_sub perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate ///
								c.abs_adv_stem_2#c.Female ///
								c.abs_adv_stem_3#c.Female , ///
								absorb(schoolid##year) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** quartic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
								STEM_sub nonSTEM_sub perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate ///
								c.abs_adv_stem_2#c.Female ///
								c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** quintic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
								STEM_sub nonSTEM_sub perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate ///
								c.abs_adv_stem_2#c.Female ///
								c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
								c.abs_adv_stem_5#c.Female, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)	
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** non-linear: _abs_dummy_adv_stem_
		eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
								c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
								perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate ///
								i._abs_dummy_adv_stem_*#c.female, ///
								absorb(schoolid##year) vce(cluster idschoolcohort)	
		di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
		test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
		di %8.2f r(p)
		estadd local schoolyearFE "Yes"	
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace

			
		esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
				keep(*perc_rank_abs_adv*) 
				
esttab using Table_A5_panelA.rtf, title({STEM Track in Grade 11}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)				
		
*] PANEL B

	eststo clear
	*** linear
	eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace	
	*** quadratic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate ///
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** cubic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female , ///
							absorb(schoolid##year) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quartic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quintic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
							c.abs_adv_stem_5#c.Female, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** non-linear
	eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_class_stem ///
							i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema c.class_mean_abs_adv##c.female c.STEM_sub_mean_class##c.female c.nonSTEM_sub_mean_class##c.female c.class_size##c.female c.prop_female_class_##c.female c.class_sd_abs_adv##c.female c.class_sd_abs_adv##c.class_mean_abs_adv##c.female 	i._abs_dummy_adv_stem_*#c.female $studentcovariate, ///
							absorb(schoolid##year) vce(cluster idschoolcohort)		
	estadd local schoolyearFE "Yes"	
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace

	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)  
			
esttab using Table_A5_panelB.rtf, title({Application for STEM University Degree}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)			

	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 6   #" 
	noi:di "#----------------------#"
	noi:di ""

**** compute percentile rank in STEM and non-STEM
egen rank_STEM=rank(STEM_sub), by(idclass) track
tab rank_STEM
gen perc_rank_STEM=round((rank_STEM - 1)/(N-1), 0.01)
tab perc_rank_STEM

egen rank_nonSTEM=rank(nonSTEM_sub), by(idclass) track
tab rank_nonSTEM
drop perc_rank_nonSTEM
gen perc_rank_nonSTEM=round((rank_nonSTEM - 1)/(N-1), 0.01)
tab perc_rank_nonSTEM

	la variable perc_rank_STEM "Perc. Rank in STEM"
	la variable perc_rank_nonSTEM "Perc. Rank non-STEM"	
	
*** generate polinomial
gen    STEM_sub_sq=STEM_sub*STEM_sub
gen nonSTEM_sub_sq=nonSTEM_sub*nonSTEM_sub

gen    STEM_sub_cu=STEM_sub*STEM_sub*STEM_sub
gen nonSTEM_sub_cu=nonSTEM_sub*nonSTEM_sub*nonSTEM_sub

gen    STEM_sub_quad=STEM_sub*STEM_sub*STEM_sub*STEM_sub
gen nonSTEM_sub_quad=nonSTEM_sub*nonSTEM_sub*nonSTEM_sub*nonSTEM_sub

gen    STEM_sub_quin=STEM_sub*STEM_sub*STEM_sub*STEM_sub*STEM_sub
gen nonSTEM_sub_quin=nonSTEM_sub*nonSTEM_sub*nonSTEM_sub*nonSTEM_sub*nonSTEM_sub

gen STEM_sub_round=round(STEM_sub, 1)
gen nonSTEM_sub_round=round(STEM_sub, 1)

tab STEM_sub_round, gen(STEM_sub_d)
tab nonSTEM_sub_round, gen(nonSTEM_sub_d)

*** add on top abs adv and comparative advantage	
eststo clear
*** linear
eststo: reghdfe track_11_2 Female abs_adv_stem perc_rank_abs_adv c.abs_adv_stem#c.female perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
***** quadratic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem#c.female c.abs_adv_stem_2 c.abs_adv_stem_2#c.female ///
						perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub STEM_sub_sq nonSTEM_sub_sq c.STEM_sub_sq#c.female c.nonSTEM_sub_sq#c.female ///
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
**** cubic 
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem#c.female c.abs_adv_stem_2 c.abs_adv_stem_2#c.female ///
						c.abs_adv_stem_3 c.abs_adv_stem_3#c.female ///
						perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub STEM_sub_sq nonSTEM_sub_sq c.STEM_sub_sq#c.female c.nonSTEM_sub_sq#c.female ///
						STEM_sub_cu nonSTEM_sub_cu c.STEM_sub_cu#c.female c.nonSTEM_sub_cu#c.female /// 
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
*** quartic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem#c.female c.abs_adv_stem_2 c.abs_adv_stem_2#c.female ///
						c.abs_adv_stem_3 c.abs_adv_stem_3#c.female c.abs_adv_stem_4 c.abs_adv_stem_4#c.female ///
						perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub STEM_sub_sq nonSTEM_sub_sq c.STEM_sub_sq#c.female c.nonSTEM_sub_sq#c.female ///
						STEM_sub_cu nonSTEM_sub_cu c.STEM_sub_cu#c.female c.nonSTEM_sub_cu#c.female /// 
						STEM_sub_quad nonSTEM_sub_quad c.STEM_sub_quad#c.female c.nonSTEM_sub_quad#c.female /// 
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
*** quintic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem#c.female c.abs_adv_stem_2 c.abs_adv_stem_2#c.female ///
						c.abs_adv_stem_3 c.abs_adv_stem_3#c.female c.abs_adv_stem_4 c.abs_adv_stem_4#c.female ///
						c.abs_adv_stem_5 c.abs_adv_stem_5#c.female perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub STEM_sub_sq nonSTEM_sub_sq c.STEM_sub_sq#c.female c.nonSTEM_sub_sq#c.female ///
						STEM_sub_cu nonSTEM_sub_cu c.STEM_sub_cu#c.female c.nonSTEM_sub_cu#c.female /// 
						STEM_sub_quad nonSTEM_sub_quad c.STEM_sub_quad#c.female c.nonSTEM_sub_quad#c.female /// 
						STEM_sub_quin nonSTEM_sub_quin c.STEM_sub_quin#c.female c.nonSTEM_sub_quin#c.female /// 
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
****non-linear						
eststo: reghdfe track_11_2 Female i._abs_dummy_adv_stem_* i._abs_dummy_adv_stem_*#c.female ///
						perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						i.STEM_sub_d* i.STEM_sub_d*#c.female ///
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)

esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
		keep(*perc_rank_*) 	
				
esttab using Table_A6_panelA.rtf, title({STEM Track in Grade 11}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)	

*] PANEL B
eststo clear						
*** linear
eststo: reghdfe stem_application Female abs_adv_stem perc_rank_abs_adv c.abs_adv_stem#c.female perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
***** quadratic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem#c.female c.abs_adv_stem_2 c.abs_adv_stem_2#c.female ///
						perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub STEM_sub_sq nonSTEM_sub_sq c.STEM_sub_sq#c.female c.nonSTEM_sub_sq#c.female ///
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
**** cubic 
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem#c.female c.abs_adv_stem_2 c.abs_adv_stem_2#c.female ///
						c.abs_adv_stem_3 c.abs_adv_stem_3#c.female ///
						perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub STEM_sub_sq nonSTEM_sub_sq c.STEM_sub_sq#c.female c.nonSTEM_sub_sq#c.female ///
						STEM_sub_cu nonSTEM_sub_cu c.STEM_sub_cu#c.female c.nonSTEM_sub_cu#c.female /// 
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
*** quartic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem#c.female c.abs_adv_stem_2 c.abs_adv_stem_2#c.female ///
						c.abs_adv_stem_3 c.abs_adv_stem_3#c.female c.abs_adv_stem_4 c.abs_adv_stem_4#c.female ///
						perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub STEM_sub_sq nonSTEM_sub_sq c.STEM_sub_sq#c.female c.nonSTEM_sub_sq#c.female ///
						STEM_sub_cu nonSTEM_sub_cu c.STEM_sub_cu#c.female c.nonSTEM_sub_cu#c.female /// 
						STEM_sub_quad nonSTEM_sub_quad c.STEM_sub_quad#c.female c.nonSTEM_sub_quad#c.female /// 
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
*** quintic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem#c.female c.abs_adv_stem_2 c.abs_adv_stem_2#c.female ///
						c.abs_adv_stem_3 c.abs_adv_stem_3#c.female c.abs_adv_stem_4 c.abs_adv_stem_4#c.female ///
						c.abs_adv_stem_5 c.abs_adv_stem_5#c.female perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub STEM_sub_sq nonSTEM_sub_sq c.STEM_sub_sq#c.female c.nonSTEM_sub_sq#c.female ///
						STEM_sub_cu nonSTEM_sub_cu c.STEM_sub_cu#c.female c.nonSTEM_sub_cu#c.female /// 
						STEM_sub_quad nonSTEM_sub_quad c.STEM_sub_quad#c.female c.nonSTEM_sub_quad#c.female /// 
						STEM_sub_quin nonSTEM_sub_quin c.STEM_sub_quin#c.female c.nonSTEM_sub_quin#c.female /// 
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
****non-linear						
eststo: reghdfe stem_application Female i._abs_dummy_adv_stem_* i._abs_dummy_adv_stem_*#c.female ///
						perc_rank_abs_adv perc_rank_abs_adv_fema ///
						STEM_sub nonSTEM_sub c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						i.STEM_sub_d* i.STEM_sub_d*#c.female ///
						perc_rank_STEM perc_rank_nonSTEM c.perc_rank_STEM#c.female c.perc_rank_nonSTEM#c.female ///
						$studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)

esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
		keep(*perc_rank_*) 
		
esttab using Table_A6_panelB.rtf, title({Application for STEM University Degree}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)			

	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 7   #" 
	noi:di "#----------------------#"
	noi:di ""
	
egen rank_nonSTEM_sub=rank(nonSTEM_sub), by(idclass) track

egen rank_STEM_sub=rank(STEM_sub), by(idclass) track

eststo clear
*** linear
eststo: reghdfe track_11_2 Female abs_adv_stem rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv  ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quadratic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear: _abs_dummy_adv_stem_
eststo: reghdfe track_11_2 Female abs_adv_stem rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
di %8.2f r(p)
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

	
esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
		keep(*perc_rank_abs_adv*)   

esttab using Table_A7_panelA.rtf, title({STEM Track in Grade 11}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

*] PANEL B
label variable perc_rank_abs_adv_fema "\shortstack{Comparative STEM Advantage\\ $\times$ Female}"
eststo clear
*** linear
eststo: reghdfe stem_application Female abs_adv_stem rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace	
*** quadratic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear
eststo: reghdfe stem_application Female abs_adv_stem rank_STEM_sub rank_nonSTEM_sub perc_rank_abs_adv abs_adv_class_stem ///
						i._abs_dummy_adv_stem_* ///
						c.abs_adv_stem#c.female c.rank_STEM_sub#c.female c.rank_nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema 	i._abs_dummy_adv_stem_*#c.female $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
		keep(*perc_rank_abs_adv*)  
		
esttab using Table_A7_panelB.rtf, title({Application for STEM University Degree}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)	

	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 8   #" 
	noi:di "#----------------------#"
	noi:di ""
	
*] PANEL A
		eststo clear
		*** linear
		eststo: reghdfe track_11_2 Female abs_adv_stem scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv  ///
								c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
								perc_rank_abs_adv_fema $studentcovariate, ///
								absorb(schoolid##year##classid) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** quadratic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
								perc_rank_abs_adv_fema $studentcovariate ///
								c.abs_adv_stem_2#c.Female, ///
								absorb(schoolid##year##classid) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** cubic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
								scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
								perc_rank_abs_adv_fema $studentcovariate ///
								c.abs_adv_stem_2#c.Female ///
								c.abs_adv_stem_3#c.Female , ///
								absorb(schoolid##year##classid) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** quartic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
								scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
								perc_rank_abs_adv_fema $studentcovariate ///
								c.abs_adv_stem_2#c.Female ///
								c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
								absorb(schoolid##year##classid) vce(cluster idschoolcohort)
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** quintic
		eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
								scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv ///
								c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
								perc_rank_abs_adv_fema $studentcovariate ///
								c.abs_adv_stem_2#c.Female ///
								c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
								c.abs_adv_stem_5#c.Female, ///
								absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
		estadd local schoolyearFE "Yes"
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace
		*** non-linear: _abs_dummy_adv_stem_
		eststo: reghdfe track_11_2 Female abs_adv_stem scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
								c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
								perc_rank_abs_adv_fema $studentcovariate ///
								i._abs_dummy_adv_stem_*#c.female, ///
								absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
		di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
		test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
		di %8.2f r(p)
		estadd local schoolyearFE "Yes"	
		estadd local controls "Yes"
		quietly summ track_11_2
		loc mymean: di %8.2f r(mean) 	
		estadd loc mymean `mymean', replace
		loc mysd: di %8.2f r(sd) 	
		estadd loc mysd `mysd', replace
		quietly summ gg_track_11_2
		loc mygap: di %8.2f r(mean) 	
		estadd loc mygap `mygap', replace

			
		esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
				keep(*perc_rank_abs_adv*)
				
esttab using Table_A8_panelA.rtf, title({STEM Track in Grade 11}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)		

*] PANEL B
	eststo clear
	*** linear
	eststo: reghdfe stem_application Female abs_adv_stem scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
							perc_rank_abs_adv_fema $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace	
	*** quadratic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** cubic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
							scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female , ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quartic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
							scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quintic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
							scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
							c.abs_adv_stem_5#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** non-linear
	eststo: reghdfe stem_application Female abs_adv_stem scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_Ancient perc_rank_abs_adv abs_adv_class_stem ///
							i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.scr_Algebra#c.female c.scr_Physics#c.female c.scr_Chemistry#c.female c.scr_ModernGreek#c.female c.scr_GreekLiterature#c.female c.scr_Ancient#c.female ///
							perc_rank_abs_adv_fema 	i._abs_dummy_adv_stem_*#c.female $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
	estadd local schoolyearFE "Yes"	
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace

	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)  
			
esttab using Table_A8_panelB.rtf, title({Application for STEM University Degree}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 17  #" 
	noi:di "#----------------------#"
	noi:di ""
	
tab engen_tech_application stem_application
replace engen_tech_application=. if stem_application==1 & engen_tech_application==0
tab math_science_application stem_application
replace math_science_application=. if stem_application==1 & math_science_application==0

			*1] 		*************************	engeegenring and tech _application 			*************************
			label variable perc_rank_abs_adv_fema "\shortstack{Comparative STEM Advantage\\ $\times$ Female}"
			eststo clear
			*** linear
			eststo: reghdfe engen_tech_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ engen_tech_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** quadratic
			eststo: reghdfe engen_tech_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate ///
									c.abs_adv_stem_2#c.Female, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ engen_tech_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** cubic
			eststo: reghdfe engen_tech_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
									STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate ///
									c.abs_adv_stem_2#c.Female ///
									c.abs_adv_stem_3#c.Female , ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ engen_tech_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** quartic
			eststo: reghdfe engen_tech_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
									STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate ///
									c.abs_adv_stem_2#c.Female ///
									c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ engen_tech_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** quintic
			eststo: reghdfe engen_tech_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
									STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate ///
									c.abs_adv_stem_2#c.Female ///
									c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
									c.abs_adv_stem_5#c.Female, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ engen_tech_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** non-linear
			eststo: reghdfe engen_tech_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_class_stem ///
									i._abs_dummy_adv_stem_* ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema 	i._abs_dummy_adv_stem_*#c.female $studentcovariate, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
			estadd local schoolyearFE "Yes"	
			estadd local controls "Yes"
			quietly summ engen_tech_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace

			esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
					keep(*perc_rank_abs_adv*) 
					
esttab using Table_A17_panelA.rtf, title({Application for Engineering and Technology University Degree}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

			eststo clear
			*** linear
			eststo: reghdfe math_science_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ math_science_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** quadratic
			eststo: reghdfe math_science_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate ///
									c.abs_adv_stem_2#c.Female, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ math_science_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** cubic
			eststo: reghdfe math_science_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
									STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate ///
									c.abs_adv_stem_2#c.Female ///
									c.abs_adv_stem_3#c.Female , ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ math_science_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** quartic
			eststo: reghdfe math_science_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
									STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate ///
									c.abs_adv_stem_2#c.Female ///
									c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ math_science_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** quintic
			eststo: reghdfe math_science_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
									STEM_sub nonSTEM_sub perc_rank_abs_adv ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema $studentcovariate ///
									c.abs_adv_stem_2#c.Female ///
									c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
									c.abs_adv_stem_5#c.Female, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
			estadd local schoolyearFE "Yes"
			estadd local controls "Yes"
			quietly summ math_science_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace
			*** non-linear
			eststo: reghdfe math_science_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_class_stem ///
									i._abs_dummy_adv_stem_* ///
									c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
									perc_rank_abs_adv_fema 	i._abs_dummy_adv_stem_*#c.female $studentcovariate, ///
									absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
			estadd local schoolyearFE "Yes"	
			estadd local controls "Yes"
			quietly summ math_science_application
			loc mymean: di %8.2f r(mean) 	
			estadd loc mymean `mymean', replace
			loc mysd: di %8.2f r(sd) 	
			estadd loc mysd `mysd', replace

			esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
					keep(*perc_rank_abs_adv*) 
					
esttab using Table_A17_panelB.rtf, title({Application for Science and Math University Degree}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)



	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 9   #" 
	noi:di "#----------------------#"
	noi:di ""


preserve

keep if inrange(grade_level, 10, 10)

egen class_ability_median=median(gpa), by (classid) 
egen class_ability_sd=sd(gpa), by (classid) 
egen school_ability_mean=mean(gpa), by (idschoolcohort) 
egen female_class=sum(female), by (classid)
egen male_class=sum(male), by (classid)
gen prop_female_class=female_class/(female_class+male_class)
egen n_class_school=max(class_number), by( idschoolcohort)
egen class_ability_mean=mean(gpa), by (classid) 
egen female_peer_ability=mean(gpa) if female==1, by (classid) 
egen male_peer_ability=mean(gpa) if female==0, by (classid) 
egen female_peer_STEMability=mean(STEM_sub) if female==1, by (classid) 
egen male_peer_STEMability=mean(STEM_sub) if female==0, by (classid) 
egen female_peer_nonSTEMability=mean(nonSTEM_sub) if female==1, by (classid) 
egen male_peer_nonSTEMability=mean(nonSTEM_sub) if female==0, by (classid) 

gen nonSTEM_sub_f=nonSTEM_sub if female==1
egen nonSTEM_sub_f_mean=mean(nonSTEM_sub_f), by(classid)

gen nonSTEM_sub_m=nonSTEM_sub if female==0
egen nonSTEM_sub_m_mean=mean(nonSTEM_sub_m), by(classid)

gen STEM_sub_f=STEM_sub if female==1
egen STEM_sub_f_mean=mean(STEM_sub_f), by(classid)

gen STEM_sub_m=STEM_sub if female==0
egen STEM_sub_m_mean=mean(STEM_sub_m), by(classid)

egen STEM_sub_mean=mean(STEM_sub), by(classid)
egen nonSTEM_sub_mean=mean(nonSTEM_sub), by(classid)


gen ability_m=gpa if female==0
egen class_ability_mean_m=mean(ability_m), by(classid)

gen ability_f=gpa if female==0
egen class_ability_mean_f=mean(ability_f), by(classid)

egen number_classmates=count(STEM_sub), by(classid)

eststo clear
foreach y in   abs_adv_stem_class prop_female_class class_ability_mean class_ability_median  {  
	eststo: reghdfe `y' rank_abs_adv, absorb(schoolid) vce(cluster schoolid)
}


label var prop_female_class "Prop. Female"
label var abs_adv_stem_class "Class Av. Abs. STEM Advantage"
label var class_ability_mean_f "Av. GPA Female"
label var class_ability_mean_m "Av. GPA Male"
label var class_ability_mean "Class Av. GPA"
label var class_ability_median "Class Median GPA"
label var STEM_sub_f_mean "Av. STEM GPA Female"
label var STEM_sub_m_mean "Av. STEM GPA Male"
label var nonSTEM_sub_f_mean "Av. non-STEM GPA Female" 
label var nonSTEM_sub_m_mean "Av. non-STEM GPA Male"

			gen result1=.
			gen result2=.
			local vars  class_ability_mean class_ability_median prop_female_class class_ability_mean_f class_ability_mean_m STEM_sub_f_mean STEM_sub_m_mean nonSTEM_sub_f_mean nonSTEM_sub_m_mean  //STEM_sub_f_mean STEM_sub_m_mean nonSTEM_sub_f_mean nonSTEM_sub_m_mean abs_adv_stem_class 
			tempname postreg
			tempfile reg
			postfile `postreg' ///
				str100 (varname) str100( result1) using "`reg'", replace
			foreach v of local vars {
				local name: variable label `v' 
				if inlist("`v'","STEM_sub_f_mean", "STEM_sub_m_mean"){
					local contr="number_classmates"  
				}
				else{
					local contr=""
				}
				
				reghdfe `v' rank_abs_adv `contr', absorb(schoolid) 
				local beta1=trim("`: display %9.5f _b[rank_abs_adv]'")
				local se1=trim("`: display %9.5f _se[rank_abs_adv]'")
				
				local t = _b[rank_abs_adv]/_se[rank_abs_adv]
				local p =1.96*ttail(e(df_r),abs(`t'))
				
				if inrange(`p',0,0.01){
					local w="***"
				}
				if inrange(`p',0.01,0.05){
					local w="**"
				}
				if inrange(`p',0.05,0.1){
					local w="*"
				}
				if inrange(`p',0.1,2){
					local w=""
				}						
								
				post `postreg' ("`name'") ("`beta1'`w' \\ (`se1')") 
			}
			postclose `postreg'
			
			use `reg', clear
			list 
			asdoc list, replace save(Table_A9.doc)		

restore	

	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Table 7     #" 
	noi:di "#----------------#"
	noi:di ""  
	
	use student_drop_out.dta, clear

	eststo clear
	foreach y in tranferout_11 {
	eststo: reghdfe `y' Female c.abs_adv_stem#c.female c.abs_adv_stem_2#c.female ///
					c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
					c.perc_rank_abs_adv#c.female c.abs_adv_stem_class#c.female ///
					c.STEM_sub_mean_classmates#c.female ///
					c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female $studentcovariate ///
					abs_adv_stem abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_stem_class ///
					STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size, ///
					absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	loc myrs: di %8.2f e(r2_p) 	
	estadd loc mD `myrs', replace	

	}

esttab using Table_7.rtf,  replace label varwidth(30) modelwidth(20) keep (*perc_rank_abs_adv*) ///
		mtitles("Attrition at End of Grade 10") b(3) se(3) s(N schoolyearFE controls, label("Obs." "Classroom FE" "Controls") ///
		fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01) nonotes nogap nonumbers order(perc_rank_abs_adv)  ///
			prehead(`"{\rtf1\mac\deff0 {\fonttbl\f0\fnil Times New Roman;}"' `"{\info {\author .}{\company .}{\title .}{\creatim\yr2022\mo4\dy7\hr11\min21}}"' `"\deflang1033\plain\fs24"' `"{\footer\pard\qc\plain\f0\fs24\chpgn\par}"' `"\lndscpsxn\pgwsxn16840\pghsxn11901"' `"{"')

	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Table 8     #" 
	noi:di "#----------------#"
	noi:di ""
	
	use data_students_sem.dta, clear

*] PANEL A
eststo clear
*** linear
eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quadratic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear
eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ track_11_2
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_track_11_2
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

esttab using Table_8_panelA.rtf, title({STEM Track in Grade 11}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)

*] PANEL B
label variable perc_rank_abs_adv_fema "\shortstack{Comparative STEM Advantage\\ $\times$ Female}"
eststo clear
*** linear
eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quadratic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** cubic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female , ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quartic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema  $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** quintic
eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						c.abs_adv_stem_2#c.Female ///
						c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
						c.abs_adv_stem_5#c.Female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
estadd local schoolyearFE "Yes"
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace
*** non-linear
eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema $studentcovariate ///
						i._abs_dummy_adv_stem_*#c.female, ///
						absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
estadd local schoolyearFE "Yes"	
estadd local controls "Yes"
quietly summ stem_application
loc mymean: di %8.2f r(mean) 	
estadd loc mymean `mymean', replace
loc mysd: di %8.2f r(sd) 	
estadd loc mysd `mysd', replace
quietly summ gg_stem_application
loc mygap: di %8.2f r(mean) 	
estadd loc mygap `mygap', replace

esttab using Table_8_panelB.rtf, title({Application for STEM University Degree}) replace label modelwidth(6) keep(*perc_rank_abs_adv*) r2 mtitles("Linear" "Quadratic" "Cubic" "Quartic" "Quintic" "Nonlinear") b(3) se(3) s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01)
	
noi:di ""
noi:di "#================#"
noi:di "#  Main Figures  #"
noi:di "#================#"
noi:di "" 	


	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Figure 2    #" 
	noi:di "#----------------#"
	noi:di ""  
	
	preserve
	
	foreach subj in Algebra Physics Chemistry AncientGreek ModernGreek GreekLiterature{
		egen ventile_`subj'_sub=xtile(scr_`subj'), nq(20)
		egen n_male_v_`subj'=sum(male), by(ventile_`subj'_sub)
		egen n_female_v_`subj'=sum(female), by(ventile_`subj'_sub)
		gen m_f_r_`subj'=n_male_v_`subj'/n_female_v_`subj'
		tab m_f_r_`subj'
	}
	
	collapse m_f_r_Algebra m_f_r_Physics m_f_r_Chemistry m_f_r_AncientGreek m_f_r_ModernGreek m_f_r_GreekLiterature, by( ventile_Algebra_sub ventile_Physics_sub ventile_Chemistry_sub ventile_AncientGreek_sub ventile_ModernGreek_sub ventile_GreekLiterature_sub)
	gen 	ventile=ventile_Algebra_sub
	gen 	v_m_f_r_Algebra=m_f_r_Algebra if ventile_Algebra_sub==ventile
	gen 	v_m_f_r_Physics=m_f_r_Physics if ventile_Physics_sub==ventile
	gen 	v_m_f_r_Chemistry=m_f_r_Chemistry if ventile_Chemistry_sub==ventile
	gen 	v_m_f_r_AncientGreek=m_f_r_AncientGreek if ventile_AncientGreek_sub==ventile
	gen 	v_m_f_r_ModernGreek=m_f_r_ModernGreek if ventile_ModernGreek_sub==ventile
	gen 	v_m_f_r_GreekLiterature=m_f_r_GreekLiterature if ventile_GreekLiterature_sub==ventile
	foreach subj in Physics Chemistry AncientGreek ModernGreek GreekLiterature{
		drop if v_m_f_r_`subj'==.
	}
	
	
	keep ventile v_m_f_r_Algebra v_m_f_r_Physics v_m_f_r_Chemistry v_m_f_r_AncientGreek v_m_f_r_ModernGreek v_m_f_r_GreekLiterature
	
	replace ventile=0.05 if ventile==1
	replace ventile=0.10 if ventile==2
	replace ventile=0.15 if ventile==3
	replace ventile=0.20 if ventile==4
	replace ventile=0.25 if ventile==5
	replace ventile=0.30 if ventile==6
	replace ventile=0.35 if ventile==7
	replace ventile=0.40 if ventile==8
	replace ventile=0.45 if ventile==9
	replace ventile=0.50 if ventile==10
	replace ventile=0.55 if ventile==11
	replace ventile=0.60 if ventile==12
	replace ventile=0.65 if ventile==13
	replace ventile=0.70 if ventile==14
	replace ventile=0.75 if ventile==15
	replace ventile=0.80 if ventile==16
	replace ventile=0.85 if ventile==17
	replace ventile=0.90 if ventile==18
	replace ventile=0.95 if ventile==19
	replace ventile=1 if ventile==20
	
	twoway (connected v_m_f_r_Algebra ventile, sort lcolor(gs2) mcolor(gs2) msymbol(circle)) (connected v_m_f_r_Physics ventile, sort lpattern(dash) lcolor(gs2*0.6) mcolor(gs2*0.6) msymbol(diamond)) (connected v_m_f_r_Chemistry ventile, sort lpattern(longdash_dot) lcolor(gs2*0.4) mcolor(gs2*0.4) msymbol(square)) (connected v_m_f_r_AncientGreek ventile, sort lcolor(gs12*1.2) mcolor(gs12*1.2) msymbol(Oh)) (connected v_m_f_r_ModernGreek ventile, sort lpattern(dash) lcolor(gs12) mcolor(gs12) msymbol(Dh)) (connected v_m_f_r_GreekLiterature ventile, sort lpattern(longdash_dot) lcolor(gs12*0.6) mcolor(gs12*0.6) msymbol(Sh)), ///
		ytitle(Male-Female Ratio) xtitle(Score Percentile) ytick(0(0.2)1.6) xtick(0(0.05)1) ylabel(0(0.4)1.6) xlabel(0(0.1)1) legend(label(1 "Algebra") label(2 "Physics") label(3 "Chemistry") label(4 "Ancient Greek") label(5 "Modern Greek") label(6 "Greek Literature") col(2) order(1 4 3 6 2 5)) ylabel(, grid glcolor(gs15)) graphregion(color(white)) 
	graph export motivation_graph_r1_v2.pdf, as(pdf) replace	
	restore
	
	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Figure 4    #" 
	noi:di "#----------------#"
	noi:di ""  	
	
	preserve
	tab abs_adv_stem
	egen cut_abs_adv_stem=cut(abs_adv_stem), at(0 (0.3) 3.1)
	tab cut_abs_adv_stem abs_adv_stem, m

	xtile dec_abs_adv_stem=abs_adv_stem, nq(10)
	tab dec_abs_adv_stem, sum(abs_adv_stem)

	label variable dec_abs_adv_stem "Own advanatge in STEM"
	label define dec_abs_adv_stem_l 1 "0.4" 2 "0.5" 3 "0.6" 4 "0.7" 5 "0.8" 6 "0.9" 7 "1.0" 8 "" 9  "1.1" 10 "1.4"
	label values dec_abs_adv_stem dec_abs_adv_stem_l
	label variable abs_adv_stem "Absolute STEM Advantage"

	graph box perc_rank_abs_adv, over(dec_abs_adv_stem, gap(*3)) nooutsides box(1,color(gs8)) box(2,color(gs8)) box(3,color(gs8)) box(4,color(gs8)) box(5,color(gs8)) box(6,color(gs8)) box(7,color(gs8)) box(8,color(gs8)) box(9,color(gs8)) box(10,color(gs8)) asyvars showyvars leg(off) ///
		title("Absolute STEM Advantage", size(medium) position(6) span ring(1)) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	gr_edit note.text = {}
	graph export variation_rank_absolute.pdf, as(pdf) replace

	save 02_data_modified\student_level_final_decode_murphy_analysis.dta, replace

		restore	

	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Figure 5    #" 
	noi:di "#----------------#"
	noi:di ""  
	
	preserve
	twoway (histogram perc_rank_abs_adv if female==0, discrete percent fcolor(gs2%50) lcolor(gs2%50)) ///
		   (histogram perc_rank_abs_adv if female==1, discrete percent fcolor(gs12%50) lcolor(gs12%50)), ///
		   xtitle("Comparative STEM Advantage") ///
		   legend(order(1 "Male" 2 "Female")) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export Rank_desc_hist.pdf, as(pdf) replace
	restore
	
	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Figure 6    #" 
	noi:di "#----------------#"
	noi:di ""  
	
	preserve
	tab perc_rank_abs_adv, gen(perc_rank_indicator)
	gen ind_rank=.
	forvalues i=1/21{
	replace ind_rank=`i'-1 if perc_rank_indicator`i'==1
	drop perc_rank_indicator`i'
	}
	tab ind_rank, sum(perc_rank_abs_adv)
	
	**** create label
	forvalues i=1/20{
	sum perc_rank_abs_adv if ind_rank==`i'
	local sum_`i'_= r(mean)
	loc sum_`i': di %8.2f `sum_`i'_'
	}
	
	label define ind_rank_l 1 "`sum_1'" 2 "`sum_2'" 3 "`sum_3'" 4 "`sum_4'" 5 "`sum_5'" 6 "`sum_6'" ///
			7 "`sum_7'" 8 "`sum_8'" 9  "`sum_9'" 10 "`sum_10'" ///
			11 "`sum_11'" 12 "`sum_12'" 13 "`sum_13'" 14 "`sum_14'" 15 "`sum_15'" 16 "`sum_16'" ///
			17 "`sum_17'" 18 "`sum_18'" 19  "`sum_19'" 20 "`sum_20'"
			
	label values ind_rank ind_rank_l
	tab ind_rank
	
	label variable ind_rank "Comparative STEM Advantage"
	
	
	label variable perc_rank_abs_adv "Comparative STEM Advantage"
	eststo: reghdfe track_11_2 female abs_adv_stem_2 STEM_sub nonSTEM_sub ///
		c.perc_rank_abs_adv#i.ind_rank $studentcovariate if female==0, ///
		absorb(schoolid##year##classid) vce(cluster idschoolcohort)			
	quietly margins, dydx(perc_rank_abs_adv) at(ind_rank=(1(1)20))
	marginsplot, xlabel(1(1)20) recast(line) ciopt(color(gs2))  recastci(rarea) xlabel(, angle(vertical)) ///
		ytitle("Av. ME for Males with 95% CI", size(medium)) title("") ///
		yline(0, lpattern(dash) lcolor(gs8)) ylabel(-0.7(0.2)0.9) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export non_linear_rank_male.pdf, as(pdf) replace
	
	label variable ind_rank "Comparative STEM Advantage"
	eststo: reghdfe track_11_2 female abs_adv_stem_2 STEM_sub nonSTEM_sub ///
		c.perc_rank_abs_adv#i.ind_rank $studentcovariate if female==1, ///
		absorb(schoolid##year##classid) vce(cluster idschoolcohort)			
	quietly margins, dydx(perc_rank_abs_adv) at(ind_rank=(1(1)20))
	marginsplot, xlabel(1(1)20) recast(line) ciopt(color(gs12))  recastci(rarea) xlabel(, angle(vertical)) ///
		ytitle("Av. ME for Females with 95% CI", size(medium)) title("") ///
		yline(0, lpattern(dash) lcolor(gs8)) ylabel(-0.7(0.2)0.9) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export non_linear_rank_female.pdf, as(pdf) replace
	
	restore
	
	noi:di ""
	noi:di "#----------------#"
	noi:di "#    Figure 7    #" 
	noi:di "#----------------#"
	noi:di ""  

	bysort classid: egen mean_abs_adv_stem=mean(abs_adv_stem)
	bysort classid: egen min_abs_adv_stem=min(abs_adv_stem)
	bysort classid: egen max_abs_adv_stem=max(abs_adv_stem)
	
	global studentcovariate "female  i.birth"
	
	capture postutil clear
	
	
	set seed 27062017
	*Different level of measurement error
	
	foreach x in 0 5  10 15 20 25 30 35 40{
	cap postclose buffer_`x'
	postfile buffer1_`x' p_rank_noise  p_rank_noise_se reject using "sim_ME1_`x'", replace
	postfile buffer2_`x' p_rank_noise  p_rank_noise_se reject using "sim_ME2_`x'", replace
	
	*Set number of iterations
	
	forvalues i=1/1000{	
		disp "Loop `i'"
	
		*Proportion of test score SD that is random
		if `x'<10{
			gen noise= rnormal(0,0.296*0.0`x')*min(abs(abs_adv_stem-min_abs_adv_stem), abs(abs_adv_stem-max_abs_adv_stem))
	
	
		}
		else {
			gen noise= rnormal(0,0.296*0.`x')*min(abs(abs_adv_stem-min_abs_adv_stem), abs(abs_adv_stem-max_abs_adv_stem))
	
		}		
		
		cap drop noisy_perc_rank_abs_adv
		cap drop noisy_perc_rank_abs_adv_female
		
		// create noise in the absolute advantage and then create comparative advantage
		gen noisy_abs_adv_stem=abs_adv_stem+noise
		egen noisy_rank_abs_adv=rank(noisy_abs_adv_stem), by(idclass) track
		gen noisy_perc_rank_abs_adv=round((noisy_rank_abs_adv-1)/(N-1),0.05)
		gen noisy_perc_rank_abs_adv_female=noisy_perc_rank_abs_adv*female
		
		reghdfe track_11_2 noisy_perc_rank_abs_adv ///
							female abs_adv_stem STEM_sub nonSTEM_sub  ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female i._abs_dummy_adv_stem_* i._abs_dummy_adv_stem_*#c.female  ///
							noisy_perc_rank_abs_adv_female  $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
		local r=(r(p)<0.05)
		post buffer1_`x' (_b[noisy_perc_rank_abs_adv]) (_se[noisy_perc_rank_abs_adv]) (`r')
		
		local r=(r(p)<0.05)
		post buffer2_`x' (_b[noisy_perc_rank_abs_adv]+_b[noisy_perc_rank_abs_adv_female]) (_se[noisy_perc_rank_abs_adv_female]) (`r')
	
		drop noise noisy_abs_adv_stem noisy_rank_abs_adv noisy_perc_rank_abs_adv noisy_perc_rank_abs_adv_female
		
		}
		postclose buffer1_`x'
		postclose buffer2_`x'
	
	
	}
	
	
	foreach x in 0 5  10 15 20 25 30 35 40{
	use "sim_ME1_`x'",replace
	rename p_rank_noise p_rank_noise_1
	merge 1:1 _n using "sim_ME2_`x'"
	cap drop _merge
	rename p_rank_noise p_rank_noise_2
	
	di `x'
	gen error=`x'
	
	
	forval i=1/2{
		sum p_rank_noise_`i'
		egen mean_`i'=mean(p_rank_noise_`i')
		gsort p_rank_noise_`i'
		gen ob25_`i'=p_rank_noise_`i' if _n==25 //if _n==25
		gen ob975_`i'=p_rank_noise_`i' if _n==975 //if _n==975
	}
	collapse (mean) error mean_* ob25_* ob975_*
	save "ME_`x'_sum",replace
	}
	
	
	clear 
	use "ME_0_sum",replace
	
	foreach x in 5 10 15 20 25 30 35 40{ 
	append using "ME_`x'_sum"
	}
	save "ME_complete",replace
	
	twoway rcap ob25_1 ob975_1 error, lcolor(black) || scatter mean_1 error ,msymbol(D) msize(vsmall) mcolor(black) connect(l)  lcolor(black) || ///
		rcap ob25_2 ob975_2 error, lcolor(gs8) || scatter mean_2 error ,msymbol(T) msize(vsmall) mcolor(gs8) connect(l)  lcolor(gs8) ///
		xtitle("Random Noise in Comparative STEM Advantage as % of Standard Deviation") ///
		ytitle("Comparative STEM Advantage Effect")  ylabel(-0.05(0.05)0.25) yline(0, lpattern(dash) lcolor(gs12))  ///
		legend(order(2 "Males" 4 "Females (marginal to Males)")) ylabel(, grid glcolor(gs15)) graphregion(color(white)) 
	
	graph save "Graph" "measurament_error_nonlinear.gph", replace
	graph export measurament_error_nonlinear.pdf, as(pdf) replace

noi:di ""
noi:di "#===================#"
noi:di "#  Appendix Tables  #"
noi:di "#===================#"
noi:di "" 	


	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 1   #" 
	noi:di "#----------------------#"
	noi:di ""
	preserve
	use data_students.dta, clear
*1] track 11
		local vars STEM_sub nonSTEM_sub perc_rank_abs_adv STEM_sub_mean_class nonSTEM_sub_mean_class STEM_non_STEM_sub class_STEM_nonSTEM

		/* male */
		tempname postMeans_M
		tempfile means
		postfile `postMeans_M' ///
			str100 varname NoenrollMeans_M EnrollMeans_M diff_m pMeans_M using "`means'", replace
		foreach v of local vars {
			local name: variable label `v'
			ttest `v' if female==0, by(track_11_2)
			post `postMeans_M' ("`name'") (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
		}
		ttest STEM_sub if female==0, by(track_11_2)

		*post `postMeans_M' ("Obs.") (r(N_1)) (r(N_2)) 
		postclose `postMeans_M'

		/* female */
		tempname postMeans_F
		tempfile medians
		postfile `postMeans_F' ///
			NoenrollMeans_F EnrollMeans_F diff_F pMeans_F using `medians', replace
		foreach v of local vars {
		   local name: variable label `v'
		   ttest `v' if female==1, by(track_11_2)
		   post `postMeans_F' (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
		}
		ttest STEM_sub if female==0, by(track_11_2)
		*post `postMeans_F' (r(N_1)) (r(N_2)) 
		postclose `postMeans_F'

		/* combine */
		use `means', clear
		merge 1:1 _n using `medians', nogenerate
		format *Means* *diff* pMeans_* %9.3f 
		list 
		
		asdoc list, replace save(Table_A1_PanA.doc)
		
		restore
		
	*] PANEL B
		preserve
		use data_students.dta, clear
		local vars STEM_sub nonSTEM_sub perc_rank_abs_adv STEM_sub_mean_class nonSTEM_sub_mean_class STEM_non_STEM_sub class_STEM_nonSTEM

		/* male */
		tempname postMeans_M
		tempfile means
		postfile `postMeans_M' ///
			str100 varname NoenrollMeans_M EnrollMeans_M diff_m pMeans_M using "`means'", replace
		foreach v of local vars {
			local name: variable label `v'
			ttest `v' if female==0, by(stem_application)
			post `postMeans_M' ("`name'") (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
		}
		postclose `postMeans_M'

		/* female */
		tempname postMeans_F
		tempfile medians
		postfile `postMeans_F' ///
			NoenrollMeans_F EnrollMeans_F diff_F pMeans_F using `medians', replace
		foreach v of local vars {
		   local name: variable label `v'
		   ttest `v' if female==1, by(stem_application)
		   post `postMeans_F' (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
		}
		postclose `postMeans_F'

		/* combine */
		use `means', clear
		merge 1:1 _n using `medians', nogenerate
		format *Means* *diff* pMeans_* %9.3f
		list

		asdoc list, replace save(Table_A1_PanB.doc)		
		restore


	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 9   #" 
	noi:di "#----------------------#"
	noi:di ""
	
	
	
	preserve
	
	keep if inrange(grade_level, 10, 10)
	
	egen class_ability_median=median(gpa), by (classid) 
	egen class_ability_sd=sd(gpa), by (classid) 
	egen school_ability_mean=mean(gpa), by (idschoolcohort) 
	egen female_class=sum(female), by (classid)
	egen male_class=sum(male), by (classid)
	gen prop_female_class=female_class/(female_class+male_class)
	egen n_class_school=max(class_number), by( idschoolcohort)
	egen class_ability_mean=mean(gpa), by (classid) 
	egen female_peer_ability=mean(gpa) if female==1, by (classid) 
	egen male_peer_ability=mean(gpa) if female==0, by (classid) 
	egen female_peer_STEMability=mean(STEM_sub) if female==1, by (classid) 
	egen male_peer_STEMability=mean(STEM_sub) if female==0, by (classid) 
	egen female_peer_nonSTEMability=mean(nonSTEM_sub) if female==1, by (classid) 
	egen male_peer_nonSTEMability=mean(nonSTEM_sub) if female==0, by (classid) 
	
	gen nonSTEM_sub_f=nonSTEM_sub if female==1
	egen nonSTEM_sub_f_mean=mean(nonSTEM_sub_f), by(classid)
	
	gen nonSTEM_sub_m=nonSTEM_sub if female==0
	egen nonSTEM_sub_m_mean=mean(nonSTEM_sub_m), by(classid)
	
	gen STEM_sub_f=STEM_sub if female==1
	egen STEM_sub_f_mean=mean(STEM_sub_f), by(classid)
	
	gen STEM_sub_m=STEM_sub if female==0
	egen STEM_sub_m_mean=mean(STEM_sub_m), by(classid)
	
	egen STEM_sub_mean=mean(STEM_sub), by(classid)
	egen nonSTEM_sub_mean=mean(nonSTEM_sub), by(classid)
	
	
	gen ability_m=gpa if female==0
	egen class_ability_mean_m=mean(ability_m), by(classid)
	
	gen ability_f=gpa if female==0
	egen class_ability_mean_f=mean(ability_f), by(classid)
	
	egen number_classmates=count(STEM_sub), by(classid)
	
	
	eststo clear
	foreach y in   abs_adv_stem_class prop_female_class class_ability_mean class_ability_median  {  
		eststo: reghdfe `y' rank_abs_adv, absorb(schoolid) vce(cluster schoolid)
	}
	
	
	label var prop_female_class "Prop. Female"
	label var abs_adv_stem_class "Class Av. Abs. STEM Advantage"
	label var class_ability_mean_f "Av. GPA Female"
	label var class_ability_mean_m "Av. GPA Male"
	label var class_ability_mean "Class Av. GPA"
	label var class_ability_median "Class Median GPA"
	label var STEM_sub_f_mean "Av. STEM GPA Female"
	label var STEM_sub_m_mean "Av. STEM GPA Male"
	label var nonSTEM_sub_f_mean "Av. non-STEM GPA Female" 
	label var nonSTEM_sub_m_mean "Av. non-STEM GPA Male"

	gen result1=.
	gen result2=.
	local vars  class_ability_mean class_ability_median prop_female_class class_ability_mean_f class_ability_mean_m STEM_sub_f_mean STEM_sub_m_mean nonSTEM_sub_f_mean nonSTEM_sub_m_mean  
	tempname postreg
	tempfile reg
	postfile `postreg' ///
		str100 (varname) str100( result1) using "`reg'", replace
	foreach v of local vars {
		local name: variable label `v' 
		
		if inlist("`v'","STEM_sub_f_mean", "STEM_sub_m_mean"){
			local contr="number_classmates"  //We need to control for class size when STEM variables are considered because of the mechanics of the construction of rank in STEM advantage
		}
		else{
			local contr=""
		}
		
		reghdfe `v' rank_abs_adv `contr', absorb(schoolid) 
		local beta1=trim("`: display %9.5f _b[rank_abs_adv]'")
		local se1=trim("`: display %9.5f _se[rank_abs_adv]'")
		
		local t = _b[rank_abs_adv]/_se[rank_abs_adv]
		local p =1.96*ttail(e(df_r),abs(`t'))
		
		if inrange(`p',0,0.01){
			local w="***"
		}
		if inrange(`p',0.01,0.05){
			local w="**"
		}
		if inrange(`p',0.05,0.1){
			local w="*"
		}
		if inrange(`p',0.1,2){
			local w=""
		}						
		
		
		post `postreg' ("\shortstack{`name' \\ {}}") ("\shortstack{`beta1'`w' \\ (`se1')}") //("\shortstack{`beta2' \\ `se2'}")
	}
	postclose `postreg'
	
	use `reg', clear
	list 
	
	listtab * using balancing_round2_r2_comment2.tex,  rstyle(tabular) replace 	
	
	restore
 	
	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 10  #" 
	noi:di "#----------------------#"
	noi:di ""
	
	preserve
	
	gen 	gpa_raw_eng=""
	replace gpa_raw_eng="low performance" if strpos(gpa_raw, "ΒΑΘΜΟΛΟΓΙΑΣ")
	replace gpa_raw_eng="many absences" if strpos(gpa_raw, "ΑΠΟΥΣΙΩΝ")

	gen 	drop_out=0
	replace drop_out=1 if gpa_raw_eng=="low performance" | gpa_raw_eng=="many absences" 
	
	gen 	dropout_11=.
	replace dropout_11=1 if drop_out==1 & grade_level==11
	replace dropout_11=0 if drop_out==0 & grade_level==11
	
	by studentid, sort: egen in_11 = max(grade_level == 11)
	
	gen 	tranferout_11=1 if in_11==0
	replace tranferout_11=0 if in_11==1
	
	local vars "dropout_11  tranferout_11"
	label variable dropout_11 "Early leavers"
	label variable tranferout_11 "Students' attrition"

	tempname postMeans
	tempfile means
	postfile `postMeans' ///
		str100 varname maleMeans femaleMeans diffMeans pMeans using "`means'", replace
	foreach v of local vars {
		local name: variable label `v'
		ttest `v', by(female)
		post `postMeans' ("`name'") (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
	}
	postclose `postMeans'
	
	use `means', clear
	format *Means %9.3f
	list
	
	listtab * using summ_stat_attrition.tex, rstyle(tabular) replace // ///
	restore
 	
	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 11  #" 
	noi:di "#----------------------#"
	noi:di ""
	
	preserve
	
	gen 	male=.
	replace male=1 if female==0
	replace male=0 if female==1
	
	egen class_av_gpa=mean(gpa), by(schoolid class year grade)
	egen class_av_gpa_f=mean(gpa*female), by(schoolid class year grade)
	egen class_av_gpa_m=mean(gpa*male), by(schoolid class year grade)
	**
	egen class_av_drop_11=mean(dropout_11), by(schoolid class year grade)
	egen class_av_drop_11_f=mean(dropout_11*female), by(schoolid class year grade)
	egen class_av_drop_11_m=mean(dropout_11*male), by(schoolid class year grade)
	***
	egen class_av_drop_12=mean(dropout_12), by(schoolid class year grade)
	egen class_av_drop_12_f=mean(dropout_12*female), by(schoolid class year grade)
	egen class_av_drop_12_m=mean(dropout_12*male), by(schoolid class year grade)
	***
	egen class_av_tranferout_11=mean(tranferout_11), by(schoolid class year grade)
	egen class_av_tranferout_11_f=mean(tranferout_11*female), by(schoolid class year grade)
	egen class_av_tranferout_11_m=mean(tranferout_11*male), by(schoolid class year grade)
	***
	egen class_av_tranferout_12=mean(tranferout_12), by(schoolid class year grade)
	egen class_av_tranferout_12_f=mean(tranferout_12*female), by(schoolid class year grade)
	egen class_av_tranferout_12_m=mean(tranferout_12*male), by(schoolid class year grade)
	
	****
	egen class_av_STEM_sub=mean(STEM_sub), by(schoolid class year grade)
	egen class_av_STEM_sub_f=mean(STEM_sub*female), by(schoolid class year grade)
	egen class_av_STEM_sub_m=mean(STEM_sub*male), by(schoolid class year grade)
	
	egen class_av_nonSTEM_sub=mean(nonSTEM_sub), by(schoolid class year grade)
	egen class_av_nonSTEM_sub_f=mean(nonSTEM_sub*female), by(schoolid class year grade)
	egen class_av_nonSTEM_sub_m=mean(nonSTEM_sub*male), by(schoolid class year grade)
	
	codebook class_av_drop_11 class_av_drop_11_f class_av_drop_11_m class_av_drop_12 ///
		class_av_drop_12_f class_av_drop_12_m class_av_tranferout_11 class_av_tranferout_11_f ///
		class_av_tranferout_11_m class_av_tranferout_12 class_av_tranferout_12_f class_av_tranferout_12_m
	
	collapse female class_av_gpa class_av_gpa_f class_av_gpa_m class_av_drop_11 class_av_drop_11_f ///
		class_av_drop_11_m class_av_drop_12 class_av_drop_12_f class_av_drop_12_m class_av_tranferout_11 ///
		class_av_tranferout_11_f class_av_tranferout_11_m class_av_tranferout_12 class_av_tranferout_12_f ///
		class_av_tranferout_12_m class_av_STEM_sub class_av_STEM_sub_f class_av_STEM_sub_m ///
		class_av_nonSTEM_sub class_av_nonSTEM_sub_f class_av_nonSTEM_sub_m, by(schoolid class year grade)
		
	merge 1:1 schoolid class year grade using final_sample_class.dta
	keep if _merge==3
	
	foreach var in class_av_gpa class_av_drop_11 class_av_tranferout_11 class_av_tranferout_12{
	gen gg_`var'=(`var'_m-`var'_f)*100
	}
	
	drop if class_av_tranferout_12==.
	
	eststo clear
	foreach var in class_av_drop_11 class_av_tranferout_11 { {
		eststo: reghdfe gg_`var' class_av_gpa female, absorb( idschoolcohort) vce(cluster schoolid)
	
		estadd local schoolyearFE "Yes"
	}
	
	noisily: esttab , label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01)  //just print results on screen
	
	local titles "& GD Early Leavers & GD Students' Attrition \\ \cmidrule(lr){2-2} \cmidrule(lr){3-3}  "
	local numbers "& (1) & (2) \\ \hline"				
	esttab using 05_tables/drop_rate_2.tex,  nomtitles ///
		varlabels(class_av_gpa "Classroom GPA")  ///
		drop (female ) nonumber 	mlabels(none) nonumbers posthead("`titles'" "`numbers'") ///
		replace b(3) se(3) label s(N schoolyearFE, ///
		label("Obs." "School $\times$ Year FE") fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01) nonotes 
	
	restore
 	
	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 12  #" 
	noi:di "#----------------------#"
	noi:di ""
	
	preserve
	
	set more off
	eststo clear
	foreach y in tranferout_11{
	xi: probit `y' Female c.abs_adv_stem#c.female c.abs_adv_stem_2#c.female ///
					c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
					c.perc_rank_abs_adv#c.female c.abs_adv_stem_class#c.female ///
					c.STEM_sub_mean_classmates#c.female ///
					c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female $studentcovariate ///
					abs_adv_stem abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_stem_class ///
					STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size, robust cluster(idschoolcohort) //i.SchoolyearFE
	eststo `y'_pro
	estadd local schoolyearFE "-"
	estadd local controls "Yes"
	loc myrs: di %8.2f e(r2_p) 	
	estadd loc mD `myrs', replace
	}
	esttab tranferout_11_pro, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) 	
	esttab tranferout_11_pro using 05_tables\attritionprobit_1.tex,  ///
		replace label b(3) se(3) drop (_cons Female STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size ///
		c.abs_adv_stem_class#c.female c.STEM_sub_mean_classmates#c.female c.class_size#c.female ///
		c.nonSTEM_sub_mean_classmates#c.female abs_adv_stem_class c.perc_rank_abs_adv#c.female ///
		perc_rank_abs_adv) ///
		nonumber s(N  schoolyearFE controls, label("Obs." "School x Year FE" "Controls" ) ///
		fmt(%9.3gc)) star(* 0.10 ** 0.05 *** 0.01) nonotes ///
		mgroups("Transfer out Grade 11", pattern(1) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		nomtitle order (Female abs_adv_stem abs_adv_stem_2 STEM_sub nonSTEM_sub c.abs_adv_stem#c.female ///
		c.abs_adv_stem_2#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female )
	
	* Variables that are significant predictors of attrition are female, the interaction between Non-STEM ///
	* average performance and female, absolute advantage in STEM and the square of absolute advantage in STEM, ///
	* own performance in STEM and non STEM subjects, and average class performance in STEM and non STEM subjects. 
	
	*2]Using the Stata test command we perform a Wald test of whether these groups variables are
	*  jointly equal to zero using the command:
	test Female c.nonSTEM_sub#c.female abs_adv_stem abs_adv_stem_2 STEM_sub nonSTEM_sub ///
		STEM_sub_mean_classmates nonSTEM_sub_mean_classmates
	
	* the test concludes that model is nonrandom, we proceed to calculate inverse probability weights for this model. 
	*3]To do this we first calculate the predicted probabilities from the unrestricted attrition probit in [1], and
	*then re-estimate it excluding seven groups of auxiliary variables, 
	* After calculating the predicted probabilities from the restricted attrition probit, 
	*the inverse probability weights are calculated straightforwardly by taking the
	*ratio of the restricted to unrestricted probabilities.
	
	xi: probit tranferout_11 Female c.abs_adv_stem#c.female c.abs_adv_stem_2#c.female ///
					c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
					c.perc_rank_abs_adv#c.female c.abs_adv_stem_class#c.female ///
					c.STEM_sub_mean_classmates#c.female ///
					c.nonSTEM_sub_mean_classmates#c.female c.class_size#c.female $studentcovariate ///
					abs_adv_stem abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_stem_class ///
					STEM_sub_mean_classmates nonSTEM_sub_mean_classmates class_size  schoolid year, ///
					robust cluster(idschoolcohort) //i.SchoolyearFE
	gen sample=e(sample)
	predict pxav
	*xi: probit tranferout_11 class_size  schoolid year if sample==1, robust cluster(idschoolcohort)
	xi: probit tranferout_11 c.abs_adv_stem#c.female c.abs_adv_stem_2#c.female ///
				c.STEM_sub#c.female class_size c.perc_rank_abs_adv#c.female c.abs_adv_stem_class#c.female ///
				c.STEM_sub_mean_classmates#c.female c.nonSTEM_sub_mean_classmates#c.female ///
				c.class_size#c.female $studentcovariate schoolid year if sample==1, robust cluster(idschoolcohort) 
	predict pxres
	gen attwght=pxres/pxav
	hist attwght
	codebook attwght // The inverse probability (or attrition) weights produced vary from .03529375,19.348248
	
	*rename  _abs_adv_stem_* _abs_dummy_adv_stem_*
	
		*===========================================================================
		*			MURPHY MODEL WITH AND WITHOUT ATTRITION RATE
		*===========================================================================
	tab tranferout_11 track_11_2, m
	tab track_11_2
	
	preserve
	eststo clear
	use 02_data_modified\student_level_final_decode_wage_2.dta, clear
	eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ track_11_2
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	***
	eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							i._abs_dummy_adv_stem_*#c.female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ track_11_2
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	********************************************************************************
	*with inverse probability weights
	***
	eststo: reghdfe track_11_2 Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							c.abs_adv_stem_2#c.Female [pw=attwght], ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ track_11_2
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	***
	eststo: reghdfe track_11_2 Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							i._abs_dummy_adv_stem_*#c.female [pw=attwght], ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ track_11_2
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	********************************************************************************
	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)     //drop(_cons *.schoolid *.year _abs_adv_stem_*) label b(3) se(3) ///
	
			
			
	local titles " & Quadratic  & Non Linear & Quadratic  & Non Linear \\ \cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5}"
	local numbers "& (1) & (2) & (3) & (4) \\ \hline"						
	esttab using model_murphy_weight.tex, ///
		replace keep(*perc_rank_abs_adv*) label b(3) se(3) ///
		nonumber s(N schoolyearFE controls mymean mysd, ///
		label("Obs." "School x Year FE" "Controls" "Mean Y" "St. Dev Y" ) ///
		fmt(%12.0gc)) star(* 0.10 ** 0.05 *** 0.01) nonotes ///
		mgroups("\shortstack{Without Attrition\\Weights}" "\shortstack{With Attrition\\Weights}" ///
		, pattern(1 0 1 0 ) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mlabels(none) nonumbers posthead("`titles'" "`numbers'") order(perc_rank_abs_adv)
	
	restore
	
	
	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 13  #" 
	noi:di "#----------------------#"
	noi:di ""
	
	*Panel A
	local vars  scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_AncientGreek 
	***** PANEL A: performance grade 10
	label variable scr_Algebra "Algebra "
	label variable scr_Physics "Physics "
	label variable scr_Chemistry "Chemistry "
	label variable scr_ModernGreek "Modern Greek "
	label variable scr_GreekLiterature "Greek Literature "
	label variable scr_AncientGreek "Ancient Greek "
	
	preserve
	/* means */
	tempname postMeans
	tempfile means
	postfile `postMeans' ///
		str100 varname maleMeans femaleMeans diffMeans pMeans using "`means'", replace
	foreach v of local vars {
		local name: variable label `v'
		ttest `v', by(female)
		post `postMeans' ("`name'") (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
	}
	postclose `postMeans'
	
	use `means', clear
	format *Means %9.3f
	list
	
	/* make latex table */
	listtab * using 05_tables\summ_stat_PanA_semA.tex, rstyle(tabular) replace 
	
	restore
	
	*Panel B
	
	replace stem_admitted=. if stem_application==.
	tab stem_application stem_admitted, m
	
	la variable  stem_application "Applied for a STEM departments"
	la variable  stem_admitted "Admitted to a STEM departments"
	
	local vars STEM_sub nonSTEM_sub STEM_sub_mean_class nonSTEM_sub_mean_class  perc_rank_abs_adv  // STEM_non_STEM_sub //class_STEM_nonSTEM
	
	preserve
	label variable STEM_sub "Own Grade in STEM"
	label variable nonSTEM_sub "Own Grade in non-STEM"
	label variable STEM_non_STEM_sub "Student Abs. STEM Adv"
	label variable STEM_sub_mean_class "Class Average Grade in STEM"
	label variable nonSTEM_sub_mean_class "Class Average Grade in non-STEM"
	label variable perc_rank_abs_adv "Comparative STEM Advantage"

	/* means */
	tempname postMeans
	tempfile means
	postfile `postMeans' ///
		str100 varname maleMeans femaleMeans diffMeans pMeans using "`means'", replace
	foreach v of local vars {
		local name: variable label `v'
		ttest `v', by(female)
		post `postMeans' ("`name'") (r(mu_1)) (r(mu_2)) (r(mu_2)-r(mu_1)) (r(p))
	}
	postclose `postMeans'
	
	use `means', clear
	format *Means %9.3f
	list
	
	/* make latex table */
	listtab * using 05_tables\summ_stat_PanB_semA.tex,  ///
		rstyle(tabular) replace //

	restore
 	
	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 14  #" 
	noi:di "#----------------------#"
	noi:di ""
	
	preserve
	
	*************************       STEMecon  **************************************
	eststo clear
	*** linear
	eststo: reghdfe STEMecon_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv  ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMecon_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMecon_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quadratic
	eststo: reghdfe STEMecon_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMecon_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMecon_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** cubic
	eststo: reghdfe STEMecon_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female , ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMecon_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMecon_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quartic
	eststo: reghdfe STEMecon_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMecon_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMecon_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quintic
	eststo: reghdfe STEMecon_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
							c.abs_adv_stem_5#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMecon_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMecon_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** non-linear: _abs_dummy_adv_stem_
	eststo: reghdfe STEMecon_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							i._abs_dummy_adv_stem_*#c.female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
	test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
	di %8.2f r(p)
	estadd local schoolyearFE "Yes"	
	estadd local controls "Yes"
	quietly summ STEMecon_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMecon_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	
		
	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)    
		
	esttab using model_murphy_functional_STEMecon.tex, replace fragment keep(*perc_rank_abs_adv*) ///
		label b(3) se(3) nonumber star(* 0.10 ** 0.05 *** 0.01) nonotes ///
		s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
		"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) ///
		order (*abs_adv_stem*) ///
		mgroups("\textbf{\textit{\shortstack{STEM departments = Sciences, Engineering,\\ Technology, Economics and Business}}}", pattern(1 0 0 0 0 0 ) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles
	
	**********************            STEMhealth
	eststo clear
	*** linear
	eststo: reghdfe STEMhealth_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv  ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMhealth_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMhealth_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quadratic
	eststo: reghdfe STEMhealth_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMhealth_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMhealth_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** cubic
	eststo: reghdfe STEMhealth_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female , ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMhealth_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMhealth_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quartic
	eststo: reghdfe STEMhealth_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMhealth_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMhealth_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quintic
	eststo: reghdfe STEMhealth_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
							c.abs_adv_stem_5#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ STEMhealth_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMhealth_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** non-linear: _abs_dummy_adv_stem_
	eststo: reghdfe STEMhealth_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate ///
							i._abs_dummy_adv_stem_*#c.female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
	test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
	di %8.2f r(p)
	estadd local schoolyearFE "Yes"	
	estadd local controls "Yes"
	quietly summ STEMhealth_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_STEMhealth_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	
		
	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)    
		
	esttab using model_murphy_functional_STEMhealth.tex, replace fragment keep(*perc_rank_abs_adv*) ///
		label b(3) se(3) nonumber star(* 0.10 ** 0.05 *** 0.01) nonotes ///
		s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
		"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) ///
		order (*abs_adv_stem*) ///
		mgroups("\textbf{\textit{\shortstack{STEM departments = Sciences, Engineering, \\Technology and Health Science}}}", pattern(1 0 0 0 0 0 ) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles
	
	
	restore
 	
	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 15  #" 
	noi:di "#----------------------#"
	noi:di ""
	
`	preserve

	label variable perc_rank_abs_adv_fema "\shortstack{Comparative STEM Advantage\\ $\times$ Female}"

	gen track_11_2_sc=track_11_triple==2

	eststo clear
	*** linear
	eststo: reghdfe track_11_2_sc Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv  ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema  $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ track_11_2_sc
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** quadratic
	eststo: reghdfe track_11_2_sc Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ track_11_2_sc
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** cubic
	eststo: reghdfe track_11_2_sc Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female , ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ track_11_2_sc
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** quartic
	eststo: reghdfe track_11_2_sc Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ track_11_2_sc
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** quintic
	eststo: reghdfe track_11_2_sc Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
							c.abs_adv_stem_5#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ track_11_2_sc
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** non-linear: _abs_dummy_adv_stem_
	eststo: reghdfe track_11_2_sc Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							i._abs_dummy_adv_stem_*#c.female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
	test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
	di %8.2f r(p)
	estadd local schoolyearFE "Yes"	
	estadd local controls "Yes"
	quietly summ track_11_2_sc
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
		
	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)    
		
	esttab using model_murphy_functional_track_11_2_onlyscience.tex, replace fragment keep(*perc_rank_abs_adv*) ///
		label b(3) se(3) nonumber star(* 0.10 ** 0.05 *** 0.01) nonotes ///
		s(N mymean mysd , label("Obs." "Mean of Y" ///
		"St. Dev. Y") fmt(%12.0gc)) ///
		order (*abs_adv_stem*) ///
		mgroups("\textbf{\textit{STEM Track in Grade 11}}", pattern(1 0 0 0 0 0 ) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles
 	
	restore
	
	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 16   #" 
	noi:di "#----------------------#"
	noi:di ""
	
	preserve

	tab engen_tech_application stem_application
	replace engen_tech_application=. if stem_application==1 & engen_tech_application==0
	tab math_science_application stem_application
	replace math_science_application=. if stem_application==1 & math_science_application==0

	*1] 		*************************	engeegenring and tech _application 			*************************
	label variable perc_rank_abs_adv_fema "\shortstack{Comparative STEM Advantage\\ $\times$ Female}"
	eststo clear
	*** linear
	eststo: reghdfe engen_tech_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ engen_tech_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** quadratic
	eststo: reghdfe engen_tech_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ engen_tech_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** cubic
	eststo: reghdfe engen_tech_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female , ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ engen_tech_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** quartic
	eststo: reghdfe engen_tech_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ engen_tech_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** quintic
	eststo: reghdfe engen_tech_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
							c.abs_adv_stem_5#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ engen_tech_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** non-linear
	eststo: reghdfe engen_tech_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_class_stem ///
							i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema 	i._abs_dummy_adv_stem_*#c.female $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
	estadd local schoolyearFE "Yes"	
	estadd local controls "Yes"
	quietly summ engen_tech_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace

	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)  
		
	esttab using model_murphy_functional_engen_tech_application.tex, replace fragment keep(*perc_rank_abs_adv*) ///
		label b(3) se(3) nonumber star(* 0.10 ** 0.05 *** 0.01) nonotes ///
		s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
		"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) ///
		order (*abs_adv_stem*) ///
		mgroups("\textbf{\textit{Application for Engineering and Technology University Degree}}", pattern(1 0 0 0 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles

*1] *************************	math_science_application _application 			*************************
	eststo clear
	*** linear
	eststo: reghdfe math_science_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ math_science_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** quadratic
	eststo: reghdfe math_science_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ math_science_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** cubic
	eststo: reghdfe math_science_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female , ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ math_science_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** quartic
	eststo: reghdfe math_science_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ math_science_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** quintic
	eststo: reghdfe math_science_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema $studentcovariate ///
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
							c.abs_adv_stem_5#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ math_science_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	*** non-linear
	eststo: reghdfe math_science_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv abs_adv_class_stem ///
							i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema 	i._abs_dummy_adv_stem_*#c.female $studentcovariate, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)		
	estadd local schoolyearFE "Yes"	
	estadd local controls "Yes"
	quietly summ math_science_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace

	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)  
		
	esttab using model_murphy_functional_math_science_application.tex, replace fragment keep(*perc_rank_abs_adv*) ///
		label b(3) se(3) nonumber star(* 0.10 ** 0.05 *** 0.01) nonotes ///
		s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
		"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) ///
		order (*abs_adv_stem*) ///
		mgroups("\textbf{\textit{Application for Science and Math University Degree}}", pattern(1 0 0 0 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles
				
	restore

	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 18   #" 
	noi:di "#----------------------#"
	noi:di ""	
	
	noi:di ""
	noi:di "#------------------------------#"
	noi:di "#   Appendix Table 19 Panel B  #" 
	noi:di "#------------------------------#"
	noi:di ""
	
	preserve
	label variable perc_rank_abs_adv_fema "\shortstack{Comparative STEM Advantage\\ $\times$ Female}"
	eststo clear
	*** linear
	eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv  ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema total_choices $studentcovariate, ///  //added total_choices ΣΓ Jan 2, 2022
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	estadd loc N "45,259", replace
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quadratic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema total_choices $studentcovariate ///  //added total_choices ΣΓ Jan 2, 2022
							c.abs_adv_stem_2#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	estadd loc N "45,259", replace
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** cubic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema total_choices  $studentcovariate ///  //added total_choices ΣΓ Jan 2, 2022
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female , ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	estadd loc N "45,259", replace
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quartic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 ///
							STEM_sub nonSTEM_sub perc_rank_abs_adv ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema total_choices $studentcovariate ///  //added total_choices ΣΓ Jan 2, 2022
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	estadd loc N "45,259", replace
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** quintic
	eststo: reghdfe stem_application Female abs_adv_stem c.abs_adv_stem_2 abs_adv_stem_3 abs_adv_stem_4 abs_adv_stem_5 ///
						STEM_sub nonSTEM_sub perc_rank_abs_adv ///
						c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
						perc_rank_abs_adv_fema total_choices $studentcovariate ///  //added total_choices ΣΓ Jan 2, 2022
							c.abs_adv_stem_2#c.Female ///
							c.abs_adv_stem_3#c.Female c.abs_adv_stem_4#c.Female ///
							c.abs_adv_stem_5#c.Female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	estadd local schoolyearFE "Yes"
	estadd local controls "Yes"
	quietly summ stem_application
	estadd loc N "45,259" , replace
	loc mymean: di %8.2f r(mean) 	
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	*** non-linear: _abs_dummy_adv_stem_
	eststo: reghdfe stem_application Female abs_adv_stem STEM_sub nonSTEM_sub perc_rank_abs_adv i._abs_dummy_adv_stem_* ///
							c.abs_adv_stem#c.female c.STEM_sub#c.female c.nonSTEM_sub#c.female ///
							perc_rank_abs_adv_fema total_choices  $studentcovariate ///   //added total_choices ΣΓ Jan 2, 2022
							i._abs_dummy_adv_stem_*#c.female, ///
							absorb(schoolid##year##classid) vce(cluster idschoolcohort)	
	di %8.2f _b[perc_rank_abs_adv]+_b[perc_rank_abs_adv_fema]
	test perc_rank_abs_adv+perc_rank_abs_adv_fema=0
	di %8.2f r(p)
	estadd local schoolyearFE "Yes"	
	estadd local controls "Yes"
	quietly summ stem_application
	loc mymean: di %8.2f r(mean) 	
	estadd loc N "45,259" , replace
	estadd loc mymean `mymean', replace
	loc mysd: di %8.2f r(sd) 	
	estadd loc mysd `mysd', replace
	quietly summ gg_stem_application
	loc mygap: di %8.2f r(mean) 	
	estadd loc mygap `mygap', replace
	
		
	esttab, varwidth(35) label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			keep(*perc_rank_abs_adv*)    
		
	esttab using model_murphy_functional_STEM_control_for_listed.tex, replace fragment keep(*perc_rank_abs_adv*) ///
	label b(3) se(3) nonumber star(* 0.10 ** 0.05 *** 0.01) nonotes ///
	s(N mymean mysd mygap , label("Obs." "Mean of Y" ///
	"St. Dev. Y" "Raw Gender Gap Y") fmt(%12.0gc)) ///
	order (*abs_adv_stem*) ///
	mgroups("\textbf{\textit{\shortstack{Application for STEM University Degree\\ controlling for the Number of University Degree Applications}}}", pattern(1 0 0 0 0 0 ) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles

 	restore
	
	noi:di ""
	noi:di "#----------------------#"
	noi:di "#   Appendix Table 20  #" 
	noi:di "#----------------------#"
	noi:di ""	
	
noi:di ""
noi:di "#====================#"
noi:di "#  Appendix Figures  #"
noi:di "#====================#"
noi:di "" 	


	noi:di ""
	noi:di "#--------------------#"
	noi:di "# Appendix Figure 1  #" 
	noi:di "#--------------------#"
	noi:di ""  
	
	**** hist of STEM 
	twoway (histogram STEM_sub if female==0, percent fcolor(gs2%50) lcolor(gs2%50)) ///
		   (histogram STEM_sub if female==1, percent fcolor(gs12%50) lcolor(gs12%50) ), ///
		   xtitle("Average Performance in STEM Subjects") ///
		   legend(order(1 "Male" 2 "Female")) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export dist_STEM_sub.pdf, as(pdf) replace 

	**** hist of non-STEM 
	twoway (histogram nonSTEM_sub if female==0, percent fcolor(gs2%50) lcolor(gs2%50)) ///
		   (histogram nonSTEM_sub if female==1, percent fcolor(gs12%50) lcolor(gs12%50)), ///
		   xtitle("Average Performance in Non-STEM Subjects") ///
		   legend(order(1 "Male" 2 "Female")) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export dist_nonSTEM_sub.pdf, as(pdf) replace 
	
	noi:di ""
	noi:di "#--------------------#"
	noi:di "# Appendix Figure 2  #" 
	noi:di "#--------------------#"
	noi:di "" 
	
	sum abs_adv_stem, detail
	local min_abs_adv_stem=`r(p1)'
	local max_abs_adv_stem=`r(p99)'
	twoway (histogram abs_adv_stem if female==0 & inrange(abs_adv_stem, `min_abs_adv_stem', `max_abs_adv_stem'), ///
			discrete percent fcolor(gs2%50) lcolor(bgs2%50)) ///
		   (histogram abs_adv_stem if female==1 & inrange(abs_adv_stem, `min_abs_adv_stem', `max_abs_adv_stem'), ///
		   discrete percent fcolor(gs12%50) lcolor(gs12%50)), ///
		   xtitle("Absolute STEM Advantage") ///
		   legend(order(1 "Male" 2 "Female")) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export 04_graphs\dist_STEM_adv.pdf, as(pdf) replace 
	
	noi:di ""
	noi:di "#--------------------#"
	noi:di "# Appendix Figure 3  #" 
	noi:di "#--------------------#"
	noi:di ""  
	
	xtile abil_nonSTEM_q = nonSTEM_sub, nq(5)
	tabulate abil_nonSTEM_q, sum(nonSTEM_sub)
	
	xtile abil_STEM_q = STEM_sub, nq(5)
	tabulate abil_STEM_q, sum(STEM_sub)
	
	
	tabulate abil_nonSTEM_q, sum(female)
	
	label define abil_nonSTEM_q_l 1 "1" 2 "2"  3 "3" ///
								4 "4" 5 "5" 
	
	
	label value abil_nonSTEM_q 	abil_nonSTEM_q_l						  
	label value abil_STEM_q 	abil_nonSTEM_q_l						  
								
	gen male=.
	replace male=1 if female==0
	replace male=0 if female==1

	graph bar (mean) female (mean) male, over(abil_nonSTEM_q) bar(1, fcolor(gs12) lcolor(gs12)) ///
			bar(2, fcolor(gs2) lcolor(gs2)) stack yline(0.5, lpattern(dash) lcolor(gs5)) ///
			title("Non-STEM Performance", size(medium) color(black)) ///
			legend(order(1 "Prop. Females" 2 "Prop. Males" )) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export 04_graphs\prop_female_nonSTEM.pdf,as(pdf) replace

	graph bar (mean) female (mean) male, over(abil_STEM_q) bar(1, fcolor(gs12) lcolor(gs12)) ///
			bar(2, fcolor(gs2) lcolor(gs2)) stack yline(0.5, lpattern(dash) lcolor(gs5)) ///
			title("STEM Performance", size(medium) color(black)) ///
			legend(order(1 "Prop. Females" 2 "Prop. Males" )) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export 04_graphs\prop_female_STEM.pdf,as(pdf) replace	
	
	noi:di ""
	noi:di "#--------------------#"
	noi:di "# Appendix Figure 4  #" 
	noi:di "#--------------------#"
	noi:di "" 

	preserve

	xtile abil_STEM_d=STEM_sub, nq(10)
	tab abil_STEM_d, sum(STEM_sub)

	forvalues i=1/10{
		sum STEM_sub if abil_STEM_d==`i'
		local sum_`i'_= r(mean)
		loc sum_`i': di %8.2f `sum_`i'_'
	}

	label define abil_STEM_d_l 1 "`sum_1'" 2 "`sum_2'" 3 "`sum_3'" 4 "`sum_4'" 5 "`sum_5'" 6 "`sum_6'" ///
			7 "`sum_7'" 8 "`sum_8'" 9  "`sum_9'" 10 "`sum_10'"
	label values abil_STEM_d abil_STEM_d_l
	tab abil_STEM_d

	graph box perc_rank_abs_adv, over(abil_STEM_d, gap(*3)) nooutsides box(1,color(gs8)) box(2,color(gs8)) box(3,color(gs8)) box(4,color(gs8)) box(5,color(gs8)) box(6,color(gs8)) box(7,color(gs8)) box(8,color(gs8)) box(9,color(gs8)) box(10,color(gs8)) asyvars showyvars leg(off) ///
		title("STEM Performance", size(medium) position(6) span ring(1)) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export variation_rank_STEM_ability.pdf, as(pdf) replace

	xtile abil_nonSTEM_d=nonSTEM_sub, nq(10)
	tab abil_nonSTEM_d, sum(nonSTEM_sub)

	forvalues i=1/10{
		sum nonSTEM_sub if abil_nonSTEM_d==`i'
		local sum_`i'_= r(mean)
		loc sum_`i': di %8.2f `sum_`i'_'
	}

	label define abil_nonSTEM_d_l 1 "`sum_1'" 2 "`sum_2'" 3 "`sum_3'" 4 "`sum_4'" 5 "`sum_5'" 6 "`sum_6'" ///
			7 "`sum_7'" 8 "`sum_8'" 9  "`sum_9'" 10 "`sum_10'"
	label values abil_nonSTEM_d abil_nonSTEM_d_l
	tab abil_nonSTEM_d

	graph box perc_rank_abs_adv, over(abil_nonSTEM_d, gap(*3)) nooutsides box(1,color(gs8)) box(2,color(gs8)) box(3,color(gs8)) box(4,color(gs8)) box(5,color(gs8)) box(6,color(gs8)) box(7,color(gs8)) box(8,color(gs8)) box(9,color(gs8)) box(10,color(gs8)) asyvars showyvars leg(off) ///
		title("Non-STEM Performance", size(medium) position(6) span ring(1)) graphregion(color(white))
	graph export variation_rank_nonSTEM_ability.pdf, as(pdf) replace
	
	restore
	
	noi:di ""
	noi:di "#--------------------#"
	noi:di "# Appendix Figure 5  #" 
	noi:di "#--------------------#"
	noi:di "" 
	
	preserve
	bysort idclass: egen abs_adv_stem_cls_sd=sd(abs_adv_stem)
	bysort idclass: gen uni_cls=1 if _n==1
	
	histogram abs_adv_stem_cls_sd if uni_cls==1, fcolor(%0) lcolor(gs2) xtitle(Classroom Standard Deviation of Absolute STEM Advantage) xline(0.2960514, lpattern(dash) lcolor(gs8)) ylabel(, grid glcolor(gs15)) graphregion(color(white))
	gr_edit AddTextBox added_text editor 7.97882971518607 48.81929754395333
	gr_edit added_text_new = 1
	gr_edit added_text_rec = 1
	gr_edit added_text[1].style.editstyle  angle(default) size( sztype(relative) val(3.4722) allow_pct(1)) color(black) horizontal(left) vertical(middle) margin( gleft( sztype(relative) val(0) allow_pct(1)) gright( sztype(relative) val(0) allow_pct(1)) gtop( sztype(relative) val(0) allow_pct(1)) gbottom( sztype(relative) val(0) allow_pct(1))) linegap( sztype(relative) val(0) allow_pct(1)) drawbox(no) boxmargin( gleft( sztype(relative) val(0) allow_pct(1)) gright( sztype(relative) val(0) allow_pct(1)) gtop( sztype(relative) val(0) allow_pct(1)) gbottom( sztype(relative) val(0) allow_pct(1))) fillcolor(bluishgray) linestyle( width( sztype(relative) val(.2) allow_pct(1)) color(black) pattern(solid) align(inside)) box_alignment(east) editcopy
	gr_edit added_text[1].style.editstyle size(vsmall) editcopy
	gr_edit added_text[1].text = {}
	gr_edit added_text[1].text.Arrpush Across-sample SD
	gr_edit added_text[1].style.editstyle color(gs8) editcopy
	graph export classroom_sd_histogram.pdf, as(pdf) replace
	restore
	
	noi:di ""
	noi:di "#--------------------#"
	noi:di "# Appendix Figure 6  #" 
	noi:di "#--------------------#"
	noi:di "" 
	
	preserve
	global studentcovariate "female  i.birth leave_out_female_peer"
	
	label variable abil_STEM_q "Quintile of STEM Performance"
	label variable abil_nonSTEM_q "Quintile of Non-STEM Performance"
	
	eststo: reghdfe track_11_2 female c.abs_adv_stem abs_adv_stem_2 STEM_sub nonSTEM_sub ///
		c.perc_rank_abs_adv##i.abil_STEM_q $studentcovariate, ///
		absorb(schoolid##year##classid) vce(cluster idschoolcohort)
			
	quietly margins, dydx(perc_rank_abs_adv) at(abil_STEM_q=(1(1)5)) 
	marginsplot, xlabel(1(1)5) recast(line) recastci(rarea) xlabel(, angle(horizontal)) ylabel(-0.1(0.1)0.25) ///
		yline(0, lpattern(dash) lcolor(gs8)) title("") ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export Rank_me_bySTEMability.pdf, as(pdf) replace
	
	eststo: reghdfe track_11_2 female c.abs_adv_stem abs_adv_stem_2 STEM_sub nonSTEM_sub ///
		c.perc_rank_abs_adv##i.abil_nonSTEM_q $studentcovariate, ///
		absorb(schoolid##year##classid) vce(cluster idschoolcohort)
	quietly margins, dydx(perc_rank_abs_adv) at(abil_nonSTEM_q=(1(1)5))
	marginsplot, xlabel(1(1)5) recast(line) recastci(rarea) xlabel(, angle(horizontal)) ylabel(-0.1(0.1)0.25) ///
		yline(0, lpattern(dash) lcolor(gs8)) title("") ylabel(, grid glcolor(gs15)) graphregion(color(white))
	graph export Rank_me_bynonSTEMability.pdf, as(pdf) replace	
	
	restore
	
	noi:di ""
	noi:di "#--------------------#"
	noi:di "# Appendix Figure 8  #" 
	noi:di "#--------------------#"
	noi:di "" 
	
	preserve
	keep  schoolid class_number mitroo female scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_AncientGreek
	
	gen sd_Algebra=scr_Algebra 
	gen sd_Physics=scr_Physics 
	gen sd_Chemistry=scr_Chemistry 
	gen sd_ModernGreek=scr_ModernGreek 
	gen sd_GreekLiterature=scr_GreekLiterature 
	gen sd_AncientGreek=scr_AncientGreek
	
	gen n_Algebra=scr_Algebra 
	gen n_Physics=scr_Physics 
	gen n_Chemistry=scr_Chemistry 
	gen n_ModernGreek=scr_ModernGreek 
	gen n_GreekLiterature=scr_GreekLiterature 
	gen n_AncientGreek=scr_AncientGreek
	
	collapse (mean) scr_Algebra scr_Physics scr_Chemistry scr_ModernGreek scr_GreekLiterature scr_AncientGreek ///
			(sd)  sd_Algebra sd_Physics sd_Chemistry sd_ModernGreek sd_GreekLiterature sd_AncientGreek ///
			(count) n_Algebra n_Physics n_Chemistry n_ModernGreek n_GreekLiterature n_AncientGreek , by(female)
	
	rename scr_Algebra 			score_1
	rename scr_Chemistry  		score_2
	rename scr_Physics 			score_3
	rename scr_AncientGreek  	score_4
	rename scr_GreekLiterature 	score_5
	rename scr_ModernGreek 		score_6
	
	rename sd_Algebra 			sd_1
	rename sd_Chemistry 		sd_2
	rename sd_Physics 			sd_3
	rename sd_AncientGreek 		sd_4
	rename sd_GreekLiterature 	sd_5
	rename sd_ModernGreek		sd_6
	
	rename n_Algebra 			n_1
	rename n_Chemistry 			n_2
	rename n_Physics			n_3
	rename n_AncientGreek 		n_4
	rename n_GreekLiterature 	n_5
	rename n_ModernGreek	    n_6
	
	
	reshape  long score_ sd_ n_, i(female) j(new)
	
	generate hi = score_ + invttail(n_-1,0.025)*(sd_ / sqrt(n_))
	generate lo = score_ - invttail(n_-1,0.025)*(sd_ / sqrt(n_))
	
	
	graph bar score_,  over(female) over(new) asyvars
	
	gen new_female=1 if new==1 & female==0
	replace new_female=2 if new==1 & female==1
	
	replace new_female=5 if new==2 & female==0
	replace new_female=6 if new==2 & female==1
	
	replace new_female=9 if new==3 & female==0
	replace new_female=10 if new==3 & female==1
	
	replace new_female=13 if new==4 & female==0
	replace new_female=14 if new==4 & female==1
	
	replace new_female=17 if new==5 & female==0
	replace new_female=18 if new==5 & female==1
	
	replace new_female=21 if new==6 & female==0
	replace new_female=22 if new==6 & female==1
	
	
	label define new_female_l 1 "Algebra" 5 "Chemistry"  9 "Physics"  13 "AncientGreek" 17 "GreekLiterature" 21 "ModernGreek" 
	label variable new_female ""						  
	
	label values new_female new_female_l	
	
	sort new_female
	list new_female female new, sepby(new)
	
	twoway (bar score_ new_female, sort), ylabel(9(1)14.5) xlabel(1(2)22, labsize(vsmall) angle(forty_five) valuelabel) || ///
			(rcap hi lo new_female)
			
			
	twoway (bar score_ new_female if female==0, fcolor(gs2) lcolor(gs2)) ///
		(bar score_ new_female if female==1, fcolor(gs12) lcolor(gs12)) ///
		(rcap hi lo new_female,  lcolor(gray)), ylabel(9(1)16) ///
		legend(row(1) order(1 "Male" 2 "Female") ) ///
		xlabel( 1.5 "Algebra" 5.5 "Chemistry" 9.5  "Physics" 13.5 "Ancient Greek" ///
		17.5 "Greek Literature" 21.5 "Modern Greek"  , labsize(small) angle(forty_five) noticks) ///
		xtitle("") ytitle("First Semester Score (/20)") ylabel(, grid glcolor(gs15)) graphregion(color(white)) 
		
	graph export 04_graphs\subj_gender_CI_semA.pdf, as(pdf) replace 
	restore