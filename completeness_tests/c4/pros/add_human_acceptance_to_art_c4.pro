;	take in the split fits and compute the S/N 
;	as well as the user_success and user_failure
;   value associated with the detection (or non-detection)
;   it will take in the split file
;
pro add_human_acceptance_to_art_c4, cd_index

fits_input_path = '/lustre/projects/p036_swin/alexc/completeness_test/c4/fits/'

column_density_range = dindgen(20)/10 + 12.5
column_density_range = column_density_range[cd_index]
cd_string = strmid(strtrim(string(cd_index),1),0,1)
if cd_index gt 9.0 then cd_string = strmid(strtrim(string(cd_index),1),0,2)
cd_index_string = strmid(strtrim(string(cd_index),1),0,1)
if cd_index gt 9.0 then cd_index_string = strmid(strtrim(string(cd_index),1),0,2)


input_fits_name = fits_input_path + 'c4_artificial_single_profiles_' + cd_index_string + '.fits'
input_fits = mrdfits(input_fits_name, 1)

c4_1548 = 1548.2049
c4_1553 = 1553.77845


completeness_results_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/real_mg2_results/'
output_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/corrections_completeness/completeness_fits/'

SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
redshift_emission = [5.79, 5.98, 5.99, 6.13]

;	output fits
str = {c_d:0.0, $
	   b:0.0, $
	   z:0.0, $
	   sn1548:0.0, $
	   sn1553:0.0, $
	   sol:' ', $
	   user_success_1548:0.0, $
	   user_failure_1548:0.0, $
	   user_success_1553:0.0, $
	   user_failure_1553:0.0}

output_fits = replicate(str, n_elements(SOLS)*n_elements(input_fits.b))
output_name = fits_input_path + 'art_c4_human_acc_fail_' + cd_index_string + '.fits'
	  			          

local_counter = 0.0
for s = 0, n_elements(SOLS) - 1 do begin
	SOL = SOLS[s]
	sol_string = strmid(strtrim(string(s), 1),0, 1)
	;	read in the original spectra with the correct precision
		original_file = "/lustre/projects/p036_swin/alexc/final_files/correct_precision/" + $
						SOL + "/" + SOL + "_combined_spectra.dat"
		readcol, original_file, l, f, e, v, format=('D, D, D, D'), /silent
	
		for i = 0, n_elements(input_fits.z) - 1 do begin
			vpf = input_fits[i].vp
			artificial_vpf    = fltarr(n_elements(vpf))
			artificial_vpf[*] = 1.0
		
			;	find the second feature of the doublet
			doublet_index = where(vpf lt 0.9999)
			doublet_index_diff = fltarr(n_elements(doublet_index) - 1)
		
				for doublet_index_iter = 0, n_elements(doublet_index)-2 do begin
					doublet_index_diff[doublet_index_iter] = $
						doublet_index[doublet_index_iter + 1] - doublet_index[doublet_index_iter]
		
				endfor
				;stop
			doublet_index_break = where(doublet_index_diff gt 1.0)

			;	c41548 feature only 
				vp1548     = vpf[doublet_index[0:doublet_index_break]]
				flux1548   = f[doublet_index[0:doublet_index_break]]
				error1548  = e[doublet_index[0:doublet_index_break]]
				lambda1548 = l[doublet_index[0:doublet_index_break]]
			
				intflux1548 = flux1548*vp1548
				sn1548 = total(1.0 - intflux1548)/total(error1548)
				if sn1548 lt 0.0 then sn1548 = 0.0
			
				failure1548 = 0.04*sn1548 -0.001
				if sn1548 ge 5.304 then failure1548 = -1.0*0.029*sn1548 + 0.365
				if failure1548 lt 0.0 then failure1548 = 0.0
				
				
			;	c41553 feature only 
				vp1553     = vpf[doublet_index[doublet_index_break + 1:n_elements(doublet_index) - 1]]
				flux1553   = f[doublet_index[doublet_index_break + 1:n_elements(doublet_index) - 1]]
				error1553  = e[doublet_index[doublet_index_break + 1:n_elements(doublet_index) - 1]]
				lambda1553 = l[doublet_index[doublet_index_break + 1:n_elements(doublet_index) - 1]]
			
				intflux1553 = flux1553*vp1553
				sn1553 = total(1.0 - intflux1553)/total(error1553)
				if sn1553 lt 0.0 then sn1553 = 0.0
			
				failure1553 = 0.04*sn1553 -0.001
				if sn1553 ge 5.304 then failure1553 = -1.0*0.029*sn1553 + 0.365
				if failure1553 lt 0.0 then failure1553 = 0.0
			
			output_fits[local_counter].c_d = input_fits[i].c_d
			output_fits[local_counter].b = input_fits[i].b
			output_fits[local_counter].z = input_fits[i].z
			output_fits[local_counter].sn1548 = sn1548
			output_fits[local_counter].sn1553 = sn1553
			output_fits[local_counter].sol = SOL
			
			output_fits[local_counter].user_success_1548 = 0.988*(1.0 -exp(-1.0*sn1548/0.93))
			output_fits[local_counter].user_failure_1548 = failure1548
			
			output_fits[local_counter].user_success_1553 = 0.988*(1.0 -exp(-1.0*sn1553/0.93))
			output_fits[local_counter].user_failure_1553 = failure1553
		
			local_counter = local_counter + 1.0
			
			print, s, i, local_counter
		
	endfor
endfor

;	rewrite the fits
mwrfits, output_fits, output_name, /create
print, output_name



END
