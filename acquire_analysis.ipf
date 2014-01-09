#pragma rtGlobals=1		// Use modern global access method

// Gaussian filter function.  Accepts data from array IN 
// filters it withh -3db frequency of FC (unit of sampling 
// frequency) and return result in IN array.


function gfilt(in, np, fc)
	wave in
	variable np, fc
	 // np is number of data points 
	 // fc is -3db point 
	variable /g old_fc, old_np
	variable sigma, loop_sum, b, nc, i, jl, ju, k, j
	sigma = 0.132505/fc

	if ((old_fc != fc) %| (old_np != np))
		Make /O/N=55 a
		sigma = 0.132505/fc
		If (sigma < 0.62)
			nc = 1
			a[1] = sigma*sigma *0.5;
			a[0] = (1.0 - 2.0*a[1]);
		Endif
		If (sigma >= 0.62)
			nc = floor(4.0*sigma)
			if (nc > 53)
				nc = 53
			Endif
			b = -1.0/(2.0*sigma*sigma)
			loop_sum = 0.5
			i = 1
			do
				loop_sum += exp(i * i * b)
				i += 1
			While (i < nc)
		// normalize the coefficients
			loop_sum *= 2.0
			a[0] = 1.0 /loop_sum
			i = 1
			do
				a[i] = exp(i*i*b)/loop_sum
				i += 1
			While (i < nc)
		Endif
		old_fc = fc
		old_np = np
		Redimension /N=(nc) a
		InsertPoints 0, nc, a
		i = 1
		do
			a[nc-i] = a[nc+i]
			i += 1
		while (i <= nc)
	Endif
 // actual filtering starts here 
 	SmoothCustom /E=3 a, in
	Return(0)
End




Function Detect_ap_peaks(trace, thresh, duration, detect_start, detect_end, detections)
	wave trace
	wave detections
	variable thresh, duration, detect_start, detect_end

//printf "detect_ap_peaks: %f\r", thresh
// local variables	
	
	variable i, j, k=0, peak, peak_index
	detections = 0
	i = detect_start
	k = 0
	do
		if (trace[i] > thresh)   // a threshold crossing at i
			peak = trace[i]
			peak_index = i
			j = 0
			do
				 j += 1
				 if ((j > duration) %| (trace[j+i] < thresh))
				 	detections[k] = peak_index
				 	k += 1
				 	break
				Endif 
				if (trace[i+j] > peak)
					peak = trace[i+j]
					peak_index = i+j
				Endif
			While(1)
			i += j
		Endif		// end of a single detection
		i += 1		
	While(i < detect_end)
		
Return(k) // return number of detections

End


Function Get_Amp(mode,trace_name, bl_start, bl_end, peak_start, peak_end, front_window) // returns the difference between the baseline and average about the peak
	variable mode // if 0 average difference if 1 positive peak detection if -1 negative peak detection; 5: SD
	string trace_name
	variable  bl_start, bl_end, peak_start, peak_end
	string front_window // 
	NVAR peak_index
	NVAR peak_points // same for all analysis
	NVAR freq
	NVAR draw_flag
	WAVE trace = $trace_name
	WAVE analysed_points_wave  // the number of points analysed in the dpoints waves
	WAVE amp_points_wave_0
	WAVE amp_points_wave_1

// local variables	
	
	variable i, j, peak_sum
	variable baseline, peak, bl_sd, peak_sd

	
// find baseline
	baseline = mean(trace, pnt2x(trace,bl_start), pnt2x(trace,bl_end))
//	baseline = 0
//	i = bl_start
//	do
//		baseline += trace[i]
//		i += 1
//	while ( i < bl_end)
//	baseline /= (bl_end - bl_start)
// now find peak value
	if (mode == 0 || mode == 2) // average between cursors
		peak = mean(trace, pnt2x(trace,peak_start), pnt2x(trace,peak_end))
		peak_index = peak_start + (peak_end - peak_start)/2
//		peak = 0
//		i = peak_start
//		do
//			peak += trace[i]
//			i += 1
//		While (i < peak_end)
//		peak /= (peak_end - peak_start)
	Endif
	if (mode == 5)
		WaveStats /Q/R = [peak_start, peak_end ]/Z trace
		peak_sd = V_sdev
		WaveStats /Q/R = [bl_start, bl_end ]/Z trace
		bl_sd = V_sdev
		return(sqrt(bl_sd*bl_sd + peak_sd*peak_sd)) // SD of the measurement
	Endif
	if (mode == 1)
		WaveStats /Q/R = [peak_start, peak_end ]/Z trace
		peak_index = freq*V_maxloc
		peak = V_max
		if (peak_points > 0)
			peak_sum = 0
			j = 0
			for (i = (x2pnt(trace, V_maxloc) - peak_points); i <= (x2pnt(trace, V_maxloc)+peak_points); i += 1)
				peak_sum += trace[ i]
				j += 1
			EndFor
			peak = peak_sum/j
		Endif 
//		i = peak_start
//		peak = trace[i]
//		Do
//			if (trace[i] >= peak)
//				peak = trace[i]
//				peak_index = i
//			Endif	
//			i += 1
//		While (i < peak_end)	
	Endif
	if (mode == -1)
		WaveStats /Q/R = [peak_start, peak_end ]/Z trace
		peak_index = freq*V_MinLoc
		peak = V_min
		if (peak_points > 0)
			peak_sum = 0
			j = 0
			for (i = (x2pnt(trace, V_minloc) - peak_points); i <= (x2pnt(trace, V_minloc)+peak_points); i += 1)
				peak_sum += trace[ i]
				j += 1
			EndFor
			peak = peak_sum/j
		Endif 

//		i = peak_start
//		peak = trace[i]
//		Do
//			if (trace[i] <= peak)
//				peak = trace[i]
//				peak_index = i
//			Endif	
//			i += 1
//		While (i < peak_end)	
	Endif
	if (mode == 10)
		return (baseline)
	Endif
	if (mode == 2) // integrate in ms * mV or pA
		Return((peak-baseline)*(peak_end-peak_start)/freq)
	Endif
	if (mode == 3)
		Return (amp_points_wave_0[analysed_points_wave[0]-1]/amp_points_wave_1[analysed_points_wave[0]-1])
	EndIf
	
	if (draw_flag)
//		DoWindow /F G_traces
		if (stringmatch(front_window, "G_traces"))
			DoWindow /F G_Traces
		Endif
		if (stringmatch(front_window, "G_average"))
			DoWindow /F G_average
		Endif

//		Execute ("BringDestFront(trace_name)"
//			setdrawlayer /K progback
			setdrawenv linethick=1.2, linefgc=(0,26112,13056), xcoord=bottom, ycoord=$get_yaxis(trace_name)
			setdrawenv save
//		printf "peak_index: %f, peak: %f\r", peak_index, peak
		drawline pnt2x(trace, bl_start), baseline, pnt2x(trace, bl_end), baseline
		drawline pnt2x(trace, peak_index), (peak ), pnt2x(trace, peak_index), baseline
	Endif

	Return(peak-baseline)
End


function fit_exp()
// to fit things
	variable fit_points
	variable bl_avg
	SVAR fit_trace_name
	NVAR bl_start, bl_end, f_start, f_end, tau1, tau2, frac1, frac2, fit_type
	fit_points = f_end - f_start
	Duplicate /O $fit_trace_name fit_data
	WaveStats/Q/R=[bl_start,bl_end] fit_data
	bl_avg = V_Avg
  //	fit_data -= bl_avg
	DeletePoints 0,f_start, fit_data
	killwaves /Z test_fit
	duplicate /O /R=[0, (f_end-f_start)+2] fit_data, test_fit
	k0 = bl_avg
	if (fit_type == 2)
		CurveFit /N/Q/H="00000" dblexp fit_data(0.0,pnt2x(fit_data,fit_points))
  		test_fit= k0+k1*exp(-k2*x)+k3*exp(-k4*x)
  		tau2 = 1/k4
  		tau1 = 1/k2
		frac1 = k1/(k1+k3)
		frac2 = k3/(k1+k3)
	endif
	if (fit_type == 1)
		CurveFit /N/Q/H="000" exp fit_data(0.0,pnt2x(fit_data,fit_points))
  		test_fit= k0+k1*exp(-k2*x)
  		tau1 = 1/k2
  		tau2 = 0
		frac1 = 1
		frac2 = 0
	Endif
	if (fit_type == 3)
		k0 = 0
		CurveFit /N/H="000" exp fit_data(0.0,pnt2x(fit_data,fit_points))
  		test_fit= k0+k1*exp(-k2*x)
  		tau1 = 1/k2
  		tau2 = 0
		frac1 = 1
		frac2 = 0
	Endif
	string tempstr
  	RemoveFromGraph /Z test_fit
  	tempstr = get_yaxis(fit_trace_name)
  	if (cmpstr(tempstr, "left") == 0)
 		AppendToGraph /L test_fit
 	Endif
 	if (cmpstr(tempstr, "left2") == 0)
 		AppendToGraph /L=left2 test_fit
 	Endif
 	if (cmpstr(tempstr, "right") == 0)
 		AppendToGraph /R test_fit
 	Endif
	ModifyGraph offset(test_fit)={pnt2x($fit_trace_name, f_start), 0}
	ModifyGraph rgb(test_fit)=(0,0,0)
	if (GetRTError(0))
		print "Error in function fit_exp"
		print GetRTErrMessage()
	endif
End

function Set_bl(CntrlName) : ButtonControl
	String CntrlName
	NVAR bl_start=bl_start, bl_end=bl_end
	bl_start = pcsr(a)
	bl_end = pcsr(b)
End

function Set_fit_range(CntrlName) : ButtonControl
	String CntrlName
	NVAR f_start, f_end
	SVAR fit_trace_name
	fit_trace_name = CsrWave(a)
	f_start = pcsr(a)
	f_end = pcsr(b)
End




function do_2_exp_fit(CntrlName) : ButtonControl
	String CntrlName
	NVAR fit_type=fit_type
	fit_type = 2
	fit_exp()
End

function do_1_exp_fit(CntrlName) : ButtonControl
	String CntrlName
	NVAR fit_type=fit_type
	fit_type = 1
	fit_exp()
End




function multi_analysis() // to arrange multiple amp analysis on the same trace

// the following are used for online amplitude analysis
	WAVE /T analysis_trace_name_wave // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE amp_analysis_flag_wave // if 1 do analysis
	WAVE amp_analysis_mode_wave  // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline

	variable i, num=0, interval=0 // in points
	Prompt num, "Enter number of analysis"
	Prompt interval, "Enter interval points"
	DoPrompt "Enter number of analysis and interval points", num, interval
	if (V_Flag)
		return -1		// User canceled
	endif
	//  set all analysis flags other then the first to zero
	For (i = 1; i < 10; i += 1)
		 amp_analysis_flag_wave[i] = 0
	EndFor
	For (i = 1; i < num; i += 1)
		analysis_trace_name_wave[i] = analysis_trace_name_wave[0]
		amp_bl_start_wave[i] = amp_bl_start_wave[0] + interval*i
		amp_bl_end_wave[i] = amp_bl_end_wave[0] + interval*i
		amp_start_wave[i] = amp_start_wave[0] + interval*i
		amp_end_wave[i] = amp_end_wave[0] + interval*i
		amp_analysis_flag_wave[i] = 1
		amp_analysis_mode_wave[i] = amp_analysis_mode_wave[0]
	EndFor
	Make_amp_analysis_panel()
End




function average()
	NVAR samples, update, trace_start, trace_end, freq, trace_num
	NVAR bin_type, total_chan_num, peak, alternate
	NVAR acquired,peak2peak,spike_duration,spike_thresh,search_flag, initialize
	NVAR total_spikes,read_file_ref,total_header_size, spike_num,interactive
	NVAR adc_status0, adc_status1, adc_status2, adc_status3
	NVAR traces_analyzed, num_prior_traces
	WAVE adc0, adc1, adc2,adc3, peaks,psth, dac0_stimwave, dac1_stimwave,dac2_stimwave
	SVAR spike_detection_trace_name, ZoomWindow
	WAVE adc0_avg_0, adc1_avg_0, adc2_avg_0, adc3_avg_0
	WAVE adc0_mini_avg, adc1_mini_avg, adc2_mini_avg, adc3_mini_avg //SPB added 4-30-07
	NVAR dac0_cc, dac0_vc, dac1_cc, dac1_vc,dac2_cc,dac2_vc,dac3_cc,dac3_vc
	WAVE adc0_mini_avg_temp, adc1_mini_avg_temp, adc2_mini_avg_temp, adc3_mini_avg_temp  //SPB added 4-30-07
	NVAR mini_num_0, mini_num_1, mini_num_2, mini_num_3  //SPB added 4-30-07
//--------------------------------------------------	
// the following are used for online amplitude analysis
	WAVE /T analysis_trace_name_wave // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE analysed_points_wave  // the number of points analysed in the dpoints waves
	WAVE amp_analysis_flag_wave // if 1 do analysis
	WAVE amp_analysis_mode_wave  // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	WAVE ExcludeList
	NVAR ExcludeIndex
	
//------------------------------------------------	
	NVAR number_of_pro, requested, adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag, scheme_on
	NVAR acquire_mode, draw_flag, ptime, miniFlag
	SVAR scheme
	NVAR mini_trace_points
	WAVE concat_0, concat_1, concat_2, concat_3
	variable stop_requested = 0
	variable pro_num, pro_sweeps, skip
	variable /g average_num
	variable temp, i, flag
	variable length
	string s
	wavestats ExcludeList
	length = V_npnts
	Make /O/N=1000 detections=0
	if (search_flag == 1)
		Make /O/N=100000 total_detections = 0
		Make /O/N=10000 isi_wave
	endif
	if (acquire_mode == 0)
		scheme_on = 0
	Endif
	if (scheme_on == 1)
		decode_scheme(scheme)
	EndIf
	total_spikes = 0
	variable index, k, j
	if (initialize)
		traces_analyzed = 0
		num_prior_traces  = 0
		setDataFolder root:minis
		KillWaves /A
		setDataFolder root:
		ExcludeIndex = 0
		string wavename
		i = 0
		Do
			wavename = ("amp_points_wave_" + num2str(i))
			WAVE tempwave = $wavename
			tempwave  = NaN
			analysed_points_wave[i] = 0
			i += 1
		While (i < 10)
		Make /O/N=(samples) adc0_temp, adc0_avg_0, adc1_temp, adc1_avg_0, adc2_temp, adc2_avg_0, adc3_temp, adc3_avg_0
		Make /O/N=(mini_trace_points) adc0_mini_avg=0, adc0_mini_avg_temp = 0, adc1_mini_avg = 0, adc1_mini_avg_temp = 0, adc2_mini_avg = 0, adc2_mini_avg_temp = 0, adc3_mini_avg = 0, adc3_mini_avg_temp = 0  //SPB added 4-30-07
		mini_num_0 = 0
		mini_num_1 = 0
		mini_num_2 = 0
		mini_num_3 = 0  //SPB added 4-30-07
		adc0_avg_0 = 0
		adc1_avg_0 = 0
		adc2_avg_0 = 0
		adc3_avg_0 = 0
		if ((bin_type == 0) %| (bin_type == 10) %| (bin_type == 100))
			SetScale /P x, 0, (1.0/freq), "ms", adc0_avg_0, adc1_avg_0, adc2_avg_0, adc3_avg_0, adc0_mini_avg,adc1_mini_avg, adc2_mini_avg
		endif
		if (((bin_type == 1) %| (bin_type == 2)) %& (total_chan_num == 2))
			SetScale /P x, 0, (1.0/freq), "ms", adc1_avg
			SetScale /P x, (0.5/freq), (1.0/freq), "ms", adc0_avg
		endif
		if (dac0_cc)
			SetScale d, -200, 200, "mV", adc0_avg_0, adc0_mini_avg, adc1_mini_avg, adc2_mini_avg, adc3_mini_avg //SPB added adc3 5-1-07
		Else
			SetScale d, -200, 200, "pA", adc0_avg_0, adc0_mini_avg, adc1_mini_avg, adc2_mini_avg, adc3_mini_avg //SPB added adc3 5-1-07
		EndIf
		if (dac1_cc)
			SetScale d, -200, 200, "mV", adc1_avg_0
		Else
			SetScale d, -200, 200, "pA", adc1_avg_0
		EndIf
		if (dac2_cc)
			SetScale d, -200, 200, "mV", adc2_avg_0
		Else
			SetScale d, -200, 200, "pA", adc2_avg_0
		EndIf
		if (dac3_cc)
			SetScale d, -200, 200, "mV", adc3_avg_0
		Else
			SetScale d, -200, 200, "pA", adc3_avg_0
		EndIf
		average_num = 0
		adc0_temp = 0
		adc1_temp = 0
		adc2_temp = 0
		adc3_temp = 0
		pro_num = 0
		if (scheme_on)
			decode_pro("pro_" + num2str(pro_num))
		Endif
		pro_sweeps = 0
		if (miniFlag)
			query_mini("init")
		Endif
	Endif
// get one trace before begining the loop	
	trace_num = trace_start
	if (alternate == 0)
		alternate = 1
	Endif
	temp = trace_num
	stop_requested = 0
	Do
//		trace_num = trace_start + alternate * average_num
//		trace_num += 1
//		pro_sweeps += 1
//	test if stop is requested
		if (stop_requested) // during wait_time()
			break
		EndIf
		s = KeyboardState("")
 		if (cmpstr(s[9], "z") == 0) // z   to stop
 			break
 		Endif
		if (cmpstr(s[9], "1") == 0) // zoom
			ChangeAxis(1, ZoomWindow)
		endif
		if (cmpstr(s[9], "2") == 0) // zoom
			ChangeAxis(-1, ZoomWindow)
		endif


		if ((pro_sweeps >= requested) && (requested != -1) && scheme_on && (alternate == 1))
			pro_num += 1
			if (pro_num >= number_of_pro)
				pro_num = 0 // recycle the scheme
			EndIf
			decode_pro("pro_" + num2str(pro_num))
//			printf "pro_num:%d, , requested: %d\r" pro_num, requested
			pro_sweeps = 0
		Endif
		
		if (trace_num > trace_end)
//			trace_num = temp
			break
		Endif
		Do // Modified by Zhou, solved the exceed problem
 	printf "ExcludeIndex=%f, ExcludeList[ExcludeIndex]=%f,  trace_num=%f\r",ExcludeIndex, ExcludeList[ExcludeIndex], trace_num // Added by Zhou
			if (ExcludeIndex >= length)
			Break
			Endif
			if (ExcludeList[ExcludeIndex] < trace_num)
				ExcludeIndex += 1
			Endif
			if (ExcludeList[ExcludeIndex] == trace_num)
				ExcludeIndex += 1
			printf " exclude trace_num: %f\r", trace_num// activated by Zhou
			printf "ExcludeIndex: %f\r", ExcludeIndex
//				temp = trace_num
				trace_num += alternate
			Endif 
				if (ExcludeList[ExcludeIndex]>trace_num)
				break
			EndIf
		While(1)
		if (trace_num > trace_end)
//			trace_num = temp
			break
		Endif
		ControlUpdate /W=Panel_C set_trace_num
		traces_analyzed += 1
		Get_a_trace(trace_num)
		if (MiniFlag)
//			printf "miniflag in average before calling GetSweepMinis=%d\r", MiniFlag
			flag = GetSweepMinis(0)
//			printf "mini flag in average after calling=%.0f\r", flag
			if (flag == -1)
				stop_requested = 1
