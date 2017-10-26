Function ml_powerlaw_testing_new,data,completeness=completeness,logx_range=logx_range,$
                     	   		     alpha_range=alpha_range,logB_range=logB_range,$
                     	   		     alpha_list=alpha_list,logB_list=logB_list,$
                     	   		     likelihood=likelihood,plot=plot
  
;+------------------------------------------------------------------------
;
; ML_POWERLAW
;
; Estimate power law distribution parameters for a data set using
; maximum likelihood.
;
; Power law form:  P(x) = B * (x/x0)^alpha
;
; Likelikhood function:  L = L_x(alpha) * L_n(alpha,B)
; where L_x = Product of P(x) for each event, and 
;       L_n = Poisson prob of the observed number of events given the
;             expected mean number
; When computing L_x, a value of B is chosen such that the expected
; mean number of events is equal to the observed number.
;
; INPUTS
;        data          - Array of column density values
;
; KEYWORDS
;        completeness  - 2 x n array of completeness information,
;                        where [0,*] is an array of increasing log(x)
;                        values, and [1,*] is the completeness at each
;                        value.  The completeness outside the given
;                        range of x is extrapolated from the ends.
;        logx_range    - 3-element array, [logx_min, logx_max,
;                        log_x0], specifying the range over which to
;                        fit P(x) and the value of x0.  Default is
;                        [13, 15, 13.5].
;        alpha_range   - 2-element array, [alpha_min, alpha_max]
;                        giving the range of exponent values over
;                        which to compute the likelihood function.
;                        Default is [-3,-1].  The sampling within this
;                        range is set (to 0.01) in the program body.
;        logB_range    - 2-element array, [logB_min, logB_max] giving
;                        the range of scaling values over which to
;                        compute the likelihood function.  The default
;                        range is set to +/-1 of the value of logB
;                        that would produce a mean number of events
;                        equal to the observed number for the middle
;                        value of alpha being evaluated.  The sampling
;                        within this range is set (to 0.01) in the
;                        program body.
;        plot          - If set, plot 68%, 95%, and 99% probability
;                        contours.
;        alpha_list    - Returns the list of alpha values over which
;                        likelihood is evaluates
;        logB_list     - Returns the list of logB values over which
;                        likelihood is evaluated
;        likelihood    - Returns two-dimensional normalized likelihood
;                        function, with n_alpha x n_logB elements.
;
; OUTPUTS
;        <result>      - 2-element array with [alpha, logB] at which
;                        likelihood function is maximum
;
; HISTORY
;        Written 10/3/2016 GDB
;-------------------------------------------------------------------------

if (n_params() lt 1) then begin
   print,'CALLING SEQUNCE:  '
   print,'   param_est = ml_powerlaw(data,completeness=completeness,'
   print,'                           logx_range=logx_range,'
   print,'                           alpha_range=alpha_range,'
   print,'                           logB_range=logB_range,'
   print,'                           alpha_list=alpha_list,'
   print,'                           logB_list=logB_list,'
   print,'                           likelihood=likelihood,/plot)'
   return,-1
endif

;; Completenes information

if keyword_set(completeness) then begin
   complete_logx = reform(completeness(0,*))
   complete_x    = 10d^complete_logx
   complete_frac = reform(completeness(1,*))
   do_analytic   = 0
endif else begin
   complete_logx = 0
   complete_x    = 0
   copmlete_frac = 0
   do_analytic   = 1
endelse

;; Range over which to fit powerlaw

if keyword_set(logx_range) then begin
   log_xlo = double(logx_range(0))
   log_xhi = double(logx_range(1))
   log_x0  = double(logx_range(2))
endif else begin
   log_xlo = 13d
   log_xhi = 15d
   log_x0  = 13.5d
endelse
xlo     = 10d^log_xlo
xhi     = 10d^log_xhi
x0      = 10d^log_x0
ylo     = xlo / x0
yhi     = xhi / x0


; Fit only observed data that fall within this range
obs_ls = where(data ge xlo and data le xhi,n_obs)
if (n_obs eq 0) then begin
   print,'No data within range of fit.'
   return,-1
endif
x_obs = data(obs_ls)
y_obs = x_obs / x0
logx_obs = alog10(x_obs)

; Compute n_obs! for evaluating Poisson probabilities
if (n_obs lt 100) then begin
   ln_n_obs_factorial = alog(factorial(n_obs))
endif else begin
   ln_n_obs_factorial = alog(sqrt(2*!dpi*n_obs)) + n_obs*alog(n_obs) - n_obs
endelse

;; Power law exponents to evaluate

if keyword_set(alpha_range) then begin
   alpha_min  = min(alpha_range)
   alpha_max  = max(alpha_range)
endif else begin
   alpha_min  = -3.0
   alpha_max  = -1.0
endelse
alpha_step =  0.01
n_alpha    = (alpha_max-alpha_min)/alpha_step + 1
alpha_list = alpha_min + alpha_step * dindgen(n_alpha)

;; Normalizations to evaluate

; Analytic integration (for reference)
;P = B * (x/x0)^alpha
;n_expect = B Int_xlo^xhi (x/x0)^alpha dx   ; y = x/x0, dy = dx/x0, dx = x0 * dy
;         = B * x0 * Int_ylo^yhi y^alpha dy
;         = B * x0 * (1/(alpha+1)) * [yhi^(alpha+1) - ylo^(alpha+1)]

