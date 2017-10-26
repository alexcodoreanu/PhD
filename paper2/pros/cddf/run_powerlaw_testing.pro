pro run_powerlaw_testing

ion = 'mg2'
N0 = 0.0

zbin_bound_low  = [2.00,  3.00,  4.00,  4.33]
zbin_bound_high = [3.00,  4.00,  5.45,  5.45]
mincd = [12.0, 12.0, 12.0, 12.0]
path = [13.6980979692, 15.0932703536, 24.8372040807, 19.4755618242]

	for z = 0, n_elements(zbin_bound_low) - 1 do begin
	 run_ml_powerlaw_testing_new_mincd, path[z], zbin_bound_low[z], zbin_bound_high[z], ion, mincd[z], N0

	endfor




END