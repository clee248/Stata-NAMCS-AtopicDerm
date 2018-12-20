cls
clear

/*
This program will subset variables from years 1995 to 2015 based on a ICD9 code.
To change the ICD9 code,  replace "6918" with the desired code.
*/

*source folder where all the subset NAMCS datasets are in Stata .dta format
local source "/Volumes/GoogleDrive/My Drive/20181219_NAMCS_AtopicDermatitis/Datasets/0.1_Datasets_Merged"

*output folder where all the subset NAMCS datasets will be created in Stata .dta format
local output "/Volumes/GoogleDrive/My Drive/20181219_NAMCS_AtopicDermatitis/Datasets/0.2_Datasets_ADerm_ID"



*macro identifying the 3-digit ICD9 code

local ICD9code "691"

foreach code in `ICD9code' {

	*clear loaded data
	clear
	
	*mac path to complete NAMCS datasets for 1995 to 2015
	cd "`source'"

	*load the dataset
	use "namcs_2015to1995.dta"
	
	*add an indicator variable for cases or controls
	gen CACO = 0
	replace CACO = 1 if	strpos(DIAG13D, "`code'") | strpos(DIAG23D, "`code'") | strpos(DIAG33D, "`code'") | strpos(DIAG43D, "`code'") | strpos(DIAG53D, "`code'")
	label define CACOf	0 "Control" 1 "Case"
	label value CACO CACOf
	label var CACO "Case indicator variable"

	*change directory to where would like to save datasets
	cd "`output'"
	
	*organize variables in meaningful order
	order  	CACO YEAR SETTYPE PATWT CSTRATM CPSUM											///
			DIAG1 DIAG13D DIAG2 DIAG23D DIAG3 DIAG33D DIAG4 DIAG43D DIAG5 DIAG53D			///
			SEX AGE AGER RACER RACERETH RACEUN PAYTYPER REGIONOFF MSA OWNSR SPECR SPECCAT	///
			s_MED1-s_MED30																	///
			ETOHAB ALZHD ARTHRTIS ASTHMA ASTH_SEV ASTH_CON AUTISM CANCER CASTAGE			///
			CEBVD CAD CHF CKD COPD CRF DEPRN DIABETES DIABTYP1 DIABTYP2 DIABTYP0			///
			ESRD HIV HPE HTN HYPLIPID IHD OBESITY OSA OSTPRSIS SUBSTAB						///
			NOCHRON TOTCHRON STRATM PSUM SUBFILE PROSTRAT PROVIDER
			
	*drop if 18 years and older
	drop if AGE >= 18
	
	*save complete dataset of cases and controls, now with indicator variable
	save namcs_2015to1995_ICD9_`code', replace
	
	*keep observations with diagnoses of "Atopic dermatitis and related conditions" (691) 
	keep if	strpos(DIAG13D, "`code'") | strpos(DIAG23D, "`code'") | strpos(DIAG33D, "`code'") | strpos(DIAG43D, "`code'") | strpos(DIAG53D, "`code'")
				
	*save dataset of cases only
	save namcs_2015to1995_ICD9_`code'_CasesOnly, replace
		
}
