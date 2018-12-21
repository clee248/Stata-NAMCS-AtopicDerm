cls
clear

/*
Formatted to 2015 variables:
	YEAR SETTYPE PATWT
	DIAG1 DIAG13D DIAG2 DIAG23D DIAG3 DIAG33D DIAG4 DIAG43D DIAG5 DIAG53D
	SEX AGE AGER RACER RACERETH RACEUN PAYTYPER REGIONOFF MSA OWNSR SPECR SPECCAT
	s_MED1-s_MED30
	ETOHAB ALZHD ARTHRTIS ASTHMA ASTH_SEV ASTH_CON AUTISM CANCER CASTAGE
	CEBVD CAD CHF CKD COPD CRF DEPRN DIABETES DIABTYP1 DIABTYP2 DIABTYP0
	ESRD HIV HPE HTN HYPLIPID IHD OBESITY OSA OSTPRSIS SUBSTAB
	NOCHRON TOTCHRON
*/

local source_case "/Volumes/GoogleDrive/My Drive/20181219_NAMCS_AtopicDermatitis/Datasets/0.2_Datasets_ADerm_ID"

*output folder where analysis Figures and Tables output will be stored
local output_dat "/Volumes/GoogleDrive/My Drive/20181219_NAMCS_AtopicDermatitis/Datasets/1.0_ADerm_Analysis"

*output folder where analysis Figures and Tables output will be stored
local output_fig "/Volumes/GoogleDrive/My Drive/20181219_NAMCS_AtopicDermatitis/Figures & Tables"

*change to output directory for all analysis
cd "`source_case'"

*load merged, clean dataset
use "namcs_2015to1995_ICD9_691.dta"


/*
Data processing
	- collapsing variables to appropriately sized categories
	- identifying outcome variables
	- saving datasets for further analysis
/

*sort on case status (cases, then controls), then by year (2015 to 1995)
gsort -CACO -YEAR

*make case id, useful for further analyses
gen ptid = _n

*indicator variable to see whether diagnosed with Diaper or napkin rash (691.0), or Other atopic dermatitis and related conditions (691.8)
gen adermcat = .
	*identify all cases
		replace adermcat = -1 if CACO == 1
	*Diaper or napkin rash (691.0)
		replace adermcat = 0 if	DIAG1 == "6910-" | DIAG2 == "6910-" | DIAG3 == "6910-" | DIAG4 == "6910-" | DIAG5 == "6910-"
	*Other atopic dermatitis and related conditions (691.8)
		replace adermcat = 8 if	DIAG1 == "6918-" | DIAG2 == "6918-" | DIAG3 == "6918-" | DIAG4 == "6918-" | DIAG5 == "6918-"
	*format
	label define adermcatf	-1 "Case that does not fit into any specific category"			///
							 0 "(691.0) Diaper or napkin rash"								///
							 8 "(691.8) Other atopic dermatitis and related conditions"
label value adermcat adermcatf

*look at how data is distributed among the subcategories of atopic derm
tab adermcat

*change to output directory for saving plots and other figures
cd "`output_fig'"

/*
*histograms showing the distributions of atopic derm by sub-disease categories

	hist AGE if CACO == 1, freq title("Any Atopic dermatitis and related conditions (691)") subtitle("n = 1,308 (100%)") ylabel(0(100)400) xlabel(0(3)18) name("AnyADerm_age", replace) 
	graph export "hist_age_AnyADerm.png", replace
	
	hist AGE if adermcat == 0, freq title("Diaper or napkin rash (691.0)") subtitle("n = 436 (33.3%)") ylabel(0(100)400) xlabel(0(3)18) name("DiaperRash_age", replace) 
	graph export "hist_age_DiaperRash.png", replace
	
	hist AGE if adermcat == 8, freq title("Other atopic dermatitis and related conditions (691.8)") subtitle("n = 872 (66.7%)") ylabel(0(100)400) xlabel(0(3)18) name("ADerm_age", replace) 
	graph export "hist_age_ADerm.png", replace
*/

*after discussion w/AB, only include Other atopic dermatitis and related conditions (691.8)

	*save variable of all 691 diagnoses (just in case)
	gen CACO_691 = CACO

	*Recode the CACO variable to only inlcude 691.8
	replace CACO = 0 if adermcat != 8

