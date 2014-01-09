#pragma rtGlobals=1		// Use modern global access method.
function Do_a_Protocol(num) // num is the protocol number within a scheme and 0 if a single protocol is run
	variable num
	
	NVAR ITC18 // if 1, normal mode use ITC18 if 0 test program w/o itc18
	NVAR last_protocol_run_time
	NVAR micros, ref1 // for timing analysis
	NVAR pro_running // if 1 protocol has already run in this call
	NVAR scheme_on, trig_mode
	NVAR start_time, current_time
	WAVE adc0,adc1,adc2,adc3,adc4,adc5,adc6,adc7
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4,adc_gain5,adc_gain6,adc_gain7
	NVAR freq, total_chan_num, requested, period, samples
	NVAR update, acquired,wait,pro_wait, write_permit,his_flag, ttl_status
	NVAR continuous_flag,average_flag,cross_flag,init_analysis
	NVAR Scale_to_Vis
	SVAR seq_in, seq_out, fake_chan
	WAVE StimWave, InData, total_detections, dac0_stimwave
	NVAR adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag // to indicate seperate averaging during protocols
	WAVE avg0=$("adc0_avg_"+num2str(num)), avg1=$("adc1_avg_"+num2str(num))
	WAVE avg0_temp=$("root:avg:adc0_avg_temp_"+num2str(num)), avg1_temp=$("root:avg:adc1_avg_temp_"+num2str(num))
	WAVE avg2=$("adc2_avg_"+num2str(num)), avg3=$("adc3_avg_"+num2str(num))
	WAVE avg2_temp=$("root:avg:adc2_avg_temp_"+num2str(num)), avg3_temp=$("root:avg:adc3_avg_temp_"+num2str(num))
	NVAR av_sweeps = $("av_sweeps_"+num2str(num))
	NVAR cs_1 //
	NVAR cs_0 // when sweeps = continuous_switch_1 switch to pro_1, when sweeps=continuous_swich_0 switch to pro_0
	NVAR cont_multi_flag // if 1 multiple protocols under continuous mode
	NVAR current_pro, number_of_pro
	NVAR scheme_repeat
//--------------------------------------------------------------------

	WAVE /T analysis_trace_name_wave // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE analysed_points_wave  // the number of points analysed in the dpoints waves
	WAVE amp_analysis_flag_wave // if 1 do analysis
	WAVE amp_analysis_mode_wave  // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	NVAR peak, draw_flag
	NVAR amp_change_0, amp_change_1,amp_change_2,amp_change_3 // changing pulse amplitude
	NVAR interval_change_0, interval_change_1, interval_change_2, interval_change_3 
	SVAR protocol // the current protocol

//******************************************************
// the following are used for online amplitude analysis
	
	
	
//*************************************************	
	NVAR spike_duration, spike_num
//	NVAR av_sweeps_0, av_sweeps_1, av_sweeps_2, av_sweeps_3 , av_sweeps_4, av_sweeps_5
//	NVAR av_sweeps_6, av_sweeps_7, av_sweeps_8, av_sweeps_9
	NVAR spike_thresh, bin_size,histogram_sweeps
	SVAR spike_detection_trace_name
//*************************************************
	NVAR electrode0_res, electrode1_res, electrode2_res, electrode3_res, align_flag, smooth_flag
	NVAR hp0, hp1, hp2, hp3
	WAVE dac0_amp, dac1_amp, dac0_start, dac1_start,dac0_end, dac1_end
	WAVE dac2_amp, dac3_amp, dac2_start, dac3_start, dac2_end, dac3_end
	WAVE adc0_avg_temp, adc1_avg_temp, adc2_avg_temp, adc3_avg_temp
	WAVE adc0_avg, adc1_avg, adc2_avg, adc3_avg
	SVAR ZoomWindow
	variable /g total_spikes
	variable /g res_temp, res_index, res_index_flag // to calculate electrode resistance
	variable /g  res_sum = 1
	variable kk, m, save_file_ref, index
	variable mm, i, j, spikes_0, spikes_1, tm, mid_point
	variable scheme_repeat_index // how many times the scheme has been repeated in continuous mode
//	variable single_sweep
//	if (num == 0)
//		single_sweep = 1
//	Else
//		single_sweep = 0
//	Endif
	if (scheme_on == 0) // use wait if scheme is not running
		pro_wait = wait
	Endif
	if ((continuous_flag == 1) && (scheme_on == 1))    //(cont_multi_flag == 1))
		decode_c_pro("pro_0")
		current_pro = 0
	Endif
/////////////
	make /O /N=(samples*total_chan_num) StimWave
	make /O/N=(samples*total_chan_num) InData
	make /o /n=(samples) Poisson_Stim
	if (init_analysis)
		init_amp_analysis("")
	Endif
	res_index = 0
	res_temp = 0
	period = round(1000.0/(freq * 1.25 * total_chan_num)) // to get to the nearest integer
	freq = 1000/(1.25*total_chan_num*period)
	pro_running = 0 
//// trying to average only in one protocol when alternating	
//	if (init_analysis == 1)
//		Make /O/N=(samples) adc1_avg=0, adc1_avg_temp=0, adc2_avg=0, adc2_avg_temp=0, adc0_avg=0, adc0_avg_temp=0
//		SetScale /P x, 0, (1/freq), "ms",adc0_avg, adc1_avg,adc2_avg, avg0
//		SetScale d 0,0, "mv",adc0_avg, adc1_avg,adc2_avg, avg0
//		average_sweeps = 0
//	Endif
//	if (!scheme_on) // this protocol is run from do_a_scheme
//		make /o /n=(samples) adc0=0,adc1=0,adc2=0, adc3=0
//		SetScale /P x, 0, (1/freq), "ms", adc0, adc1,adc2, adc3
//		SetScale d 0,0, "mv", adc0, adc1,adc2, adc3
//	EndIf
	if ((cross_flag == 1) & (init_analysis == 1))
		make /o /n=300 detections_0, detections_1
		make /O/N=((freq/bin_size)*100) psth = 0 // +/- 50 ms
		SetScale /P x, -50, (bin_size/freq), psth
		mid_point = ((freq/bin_size)*100) /2
		DoWindow /F S_Histogram
	Endif
	
///////////////////////////////////////////////////////

	
//*************************************************	
	if ((his_flag == 1) & (init_analysis == 1))
		Make /o /n=300 detections
//	Make /o /n=1000000 total_detections
		Make /o /n=1 psth
	Endif
//*************************************************
	
	
	
	
	
	variable sweeps
	variable cProRequested // how many sweeps are requested in a continuous protocol
	variable cProSweeps // how many sweeps have been acquired for the currently running continuous protocol under a scheme
	variable cycle_time, t0, t1, Timer_ref, temp, stop_request, started
	string s
	started = 0
//	set_in()
	if ((his_flag == 1) & (init_analysis == 1))
		total_detections = 0
		total_spikes = 0
	Endif
	string s_in = seq_in
	string s_out = seq_out
	string seq_command, start_command
//	seq_command = "ITC18Seq" + " \"" + seq_in  + "\", \"" + seq_out +"\"," + "1" 
	seq_command = "ITC18Seq" + " \"" + seq_in  + "\", \"" + seq_out +"\""
	period = round(1000.0/(freq * 1.25 * total_chan_num)) // to get to the nearest integer
	if (ITC18)
	Execute (seq_command)
	Endif
	stop_request = 0
	t0 = ticks // take the time
	last_protocol_run_time = t0