//			printf "stop_requested = %d\r", stop_requested
				continue
			EndIf
			if (flag != 1)
				trace_num += alternate
				pro_sweeps += 1
				if(trace_num <= trace_end)
					continue
				else
					break
				endif
			Endif
		Endif


	    if (scheme_on && (alternate == 1)) // if alternate >1 ignore scheme protocols; note that average flag has to be set for amp analysis
		skip = 0
		if ((adc_status0 == 1) && (adc0_avg_flag == 1))
			skip = 1
		Endif
		if ((adc_status1 == 1) && (adc1_avg_flag == 1))
			skip = 1
		Endif
		if ((adc_status2 == 1) && (adc2_avg_flag == 1))
			skip = 1
		Endif
		if ((adc_status3 == 1) && (adc3_avg_flag == 1))
			skip = 1
		Endif
		if (skip == 0)
			if (update)
				DoUpDate
			Endif
			pro_sweeps += 1
			trace_num += 1
			Continue
		Endif
	    EndIf
		average_num += 1
		if (adc_status0)
			adc0_temp += adc0
			adc0_avg_0 = adc0_temp / average_num
			concat_0[trace_num*samples,(trace_num+1)*samples] = adc0[p-trace_num*samples]
		Endif
		if (adc_status1)
			adc1_temp += adc1
			adc1_avg_0 = adc1_temp / average_num
			concat_1[trace_num*samples,(trace_num+1)*samples] = adc1[p-trace_num*samples]
		Endif
		if (adc_status2)
			adc2_temp += adc2
			adc2_avg_0 = adc2_temp / average_num
			concat_2[trace_num*samples,(trace_num+1)*samples] = adc2[p-trace_num*samples]
		Endif
		if (adc_status3)
			adc3_temp += adc3
			adc3_avg_0 = adc3_temp / average_num
			concat_3[trace_num*samples,(trace_num+1)*samples] = adc3[p-trace_num*samples]
		Endif
		
//		if (MiniFlag)
//			if (GetSweepMinis(0) == -1)
//				stop_requested = 1
////			printf "stop_requested = %d\r", stop_requested
//			continue
//			EndIf
//		Endif
// start comment		
//
//		string wavename
//		i = 0
//		if (draw_flag)
//			DoWindow /F G_traces
//			setdrawlayer /K progback
//			setdrawenv linethick=1.2, linefgc=(0,26112,13056), xcoord=bottom, ycoord=$get_yaxis(analysis_trace_name_wave[i])
//			setdrawenv save
//		Endif
//
//		Do
//			if (amp_analysis_flag_wave[i])
//				peak = Get_Amp(amp_analysis_mode_wave[i],analysis_trace_name_wave[i], amp_bl_start_wave[i], amp_bl_end_wave[i], amp_start_wave[i], amp_end_wave[i])
//				wavename = ("amp_points_wave_" + num2str(i))
//				WAVE tempwave = $wavename
//				tempwave[analysed_points_wave[i]]  = peak
//				analysed_points_wave[i] += 1
//			Endif
//			i += 1
//		While (i < 10)
		
		if (update)
			DoUpDate
		Endif
		if (search_flag == 1)
			k = FindSingleUnitsInTrace($spike_detection_trace_name, spike_thresh, spike_duration, peak2peak, 0, samples, detections)
			spike_num = k
			index = 0
			do
				if (k == 0)
					break
				Endif
				total_detections[total_spikes] = detections[index] + (average_num-1)*samples
				total_spikes += 1
				index += 1
			while(index < k)	
		Endif
		stop_requested = wait_time(ptime) // pause in seconds
		if (stop_requested)
			continue
		Endif
		temp = trace_num
		trace_num += alternate
		pro_sweeps += 1
	While (trace_num <= trace_end)
	if (trace_num > trace_end)
		trace_num = trace_end
	EndIf
	if (search_flag == 1)
		isi_wave = NaN
		total_detections /= freq
		j = 0
		do
			isi_wave[j] = total_detections[j+1] - total_detections[j]
			j += 1
		While (j < (total_spikes-1))
		Histogram /B={0,1,1000} isi_wave,psth
	Endif
	printf "average: %d (%d -> %d) done\r", average_num, trace_start, trace_end
	printf "%d traces analyzed\r", traces_analyzed
	num_prior_traces = traces_analyzed
//	if (GetRTError(0))
//		print "Error in function average"
//		print GetRTErrMessage()
//	endif
End




function query_mini(cntrlName) : ButtonControl
	String CntrlName
	WAVE Mini_adc0, Mini_adc1, Mini_adc2, Mini_adc3  //SPB added 4-30-07
	WAVE Mini_adc0_f, Mini_adc1_f, Mini_adc2_f, Mini_adc3_f // final	 //SPB added 4-30-07
	WAVE adc0_mini_wave, adc1_mini_wave, adc2_mini_wave, adc3_mini_wave
	NVAR adc0_index, adc1_index, adc2_index, adc3_index  //SPB added 4-30-07
	NVAR adc0_index_f, adc1_index_f, adc2_index_f, adc3_index_f  //SPB added 4-30-07
	NVAR trace_num, trace_start
	NVAR over_ride_init
	NVAR mini_trace_points
	if (stringmatch("init",CntrlName) == 1 && over_ride_init == 0) // init
		Mini_adc0 = 0
		Mini_adc1 = 0
		Mini_adc2 = 0 // first column: time, second column: amplitude
		Mini_adc3 = 0  //SPB added 4-30-07
		Mini_adc0_f = 0
		Mini_adc1_f = 0
		Mini_adc2_f = 0 // first column: time, second column: amplitude
		Mini_adc3_f = 0  //SPB added 4-30-07
		adc0_index = 0
		adc1_index = 0
		adc2_index = 0
		adc3_index = 0  //SPB added 4-30-07
		adc0_index_f = 0
		adc1_index_f = 0
		adc2_index_f = 0
		adc3_index_f = 0  //SPB added 4-30-07
//		Make /O/N=(mini_trace_points) adc0_mini_wave=0, adc1_mini_wave=0, adc2_mini_wave=0, adc3_mini_wave=0
		Make /O/N=(mini_trace_points) adc0_mini_wave = 0
		Make /O/N=(mini_trace_points) adc1_mini_wave = 0
		Make /O/N=(mini_trace_points) adc2_mini_wave = 0
		Make /O/N=(mini_trace_points) adc3_mini_wave = 0
		Make /O/N=(mini_trace_points) temp_mini_wave = 0 

//		trace_num = trace_start
//		Get_a_Trace(trace_num)
	Endif
	
	if (stringmatch("include",CntrlName) == 1) // Include
	
	Endif
	if (stringmatch("reject",CntrlName) == 1) // Reject
	
	EndIf
End



// read and average adc0,adc1 into adc0_avg, adc1_avg after query.
// if flag = 0 :init, if flag = 1 include, if flag = -1 exclude

// read and compute the correlation or autocorrelation of two traces adc0,adc1 outWave after query.
// if flag = 0 :init, if flag = 1 include, if flag = -1 exclude
function query_corr(CntrlName) : ButtonControl
	String CntrlName
	NVAR trace_start, trace_end, freq, trace_num
	NVAR corr_num // the number of points used in the correlation
	NVAR corr_start // where to begin in the trace
	NVAR end_analysis
	NVAR alternate,bin_type,total_chan_num,traces_analyzed, keepADC0,keepADC1,keepADC2,keepADC3
	SVAR srcWave_0, srcWave_1 // strings of the traces to be correlated
//	WAVE outWave // to be defined by corr()
	variable i
	WAVE ExcludeList// ZY
	variable ExcludeList_length_ZY// ZY
	variable/g Exclude_points// ZY
	if (stringmatch("init1",CntrlName) == 1) // init
		Exclude_points =0// reset exclude list
		WaveStats ExcludeList // ZY
		ExcludeList_length_ZY= V_npnts//ZY
		DeletePoints 0, ExcludeList_length_ZY, ExcludeList
		Make /O/N=(corr_num) outWave, outWave_temp, corrWave
		outWave = 0
		trace_num = trace_start
		traces_analyzed = 0
		Get_a_Trace(trace_num)
		corr_start = pcsr(a)
		corr(corr_num, srcWave_0, srcWave_1) // to generate scaling
		duplicate /O outWave, outWave_temp, corrWave
		outWave_temp = 0
		corrWave = 0
		end_analysis = 0
		Dowindow /K Correlation
		Display /W=(5.76,237.728,401.472,416.288) corrWave
		DoWindow /c Correlation
		DoWindow /F g_traces
	Endif
	if (end_analysis)
		return(0)
	Endif
	if (stringmatch("include1",CntrlName) == 1) // include
		traces_analyzed += 1
		corr_start = pcsr(a)
		corr(corr_num, srcWave_0, srcWave_1)
		outWave_temp += outWave
		corrWave = outWave_temp/traces_analyzed
		trace_num = trace_num + alternate
		if (trace_num > trace_end)
			trace_num -= alternate
			end_analysis = 1
			return(0)
		Endif
		Get_a_trace(trace_num)
	Endif
	if (stringmatch("do_not_include1",CntrlName) == 1) // do not include
		ExcludeList[Exclude_points]=trace_num
		Exclude_points=Exclude_points+1
		trace_num = trace_num + alternate
		if (trace_num > trace_end)
			trace_num -= alternate
			end_analysis = 1
			return(0)
		Endif
		Get_a_trace(trace_num)
	Endif
End







function corr(num,string_Wave_0,string_Wave_1)
variable num
string string_Wave_0, string_Wave_1
NVAR freq
NVAR corr_start
WAVE Wave_0=$string_Wave_0
WAVE Wave_1=$string_Wave_1
duplicate /O/R=[corr_start,(corr_start+num-1)] Wave_0, src0Wave
SetScale/P x 0,(1/freq),"ms", src0Wave
WaveStats/Q src0Wave
src0Wave -= v_avg
WaveStats/Q src0Wave
Variable srcRMS= V_rms
Variable srcLen= numpnts(src0Wave)	

duplicate /O/R=[corr_start,(corr_start+num-1)] Wave_1, src1Wave
SetScale/P x 0,(1/freq),"ms", src1Wave


WaveStats/Q src1Wave
src1Wave -= V_avg
WaveStats/Q src1Wave
Variable destRMS= V_rms
Variable destLen= numpnts(src1Wave)	
duplicate /O src1Wave, outWave
Correlate src0Wave, outWave	// overwrites destWave

// now normalize to max of 1.0
outWave /= (srcRMS * sqrt(srcLen) * destRMS * sqrt(destLen))
End



// detect multiple spikes (or other events) in one trace and excise traces aligned to the spike
function query_detections(CntrlName) : ButtonControl
	String CntrlName
	NVAR samples, trace_start, trace_end, freq, trace_num
	NVAR alternate,bin_type,total_chan_num,traces_analyzed,keepADC0,keepADC1,keepADC2,keepADC3
	SVAR spike_detection_trace_name
	WAVE adc0, adc1, adc2
	NVAR spike_thresh, spike_duration
	variable /g  spike_num, detected, spikes_accepted, index
	WAVE detection_trace = $spike_detection_trace_name
	Make /O/N=100 detections
	variable ex_points = 2000
// prepare for drawing in the trace window
	Execute ("BringDestFront(spike_detection_trace_name)")
	setdrawlayer /K progback
	setdrawenv linethick=1.0, arrow=2,linefgc=(0,26112,13056), xcoord=bottom, ycoord=$get_yaxis(spike_detection_trace_name)
	setdrawenv save
	if (stringmatch("init",CntrlName) == 1) // init
		spikes_accepted = 0
		Make /O/N=(ex_points) adc0_temp, adc1_temp, adc0_avg, adc1_avg,adc2_temp,adc2_avg
		if ((bin_type == 0) %| (bin_type == 10) %| (bin_type == 100))
			SetScale /P x, 0, (1.0/freq), "ms", adc0_avg, adc1_avg,adc2_avg
		endif
		if (((bin_type == 1) %| (bin_type == 2)) %& (total_chan_num == 2))
			SetScale /P x, 0, (1.0/freq), "ms", adc1_avg
			SetScale /P x, (0.5/freq), (1.0/freq), "ms", adc0_avg
		endif
		SetScale d, -200, 200, "mV", adc0_avg, adc1_avg ,adc2_avg
//		if ((traces_analyzed > 0) %& ((keepDAC0 == 1) %| (keepDAC1 == 1)))
//			DoWindow /F G_Traces
//			i = 0
//			Do
//				RemoveFromGraph /Z $("adc0_" + num2str(i)), $("adc1_" + num2str(i))
//				KillWaves /Z $("adc0_" + num2str(i)), $("adc1_" + num2str(i))
//				i += 1
//			While (i < traces_analyzed)
//		Endif
		adc0_temp = 0
		adc1_temp = 0
		adc2_temp = 0
		adc0_avg = 0
		adc1_avg = 0
		adc2_avg = 0
		trace_num = trace_start
		Get_a_Trace(trace_num)
// now detect spikes in the first trace
		detected = detect_ap_peaks(detection_trace, spike_thresh, spike_duration, 0, samples, detections)
		spike_num = 0
// now mark the first detected spike in the original graph
		if (detected != 0)
			drawline pnt2x(detection_trace, detections[spike_num]), detection_trace[detections[spike_num]], pnt2x(detection_trace, detections[spike_num]), 1.2*detection_trace[detections[spike_num]]
		EndIf

		Dowindow /K G_Average
		Display /W=(4.2,234.8,399.6,413.6) adc0_avg as "G_average"
		DoWindow /C G_average
		AppendToGraph/R adc1_avg
		ModifyGraph rgb(adc1_avg)=(0,34816,52224)
		return(0)
	Endif
//	if ((alternate == 0) %& ((trace_num+1) >= trace_end))
//		return(0)
//	Endif
//	If ((alternate > 0) %& ((trace_num+alternate) >= trace_end))
//		return(0)
//	Endif
	if (stringmatch("include",CntrlName) == 1) // include
		if (trace_num > trace_end)
			Return 0
		EndIf
		adc0_temp[0,ex_points] += adc0[detections[spike_num]-500+p]
		adc1_temp[0, ex_points] += adc1[detections[spike_num]-500+p]
		spikes_accepted += 1
		adc0_avg = adc0_temp / spikes_accepted
		adc1_avg = adc1_temp / spikes_accepted
//		if (keepDAC0)
//			Duplicate /O adc0, $("adc0_" + num2str(traces_analyzed-1))
//			DoWindow /F G_traces
//			AppendToGraph /L $("adc0_" + num2str(traces_analyzed-1))
//			ModifyGraph rgb($("adc0_" + num2str(traces_analyzed-1)))=(0,0,0)
//		Endif
//		if (keepDAC1)
//			Duplicate /O adc1, $("adc1_" + num2str(traces_analyzed-1))
//			DoWindow /F G_traces
//			AppendToGraph /R $("adc1_" + num2str(traces_analyzed-1))
//			ModifyGraph rgb($("adc1_" + num2str(traces_analyzed-1)))=(0,0,0)			
//		Endif
//		if (alternate == 0)
//			trace_num += 1
//		Else
//			trace_num = trace_num + alternate
//		Endif
		spike_num += 1
		if (spike_num >= detected)
			trace_num += 1
			if (trace_num > trace_end)
				Return 0
			EndIf
			Get_a_trace(trace_num)
			detected = detect_ap_peaks(detection_trace, spike_thresh, spike_duration, 0, samples, detections)
			spike_num = 0
// now mark the first detected spike in the original graph
			if (detected != 0)
			   drawline pnt2x(detection_trace, detections[spike_num]), detection_trace[detections[spike_num]], pnt2x(detection_trace, detections[spike_num]), 1.2*detection_trace[detections[spike_num]]
			EndIf
		EndIf
		if (spike_num < detected)
			drawline pnt2x(detection_trace, detections[spike_num]), detection_trace[detections[spike_num]], pnt2x(detection_trace, detections[spike_num]), 1.2*detection_trace[detections[spike_num]]
		EndIf
	Endif
	if (stringmatch("do_not_include",CntrlName) == 1) // do not include
//		if (alternate == 0)
//			trace_num += 1
//		Else
//			trace_num = trace_num + alternate
//		Endif
		spike_num += 1
		if (spike_num >= detected)
			trace_num += 1
			if (trace_num > trace_end)
				Return 0
			EndIf
			Get_a_trace(trace_num)
			DoWindow /F Panel_C
			SetVariable set_trace_num, Win=Panel_C, value= trace_num
			detected = detect_ap_peaks(detection_trace, spike_thresh, spike_duration, 0, samples, detections)
			spike_num = 0
// now mark the first detected spike in the original graph
			if (detected != 0)
			   drawline pnt2x(detection_trace, detections[spike_num]), detection_trace[detections[spike_num]], pnt2x(detection_trace, detections[spike_num]), 1.2*detection_trace[detections[spike_num]]
			EndIf
		EndIf
		if (spike_num < detected)
			drawline pnt2x(detection_trace, detections[spike_num]), detection_trace[detections[spike_num]], pnt2x(detection_trace, detections[spike_num]), 1.2*detection_trace[detections[spike_num]]
		EndIf
	Endif	
End

function GetSweepMinis(flag) // search for minis in all traces from a sweep and insert results in output waves
	variable flag // if 1 init
	NVAR freq
	NVAR keep_minis // if =1 make a copy of a portion of the trace 
	NVAR adc0_index, adc1_index, adc2_index, adc3_index //added all the adc3's here SPB 4-30-07
	NVAR mode_0, mode_1, mode_2, mode_3
	NVAR searchStart_0, searchStart_1, searchStart_2, searchStart_3
	NVAR searchEnd_0, searchEnd_1, searchEnd_2, searchEnd_3
	NVAR blTime_0, blTime_1, blTime_2, blTime_3
	NVAR LAtime_0, LAtime_1, LAtime_2, LAtime_3
	NVAR Threshold_0, Threshold_1, Threshold_2, Threshold_3
	NVAR jumpTime_0, jumpTime_1, jumpTime_2, jumpTime_3
	NVAR peakWindowTime_0, peakWindowTime_1, peakWindowTime_2, peakWindowTime_3
	NVAR slope_0, slope_1, slope_2, slope_3
	NVAR TraceOffSet, num_prior_traces
	NVAR mini_pre_points, mini_trace_points
//	(mode, traceName, searchStart, searchEnd, blTime, LAtime, Threshold, jumpTime, peakWindowTime) 
	WAVE adc0_mini_avg, adc0_mini_avg_temp,adc1_mini_avg, adc1_mini_avg_temp,adc2_mini_avg, adc2_mini_avg_temp, adc3_mini_avg, adc3_mini_avg_temp
	WAVE adc0_mini_wave, adc1_mini_wave, adc2_mini_wave, adc3_mini_wave
	NVAR mini_num_0, mini_num_1, mini_num_2, mini_num_3
	WAVE Mini_adc0, Mini_adc1, Mini_adc2, Mini_adc3  // first column: time, second column: amplitude
	WAVE adc0,adc1,adc2,adc3
	WAVE results
	NVAR samples, trace_num, traces_analyzed
	WAVE detections
	NVAR spike_duration, spike_thresh, beforeSpike
	variable position
	variable k, tvar
	if (flag)
		Mini_adc0 = 0
		Mini_adc1 = 0
		Mini_adc2 = 0 // first column: time, second column: amplitude
		Mini_adc3 = 0
		adc0_index = 0
		adc1_index = 0
		adc2_index = 0
		adc3_index =0
	EndIf
	string traceName
	variable searchStart
	variable i, found, jj
	
	For (i = 0; i < 4; i += 1)
		if ((i == 0) && (Threshold_0 >= 1000))
			Continue
		EndIf
		if ((i == 1) && (Threshold_1 >= 1000))
			Continue
		EndIf
		if ((i == 2) && (Threshold_2 >= 1000))
			Continue
		EndIf
		if ((i == 3) && (Threshold_3 >= 1000))
			Continue
		EndIf

		traceName = "adc" + num2str(i)
		
		if (i == 0)
			searchStart = searchStart_0
		EndIf
		if (i == 1)
			searchStart = searchStart_1
		EndIf
		if (i == 2)
			searchStart = searchStart_2
		EndIf
		if (i == 3)
			searchStart = searchStart_3
		EndIf

