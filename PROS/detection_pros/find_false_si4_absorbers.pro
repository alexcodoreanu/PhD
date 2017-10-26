
;	This .pro takes in the fits result output from 
;	find_absorbers.pro and searches for possible
;	magnesium doublets.
;
;	The output is a .fits file which holds all of the
;	systems identified
;
function find_false_si4_absorbers, total_lambda, total_flux, total_error, pass_redshift, pass_sigma

a=find_absorbers(total_lambda, total_flux, total_error, pass_redshift, pass_sigma)

	si4_1393 = 1393.76018
	si4_1402 = (1402.77291 - si4_1393)*2. + si4_1393

check_array = fltarr(2, n_elements(a.lambda))
check_array[*, *] = -99.0



for i = 1, n_elements(a.lambda)-2 do begin

	if a.flux[i] lt 1.0 then begin
	 if a.flux[i-1] lt 1.0 then begin
		 if a.flux[i+1] lt 1.0 then begin
			 
			 delta_lambda = a.lambda[i+1] - a.lambda[i]
		 
			 ;	identify redshift of feature 
			 redshift = [a.lambda[i-1], a.lambda[i],a.lambda[i+1]]/si4_1393 - 1

			 ;	get the location of where MgII 2803 should be at
			 lambda_location = si4_1402*(1.0 +  redshift)

		     ;      check that lambda_location exists in a.lambda
			 local_check = value_locate(a.lambda, lambda_location)
			 difference =  a.lambda[local_check] - lambda_location
		 
				if a.flux[local_check[0]] lt 1.0 then begin
					if a.flux[local_check[1]] lt 1.0 then begin
						if a.flux[local_check[2]] lt 1.0 then begin
							
							sum_1393 = (1.0 - a.flux[i-1])+(1.0 - a.flux[i]) + (1.0 - a.flux[i+1])
					
							sum_1402 = (1.0 - a.flux[local_check[0]]) + $
									   (1.0 - a.flux[local_check[1]]) + $
									   (1.0 - a.flux[local_check[2]])

							check_array[0, i] = 0.0
							check_array[1, i] = redshift[1]
	
							endif 
						endif
					endif
			endif
		endif
	endif
endfor


;	identify systems by taking looking for sequencial index values
	id_index=where(check_array[0, *] eq 0.0)
	redshift_array=fltarr(n_elements(id_index))
	redshift_array=check_array[1, id_index]


	systems_array=fltarr(n_elements(id_index))
	systems_array[*]=-99.00
	systems_array[0] = 0.0
	count=0.0

 
 ;	the problem now is that large features are not recognized as single systems
 for i = 0, n_elements(id_index)-1 do begin
	  check_infinte_loop = 0.0
	 if i eq n_elements(id_index)-1 then begin
		 i = i-1
		 check_infinte_loop = 1.0
	 endif
	
	 if systems_array[i+1] lt 0.0 then begin
		 
	 	x=i
	    difference=id_index[x+1]-id_index[x]
	 
	 		while(difference eq 1) do begin
				systems_array[x]=count
				
				; this accounts for the fact that id_index might be the last value
				if x lt n_elements(id_index) - 1 then begin
					systems_array[x+1]=count
				
						if x lt n_elements(id_index) - 1 then begin
							x=x+1
							if x lt n_elements(id_index) - 1 then begin
								difference=id_index[x+1]-id_index[x]								
							endif
						
							if x eq n_elements(id_index) - 1 then begin
								difference = 0.0
								x = n_elements(id_index) + 1000000
							endif
						
						endif
				endif
		
	 		endwhile
			
		count=count+1.0
		
	 endif
	if  check_infinte_loop eq 1.0 then i=i+1
 endfor
 

 
 ;	this holds all of the uniq ids as defined by count in the above 
 ;	for loop
 	sys_id=uniq(systems_array)
 
 ;	identify the multiple component systems, ie. more than 3 pixels
 	plus_99_id=where(systems_array[sys_id] ge  0.00)
	 systems_id=sys_id[plus_99_id]
 
 ;	individual multiple component systems uniq id's
	multiple_component_systems=systems_array[systems_id]
 
 ;	identify the single component systems, ie. only 3 pixels
	 minus_99_id=where(systems_array eq -99.0)
	 single_component_sytems=systems_array[minus_99_id]


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;	create .fits of individual single component MgII systems
 ;	with redshift, flag, equivalent_width of 2796 and 2803 features 
 ;	and their associated noise profiles
	 str={redshift:0.0, $
 			flag:0.0, $
			num_pixels:0.0, $
			ew1393:0.0, $
			ew1402:0.0, $
			ew1393_err:0.0, $
			ew1402_err:0.0, $
			x_min_1393:0.0, $
			x_max_1393:0.0, $
			x_min_1402:0.0, $
			x_max_1402:0.0}
	 
	 single_component=replicate(str, n_elements(single_component_sytems))
	 multiple_component=replicate(str, n_elements(multiple_component_systems))
 ;	Flag code:
 ;				0 ---- single component feature, ie. only 3 pixel detection
 ;				x-value ---- this represents the associated system id
					    
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;																				     ;
;	Reminder that systems_array and redshift_array have the same index values        ;
;																			    	 ;		
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sorted_index = sort(check_array[1, *])


