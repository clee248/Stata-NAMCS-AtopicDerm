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
local output_fig "/Volumes/GoogleDrive/My Drive/20181219_NAMCS_AtopicDermatitis"

*change to output directory for all analysis
cd "`source_case'"

*load merged, clean dataset
use "namcs_2015to1995_ICD9_691.dta"


/*
Data processing
	- collapsing variables to appropriately sized categories
	- identifying outcome variables
	- saving datasets for further analysis
*/

*change to output directory for datasets with new derived variables
cd "`output_dat'"

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

*histograms showing the distributions of atopic derm by sub-disease categories
hist AGE if CACO == 1, percent title("Any Atopic dermatitis and related conditions (691)") subtitle("n = 1,308") name("AnyADerm_age", replace)
hist AGE if adermcat == 0, percent title("Diaper or napkin rash (691.0)") subtitle("n = 436") name("diaperRash_age", replace) 
hist AGE if adermcat == 8, percent title("Other atopic dermatitis and related conditions (691.8)") subtitle("n = 872") name("ADerm_age", replace) 



/*
The remaining is from the pemphigoid analysis, 
and will be useful as a model to build the Atopic Dermatitis analysis




*look at 				
tab pemphcat pemphcatcol


*Reformat Table 1 variables as they were in Horii 2007, 
*	while obeying Cochran's Rule (5 observations per category)

**GENDER, DERIVED**

	*Gender (male)
	gen gender = .
	replace gender = 0 if SEX == 1
	replace gender = 1 if SEX == 2
	label define genderf 0 "Female" 1 "Male"
	label value gender genderf
	label variable gender "Gender"
	tab gender
	

**AGE CATEGORIZED, DERIVED**

	*look at age variables (AGE, AGER) in original NAMCS categories
	
	*look at histogram of age
	sum AGE, detail	
	*histogram AGE, frequency name(histogram_AGE, replace)
	sum AGE if pemphcatcol == 1, detail	
	*histogram AGE if pemphcatcol == 1, frequency name(hist_6945_AGE, replace)
	
	*Age dichotomized
	gen age70 = .
	replace age70 = 0 if AGE < 70 & AGE != .
	replace age70 = 1 if AGE >= 70 & AGE != .
	label define age70f 0 "< 70" 1 "≥ 70"
	label value age70 age70f
	label variable age70 "< 70 years old?"
	
	*Age categorized
	gen agecat = .
	replace agecat = 0 if AGE < 10
	replace agecat = 1 if AGE >=10 & AGE < 20
	replace agecat = 2 if AGE >=20 & AGE < 30
	replace agecat = 3 if AGE >=30 & AGE < 40
	replace agecat = 4 if AGE >=40 & AGE < 50
	replace agecat = 5 if AGE >=50 & AGE < 60
	replace agecat = 6 if AGE >=60 & AGE < 70
	replace agecat = 7 if AGE >=70 & AGE < 80
	replace agecat = 8 if AGE >=80 & AGE < 90
	replace agecat = 9 if AGE >= 90
	label define agecatf	0 "< 10"		///
							1 "teenager"	///
							2 "20's"		///
							3 "30's"		///
							4 "40's"		///
							5 "50's"		///
							6 "60's"		///
							7 "70's"		///
							8 "80's"		///
							9 "≥ 90"
	label value agecat agecatf
	label variable agecat "Age (years)"
	
	*age categorized so at least 5 observations in each category
	gen agecat5 = .
	replace agecat5 = 0 if AGE < 50
	replace agecat5 = 1 if AGE >=50 & AGE < 60
	replace agecat5 = 2 if AGE >=60 & AGE < 70
	replace agecat5 = 3 if AGE >=70 & AGE < 80
	replace agecat5 = 4 if AGE >=80 & AGE < 90
	replace agecat5 = 5 if AGE >= 90
	label define agecat5f	0 "< 50"		///
							1 "50-60"		///
							2 "60-70"		///
							3 "70-80"		///
							4 "80-90"		///
							5 "≥ 90"
	label value agecat5 agecat5f
	label variable agecat "Age (years)"
	tab agecat5
	
	
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
	gen race = .
	*White
	replace race = 0 if RACER == 1 & RACERETH == 1
	*Black
	replace race = 2 if RACER == 2 & RACERETH == 2
	*Hispanic
	replace race = 1 if RACER == 1 & RACERETH == 3	
	*Asian or Pacific Islander
	replace race = 3 if RACER == 3 & RACERETH == 4 & (RACEUN == 3 | RACEUN == 4)
	*American Indian/Alaska Native Only
	replace race = 4 if RACER == 3 & RACERETH == 4 & RACEUN == 5
	*Other
	replace race = 5 if RACER == 3 & RACERETH == 4 & (RACEUN != 3 & RACEUN != 4 & RACEUN != 5) 
	label define racef	0 "White"								///
						2 "Black"								///
						1 "Hispanic"							///
						3 "Asian or Pacific Islander"			///
						4 "American Indian/Alaska Native Only"	///
						5 "Other"
	label value race racef
	label variable race "Race"
*	graph bar (count),						///
*		over(race, label(tick angle(15)))	///
*		blabel(bar, format(%9.1f)) name(bar_race, replace)
	*look at race variable compared to original variables
	tab race
	
	*Race - white/not-white
	*	Do this because a lot of the categories have less than 5 observations,
	*		which violates Cochran's rule of ≥ 5 observations per category 
	*		in statistical tests
	gen white = .
	*White Only
	replace white = 1 if RACERETH != 1
	*Not-White
	replace white = 0 if RACER == 1 & RACERETH == 1
	label define whitef	1 "Not White"	///
						0 "White, Only"
	label value white whitef
	label variable white "Race White or not white"
	tab white
	
	*look at white variable vs race variables
	tab white race

	
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
	*Commercial: Private Insurance, Worker's Compensation
	replace insur = 1 if PAYTYPER == 1 | PAYTYPER == 4
	*Other: Self-pay, No charge/Charity, Other, Unknown, All Sources Left Blank
	replace insur = 2 if PAYTYPER == 5 | PAYTYPER == 6 | PAYTYPER == 7 | PAYTYPER == -8 | PAYTYPER == -9
	label define insurf  0 "Government" 1 "Commercial" 2 "Other"
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
	replace setting = MSA
	label define setf 1 "Urban" 2 "Nonurban"
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
	*Unknown: Unknown
	replace practice = 3 if OWNSR == -8
	label define pracf 0 "Physician Office" 1 "Hospital" 2 "Health Corporation" 3 "Unknown"
	label value practice pracf
	label var practice "Who owns the practice?"
	tab practice
	
	*physoff - the practice categories are too sparse...need to dichotomize
	gen physoff = .
	*All other practices: 	Medical/academic health center; Community health center; other hospital;; 
	*						Insurance company, health plan, or HMO; other health corporation; other;;
	*						Unknown;;
	*						Refused to answer;;
	*						Blank
	replace physoff = 0 if OWNSR == 2 | OWNSR == 3 | OWNSR == -6 | OWNSR == -8
	*Physician Office: Physician or physician group
	replace physoff = 1 if OWNSR == 1
	label define physofff 0 "All other practices" 1 "Physician or physician group"
	label value physoff physofff
	label var physoff "Do physicians own the practice?"
	tab physoff
	
	total PATWT, over(physoff)
	

**PROVIDER (SPECR), DERIVED**

	*look at provider (SPECR) in original NAMCS categories
	tab SPECR

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
	
	*provider - need to move ENT into "Other specialties" bc < 5 observations
	gen provider = .
	*Dermatology: Dermatology
	replace provider = 0 if SPECR == 9
	*Other specialties: Otolaryngology and Other specialties
	replace provider = 1 if SPECR == 14 | SPECR == 15
	*Internal medicine: Internal medicine
	replace provider = 2 if SPECR == 3
	*General/family practice: General/family practice
	replace provider = 3 if SPECR == 1
	*Ophthalmology: Ophthalmology
	replace provider = 4 if SPECR == 13
	label define providerf	3 "General/family practice"		///
							2 "Internal medicine"			///
							0 "Dermatology"					///
							4 "Ophthalmology"				///
							1 "Other specialties"
	label value provider providerf
	label var provider "Physician specialty - 5 Groups"
	tab provider SPECR

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
	tab SPECR specDerm
	
	*spec2 - make a dichotomous specalty variable: primary care vs specialist
	gen spec2 = .
	*primary care
	replace spec2 = 0 if specDerm == 1
	*specialist
	replace spec2 = 1 if inlist(specDerm,0,2) 
	label define spec2f 0 "Primary care" 1 "Specialist"
	label value spec2 spec2f
	label var spec2 "Was provider primary care or specialist?"
	
*save dataset with reformatted variables
order ptid CACO YEAR SETTYPE PATWT pemphcatcol pemphcat
sort ptid

cd "`output_dat'"

*all observations
save "namcs_2015to1995_anal.dta", replace

*cases only
keep if CACO == 1
save "namcs_2015to1995_anal_CasesOnly.dta", replace

/*
End of Data processing
*/