//	for (i=0; i < 10; i += 1)
//		micros = stopMSTimer(i)
//	EndFor
	sweeps = 0
	scheme_repeat_index = 0
	if (continuous_flag == 1) // not a single sweep 
		if (scheme_on)   //(cont_multi_flag == 1)
			decode_pro("pro_0")
			cProRequested = requested
			cProSweeps = 0
		EndIf
		set_stim()
		if (ITC18)
		Execute("ITC18Stim StimWave")
		Endif
		if ((scheme_on == 1) && (cProRequested == 1)) // do not change protocol if requested > 1
				decode_pro("pro_1")
				cProRequested = requested
				cProSweeps = 0
				current_pro = 1
				set_stim()
		EndIf
		if(ITC18)
		Execute("ITC18StimAppend StimWave")
		Execute("ITC18StartAcq period, trig_mode, 0")
		Endif
		for (i=0; i < 10; i += 1)
			micros = stopMSTimer(i)
		EndFor		
		ref1 = StartMSTimer
	endif
	variable corrected_wait
	do
		if (continuous_flag == 0)
			set_stim()
			if(ITC18)
			Execute ("ITC18Stim StimWave")
			Endif
		Endif
		if (continuous_flag == 0)
			// now wait
			if (pro_running  == 1)
				wait = pro_wait 
			Endif
			corrected_wait = wait * 0.98 // correction
			if ((pro_running == 0) && (scheme_on == 0)) // do not wait if it's the start
				corrected_wait = 0
			Endif
			do
				current_time = ticks
				cycle_time = (current_time-start_time)/60.0
		 		s = KeyboardState("")
		 		if (cmpstr(s[9], "z") == 0) // z  to stop
		 			stop_request = 1
		 			if(ITC18)
		 			Execute ("ITC18StopAcq")
		 			Endif
		 			if (dac0_status)
			 			set_hp(0, hp0)
			 		Endif
			 		if (dac1_status)
			 			set_hp(1, hp1)
			 		Endif
			 		if (dac2_status)
			 			set_hp(2, hp2)
			 		Endif
			 		If(dac3_status)
			 			set_hp(3, hp3)
			 		Endif
		 			return(1)
 					break
				endif
				if (cmpstr(s[9], "1") == 0) // zoom
					ChangeAxis(1, ZoomWindow)
				endif
				if (cmpstr(s[9], "2") == 0) // zoom
					ChangeAxis(-1, ZoomWindow)
				endif
			While (cycle_time < corrected_wait)
			start_time = ticks
			micros = StopMSTimer(ref1)
			//print micros/1000.0
			ref1 = StartMSTimer
			if (ref1 == -1)
				printf "all MSTimers  are busy\r"
				for (i=0; i < 10; i += 1)
					micros = stopMSTimer(i)
				EndFor		
				ref1 = StartMSTimer
			EndIf
			if(ITC18)
			Execute ("ITC18StartAcq period, trig_mode, 0")
			Execute ("ITC18Samp InData")
			Execute ("ITC18StopAcq")
			Else
//				StimWave[index,(total_chan_num*(samples-1)+index);total_chan_num]=dac0_stimwave[(p-index)/(total_chan_num)]
				indata = 100*gnoise(1)
				InData[0,2*(samples-1);2] +=  dac0_stimwave[p]//500*sin(2*Pi*p/(numpnts(InData)/4))
				InData /= 3.2
			Endif
// 			set_hp(0, hp0)
//			set_hp(1, hp1)
// 			set_hp(2, hp2)
// 			set_hp(3, hp3)
		Endif
		if (continuous_flag == 1) // for now only single sweep per protocol is allowed in continuous mode
				s = KeyboardState("")
		 		if (cmpstr(s[9], "z") == 0) // z  to stop
		 			micros = StopMSTimer(ref1)
		 			stop_request = 1
		 			if(ITC18)
		 			Execute ("ITC18StopAcq")
		 			Endif
		 			if (scheme_on)  //(cont_multi_flag)
		 				decode_pro("pro_0")
		 				set_stim()
						current_pro = 0
					EndIf	
		 			if (dac0_status)
			 			set_hp(0, hp0)
			 		Endif
			 		if (dac1_status)
			 			set_hp(1, hp1)
			 		Endif
			 		if (dac2_status)
			 			set_hp(2, hp2)
			 		Endif
			 		If(dac3_status)
			 			set_hp(3, hp3)
			 		Endif
		 			return(1)
				endif
				if (cmpstr(s[9], "1") == 0) // zoom
					ChangeAxis(1, ZoomWindow)
				endif
				if (cmpstr(s[9], "2") == 0) // zoom
					ChangeAxis(-1, ZoomWindow)
				endif
			if (sweeps == 0)
				if(ITC18)
				Execute("ITC18Samp InData")
				Else
					indata = 100*gnoise(1)
					InData[0,2*(samples-1);2] +=  dac0_stimwave[p]//500*sin(2*Pi*p/(numpnts(InData)/4))
					InData /= 3.2
				Endif
				micros = StopMSTimer(ref1)
				print micros/1000.0
				ref1 = StartMSTimer
				if (started == 0)
					cProSweeps += 2
						started = 1
				Else
					cProSweeps += 1
				Endif
				num = 0
				WAVE avg0=$("adc0_avg_"+num2str(num)), avg1=$("adc1_avg_"+num2str(num))
				WAVE avg0_temp=$("root:avg:adc0_avg_temp_"+num2str(num)), avg1_temp=$("root:avg:adc1_avg_temp_"+num2str(num))
				WAVE avg2=$("adc2_avg_"+num2str(num)), avg3=$("adc3_avg_"+num2str(num))
				WAVE avg2_temp=$("root:avg:adc2_avg_temp_"+num2str(num)), avg3_temp=$("root:avg:adc3_avg_temp_"+num2str(num))
				NVAR av_sweeps = $("av_sweeps_"+num2str(num))
			Endif
			if (sweeps > 0)
				If (scheme_on)  //(cont_multi_flag == 1) // do not decode protocols if only a single protocol
					num = current_pro
					WAVE avg0=$("adc0_avg_"+num2str(num)), avg1=$("adc1_avg_"+num2str(num))
					WAVE avg0_temp=$("root:avg:adc0_avg_temp_"+num2str(num)), avg1_temp=$("root:avg:adc1_avg_temp_"+num2str(num))
					WAVE avg2=$("adc2_avg_"+num2str(num)), avg3=$("adc3_avg_"+num2str(num))
					WAVE avg2_temp=$("root:avg:adc2_avg_temp_"+num2str(num)), avg3_temp=$("root:avg:adc3_avg_temp_"+num2str(num))
					NVAR av_sweeps = $("av_sweeps_"+num2str(num))
					if (cProSweeps >= cProRequested) 
						if (current_pro < (number_of_pro-1))
							current_pro += 1
						Else
							scheme_repeat_index += 1
							current_pro = 0
						EndIf
						decode_c_pro("pro_"+num2str(current_pro) )
						cProRequested = requested
						cProSweeps = 0
						set_stim()
					Endif
				Endif
				if(ITC18)
				Execute("ITC18StimAppend StimWave")
				Execute("ITC18SampAppend InData")
				Else
					indata = 100*gnoise(1)
					InData[0,2*(samples-1);2] +=  dac0_stimwave[p]//500*sin(2*Pi*p/(numpnts(InData)/4))
					InData /= 3.2
				Endif
				micros = StopMSTimer(ref1)
				printf "%.3f ms\r", micros/1000.0
				ref1 = StartMSTimer
				cProSweeps += 1
				s = KeyboardState("")
		 		if (cmpstr(s[9], "z") == 0) // z  to stop
		 			stop_request = 1
		 			if(ITC18)
		 			Execute ("ITC18StopAcq")
		 			Endif
		 			if (scheme_on)  //(cont_multi_flag)
		 				decode_pro("pro_0")
		 				set_stim()
						current_pro = 0
					EndIf
					if (dac0_status)
			 			set_hp(0, hp0)
			 		Endif
			 		if (dac1_status)
			 			set_hp(1, hp1)
			 		Endif
			 		if (dac2_status)
			 			set_hp(2, hp2)
			 		Endif
			 		If(dac3_status)
			 			set_hp(3, hp3)
			 		Endif
		 			return(1)
				endif
				if (cmpstr(s[9], "1") == 0) // zoom
					ChangeAxis(1, ZoomWindow)
				endif
				if (cmpstr(s[9], "2") == 0) // zoom
					ChangeAxis(-1, ZoomWindow)
				endif
			endif
		Endif // end of continuous_flag == 1
		if (write_permit == 1)
			if ( 0 == write_sweep(InData)) // note that the variable 'acquired' is advanced by write_sweep()
					if (scheme_on)  //(cont_multi_flag)
		 				decode_pro("pro_0")
		 				set_stim()
						current_pro = 0
						Return(0)
					EndIf
				Return(0)
			Endif
		Endif
		if (update == 1)
		index = 0
		Do
			If (cmpstr(seq_in[index], "D") != 0)
				strswitch(seq_in[index])
				case "0":
					adc0[0,samples-1]=InData[index+p*total_chan_num]
					adc0 /= (3.2 * adc_gain0)
					break
				case "1":
					adc1[0,samples-1]=InData[index+p*total_chan_num]
					adc1 /= (3.2 * adc_gain1)
					break
				case "2":
					adc2[0,samples-1]=InData[index+p*total_chan_num]
					adc2 /= (3.2 * adc_gain2)
					break
				case "3":
					adc3[0,samples-1]=InData[index+p*total_chan_num]
					adc3 /= (3.2 * adc_gain3)
					break
				EndSwitch
			Endif
			index += 1
		While (index < total_chan_num)

		Endif // if update