// detect if there is a spike in TraceName
// determine spikeTime
// BlankStart = (spikeTime-beforeSpike)
// BlankEnd = (spikeTime+afterSpike)
// Do not search from BlankStart to BlankEnd
//		WAVE detectTrace = $traceName
//		k = Detect_ap_peaks(detectTrace,spike_thresh, spike_duration, searchStart, searchEnd_0, detections)
		Do
			if (i == 0)
				found = detectMini (mode_0, traceName, searchStart, searchEnd_0, blTime_0, LATime_0, Threshold_0, jumpTime_0,  peakWindowTime_0, adc0_index, slope_0)
			EndIf
			if (i == 1)
				found = detectMini (mode_1, traceName, searchStart, searchEnd_1, blTime_1, LATime_1, Threshold_1, jumpTime_1,  peakWindowTime_1, adc1_index, slope_1)
			EndIf
			if (i == 2)
				found = detectMini (mode_2, traceName, searchStart, searchEnd_2, blTime_2, LATime_2, Threshold_2, jumpTime_2,  peakWindowTime_2, adc2_index, slope_2)
			EndIf
			if (i == 3)
				found = detectMini (mode_3, traceName, searchStart, searchEnd_3, blTime_3, LATime_3, Threshold_3, jumpTime_3,  peakWindowTime_3, adc3_index, slope_3)
			EndIf
//			printf "found returned from detectmini =%.0f\r", found
			if (found == -1) // terminate
				return(-1)
			Endif
			if (found == 3)
				traces_analyzed -= 1
				break
			Endif
//			traces_analyzed += 1
			if (found == 10)
				if (i == 0)
					searchStart = x2pnt($traceName, results[0]) + x2pnt($traceName,jumpTime_0)
				Endif
				if (i == 1)
					searchStart = x2pnt($traceName, results[0]) + x2pnt($traceName,jumpTime_1)
				Endif
				if (i == 2)
					searchStart = x2pnt($traceName, results[0]) + x2pnt($traceName,jumpTime_2)
				Endif
				if (i == 3)
					searchStart = x2pnt($traceName, results[0]) + x2pnt($traceName,jumpTime_3)
				Endif
//	printf "(1)searchStart=%d\r", searchStart
				if (searchStart >= samples)
//					printf "(1)searchStart=%d\r", searchStart					found = 0
				EndIf
			Endif
			If (found == 1)
				if (i == 0)
//					printf "%s, results: %.12f\r", traceName, results[0]
					Mini_adc0[adc0_index][0] = trace_num*TraceOffSet + results[0] + num_prior_traces*TraceOffSet
					Mini_adc0[adc0_index][1] = results[1]
					Mini_adc0[adc0_index][2] = results[2]
					Mini_adc0[adc0_index][3] = results[3]
					position = x2pnt(adc0,results[0])-mini_pre_points
					adc0_mini_avg_temp += adc0[position+p]
					adc0_mini_avg = adc0_mini_avg_temp/(mini_num_0+1)
					mini_num_0 += 1
								
								
					if (keep_minis)		
//						Make /O/N=(mini_trace_points) $("root:minis:adc0_mini_" + num2str(adc0_index)) 
//						WAVE tempw = $("root:minis:adc0_mini_" + num2str(adc0_index))
//						SetScale /P x  0,(1/freq), "ms", tempw 
//						tempw  = adc0[position+p]
						WAVE temp_mini_wave
						temp_mini_wave = adc0[position+p]
						tvar = mean(temp_mini_Wave,0,10)
						temp_mini_wave -= tvar
//						adc0_mini_wave[(adc0_index*mini_trace_points),] = temp_mini_wave[p]
						if (adc0_index == 0)
							Concatenate /O/NP {temp_mini_wave}, adc0_mini_wave
						Else
							Concatenate /NP {temp_mini_wave}, adc0_mini_wave
						Endif
					Endif

					adc0_index += 1
					searchStart = x2pnt($traceName, results[0]) + x2pnt($traceName,jumpTime_0)
				Endif
				if (i == 1)
					Mini_adc1[adc1_index][0] = trace_num*TraceOffSet + results[0] + num_prior_traces*TraceOffSet
					Mini_adc1[adc1_index][1] = results[1]
					Mini_adc1[adc1_index][2] = results[2]
					Mini_adc1[adc1_index][3] = results[3]
					position = x2pnt(adc1,results[0])-mini_pre_points
					
					adc1_mini_avg_temp += adc1[position+p]
					adc1_mini_avg = adc1_mini_avg_temp/(mini_num_1+1)
					mini_num_1 += 1
					if (keep_minis)
//						Make /O/N=(mini_trace_points) $("root:minis:adc1_mini_" + num2str(adc1_index)) 
//						WAVE tempw = $("root:minis:adc1_mini_" + num2str(adc1_index))
//						tempw  = adc1[position+p]
//						SetScale /P x 0,(1/freq), "ms", tempw 
//						tvar = mean(tempw,0,100)
//						tempw -= tvar
						WAVE temp_mini_wave
						temp_mini_wave = adc1[position+p]
						tvar = mean(temp_mini_Wave,0,10)
						temp_mini_wave -= tvar
//						adc1_mini_wave[(adc1_index*mini_trace_points),] = temp_mini_wave[p]
						if (adc1_index == 0)
							Concatenate /O/NP {temp_mini_wave}, adc1_mini_wave
						Else
							Concatenate /NP {temp_mini_wave}, adc1_mini_wave
						Endif
					Endif
					adc1_index += 1
					searchStart = x2pnt($traceName, results[0]) + x2pnt($traceName,jumpTime_1)
				Endif
				if (i == 2)
					Mini_adc2[adc2_index][0] = trace_num * TraceOffSet + results[0] + num_prior_traces*TraceOffSet
					Mini_adc2[adc2_index][1] = results[1]
					Mini_adc2[adc2_index][2] = results[2]
					Mini_adc2[adc2_index][3] = results[3]
					position = x2pnt(adc2,results[0])-mini_pre_points
					adc2_mini_avg_temp += adc2[position+p]
					adc2_mini_avg = adc2_mini_avg_temp/(mini_num_2+1)
					mini_num_2 += 1
					if(keep_minis)
//						Make /O/N=(mini_trace_points) $("root:minis:adc2_mini_" + num2str(adc2_index)) 
//						WAVE tempw = $("root:minis:adc2_mini_" + num2str(adc2_index))
//						tempw  = adc2[position+p]
//						SetScale /P x 0,(1/freq), "ms", tempw 
//						tvar = mean(tempw,0,100)
//						tempw -= tvar
//						Concatenate /NP {tempw}, adc2_mini_wave
						WAVE temp_mini_wave
						temp_mini_wave = adc2[position+p]
						tvar = mean(temp_mini_Wave,0,10)
						temp_mini_wave -= tvar
//						adc2_mini_wave[(adc2_index*mini_trace_points),] = temp_mini_wave[p]
						if (adc2_index == 0)
							Concatenate /O/NP {temp_mini_wave}, adc2_mini_wave
						Else
							Concatenate /NP {temp_mini_wave}, adc2_mini_wave
						Endif
					Endif

					adc2_index += 1
					searchStart = x2pnt($traceName, results[0]) + x2pnt($traceName,jumpTime_2)
				Endif
				if (i == 3)
					Mini_adc3[adc3_index][0] = trace_num * TraceOffSet + results[0] + num_prior_traces*TraceOffSet
					Mini_adc3[adc3_index][1] = results[1]
					Mini_adc3[adc3_index][2] = results[2]
					Mini_adc3[adc3_index][3] = results[3]
					position = x2pnt(adc3,results[0])-mini_pre_points
					adc3_mini_avg_temp += adc3[position+p]
					adc3_mini_avg = adc3_mini_avg_temp/(mini_num_3+1)
					mini_num_3 += 1
					if(keep_minis)
//						Make /O/N=(mini_trace_points) $("root:minis:adc3_mini_" + num2str(adc3_index)) 
//						WAVE tempw = $("root:minis:adc3_mini_" + num2str(adc3_index))
//						tempw  = adc3[position+p]
//						SetScale /P x 0,(1/freq), "ms", tempw 
//						tvar = mean(tempw,0,100)
//						tempw -= tvar
//						Concatenate /NP {tempw}, adc3_mini_wave
						WAVE temp_mini_wave
						temp_mini_wave = adc3[position+p]
						tvar = mean(temp_mini_Wave,0,10)
						temp_mini_wave -= tvar
//						adc3_mini_wave[(adc3_index*mini_trace_points),] = temp_mini_wave[p]
						if (adc3_index == 0)
							Concatenate /O/NP {temp_mini_wave}, adc3_mini_wave
						Else
							Concatenate /NP {temp_mini_wave}, adc3_mini_wave
						Endif
					Endif

					adc3_index += 1
					searchStart = x2pnt($traceName, results[0]) + x2pnt($traceName,jumpTime_3)
				Endif
				if(i==0)
					ControlUpdate /W=Minis_Panel End_10
				Endif
				if(i==1)
					ControlUpdate /W=Minis_Panel End_1001
				Endif
				if(i==2)
					ControlUpdate /W=Minis_Panel End_100101
				EndIf
				if(i==3) //added SPB 4-30-07
					ControlUpdate /W=Minis_Panel End_100102
				EndIf
				if (searchStart >= samples)
//					printf "(1)searchStart=%d\r", searchStart
					found = 0
				EndIf
			EndIf
//			traces_analyzed += 1
		While((found==1) || (found ==10))
	EndFor
//	printf "found at end of getsweepminis=%.0f\r", found
	Return(found)
End

#include <Peak AutoFind>

function DetectMini(mode, traceName, searchStart, searchEnd, blTime, LAtime, Threshold, jumpTime, peakWindowTime, index, slope) // return mini start point
// return -1 if stop requested; 0 if end of trace and no mini; 1 if mini found and accepted; 10 if mini rejected;  
// searchStart is from last detection + jumpTime
	variable mode // 0 for now
	string traceName
	variable searchStart, searchEnd, blTime, LATime, Threshold, jumpTime, peakWindowTime, index, slope
	NVAR autoFlag
	NVAR samples, event_max
	WAVE results // results[0] = mini start, results[1] = mini amp
	WAVE trace = $traceName
	WAVE adc0_mini_avg, adc1_mini_avg, adc2_mini_avg, adc3_mini_avg //added by SPB 4-30-07
	NVAR afterSpike, spike_thresh
	NVAR update, initialize
	NVAR risePoints
	NVAR miniDrawPre, miniDrawPost, miniDuration
	NVAR trace_num
	variable temp, kk, t20, t80, riseTime
	variable blPoints = x2pnt(trace,blTime)
	variable jumpPoints = x2pnt(trace, jumpTime)
	variable peakWindowPoints = x2pnt(trace, peakWindowTime)
	variable LAPoints = x2pnt(trace, LATime)
	
	variable MiniStart, i, j, blValue, miniFound, Peak, halfPoint, midPoint,accept, miniStartVal
	WAVE trace = $traceName
	MiniStart = 0
	blValue = 0
//	printf "(DetectMini)searchStart=%d\r", searchStart
	if (searchStart >= samples)
		return(0)
	Endif
// clean markers
//	DoWindow /F Graph0
//	SetDrawLayer /K progback
	if (update)
		DoWindow /f g_traces
		SetDrawLayer /K progback
		DoWindow /F G_traces
//	ModifyGraph/z rgb(adc2)=(0,52224,0),rgb(adc1)=(0,43520,65280),rgb(adc3)=(0,0,0)
		if (stringmatch(traceName, "adc0"))
			setdrawenv linethick=1.5, linefgc=(65280,0,0), xcoord=bottom, ycoord=$get_yaxis(traceName)
		Endif
		if (stringmatch(traceName, "adc1"))
			setdrawenv linethick=1.5, linefgc=(0,43520,65280), xcoord=bottom, ycoord=$get_yaxis(traceName)
		Endif
		if (stringmatch(traceName, "adc2"))
			setdrawenv linethick=1.5, linefgc=(0,52224,0), xcoord=bottom, ycoord=$get_yaxis(traceName)
		Endif
		//added SPB 4-30-07
		if (stringmatch(traceName, "adc3"))
			setdrawenv linethick=1.5, linefgc=(0,0,0), xcoord=bottom, ycoord=$get_yaxis(traceName)
		Endif
		setdrawenv save
	Endif
	Variable timerRefNum
	Variable microSeconds


	
	miniFound = 0
	for (i = searchStart; i < searchEnd; i += 1)
		if (((i+blPoints+LAPoints) >= samples) || ((i+blPoints+peakWindowPoints) >= samples))
			return(0)
		Endif	
		blValue = mean(trace,pnt2x(trace,i),pnt2x(trace,i+blPoints))
		if (threshold > 0)
			if (trace[i+blPoints+LAPoints] > (blValue+Threshold))
				WaveStats/Q/R=[(i+blPoints), (i+blPoints+peakWindowPoints)] trace // find max
				if (V_maxloc == pnt2x(trace, (i+blPoints+peakWindowPoints)) || ((V_max-blValue) > event_max)) // if the peak is at the end of the segment it is probably a spike
					miniFound = 0
					if (V_max > spike_thresh)
						i = i + afterSpike
					Endif
				Else
					miniFound = 1
				Endif
//				WaveStats /Q/R=(V_maxloc,V_maxloc+miniDuration) trace
//				if ((V_min-blValue) < (V_max-blValue)*0.5)
				if ((V_max-blValue) > (mean(trace,V_maxloc,V_maxloc+miniDuration) - blValue) * 2.0 )
					miniFound = 0
				Endif		
			Else
				miniFound = 0
			EndIf
		Endif

		if (threshold < 0)
			if (trace[i+blPoints+LAPoints] < (blValue+Threshold))
				WaveStats/Q/R=[(i+blPoints), (i+blPoints+peakWindowPoints)] trace // find the min
				if (V_minloc == pnt2x(trace, (i+blPoints+peakWindowPoints)) || (abs((V_min-blValue)) > event_max))  // if the negative peak is at the end of the segment reject it
					miniFound = 0
				Else
					miniFound = 1
				Endif
			Else
				miniFound = 0
			EndIf
		Endif
		variable t_ref
		if (miniFound)
			CurveFit /N/Q/H="00" line trace(pnt2x(trace,i), pnt2x(trace, i+blPoints)) // if basline is on a slope reject
			if (k1 > slope || k1 < -slope)
				temp = pnt2x(trace,i)
				results[0] = temp
//				printf "reject #1\r"
				return(10)
			Endif
			if(update)
				DoWindow /f g_traces
				SetDrawLayer /K progback
				DoWindow /F G_traces
				if (stringmatch(traceName, "adc0"))
					setdrawenv linethick=1.5, linefgc=(65280,0,0), xcoord=bottom, ycoord=$get_yaxis(traceName)
				Endif
				if (stringmatch(traceName, "adc1"))
					setdrawenv linethick=1.5, linefgc=(0,43520,65280), xcoord=bottom, ycoord=$get_yaxis(traceName)
				Endif
				if (stringmatch(traceName, "adc2"))
					setdrawenv linethick=1.5, linefgc=(0,52224,0), xcoord=bottom, ycoord=$get_yaxis(traceName)
				Endif
				if (stringmatch(traceName, "adc3")) //added SPB
					setdrawenv linethick=1.5, linefgc=(0,0,0), xcoord=bottom, ycoord=$get_yaxis(traceName)
				Endif
//			setdrawenv linethick=1.5, linefgc=(0,26112,13056), xcoord=bottom, ycoord=$get_yaxis(traceName)
				setdrawenv save
			Endif

//			SetDrawLayer /K progback
			WaveStats/Q/R=[(i+blPoints), (i+blPoints+peakWindowPoints)] trace // find max or min
			if (Threshold > 0)
				peak = V_max - blValue
//				printf "peak: %f counts\r", peak
			Elseif (Threshold < 0)
				peak = V_min-blValue
//				FindPeak /Q/B=10/N/M=(V_min-peak*0.2)/R=[(i+blPoints), (i+blPoints+peakWindowPoints)] trace
//				printf "vmin=%.3f, Peak min = %.3f, peak_loc = %.3f\r", V_min-peak*0.2,V_PeakVal, V_Peakloc
			EndIf
			if (peak > event_max && Threshold > 0)
				temp = pnt2x(trace,i)
				results[0] = temp
//				printf "reject #2\r"
				return(10)
			Endif
			// find the midpoint from peak backwards
			if (Threshold > 0)
				for (j = x2pnt(trace,V_maxloc); j > (i + blPoints); j -= 1)
					if (trace[j] < blValue + peak/2)
						midPoint = j
//						printf "midpoint: %d points\r", j 
						break
					Endif
				Endfor
			ElseIf (Threshold < 0)
				for (j = x2pnt(trace,V_minloc); j > (i + blPoints); j -= 1)
					if (trace[j] > blValue + peak/2)
						midPoint = j
						break
					Endif
				Endfor
			EndIf

			CurveFit /N/Q/H="00" line trace(pnt2x(trace,midPoint-risePoints),pnt2x(trace,midPoint+risePoints))
			if (Threshold > 0 )
		// if event start occurs before end of baseline OR after maximum set results to time of i and return 10 to make a jump
				if ((x2pnt(trace,(blValue-k0)/k1) < (i + blPoints-1)) ||  ((blValue-k0)/k1 >= V_maxloc)) 
					temp = pnt2x(trace,i)
					results[0] = temp
//					printf "reject #3\r"
//					printf "start : %f\r", (x2pnt(trace,(blValue-k0)/k1)
//					printf "i: %d, blPoints: %d\r", i, blPoints
					return(10)
				Endif
			EndIf
			if (Threshold < 0)
				if ((x2pnt(trace,(blValue-k0)/k1) < (i + blPoints)) || ((blValue-k0)/k1 >= V_minloc))
					temp = pnt2x(trace,i)
					results[0] = temp
					return(10)
				Endif
			EndIf
			
	// draw a line over the rise phase
			if(update)
			 drawline pnt2x(trace,midPoint-risePoints), k0+k1*pnt2x(trace,midPoint-risePoints),pnt2x(trace,midPoint+risePoints), k0+k1*pnt2x(trace,midPoint+risePoints)
			 Endif
			 miniStart = x2pnt(trace, (blValue-k0)/k1)
			 miniStartVal = (blValue-k0)/k1
			if(update)	
			 drawline pnt2x(trace,i), blValue, pnt2x(trace, i+blPoints), blValue // draw baseline
			 if (Threshold > 0)
			  	drawline V_maxloc, blValue, V_maxloc, V_max // draw line to peak
			 ElseIf (Threshold < 0)
				drawline V_minloc, blValue, V_minloc, V_min
			 EndIf
			 setDrawEnv arrow=2, linethick = 1.5
			 drawline miniStartVal, blValue, miniStartVal, blValue-peak/3
