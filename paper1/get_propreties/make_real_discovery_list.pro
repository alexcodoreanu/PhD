pro make_real_discovery_list
	
	real_path = '/lustre/projects/p036_swin/alexc/final_files/correct_precision/corrections_completeness/'

	SOLS = ['S0927',  'U0148', 'S1306',  'U1319']
	redshift_emission = [5.79, 5.98, 5.99, 6.13]

	for s = 0, n_elements(SOLS) - 1 do begin
		real_discovery_name = real_path + SOLS[s] + '_mg2_systems.fits'
		real = mrdfits(real_discovery_name, 1, /silent)
		systems = real[uniq(real.system)].system
		
		for n = 0, n_elements(systems) - 1 do begin
			local_system = systems[n]
			real_index_s3 = where(real.system eq local_system)
			local_index = real_index_s3[0]
			if local_index lt 0.0 then stop
			
			print, SOLS[s], real[local_index].z, real[local_index].SYS_EW, real[local_index].s3, real[local_index].s5
			
		endfor
	endfor
	
	
	
END