//Added next four lines by spb 6-10-03 to display resistance of electrode
		 res_index += 1
		 res_index_flag = 1
		if ((dac0_start[0] > 0.5) && ((dac0_end[0]-dac0_start[0]) > 8) && dac0_status)
			res_temp += abs((((hp0-dac0_amp[0])*10^-3) / ((mean(adc0,0.5,dac0_start[0] - .5) - mean(adc0,dac0_start[0] + 8,dac0_end[0] - .5)) *10^-12)) / 10^6)
			if (res_index == res_sum)
				electrode0_res =  res_temp/res_sum
				res_index_flag = 0
				res_temp = 0
			Endif
                 EndIf
                 if ((dac1_start[0] > 0.5) && ((dac1_end[0]-dac1_start[0]) > 8) && dac1_status)
                 	res_temp += abs((((hp1-dac1_amp[0])*10^-3) / ((mean(adc1,0.5,dac1_start[0] - .5) - mean(adc1,dac1_start[0] + 8,dac1_end[0] - .5)) *10^-12)) / 10^6)
                 	if (res_index == res_sum)
				electrode1_res =  res_temp/res_sum
				res_index_flag = 0
				res_temp = 0
			Endif
                 EndIf
                 if ((dac2_start[0] > 0.5) && ((dac2_end[0]-dac2_start[0]) > 8) && dac2_status)
                   res_temp += abs((((hp2-dac2_amp[0])*10^-3) / ((mean(adc2,0.5,dac2_start[0] - .5) - mean(adc2,dac2_start[0] + 8,dac2_end[0] - .5)) *10^-12)) / 10^6)
                   if (res_index == res_sum)
				electrode2_res =  res_temp/res_sum
				res_index_flag = 0
				res_temp = 0
			Endif
                 EndIf
                 if ((dac3_start[0] > 0.5) && ((dac3_end[0]-dac3_start[0]) > 8) && dac3_status)
                    res_temp += abs((((hp3-dac3_amp[0])*10^-3) / ((mean(adc3,0.5,dac3_start[0] - .5) - mean(adc3,dac3_start[0] + 8,dac3_end[0] - .5)) *10^-12)) / 10^6) 
                   if (res_index == res_sum)
				electrode3_res =  res_temp/res_sum
				res_index_flag = 0
				res_temp = 0
			Endif
                 EndIf
                 if (res_index_flag == 0)
                 	res_index = 0
                 Endif
                 if (align_flag)
			align_traces()
		EndIf
		if (smooth_flag)
			smooth_trace()
		EndIf
		If ( (adc0_avg_flag == 1) || (adc1_avg_flag == 1) || (adc2_avg_flag == 1) || (adc3_avg_flag == 1) )
			av_sweeps += 1
			if (adc0_avg_flag)
				avg0_temp += adc0
				avg0 = avg0_temp / av_sweeps
			Endif
			if (adc1_avg_flag)
				avg1_temp += adc1
				avg1 = avg1_temp / av_sweeps
			Endif
			if (adc2_avg_flag)
				avg2_temp += adc2
				avg2 = avg2_temp / av_sweeps
			Endif
			if (adc3_avg_flag)
				avg3_temp += adc3
				avg3 = avg3_temp / av_sweeps
			Endif
		Endif
		sweeps += 1
//		printf "pro_num: %d, sweeps: %d\r", num,sweeps
		s = KeyboardState("")
 		if ((cmpstr(s[9], "z") == 0)%| (stop_request == 1)) // z   to stop
 			if (ITC18)
 			Execute ("ITC18StopAcq")
 			Endif
 //			set_hp(0, hp0)