//			printf "miniStartVal: %.3f\r", miniStartVal
//	if (spike_thresh > 100)
//		MiniStart = midPoint-2
//		ministartVal = pnt2x(trace,(midPoint-1))
//	Endif
			 plot_mini(miniStartVal-miniDrawPre, miniStartVal + miniDrawPost, initialize, traceName) //CHANGE BY SPB -- added tracename
			Endif
			if (initialize && update)
			 DoWindow /F Mini_Graph
			 SetDrawLayer /K progback
			 if (stringmatch(traceName, "adc0"))
			 	setdrawenv linethick=1.5, linefgc=(65280,0,0), xcoord=bottom, ycoord=$get_yaxis(traceName)
			 Endif
			 if (stringmatch(traceName, "adc1"))
				setdrawenv linethick=1.5, linefgc=(0,43520,65280), xcoord=bottom, ycoord=$get_yaxis(traceName)
			 Endif
			 if (stringmatch(traceName, "adc2"))
				setdrawenv linethick=1.5, linefgc=(0,52224,0), xcoord=bottom, ycoord=$get_yaxis(traceName)
			 Endif
			 if (stringmatch(traceName, "adc3")) //added SPB 4-30-07
				setdrawenv linethick=1.5, linefgc=(0,0,0), xcoord=bottom, ycoord=$get_yaxis(traceName)
			 Endif
			 setdrawenv save
	 	// draw a line over the rise phase
			drawline pnt2x(trace,midPoint-risePoints), k0+k1*pnt2x(trace,midPoint-risePoints),pnt2x(trace,midPoint+risePoints), k0+k1*pnt2x(trace,midPoint+risePoints)
		 	drawline pnt2x(trace,i), blValue, pnt2x(trace, i+blPoints), blValue
		 	results[3] = trace_num
			 If (Threshold > 0)
			 	drawline V_maxloc, blValue, V_maxloc, V_max
			 ElseIf (Threshold < 0)
			 	drawline V_minloc, blValue, V_minloc, V_min
			 Endif
			 setDrawEnv arrow=2, linethick = 1.5
			 drawline miniStartVal, blValue, miniStartVal, blValue-peak/3
			Endif
			if (Threshold > 0)
//				printf "miniStart : %d\r", miniStart
				for (kk = miniStart; kk < x2pnt(trace,V_maxloc); kk += 1)
					if (trace[kk] >= blValue+0.2 * peak)
						t20 = kk
//						printf "t20: %d\r" t20
						break
					endif
				endfor
//				printf "peak at  %d point\r", x2pnt(trace,V_maxloc)
				t80 = x2pnt(trace,V_maxloc)
				for (kk = t20; kk < x2pnt(trace,V_maxloc); kk += 1)
					if (trace[kk] >= blValue+0.8 * peak)
						t80 = kk
//						printf "t80: %d\r", t80
						break
					endif
				endfor
			 	riseTime = pnt2x(trace,t80)-pnt2x(trace,t20)
//			 	printf "rt: %f\r", riseTime
			 EndIf

			if (Threshold < 0)
				for (kk = miniStart; kk < x2pnt(trace,V_minloc); kk += 1)
					if (trace[kk] <= blValue+0.2 * peak)
						t20 = kk
						break
					endif
				endfor
				for (kk = t20; kk < x2pnt(trace,V_minloc); kk += 1)
					if (trace[kk] <= blValue+0.8 * peak)
						t80 = kk
						break
					endif
				endfor
			 	riseTime = pnt2x(trace,t80)-pnt2x(trace,t20)
			 EndIf
			if (abs(riseTime) > LATime*3 && spike_thresh < 100)
				results[0] = pnt2x(trace,i)
//				printf "reject #4\r"
				Return(10)
			EndIf
			if(update)
				DoWindow /F g_traces
			Endif
			
			
			
			
			
			
			// jump ahead
//			i += (blPoints+LAPoints+jumpPoints)
			if (update)
				Doupdate
			Endif
			string pstr
			sprintf pstr,  "%s,a=%.1f;St=%.1f;rt=%.2f;sl:%.1f (0:quit;1:accept;2:auto;3:skip;4:undo)", traceName, peak, miniStartVal,riseTime, results[3]
			pstr += "accept?"
			accept = 1
			if (autoFlag == 0)
				Prompt  accept, pstr//"peak = %.3f accept?", peak		// Set prompt for x param
				DoPrompt "Accept", accept 
			Else
				accept = 1
				V_flag = 0
			Endif
//			printf "V_flag = %.0f, accept = %.0f\r", V_flag, accept
			if ((V_flag == 0 && accept == 1) || (V_flag == 0 && accept == 2))
				temp = miniStartVal
				results[0] = temp
				results[1] = peak
				results[2] = riseTime
				if (accept == 2)
					autoflag = 1
				Endif
//				printf "returning from detectmini: 1\r"
				return(1)
			Endif
			if (V_flag == 1 && accept == 1) // cancel was entered
				temp = miniStartVal
				results[0] = temp
//				printf "trace: %s, miniStartVal=%.3f\r" traceName, results[0]
				results[1] = peak
				return(10)
			EndIf
			if (V_flag == 0 && accept == 3) // skip trace
				temp = miniStartVal
				results[0] = temp
//				printf "trace: %s, temp=%.12f; array=%.12f\r" traceName, temp, results[0]
				results[1] = peak
				return(3)
			EndIf


			if (V_flag == 0 && accept == 0) // 0 was entered
				temp = miniStartVal
				results[0] = temp
//				printf "trace: %s, temp=%.12f; array=%.12f\r" traceName, temp, results[0]
				results[1] = peak
				if (accept == 0)
					return (-1)
				Endif
				return(10)
			EndIf
		Endif
	EndFor
	Return(0) // no mini was found
End


function plot_mini(leftBottom, rightBottom, initplot,trace_w_mini)
	variable leftBottom, rightBottom, initplot
	string trace_w_mini
	NVAR mini_panel_display_flag
	if (initplot == 0)
		return(0)
	Endif
	DoWindow /k Mini_Graph
	Display /W=(3.6,228.2,403.2,412.4) adc0
	DoWindow /C Mini_Graph
	AppendToGraph/R adc1
	AppendToGraph/L=left2 adc2
	AppendtoGraph /R=right2 adc3 //SPB 4-30-07
	ModifyGraph margin(left)=40,margin(right)=22
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1)=(0,43520,65280),rgb(adc2)=(0,52224,0), rgb(adc3)=(0,0,0) //added SPB 4-30-07
	ModifyGraph tick(left)=2,tick(right)=2,tick(left2)=2, tick(right2)=2 //added SPB 4-30-07
	ModifyGraph font(left)="Arial",font(right)="Arial",font(left2)="Arial", font(right2)="Arial" //added SPB 4-30-07
	ModifyGraph fSize(left)=8,fSize(right)=8,fSize(left2)=8,fsize(right2)=8 //added SPB 4-30-07
	ModifyGraph axOffset(left)=4.14286,axOffset(right)=4.66667,axOffset(left2)=-10,axOffset(right2)=-10 //added SPB 4-30-07
	ModifyGraph tlblRGB(left)=(65280,0,0),tlblRGB(right)=(0,43520,65280),tlblRGB(left2)=(0,52224,0),tlblRGB(right2)=(0,0,0) //added SPB 4-30-07
	ModifyGraph lblPos(left)=44,lblPos(left2)=-6
	ModifyGraph lblLatPos(left2)=-1
	ModifyGraph btLen(left)=1,btLen(right)=1,btLen(left2)=1,btLen(right2)=1 //added SPB 4-30-07
	ModifyGraph btThick(left)=1,btThick(right)=1,btThick(left2)=1,btThick(right2)=1 //added SPB 4-30-07
	ModifyGraph stLen(left)=0.5,stLen(right)=0.5,stLen(left2)=0.5,stLen(right2)=0.5 //added SPB 4-30-07
	ModifyGraph stThick(left)=1,stThick(right)=1,stThick(left2)=1,stThick(right2)=1 //added SPB 4-30-07
	ModifyGraph freePos(left2)=21
	Label left "\\u#2"
	Label right "\\u#2"
	Label left2 "\\u#2"
	Label right2 "\\u#2"
	SetAxis bottom leftBottom, rightBottom
	WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc0
	SetAxis left V_min-0.2, V_max+0.2
	WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc1
	SetAxis right V_min-0.2, V_max+0.2
	WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc2
	SetAxis left2 V_min-0.2, V_max+0.2
	WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc3 //added SPB 4-30-07
	SetAxis right2 V_min-0.2, V_max+0.2 //added SPB 4-30-07
	//MUST ADD TOGGLE FLAG 
	//ADD argument when plot_mini called in detectMini
	//declare trace_w_mini
	//CHANGED FOR 4 CHANNELS SPB 4-30-07
	if (mini_panel_display_flag == 1)
		if (stringmatch (trace_w_mini,"adc0"))
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc1
			SetAxis right V_min+100, V_max+150
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc2
			SetAxis left2 V_min+100, V_max+150
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc3
			SetAxis right2 V_min+100, V_max+150
		elseif (stringmatch (trace_w_mini,"adc1"))
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc0
			SetAxis left V_min+100, V_max+150
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc2
			SetAxis left2 V_min+100, V_max+150
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc3
			SetAxis right2 V_min+100, V_max+150
		elseif (stringmatch (trace_w_mini,"adc2"))
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc0
			SetAxis left V_min+100, V_max+150
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc1
			SetAxis right V_min+100, V_max+150
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc3
			SetAxis right2 V_min+100, V_max+150
		elseif (stringmatch (trace_w_mini,"adc3"))
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc0
			SetAxis left V_min+100, V_max+150
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc1
			SetAxis right V_min+100, V_max+150
			WaveStats /Q/R=(leftBottom+5, rightBottom-15) adc2
			SetAxis left2 V_min+100, V_max+150
		endif
	endif
End



//
//function find_minis(CntrlName) : ButtonControl
//	String CntrlName
//	NVAR samples=samples, update=update, trace_start=trace_start, trace_end=trace_end, freq=freq, trace_num=trace_num
//	NVAR bin_type=bin_type, total_chan_num=total_chan_num, peak=peak, alternate=alternate
//	NVAR acquired=acquired,peak2peak=peak2peak,spike_duration=spike_duration,spike_thresh=spike_thresh,search_flag=search_flag,interactive=interactive
//	NVAR total_spikes=total_spikes,read_file_ref=read_file_ref,total_header_size=total_header_size, spike_num=spike_num, initialize=initialize
//	WAVE adc0=adc0, adc1=adc1, adc2=adc2,peaks=peaks,psth=psth, dac0_stimwave=dac0_stimwave, dac1_stimwave=dac1_stimwave,dac2_stimwave=dac2_stimwave
//	SVAR amp_trace_name=amp_trace_name
//	WAVE detection_trace = $amp_trace_name
//	NVAR baseline_points=baseline_points,points_to_cross=points_to_cross, peak_points=peak_points,peak_window=peak_window
//	NVAR amp_start=amp_start,amp_end=amp_end,amp_bl_start=amp_bl_start,amp_bl_end=amp_bl_end,peak_index=peak_index
//	variable index, num, k, j, i, baseline, start,mini_found
//	variable /g mini_location, number_of_minis, flag
//	if (initialize == 1) // initialize without query
//		Make /O/N=200 mini_trace, mini_average, mini_temp
//		Make /O/N=2000 mini_amplitudes, mini_histogram
//		mini_amplitudes = NaN
//		if ((bin_type == 0) %| (bin_type == 10) %| (bin_type == 100))
//			SetScale /P x, 0, (1.0/freq), "ms", mini_trace,mini_average
//		endif
//		if (((bin_type == 1) %| (bin_type == 2)) %& (total_chan_num == 2))
//			SetScale /P x, 0, (1.0/freq), "ms", mini_trace,mini_average
//			SetScale /P x, (0.5/freq), (1.0/freq), "ms", mini_trace,mini_average
//		endif
//		SetScale d, -200, 200, "mV", mini_trace,mini_average, mini_amplitudes
//		number_of_minis = 0
//		mini_average = 0
//		mini_temp = 0
//		mini_histogram = 0
//		number_of_minis = 0
//	Endif
//	trace_num = trace_start
//	num = 0
//	printf "trace_start=%d, trace_end=%d, alter: %d\r", trace_start,trace_end,alternate
//	Do
//	
//		if ((trace_start + num*alternate) > trace_end)
//			break
//		Endif
//		if (alternate != 0)
//			trace_num = trace_start + alternate * num
//			Get_a_trace(trace_num)
//		Endif
//		if ((alternate == 0) %& (num > 0))
//			Get_Next_Trace(alternate)
//		Endif
//		if ((alternate == 0) %& (num == 0))
//			Get_a_trace(trace_num)
//		Endif
//		num += 1
//
//// find minis
//		if (1 != stringmatch("one", CntrlName)) // only one requested keep old mini_location
//			mini_location = 0
//		Endif
//		
//		Do
//// get baseline		
//			mini_found = 0
//			baseline = 0
//			i = mini_location
//			Do
//				baseline += detection_trace[mini_location]
//				i += 1
//			While ((i-mini_location) < baseline_points)
//			baseline /= baseline_points
//// look for threshold crossing
//			if ((detection_trace[mini_location+points_to_cross] - baseline) > spike_thresh) // check for threshold crossing 
//				mini_found = 1
//			Endif
//			if (mini_found)
//				amp_bl_start = mini_location
//				amp_bl_end = mini_location + baseline_points
//				amp_start = amp_bl_end + 1
//				amp_end = amp_start + peak_window
//				peak = draw_amp(0)
//				if ((peak > 20) %| (peak_index == (amp_end-1))) // it is a spike or peak is at end of window
//					mini_found = 0
//					mini_location += 20 // jump to avoid repeats
//				Endif
//			Endif
//			if (mini_found)
//				printf "peak=%f\r", peak
//				if (interactive)
//					Execute ("BringDestFront(amp_trace_name)")
//					setaxis bottom, (mini_location -200)/freq, (peak_index + 200)/freq
//					setaxis $get_yaxis(amp_trace_name), baseline - peak*0.3, baseline+peak*1.3
//					setdrawlayer /K progback
//					setdrawenv linethick=1.2, linefgc=(0,26112,13056), xcoord=bottom, ycoord=$get_yaxis(amp_trace_name)
//					setdrawenv save
//					drawline pnt2x($amp_trace_name, amp_bl_start), baseline, pnt2x($amp_trace_name, amp_bl_end), baseline
//					drawline pnt2x($amp_trace_name, amp_start), (peak+baseline), pnt2x($amp_trace_name, amp_end), (peak + baseline)
//					drawline pnt2x($amp_trace_name, peak_index), (peak + baseline), pnt2x($amp_trace_name, peak_index), baseline
//					flag = 1
//					Execute ("approve()")
//				Else
//					flag = 1
//				Endif
//				printf "flag = %f\r", flag
//				if (flag == 1)
//					mini_amplitudes[number_of_minis] = peak
//					Histogram /B={0, 0.1, 200} /R=[0, (number_of_minis+1)] mini_amplitudes, mini_histogram
//					number_of_minis += 1
//					mini_trace[0,200]  =  detection_trace[mini_location-baseline_points + p] // excise mini from trace
//					mini_temp += mini_trace
//					mini_average = mini_temp / number_of_minis
//					if (update)
//						DoUpDate
//					Endif
//					mini_location += 20 // for now, jump to avoid repeats
//				Endif
//				mini_found = 0
//				if (1 == stringmatch("one", CntrlName))
//					break
//				Endif
//			Endif
//			mini_location += 1
//		While (mini_location < (samples-points_to_cross))
//		if (1 == stringmatch("one", CntrlName))
//			break
//		Endif
//		trace_num += 1	
//	While (trace_num < trace_end)
//	printf "number_of_minis: %d  trace(%d -> %d) done\r", number_of_minis, trace_start, trace_end
//	if (GetRTError(0))
//		print "Error in function average"
//		print GetRTErrMessage()
//	endif
//End
//
//Proc approve(v)
//	variable v = flag
//	prompt v, "accept ?"
//	flag = v
//End
//	
//function get_peaks(CntrlName) : ButtonControl
//	String CntrlName
//	NVAR trace_end=trace_end, trace_start=trace_start, get_peaks_flag=get_peaks_flag
//	Make /O/N=(trace_end - trace_start + 1) peaks
//	peaks = NaN
//	Doupdate
//	get_peaks_flag = 1
//	average()
//	get_peaks_flag = 0
//End
	
function get_peak(CntrlName) : ButtonControl
	String CntrlName
	NVAR trace_num
	WAVE /T analysis_trace_name_wave // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE analysed_points_wave  // the number of points analysed in the dpoints waves
	WAVE amp_analysis_flag_wave // if 1 do analysis
	WAVE amp_analysis_mode_wave  // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
//------------------------------------------------	
	NVAR number_of_pro, requested, adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag, scheme_on
	NVAR acquire_mode, draw_flag, peak, update
	variable i
	i = 0
	for (i = 0; i < 10; i += 1)
		if (amp_analysis_flag_wave[i])
	        		peak = Get_Amp(amp_analysis_mode_wave[i],analysis_trace_name_wave[i], amp_bl_start_wave[i], amp_bl_end_wave[i], amp_start_wave[i], amp_end_wave[i], "G_average")
	        	Endif
	EndFor
End
	
	
function smooth_trace()
	NVAR cutoff, freq, samples
	NVAR smoothAll
	NVAR adc_status0, adc_status1, adc_status2, adc_status3
	SVAR smooth_trace_name=smooth_trace_name
	Wave smooth_trace =  $smooth_trace_name
	variable fc // -3 db
	fc = cutoff / (freq*1000.0)
//	Smooth smooth_par, smooth_trace
	if (smoothAll)
		if (adc_status0)
			gfilt(adc0,samples,fc)
		Endif
		if(adc_status1)
			gfilt(adc1,samples,fc)
		Endif
		if(adc_status2)
			gfilt(adc2,samples,fc)
		Endif
		if(adc_status3)
			gfilt(adc3,samples,fc)
		Endif
		Return(0)
	EndIf
	gfilt(smooth_trace, samples, fc)
End
	
function align_traces()
	NVAR align_index, align_end, align_start
	NVAR align_thresh, spike_duration
	NVAR samples
	SVAR align_trace_name
	NVAR adc_status0, adc_status1, adc_status2, adc_status3
	WAVE adc0, adc1, adc2, adc3
	Wave align_trace = $align_trace_name
	Make /O /N=300 detections
	variable diff, i, num
	variable temp_align
	num = detect_ap_peaks(align_trace, align_thresh, spike_duration, align_start, align_end, detections)
	if (num == 0)
		printf "no spikes detected (align_traces())\r"
		Return(0)
	Endif
	diff = detections[0] - align_index
	if (diff < 0)
		if (adc_status0)
			temp_align = adc0[0]
			InsertPoints 0, (-diff), adc0
			i = 0
			do
				adc0[i] = temp_align
				i += 1
			while (i < (-diff))
			DeletePoints samples, (-diff), adc0
		Endif
		if (adc_status1)
			temp_align = adc1[0]
			InsertPoints 0, (-diff), adc1
			i = 0
			do
				adc1[i] = temp_align
				i += 1
			while (i < (-diff))
			DeletePoints samples, (-diff), adc1
		Endif
		if (adc_status2)
			temp_align = adc2[0]
			InsertPoints 0, (-diff), adc2
			i = 0
			do
				adc2[i] = temp_align
				i += 1
			while (i < (-diff))
			DeletePoints samples, (-diff), adc2
		Endif
		if (adc_status3)
			temp_align = adc3[0]
			InsertPoints 0, (-diff), adc3
			i = 0
			do
				adc3[i] = temp_align
				i += 1
			while (i < (-diff))
			DeletePoints samples, (-diff), adc3
		Endif
	Endif
	If (diff > 0)
		if (adc_status0)
			DeletePoints 0, diff, adc0
			InsertPoints (samples-diff), diff, adc0
			adc0[(samples-diff),samples] = adc0[(samples-diff-2)] 
			i = (samples-diff)
			do
				adc0[i] = adc0[(samples-diff-1)]
				i += 1
			while (i < samples)
		Endif
		if (adc_status1)
			DeletePoints 0, diff, adc1
			InsertPoints (samples-diff), diff, adc1
			adc1[(samples-diff),samples] = adc1[(samples-diff-2)] 
			i = (samples-diff)
			do
				adc1[i] = adc1[(samples-diff-1)]
				i += 1
			while (i < samples)
		Endif
		if (adc_status2)
			DeletePoints 0, diff, adc2
			InsertPoints (samples-diff), diff, adc2
			adc2[(samples-diff),samples] = adc2[(samples-diff-2)] 
			i = (samples-diff)
			do
				adc2[i] = adc2[(samples-diff-1)]
				i += 1
			while (i < samples)
		Endif
		if (adc_status3)
			DeletePoints 0, diff, adc3
			InsertPoints (samples-diff), diff, adc3
			adc3[(samples-diff),samples] = adc3[(samples-diff-2)] 
			i = (samples-diff)
			do
				adc3[i] = adc3[(samples-diff-1)]
				i += 1
			while (i < samples)
		Endif
	endif
