* models_paper_january2020_year.do
* Outputs: Models for sample > 1990 (or in fact any other year of your choice) presented in tables in appendix
* Dependencies: master_elec.dta

not a command but stops execution of the code if whole do file is ran accidentally

set more off

cap cd ""
cap use "master_elec.dta", clear

*Create correct time - var
gen election_date2 = date(election_date, "YMD")
format election_date2 %td

* But not a useful time variable because it doesn't allow lags
* We need a temporal count variable

*Creat year
gen year = election_year
* Create year squared
gen year2 = year^2

***NB (!): Two types of elections in the data: EP and nat. parl.

* Duplicates in data set - we have to decide on which we drop:
* No duplicates in national elections but some concurrent national and EP elections
* duplicates drop country_id country_name election_date2 election_type, force

* Parliamentary elections only for now
*Drop EP results
keep if election_type=="parliament"

xtset country_id election_count

* ------------------------------------------------------------------------------
* Figure 1 and Table 1
* ------------------------------------------------------------------------------

* Table 1  ---------------------------------------------------------------------

local ivs populistparty l_populistpresence populist_new l_populistvoteshare l_populistseatshare
local controls enp_seats unemp openc population_mio compulsory_voting pr tier1_avemag margin age_of_democracy
local year 1990

eststo clear
cap drop pred*

eststo m1: xtreg turnout populistparty `controls' i.election_period if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m1
replace pred_m1 = round(pred_m1,.01)
regsave populistparty using "models/figure1_`year'.dta", ci replace saveold(12) ///
	addlabel(model, "m1", specification, "FE5", operationalization, "level")

eststo m2: xtreg turnout l_populistpresence `controls' i.election_period if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m2
replace pred_m2 = round(pred_m2,.01)
regsave l_populistpresence using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "FE5", operationalization, "level")	
	
eststo m3: xtreg turnout populist_new `controls' i.election_period if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m3
replace pred_m3 = round(pred_m3,.01)
regsave populist_new using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "FE5", operationalization, "level")
	
eststo m4: xtreg turnout l_populistvoteshare `controls' i.election_period if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m4
replace pred_m4 = round(pred_m4,.01)
regsave l_populistvoteshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "FE5", operationalization, "level")	
	
eststo m5: xtreg turnout l_populistseatshare `controls' i.election_period if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m5
replace pred_m5 = round(pred_m5,.01)
regsave l_populistseatshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m5", specification, "FE5", operationalization, "level")	

* Table A.4
sum pred_m*  // Range of predictions

* Table 1
esttab m1 m2 m3 m4 m5, se keep(`ivs' `controls') ///
	s(fixed r2 N , ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}" "N"))
	
esttab m1 m2 m3 m4 m5 using "tables/t_1_`year'.tex", ///
	se r2 booktabs compress nogaps align(l) b(2) se(2) staraux replace ///
	keep(`ivs' `controls') nomtitles ///
	coeflabels(populistparty "Populist Participation" ///
		   l_populistpresence "Populist Representation" ///
		   populist_new "New Populist Party" ///
		   l_populistvoteshare "Populist Vote Share" ///
		   l_populistseatshare "Populist Seat Share" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(populistparty l_populistpresence populist_new ///
		  l_populistvoteshare l_populistseatshare) ///
	s(fixed r2 N, ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}" "N")) ///
	star(+ 0.1 * 0.05)	
	

* Table 1 (Delta) --------------------------------------------------------------

local ivs d_populistparty d_l_populistpresence d_populist_new d_l_populistvoteshare d_l_populistseatshare
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_tier1_avemag d_margin d_age_of_democracy
local year 1990

eststo clear
cap drop pred*

eststo m1: reg d_turnout d_populistparty `d_controls' i.election_period if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m1
replace pred_m1 = round(pred_m1,.01)
regsave d_populistparty using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "FE5", operationalization, "delta")

eststo m2: reg d_turnout d_l_populistpresence `d_controls' i.election_period if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m2
replace pred_m2 = round(pred_m2,.01)
regsave d_l_populistpresence using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "FE5", operationalization, "delta")	
	
eststo m3: reg d_turnout d_populist_new `d_controls' i.election_period if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m3
replace pred_m3 = round(pred_m3,.01)
regsave d_populist_new using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "FE5", operationalization, "delta")
	
eststo m4: reg d_turnout d_l_populistvoteshare `d_controls' i.election_period if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m4
replace pred_m4 = round(pred_m4,.01)
regsave d_l_populistvoteshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "FE5", operationalization, "delta")	
	
eststo m5: reg d_turnout d_l_populistseatshare `d_controls' i.election_period if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m5
replace pred_m5 = round(pred_m5,.01)
regsave d_l_populistseatshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m5", specification, "FE5", operationalization, "delta")	

* Table 1
esttab m1 m2 m3 m4 m5, se keep(`ivs' `d_controls') ///
	s(fixed r2 N , ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}" "N"))
	
