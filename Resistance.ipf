#pragma rtGlobals=1		// Use modern global access method.

Function resist(adc_num)
	Variable adc_num
	Variable i_ss, i_pk, i_base, Rm, Ra
	Variable v_step = -5 //mV as defined by WCVC mode
	String adc_avg
	sprintf adc_avg "adc%g_avg_0" adc_num
	
	Wave avg_adc = $adc_avg
	Wavestats /Q/R=(0,50) avg_adc
	i_base = V_avg
	Wavestats /Q/R=(50,75) avg_adc
	i_pk = V_min
	Wavestats /Q/R=(130,150) avg_adc
	i_ss = V_avg
	
	Ra = v_step / (i_pk - i_base) * 1000 // to convert to megaohms
	Rm = v_step / (i_ss - i_base) * 1000 
	
	printf "%s     Ra: %g MOhms; Rm %g MOhms\r" adc_avg, Ra, Rm
End