End

#include <BringDestToFront>
function Draw_Amp(draw)
	variable draw
	NVAR amp_bl_end, amp_bl_start, amp_start, amp_end
	NVAR amplitude, peak, peak_dir, peak_index, peak_points
	NVAR peak_risetime,freq
	SVAR amp_trace_name
	NVAR draw_flag
	Wave amp_trace = $amp_trace_name
	if (draw)
		Execute ("BringDestFront(amp_trace_name)")
	Endif
//	doWindow /F $amp_window_name
	variable /g draw_set
	variable i, temp, baseline, first_halfpoint, second_halfpoint
	i = amp_bl_start
	temp = 0
	do
		temp += amp_trace[i]
		i += 1
	While (i < amp_bl_end)
	baseline = temp / (amp_bl_end - amp_bl_start)
	peak = amp_trace[amp_start]
	peak_index = amp_start
	i = amp_start
	do
		if ((peak_dir < 0) %& (amp_trace[i] < peak))
			peak = amp_trace[i]
			peak_index = i
		Endif
		if ((peak_dir > 0) %& (amp_trace[i] > peak))
			peak = amp_trace[i]
			peak_index = i
		Endif
		i += 1
	While (i < amp_end)
	i = peak_index - peak_points
	temp = 0
	do
		temp  += amp_trace[i]
		i += 1
	While (i <= (peak_index + peak_points))
	peak = temp / (peak_points*2 + 1)
	peak = peak - baseline
// now find 10-90 rise time, half-width
	variable low_value, hi_value, low_point, hi_point, half
	low_value = baseline + 0.1 * peak
	hi_value = baseline + 0.9 * peak
	half = baseline + 0.5 * peak
	i = amp_bl_end
	do
		if ((amp_trace[i] >= low_value) %& (peak_dir > 0))
			low_point = i
			break
		Endif
		if ((amp_trace[i] <= low_value) %& (peak_dir < 0))
			low_point = i
			break
		Endif
		i += 1
	While(i < peak_index)
	i = amp_bl_end
	do
		if ((amp_trace[i] >= hi_value) %& (peak_dir > 0))
			hi_point = i
			break
		Endif
		if ((amp_trace[i] <= hi_value) %& (peak_dir < 0))
			hi_point = i
			break
		Endif
		i += 1
	While(i < peak_index)
	peak_risetime = (hi_point - low_point ) * (1.0/ freq)
// half-width	
	i = amp_bl_end	
	do
	if ((amp_trace[i] >= half) %& (peak_dir > 0))
		first_halfpoint = i
		break
	Endif
	if ((amp_trace[i] <= half) %& (peak_dir < 0))
		first_halfpoint = i
		break
	Endif
		i += 1
	While(i < peak_index)
	i = peak_index	
	do
	if ((amp_trace[i] <= half) %& (peak_dir > 0))
		second_halfpoint = i
		break
	Endif
	if ((amp_trace[i] >= half) %& (peak_dir < 0))
		second_halfpoint = i
		break
	Endif
		i += 1
	While(i < amp_end)
	printf "half-width = %.3f\r", (second_halfpoint - first_halfpoint ) * (1.0/ freq)

	if (draw)
		setdrawlayer /K progback
		setdrawenv linethick=1.2, linefgc=(0,26112,13056), xcoord=bottom, ycoord=$get_yaxis(amp_trace_name)
		setdrawenv save
		drawline pnt2x(amp_trace, amp_bl_start), baseline, pnt2x(amp_trace, amp_bl_end), baseline
		drawline pnt2x(amp_trace, amp_start), (peak+baseline), pnt2x(amp_trace, amp_end), (peak + baseline)
		drawline pnt2x(amp_trace, peak_index), (peak + baseline), pnt2x(amp_trace, peak_index), baseline
	Endif
	return(peak)
End


function do_histogram()
	variable num 
	WAVE psth=psth
	WAVE adc0=adc0, adc1=adc1
	NVAR spike_thresh=spike_thresh, spike_duration=spike_duration, trace_start=trace_start, trace_end=trace_end, spike_num=spike_num
	NVAR bin_type=bin_type, total_chan_num=total_chan_num,update=update,trace_num=trace_num,init_analysis=init_analysis
	NVAR bin_size=bin_size, acquired=acquired, samples=samples, freq=freq, total_spikes=total_spikes
	NVAR spike_start=spike_start, spike_end=spike_end, discriminate=discriminate, traces_analyzed=traces_analyzed,alternate=alternate
	SVAR spike_detection_trace_name=spike_detection_trace_name
	Wave analyzed_trace = $spike_detection_trace_name
	Make /O/N=(samples) detect_temp_trace, detect_avg_trace
	if ((bin_type == 0) %| (bin_type == 10) %| (bin_type == 100))
		SetScale /P x, 0, (1.0/freq), "ms", detect_temp_trace, detect_avg_trace
	endif
	if (bin_type == 1)
		SetScale /P x, 0, (1.0/freq), "ms", detect_temp_trace, detect_avg_trace
	endif
	SetScale d, -200, 200, "mV", detect_avg_trace 
	variable m, kk, i, include_trace
	variable /g total_interval_num
	make /o /n=300 detections
	if (init_analysis == 1)
		make /O/N=100000 total_detections
		Make /O/N=100000 total_intervals_detected
		Make /O isi_his
		traces_analyzed = 0
		total_spikes= 0
		total_interval_num = 0
	Endif
	num = -1
//	total_detections = 0
	detect_avg_trace = 0
	detect_temp_trace = 0
	trace_num = trace_start
	DoWindow /F S_Histogram
	do
		num += 1
		if (alternate == 0)
			If ((trace_start + num) >= trace_end)
				break
			Else
				trace_num = trace_start + num
			Endif
		Endif
		If (alternate > 0)
			if ((trace_start + num*alternate) >= trace_end)
				break
			Else
				trace_num = trace_start + num*alternate
			Endif
		Endif
		Get_a_trace(trace_num)
		detections = 0
		spike_num = detect_ap_peaks($spike_detection_trace_name, spike_thresh, spike_duration, 0, samples, detections)
		include_trace = 1
		if (discriminate == 1)
			include_trace = 0
			kk = 0
			do
				if ((detections[kk] >= spike_start) %& (detections[kk] < spike_end))
					include_trace = 1
					break
				Endif
				kk += 1
			While(kk < spike_num)
		endif
		if (discriminate == -1)
			include_trace = 1
			kk = 0
			do
				if ((detections[kk] >= spike_start) %& (detections[kk] < spike_end))
					include_trace = 0
					break
				Endif
				kk += 1
			While(kk < spike_num)
		endif
		if (include_trace == 1)
			kk = 0
			do
				if (spike_num == 0)
					break
				Endif
				total_detections[total_spikes] = detections[kk]
				total_spikes += 1
				kk += 1
			While(kk < spike_num)
			Histogram /B={0, bin_size, (samples/bin_size)} /R=[0, (total_spikes-1)] total_detections, psth
			if (bin_type == 1)
				psth *= ((freq*1000.0/1.0)/(bin_size*(traces_analyzed+1))) 
			Endif
			if ((bin_type == 0) %| (bin_type == 10) %| (bin_type == 100))
				psth *= ((freq*1000)/(bin_size*(traces_analyzed+1)))
			endif
			if ((bin_type == 0) %| (bin_type == 10) %| (bin_type == 100))
				Setscale /I x, 0, (samples/freq), "ms", psth
			Endif
			if (bin_type == 1)
				SetScale /I x, 0, (samples/(freq/1.0)), "ms", psth
			Endif
			SetScale d, 0, 200, "Frequency (Hz)", psth
			detect_temp_trace += analyzed_trace
			detect_avg_trace = detect_temp_trace / traces_analyzed
			kk = 0
			do
				if (spike_num < 2)
					break
				endif
				total_intervals_detected[total_interval_num] = (detections[kk+1] - detections[kk])/freq
				total_interval_num += 1
				kk += 1
			While((kk+1) < spike_num)
			Histogram /B={0, (bin_size/freq), (samples/bin_size)} /R=[0, (total_interval_num-1)] total_intervals_detected, isi_his
			traces_analyzed += 1
			if (update)
				DoUpDate
			Endif
		Endif
	While (trace_num <= trace_end)
	if (GetRTError(0))
		print "Error in function do_histogram"
		print GetRTErrMessage()
	endif
//	Killwaves /Z total_interval_detected
End


function do_xcorrelation(flag)
	variable flag // 1: adc0Xadc1; 0: adc0Xadc0; 2: shift by one trace (?); 10: adc1Xadc1; -1: adc1Xadc0
	variable num
	WAVE psth=psth
	WAVE adc0=adc0, adc1=adc1
	NVAR spike_thresh=spike_thresh, spike_duration=spike_duration, trace_start=trace_start, trace_end=trace_end, spike_num=spike_num
	NVAR bin_type=bin_type, total_chan_num=total_chan_num
	NVAR bin_size=bin_size, acquired=acquired, samples=samples, freq=freq, total_spikes=total_spikes
	NVAR spike_start=spike_start, spike_end=spike_end, discriminate=discriminate, traces_analyzed=traces_analyzed
	NVAR x_window // window for correlation
	SVAR spike_detection_trace_name=spike_detection_trace_name
	
	Make /O/N=(samples) detect_temp_trace, detect_avg_trace
	if ((bin_type == 0) %| (bin_type == 10) %| (bin_type == 100))
		SetScale /P x, 0, (1.0/freq), "ms", detect_temp_trace, detect_avg_trace
	endif
	if (bin_type == 1)
		SetScale /P x, 0, (1.0/freq), "ms", detect_temp_trace, detect_avg_trace
	endif
	SetScale d, -200, 200, "mV", detect_avg_trace 
	variable m, kk, mm, i, j, include_trace, spikes_0, spikes_1, tm, mid_point
	make /o /n=1000 detections_0, detections_1
	make /O/N=((freq/bin_size)*x_window*2) psth = 0 // +/- 50 ms
	make /O/N=((freq/bin_size)*x_window*2) temp_psth = 0
	SetScale /P x, -(x_window), (bin_size/freq), "ms", psth
	SetScale d, 0, x_window*2, "Spike Frequency (Hz)", psth
	mid_point = ((freq/bin_size)*x_window*2) /2
	i = 0
	j = 0
	traces_analyzed = 0
	total_spikes = 0 // accumulate reference train spikes
	temp_psth = 0
	num = trace_end - trace_start
//	if (flag == 2)
//		get_a_trace(trace_start+i)
//	Endif
	do
		if (flag != 2)
			get_a_trace(trace_start+i)
		Endif
		if (flag == 1)
			spikes_0 = detect_ap_peaks(adc0, spike_thresh, spike_duration, 1000, (samples-1000), detections_0)
			spikes_1 = detect_ap_peaks(adc1, spike_thresh, spike_duration, 500, (samples-500), detections_1)
		endif
		if (flag == -1)
			spikes_0 = detect_ap_peaks(adc1, spike_thresh, spike_duration, 1000, (samples-1000), detections_0)
			spikes_1 = detect_ap_peaks(adc0, spike_thresh, spike_duration, 500, (samples-500), detections_1)
		endif
		if (flag == 0)
			spikes_0 = detect_ap_peaks(adc0, spike_thresh, spike_duration, 1000, (samples-1000), detections_0)
			spikes_1 = detect_ap_peaks(adc0, spike_thresh, spike_duration, 500, (samples-500), detections_1)
		Endif
		if (flag == 10)
			spikes_0 = detect_ap_peaks(adc1, spike_thresh, spike_duration, 1000, (samples-1000), detections_0)
			spikes_1 = detect_ap_peaks(adc1, spike_thresh, spike_duration, 500, (samples-500), detections_1)
		Endif
		if (flag == 2)
			get_a_trace(trace_start+i)
			spikes_0 = detect_ap_peaks(adc0, spike_thresh, spike_duration, 1000, (samples-1000), detections_0)
			get_a_trace(trace_start+i+1)
			spikes_1 = detect_ap_peaks(adc1, spike_thresh, spike_duration, 500, (samples-500), detections_1)
//			get_a_trace(trace_start+i)
		Endif
		detections_0 /= bin_size  // to get detections in units of bin_size
		detections_1 /= bin_size
		mm = 0
		do
			if ((spikes_0 == 0) %| (spikes_1 == 0))
				break
			Endif

			kk = 0
			do
				tm = detections_1[kk] - detections_0[mm]
//				printf "tm: %f\r", tm
//				printf "spikes_0: %f; spikes_1: %f\r", spikes_0, spikes_1
				if ((tm >= 0) %& (tm < mid_point))
					psth[mid_point + tm] += 1
				Endif
				if ((tm < 0) %& ((-tm) < mid_point))
					psth[mid_point + tm] += 1
				Endif
				kk += 1
			while (kk < spikes_1)
			mm += 1
		While(mm < spikes_0)
		j += 1
		traces_analyzed = j
		if ((spikes_0 == 0) %| (spikes_1 == 0))
			;
		Else
			total_spikes += spikes_0
		Endif
		DoUpDate
		i += 1
	While (i < num)
	if (GetRTError(0))
		print "Error in function do_xcorrelation"
		print GetRTErrMessage()
	endif
End

function get_spikes4(adc0_start1, adc0_end1, adc0_start2, adc0_end2, adc1_start1, adc1_end1, adc1_start2,adc1_end2)
	variable adc0_start1, adc0_end1, adc0_start2, adc0_end2, adc1_start1, adc1_end1, adc1_start2,adc1_end2
	variable num
	WAVE adc0=adc0, adc1=adc1
	NVAR spike_thresh=spike_thresh, spike_duration=spike_duration, trace_start=trace_start, trace_end=trace_end, spike_num=spike_num
	NVAR bin_type=bin_type, total_chan_num=total_chan_num
	NVAR bin_size=bin_size, acquired=acquired, samples=samples, freq=freq, total_spikes=total_spikes
	NVAR spike_start=spike_start, spike_end=spike_end, discriminate=discriminate, traces_analyzed=traces_analyzed
	Make /O/N=(acquired) adc0_first, adc0_second, adc1_first, adc1_second
	variable m, kk, mm, i, j, include_trace
	make /o /n=300 detections
	i = 0
	j = 0
	traces_analyzed = 0
//	total_detections = 0
	num = trace_end - trace_start
	
	do
		get_a_trace(trace_start+i)
		adc0_first[i] = detect_ap_peaks(adc0, spike_thresh, spike_duration, adc0_start1, adc0_end1, detections)
		adc0_second[i] = detect_ap_peaks(adc0, spike_thresh, spike_duration, adc0_start2, adc0_end2, detections)
		adc1_first[i] = detect_ap_peaks(adc1, spike_thresh, spike_duration, adc1_start1, adc1_end1, detections)
		adc1_second[i] = detect_ap_peaks(adc1, spike_thresh, spike_duration, adc1_start2, adc1_end2, detections)
		DoUpDate
		i += 1
	While (i < num)
End



Function FindSingleUnitsInTrace(trace, thresh, duration, peak2peak, start, end, detections)
	wave trace
	wave detections
	variable thresh, duration, peak2peak, start, end


// local variables	
	
	variable i, k=0, positive_peak, negative_peak, peak_index
	detections = 0
	i = start
	k = 0
	do
		if (trace[i] > thresh)   // a threshold crossing at i
			positive_peak = trace[i]
			peak_index = i
			do
				 i += 1
				 if (((i-peak_index) > duration) %| (trace[i] < thresh))
//				 	detections[k] = peak_index
//				 	k += 1
				 	break
				Endif 
				if (trace[i] > positive_peak)
					positive_peak = trace[i]
					peak_index = i
				Endif
			While(1)
			i = peak_index
// now find the negative peak	
			i += 1
			negative_peak = trace[i]
			do
				i += 1
				if ((i-peak_index) > duration)
					if ((positive_peak - negative_peak) > peak2peak)
						detections[k] = peak_index
						k += 1
						break
					Else
						break
					Endif
				Endif
				if (trace[i] < negative_peak)
					negative_peak = trace[i]
				Endif
			While(1)
		Endif		// end of a single detection
		i += 1		
	While(i < end)
Return(k) // return number of detections

End



Function average_detected(start,end,length,num)
	variable start, end, length, num

	variable i, trace_num
	variable counts, diff
	NVAR spike_start=spike_start, spike_end=spike_end, samples=samples,freq=freq
	WAVE detect_avg_trace=detect_avg_trace
	NVAR spike_thresh=spike_thresh, spike_duration=spike_duration, trace_start=trace_start, trace_end=trace_end, spike_num=spike_num
	NVAR update=update, bin_type=bin_type, traces_analyzed=traces_analyzed
	NVAR samples=samples, total_spikes=total_spikes
	NVAR spike_start=spike_start, spike_end=spike_end
	SVAR spike_detection_trace_name=spike_detection_trace_name
	Wave analyzed_trace = $spike_detection_trace_name
	diff = end - start
	Make /O/N=(samples) detect_temp_trace, detect_avg_trace
	if ((bin_type == 0) %| (bin_type == 10) %| (bin_type == 100))
		SetScale /P x, 0, (1.0/freq), "ms", detect_temp_trace, detect_avg_trace
	endif
	if (bin_type == 1)
		SetScale /P x, 0, (1.0/freq), "ms", detect_temp_trace, detect_avg_trace
	endif
	SetScale d, -200, 200, "mV", detect_avg_trace 
	variable m, kk, j, include_trace
	make /O /N=300 detections
	make /O/N=100000 total_detections
	Make /O/N=100000 total_intervals_detected
	Duplicate /O detect_avg_trace, detected_multi_avg_trace
	DeletePoints 0, (samples-length), detected_multi_avg_trace
	Duplicate /O detected_multi_avg_trace, temp_multi_trace
	
	traces_analyzed = 0
	detected_multi_avg_trace = 0
	if (update)
		DoUpDate
	Endif
	temp_multi_trace = 0
	trace_num = trace_start
	Do
		detections = 0
		total_spikes = 0
		get_a_trace(trace_num)
		spike_num = detect_ap_peaks($spike_detection_trace_name, spike_thresh,spike_duration, 0, samples, detections)
		i = 0
		Do
			spike_start = start + diff*i
			spike_end = end + diff*i
			kk = 0
			include_trace = 1
			Do
				if ((detections[kk] >= spike_start) %& (detections[kk] < spike_end))
					include_trace = 0
				Endif
				kk += 1
			While (kk < spike_num)
			if (include_trace)
				temp_multi_trace[0,length] += analyzed_trace[spike_start+p]
				traces_analyzed += 1
				detected_multi_avg_trace = temp_multi_trace / traces_analyzed
				if (update)
					DoUpDate
				Endif
			Endif
			i += 1
		While (i < num)
		trace_num += 1
	While(trace_num < trace_end)
End