esttab m1 m2 m3 m4 m5 using "tables/t_1_delta_`year'.tex", ///
	se r2 booktabs compress nogaps align(l) b(2) se(2) staraux replace ///
	keep(`ivs' `d_controls') nomtitles ///
	coeflabels(d_populistparty "$\Delta$ Populist Participation" ///
		   d_l_populistpresence "$\Delta$ Populist Representation" ///
		   d_populist_new "$\Delta$ New Populist Party" ///
		   d_l_populistvoteshare "$\Delta$ Populist Vote Share" ///
		   d_l_populistseatshare "$\Delta$ Populist Seat Share" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(d_populistparty d_l_populistpresence d_populist_new ///
		  d_l_populistvoteshare d_l_populistseatshare) ///
	s(fixed r2 N, ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}" "N")) ///
	star(+ 0.1 * 0.05)	
	
* Table 1 (year fixed effects) -------------------------------------------------

local ivs populistparty l_populistpresence populist_new l_populistvoteshare l_populistseatshare
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local year 1990

eststo clear
cap drop pred*

eststo m1: xtreg turnout populistparty `controls' i.election_year if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m1
replace pred_m1 = round(pred_m1,.01)
regsave populistparty using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "FE", operationalization, "level")

eststo m2: xtreg turnout l_populistpresence `controls' i.election_year if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m2
replace pred_m2 = round(pred_m2,.01)
regsave l_populistpresence using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "FE", operationalization, "level")	
	
eststo m3: xtreg turnout populist_new `controls' i.election_year if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m3
replace pred_m3 = round(pred_m3,.01)
regsave populist_new using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "FE", operationalization, "level")
	
eststo m4: xtreg turnout l_populistvoteshare `controls' i.election_year if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m4
replace pred_m4 = round(pred_m4,.01)
regsave l_populistvoteshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "FE", operationalization, "level")	
	
eststo m5: xtreg turnout l_populistseatshare `controls' i.election_year if election_year >= `year', fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
predict pred_m5
replace pred_m5 = round(pred_m5,.01)
regsave l_populistseatshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m5", specification, "FE", operationalization, "level")	

