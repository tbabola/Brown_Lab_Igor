#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function oops()
//This function removes the last included sweeps from the running average
	Wave adc0_avg_0 = root:adc0_avg_0
	Wave adc1_avg_0 = root:adc1_avg_0
	Wave adc0 = root:adc0
	Wave adc1 = root:adc1
	Wave adc0_temp = root:adc0_temp //used in query_average() for running total
	Wave adc1_temp = root: adc1_temp //used in query_average() for running total
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