// 			set_hp(1, hp1)
// 			set_hp(2, hp2)
// 			set_hp(3, hp3)
 			if (scheme_on)  //(cont_multi_flag)
 				decode_pro("pro_0")
 				set_stim()
 			EndIf
   			break
 		Endif
 		if ((cmpstr(s[9], "s") == 0)) // auto scale
 			ControlInfo /W=Panel_AQ_C A_Scale // get info on checkbox
 			if(v_value)
 				A_scale("", 0)
 				CheckBox A_Scale, Win=Panel_AQ_C, Value=0
 			Else
 				A_scale("", 1)
 				CheckBox A_Scale, Win=Panel_AQ_C, Value=1
 			Endif
 		EndIf
 		variable change
		if ((cmpstr(s[9], "-") == 0)) // hyperpolarize
			change = -5
		Endif
		if ((cmpstr(s[9], "=") == 0)) // depolarize
			change = 5
		Endif
		if ((cmpstr(s[9], "-") == 0) || (cmpstr(s[9], "=") == 0))
			if (dac0_status)
				if ((hp0 > -100 && change < 0) || (hp0 < 0  && change > 0))
					hp0 += change
					dac0_amp[0] += change
				Endif
			Endif
			if (dac1_status)
				if ((hp1 > -100 && change < 0) || (hp1 < 0  && change > 0))
					hp1 += change
					dac1_amp[0] += change
				Endif
			Endif
			if (dac2_status)
				if ((hp2 > -100 && change < 0) || (hp2 < 0  && change > 0))
					hp2 += change
					dac2_amp[0] += change
				Endif
			Endif	
			if (dac3_status)
				if ((hp3 > -100 && change < 0) || (hp3 < 0  && change > 0))
					hp3 += change
					dac3_amp[0] += change
				Endif
			Endif	
			set_stim()
		Endif
		if (cross_flag == 1)
			i = 0
			j = 0
			spikes_0 = detect_ap_peaks(adc0, spike_thresh, spike_duration, 1000, (samples-1000), detections_0)
			spikes_1 = detect_ap_peaks(adc1, spike_thresh, spike_duration, 500, (samples-500), detections_1)
			detections_0 /= 10  // to get ms bins
			detections_1 /= 10
			mm = 0
			do
				if ((spikes_0 == 0) %| (spikes_1 == 0))
					break
				Endif
				kk = 0
				do
					tm = detections_1[kk] - detections_0[mm]
					if ((tm >= 0) %& (tm < mid_point))
						psth[mid_point + tm] += 1	
					Endif
					kk += 1
				while (kk < spikes_1)
				mm += 1
			While(mm < spikes_0)
			mm = 0
			do
				if ((spikes_0 == 0) %| (spikes_1 == 0))
					break
				Endif
				kk = 0
				do
					tm = (detections_0[mm] - detections_1[kk])
					if ((tm > 0) %& (tm <= mid_point) )
						psth[mid_point - tm] += 1	
					Endif
					kk += 1
				while (kk < spikes_1)
				mm += 1
			While(mm < spikes_0)
			DoUpDate
		Endif
		if (his_flag == 1)
			detections = 0
			spike_num = detect_ap_peaks($spike_detection_trace_name, spike_thresh, spike_duration, 1, (samples-1), detections)
			printf "do_a_protocol(): spike_num =%d\r", spike_num
			m = total_spikes
			kk = 0
			do
				total_detections[m+kk] = detections[kk]
				kk += 1
			While(kk < spike_num)
			total_spikes += spike_num
			Histogram /B={0 , bin_size, (samples/bin_size)} /R=[0, (total_spikes-1)] total_detections, psth
			histogram_sweeps += 1
			psth *= ((freq*1000.0)/(bin_size*(histogram_sweeps+1)))
			SetScale /P x 0, (bin_size/freq), "ms", psth
			SetScale d 0, 0, "Frequency (Hz)", psth
		Endif
	if (draw_flag)
		DoWindow /F G_traces
		setdrawlayer /K progback
		setdrawenv linethick=1.2, linefgc=(0,26112,13056), xcoord=bottom, ycoord=$get_yaxis(analysis_trace_name_wave[i])
		setdrawenv save
	Endif
		i = 0
		string wavename
		Do
			if (amp_analysis_flag_wave[i])
				peak = Get_Amp(amp_analysis_mode_wave[i],analysis_trace_name_wave[i], amp_bl_start_wave[i], amp_bl_end_wave[i], amp_start_wave[i], amp_end_wave[i], "G_Traces")
				wavename = ("amp_points_wave_" + num2str(i))
				WAVE tempwave = $wavename
				tempwave[analysed_points_wave[i]]  = peak
				analysed_points_wave[i] += 1
			Endif
			i += 1
		While (i < 10)
		if (update)
			if (Scale_to_Vis)
				Scale_Vis("G_traces")
//				Scale_Vis("G_average")
			EndIf			
			DoUpDate
		endif
 		s = KeyboardState("")
// 		if (cmpstr(s[9], "z") == 0) // z  to stop
 //			stop_request = 1
//			break
//		endif
		pro_running = 1
		if (amp_change_0 != 0)
			dac0_amp[0] += amp_change_0
		Endif
		if (amp_change_1 != 0)
			dac1_amp[0] += amp_change_1
		Endif
		if (amp_change_2 != 0)
			dac2_amp[0] += amp_change_2
		Endif
		if (amp_change_3 != 0)
			dac3_amp[0] += amp_change_3
		Endif
		if ((amp_change_3 != 0) || (amp_change_2 != 0) || (amp_change_1 != 0) || (amp_change_0 != 0))
			set_stim()
		Endif
	while(((sweeps < requested) || (requested == -1)) || ((scheme_on == 1) && (continuous_flag == 1) && (scheme_repeat_index < scheme_repeat))) // if cont_multi_flag cycle protocols and only single sweep for each protocol
	if(ITC18)
	Execute ("ITC18StopAcq")
	Endif
	if (dac0_status)
		set_hp(0, hp0)
	Endif
	if (dac1_status)
		set_hp(1, hp1)
	Endif
	if (dac2_status)
		set_hp(2, hp2)
	Endif
	If(dac3_status)
		set_hp(3, hp3)
	Endif
	if (update != 1)
	index = 0
	Do
		If (cmpstr(seq_in[index], "D") != 0)
			strswitch(seq_in[index])
			case "0":
				adc0[0,samples-1]=InData[index+p*total_chan_num]
				adc0 /= (3.2 * adc_gain0)
				break
			case "1":
				adc1[0,samples-1]=InData[index+p*total_chan_num]
				adc1 /= (3.2 * adc_gain1)
				break
			case "2":
				adc2[0,samples-1]=InData[index+p*total_chan_num]
				adc2 /= (3.2 * adc_gain2)
				break
			case "3":
				adc3[0,samples-1]=InData[index+p*total_chan_num]
				adc3 /= (3.2 * adc_gain3)
				break
			EndSwitch
		Endif
		index += 1
	While (index < total_chan_num)
	Endif // of != update
	if (Scale_to_Vis)
		Scale_Vis("G_Traces")
		Scale_Vis("G_average")
EndIf
	return(stop_request)
End



// for now only dac0, dac1 are allowed
function Set_Stim()
	SVAR seq_out
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR ttl_status, fake_chan
	NVAR adc_status4=adc_status4,adc_status5=adc_status5,adc_status6=adc_status6,adc_status7=adc_status7
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4=adc_gain4,adc_gain5=adc_gain5,adc_gain6=adc_gain6,adc_gain7=adc_gain7
	NVAR samples, total_chan_num
	NVAR hp0, hp1,hp2,hp3
	NVAR dac0_pulse_num, dac1_pulse_num,dac2_pulse_num, dac3_pulse_num   //, ttl1_pulse_num, ttl2_pulse_num, ttl3_pulse_num, ttl4_pulse_num
	NVAR freq, stimfile_loc
	NVAR dac0_stimfile_flag,stimfile_ref,dac0_stimfile_scale,stimfile_recycle
	NVAR dac1_stimfile_flag,dac1_stimfile_scale
	NVAR dac2_stimfile_flag,dac2_stimfile_scale
	NVAR dac3_stimfile_flag,dac3_stimfile_scale
	NVAR sine_flag_dac0, sine_flag_dac1,sine_flag_dac2, sine_phase_dac0, sine_phase_dac3,sine_flag_dac3
	NVAR sine_phase_dac1,sine_phase_dac2, sine_amp_dac0, sine_amp_dac1,sine_amp_dac2,sine_amp_dac3
	NVAR sine_freq_dac0, sine_freq_dac1,sine_freq_dac2,sine_freq_dac3

	WAVE psc=psc
	NVAR dac0_psc_flag, dac1_psc_flag,dac2_psc_flag,dac3_psc_flag,acquire_mode
	SVAR stimfile_name=stimfile_name
	NVAR pro_0_stimfile_loc=pro_0_stimfile_loc, pro_1_stimfile_loc=pro_1_stimfile_loc
	WAVE StimWave=StimeWave, dac0_amp, dac0_start, dac0_end