* Table 1
esttab m1 m2 m3 m4 m5, se keep(`ivs' `controls') ///
	s(fixed r2 N , ///
	label("Country / Year Fixed Effects" "R\textsuperscript{2}" "N"))
	
esttab m1 m2 m3 m4 m5 using "tables/t_1_fe_`year'.tex", ///
	se r2 booktabs compress nogaps align(l) b(2) se(2) staraux replace ///
	keep(`ivs' `controls') nomtitles ///
	coeflabels(populistparty "Populist Participation" ///
		   l_populistpresence "Populist Representation" ///
		   populist_new "New Populist Party" ///
		   l_populistvoteshare "Populist Vote Share" ///
		   l_populistseatshare "Populist Seat Share" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(populistparty l_populistpresence populist_new ///
		  l_populistvoteshare l_populistseatshare) ///
	s(fixed r2 N, ///
	label("Country / Year Fixed Effects" "R\textsuperscript{2}" "N")) ///
	star(+ 0.1 * 0.05)	

* Table 1 (Delta, year fixed effects) ------------------------------------------

local ivs d_populistparty d_l_populistpresence d_populist_new d_l_populistvoteshare d_l_populistseatshare
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear
cap drop pred*

eststo m1: reg d_turnout d_populistparty `d_controls' i.election_year if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m1
replace pred_m1 = round(pred_m1,.01)
regsave d_populistparty using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "FE", operationalization, "delta")

eststo m2: reg d_turnout d_l_populistpresence `d_controls' i.election_year if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m2
replace pred_m2 = round(pred_m2,.01)
regsave d_l_populistpresence using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "FE", operationalization, "delta")	
	
eststo m3: reg d_turnout d_populist_new `d_controls' i.election_year if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m3
replace pred_m3 = round(pred_m3,.01)
regsave d_populist_new using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "FE", operationalization, "delta")
	
eststo m4: reg d_turnout d_l_populistvoteshare `d_controls' i.election_year if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m4
replace pred_m4 = round(pred_m4,.01)
regsave d_l_populistvoteshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "FE", operationalization, "delta")	
	
eststo m5: reg d_turnout d_l_populistseatshare `d_controls' i.election_year if election_year >= `year', cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
predict pred_m5
replace pred_m5 = round(pred_m5,.01)
regsave d_l_populistseatshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m5", specification, "FE", operationalization, "delta")	

* Table 1
esttab m1 m2 m3 m4 m5, se keep(`ivs' `d_controls') ///
	s(fixed r2 N , ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}" "N"))
	
esttab m1 m2 m3 m4 m5 using "tables/t_1_delta_fe_`year'.tex", ///
	se r2 booktabs compress nogaps align(l) b(2) se(2) staraux replace ///
	keep(`ivs' `d_controls') nomtitles ///
	coeflabels(d_populistparty "$\Delta$ Populist Participation" ///
		   d_l_populistpresence "$\Delta$ Populist Representation" ///
		   d_populist_new "$\Delta$ New Populist Party" ///
		   d_l_populistvoteshare "$\Delta$ Populist Vote Share" ///
		   d_l_populistseatshare "$\Delta$ Populist Seat Share" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(d_populistparty d_l_populistpresence d_populist_new ///
		  d_l_populistvoteshare d_l_populistseatshare) ///
	s(fixed r2 N, ///
	label("Country / Year Fixed Effects" "R\textsuperscript{2}" "N")) ///
	star(+ 0.1 * 0.05)	

* Table 1 (Level, PW period fixed effects) -------------------------------------------

local ivs populistparty l_populistpresence populist_new l_populistvoteshare l_populistseatshare
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local year 1990

eststo clear
cap drop pred*

eststo m1: xtpcse turnout populistparty `controls' i.election_period i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m1
replace pred_m1 = round(pred_m1,.01)
regsave populistparty using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "PWFE5", operationalization, "level")

eststo m2: xtpcse turnout l_populistpresence `controls' i.election_period i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m2
replace pred_m2 = round(pred_m2,.01)
regsave l_populistpresence using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "PWFE5", operationalization, "level")	
	
eststo m3: xtpcse turnout populist_new `controls' i.election_period i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m3
replace pred_m3 = round(pred_m3,.01)
regsave populist_new using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "PWFE5", operationalization, "level")
	
eststo m4: xtpcse turnout l_populistvoteshare `controls' i.election_period i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m4
replace pred_m4 = round(pred_m4,.01)
regsave l_populistvoteshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "PWFE5", operationalization, "level")	
	
eststo m5: xtpcse turnout l_populistseatshare `controls' i.election_period i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m5
replace pred_m5 = round(pred_m5,.01)
regsave l_populistseatshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m5", specification, "PWFE5", operationalization, "level")	

* Table A.4
sum pred_m*  // Range of predictions

* Table 1
esttab m1 m2 m3 m4 m5, se keep(`ivs' `controls') ///
	s(fixed r2 N , ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}" "N"))
	
esttab m1 m2 m3 m4 m5 using "tables/t_1_pwfe5_`year'.tex", ///
	se r2 booktabs compress nogaps align(l) b(2) se(2) staraux replace ///
	keep(`ivs' `controls') nomtitles ///
	coeflabels(populistparty "Populist Participation" ///
		   l_populistpresence "Populist Representation" ///
		   populist_new "New Populist Party" ///
		   l_populistvoteshare "Populist Vote Share" ///
		   l_populistseatshare "Populist Seat Share" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(populistparty l_populistpresence populist_new ///
		  l_populistvoteshare l_populistseatshare) ///
	s(fixed r2 N, ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}" "N")) ///
	star(+ 0.1 * 0.05)		
	
* Table 1 (Delta, PW period fixed effects) -------------------------------------

local ivs d_populistparty d_l_populistpresence d_populist_new d_l_populistvoteshare d_l_populistseatshare
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear
cap drop pred*

eststo m1: xtpcse d_turnout d_populistparty `d_controls' i.election_period if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m1
replace pred_m1 = round(pred_m1,.01)
regsave d_populistparty using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "PWFE5", operationalization, "delta")

eststo m2: xtpcse d_turnout d_l_populistpresence `d_controls' i.election_period if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m2
replace pred_m2 = round(pred_m2,.01)
regsave d_l_populistpresence using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "PWFE5", operationalization, "delta")	
	
eststo m3: xtpcse d_turnout d_populist_new `d_controls' i.election_period if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m3
replace pred_m3 = round(pred_m3,.01)
regsave d_populist_new using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "PWFE5", operationalization, "delta")
	
eststo m4: xtpcse d_turnout d_l_populistvoteshare `d_controls' i.election_period if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m4
replace pred_m4 = round(pred_m4,.01)
regsave d_l_populistvoteshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "PWFE5", operationalization, "delta")	
	
eststo m5: xtpcse d_turnout d_l_populistseatshare `d_controls' i.election_period if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m5
replace pred_m5 = round(pred_m5,.01)
regsave d_l_populistseatshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m5", specification, "PWFE5", operationalization, "delta")	

* Table 1
esttab m1 m2 m3 m4 m5, se keep(`ivs' `d_controls') ///
	s(fixed r2 N , ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}" "N"))
	