Function detect_multi(start,end,length,num)
	variable start, end, length, num
	variable counts, i, diff
	NVAR spike_start=spike_start, spike_end=spike_end, samples=samples
	WAVE detect_avg_trace=detect_avg_trace
	diff = spike_end - spike_start
	Duplicate /O detect_avg_trace, detected_multi_avg_trace
	DeletePoints 0, (samples-length), detected_multi_avg_trace
	Duplicate /O detected_multi_avg_trace, temp_multi_trace
	detected_multi_avg_trace = 0
	temp_multi_trace = 0
	counts = 0
	Do
		get_a_trace(1)
		spike_start = start + diff*counts
		spike_end = end + diff*counts
		do_histogram()
		counts += 1
//		i = 0
//		Do
//			temp_multi_trace[i] += detect_avg_trace[spike_start+i]
//			i += 1
//		While (i < length)
		temp_multi_trace[0,length] += detect_avg_trace[spike_start+p] 
		detected_multi_avg_trace = temp_multi_trace / counts
		DoUpdate
	While (counts < num)
End


Function detect_epsp(length)
	variable length
	variable i
	NVAR samples=samples, spike_start=spike_start, spike_end=spike_end
	WAVE detect_avg_trace=detect_avg_trace
	Duplicate /O detect_avg_trace, detected_epsp_trace
	DeletePoints 0, (samples-length), detected_epsp_trace
	i = 0
	Do
		detected_epsp_trace[i] = detect_avg_trace[spike_start+i]
		i += 1
	While (i < length)
End

function histo_vm(CntrlName) : ButtonControl
	String CntrlName
	SVAR analyzed_trace=analyzed_trace
	WAVE trace = $analyzed_trace
	NVAR trace_start=trace_start, trace_end=trace_end,f_start=f_start,f_end=f_end,alternate=alternate
	Make /O histog_vm, temp_his
	variable i, total_points, num
	variable bin_size
	bin_size = 0.5
	i = trace_start
	total_points = 0
	histog_vm = 0
	temp_his = 0
	DoWindow /K histo_vm_graph
	Display /W=(4.2,238.4,399.6,411.2) histog_vm
	DoWindow /C histo_vm_graph
	num = 0
	Histogram/A/R=[f_start,f_end]/B={-100,bin_size,300} trace,histog_vm
	Do
		get_a_trace(i)
		num += 1
		Histogram/A/R=[f_start,f_end]/B={-100,bin_size,300} trace,temp_his
		histog_vm = temp_his / bin_size
		total_points = sum(temp_his,-100,150)
		if (total_points != 0)
			histog_vm /= total_points
		Endif
		DoUpdate
		if (alternate != 0)
			i = i + alternate
		Else
			i += 1
		Endif
	While (i < trace_end)
	KillWaves /Z temp_his
	printf "%d traces analyzed\r", num
	printf "average: %.3f \r", get_expectation(histog_vm, 300)	
End

function histo_peaks(CntrlName) : ButtonControl
	String CntrlName
	SVAR analyzed_trace=analyzed_trace
	WAVE trace = $analyzed_trace
	NVAR trace_start=trace_start, trace_end=trace_end,f_start=f_start,f_end=f_end,alternate=alternate
	Make /O histog_vm, temp_his
	variable i, rising, j, total_peaks, num
	variable bin_size
	variable number_of_peaks
	bin_size = 0.5
	i = trace_start
	histog_vm = 0
	DoWindow /K histo_vm_graph
	Display /W=(4.2,238.4,399.6,411.2) histog_vm
	DoWindow /C histo_vm_graph
	number_of_peaks = 0
	Histogram/A/R=[0,(number_of_peaks-1)]/B={-100,bin_size,300} peaks_trace,histog_vm
	temp_his = 0
	total_peaks = 0
	num = 0
	Do
		get_a_trace(i)
		num += 1
		Duplicate /O trace, peaks_trace
		number_of_peaks = 0
// construct a trace of peaks		
		j = f_start
		if (trace[j+1] > trace[j])
			rising = 1
		Else
			rising = 0
		Endif
		j = j+1 
		Do
			if ((j+1) >= f_end)
				break
			Endif
			if (rising == 1)
				if (trace[j+1] <= trace[j])
					peaks_trace[number_of_peaks] = trace[j]
					number_of_peaks += 1
					rising = 0
					j = j +1
				Else
					j += 1
				Endif
			Endif
			if (rising == 0)
				if (trace[j+1] <= trace[j])
					j += 1
				Endif
				If (trace[j+1] > trace[j])
					rising = 1
					j += 1
				Endif
			Endif
		While(1)
		total_peaks += number_of_peaks
		if (number_of_peaks > 0)
			Histogram/A/R=[0,(number_of_peaks-1)]/B={-100,bin_size,300} peaks_trace,temp_his
			histog_vm = temp_his / bin_size
			if (total_peaks != 0)
				histog_vm /= total_peaks
			Endif
			DoUpdate
		Endif
		if (alternate != 0)
			i = i +alternate
		Else
			i += 1
		Endif
	While (i < trace_end)
	Killwaves /Z temp_his
	printf "%d traces analyzed, total_peaks = %d\r", num, total_peaks
	printf "average: %.3f \r", get_expectation(histog_vm, 300)
End

// will look for crossing of threshold in derivative of trace between f_start and f_end
// first find spikes then look at the trace derivative and find if within the peak window from spike peak there was a crossing of 
// the threshold (deriv_thresh).
function histo_thresh(CntrlName) : ButtonControl
	String CntrlName
	SVAR analyzed_trace=analyzed_trace
	WAVE trace = $analyzed_trace
	NVAR trace_start=trace_start, trace_end=trace_end,f_start=f_start,f_end=f_end,alternate=alternate,spike_thresh=spike_thresh,samples=samples
	NVAR peak_window=peak_window,deriv_thresh=deriv_thresh,compare_flag=compare_flag
	Make /O histog_vm, temp_his
	Make /O/N=200 detections // for use with function : detect_ap_peaks()
	variable i,  j, num, spike, k, detected, analyze, detect1, detect2
	variable number_of_spikes // in each trace between f_start and f_end
	variable bin_size, temp
	variable TotalNumberofSpikes
	TotalNumberofSpikes = 0
	bin_size = 0.5
	histog_vm = 0
	DoWindow /F histo_vm_graph
//	DoUpDate
	number_of_spikes = 0
	Duplicate /O trace, threshold_wave
	Histogram/A/R=[0,(number_of_spikes-1)]/B={-100,bin_size,300} threshold_wave,histog_vm
	temp_his = 0
	num = 0
	i = trace_start
// begin main loop	
	Do
		analyze = 1
		if (compare_flag != 0) // check that spikes detected in i trace but not in i + compare_flag
			get_a_trace(i+compare_flag)
			detected = Detect_ap_peaks(trace, spike_thresh, peak_window, 0,  samples, detections)
			k = 0
			detect2 = 0
			Do
				if ( (detections[k] >= f_start) %& (detections[k] <= f_end) )
					detect2 = 1
					break
				else
					k += 1
				Endif
			While (k < detected)
			get_a_trace(i)
			detected = Detect_ap_peaks(trace, spike_thresh, peak_window, 0,  samples, detections)
			k = 0
			detect1 = 0
			Do
				if ( (detections[k] >= f_start) %& (detections[k] <= f_end) )
					detect1 = 1
					break
				else
					k += 1
				Endif
			While (k < detected)
			if ( (detect1 == 1) %& (detect2 == 0) )
				analyze = 1
			Else
				analyze = 0
			Endif
		Else
			get_a_trace(i)
		Endif
		num += 1
		Duplicate /O trace, trace_copy
		detected = Detect_ap_peaks(trace, spike_thresh, peak_window, 0,  samples, detections)

// check if spike occurred		
			
		if ((detected > 0) %& (analyze))
			Differentiate trace_copy // replacing trace_copy with its derivative		
			k = 0
			number_of_spikes = 0
			Do
				if ( (detections[k] >= f_start) %& (detections[k] <= f_end) )
					j = detections[k]// look backwards for the spike threshold in the peak window before spike peak
				// first look for peak in derivative	
					temp = trace_copy[j]
					Do
						j  -= 1
						if (trace_copy[j] >= temp)
							temp = trace_copy[j]
						Else
							break
						Endif
					While(j > (detections[k]-peak_window))
					Do
						j  -= 1
						if (trace_copy[j] <= deriv_thresh)
							threshold_wave[number_of_spikes] = trace[j]
							printf "trace:#: %d, (%d): %d value: %.2f\r", i, number_of_spikes, j, trace[j]
							number_of_spikes += 1
							break
						Endif
					While(j > (detections[k]-peak_window))
				Endif
				k += 1
			While (k < detected)
			TotalNumberofSpikes += number_of_spikes
			if (number_of_spikes > 0)
				Histogram/A/R=[0,(number_of_spikes-1)]/B={-100,bin_size,300} threshold_wave,temp_his
				histog_vm = temp_his / bin_size
				if (TotalNumberofSpikes != 0)
					histog_vm /= TotalNumberofSpikes // normalize histogram
				Endif
				DoUpdate
			Endif
		Endif
		if (alternate != 0)
			i = i +alternate
		Else
			i += 1
		Endif
	While (i < trace_end)
	Killwaves /Z temp_his
	printf "%d traces analyzed, total_spikes = %d\r", num, TotalNumberofSpikes
	printf "average: %.3f \r", get_expectation(histog_vm, 300)
End

function Average_excitation(CntrlName) : ButtonControl
	String CntrlName
	SVAR analyzed_trace=analyzed_trace
	WAVE trace = $analyzed_trace
	NVAR trace_start=trace_start, trace_end=trace_end,f_start=f_start,f_end=f_end,samples=samples,freq=freq
	NVAR stimfile_loc=stimfile_loc,stimfile_ref=stimfile_ref, dac0_gain=dac0_gain,dac0_stimfile_scale=dac0_stimfile_scale
	NVAR dac1_gain=dac1_gain,dac2_gain=dac2_gain
	NVAR spike_thresh=spike_thresh,spike_duration=spike_duration,compare_flag=compare_flag,alternate=alternate,dac_num=dac_num
	WAVE stimfile_wave=stimfile_wave, dac0_stimwave=dac0_stimwave,dac1_stimwave=dac1_stimwave,dac2_stimwave=dac2_stimwave
	Make /O/N=(samples) stim_temp, stim_temp_buf, twave
	SetScale /P x, 0, (1/freq), "ms", twave, stimfile_wave
	variable i,  num, var_buf, var_temp
	var_buf = 0
	stim_temp_buf = 0
	twave = 0
	Dowindow /K Excitation_Graph
	Display /W=(6.6,234.2,402,411.8) twave
	DoWindow /C Excitation_Graph
	i = trace_start
	stimfile_loc = i
	num = 0
	Do
		get_a_trace(i)
		num += 1
//		FSetPos stimfile_ref, (stimfile_loc * samples * 2) 
//		FBinRead /F=2 stimfile_ref, stimfile_wave
//		stimfile_wave *= dac0_stimfile_scale
//		stim_temp_buf += stimfile_wave
		set_stim()
		if (dac_num == 0)
			stim_temp_buf += (dac0_stimwave / (3.2 * dac0_gain))
			twave = stim_temp_buf / num
		Endif
		if (dac_num == 1)
			stim_temp_buf += (dac1_stimwave / (3.2 * dac1_gain))
			twave = stim_temp_buf / num
		Endif
		if (dac_num == 2)
			stim_temp_buf += (dac2_stimwave / (3.2 * dac2_gain))
			twave = stim_temp_buf / num
		Endif
		DoUpdate
		if (alternate == 0)
			i += 1
		Else
			i = i + alternate
		Endif
		stimfile_loc = i
	While (i < trace_end)
End

function STA_fixed(CntrlName) : ButtonControl
	String CntrlName
	SVAR analyzed_trace=analyzed_trace
	WAVE trace = $analyzed_trace
	NVAR trace_start=trace_start, trace_end=trace_end,f_start=f_start,f_end=f_end,samples=samples,freq=freq
	NVAR stimfile_loc=stimfile_loc,stimfile_ref=stimfile_ref, dac0_gain=dac0_gain,dac0_stimfile_scale=dac0_stimfile_scale
	NVAR spike_thresh=spike_thresh,spike_duration=spike_duration,compare_flag=compare_flag
	WAVE stimfile_wave=stimfile_wave
	Make /O/N=(samples) stim_temp, stim_temp_buf, twave,detections
	SetScale /P x, 0, (1/freq), "ms", twave, stimfile_wave
	variable i,  num, var_buf, var_temp
	var_buf = 0
	stim_temp_buf = 0
	i = trace_start
	num = 0
	if (compare_flag == 0)
	   Do
		get_a_trace(i)
		if ( 0 != Detect_ap_peaks(trace, spike_thresh, spike_duration, f_start, f_end, detections))
			num += 1
			FSetPos stimfile_ref, (stimfile_loc * samples * 2) 
			FBinRead /F=2 stimfile_ref, stimfile_wave
			stimfile_wave *= dac0_stimfile_scale
			stim_temp_buf += stimfile_wave
			twave = stim_temp_buf / num
			DoUpdate
		Endif
		stimfile_loc += 1
		i += 1
	    While (i < trace_end)
	 Endif
	 if (compare_flag == 1) // look for spike alternating with no spike
	   Do
		get_a_trace(i)
		i += 1
		if ( 0 != Detect_ap_peaks(trace, spike_thresh, spike_duration, f_start, f_end, detections))
			get_a_trace(i)
			i += 1
			if ( 0 == Detect_ap_peaks(trace, spike_thresh, spike_duration, f_start, f_end, detections))
				num += 1 // found it
				FSetPos stimfile_ref, (stimfile_loc * samples * 2) 
				FBinRead /F=2 stimfile_ref, stimfile_wave
				stimfile_wave *= dac0_stimfile_scale
				stim_temp_buf += stimfile_wave
				twave = stim_temp_buf / num
				DoUpdate
			Endif
		Else
			i += 1
		Endif
		stimfile_loc += 1
	    While (i < (trace_end-1))
	 Endif
End



function set_cursors_trace(CntrlName) : ButtonControl // get name of trace and cursor points for analysis
	String CntrlName
	SVAR analyzed_trace=analyzed_trace
	NVAR f_start=f_start, f_end=f_end
	analyzed_trace = CsrWave(A)
	f_start = pcsr(a)
	f_end = pcsr(b)
End

// SaveGraph 1.1
//
//  Creates an Igor Text file that will be able to recreate the target graph (including the data)
//  in another experiment.
//
// To use, simply bring the graph you wish to save to the front and select "Save Graph"
// from the Macros menu.  You will be presented with a save dialog. 
// Later, in another experiment, you can use the "Load Igor Text..." item from the Data menu 
// to load the file. The data will be loaded and the graph will be regenerated. 
//
// "Save Graph" makes an Igor Text file that, when later loaded,  will load the data into a data folder
// of the same name as your graph.  If there are conflicts in the wave names, subfolders called
// data1 etc will be created for any subsequent waves.
//
// No data folders or waves are created by the Save Graph macros in the experiment where
// the graph was first created.  All new folders and waves are generated by loading the Igor
// Text file that recreates the graph.  The new folders and waves are in the destination experiment.
//
// NOTE:  The data folder hierarchy from the original experiment is not preserved by Save Graph.
//
// Version 1.1 differs from the first version as follows:
//      Supports Igor 3.0's Data Folders, liberal wave names
//      Supports contour and image graphs.

// #pragma rtglobals=1

//
//Menu "Macros"
//        "Save Graph", DoSaveGraphToFile()
//end
//
//Function DoSaveGraphToFile()
//        
//        Variable numWaves
//        Variable refnum
//        Variable i
//        Variable pos0, pos1
//        Variable FolderLevel=1
//
//        String TopFolder, FolderName
//        String WinRecStr
//        String fileName
//        String wname=  WinName(0,1)
//        
//        if( strlen(wname) == 0 )
//                DoAlert 0,"No graph!"
//                return 0
//        else
//                DoWindow/F $wname
//        endif
//        
//        TopFolder= wname
//        
//        
//        GetWindow kwTopWin, wavelist
//        Wave/T wlist=W_WaveList
//        numWaves = DimSize(wlist, 0)
//        
//        Redimension/N=(-1,5) wlist
//        
//        MakeUniqueFolders(wlist, "data")
//        
//        Open/D refnum as wname
//        filename=S_filename
//        
//        if (strlen(filename) == 0)
//                DoAlert 0, "You cancelled the Save Graph operation"
//                KillWaves/Z wlist
//                return 0
//        endif
//        
//        Open refnum as filename
//        fprintf refnum, "%s", "IGOR\r"
//        fprintf refnum, "%s", "X NewDataFolder/S/O "+TopFolder+"\r"
//        close refnum
//        
//        i = 0
//        do
//                if (strlen(wlist[i][3]) != 0)
//                        Open/A refnum as filename
//                        if (FolderLevel > 1)
//                                fprintf refnum, "%s", "X SetDataFolder ::\r"
//                        endif
//                        fprintf refnum, "%s", "X NewDataFolder/S "+wlist[i][3]+"\r"
//                        FolderLevel=2
//                        close refnum
//                endif
//                Execute "Save/A/T "+wlist[i][1]+" as \""+FileName+"\""
//
//                i += 1
//        while (i < numWaves)
//
//        if (FolderLevel > 1)
//                Open/A refnum as filename
//                fprintf refnum, "%s", "X SetDataFolder ::\r"
//                close refnum
//        endif
//
//        WinRecStr = WinRecreation(wname, 2)
//        i = 0
//        FolderName = ""
//        do
//                pos0=0
//                if (strlen(wlist[i][3]) != 0)
//                        FolderName = ":"+wlist[i][3]+":"
//                endif
//                do
//                        pos0=strsearch(WinRecStr, wlist[i][2], pos0+1)
//                        if (pos0 < 0)
//                                break
//                        endif
//                        WinRecStr[pos0,pos0+strlen(wlist[i][2])-1] = FolderName+PossiblyQuoteName(wlist[i][0])
//        
//                while (1)
//                i += 1
//        while (i<numWaves)
//        
//        Open/A refnum as filename
//        
//        pos0= strsearch(WinRecStr, "\r", 0)
//        pos0= strsearch(WinRecStr, "\r", pos0+1)+1
//        fprintf refnum,"X Preferences 0\r"
//        do
//                pos1= strsearch(WinRecStr, "\r", pos0)
//                if( (pos1 == -1) %| (cmpstr(WinRecStr[pos0,pos0+2],"End") == 0 ) )
//                        break
//                endif
//                fprintf refnum,"X%s%s",WinRecStr[pos0,pos1-1],";DelayUpdate\r"
//                pos0= pos1+1
//        while(1)
//        
//        fprintf refnum, "%s", "X SetDataFolder ::\r"
//        fprintf refnum,"X Preferences 1\r"
//        fprintf refnum,"X KillStrings S_waveNames\r"
//        close refnum
//        
//        KillWaves/Z wlist
//        return 0
//        
//end
//
//Function MakeUniqueFolders(wlist, FBaseName)
//        Wave/T wlist
//        String FBaseName
//        
//        Variable i,j, endi = DimSize(wlist, 0), startj = 0
//        Variable FolderNum = 0
//        
//        wlist[0][3] = ""
//        
//        i = 1
//        do
//        
//                j = startj
//                do
//                        if (cmpstr(wlist[i][0], wlist[j][0]) == 0)
//                                FolderNum +=1
//                                wlist[i][3] = FBaseName+num2istr(FolderNum)
//                                startj = i
//                                break
//                        endif
//                
//                        j += 1
//                while (j < i)
//        
//        
//                i += 1
//        while (i < endi)
//end
  
function get_expectation(waveV, length)
	wave waveV
	variable length // of wave
	variable i, dx, temp, expectation
	dx = deltax(waveV)
	temp = 0
	i = 0
	Do
		temp = temp + waveV[i] * pnt2x(waveV,i) * dx
		i += 1
	While(i < length)
	return(temp)