//	WAVE ttl1_start, ttl1_end, ttl2_start, ttl2_end,ttl3_start, ttl3_end, ttl4_start, ttl4_end
	WAVE dac1_amp, dac1_start, dac1_end,stimfile_wave,dac2_amp, dac2_start, dac2_end
	WAVE dac3_amp, dac3_start, dac3_end
	Make /O/N=(samples*total_chan_num) StimWave 
	Make /O/N=(samples) dac0_stimwave, dac1_stimwave,dac2_stimwave, dac3_stimwave, ttl_stimwave
	variable i
	i = 0
	if (numtype(dac1_pulse_num) == 2)
		dac1_pulse_num = 1
	Endif
	if (numtype(dac0_pulse_num) == 2)
		dac0_pulse_num = 1
	Endif
	dac0_stimwave = hp0 * dac0_gain * 3.2
	dac1_stimwave = hp1 * dac1_gain * 3.2
	dac2_stimwave = hp2 * dac2_gain * 3.2
	dac3_stimwave = hp3 * dac3_gain * 3.2
	ttl_stimwave = 0 // zero ttl stimulation wave
	if ((acquire_mode == 0) %& ((dac0_stimfile_flag == 1) %| (dac1_stimfile_flag == 1) %| (dac2_stimfile_flag == 1) %| (dac3_stimfile_flag == 1)))
		Make /O/N=(samples) stimfile_wave
		SetScale /P x 0, (1.0/freq), "ms", stimfile_wave
	Endif
// make 16 TTL waves combined in ttl_stimwave	
	variable j
	For(i = 1; i < 16; i += 1) // first ttl channel is reserved for scope trigger
		NVAR ttl_pulse_num = $("ttl"+num2str(i)+"_pulse_num")
		WAVE ttl_start = $("ttl"+num2str(i)+"_start")
		WAVE ttl_end = $("ttl"+num2str(i)+"_end")
//		ttl_start = 0
//		ttl_end = 0
		j = 0
		For (j = 0; j < ttl_pulse_num; j += 1)
//			WAVE ttl_start = $("ttl"+num2str(j)+"_start")
//			WAVE ttl_end = $("ttl"+num2str(j)+"_end")
			ttl_stimwave[ttl_start[j]*freq, ttl_end[j]*freq] = (2^i | ttl_stimwave[p])
		EndFor
	EndFor
	if ((dac0_status == 1) %| (acquire_mode == 0))
		i = 0
		do
			if (i >= dac0_pulse_num)
				break
			endif
			if (numtype(dac0_pulse_num) == 2)
				break
			Endif
			dac0_stimwave[dac0_start[i]*freq, dac0_end[i]*freq] = (dac0_amp[i] * dac0_gain * 3.2)
			i += 1
		While (i < dac0_pulse_num)
		if (dac0_stimfile_flag == 1) 
			FStatus stimfile_ref
			if (V_flag != 0)
				FSetPos stimfile_ref, (stimfile_loc * samples * 2) 
				if (stimfile_recycle == 0)
					stimfile_loc += 1
				Endif
				FBinRead /F=2 stimfile_ref, stimfile_wave
				stimfile_wave *= dac0_stimfile_scale
			Endif
			dac0_stimwave += (stimfile_wave * dac0_gain * 3.2)
			dac0_stimwave[0,499] = hp0 * dac0_gain * 3.2
			dac0_stimwave[samples-500,samples] = hp0 * dac0_gain * 3.2
		Endif
		if (dac0_psc_flag == 1)
			make_psc(0, psc, samples,(1/freq))
			dac0_stimwave += psc
		Endif
		if (sine_flag_dac0 == 1)
			Make /O/N=(samples) sine_wave
			make_sine(sine_wave, samples, freq, sine_freq_dac0, sine_amp_dac0, sine_phase_dac0)
			dac0_stimwave += sine_wave
		Endif
		if (total_chan_num == 1)
			StimWave = dac0_stimwave
		Endif
	endif
	if (dac1_status == 1)
		i = 0
		do
			if (i >= dac1_pulse_num)
				break
			endif
			if (dac1_pulse_num == NaN)
				break
			Endif
			dac1_stimwave[dac1_start[i]*freq, dac1_end[i]*freq] = (dac1_amp[i] * dac1_gain * 3.2)
			i += 1
		While (i < dac1_pulse_num)
		if (dac1_stimfile_flag == 1) // stim file is open
			FStatus stimfile_ref
			if (V_flag != 0)
				FSetPos stimfile_ref, (stimfile_loc * samples * 2) 
				FBinRead /F=2 stimfile_ref, stimfile_wave
				if (stimfile_recycle == 0)
					stimfile_loc += 1
				Endif
				stimfile_wave *= dac1_stimfile_scale
			Endif
			dac1_stimwave += (stimfile_wave * dac1_gain * 3.2)
			dac1_stimwave[0,499] = hp1 * dac1_gain * 3.2
			dac1_stimwave[samples-500,samples] = hp1 * dac1_gain * 3.2
		Endif
		if (sine_flag_dac1 == 1)
			Make /O/N=(samples) sine_wave
			make_sine(sine_wave, samples, freq, sine_freq_dac1, sine_amp_dac1, sine_phase_dac1)
			dac1_stimwave += sine_wave
		Endif
		if (dac1_psc_flag == 1)
			make_psc(1, psc, samples,(1/freq))
			dac1_stimwave += psc
		Endif
		if (total_chan_num == 1)
			StimWave = dac1_stimwave
		Endif
	Endif	
	if (dac2_status == 1)
		i = 0
		do
			if (i >= dac2_pulse_num)
				break
			endif
			if (dac2_pulse_num == NaN)
				break
			Endif
			dac2_stimwave[dac2_start[i]*freq, dac2_end[i]*freq] = (dac2_amp[i] * dac2_gain * 3.2)
			i += 1
		While (i < dac2_pulse_num)
		if (dac2_stimfile_flag == 1) // stim file is open
			FStatus stimfile_ref
			if (V_flag != 0)
				FSetPos stimfile_ref, (stimfile_loc * samples * 2) 
				FBinRead /F=2 stimfile_ref, stimfile_wave
				if (stimfile_recycle == 0)
					stimfile_loc += 1
				Endif
				stimfile_wave *= dac2_stimfile_scale
			Endif
			dac2_stimwave += (stimfile_wave * dac2_gain * 3.2)
			dac2_stimwave[0,499] = hp2 * dac2_gain * 3.2
			dac2_stimwave[samples-500,samples] = hp2 * dac2_gain * 3.2
		Endif
		if (sine_flag_dac2 == 1)
			Make /O/N=(samples) sine_wave
			make_sine(sine_wave, samples, freq, sine_freq_dac2, sine_amp_dac2, sine_phase_dac2)
			dac2_stimwave += sine_wave
		Endif
		if (dac2_psc_flag == 1)
			make_psc(2, psc, samples,(1/freq))
			dac2_stimwave += psc
		Endif
		if (total_chan_num == 1)
			StimWave = dac2_stimwave
		Endif
	Endif	
	
	if (dac3_status == 1)
	i = 0
		do
			if (i >= dac3_pulse_num)
				break
			endif
			if (numtype(dac3_pulse_num) == 2)
				break
			Endif
			dac3_stimwave[dac3_start[i]*freq, dac3_end[i]*freq] = (dac3_amp[i] * dac3_gain * 3.2)
			i += 1
		While (i < dac3_pulse_num)
		if (dac3_stimfile_flag == 1) 
			FStatus stimfile_ref
			if (V_flag != 0)
				FSetPos stimfile_ref, (stimfile_loc * samples * 2) 
				if (stimfile_recycle == 0)
					stimfile_loc += 1
				Endif
				FBinRead /F=2 stimfile_ref, stimfile_wave
				stimfile_wave *= dac3_stimfile_scale
			Endif
			dac3_stimwave += (stimfile_wave * dac3_gain * 3.2)
			dac3_stimwave[0,499] = hp3 * dac3_gain * 3.2
			dac3_stimwave[samples-500,samples] = hp3 * dac3_gain * 3.2
		Endif
		if (dac3_psc_flag == 1)
			make_psc(0, psc, samples,(1/freq))
			dac3_stimwave += psc
		Endif
		if (sine_flag_dac3 == 1)
			Make /O/N=(samples) sine_wave
			make_sine(sine_wave, samples, freq, sine_freq_dac3, sine_amp_dac3, sine_phase_dac3)
			dac3_stimwave += sine_wave
		Endif
		if (total_chan_num == 1)
			StimWave = dac3_stimwave
		Endif
	endif

	// trigger the scope
	if (ttl_status == 1)