;	select only single component systems, ie. 3 pixel detections
	 for i = 0, n_elements(single_component_sytems)-1 do begin
	 
		local_index = minus_99_id[i]		
	 	single_component[i].redshift=redshift_array[local_index]
 
		 ;	assign flag value
		 	single_component[i].flag=0.0
 
			EW1393=0.0
			EW1393_ERROR=0.0
			EW1402=0.0
			EW1393_1402=0.0
 
		 ;	find lambda indeces to calculate EW1393
		 	lambda_centerpoint_index_unsorted = value_locate(check_array[1,sorted_index],  single_component[i].redshift)
		 	lambda_centerpoint_index = sorted_index[lambda_centerpoint_index_unsorted]
			lambda_1393_indeces = [lambda_centerpoint_index - 1, lambda_centerpoint_index, lambda_centerpoint_index + 1]
			single_component[i].x_min_1393=a.lambda[lambda_1393_indeces[0]]
	 
	 
		 ;	find lambda indeces to calculate EW1402
		    lambda_1402=(1.0 + single_component[i].redshift) * si4_1402
		    lambda_1402_centerpoint_index=value_locate(a.lambda, lambda_1402)
		    lambda_1402_indeces=[lambda_1402_centerpoint_index-1, lambda_1402_centerpoint_index, lambda_1402_centerpoint_index+1]
		 
		 if lambda_1402_indeces[n_elements(lambda_1402_indeces)-1] ge n_elements(a.lambda) then $
			single_component[i].x_max_1402 = a.lambda[n_elements(a.lambda) - 1]
		 if lambda_1402_indeces[n_elements(lambda_1402_indeces)-1] lt n_elements(a.lambda) then $
		 single_component[i].x_max_1402 = a.lambda[lambda_1402_indeces[n_elements(lambda_1402_indeces)-1]]

	 
		 ;	calculate EW of the features where
		 ;	EW is aproximated by:
		 ;  EW1393 = TOTAL(1.0-a.flux[lambda_1393_indeces])*delta_lambda 
		    delta_lambda = a.lambda[lambda_1393_indeces[1]] - a.lambda[lambda_1393_indeces[0]] 
		    EW1393 = TOTAL(1.0-a.flux[lambda_1393_indeces])*delta_lambda
		    EW1393_ERROR = sqrt(TOTAL(a.error[lambda_1393_indeces]*a.error[lambda_1393_indeces]))*delta_lambda
	    
		    EW1402 = TOTAL(1.0-a.flux[lambda_1402_indeces])*delta_lambda
	 	    EW1402_ERROR = sqrt(TOTAL(a.error[lambda_1402_indeces]*a.error[lambda_1402_indeces]))*delta_lambda
       
		    single_component[i].ew1393 = EW1393
		    single_component[i].ew1393_err = EW1393_ERROR 
		    single_component[i].ew1402 = EW1402
		    single_component[i].ew1402_err = EW1402_ERROR 
       
		    single_component[i].num_pixels=n_elements(lambda_1393_indeces)
	    
	 
		 if a.lambda[lambda_1393_indeces[0]] lt max(a.lambda) then $
			 single_component[i].x_min_1393=a.lambda[lambda_1393_indeces[0]]
		 if a.lambda[lambda_1393_indeces[0]] ge max(a.lambda) then $
			 single_component[i].x_min_1393=max(a.lambda)
 
	 
		 if a.lambda[lambda_1393_indeces[n_elements(lambda_1393_indeces) - 1]] lt max(a.lambda) then $
			 single_component[i].x_max_1393=a.lambda[lambda_1393_indeces[n_elements(lambda_1393_indeces) - 1]]
		 if a.lambda[lambda_1393_indeces[n_elements(lambda_1393_indeces) - 1]] ge max(a.lambda) then $
			 single_component[i].x_max_1393=max(a.lambda)
	
	
	 
		 if a.lambda[lambda_1402_indeces[0]] lt max(a.lambda) then $
			 single_component[i].x_min_1402=a.lambda[0]
		 if a.lambda[lambda_1402_indeces[0]] ge max(a.lambda) then $
			 single_component[i].x_min_1402=max(a.lambda)	
 
		 if a.lambda[lambda_1402_indeces[n_elements(lambda_1402_indeces) - 1]] lt max(a.lambda) then $
			 single_component[i].x_max_1402=a.lambda[lambda_1402_indeces[n_elements(lambda_1402_indeces) - 1]]
		 if a.lambda[lambda_1402_indeces[n_elements(lambda_1402_indeces) - 1]] ge max(a.lambda) then $
			 single_component[i].x_max_1402=max(a.lambda)

	 endfor


 ;	select only larger than 3 pixel systems
	 for i = 0, n_elements(multiple_component_systems)-1 do begin
	 
 
		local_index = plus_99_id[i]
		mc_index = i + n_elements(single_component_sytems)
 
		 ;	assign flag value
		 	multiple_component[i].flag=multiple_component_systems[i]+1
 
	     ;	assign blend check value
	 	 ;	by first identifying the associated pixels +/- in index
		 ; 	as identified by findel in check_array. 
			 EW1393=0.0
			 EW1393_ERROR=0.0
			 EW1402=0.0
			 EW1393_1402=0.0
 
		 ;	identify the number of pixels and their location
		 ;	systems_array will hold the selected systems. 
		 ;	where for multiple_component_systems[i] eq systems_array
		 ;	this is the sub-index of id_index in check_array which has
		 ;	the same indexing as a.lambda and a.flux
		 	sub_index = where(systems_array eq multiple_component_systems[i] )
		 	lambda_1393_indeces = [id_index[sub_index[0]]-1, id_index[sub_index], id_index[sub_index[n_elements(sub_index)-1]] + 1]
 
		 ; the value of the min is -1 of lambda_1393_indeces[0]
     	   x_min_1393_index = lambda_1393_indeces[0] - 1
     	   multiple_component[i].x_min_1393=a.lambda[x_min_1393_index]
     	   multiple_component[i].redshift=multiple_component[i].x_min_1393/si4_1393 - 1.0
 
		 ;	in order to get the 2803 indeces loop through lambda_1402_values
		 	lambda_1402_values = a.lambda[lambda_1393_indeces]*si4_1402/si4_1393
		 	lambda_1402_indeces = fltarr(n_elements(lambda_1402_values))
	 	
			 for x= 0, n_elements(lambda_1402_values)-1 do begin		 
				 local_1402_index= 0.0
				 local_1402_index = value_locate(a.lambda, lambda_1402_values[x])
				 lambda_1402_indeces[x]=local_1402_index	
				 	 
			 endfor
 
		; the value of the min is -1 of lambda_1402_indeces[0]
	      x_max_1402_index = lambda_1402_indeces[0] - 1
		  multiple_component[i].x_max_1402=a.lambda[x_max_1402_index]
			
	    ;	calculate EW of the features where
			EW1393 = TOTAL(1.0-a.flux[lambda_1393_indeces])*delta_lambda
	 	    EW1393_ERROR = sqrt(TOTAL(a.error[lambda_1393_indeces]*a.error[lambda_1393_indeces]))*delta_lambda
		 
			EW1402 = TOTAL(1.0-a.flux[lambda_1402_indeces])*delta_lambda
	  	    EW1402_ERROR = sqrt(TOTAL(a.error[lambda_1402_indeces]*a.error[lambda_1402_indeces]))*delta_lambda

			multiple_component[i].ew1393 = EW1393
			multiple_component[i].ew1393_err = EW1393_ERROR 
			multiple_component[i].ew1402 = EW1402
			multiple_component[i].ew1402_err = EW1402_ERROR 
	 
			multiple_component[i].num_pixels=n_elements(lambda_1393_indeces)
	 
		 if a.lambda[lambda_1393_indeces[0]] lt max(a.lambda) then $
			 multiple_component[i].x_min_1393=a.lambda[lambda_1393_indeces[0]]
		 if a.lambda[lambda_1393_indeces[0]] ge max(a.lambda) then $
			 multiple_component[i].x_min_1393=max(a.lambda)
 
		 if a.lambda[lambda_1393_indeces[n_elements(lambda_1393_indeces) - 1]] lt max(a.lambda) then $
			 multiple_component[i].x_max_1393=a.lambda[lambda_1393_indeces[n_elements(lambda_1393_indeces) - 1]]
		 if a.lambda[lambda_1393_indeces[n_elements(lambda_1393_indeces) - 1]] ge max(a.lambda) then $
			 multiple_component[i].x_max_1393=max(a.lambda)

 
 
		 if a.lambda[lambda_1402_indeces[0]] lt max(a.lambda) then $
			 multiple_component[i].x_min_1402=a.lambda[0]
		 if a.lambda[lambda_1402_indeces[0]] ge max(a.lambda) then $
			 multiple_component[i].x_min_1402=max(a.lambda)	

		 if a.lambda[lambda_1402_indeces[n_elements(lambda_1402_indeces) - 1]] lt max(a.lambda) then $
			 multiple_component[i].x_max_1402=a.lambda[lambda_1402_indeces[n_elements(lambda_1402_indeces) - 1]]
		 if a.lambda[lambda_1402_indeces[n_elements(lambda_1402_indeces) - 1]] ge max(a.lambda) then $
			 multiple_component[i].x_max_1402=max(a.lambda)

	 endfor




