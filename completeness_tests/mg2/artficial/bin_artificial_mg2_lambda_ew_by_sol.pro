;
;
;
;
;	from split to binned
;
;
;
;
;
pro bin_artificial_mg2_lambda_ew_by_sol, index

	fits_path = '/lustre/projects/p036_swin/alexc/completeness_test/mg2/artificial_mg2_results/'
	pixels = [5, 9, 13]
	pixels = [5]
	
	ew_bins = dindgen(101.)/100.
	str = {$
		EW:0.0, $
		INDEX:0.0, $
		PIXELS:0.0, $
		LAMBDA:0.0, $
		SIGMA5:0.0, $
		SIGMA3:0.0, $
		SN2796:0.0, $
		SN2803:0.0, $
		EW2796:0.0, $
		EW2803:0.0, $
		ERR2796:0.0, $
		ERR2803:0.0, $
		user_success_2796_3s:0.0, $
		user_failure_2796_3s:0.0, $
		user_success_2803_3s:0.0, $
		user_failure_2803_3s:0.0, $
		user_success_2796_5s:0.0, $
		user_failure_2796_5s:0.0, $
		user_success_2803_5s:0.0, $
		user_failure_2803_5s:0.0}


diff = 0.005
z = 0
batch_index = strmid(strtrim(string(pixels[z]), 1),0, 1)
if pixels[z] gt 9 then batch_index = strmid(strtrim(string(pixels[z]), 1),0, 2)

print, z, index,'   ',  systime()
index_string = strmid(strtrim(string(index), 1),0, 1)	

output_structure = replicate(str, 100000.000)
output_structure[*].LAMBDA = 0.0
output_name = fits_path + "binned_ew_0d01_l_28A_" + batch_index + "_" + index_string + ".fits"


input_name = fits_path + "split_with_human_acceptance_" + batch_index + "_" + index_string + ".fits"
split_file = mrdfits(input_name, 1)


;	now put the selection criteria on the split file for 3 and 5 sigma
;	SN2796 or SN 2803 ge 3 or 5
;	0.4 le (ew2796+err2796)/(ew2803+err2803) le 3.5
;						   or
;	0.4 le (ew2796-err2796)/(ew2803-err2803) le 3.5
upper_ratio = (split_file.ew2796+split_file.err2796)/(split_file.ew2803+split_file.err2803)
lower_ratio = (split_file.ew2796-split_file.err2796)/(split_file.ew2803-split_file.err2803)

snindex3 = where(split_file.SN2796 ge 3.0 or split_file.SN2803 ge 3.0)
snindex5 = where(split_file.SN2796 ge 5.0 or split_file.SN2803 ge 5.0)

select3_index = where(upper_ratio[snindex3] ge 0.4 and upper_ratio[snindex3] le 3.5)
split_file[snindex3[select3_index]].sigma3 = 1.0

select3_index = where(upper_ratio[snindex3] ge 0.4 and upper_ratio[snindex3] le 3.5)
split_file[snindex3[select3_index]].sigma3 = 1.0

select5_index = where(upper_ratio[snindex5] ge 0.4 and upper_ratio[snindex5] le 3.5)
split_file[snindex5[select5_index]].sigma5 = 1.0

check_index = where(split_file.lambda gt 7000)


local_file = split_file[check_index]

lambda_min = min(local_file.lambda)
lambda_max = max(local_file.lambda)

lambda_steps = uint((lambda_max-lambda_min)/28.)
lambda_bins = lambda_min + dindgen(lambda_steps)*28.
	
local_counter = 0.0
for e = 0, n_elements(ew_bins) - 2 do begin
	ew_index = where(local_file.ew gt (ew_bins[e] - diff) and local_file.ew lt (ew_bins[e+1]))

	for l = 0, n_elements(lambda_bins) - 2 do begin
		print, e, l
		lambda_index = where(local_file[ew_index].lambda gt lambda_bins[l] and local_file[ew_index].lambda le lambda_bins[l + 1])
		if lambda_index[0] lt 0 then stop

		output_structure[local_counter].EW = ew_bins[e]
		output_structure[local_counter].INDEX = index
		output_structure[local_counter].PIXELS = pixels[z]
		output_structure[local_counter].LAMBDA = lambda_bins[l]
		output_structure[local_counter].SIGMA5 = total(local_file[ew_index[lambda_index]].sigma5)/n_elements(lambda_index)
		output_structure[local_counter].SIGMA3 = total(local_file[ew_index[lambda_index]].sigma3)/n_elements(lambda_index)
		
		output_structure[local_counter].SN2796 = total(local_file[ew_index[lambda_index]].SN2796)/n_elements(lambda_index)
		output_structure[local_counter].SN2803 = total(local_file[ew_index[lambda_index]].SN2803)/n_elements(lambda_index)
		output_structure[local_counter].EW2796 = total(local_file[ew_index[lambda_index]].EW2796)/n_elements(lambda_index)
		output_structure[local_counter].EW2803 = total(local_file[ew_index[lambda_index]].EW2803)/n_elements(lambda_index)
		output_structure[local_counter].ERR2796 = total(local_file[ew_index[lambda_index]].ERR2796)/n_elements(lambda_index)
		output_structure[local_counter].ERR2803 = total(local_file[ew_index[lambda_index]].ERR2803)/n_elements(lambda_index)
		
		output_structure[local_counter].USER_SUCCESS_2796_3s = total(local_file[ew_index[lambda_index]].USER_SUCCESS_2796_3s)/n_elements(lambda_index)
		output_structure[local_counter].USER_FAILURE_2796_3s = total(local_file[ew_index[lambda_index]].USER_FAILURE_2796_3s)/n_elements(lambda_index)
		output_structure[local_counter].USER_SUCCESS_2803_3s = total(local_file[ew_index[lambda_index]].USER_SUCCESS_2803_3s)/n_elements(lambda_index)
		output_structure[local_counter].USER_FAILURE_2803_3s = total(local_file[ew_index[lambda_index]].USER_FAILURE_2803_3s)/n_elements(lambda_index)

		output_structure[local_counter].USER_SUCCESS_2796_5s = total(local_file[ew_index[lambda_index]].USER_SUCCESS_2796_5s)/n_elements(lambda_index)
		output_structure[local_counter].USER_FAILURE_2796_5s = total(local_file[ew_index[lambda_index]].USER_FAILURE_2796_5s)/n_elements(lambda_index)
		output_structure[local_counter].USER_SUCCESS_2803_5s = total(local_file[ew_index[lambda_index]].USER_SUCCESS_2803_5s)/n_elements(lambda_index)
		output_structure[local_counter].USER_FAILURE_2803_5s = total(local_file[ew_index[lambda_index]].USER_FAILURE_2803_5s)/n_elements(lambda_index)

		local_counter = local_counter + 1.0
		
		
	endfor
endfor

non_zero_index = where(output_structure.lambda gt 70)
mwrfits, output_structure[non_zero_index], output_name, /create
print, output_name
			


END