//		ttl_stimwave[0, 2*freq] += 1
		ttl_stimwave[0, 2*freq] = (ttl_stimwave[p] | 0x1)
	Endif
	
	variable index = 0
	Do
		strswitch(seq_out[index])
			case "0":
			StimWave[index,(total_chan_num*(samples-1)+index);total_chan_num]=dac0_stimwave[(p-index)/(total_chan_num)]
			break
			case "1":
			StimWave[index,(total_chan_num*(samples-1)+index);total_chan_num]=dac1_stimwave[(p-index)/(total_chan_num)]
			break
			case "2":
			StimWave[index,(total_chan_num*(samples-1)+index);total_chan_num]=dac2_stimwave[(p-index)/(total_chan_num)]
			break
			case "3":
			StimWave[index,(total_chan_num*(samples-1)+index);total_chan_num]=dac3_stimwave[(p-index)/(total_chan_num)]
			break
			default:
			Stimwave[index,(total_chan_num*samples-index);total_chan_num]=ttl_stimwave[(p-index)/total_chan_num]
			break
		EndSwitch
		index += 1
	While (index<total_chan_num)

End
		 
function set_in()

	NVAR dac0_status=dac0_status,dac1_status=dac1_status,dac2_status=dac2_status,dac3_status=dac3_status
	NVAR adc_status0=adc_status0,adc_status1=adc_status1,adc_status2=adc_status2,adc_status3=adc_status3
	NVAR adc_status4=adc_status4,adc_status5=adc_status5,adc_status6=adc_status6,adc_status7=adc_status7
	NVAR dac0_gain=dac0_gain,dac1_gain=dac1_gain,dac2_gain=dac2_gain,dac3_gain=dac3_gain
	NVAR adc_gain0=adc_gain0,adc_gain1=adc_gain1,adc_gain2=adc_gain2,adc_gain3=adc_gain3
	NVAR adc_gain4=adc_gain4,adc_gain5=adc_gain5,adc_gain6=adc_gain6,adc_gain7=adc_gain7
	NVAR samples, freq, total_chan_num,dac0_vc,dac1_vc,dac2_vc,dac3_vc
	NVAR init_flag
	WAVE adc0_avg, adc1_avg, adc2_avg 
//	WAVE adc0=adc0,adc1=adc1,adc0_avg=adc0_avg,adc1_avg=adc1_avg, InData=InData
	if (init_flag == 1)
		Make /O/N=(samples) adc0_avg=0,adc1_avg=0,adc2_avg=0
		SetScale /P x 0, (1.0/freq), "ms", adc0_avg, adc1_avg, adc2_avg
	Endif
	Make /O/N=(samples) adc0=0, adc1=0,adc2=0, adc3=0
	Make /O/N=(samples*total_chan_num) InData
	Make /O/N=(samples*total_chan_num) StimWave 
	Make /O/N=(samples) dac0_stimwave, dac1_stimwave, stimfile_wave
 
	
	SetScale /P x 0, (1.0/freq), "ms", adc0, adc1,adc2, adc3, stimfile_wave
	if (dac0_vc == 1)
		SetScale d, -200, 200, "pA", adc0
	Else
		SetScale d, -200, 200, "mV", adc0
	Endif
	if (dac1_vc == 1)
		SetScale d, -200, 200, "pA", adc1
	Else
		SetScale d, -200, 200, "mV", adc1
	Endif
	if (dac2_vc == 1)
		SetScale d, -200, 200, "pA", adc2
	Else
		SetScale d, -200, 200, "mV", adc2
	Endif
	if (dac3_vc == 1)
		SetScale d, -200, 200, "pA", adc3
	Else
		SetScale d, -200, 200, "mV", adc3
	Endif

End

function Set_HP(dac_num, level)
	variable dac_num //0, 1, 2, 3
	variable level		// in mV or pA
	NVAR dac0_status=dac0_status,dac1_status=dac1_status,dac2_status=dac2_status,dac3_status=dac3_status
	NVAR dac0_gain=dac0_gain,dac1_gain=dac1_gain,dac2_gain=dac2_gain,dac3_gain=dac3_gain
	NVAR hp0, hp1, hp2, hp3
	NVAR ITC18
	variable output
	string command
	string outputstr
	command = "ITC18SetDAC "
	if (dac_num == 0)
		if (dac0_status != 1)
			beep; beep; beep
			printf "ERROR: dac0_status != 1 ;acquire_acquisition;\r"
			return(0)
		endif
		hp0 = level
		output = dac0_gain * level / 1000.0
//		printf "chan:0 level: %f output: %f\r", level, output  
		outputstr = num2str(output)
		command += ("0, " + outputstr)
//		printf "command: %s\r", command
		if(ITC18)
		Execute (command)
		Endif
		Return(1)
	Endif
	if (dac_num == 1)
		if (dac1_status != 1)
			beep; beep; beep
			printf "ERROR: dac1_status != 1 (acquire_acquisition)\r"
			return(0)
		endif
		hp1 = level
		output = dac1_gain * level / 1000.0
//		printf "chan:1 level: %f output: %f\r", level, output  
		outputstr = num2str(output)
		command += ("1, " + outputstr)
//		printf "command: %s\r", command
		if(ITC18)
		Execute (command)
		Endif
		Return(1)
	Endif
	if (dac_num == 2)
		if (dac2_status != 1)
			beep; beep; beep
			printf "ERROR: dac2_status = %d (acquire_acquisition)\r", dac2_status
			return(0)
		endif
		hp2 = level
		output = dac2_gain * level / 1000.0