*check to ensure only 691.8 is coded as a case
tab CACO adermcat 
tab CACO


*Reformat Table 1 variables as they were in Horii 2007, 
*	while obeying Cochran's Rule (5 observations per category)


**SEX, DERIVED**

	*sex (male)
	gen sex = .
	replace sex = 0 if SEX == 1
	replace sex = 1 if SEX == 2
	label define sexf 0 "Female" 1 "Male"
	label value sex sexf
	label variable sex "Sex"
	tab sex CACO
	

**AGE CATEGORIZED, DERIVED**

	*look at age variables (AGE, AGER) in original NAMCS categories
	
	*look at histogram of age
	sum AGE, detail	
	*histogram AGE, frequency name(histogram_AGE, replace)
	sum AGE if CACO == 1, detail	
	*histogram AGE if pemphcatcol == 1, frequency name(hist_6945_AGE, replace)
		
	*Age categorized
	gen agecat = .
	replace agecat = 4 if AGE < 18
	replace agecat = 3 if AGE < 11
	replace agecat = 2 if AGE < 6
	replace agecat = 1 if AGE < 2
	replace agecat = 0 if AGE < 1
	label define agecatf	0 "0"		///
							1 "1"		///
							2 "2-5"		///
							3 "6-10"	///
							4 "11-18"
	label value agecat agecatf
	label variable agecat "Age Categorized"
	
	tab agecat
	tab agecat CACO
*	hist agecat
*	hist AGE
*	scatter AGE agecat
	
	
**RACE, DERIVED**
	
	*look at race variables (RACERF, RACERETHF, RACEUNF) in original NAMCS categories
	tab RACER
	tab RACERETH
	tab RACEUN
	
	/* look at formatting of NAMCS race variables
	
	RACER
	label define RACERF 1 "White"  
	label define RACERF 2 "Black" , add
	label define RACERF 3 "Other" , add

	RACERETH
	label define RACERETHF 1 "Non-Hispanic White"
	label define RACERETHF 2 "Non-Hispanic Black" , add
	label define RACERETHF 3 "Hispanic" , add
	label define RACERETHF 4 "Non-Hispanic Other" , add

	RACEUN
	label define RACEUNF 1 "White Only"  
	label define RACEUNF 2 "Black/African American Only" , add
	label define RACEUNF 3 "Asian Only" , add
	label define RACEUNF 4 "Native Hawaiian/Oth Pac Isl Only" , add
	label define RACEUNF 5 "American Indian/Alaska Native Only" , add
	label define RACEUNF 6 "More than one race reported" , add
	label define RACEUNF -9 "Blank" , add
	*/

	*look at RACER by RACERETH
	tab RACER RACERETH

	*Race
	gen race = -1
	*Black (non-Hispanic)
	replace race = 1 if RACEUN == 2 | RACER == 2 | RACERETH == 2
	*White (non-Hispanic)
	replace race = 4 if RACEUN == 1 | RACER == 1 | RACERETH == 1
	*Other
	replace race = 5 if RACER == 3 | RACERETH == 4 | RACEUN == 6
	*missing
	replace race = . if RACEUN == -9
	*Asian or Pacific Islander
	replace race = 2 if RACEUN == 3 | RACEUN == 4
	*American Indian/Alaska Native Only
	replace race = 3 if RACEUN == 5
	*Hispanic (Any hispanic is considered hispanic)
	replace race = 0 if	RACERETH == 3	
	label define racef	-1 "Did not fit any other category"		///
						 0 "Hispanic"							///
						 1 "Black"								///
						 2 "Asian or Pacific Islander"			///
						 3 "American Indian/Alaska Native Only"	///
						 4 "White"								///
						 5 "Other"
	label value race racef
	label variable race "Race"
	
		*make a graph of race distribution of cases
/*		graph bar (count) if CACO == 1,							///
			over(race, label(tick angle(15)))					///
			blabel(bar, format(%9.1f)) name(bar_race, replace)
*/			
		*look at race variable compared to original variables
		tab race
		tab race RACER
		
		*check to make sure there's no categories without a race grouping
		tab AGE if race == -1
	