esttab m1 m2 m3 m4 m5 using "tables/t_1_delta_pwfe5_`year'.tex", ///
	se r2 booktabs compress nogaps align(l) b(2) se(2) staraux replace ///
	keep(`ivs' `d_controls') nomtitles ///
	coeflabels(d_populistparty "$\Delta$ Populist Participation" ///
		   d_l_populistpresence "$\Delta$ Populist Representation" ///
		   d_populist_new "$\Delta$ New Populist Party" ///
		   d_l_populistvoteshare "$\Delta$ Populist Vote Share" ///
		   d_l_populistseatshare "$\Delta$ Populist Seat Share" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(d_populistparty d_l_populistpresence d_populist_new ///
		  d_l_populistvoteshare d_l_populistseatshare) ///
	s(fixed r2 N, ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}" "N")) ///
	star(+ 0.1 * 0.05)		
	

* Table 1 (Level, PW year fixed effects) -------------------------------------------

local ivs populistparty l_populistpresence populist_new l_populistvoteshare l_populistseatshare
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local year 1990

eststo clear
cap drop pred*

eststo m1: xtpcse turnout populistparty `controls' i.election_year i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m1
replace pred_m1 = round(pred_m1,.01)
regsave populistparty using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "PWFE", operationalization, "level")

eststo m2: xtpcse turnout l_populistpresence `controls' i.election_year i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m2
replace pred_m2 = round(pred_m2,.01)
regsave l_populistpresence using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "PWFE", operationalization, "level")	
	
eststo m3: xtpcse turnout populist_new `controls' i.election_year i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m3
replace pred_m3 = round(pred_m3,.01)
regsave populist_new using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "PWFE", operationalization, "level")
	
eststo m4: xtpcse turnout l_populistvoteshare `controls' i.election_year i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m4
replace pred_m4 = round(pred_m4,.01)
regsave l_populistvoteshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "PWFE", operationalization, "level")	
	
eststo m5: xtpcse turnout l_populistseatshare `controls' i.election_year i.country_id if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
predict pred_m5
replace pred_m5 = round(pred_m5,.01)
regsave l_populistseatshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m5", specification, "PWFE", operationalization, "level")	

* Table A.4
sum pred_m*  // Range of predictions

* Table 1
esttab m1 m2 m3 m4 m5, se keep(`ivs' `controls') ///
	s(fixed r2 N , ///
	label("Country / Year Fixed Effects" "R\textsuperscript{2}" "N"))
	
esttab m1 m2 m3 m4 m5 using "tables/t_1_pwfe_`year'.tex", ///
	se r2 booktabs compress nogaps align(l) b(2) se(2) staraux replace ///
	keep(`ivs' `controls') nomtitles ///
	coeflabels(populistparty "Populist Participation" ///
		   l_populistpresence "Populist Representation" ///
		   populist_new "New Populist Party" ///
		   l_populistvoteshare "Populist Vote Share" ///
		   l_populistseatshare "Populist Seat Share" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(populistparty l_populistpresence populist_new ///
		  l_populistvoteshare l_populistseatshare) ///
	s(fixed r2 N, ///
	label("Country / Year Fixed Effects" "R\textsuperscript{2}" "N")) ///
	star(+ 0.1 * 0.05)		
	
* Table 1 (Delta, PW year fixed effects) -------------------------------------

local ivs d_populistparty d_l_populistpresence d_populist_new d_l_populistvoteshare d_l_populistseatshare
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear
cap drop pred*

eststo m1: xtpcse d_turnout d_populistparty `d_controls' i.election_year if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m1
replace pred_m1 = round(pred_m1,.01)
regsave d_populistparty using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "PWFE", operationalization, "delta")

eststo m2: xtpcse d_turnout d_l_populistpresence `d_controls' i.election_year if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m2
replace pred_m2 = round(pred_m2,.01)
regsave d_l_populistpresence using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "PWFE", operationalization, "delta")	
	
eststo m3: xtpcse d_turnout d_populist_new `d_controls' i.election_year if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m3
replace pred_m3 = round(pred_m3,.01)
regsave d_populist_new using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "PWFE", operationalization, "delta")
	
eststo m4: xtpcse d_turnout d_l_populistvoteshare `d_controls' i.election_year if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m4
replace pred_m4 = round(pred_m4,.01)
regsave d_l_populistvoteshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "PWFE", operationalization, "delta")	
	
eststo m5: xtpcse d_turnout d_l_populistseatshare `d_controls' i.election_year if election_year >= `year', correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
predict pred_m5
replace pred_m5 = round(pred_m5,.01)
regsave d_l_populistseatshare using "models/figure1_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m5", specification, "PWFE", operationalization, "delta")	