; Grid in x for integrating P(x)
n_grid     = 1e3
log_x_step = (log_xhi - log_xlo) / n_grid
log_x      = log_xlo + log_x_step*(0.5 + dindgen(n_grid))
x          = 10d^log_x
dx         = alog(10d) * x * log_x_step
if not(do_analytic) then $
   corr    = (0 > interpol(complete_frac,complete_logx,log_x)) < 1


;stop
check_corr = where(finite(corr) eq 0)
if check_corr[0] ge 0 then corr[where(finite(corr) eq 0)] = 0.0000



if keyword_set(logB_range) then begin
   logB_min = min(logB_range)
   logB_max = max(logB_range)
endif else begin
   ; As a starting point, evaluate B such that the expected mean number = the
   ; obs number of data points for the middle value of alpha begin evaluated.
   alpha_start = 0.5*(alpha_min + alpha_max)
   if do_analytic then begin
      ; Analytic integration (no completeness correction)
      B_start  = n_obs / (x0 * (1/(alpha_start+1)) * $
                         (yhi^(alpha_start+1) - ylo^(alpha_start+1)))
   endif else begin
      ; Including completeness correction
      logPdB_nom = alpha_start*(log_x - log_x0)   ; PdB = P divided by B
      PdB_nom    = 10d^logPdB_nom                 ; nom = nominal P w/o complete
      PdB        = PdB_nom * corr
      ndB        = total(PdB*dx)                  ; mean number divided by B
      B_start    = n_obs / ndB
   endelse   
   logB_start = alog10(B_start)
   logB_min   = logB_start - 1.0
   logB_max   = logB_start + 1.0
endelse
;n_logB    = 200d
;logB_step = (logB_max-logB_min)/(n_logB-1)
;logB_list = logB_min + logB_step*dindgen(n_logB)
logB_step =  0.01
n_logB    = (logB_max-logB_min)/logB_step + 1
logB_list = logB_min + logB_step * dindgen(n_logB)

;; Calculate likelihood function for each parameter combination

logL_x = dblarr(n_alpha,n_logB)  ; Product of the likehood of each data point
logL_n = dblarr(n_alpha,n_logB)  ; Poisson prob of the total observed number

for i=0,n_alpha-1 do begin

   for j=0,n_logB-1 do begin

      alpha       = alpha_list(i)
      logB        = logB_list(j)
      B           = 10d^logB

      ; For each pair of parameters, compute probabilities at the
      ; center of a bin in (alpha, logB) space.

      ; L_x: For this alpha, evaluate L_x using normalization such that the
      ; expected number equals the observed number.
      if do_analytic then begin
         B_alpha     = n_obs / (x0 * (1/(alpha+1)) * $
                               (yhi^(alpha+1) - ylo^(alpha+1)))
         logB_alpha  = alog10(B_alpha)
         logP_obs    = logB_alpha + alpha*(logx_obs - log_x0)
      endif else begin
         logPdB_nom = alpha*(log_x - log_x0)
         PdB_nom    = 10d^logPdB_nom
         PdB        = PdB_nom * corr
         ndB        = total(PdB*dx)
         B_alpha    = n_obs / ndB
         P          = PdB * B_alpha
         logP       = alog10(P)
         logP_obs   = interpol(logP,log_x,logx_obs)
      endelse
      logL_x(i,j) = total(logP_obs)

      ; L_n
      if do_analytic then begin
         n_expect   = B * x0 * (1/(alpha+1)) * (yhi^(alpha+1) - ylo^(alpha+1))
      endif else begin
         n_expect   = total(PdB * B * dx)
      endelse
      ln_poisson_prob  = n_obs*alog(n_expect) - n_expect - ln_n_obs_factorial
      log_poisson_prob = ln_poisson_prob / alog(10d)
      logL_n(i,j)      = log_poisson_prob

   endfor

endfor

; Combined likelihood
logL = logL_x + logL_n

;;; Return normalized likelihood array

L          = 10d^(logL - max(logL))
L          = L / total(L)
likelihood = L

;;; Parameter combination where likelihood is maximized
best_ind       = array_indices(logL,where(logL eq max(logL)))
best_alpha_ind = best_ind(0)
best_logB_ind  = best_ind(1)
best_alpha     = alpha_list(best_alpha_ind)
best_logB      = logB_list(best_logB_ind)

;;; Confidence intervals

; Cumulative likelihood as a function of likelihood level
order   = sort(L)
L_level = L(order)
L_sum   = total(L_level,/cumulative)
L68     = interpol(L_level,L_sum,1-0.68)
L95     = interpol(L_level,L_sum,1-0.95)
L99     = interpol(L_level,L_sum,1-0.99)

;stop

L68_ind = array_indices(logL,where(logL le L68))

;;; Plot

;   contour,L,alpha_list,logB_list,level=[L99,L95,L68], xtitle='alpha',ytitle='logB',xs=3,ys=3, charsize = 2
   ;; TESTING
   ;true_alpha = -2.0d
   ;true_logB  = -12.0229
   ;oplot,[-10,10],replicate(true_logB,2),linestyle=1
   ;oplot,replicate(true_alpha,2),[-1e6,1e6],linestyle=1
   ;print,'Done. Hit key to exit.'
   ;key = get_kbrd()


return,[best_alpha,best_logB,L68,L95,L99]




end