**INSURANCE, DERIVED**	

	*look at the payment method (PAYTYPER) in original NAMCS categories
	tab PAYTYPER
	
	/* look at formatting of NAMCS PAYTYPER variable
	
	label define PAYTYPERF 1 "Private insurance"  
	label define PAYTYPERF 2 "Medicare" , add
	label define PAYTYPERF 3 "Medicaid, CHIP or other state-based program" , add
	label define PAYTYPERF 4 "Worker's compensation" , add
	label define PAYTYPERF 5 "Self-pay" , add
	label define PAYTYPERF 6 "No charge/Charity" , add
	label define PAYTYPERF 7 "Other" , add
	label define PAYTYPERF -8 "Unknown" , add
	label define PAYTYPERF -9 "All sources of payment are blank" , add	
	*/
	
	*Insurance
	gen insur = .
	*Government: Medicare, Medicaid
	replace insur = 0 if PAYTYPER == 2 | PAYTYPER == 3
	*Self-pay
	replace insur = 1 if PAYTYPER == 5
	*Other: No charge/Charity, Other, Unknown
	replace insur = 2 if PAYTYPER == 6 | PAYTYPER == 7 | PAYTYPER == -8
	*Commercial: Private Insurance, Worker's Compensation
	replace insur = 3 if PAYTYPER == 1 | PAYTYPER == 4
	*Missing
	replace insur = . if PAYTYPER == -9
		label define insurf  0 "Government" 1 "Self-pay" 2 "Other" 3 "Commercial"
		label value insur insurf
		label var insur "Payment method"
	tab insur


**REGION, DERIVED**	

	*look at region (REGIONOFF) in original NAMCS categories
	tab REGIONOFF
	
	/* look at formatting of NAMCS REGIONOFF variable

	label define REGIONF 1 "Northeast"  
	label define REGIONF 2 "Midwest" , add
	label define REGIONF 3 "South" , add
	label define REGIONF 4 "West" , add
	*/
	
	*REGIONOFF is okay; there are sufficient observations in each regional category.
	*	need to rename and relabel to make clean graph
	gen region = .
	replace region = REGIONOFF
	label define regf 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
	label value region regf
	label var region "Region where majority of physician's sampled visits occurred"
	tab region
	
**SETTING (MSA), DERIVED**

	*look at setting (MSA) in original NAMCS categories
	tab MSA

	/* look at formatting of NAMCS MSA variable
	
	label define MSAF 1 "MSA (Metropolitan Statistical Area)"
	label define MSAF 2 "Non-MSA" , add
	*/
	
	*MSA is okay; there are sufficient observations in each setting category.
	*	need to rename and relabel to make clean graph
	gen setting = .
	*Urban
	replace setting = 0 if MSA == 1
	*Nonurban
	replace setting = 1 if MSA == 2
		label define setf 0 "Urban" 1 "Nonurban"
		label value setting setf
		label var setting "Metropolitan Statistical Area - Status of physician location"
	tab setting
	
**PRACTICE (OWNSR), DERIVED**

	*look at practice (OWNSR) in original NAMCS categories
	tab OWNSR

	/* look at formatting of NAMCS OWNSR variable	

	label define OWNSRF 1 "Physician or physician group"  
	label define OWNSRF 2 "Medical/academic health center; Community health center; other hospital" , add
	label define OWNSRF 3 "Insurance company, health plan, or HMO; other health corporation; other" , add
	label define OWNSRF -6 "Refused to answer" , add
	label define OWNSRF -8 "Unknown" , add
	label define OWNSRF -9 "Blank" , add
	*/

	*practice
	gen practice = .
	*Physician Office: Physician or physician group
	replace practice = 0 if OWNSR == 1
	*Hospital: Medical/academic health center; Community health center; other hospital
	replace practice = 1 if OWNSR == 2
	*Health Corporation: Insurance company, health plan, or HMO; other health corporation; other
	replace practice = 2 if OWNSR == 3
	*Unknown or Missing
	replace practice = . if OWNSR == -9 | OWNSR == -6 | OWNSR == -8
		label define pracf 0 "Physician or physician group" 1 "Hospital or Community Health Center" 2 "Health Corporation"
		label value practice pracf
		label var practice "Who owns the practice?"
	bysort CACO: tab practice
		