* Table 1
esttab m1 m2 m3 m4 m5, se keep(`ivs' `d_controls') ///
	s(fixed r2 N , ///
	label("Country / Year Fixed Effects" "R\textsuperscript{2}" "N"))
	
esttab m1 m2 m3 m4 m5 using "tables/t_1_delta_pwfe_`year'.tex", ///
	se r2 booktabs compress nogaps align(l) b(2) se(2) staraux replace ///
	keep(`ivs' `d_controls') nomtitles ///
	coeflabels(d_populistparty "$\Delta$ Populist Participation" ///
		   d_l_populistpresence "$\Delta$ Populist Representation" ///
		   d_populist_new "$\Delta$ New Populist Party" ///
		   d_l_populistvoteshare "$\Delta$ Populist Vote Share" ///
		   d_l_populistseatshare "$\Delta$ Populist Seat Share" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(d_populistparty d_l_populistpresence d_populist_new ///
		  d_l_populistvoteshare d_l_populistseatshare) ///
	s(fixed r2 N, ///
	label("Country / Year Fixed Effects" "R\textsuperscript{2}" "N")) ///
	star(+ 0.1 * 0.05)			

* ------------------------------------------------------------------------------
* Figure 2
* ------------------------------------------------------------------------------

* 5FE

local ivs l_populistpresence d_l_populistpresence
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear
cap drop pred*

eststo m1: xtreg turnout l_populistpresence `controls' i.election_period if election_year >= `year' & poco == 1, fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence using "models/figure2_`year'.dta", ci replace saveold(12) ///
	addlabel(model, "m1", specification, "FE5", subsample, "west")

eststo m2: reg d_turnout d_l_populistpresence `d_controls' i.election_period if election_year >= `year' & poco == 1, cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "FE5", subsample, "west")
	
eststo m3: xtreg turnout l_populistpresence `controls' i.election_period if election_year >= `year' & poco == 2, fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "FE5", subsample, "east")

eststo m4: reg d_turnout d_l_populistpresence `d_controls' i.election_period if election_year >= `year' & poco == 2, cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "FE5", subsample, "east")	

esttab m1 m2 m3 m4, se keep(`ivs' `controls' `d_controls') 

esttab m1 m2 m3 m4 using "tables/t_f2_`year'.tex", ///
	se r2 booktabs b(2) se(2) staraux replace ///
	keep(`ivs' `controls' `d_controls') ///
	mtitles("Turnout" "$\Delta$ Turnout" "Turnout" "$\Delta$ Turnout") ///
	coeflabels(populistparty "Populist Participation" ///
		   d_populistparty "$\Delta$ Populist Participation" ///
		   l_populistpresence "Populist Representation" ///
		   d_l_populistpresence "$\Delta$ Populist Representation" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(l_populistpresence d_l_populistpresence) ///
	s(fixed r2 N, ///
	label("Country / Period Fixed Effects" "R\textsuperscript{2}")) ///
	star(+ 0.1 * 0.05)

* 2FE

local ivs l_populistpresence d_l_populistpresence
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear

eststo m1: xtreg turnout l_populistpresence `controls' i.election_year if election_year >= `year' & poco == 1, fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "FE", subsample, "west")

eststo m2: reg d_turnout d_l_populistpresence `d_controls' i.election_year if election_year >= `year' & poco == 1, cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "FE", subsample, "west")

eststo m3: xtreg turnout l_populistpresence `controls' i.election_year if election_year >= `year' & poco == 2, fe cluster(country_id)
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "FE", subsample, "east")

eststo m4: reg d_turnout d_l_populistpresence `d_controls' i.election_year if election_year >= `year' & poco == 2, cluster(country_id)
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "FE", subsample, "east")

esttab m1 m2 m3 m4, se keep(`ivs' `controls' `d_controls') 

esttab m1 m2 m3 m4 using "tables/t_f2_fe_`year'.tex", ///
	se r2 booktabs b(2) se(2) staraux replace ///
	keep(`ivs' `controls' `d_controls') ///
	mtitles("Turnout" "$\Delta$ Turnout" "Turnout" "$\Delta$ Turnout") ///
	coeflabels(populistparty "Populist Participation" ///
		   d_populistparty "$\Delta$ Populist Participation" ///
		   l_populistpresence "Populist Representation" ///
		   d_l_populistpresence "$\Delta$ Populist Representation" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(l_populistpresence d_l_populistpresence) ///
	s(fixed r2 N, label("Country / Year Fixed Effects" "R\textsuperscript{2}"))


* PWFE5

local ivs l_populistpresence d_l_populistpresence
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear

eststo m1: xtpcse turnout l_populistpresence `controls' i.election_period i.country_id if election_year >= `year' & poco == 1, correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "PWFE5", subsample, "west")
	
eststo m2: xtpcse d_turnout d_l_populistpresence `d_controls' i.election_period if election_year >= `year' & poco == 1, correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "PWFE5", subsample, "west")
	
eststo m3: xtpcse turnout l_populistpresence `controls' i.election_period i.country_id if election_year >= `year' & poco == 2, correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "PWFE5", subsample, "east")
	
eststo m4: xtpcse d_turnout d_l_populistpresence `d_controls' i.election_period if election_year >= `year' & poco == 2, correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "PWFE5", subsample, "east")	
	
esttab m1 m2 m3 m4, se keep(`ivs' `controls' `d_controls') 

esttab m1 m2 m3 m4 using "tables/t_f2_pwfe5_`year'.tex", ///
	se r2 booktabs b(2) se(2) staraux replace ///
	keep(`ivs' `controls' `d_controls') ///
	mtitles("Turnout" "$\Delta$ Turnout" "Turnout" "$\Delta$ Turnout") ///
	coeflabels(populistparty "Populist Participation" ///
		   d_populistparty "$\Delta$ Populist Participation" ///
		   l_populistpresence "Populist Representation" ///
		   d_l_populistpresence "$\Delta$ Populist Representation" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(l_populistpresence d_l_populistpresence) ///
	s(fixed r2 N, label("Country / Period Fixed Effects" "R\textsuperscript{2}"))


* PW2FE

local ivs l_populistpresence d_l_populistpresence
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear

eststo m1: xtpcse turnout l_populistpresence `controls' i.election_year i.country_id if election_year >= `year' & poco == 1, correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "PWFE", subsample, "west")

eststo m2: xtpcse d_turnout d_l_populistpresence `d_controls' i.election_year if election_year >= `year' & poco == 1, correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "PWFE", subsample, "west")
	
eststo m3: xtpcse turnout l_populistpresence `controls' i.election_year i.country_id if election_year >= `year' & poco == 2, correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "PWFE", subsample, "east")

eststo m4: xtpcse d_turnout d_l_populistpresence `d_controls' i.election_year if election_year >= `year' & poco == 2, correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence using "models/figure2_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "PWFE", subsample, "east")	

esttab m1 m2 m3 m4, se keep(`ivs' `controls' `d_controls') 

esttab m1 m2 m3 m4 using "tables/t_f2_pwfe_`year'.tex", ///
	se r2 booktabs b(2) se(2) staraux replace ///
	keep(`ivs' `controls' `d_controls') ///
	mtitles("Turnout" "$\Delta$ Turnout" "Turnout" "$\Delta$ Turnout") ///
	coeflabels(populistparty "Populist Participation" ///
		   d_populistparty "$\Delta$ Populist Participation" ///
		   l_populistpresence "Populist Representation" ///
		   d_l_populistpresence "$\Delta$ Populist Representation" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(l_populistpresence d_l_populistpresence) ///
	s(fixed r2 N, label("Country / Year Fixed Effects" "R\textsuperscript{2}"))
	

* ------------------------------------------------------------------------------
* Figure 3
* ------------------------------------------------------------------------------	
	  
* 5FE

local ivs l_populistpresence_left l_populistpresence_right ///
	d_l_populistpresence_left d_l_populistpresence_right
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear

eststo m1: xtreg turnout l_populistpresence_left l_populistpresence_right `controls' i.election_period if election_year >= `year' & poco == 1, fe cluster(country_id)
estadd local fixed "\cmark / \cmark / \cmark", replace
regsave l_populistpresence_left l_populistpresence_right using "models/figure3_`year'.dta", ci replace saveold(12) ///
	addlabel(model, "m1", specification, "FE5", subsample, "west")

eststo m2: reg d_turnout d_l_populistpresence_left d_l_populistpresence_right `d_controls' i.election_period if election_year >= `year' & poco == 1, cluster(country_id)
estadd local fixed "\cmark / \xmark / \cmark", replace
regsave d_l_populistpresence_left d_l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "FE5", subsample, "west") 

eststo m3: xtreg turnout l_populistpresence_left l_populistpresence_right `controls' i.election_period if election_year >= `year' & poco == 2, fe cluster(country_id)
estadd local fixed "\cmark / \cmark / \cmark", replace
regsave l_populistpresence_left l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "FE5", subsample, "east")

eststo m4: reg d_turnout d_l_populistpresence_left d_l_populistpresence_right `d_controls' i.election_period if election_year >= `year' & poco == 2, cluster(country_id)
estadd local fixed "\cmark / \xmark / \cmark", replace
regsave d_l_populistpresence_left d_l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "FE5", subsample, "east")

esttab m1 m2 m3 m4, se keep(`ivs')	 

esttab m1 m2 m3 m4 using "tables/t_f3_`year'.tex", ///
	se r2 booktabs b(2) se(2) staraux replace ///
	keep(`ivs') ///
	mtitles("Turnout" "$\Delta$ Turnout" "Turnout" "$\Delta$ Turnout") ///
	coeflabels(populistparty_left "Populist Participation (Left)" ///
		   populistparty_right "Populist Participation (Right)" ///
		   d_populistparty_left "$\Delta$ Populist Participation (Left)" ///
		   d_populistparty_right "$\Delta$ Populist Participation (Right)" ///
		   l_populistpresence_left "Populist Representation (Left)" ///
		   l_populistpresence_right "Populist Representation (Right)" ///
		   d_l_populistpresence_left "$\Delta$ Populist Representation (Left)" ///
		   d_l_populistpresence_right "$\Delta$ Populist Representation (Right)" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(l_populistpresence_left l_populistpresence_right ///
	      d_l_populistpresence_left d_l_populistpresence_right) ///
	      s(fixed r2 N, label("Controls / Country FE / Period FE" "R\textsuperscript{2}"))  
	
	      
* 2FE

local ivs l_populistpresence_left l_populistpresence_right ///
	d_l_populistpresence_left d_l_populistpresence_right 
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear

eststo m1: xtreg turnout l_populistpresence_left l_populistpresence_right `controls' i.election_year if election_year >= `year' & poco == 1, fe cluster(country_id)
estadd local fixed "\cmark / \cmark / \cmark", replace
regsave l_populistpresence_left l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "FE2", subsample, "west")

eststo m2: reg d_turnout d_l_populistpresence_left d_l_populistpresence_right `d_controls' i.election_year if election_year >= `year' & poco == 1, cluster(country_id)
estadd local fixed "\cmark / \xmark / \cmark", replace
regsave d_l_populistpresence_left d_l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "FE2", subsample, "west") 
	
eststo m3: xtreg turnout l_populistpresence_left l_populistpresence_right `controls' i.election_year if election_year >= `year' & poco == 2, fe cluster(country_id)
estadd local fixed "\cmark / \cmark / \cmark", replace
regsave l_populistpresence_left l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "FE2", subsample, "east")

eststo m4: reg d_turnout d_l_populistpresence_left d_l_populistpresence_right `d_controls' i.election_year if election_year >= `year' & poco == 2, cluster(country_id)
estadd local fixed "\cmark / \xmark / \cmark", replace
regsave d_l_populistpresence_left d_l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "FE2", subsample, "east") 	

