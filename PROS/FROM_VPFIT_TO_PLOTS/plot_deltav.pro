
pro plot_deltav

 readcol, 'S0927_nir_up.dat', l, f, e

 continuum = fltarr(n_elements(l))
 continuum[*] = 50.
 
 
 light = 299792.458
 
 
 plot, l, continuum, charsize =2, /nodata
 
 
 for i = 0, n_elements(l) - 2 do begin
	 
	 value = l[i+1] - l[i]
	 
	 velocity = light*value/l[i]
;	 oplot, [l[i], l[i]], [value, value], psym = 3
	 oplot, [l[i], l[i]], [velocity, velocity], psym = 3
	 
	 
	 
 endfor

END
