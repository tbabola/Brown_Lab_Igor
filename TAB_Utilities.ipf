#pragma rtGlobals=3	// Use modern global access method and strict wave access.

Function oops()
//This function removes the last included sweeps from the running average
	Wave adc0_avg_0 = root:adc0_avg_0
	Wave adc1_avg_0 = root:adc1_avg_0
	Wave adc0 = root:adc0
	Wave adc1 = root:adc1
	Wave adc0_temp = root:adc0_temp //used in query_average() for running total
	Wave adc1_temp = root:adc1_temp //used in query_average() for running total
	NVAR traces_analyzed //the number of traces in the average
	NVAR trace_num //the current trace displayed
	NVAR alternate //the alternate variable for averaging
	//load previous trace
	get_a_trace(trace_num - (1*alternate))
	
	adc0_avg_0 *= traces_analyzed //get sum total of average, average * total sweeps averaged
	adc0_avg_0 -= adc0  //subtract off current trace
	adc0_avg_0 /= (traces_analyzed - 1) //divide by the new number of averaged traces
	
	adc1_avg_0 *= traces_analyzed //repeat above for adc1
	adc1_avg_0 -= adc1
	adc1_avg_0 /= (traces_analyzed - 1)
	
	//subtract off of the running total from query_average()
	adc0_temp -= adc0
	adc1_temp -= adc1
	
	traces_analyzed -= 1 //decrement the running total of averaged waves
	DoUpdate
	
end

Function resist(adc_num)
	Variable adc_num
	Variable i_ss, i_base, i_pk, Rm, Ra
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

Function test()
	//Wavestats adc0
End