*sociodemographic variables
local sociodem  gender age70 white insur region setting physoff spec2

*reload the entire dataset with formatted variables for further analysis
cd "`output_dat'"
use "namcs_2015to1995_anal.dta
	

*Sheet 1: Case Category - all bullous dermatoses by collapsed categories
tab pemphcat pemphcatcol


*Sheet 2: Summary Stats - 694 - all bullous dermatosis

*cases

	*all cases
	sum PATWT if CACO == 1
	
	*cases by bullous dermatoses categories
	bysort pemphcatcol: sum PATWT if CACO ==1

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

	
*Sheet 3: Summary Stats - 694.5 - pemphigoid only

*cases

	*all cases
	sum PATWT if pemphcatcol == 1

	*cases by SD variables
	foreach dvar in `sociodem' {
		*look at counts in each category of SD variables
		bysort `dvar':	sum PATWT if pemphcatcol == 1
	}

*controls

	*all controls
	sum PATWT if pemphcatcol != 1

	*controls by SD variables
	foreach dvar in `sociodem' {
		*look at counts in each category of SD variables
		bysort `dvar':	sum PATWT if pemphcatcol != 1
	}
	
*Sheet 4: Table 1 - SD - 694 - all bullous dermatoses
**Total Estimated Patient Visits from 1995 to 2015**