esttab m1 m2 m3 m4, se keep(`ivs' `controls' `d_controls')	 

esttab m1 m2 m3 m4 using "tables/t_f3_fe_`year'.tex", ///
	se r2 booktabs b(2) se(2) staraux replace ///
	keep(`ivs') ///
	mtitles("Turnout" "$\Delta$ Turnout" "Turnout" "$\Delta$ Turnout") ///
	coeflabels(populistparty_left "Populist Participation (Left)" ///
		   populistparty_right "Populist Participation (Right)" ///
		   d_populistparty_left "$\Delta$ Populist Participation (Left)" ///
		   d_populistparty_right "$\Delta$ Populist Participation (Right)" ///
		   l_populistpresence_left "Populist Representation (Left)" ///
		   l_populistpresence_right "Populist Representation (Right)" ///
		   d_l_populistpresence_left "$\Delta$ Populist Representation (Left)" ///
		   d_l_populistpresence_right "$\Delta$ Populist Representation (Right)" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(l_populistpresence_left l_populistpresence_right ///
	      d_l_populistpresence_left d_l_populistpresence_right) ///
	      s(fixed r2 N, label("Controls / Country FE / Year FE" "R\textsuperscript{2}"))  	      
	      
* PW5FE

local ivs l_populistpresence_left l_populistpresence_right ///
	d_l_populistpresence_left d_l_populistpresence_right
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear

eststo m1: xtpcse turnout l_populistpresence_left l_populistpresence_right `controls' i.election_period i.country_id if election_year >= `year' & poco == 1, correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence_left l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "PWFE5", subsample, "west")