**PROVIDER (SPECR), DERIVED**

	*look at provider (SPECR) in original NAMCS categories
	bysort CACO: tab SPECR

	/* look at formatting of NAMCS OWNSR variable	
	
	label define SPECRF 01 "General/family practice"  
	label define SPECRF 03 "Internal medicine" , add
	label define SPECRF 04 "Pediatrics" , add
	label define SPECRF 05 "General surgery" , add
	label define SPECRF 06 "Obstetrics and gynecology" , add
	label define SPECRF 07 "Orthopedic surgery" , add
	label define SPECRF 08 "Cardiovascular diseases" , add
	label define SPECRF 09 "Dermatology" , add
	label define SPECRF 10 "Urology" , add
	label define SPECRF 11 "Psychiatry" , add
	label define SPECRF 12 "Neurology" , add
	label define SPECRF 13 "Ophthalmology" , add
	label define SPECRF 14 "Otolaryngology" , add
	label define SPECRF 15 "Other specialties" , add
	*/
	

	*specDerm - look at dermatologists vs primary care vs all other specialists
	gen specDerm = .
	*Dermatology: Dermatology
	replace specDerm = 0 if SPECR == 9
	*Primary Care: General/family practice, Internal medicine, Pediatrics
	replace specDerm = 1 if inlist(SPECR, 1, 3, 4)
	*Other Specialist: Ophthalmology, Otolaryngology, Other specialties
	replace specDerm = 2 if inlist(SPECR, 5, 6, 7, 8, 10, 11, 12, 13, 14 ,15)
		label define specDermf	0 "Dermatology"		///
								1 "Primary Care"	///
								2 "Other Specialists"				
		label value specDerm specDermf
		label var specDerm "Physician specialty - 3 Groups"
	bysort CACO: tab SPECR specDerm
	
	*spec2 - make a dichotomous specalty variable: primary care vs specialist
	gen spec2 = .
	*primary care
	replace spec2 = 0 if specDerm == 1
	*specialist
	replace spec2 = 1 if inlist(specDerm,0,2) 
	label define spec2f 0 "Primary care" 1 "Specialist"
	label value spec2 spec2f
	label var spec2 "Was provider primary care or specialist?"
	bysort CACO: tab SPECR spec2
	
*save dataset with reformatted variables
order ptid CACO YEAR SETTYPE PATWT adermcat
sort ptid

cd "`output_dat'"

*all observations
save "namcs_2015to1995_6918_anal.dta", replace

*cases only
keep if CACO == 1
save "namcs_2015to1995_6918_anal_CasesOnly.dta", replace

/
End of Data processing
*/

*reload the entire dataset with formatted variables for further analysis
cd "`output_dat'"
use "namcs_2015to1995_6918_anal.dta


**RELABEL VARIABLES so they fit on the plots cleanly

	*redefine race so it fits in the plots
	gen racegph = race
	label define racegphf	 0 "Hispanic"			///
							 1 "Black"				///
							 2 "Asian"				///
							 3 "Native American"	///
							 4 "White"				///
							 5 "Other"
	label val racegph racegphf
	label var racegph "Race"

*sociodemographic variables
local sociodem  	sex agecat race insur region setting practice specDerm spec2
*sociodemographic variables - relabeled so graphs produced cleanly
local sociodem_gph  sex agecat racegph insur region setting practice specDerm spec2