End

function Set_cond(CntrlName) : ButtonControl
	String CntrlName
	variable startPoint, endPoint
	variable num, delta, left
	Prompt num "Enter number of points to average for each condensed point: "
	DoPrompt "Enter number of points to average for each condensed point: ", num
	string waveName, axis_name
	startPoint = pcsr(a)
	endPoint = pcsr(b)
	waveName = csrWave(a)
	WAVE PointsWave = csrWaveRef(a)
	left  = leftx(PointsWave)
	delta = deltax(PointsWave)
	axis_name = get_yaxis(waveName)
//	WAVE PointsWave = $waveName

	condense (WaveName,axis_name,PointsWave, startPoint, endPoint, num, left, delta)
End


function condense  (PointsWaveName, Axis_name,PointsWave, startPoint, endPoint, num, left, delta)
	string PointsWaveName, Axis_name
	wave PointsWave	// amplitude and time base wave names
	variable startPoint, endPoint	// points in wave to analyse
	variable num			// how many to condense
	variable left
	variable delta
	variable scaleStart, scaleDelta
	string wave_name
	variable i, j, k, sum_num
	variable total_points, offset
	total_points = trunc( (endPoint - startPoint +1) / num) 
	Make /O/N=(total_points) $(PointsWaveName + "_cond")
	offset  = startPoint*delta + delta*trunc(num/2)
	delta = delta * num
	printf "total points: %f offset: %f, delta: %f\r", total_points, offset, delta
	WAVE DataWave = $(PointsWaveName + "_cond")
	SetScale/P x offset, delta,"", DataWave
	DataWave = 0
	for (i = startPoint, k = 0; k < total_points; k += 1)
		for (j = 0, sum_num = 0 ; j < num; j += 1)
			DataWave[k] += PointsWave[i]
			i += 1
			sum_num += 1
		endfor
		DataWave[k] /= sum_num
	endfor
	wave_name = PointsWaveName + "_cond"
	printf "Condensed wave: %s\r", wave_name
//	AxisName= StringByKey("YAXIS", TraceInfo("",csrwave(a),0))
//	if (stringmatch(Axis_name ,"Left"))
//		AppendToGraph DataWave
//	Else	
//		AppendToGraph /R DataWave
//	Endif
	return(0)
End

function align_to_spikes()

Return(0)
End


function PowerSpectra(signal, startPoint, endPoint, sampleInterval)
// output wave : W_periodogram
	wave signal
	variable startPoint, endPoint, sampleInterval
	variable numPoints
	numPoints = endPoint-startPoint
	if (mod(numPoints,2) == 0)
		endPoint -= 1
	Endif
//	WAVE W_periodogram
	dspperiodogram  /NODC=1 /Win=Hanning /R = [(startPoint), (endPoint)] signal
	WAVE W_periodogram
	W_periodogram /= (numPoints*0.375/2) // scale
	W_periodogram *= (numPoints*sampleInterval) //scale
 	SetScale/P x 0,(1.0/(numPoints*sampleInterval)),"Frequency(Hz)", W_Periodogram
	SetScale d 0,0,"mV**2", W_Periodogram
End

function corrMinis(binsize, binNum, refWaveName, nonrefWaveName, upper, lower)
	variable binsize, binNum, upper, lower // binsize in ms, binNum also sets the range to look for correlated minis
	string refWaveName, nonrefWaveName // adc0, adc1, adc2, adc3
	WAVE Mini_adc0, Mini_adc1, Mini_adc2, Mini_adc3 //added SPB 4-30-07
	NVAR adc0_index, adc1_index, adc2_index, adc3_index //added SPB 4-30-07
	variable refIndexMax, nonrefIndexMax, i	
	variable tm, refIndex, nonrefIndex, midpoint, corrIndex, diff, timer_ref, temp
// reference wave and max index	
	if (stringmatch(refWaveName, "adc0"))
		wave mini_refWave = Mini_adc0
		refindexMax = adc0_index
	Endif
	if (stringmatch(refWaveName, "adc1"))
		wave mini_refWave = Mini_adc1
		refindexMax = adc1_index
	Endif
	if (stringmatch(refWaveName, "adc2"))
		wave mini_refWave = Mini_adc2
		refindexMax = adc2_index
	Endif
	if (stringmatch(refWaveName, "adc3")) //added SPB 4-30-07
		wave mini_refWave = Mini_adc3
		refindexMax = adc3_index
	Endif

// non reference wave and max index	
	if (stringmatch(nonrefWaveName, "adc0"))
		wave mini_nonrefWave = Mini_adc0
		nonrefindexMax = adc0_index
	Endif
	if (stringmatch(nonrefWaveName, "adc1"))
		wave mini_nonrefWave = Mini_adc1
		nonrefindexMax = adc1_index
	Endif
	if (stringmatch(nonrefWaveName, "adc2"))
		wave mini_nonrefWave = Mini_adc2
		nonrefindexMax = adc2_index
	Endif
	if (stringmatch(nonrefWaveName, "adc3"))  //added SPB 4-30-07
		wave mini_nonrefWave = Mini_adc3
		nonrefindexMax = adc3_index
	Endif

	Duplicate /O Mini_adc0, Corr_ref
	Corr_ref=0
	Duplicate /O Mini_adc0, Corr_nonref
	Corr_nonref=0
	corrIndex = 0
	if (mod(binNum,2) == 0)
		binNum += 1
	Endif
	Make /O/N=(binNum) psth = 0 // binNum is odd
	SetScale/P x -(binsize*(binNum-1)/2),(binsize),"ms", psth
	//Added next four lines 5-1-07 to make psth_final symmetric (see end of function)
	Make /O/N=(binNum) psth_neg = 0 // binNum is odd
	SetScale/P x -(binsize*(binNum-1)/2),(binsize),"ms", psth_neg
	Make /O/N=(binNum) psth_final = 0 // binNum is odd
	SetScale/P x -(binsize*(binNum-1)/2),(binsize),"ms", psth_final
	midPoint = (binNum-1)/2 // midpoint is zero ms
	refIndex = 0
	nonrefindex = 0
//		timer_ref =startMSTimer
//		if (timer_ref == -1)
//			For(i=0; i < 9; i += 1)
//				timer_ref = i
//				temp = stopMSTimer(timer_ref)
//			EndFor
//			timer_ref =startMSTimer
//		Endif
//		printf "timer_ref = %f\r", timer_ref
		do

//			nonrefIndex = 0
			if (mini_refWave[refIndex][0] == 0 || mini_refWave[refIndex][0] == NaN) // indicates end of mini data in table
				Break
			Endif
			do
				if (mini_nonrefWave[nonrefIndex][0] == 0 || mini_nonrefWave[nonrefIndex][0] == NaN )
					Break
				Endif
				tm = mini_nonrefWave[nonrefIndex][0] - mini_refWave[refIndex][0] // in ms
//				printf "refindex: %d tm(1): %f\r", refindex, tm
				diff = tm
				tm /= binsize
				if (tm >= midPoint) // do not care if time difference is larger than half of binNum
					break
				Endif
				tm = round(tm)
				if (diff > lower && diff < upper) // catch its values
					corr_Ref[corrIndex][0] = mini_refWave[refindex][0]
					corr_Ref[corrIndex][1] = mini_refWave[refindex][1]
					corr_Ref[corrIndex][2] = mini_refWave[refindex][2]
					corr_nonRef[corrIndex][0] = mini_nonrefWave[nonrefindex][0]
					corr_nonRef[corrIndex][1] = mini_nonrefWave[nonrefindex][1]
					corr_nonRef[corrIndex][2] = mini_nonrefWave[nonrefindex][2]
					corrIndex += 1
				EndIf

				if ((tm >= 0) && (tm < binNum/2) ) // do not add beyond the size of psth
					psth[midPoint + tm] += 1
				Endif
				if ((tm < 0) && ((-tm) < midPoint) )
					psth[midPoint + tm] += 1
				Endif
				nonrefIndex += 1
			While(nonrefindex < nonrefindexmax)
			refIndex += 1
			if (nonrefindex > 0)
				Do
					nonrefindex -= 1
					tm = mini_nonrefWave[nonrefIndex][0] - mini_refWave[refIndex][0]
					tm = round(tm)
					if ((tm < 0) & (-tm > midPoint) || (nonrefindex <= 0))
						break
					endif
				While(1)
			Endif
		While(refindex < refindexmax)
	//	printf "%.3f (ms)\r", stopMSTimer(timer_ref)/1000.0
	
		
End

function CorrShiftMinis(binsize, binNum, refWaveName, nonrefWaveName, TraceOffSet)
	variable binsize, binNum, TraceOffSet
	string refWaveName, nonrefWaveName // adc0, adc1, adc2
	WAVE Mini_adc0, Mini_adc1, Mini_adc2, Mini_adc3 //SPB added 4-30-07
	NVAR adc0_index, adc1_index, adc2_index, adc3_index //SPB added 4-30-07
	variable refIndexMax, nonrefIndexMax
	variable refRemainder, nonrefRemainder
	variable tm, refIndex, nonrefIndex, midpoint	
	variable RefTraceNum, newNonRefTraceNum,oldNonRefTraceNum, traceCounted, new
// reference wave and max index	
	if (stringmatch(refWaveName, "adc0"))
		wave mini_refWave = Mini_adc0
		refindexMax = adc0_index
	Endif
	if (stringmatch(refWaveName, "adc1"))
		wave mini_refWave = Mini_adc1
		refindexMax = adc1_index
	Endif
	if (stringmatch(refWaveName, "adc2"))
		wave mini_refWave = Mini_adc2
		refindexMax = adc2_index
	Endif
	if (stringmatch(refWaveName, "adc3")) //added 4-30-07 SPB
		wave mini_refWave = Mini_adc3
		refindexMax = adc3_index
	Endif
// non reference wave and max index	
	if (stringmatch(nonrefWaveName, "adc0"))
		wave mini_nonrefWave = Mini_adc0
		nonrefindexMax = adc0_index
	Endif
	if (stringmatch(nonrefWaveName, "adc1"))
		wave mini_nonrefWave = Mini_adc1
		nonrefindexMax = adc1_index
	Endif
	if (stringmatch(nonrefWaveName, "adc2"))
		wave mini_nonrefWave = Mini_adc2
		nonrefindexMax = adc2_index
	Endif
	if (stringmatch(nonrefWaveName, "adc3")) //added SPB 4-30-07
		wave mini_nonrefWave = Mini_adc3
		nonrefindexMax = adc3_index
	Endif

	if (mod(binNum,2) == 0)
		binNum += 1
	Endif
	Make /O/N=(binNum) shift_psth = 0 // binNum is odd
	SetScale/P x -(binsize*(binNum-1)/2),(binsize),"ms", shift_psth
	midPoint = (binNum-1)/2 // midpoint is zero ms
	traceCounted = 0
		refIndex = 0
		RefTraceNum = 0
		do
			nonrefIndex = 0
//			printf "nonrefindex = %f\r", nonrefindex
			if (mini_refWave[refIndex][0] == 0)
				Break
			Endif
			oldNonRefTraceNum = -1
			new = 0
			do
				if (mini_nonrefWave[nonrefIndex][0] == 0)
					Break
				Endif
//				printf "tm = %f, mini_nonrefWave[nonrefIndex][0]=%f,  mini_refWave[refIndex][0]=%f\r", tm, mini_nonrefWave[nonrefIndex][0], mini_refWave[refIndex][0]
				tm = mini_nonrefWave[nonrefIndex][0] - mini_refWave[refIndex][0]
				if (abs(tm) < TraceOffSet/2.0) // ignore unshifted traces
					nonrefindex += 1
					Continue
				EndIf
//				newNonRefTraceNum = round(mini_nonrefWave[nonrefIndex][0] / TraceOffSet)
//				if (round(newNonRefTraceNum) > round(oldNonRefTraceNum))
//					traceCounted += 1
//					oldNonRefTraceNum = newNonRefTraceNum
//					if (traceCounted < 10)
//						printf "traceCounted = %f, newNonRefTraceNum = %f\r", traceCounted, newNonRefTraceNum
//					EndIf
//				Endif
				nonrefRemainder = mod(round(mini_nonrefWave[nonrefIndex][0]), round(TraceOffSet))
				refRemainder = mod(round(mini_refWave[refIndex][0]), round(TraceOffSet))		
				tm = nonrefRemainder - refRemainder
				tm /= binsize
				tm = round(tm)
				if ((tm >= 0) && (tm < midPoint) ) // do not add beyond the size of psth
					shift_psth[midPoint + tm] += 1
				Endif
				if ((tm < 0) && ((-tm) < midPoint) )
					shift_psth[midPoint + tm] += 1
				Endif
				nonrefIndex += 1
			While(1)
			refIndex += 1
		While(1)
//		printf "trace counted = %f\r", traceCounted
End

//MODIFIED 4-30-07 by SPB to handle adc3
function save_minis(CntrlName) : ButtonControl
	String CntrlName
	WAVE Mini_adc0, Mini_adc1, Mini_adc2, Mini_adc3
	WAVE Mini_adc0_f, Mini_adc1_f, Mini_adc2_f, Mini_adc3_f
	NVAR adc0_index, adc1_index, adc2_index, adc3_index
	NVAR adc0_index_f, adc1_index_f, adc2_index_f, adc3_index_f
	if (stringmatch("Save_Minis",CntrlName) == 1)
		Duplicate/O Mini_adc0 Mini_adc0_f
		Duplicate/O Mini_adc1 Mini_adc1_f
		Duplicate/O Mini_adc2 Mini_adc2_f
		Duplicate/O Mini_adc3 Mini_adc3_f
		adc0_index_f = adc0_index
		adc1_index_f = adc1_index
		adc2_index_f = adc2_index
		adc3_index_f = adc3_index
	EndIf
	if (stringmatch("Recover_Minis",CntrlName) == 1)
		Duplicate/O Mini_adc0_f Mini_adc0
		Duplicate/O Mini_adc1_f Mini_adc1
		Duplicate/O Mini_adc2_f Mini_adc2
		Duplicate/O Mini_adc3_f Mini_adc3
		adc0_index = adc0_index_f
		adc1_index = adc1_index_f
		adc2_index = adc2_index_f
		adc3_index = adc3_index_f
	EndIf

End
function EditExclude(CntrName) : ButtonControl // make waves from two-D mini waves extract second column
	String CntrName
	Edit ExcludeList
End

//modified 4-30-07 by SPB to handle adc3
function Extract_column(CntrName) : ButtonControl // make waves from two-D mini waves extract second column
	String CntrName
	NVAR Table_chan, Table_cnum, adc0_index, adc1_index, adc2_index , adc3_index
	variable chan , cnum, index_0, index_1, index_2, index_3 // cnum: which column
	// copy globals into local variables
	chan = Table_chan
	cnum = Table_cnum
	index_0 = adc0_index
	index_1 = adc1_index
	index_2 = adc2_index
	index_3 = adc3_index
	Prompt chan, "Enter channel number :"		// Set prompt for x param
	Prompt cnum, "Enter column number : "		// Set prompt for y param
	Prompt index_0 "Enter adc0_index: "
	Prompt index_1 "Enter adc1_index: "
	Prompt index_2 "Enter adc2_index: "
	Prompt index_3 "Enter adc3_index: "	
	DoPrompt "Enter channel number and  column number and index numbers", chan, cnum, index_0, index_1, index_2, index_3
	if (V_Flag)
		return -1								// User canceled
	endif
	//save values in globals
	Table_chan = chan
	Table_cnum = cnum
	adc0_index = index_0
	adc1_index = index_1
	adc2_index = index_2		
	adc3_index = index_3
	WAVE Mini_adc0, Mini_adc1, Mini_adc2, Mini_adc3
	NVAR adc0_index, adc1_index,adc2_index, adc3_index
	if (chan == 0)
		make /O/D /N=(adc0_index) mini_wave
		mini_wave = Mini_adc0[p][cnum]
	EndIf
	if (chan == 1)
		make /O/D /N=(adc1_index) mini_wave
		mini_wave = Mini_adc1[p][cnum]
	EndIf
	if (chan == 2)
		make /O/D /N=(adc2_index) mini_wave
		mini_wave = Mini_adc2[p][cnum]
	EndIf
	if (chan == 3)
		make /O/D /N=(adc3_index) mini_wave
		mini_wave = Mini_adc3[p][cnum]
	EndIf
	edit mini_wave
End

function query_average(CntrlName) : ButtonControl
	String CntrlName
	NVAR samples, trace_start, trace_end, freq, trace_num
	SVAR read_file_name
	NVAR alternate,bin_type,total_chan_num,traces_analyzed, keepADC0,keepADC1,keepADC2,keepADC3
	WAVE adc0, adc1, adc2,adc3
	WAVE analysed_points_wave
	WAVE amp_points_wave_0
	variable i
	variable temp
	variable /g stop_averaging
	if (stringmatch("init",CntrlName) == 1) // init
		Make /O/N=(samples) adc0_temp, adc1_temp, adc0_avg_0, adc1_avg_0,adc2_temp,adc2_avg_0,adc3_temp,adc3_avg_0
		if ((bin_type == 0) %| (bin_type == 10) %| (bin_type == 100))
			SetScale /P x, 0, (1.0/freq), "ms", adc0_avg_0, adc1_avg_0,adc2_avg_0,adc3_avg_0
		endif
		if (((bin_type == 1) %| (bin_type == 2)) %& (total_chan_num == 2))
			SetScale /P x, 0, (1.0/freq), "ms", adc1_avg_0
			SetScale /P x, (0.5/freq), (1.0/freq), "ms", adc0_avg_0
		endif
		SetScale d, -200, 200, "mV", adc0_avg_0, adc1_avg_0 ,adc2_avg_0,adc3_avg_0
		if ((traces_analyzed > 0) %& ((keepADC0) %| (keepADC1) %| (keepADC2) %| (keepADC3)))
			DoWindow /F G_Traces
			i = 0
			Do
				RemoveFromGraph /Z $("adc0_" + num2str(i)), $("adc1_" + num2str(i)), $("adc2_" + num2str(i)),$("adc3_" + num2str(i))
				KillWaves /Z $("adc0_" + num2str(i)), $("adc1_" + num2str(i)), $("adc2_" + num2str(i)), $("adc3_" + num2str(i))
				i += 1
			While (i < traces_analyzed)
		Endif
		stop_averaging = 0
		traces_analyzed = 0
		adc0_temp = 0
		adc1_temp = 0
		adc2_temp = 0
		adc3_temp = 0
		adc0_avg_0 = 0
		adc1_avg_0 = 0
		adc2_avg_0 = 0
		adc3_avg_0 = 0
		trace_num = trace_start
		Get_a_Trace(trace_num)
