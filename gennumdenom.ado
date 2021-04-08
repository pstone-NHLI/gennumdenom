capture program drop gennumdenom
program define gennumdenom
	version 15.0
	
	/* Take a list of variables and create numerator and denominator variables adjacent to them.
	 * Prefix - String to be placed in front of numerator and denominator variables (default = variable name)
	 * Numerators option - If there are multiple numerators, the number of them (the number being that of the highest coded category [must be in sequential order])
	 * By option - Numerators and denominators can be calculated for each of a chosen variable
	 * Zero option - include 0 coded category as one of the numerators
	 * Pc option - Calculate % of denominator for each numerator
	 */
	syntax varlist(max=1) [, PREfix(string) NUMerators(string) BY(string) ZERO PC]
	
	quietly {
	
		foreach var of local varlist {
		
			if "`prefix'" == "" {
				
				local prefix = "`var'"
			}
			
			if "`numerators'" == "" {
				
				local count = 1
			}
			else {
				
				local count = `numerators'
			}
			
			if "`zero'" == "zero" {
				
				local beginning = 0
			}
			else {
			
				local beginning = 1
			}
			
			//------this scenario needs finishing---------
			if "`zero'" == "zero" & "`numerators'" == "" {
				
				noisily display as text "CBA to code this option yet."
				error
			}
			//---------------------------------------------
			
			forvalues i = `beginning'(1)`count' {
				
				tempvar numtemp
				
				if "`by'" != "" {
					
					bysort `by': egen `numtemp' = count(`var') if `var' == `i'
				}
				else {
					
					egen `numtemp' = count(`var') if `var' == `i'
				}
				
				if `count' == 1 {
				
					if "`by'" != "" {
					
						bysort `by': egen `prefix'_nume = max(`numtemp')
					}
					else {
						
						egen `prefix'_nume = max(`numtemp')
					}
					order `prefix'_nume, after(`var')
					replace `prefix'_nume = 0 if `prefix'_nume == .
				}
				else {
					
					if "`by'" != "" {
					
						bysort `by': egen `prefix'_nume`i' = max(`numtemp')
					}
					else {
						
						egen `prefix'_nume`i' = max(`numtemp')
					}
				
					if `i' == `beginning' {
					
						order `prefix'_nume`i', after(`var')
					}
					else {
					
						local previous = `i'-1
						order `prefix'_nume`i', after(`prefix'_nume`previous')
					}
					replace `prefix'_nume`i' = 0 if `prefix'_nume`i' == .
				}
			}
			
			if "`by'" != "" {
			
				bysort `by': egen `prefix'_denom = count(`var')
			}
			else {
			
				egen `prefix'_denom = count(`var')
			}
			
			if `count' == 1 {
			
				order `prefix'_denom, after(`prefix'_nume)
			}
			else {
			
				order `prefix'_denom, after(`prefix'_nume`count')
			}
			
			if "`pc'" == "pc" {
				
				forvalues i = `beginning'(1)`count' {
				
					if `count' == 1 {
			
						gen `prefix'_numpc = round((`prefix'_nume/`prefix'_denom)*100, 0.01)
						order `prefix'_numpc, after(`prefix'_nume)
					}
					else {
					
						gen `prefix'_numpc`i' = round((`prefix'_nume`i'/`prefix'_denom)*100, 0.01)
						order `prefix'_numpc`i', after(`prefix'_nume`i')
					}
				}
			}
		}
	}
end