eststo m2: xtpcse d_turnout d_l_populistpresence_left d_l_populistpresence_right `d_controls' i.election_period if election_year >= `year' & poco == 1, correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence_left d_l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "PWFE5", subsample, "west")

eststo m3: xtpcse turnout l_populistpresence_left l_populistpresence_right `controls' i.election_period i.country_id if election_year >= `year' & poco == 2, correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence_left l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "PWFE5", subsample, "east")

eststo m4: xtpcse d_turnout d_l_populistpresence_left d_l_populistpresence_right `d_controls' i.election_period if election_year >= `year' & poco == 2, correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence_left d_l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "PWFE5", subsample, "east")
	
esttab m1 m2 m3 m4, se keep(`ivs' `controls' `d_controls') 

esttab m1 m2 m3 m4 using "tables/t_f3_pwfe5_`year'.tex", ///
	se r2 booktabs b(2) se(2) staraux replace ///
	keep(`ivs') ///
	mtitles("Turnout" "$\Delta$ Turnout" "Turnout" "$\Delta$ Turnout") ///
	coeflabels(populistparty_left "Populist Participation (Left)" ///
		   populistparty_right "Populist Participation (Right)" ///
		   d_populistparty_left "$\Delta$ Populist Participation (Left)" ///
		   d_populistparty_right "$\Delta$ Populist Participation (Right)" ///
		   l_populistpresence_left "Populist Representation (Left)" ///
		   l_populistpresence_right "Populist Representation (Right)" ///
		   d_l_populistpresence_left "$\Delta$ Populist Representation (Left)" ///
		   d_l_populistpresence_right "$\Delta$ Populist Representation (Right)" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(populistparty d_populistparty ///
	      l_populistpresence d_l_populistpresence) ///
	s(fixed r2 N, label("Country / Period Fixed Effects" "R\textsuperscript{2}"))

* PW2FE

local ivs l_populistpresence_left l_populistpresence_right ///
	d_l_populistpresence_left d_l_populistpresence_right
local controls enp_seats unemp openc population_mio compulsory_voting pr log_tier1_avemag log_margin
local d_controls d_enp_seats d_unemp d_openc d_population_mio d_compulsory_voting d_pr d_log_tier1_avemag d_log_margin
local year 1990

eststo clear

eststo m1: xtpcse turnout l_populistpresence_left l_populistpresence_right `controls' i.election_year i.country_id if election_year >= `year' & poco == 1, correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence_left l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m1", specification, "PWFE", subsample, "west")

eststo m2: xtpcse d_turnout d_l_populistpresence_left d_l_populistpresence_right `d_controls' i.election_year if election_year >= `year' & poco == 1, correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence_left d_l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m2", specification, "PWFE", subsample, "west")

eststo m3: xtpcse turnout l_populistpresence_left l_populistpresence_right `controls' i.election_year i.country_id if election_year >= `year' & poco == 2, correlation(psar1) pairwise
estadd local fixed "\cmark / \cmark", replace
regsave l_populistpresence_left l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m3", specification, "PWFE", subsample, "east")

eststo m4: xtpcse d_turnout d_l_populistpresence_left d_l_populistpresence_right `d_controls' i.election_year if election_year >= `year' & poco == 2, correlation(psar1) pairwise
estadd local fixed "\xmark / \cmark", replace
regsave d_l_populistpresence_left d_l_populistpresence_right using "models/figure3_`year'.dta", ci append saveold(12) ///
	addlabel(model, "m4", specification, "PWFE", subsample, "east")
	
esttab m1 m2 m3 m4, se keep(`ivs') 

esttab m1 m2 m3 m4 using "tables/t_f3_pwfe_`year'.tex", ///
	se r2 booktabs b(2) se(2) staraux replace ///
	keep(`ivs') ///
	mtitles("Turnout" "$\Delta$ Turnout" "Turnout" "$\Delta$ Turnout") ///
	coeflabels(populistparty_left "Populist Participation (Left)" ///
		   populistparty_right "Populist Participation (Right)" ///
		   d_populistparty_left "$\Delta$ Populist Participation (Left)" ///
		   d_populistparty_right "$\Delta$ Populist Participation (Right)" ///
		   l_populistpresence_left "Populist Representation (Left)" ///
		   l_populistpresence_right "Populist Representation (Right)" ///
		   d_l_populistpresence_left "$\Delta$ Populist Representation (Left)" ///
		   d_l_populistpresence_right "$\Delta$ Populist Representation (Right)" ///
		   enp_seats "ENPP" d_enp_seats "$\Delta$ ENPP" ///
		   unemp "Unemployment" d_unemp "$\Delta$ Unemployment" ///
		   openc "Trade Openness" d_openc "$\Delta$ Trade Openness" ///
		   population_mio "Population" ///
		   d_population_mio "$\Delta$ Population" ///
		   compulsory_voting "Compulsory Voting" ///
		   d_compulsory_voting "$\Delta$ Compulsory Voting" ///
		   pr "PR" ///
		   d_pr "$\Delta$ PR" ///
		   log_tier1_avemag "log(District Magnitude)" ///
		   d_log_tier1_avemag "$\Delta$ log(District Magnitude)" ///
		   age_of_democracy "Age of Democracy" ///
		   d_age_of_democracy "$\Delta$ Age of Democracy" ///
		   log_margin "log(Electoral Competitiveness)" ///
		   d_log_margin "$\Delta$ log(Electoral Competitiveness)") ///
	order(populistparty d_populistparty ///
	      l_populistpresence d_l_populistpresence) ///
	s(fixed r2 N, label("Country / Year Fixed Effects" "R\textsuperscript{2}"))