//		Dowindow /K G_Average
//		Display /W=(4.2,234.8,399.6,413.6) adc0_avg as "G_average"
//		DoWindow /C G_average
//		AppendToGraph/R adc1_avg
//		ModifyGraph rgb(adc1_avg)=(0,34816,52224)
		printf "Start query average file: %s\r", read_file_name
		init_g_average(1)
		return(0)
	Endif
	
	if (stop_averaging)
		printf "End of File; Inumber of traces analyzed: %f\r", traces_analyzed
		return(0)
	Endif
	if ((stringmatch("include",CntrlName) == 1) || (stringmatch("include1",CntrlName) == 1)) // include
		traces_analyzed += 1
		printf "Included trace: %d;  number of traces analyzed: %f\r", trace_num, traces_analyzed
		adc1_temp += adc1
		adc0_temp += adc0
		adc2_temp += adc2
		adc3_temp += adc3
		adc0_avg_0 = adc0_temp / traces_analyzed
		adc1_avg_0 = adc1_temp / traces_analyzed
		adc2_avg_0 = adc2_temp / traces_analyzed
		adc3_avg_0 = adc3_temp / traces_analyzed
		if (keepADC0)
			Duplicate /O adc0, $("adc0_" + num2str(traces_analyzed-1))
			DoWindow /F G_traces
			AppendToGraph /L $("adc0_" + num2str(traces_analyzed-1))
			ModifyGraph rgb($("adc0_" + num2str(traces_analyzed-1)))=(0,0,0)
		Endif
		if (keepADC1)
			Duplicate /O adc1, $("adc1_" + num2str(traces_analyzed-1))
			DoWindow /F G_traces
			AppendToGraph /R $("adc1_" + num2str(traces_analyzed-1))
			ModifyGraph rgb($("adc1_" + num2str(traces_analyzed-1)))=(0,0,0)			
		Endif
			if (keepADC2)
			Duplicate /O adc2, $("adc2_" + num2str(traces_analyzed-1))
			DoWindow /F G_traces
			AppendToGraph /L=left2 $("adc2_" + num2str(traces_analyzed-1))
			ModifyGraph rgb($("adc2_" + num2str(traces_analyzed-1)))=(0,0,0)			
		Endif
		if (keepADC3)
			Duplicate /O adc3, $("adc3_" + num2str(traces_analyzed-1))
			DoWindow /F G_traces
			AppendToGraph /R=right2 $("adc3_" + num2str(traces_analyzed-1))
			ModifyGraph rgb($("adc3_" + num2str(traces_analyzed-1)))=(0,0,0)			
		Endif
		temp = trace_num
		if (alternate == 0)
			trace_num += 1
		Else
			trace_num = trace_num + alternate
		Endif
		if (trace_num > trace_end)
			trace_num = temp
			stop_averaging = 1
			Return(0)
		Endif
		Get_a_trace(trace_num)
	Endif
	if ((stringmatch("do_not_include",CntrlName) == 1) || (stringmatch("do_not_include1",CntrlName) == 1)) // do not include
		amp_points_wave_0[analysed_points_wave[0]-1] = NAN
		temp = trace_num
		if (alternate == 0)
			trace_num += 1
		Else
			trace_num = trace_num + alternate
		Endif
		if (trace_num > trace_end)
			trace_num = temp
			stop_averaging = 1
			Return(0)
		Endif
		Get_a_trace(trace_num)		
	Endif	
//	init_g_avg()
End


// excluding traces for a DSI experiment
function exclude_it()
	WAVE excludelist
	NVAR trace_end
	variable i, index
	excludelist = nan
	index = 0
	for(i=10; i < trace_end; i +=1)
		if ((mod((i+1),16) == 0) || (mod((i+1),16) == 1) || (mod((i+1),16) == 2) || (mod((i+1),16) == 3))
			excludelist[index] = i
			index += 1
		Endif
	Endfor
End


// to make exclude list
function exclude(offset,cycle,num)
	variable offset, cycle, num 
	WAVE excludelist
	variable i, j
	for(i=0, j = 0; i < num; i += 1)
		if (mod((i+1-offset),cycle) == 0)
			excludelist[j] = i
			j += 1
		Endif
	EndFor
End

//#pragma rtGlobals=1		// Use modern global access method.
#include <all ip procedures>
	

function make_bg_curve()
	variable i, numFrames = 1000
	Make /O /N =(numFrames) avg_roi_bg = NaN, bg_curve_fit = NaN
	For(i=0; i < numFrames; i = i+1)
		ImageStats /M=1 /P=(i) 'image' //background calculated from averaging entire image
		avg_roi_bg[i] = v_avg
	EndFor
	CurveFit exp avg_roi_bg /D=bg_curve_fit
End

function roi2wave(delta, xp, yp, numFrames)
	variable delta, xp, yp, numFrames
	variable i

	Make /O /N=(numFrames) dfof = NaN
//	WAVE dfof

	For(i=0; i < numFrames; i = i+1)
		ImageStats /M=1 /P=(i) /G={xp-delta, xp+delta, yp-delta, yp+delta} 'image'
		dfof[i] = v_avg
		
		//ImageStats /M=1 /P=(i) /G={x_bg-delta, x_bg+delta, y_bg-delta, y_bg+delta} 'image' //background calculated from individual bg ROI's
		//mageStats /M=1 /P=(i) 'image' //background calculated from averaging entire image
		
		//avg_roi_bg[i] = v_avg
	EndFor

	//bg roi / whole image subtract method:
	//dfof = 100*(avg_roi - avg_roi_bg)/avg_roi_bg
	
	//bg time-avg subtract method (yuste):
	//WaveStats /q avg_roi
	//dfof = 100*(avg_roi - V_avg) / V_avg
	
	//no-processing method w/ bleach corrected images:

	
	//curve fit bg_sub method, per ROI:
	//CurveFit line avg_roi[0,numFrames]
	//For(i=0; i < numFrames; i = i+1)
	//	avg_roi_dt[i] = avg_roi[i] - k0 - i*k1
	//	dfof[i] = avg_roi_dt[i]/(k0+i*k1)
	//EndFor
	
	//subtract exponential fit to average bleach of entire movie
	//dfof = 100*(avg_roi - bg_curve_fit) / bg_curve_fit
	

End

function roi_dt2wave(delta, xp, yp, numFrames)
	variable delta, xp, yp, numFrames
	WAVE bg_curve_fit
	variable i
	
	Make /O /N=(numFrames) avg_dt_roi = NaN
	
	
	For(i=0; i < numFrames; i = i+1)

		ImageStats /M=1 /P=(i) /G={xp-delta, xp+delta, yp-delta, yp+delta} 'image_dt'
		avg_dt_roi[i] = v_avg

	EndFor
End

function roi2wave_batch()
	variable numROIs, numFrames, delta, i
	string dfofWaveName, dfdtWaveName, xcoordstr, ycoordstr, directory
	
	delta = 8 //num of pixels in +/- x and y to make ROI rectangle
	directory = "C:temp:CellG movie:" //root directory of movie
	
	//Load ROI file
	loadwave /A /J /L={0,1,0,1,2} /B=" N='_skip_'; N=roiX; N=roiY;" /O (directory + "roi.txt")
	WAVE roiX, roiY
	
	WaveStats roiX
	numROIs = V_npnts
	
	//Get ROI traces from original movie
	ImageLoad/T=tiff/O/S=0 /C=-1 /Q/N=image (directory + "movie1_electrophys_001.tif")
	
	numFrames = V_numImages
	
	Make /O /T /N = (numROIs) ROIdfofStr
	
	Make /O /T /N = (numROIs) ROIdfdtStr
	
	For(i=0; i < numROIs; i = i+1)
		 	
		xcoordstr = num2str(roiX[i])
		ycoordstr = num2str(roiY[i])
		dfofWaveName = "dfof_" + num2str(i) + "_"+ xcoordstr +"_"+ ycoordstr
		roi2wave(delta, roiX[i], roiY[i],  numFrames)
		WAVE dfof
		Duplicate /o dfof, $dfofWaveName
		ROIdfofStr[i] = dfofWaveName

//memory-saving dt calculation: calc dt for each dfof roi trace
		
		dfdtWaveName = "dfdt_" + num2str(i) + "_"+ xcoordstr +"_"+ ycoordstr
		Duplicate /o dfof, $dfdtWaveName
		Smooth 7, $dfdtWaveName //can change the amount of smoothing here
		Differentiate $dfdtWaveName
		
		ROIdfdtStr[i] = dfdtWaveName
		
	EndFor
	
	Killwaves image
	
	//Get ROI traces from dt movie
	
//	ImageLoad/T=tiff/S=0 /C=-1 /Q/N=image_dt "C:Data:12-5-06:movie1:movie1_dt.tif"
//	
//	Make /O /T /N = (numROIs) ROIdfdtStr
//
//	For(i=0; i < numROIs; i = i+1)
//		 	
//		xcoordstr = num2str(roiX[i])
//		ycoordstr = num2str(roiY[i])
//		dfdtWaveName = "dfdt_" + num2str(i) + "_"+ xcoordstr +"_"+ ycoordstr
//		roi_dt2wave(delta, roiX[i], roiY[i], numFrames)
//		
//		
//		Duplicate /o avg_dt_roi, $dfdtWaveName
//		ROIdfdtStr[i] = dfdtWaveName
//	EndFor
//	
//	Killwaves image_dt
	
End

//function detect_transients()
//
//	variable numROIs, i, num_events, num_active_cells = 0
//	WAVE fluo_trace, dt_trace
//	string fluo_name, dt_name, eventWaveName, event_yval_names
//	WAVE /T ROIdfofStr
//	WAVE /T ROIdfdtStr
//	
//	Make /o /t /n = 1000 event_trace_names
//	Make /o /t /n = 1000 event_ytrace_names
//		
//	WaveStats roiX
//	numROIs = V_npnts
//	
//	For(i=0; i < numROIs; i = i+1)
//		fluo_name = ROIdfofStr[i]
//		dt_name = ROIdfdtStr[i]
//		Duplicate /o $fluo_name, fluo_trace
//		Duplicate /o $dt_name, dt_trace
//		
//		//transient detection
//		killwindow ShowPeaks
//		num_events = TonyAutomaticallyFindPeaks(dt_trace, 1, 75, 2) //2nd parameter is dt threshold
//		if(num_events > 0)
//			AppendToGraph /R /C = (0,52224,0) fluo_trace
//			eventWaveName = "trans_" + fluo_name
//			event_yval_names = "y_trans_" + fluo_name
//			
//			Duplicate /R=[][0,0] /o W_AutoPeakInfo, $eventWaveName
//			Duplicate /O $eventWaveName, event_yvals
//			
//			event_yvals = 1
//
//			Duplicate /O event_yvals, $event_yval_names
//			
//			event_trace_names[num_active_cells] = eventWaveName
//			event_ytrace_names[num_active_cells] = event_yval_names
//			num_active_cells = num_active_cells + 1
//			
//			//Pause screen to eval each trace's peak detection
//			NewPanel/K=1 /W=(139,341,382,432) as "Pause for Cursor"
//			DoWindow /C pause_dialog_window // Set to an unlikely name
//			DrawText 21,40,"found peaks"
//			PauseForUser pause_dialog_window, ShowPeaks
//		else
//			 display /n=ShowPeaks /L dt_trace 
//			 AppendToGraph /R /C = (0, 52224, 0) fluo_trace
//			 
//			 //same pause screen
//			 NewPanel/K=1 /W=(139,341,382,432) as "Pause for Cursor"
//			 DoWindow /C pause_dialog_window // Set to an unlikely name
//			 DrawText 21,40,"no peaks"
//			 PauseForUser pause_dialog_window, ShowPeaks
//		endif
//	EndFor
//	
//	Redimension /N=(num_active_cells) event_trace_names, event_ytrace_names
//	print num_active_cells
//	
//End

//function multi_raster_plotter()
//
//	variable numTraces, i, traces_per_graph, trace_queue, max_amp, num_events, cell_num, xcoord, ycoord
//	WAVE trace_x, trace_y
//	WAVE /T event_trace_names
//	WAVE /T event_ytrace_names
//	string axisStr, identifier
//	
//	//These are variables that control the graphing of the traces
//	traces_per_graph = 55
//	max_amp = 5 //in %delta f over bg
//	//y_axis_min = -2
//	//y_axis_max = 2
//	
//	numTraces = numpnts(event_trace_names)
//
//	trace_queue = 0
//	display
//	For(i=0; i < numTraces; i = i+1)
//		
//		if (trace_queue == traces_per_graph)
//			display
//			trace_queue = 0
//		endif
//		
//		axisStr = "L" + num2str(i)
//		AppendToGraph /L = $axisStr $event_ytrace_names[i] vs $event_trace_names[i]
//		ModifyGraph axisEnab($axisStr)={(trace_queue/traces_per_graph), (trace_queue/traces_per_graph + 1/traces_per_graph)}, mode($event_ytrace_names[i])=1, nticks($axisStr)=0, lblPosMode($axisStr)=2,lblRot($axisStr)=-90, axisEnab(bottom)={0.06,1}
//		SetAxis $axisStr 0, 1
//		
//		sscanf event_trace_names[i], "trans_dfof_%d_%d_%d", cell_num, xcoord, ycoord
//		identifier = "\\Z10" + num2str(cell_num) + ", " + num2str(xcoord) + ", " + num2str(ycoord)
//		Label $axisStr (identifier)
//		ModifyGraph freePos($axisStr)={0,bottom}
//		trace_queue = trace_queue + 1
//	EndFor
//	
//	
//	
//End

//#pragma rtGlobals=1              // Use modern global access method.
// first run Acquire and set acquire mode
//enter a name for the data file you want to save and check the write permit.
//This will open a data file for writing
//function MakeDataFile()
//	
//	variable num_traces, i
//	WAVE trace
//        NVAR total_chan_num
//        NVAR freq
//        NVAR samples
//        NVAR adc_gain0
//        WAVE /T ROIdfofStr
//        
//        num_traces = numpnts(ROIdfofStr)
//        
//       // Make /W/O/N=1000 wave1, wave2, wave3 // Normally you would load these waves before running the function so you need to declare them as global
////      waves as shown below
////      WAVE wave1, wave2, wave3 // if the ROIs names have an index we can write a loop to declare a large number of waves.
//        // It would be useful to have a string with the names of the ROIs that can be parsed. This string can be an input to the function.
//        // wave1 = gnoise(1)*4096 // this is just for illustration
//         //wave2 = gnoise(1)*4096
//         //wave3 = gnoise(1)*4096
//         // Now set the relevant variables
//         // this has to be done before writing the first sweep
//         total_chan_num = 1
//         freq = 0.02 // in kHz
//         samples = 1000 // frames
//         adc_gain0 = 1
//        // now write the binary data which has to be 16 bit signed integer.
//        for(i = 0; i < num_traces; i = i+1)
//        	Duplicate /o $ROIdfofStr[i], trace
//        	trace = trace*3.2
//        	write_sweep(trace)
//        endfor
//        close_write_file()
//End
//		
		
		



//
//function roi2wave_batch()
//	variable numROIs, numFrames, delta, i, traces_per_graph, trace_queue, max_amp, num_events
//	WAVE roiX, roiY, roiX_bg, roiY_bg, dfof//, dfof_smth, dfdt
//	string dfofWaveName, xcoordstr, ycoordstr, axisStr, eventWaveName
//
//	//ImageLoad/T=tiff/S=0 /C=-1 /N /O=image "C:data:8-29-06:site1_control_001.tif"
//	//ImageLoad/T=tiff/S=0 /C=-1 /N /O=image_z "C:data:8-29-06:"
//	
//	//These are variables that control the graphing of the traces
//	numFrames = 250
//	delta = 7
//	traces_per_graph = 10
//	max_amp = 5 //in %delta f over bg
//	//y_axis_min = -2
//	//y_axis_max = 2
//
//	
//	WaveStats roiX
//	numROIs = V_npnts
//
//	Make /O /T /N = (numROIs) ROIdfofStr
//	
//	
////	trace_queue = 0
////	display
//	For(i=0; i < numROIs; i = i+1)
//		
////		if (trace_queue == traces_per_graph)
////			display
////			trace_queue = 0
////		endif
//		 	
//		xcoordstr = num2str(roiX[i])
//		ycoordstr = num2str(roiY[i])
//		dfofWaveName = "dfof_" + num2str(i) + "_"+ xcoordstr +"_"+ ycoordstr
//		roi2wave(delta, roiX[i], roiY[i], roiX_bg[i], roiY_bg[i], numFrames)
//		Duplicate /o dfof, $dfofWaveName
//		ROIdfofStr[i] = dfofWaveName
//		
////		Duplicate/O dfof, dfof_smooth;
////		Smooth/B 10, dfof_smooth
////		Differentiate dfof_smooth/D=dfdt
//
//
//		
//		//transient detection
//		killwindow ShowPeaks
//		num_events = TonyAutomaticallyFindPeaks(avg_dt_roi, 1, 75, 2)
//		if(num_events > 0)
//			AppendToGraph /R /C = (0,52224,0) dfof
//			eventWaveName = "events_" + num2str(i) + "_"+ xcoordstr + "_" + ycoordstr
//			
//			Duplicate /o W_AutoPeakInfo, $eventWaveName
//			
//			NewPanel/K=1 /W=(139,341,382,432) as "Pause for Cursor"
//			DoWindow /C pause_dialog_window // Set to an unlikely name
//			DrawText 21,40,"found peaks"
//			PauseForUser pause_dialog_window, ShowPeaks
//		else
//			 display /n=ShowPeaks /L avg_dt_roi  
//			 AppendToGraph /R /C = (0, 52223, 0) dfof
//			 
//			 NewPanel/K=1 /W=(139,341,382,432) as "Pause for Cursor"
//			 DoWindow /C pause_dialog_window // Set to an unlikely name
//			 DrawText 21,40,"no peaks"
//			 PauseForUser pause_dialog_window, ShowPeaks
//		endif
//		
//		
//			
//
//		
//		
////		axisStr = "L" + num2str(i)
////		AppendToGraph /L = $axisStr $dfofWaveName
////		ModifyGraph axisEnab($axisStr)={(trace_queue/traces_per_graph), (trace_queue/traces_per_graph + 1/traces_per_graph - 0.01)}
////		WaveStats $dfofWaveName
////		SetAxis $axisStr V_min, V_min + max_amp
////		ModifyGraph nticks($axisStr) = 3, lblLatPos = -20, lblRot = -90
////		Label $axisStr "\\c"
////		ModifyGraph freePos($axisStr)={0,bottom}
////		trace_queue = trace_queue + 1
//	EndFor
//	
//	
//	
//End
//
//
//		
//		
//		


function ps(CntrlName): ButtonControl
	string CntrlName
	variable startPoint, endPoint, sampleInterval
	
	variable i, t_segPoints, traceNum, t_segNum
	NVAR trace_start, trace_end,segNum
	NVAR segPoints
	NVAR sub_trend
	startPoint = pcsr(a)
	endPoint = pcsr(b)
	WAVE signal = csrWaveRef(a)
	Duplicate /O signal, t_signal
	if (sub_trend)
		CurveFit/Q/X=1 line  t_signal[pcsr(A),pcsr(B)]
		t_signal -=  k0+k1*x
	Endif
	sampleInterval = deltax(t_signal)
	sampleInterval /= 1000.0 // convert from ms to second
	t_segNum = segNum
//	Prompt t_segNum, "Enter number of segments : "		// Set prompt for x param
//	Prompt t_TraceNum, "Enter number of traces: "		// Set prompt for y param
//	DoPrompt "Enter Number of Segments", t_segNum
//	segNum = t_segNum
//	traceNum = t_traceNum
	PowerSpectra(t_signal, startPoint, endPoint, sampleInterval)
	traceNum = 0
	WAVE W_periodogram
	Duplicate /O W_periodogram, temp_spectra
	temp_spectra = 0
	for (i = trace_start; i < trace_end ; i = i + 1)
		get_a_trace(i)
		Duplicate /O signal, t_signal
		if (sub_trend)
			CurveFit/Q/X=1 line  t_signal[pcsr(A),pcsr(B)] 
			t_signal -=  k0+k1*x
		Endif
		PowerSpectra(t_signal, startPoint, endPoint, sampleInterval)
		temp_spectra += W_periodogram
		traceNum += 1
	EndFor
	if (traceNum > 0)
		W_periodogram = temp_spectra / traceNum
	EndIf
	DoWindow PowerSpectraGraph // checks if window exists
	if (V_flag == 0) // Graph does not exist
		DoWindow /K PowerSpectraGraph
		Display /W=(0.6,238.4,402,413.6) W_Periodogram
		DoWindow /C PowerSpectraGraph
	Endif
	DoWindow /F PowerSpectraGraph
End