//		printf "chan:2 level: %f output: %f\r", level, output  
		outputstr = num2str(output)
		command += ("2, " + outputstr)
//		printf "command: %s\r", command
		if(ITC18)
		Execute (command)
		Endif
		Return(1)
	Endif
	if (dac_num == 3)
		if (dac3_status != 1)
			beep; beep; beep
			printf "ERROR: dac3_status = %d (acquire_acquisition)\r", dac3_status
			return(0)
		endif
		hp3 = level
		output = dac3_gain * level / 1000.0
//		printf "chan:3 level: %f output: %f\r", level, output  
		outputstr = num2str(output)
		command += ("3, " + outputstr)
//		printf "command: %s\r", command
		if(ITC18)
		Execute (command)
		Endif
		Return(1)
	Endif
End




function make_sine(sine_wave, samples, freq,sine_freq, sine_amp, sine_phase)
	wave sine_wave
	variable samples, freq, sine_freq, sine_amp, sine_phase
	variable Duration, cycles
	duration = (1/freq) * samples // in ms
	cycles = sine_freq * duration /1000 // in seconds
	SetScale /P x, 0, (1/freq), sine_wave
	sine_wave = 1.6 * sine_amp * sin(sine_phase * 2 * Pi + (2 * Pi * x * cycles) / duration)
	sine_wave[0,(0.05*samples)] = 0
	sine_wave[(0.95*samples),samples-1] = 0
End






function make_psc(dac_num, psc,samples,dt)
	wave psc
	variable dac_num, samples,dt
	NVAR dac0_psc1_amp=dac0_psc1_amp, dac0_psc2_amp=dac0_psc2_amp,dac0_psc1_taurise=dac0_psc1_taurise, dac0_psc2_taurise=dac0_psc2_taurise
	NVAR dac0_psc1_taudecay=dac0_psc1_taudecay,dac0_psc2_taudecay=dac0_psc2_taudecay, dac0_psc_interval=dac0_psc_interval, dac0_psc_start=dac0_psc_start
	NVAR dac1_psc1_amp=dac1_psc1_amp, dac1_psc2_amp=dac1_psc2_amp,dac1_psc1_taurise=dac1_psc1_taurise, dac1_psc2_taurise=dac1_psc2_taurise
	NVAR dac1_psc1_taudecay=dac1_psc1_taudecay,dac1_psc2_taudecay=dac1_psc2_taudecay, dac1_psc_interval=dac1_psc_interval, dac1_psc_start=dac1_psc_start
	NVAR dac0_psc3_taudecay=dac0_psc3_taudecay, dac0_psc3_amp=dac0_psc3_amp,dac0_psc3_taurise=dac0_psc3_taurise,dac0_psc_int2=dac0_psc_int2
	variable num
//	variable ref
	Make /O/N=(samples) psc, psc1, psc2, psc3
	SetScale /P x, 0, (dt),  psc , psc1, psc2, psc3
	if (dac_num == 0)
		psc1 = 1.6 * dac0_psc1_amp * (1-exp(-x/dac0_psc1_taurise))*exp(-x/dac0_psc1_taudecay) // 1.6 units gives 1 pA in CC
		InsertPoints 0, dac0_psc_start, psc1
		psc1[0,dac0_psc_start] = 0
		DeletePoints (samples), dac0_psc_start, psc1  
		psc2 = 1.6 * dac0_psc2_amp * (1-exp(-x/dac0_psc2_taurise))*exp(-x/dac0_psc2_taudecay) // 1.6 units gives 1 pA in CC
		InsertPoints 0, (dac0_psc_start+dac0_psc_interval), psc2
		psc2[0,(dac0_psc_start+dac0_psc_interval)] = 0
		DeletePoints (samples), (dac0_psc_start+dac0_psc_interval), psc2
		if (dac0_psc3_amp != NaN)
			psc3 = 1.6 * dac0_psc3_amp * (1-exp(-x/dac0_psc3_taurise))*exp(-x/dac0_psc3_taudecay) // 1.6 units gives 1 pA in CC
			InsertPoints 0, (dac0_psc_start+dac0_psc_interval+dac0_psc_int2), psc3
			psc3[0,(dac0_psc_start+dac0_psc_interval+dac0_psc_int2)] = 0
			DeletePoints (samples), (dac0_psc_start+dac0_psc_interval+dac0_psc_int2), psc3
			psc = psc1 + psc2  + psc3
		Else
			printf "dac0_psc3_amp = %d\r", dac0_psc3_amp
			psc = psc1 + psc2
		Endif
	Else
		psc1 = 1.6 * dac1_psc1_amp * (1-exp(-x/dac1_psc1_taurise))*exp(-x/dac1_psc1_taudecay) // 1.6 units gives 1 pA in CC
		InsertPoints 0, dac1_psc_start, psc1
		psc1[0,dac1_psc_start] = 0
		DeletePoints (samples), dac1_psc_start, psc1  
		psc2 = 1.6 * dac1_psc2_amp * (1-exp(-x/dac1_psc2_taurise))*exp(-x/dac1_psc2_taudecay) // 1.6 units gives 1 pA in CC
		InsertPoints 0, (dac1_psc_start+dac1_psc_interval), psc2
		psc2[0,(dac1_psc_start+dac1_psc_interval)] = 0
		DeletePoints (samples), (dac1_psc_start+dac1_psc_interval), psc2
		psc = psc1 + psc2  
	Endif
End

function wait_time(t) // register the current time and wait t seconds
	variable t // in seconds
	t *= 0.983 // fudge 
	variable t1, cycle_time, stop_request
	variable /g t0
	string s
	stop_request = 0
	t0 = ticks
	do
		t1 = ticks
		cycle_time = (t1-t0)/60.0
		s = KeyboardState("")
		if (cmpstr(s[9], "z") == 0) // z  to stop
			stop_request = 1
 			break
		endif
	While (cycle_time < t)
	Return(stop_request)
End





function set_pulses(CntrlName) : ButtonControl
	string CntrlName
	variable chan, pulse_duration, num, start, amp, interval
	NVAR Gchan, Gpulse_duration, Gnum, Gstart, Gamp, Ginterval
// globals to hold previous values
	if (Nvar_Exists(Gchan) == 0)
		variable /g Gchan = 0
	Endif 
	if (Nvar_Exists(GPulse_duration) == 0)
		variable /g GPulse_duration = 0
	Endif 
	if (Nvar_Exists(Gnum) == 0)
		variable /g Gnum = 0
	Endif 
	if (Nvar_Exists(Gstart) == 0)
		variable /g Gstart = 0
	Endif 
	if (Nvar_Exists(Gamp) == 0)
		variable /g Gamp = 0
	Endif 
	if (Nvar_Exists(Ginterval) == 0)
		variable /g Ginterval = 0
	Endif 