*cases

	*all cases
	total PATWT if CACO == 1
	
	*cases by bullous dermatoses categories
	total PATWT if CACO ==1, over(pemphcatcol)
	
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


*Sheet 5: Table 1 - SD - 694.5 - pemphigoid only
**Total Estimated Patient Visits from 1995 to 2015**

*cases

	*all cases
	total PATWT if pemphcatcol == 1
		
	*cases by SD variables
	foreach dvar in `sociodem' {
		*look at PATWT summed in each category of SD variables
		total PATWT if pemphcatcol == 1, over(`dvar')
	}

*controls

	*all controls
	total PATWT if pemphcatcol != 1	

	*controls by SD variables
	foreach dvar in `sociodem' {
		*look at PATWT summed in each category of SD variables
		total PATWT if pemphcatcol != 1, over(`dvar')
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
local output_fig "/Volumes/GoogleDrive/My Drive/20181101_NAMCS Pierce/Figures & Tables/1.0_Pemphigus_Analysis"
cd "`output_fig'"

*look at variable frequencies in pemphigoid (694.5) only
foreach dvar in `sociodem' {
	
	**Cases
	
		*shows the number of observations per category for cases
		graph bar (count) if pemphcatcol == 1, over(`dvar', label(ticks angle(0) labsize(small)))	///
			blabel(bar, format(%9.0f))																///
			title("Frequency of Pemphigoid cases from 1995 to 2015")								///
			subtitle("≥ 30 for reliable estimates")													///
			ytitle("Number of Observations (count)")												///
			name(cnt_`dvar'_case, replace)
		*save graph
		graph export "cnt_`dvar'_case.png", replace

		*shows estimates by sociodemographic variables for cases
		graph hbar (sum) PATWT if pemphcatcol == 1, over(`dvar', label(labsize(small) angle(90) ticks))		///
			blabel(bar, format(%9.0fc))																		///
			title("Estimated patient visits, 1995-2015") 													///
			subtitle("Pemphigoid cases")																	///
			ylabel(0(250000)1100000, format(%9.0fc) angle(15)) ymticks(0(100000)1100000)												///
			ytitle("Estimated patient visits")																///
			name(est_`dvar'_case, replace)
		*save graph
		graph export "est_`dvar'_case.png", replace

	**Controls
		
		*shows the number of observations per category for controls
		graph bar (count) if pemphcatcol != 1, over(`dvar', label(ticks angle(0) labsize(small)))	///
			blabel(bar, format(%9.0f))																///
			title("Frequency of controls from 1995 to 2015")										///
			subtitle("≥ 30 for reliable estimates")													///
			ytitle("Number of Observations (count)")												///
			name(cnt_`dvar'_ctrl, replace)
		*save graph
		graph export "cnt_`dvar'_ctrl.png", replace
		
		*shows estimates by sociodemographic variables for controls
		graph hbar (sum) PATWT if pemphcatcol != 1, over(`dvar', label(labsize(small) angle(90) ticks))		///
			blabel(bar, format(%9.0fc))																		///
			title("Estimated patient visits, 1995-2015") 													///
			subtitle("Controls")																			///
			ylabel(0(5000000000)20000000000, angle(15)) ymticks(0(1000000000)20000000000)												///
			ytitle("Estimated patient visits")																///
			name(est_`dvar'_ctrl, replace)
		*save graph
		graph export "est_`dvar'_ctrl.png", replace

}


*Sheet 5: Figure 1 - Visits Year
**Total estimated patient visits per year from 1995 to 2015**
*See Figure 1 (Davis 2015)

*data to be used to make a line plot in excel


*all Bullous dermatoses

	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if CACO == 1

	*estimates and 95% CL per year
	total PATWT if CACO == 1, over(YEAR)

*(694.5) Pemphigoid

	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if pemphcatcol == 1

	*estimates and 95% CL per year
	total PATWT if pemphcatcol == 1, over(YEAR)

*(694.4) Pemphigus

	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if pemphcatcol == 2

	*estimates and 95% CL per year
	total PATWT if pemphcatcol == 2, over(YEAR)

*Other or Unspecified bullous dermatoses

	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if pemphcatcol == 3

	*estimates and 95% CL per year
	total PATWT if pemphcatcol == 3, over(YEAR)


*Sheet 6: Meds Table
**Most common meds prescribed from 1995 to 2015**

/* 
reshape medications prescribed data from wide to long 
https://stats.idre.ucla.edu/stata/modules/reshaping-data-wide-to-long/
*/

*load analytical wide dataset
cd "`output_dat'"
use "namcs_2015to1995_anal_CasesOnly.dta", clear

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
save "namcs_2015to1995_anal_LongMeds.dta", replace


*Sheet 7: Comorbidities Table
**Most common comorbidities from 1995 to 2015**

/* 
reshape diagnosis data from wide to long 
https://stats.idre.ucla.edu/stata/modules/reshaping-data-wide-to-long/
*/

*load original wide dataset
cd "`output_dat'"
use "namcs_2015to1995_anal_CasesOnly.dta", clear

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
save "namcs_2015to1995_anal_LongDiag.dta", replace



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
use "namcs_2015to1995_anal.dta", clear

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