total_systems=n_elements(single_component.redshift)+n_elements(multiple_component.redshift)
final_fits=replicate(str, total_systems)

final_fits.redshift = 			[single_component.redshift, multiple_component.redshift]
final_fits.flag = 				[single_component.flag, multiple_component.flag]
final_fits.num_pixels = 		[single_component.num_pixels, multiple_component.num_pixels]
final_fits.ew1393 =				[single_component.ew1393, multiple_component.ew1393]
final_fits.ew1402 = 			[single_component.ew1402, multiple_component.ew1402]
final_fits.ew1402_err = 		[single_component.ew1402_err, multiple_component.ew1402_err]
final_fits.ew1393_err = 		[single_component.ew1393_err, multiple_component.ew1393_err]
final_fits.x_min_1393 =			[single_component.x_min_1393, multiple_component.x_min_1393]
final_fits.x_max_1393 =			[single_component.x_max_1393, multiple_component.x_max_1393]
final_fits.x_min_1402 =			[single_component.x_min_1402, multiple_component.x_min_1402]		
final_fits.x_max_1402 =			[single_component.x_max_1402, multiple_component.x_max_1402]

index = where(final_fits.redshift lt pass_redshift  and $
	          final_fits.ew1393/final_fits.ew1393_err ge pass_sigma or $
			  final_fits.ew1402/final_fits.ew1402_err ge pass_sigma)


return,  final_fits[index]
		
END