// copy globals onto locals
	chan = Gchan
	pulse_duration = Gpulse_duration
	num = Gnum
	start = Gstart
	amp = Gamp
	interval = Ginterval	
	
	Prompt chan, "DAC number"		// Set prompt for x param
	Prompt amp, "amplitude"
	Prompt  start, "train start (ms)"
	Prompt pulse_duration, "pulse duration (ms)"		// Set prompt for y param
	Prompt interval, "inter-pulse interval (ms)"
	Prompt num, "number of pulses"
	DoPrompt "Pulse Train Parameters", chan, amp, start, pulse_duration, interval, num
	if (V_Flag)
		return -1								// User canceled
	endif
	variable i
	WAVE dac_start = $("dac"+num2str(chan)+"_start")
	WAVE dac_end = $("dac"+num2str(chan)+"_end")
	WAVE dac_amp = $("dac"+num2str(chan)+"_amp")
	NVAR dac_pulse_num = $("dac"+num2str(chan)+"_pulse_num")
	dac_start[0] = start
	dac_end[0] = start+pulse_duration
	dac_amp[0] = amp
	if (num < 1000)
		dac_pulse_num = num
	else
		dac_pulse_num = 1000
	Endif
	for (i=1; i < dac_pulse_num; i += 1)
		 dac_start[i] = dac_start[0] + i*interval
		 dac_end[i] = dac_start[i] + pulse_duration
		 dac_amp[i] = dac_amp[0]
	EndFor
	dac_start[dac_pulse_num, ] = 0
	dac_end[dac_pulse_num, ] = 0
	dac_amp[dac_pulse_num, ] = 0
	set_stim()
	// copy locals onto globals
	Gchan = chan
	Gpulse_duration = pulse_duration
	Gnum = num
	Gstart = start
	Gamp = amp
	Ginterval = interval

End

function set_delta(CntrlName) : ButtonControl
	string CntrlName
	NVAR amp_change_0, amp_change_1, amp_change_2, amp_change_3
	variable amp_delta_0 = amp_change_0, amp_delta_1 = amp_change_1, amp_delta_2 = amp_change_2, amp_delta_3 = amp_change_3
	Prompt amp_delta_0, "DAC0 amplitude Delta (mV/pA)"
	Prompt amp_delta_1, "DAC1 amplitude Delta (mV/pA)"
	Prompt amp_delta_2, "DAC2 amplitude Delta (mV/pA)"
	Prompt amp_delta_3, "DAC3 amplitude Delta (mV/pA)"
	DoPrompt "Delta Parameters", amp_delta_0, amp_delta_1, amp_delta_2, amp_delta_3 
	if (V_Flag)
		return -1								// User canceled
	endif
	// copy locals onto globals
	amp_change_0 = amp_delta_0 
	amp_change_1 = amp_delta_1 
	amp_change_2 = amp_delta_2 
	amp_change_3 = amp_delta_3 
End






function Do_a_Scheme(CntrlName) : ButtonControl
	String CntrlName
	NVAR cont_multi_flag
	NVAR last_protocol_run_time
	NVAR wait
	NVAR requested
	NVAR wait_lf, scheme_repeat,number_of_pro,scheme_on, init_display
	NVAR stimfile_loc=stimfile_loc,stimfile_recycle=stimfile_recycle, samples,freq,init_analysis
	SVAR scheme
	WAVE scheme_wait
	WAVE adc0_avg,adc1_avg,adc2_avg,adc0_avg_temp,adc1_avg_temp,adc2_avg_temp,adc3_avg,adc3_avg_temp
	para_change() // close the write file and make a new one
// make 80 waves to be used for averaging 20 protocols
	variable i = 0
	if (init_analysis)
		init_amp_analysis("")
         	Do
		 	Make /O/N=(samples) $("adc0_avg_"+num2str(i))=0, $("root:avg:adc0_avg_temp_"+num2str(i))=0
			SetScale /P x 0, (1.0/freq), "ms", $("adc0_avg_"+num2str(i))
			SetScale d, -200, 200, "pA", $("adc0_avg_"+num2str(i))
			Make /O/N=(samples) $("adc1_avg_"+num2str(i))=0, $("root:avg:adc1_avg_temp_"+num2str(i))=0
			SetScale /P x 0, (1.0/freq), "ms", $("adc1_avg_"+num2str(i))
			SetScale d, -200, 200, "pA", $("adc1_avg_"+num2str(i))
			Make /O/N=(samples) $("adc2_avg_"+num2str(i))=0, $("root:avg:adc2_avg_temp_"+num2str(i))=0
			SetScale /P x 0, (1.0/freq), "ms", $("adc2_avg_"+num2str(i))
			SetScale d, -200, 200, "pA", $("adc2_avg_"+num2str(i))
			Make /O/N=(samples) $("adc3_avg_"+num2str(i))=0, $("root:avg:adc3_avg_temp_"+num2str(i))=0
			SetScale /P x 0, (1.0/freq), "ms", $("adc3_avg_"+num2str(i))
			SetScale d, -200, 200, "pA", $("adc3_avg_"+num2str(i))
			NVAR av_sweeps = $("av_sweeps_"+num2str(i))
			av_sweeps = 0
			i += 1
		While (i < 20) 	
	EndIf
	if (scheme_on) //(cont_multi_flag) // for continuous "scheme" run protocol
		if (init_analysis)
			init_amp_analysis("")
		Endif
//		set_run("") // do a protocol
		scheme_on = 1
		do_a_protocol(0)
		scheme_on = 0
		Return(0)
	EndIf
	
	variable j
	variable t0,t1,cycle_time,stop_request
	string s
	scheme_on = 1
// init and make waves for averaging	
	if (init_analysis == 1)
		Make /O/N=(samples) adc1_avg=0, adc1_avg_temp=0, adc2_avg=0, adc2_avg_temp=0, adc0_avg=0, adc0_avg_temp=0
		SetScale /P x, 0, (1/freq), "ms",adc0_avg, adc1_avg,adc2_avg
		SetScale d 0,0, "mv",adc0_avg, adc1_avg,adc2_avg
	EndIf
	decode_scheme(scheme)
	if (init_display)
		init_G_traces()
		init_G_average(0) // remove and append the correct traces and do not bring to the front
	EndIf
	para_change() // close the write file and make a new one
	i = 0
	stop_request = 0
	t0 = ticks // register the begining
	Do
		j = 0
		Do
			if (number_of_pro == 1)
				break
			endif
			decode_pro(("pro_"+num2str(j)))
			if (j == 0 && i == 0)
				wait = 0 // when a protocol is run for the first time
			Endif
			if (j == 0 && i > 0)
				wait = wait_lf
			Endif
			if (j > 0)
				wait = scheme_wait[(j-1)]
			Endif 
			// To Control VDT port //ZY 11/07/2011
			//if ((j==1)|| (j==6))//to have two stimuli in one scheme
			//10/30/2013 -- I reversed this.  Originally, the lamp shutter opened on protocol 0 and closed on
			//protocol 2.  Now the shutter closes on protocol 0 and opens on protocol 2 so you can put as many
			//additional protocol after 2 into the scheme as you want.
			if (j==2)
			Beep
			VDTWrite2 "+\r"
			endif
			//if ((j==3) || (j==8)) // to have two stimuli in one scheme
			if (j==0)
			Beep
			VDTWrite2 "-/r"
			endif
			stop_request = Do_a_Protocol(j)
			if (stop_request) 
				break
			Endif
			j += 1
		while (j < number_of_pro)
		if (stop_request)
			break
		Endif
//		decode_pro(("pro_" + num2str(j)))
//		stop_request = Do_a_Protocol(j)
		if (stop_request)
			break
		Endif
		i += 1
	While ( (i < scheme_repeat) %| (scheme_repeat == -1) )
	decode_pro("pro_0")
	set_stim()
	scheme_on = 0
End