/*Sheet 1: Case Category - all atopic derm (691) by specific disease categories
tab adermcat


*Sheet 2: Summary Stats - 691.8

*cases

	*all cases
	sum PATWT if CACO == 1
	
	*cases by SD variables
	foreach dvar in `sociodem' {
		*look at counts in each category of SD variables
		bysort `dvar':	sum PATWT if CACO == 1
	}

*controls

	*all controls
	sum PATWT if CACO != 1

	*controls by SD variables
	foreach dvar in `sociodem' {
		*look at counts in each category of SD variables
		bysort `dvar':	sum PATWT if CACO != 1
	}


*Sheet 3: Table 1 - SD - 691.8
**Total Estimated Patient Visits from 1995 to 2015**

*cases

	*all cases
	total PATWT if CACO == 1
	
	*cases by SD variables
	foreach dvar in `sociodem' {
		*look at PATWT summed in each category of SD variables
		total PATWT if CACO == 1, over(`dvar')
	}

*controls

	*all controls
	total PATWT if CACO == 0	

	*controls by SD variables
	foreach dvar in `sociodem' {
		*look at PATWT summed in each category of SD variables
		total PATWT if CACO != 1, over(`dvar')
	}

/*
Make bar graphs showing frequency counts and estimates for each sociodemographic variable for cases and controls

	- 2 plots: number of observations per estimate (by sd variable) for cases and controls
		this is important because estimates are unreliable if < 30 observations per estimate

	- 2 plots: estimates by sd variable for cases and controls
		cannot figure out how to show 95% confidence intervals; use excel or R
		
	Note: should produce 4 plots for each SD variable

*/

*change directory to folder where graphs will be saved
cd "`output_fig'"

*look at variable frequencies in pemphigoid (694.5) only
foreach dvar in `sociodem_gph' {
	
	**Cases

		*shows the number of observations per category for cases
		graph bar (count) if CACO == 1, over(`dvar', label(ticks angle(0) labsize(small)))	///
			blabel(bar, format(%9.0f))																///
			title("Frequency of Pemphigoid cases from 1995 to 2015")								///
			subtitle("≥ 30 for reliable estimates")													///
			ytitle("Number of Observations (count)")												///
			name(cnt_`dvar'_case, replace)
		*save graph
		graph export "cnt_`dvar'_case.png", replace

		*shows estimates by sociodemographic variables for cases
		graph hbar (sum) PATWT if CACO == 1, over(`dvar', label(labsize(vsmall) angle(90) ticks alternate))		///
			blabel(bar, format(%9.0fc))																			///
			title("Estimated patient visits, 1995-2015") 														///
			subtitle("Pemphigoid cases")																		///
			ylabel(0(5e6)25e6, format(%9.0fc) angle(15)) ymticks(0(5e6)25e6)									///
			ytitle("Estimated patient visits")																	///
			name(est_`dvar'_case, replace)
		*save graph
		graph export "est_`dvar'_case.png", replace

	**Controls
	
		*shows the number of observations per category for controls
		graph bar (count) if CACO != 1, over(`dvar', label(ticks angle(0) labsize(small)))		///
			blabel(bar, format(%9.0f))															///
			title("Frequency of controls from 1995 to 2015")									///
			subtitle("≥ 30 for reliable estimates")												///
			ytitle("Number of Observations (count)")											///
			name(cnt_`dvar'_ctrl, replace)
		*save graph
		graph export "cnt_`dvar'_ctrl.png", replace
	
		*shows estimates by sociodemographic variables for controls
		graph hbar (sum) PATWT if CACO != 1, over(`dvar', label(labsize(vsmall) angle(90) ticks alternate))		///
			blabel(bar, format(%9.0fc))																			///
			title("Estimated patient visits, 1995-2015") 														///
			subtitle("Controls")																				///
			ylabel(0(5e8)3.5e9, angle(15)) ymticks(0(5e8)3.5e9)													///
			ytitle("Estimated patient visits")																	///
			name(est_`dvar'_ctrl, replace)
		*save graph
		graph export "est_`dvar'_ctrl.png", replace

}


*Sheet 4: Figure 1 - Visits Year
**Total estimated patient visits per year from 1995 to 2015**
*See Figure 1 (Davis 2015)

*data to be used to make a line plot in excel

*all Atopic dermatitis (691)

	*check n to ensure looking at correct group
	tab CACO_691 if CACO_691 == 1
	
	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if CACO_691 == 1

	*estimates and 95% CL per year
	total PATWT if CACO_691 == 1, over(YEAR)

*(691.8) Other atopic dermatitis and related conditions

	*check n to ensure looking at correct group
	tab CACO if CACO == 1

	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if CACO == 1

	*estimates and 95% CL per year
	total PATWT if CACO == 1, over(YEAR)

*(691.0) Diaper or napkin rash

	*check n to ensure looking at correct group
	tab CACO if adermcat == 0

	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if adermcat == 0

	*estimates and 95% CL per year
	total PATWT if adermcat == 0, over(YEAR)
*/

*Sheet 6: Meds Table
**Most common meds prescribed from 1995 to 2015**

/* 
reshape medications prescribed data from wide to long 
https://stats.idre.ucla.edu/stata/modules/reshaping-data-wide-to-long/
*/

*load analytical wide dataset
cd "`output_dat'"
use "namcs_2015to1995_6918_anal_CasesOnly.dta", clear

*reshape to long data
reshape long s_MED, i(ptid) j(medid) 

*look at most common meds
tab s_MED, sort

*generate indicator variable for 694 Primary diagnosis 
*	(i.e. 694 in first diagnosis position)
gen diag1_694 = .
replace diag1_694 = 1 if DIAG13D == "694"
tab s_MED if diag1_694 == 1, sort

*generate indicator variable for (694.5) Pemphigoid Primary diagnosis 
*	(i.e. 694.5 in first diagnosis position)
gen diag1_694_5 = .
replace diag1_694_5 = 1 if DIAG1 == "6945-"
tab s_MED if diag1_694_5 == 1, sort

*generate indicator variable for (694.4) Pemphigus Primary diagnosis 
*	(i.e. 694.4 in first diagnosis position)
gen diag1_694_4 = .
replace diag1_694_4 = 1 if DIAG1 == "6944-"
tab s_MED if diag1_694_4 == 1, sort

*generate indicator variable for Other or Unspecified bullous dermatoses Primary diagnosis 
*	(i.e. 6940- 6943- 69460 69461 6948- 6949- in first diagnosis position)
gen diag1_694_other = .
replace diag1_694_other = 1 if DIAG1 == "6940-" | DIAG1 == "6943-" | DIAG1 == "69460" | DIAG1 == "69461" | DIAG1 == "6948-" | DIAG1 == "6949-"
tab s_MED if diag1_694_other == 1, sort


*save long dataset
*save "namcs_2015to1995_6918_anal_LongMeds.dta", replace


/*Sheet 7: Comorbidities Table
**Most common comorbidities from 1995 to 2015**

/* 
reshape diagnosis data from wide to long 
https://stats.idre.ucla.edu/stata/modules/reshaping-data-wide-to-long/
*/

*load original wide dataset
cd "`output_dat'"
use "namcs_2015to1995_6918_anal_CasesOnly.dta", clear

*reshape to long data
reshape long DIAG, i(ptid) j(dxid) 

*look at most common comorbidities: 
*	(1) IGNORE any pemphigus diagnoses, 
*	(2) IGNORE any comorbidities that have less than 2 observations
*all Bullous dermatoses
tab DIAG if CACO == 1, sort

*(694.5) Pemphigoid
tab DIAG if pemphcatcol == 1, sort

*(694.4) Pemphigus
tab DIAG if pemphcatcol == 2, sort

*Other or Unspecified bullous dermatoses
tab DIAG if pemphcatcol == 3, sort


*save long dataset
save "namcs_2015to1995_6918_anal_LongDiag.dta", replace



*Sheet 8: Table 2 - SD ORs
**The code is here, but these ORs are not reliable due to data sparsity
**They will not be reported in the analysis

/*
Notes for running logistics in NAMCS

	*preparation for survey sampled logistic regression
	*https://stats.idre.ucla.edu/stata/faq/how-do-i-use-the-stata-survey-svy-commands/
	svyset CPSUM [pweight=poolwt], strata(CSTRATM)

	*actually run the regression
	svy: logistic y x1 x2 x3

*/

*use wide analytical dataset for logistic regression analysis
cd "`output_dat'"
use "namcs_2015to1995_6918_anal.dta", clear

*make outcome variable specific to pemphigoid
gen CACO_6945 = .
replace CACO_6945 = 1 if pemphcatcol == 1
replace CACO_6945 = 0 if pemphcatcol != 1
		
*preparation for survey sampled logistic regression
svyset CPSUM [pweight=PATWT], strata(CSTRATM)

foreach univar in `sociodem' {

	*actually run the regression
	svy: logistic CACO_6945 i.`univar'
}

*how to see where the errors are from
*	https://www.statalist.org/forums/forum/general-stata-discussion/general/1375170-survey-analysis-error-with-single-stratum
*svydes
