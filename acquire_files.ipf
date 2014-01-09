#pragma rtGlobals=1		// Use modern global access method
function create_data_file()
	NVAR write_datapath, bin_header_length, total_header_size
	SVAR comment, comment2, header_string, write_file_name, last_modified, saved_version
	NVAR write_permit, write_file_open,acquired
	NVAR write_file_ref, header_string_size, header_wave_size
	WAVE header_wave
	if (write_file_open == 0) // i.e. when starting or when switching from read mode
		Open /R/Z/P=write_datapath write_file_ref, as write_file_name
		if (V_flag != 0) // write_file_name does not exist
			Open /P=write_datapath write_file_ref, as write_file_name
			write_file_open = 1
			acquired = 0
			printf "data_file: %s created\r", write_file_name
			Return(1)
		Endif
		if (V_flag == 0) // file exists
			beep; beep; beep
			DoAlert 1, "over write " + write_file_name +" ?" 
			if (V_flag == 1) // overwrite file
				Open /P=write_datapath write_file_ref, as write_file_name
				write_file_open = 1
				acquired = 0
				printf "data_file: %s created\r", write_file_name
				return (1)
			Else
				write_file_open = 0
				return(0)
			endif
		Endif
	Endif

	if ((write_file_open == 1) %& (acquired == 0)) // no data collected
		close_write_file("")
		Open /R/Z/P=write_datapath write_file_ref, as write_file_name
		if (V_flag != 0) // write_file_name does not exist
			Open /P=write_datapath write_file_ref, as write_file_name
			write_file_open = 1
			acquired = 0
			printf "data_file: %s created\r", write_file_name
			Return(1)
		Endif
		if (V_flag == 0) // file exists
			beep; beep; beep
			DoAlert 1, "over write " + write_file_name +" ?" 
			if (V_flag == 1) // overwrite file
				Open /P=write_datapath write_file_ref, as write_file_name
				write_file_open = 1
				acquired = 0
				printf "data_file: %s created\r", write_file_name
			Else
				write_file_open = 0
			endif
		Endif
		Return(1)
	endif
	if ((write_file_open == 1) %& (acquired > 0)) // save data before trying to open new file
		close_write_file("")
		Open /R/Z/P=write_datapath write_file_ref, as write_file_name
		if (V_flag != 0) // write_file_name does not exist
			Open /P=write_datapath write_file_ref, as write_file_name
			write_file_open = 1
			acquired = 0
			printf "data_file: %s created\r", write_file_name
			Return(1)
		Endif
		if (V_flag == 0) // file exists
			beep; beep; beep
			DoAlert 1, "over write " + write_file_name +" ?" 
			if (V_flag == 1) // overwrite file
				Open /P=write_datapath write_file_ref, as write_file_name
				write_file_open = 1
				acquired = 0
				printf "data_file: %s created\r", write_file_name
			Else
				write_file_open = 0
			endif
		Endif
	Endif
End

function Close_write_file(CntrlName) : ButtonControl
	String CntrlName
	NVAR write_datapath, bin_header_length, total_header_size
	SVAR comment, comment2,header_string, write_file_name, last_modified, saved_version
	NVAR write_permit, write_file_open, acquired
	NVAR write_file_ref, header_string_size, header_wave_size
	WAVE header_wave
	variable last_position, acquired_pos
	string tstr = ""
	if (write_file_open != 1)
		Return(0)
	Endif
	if (acquired > 0)
		printf "%d acquired in %s at: %s\r", acquired, write_file_name, Secs2Time(DateTime,1)
		acquired_pos = 4 + 4 + strlen("acquired:")
		tstr = num2str(acquired)
		tstr = padstring(tstr, 10, 0x20) // put spaces in the rest of this string
		FStatus write_file_ref
		if (V_flag == 0)
			beep; beep; beep
			printf "ERROR: file not open: %s (acquire_files)\r", write_file_name
			Return(0)
		Endif
		last_position = V_filePos
		FSetPos write_file_ref, acquired_pos
		FBinWrite write_file_ref, tstr
		FSetPos write_file_ref, last_position
	endif
	close write_file_ref
	write_file_open = 0
	Return(1)
End	

function write_sweep(datawave)
	wave datawave
	NVAR write_datapath, bin_header_length, total_header_size
	SVAR comment, comment2,header_string, write_file_name, last_modified, saved_version
	NVAR write_permit, write_file_open,acquired,samples
	NVAR write_file_ref, header_string_size, header_wave_size
	NVAR ttl_status, total_chan_num
	WAVE header_wave
	if (GetRTError(0))
		print "Error in function write_sweep 0"
		print GetRTErrMessage()
	endif
	if (write_permit == 0)
		beep; beep; beep
		DoAlert 0, "write_permit = 0"
		Return(0)
	Endif
	if (write_file_open != 1)
		beep; beep; beep
		DoAlert 0, "write_file not open"
		Return(0)
	Endif
	if (GetRTError(0))
		print "Error in function write_sweep 1"
		print GetRTErrMessage()
	endif
	printf "acquired: %d\r", acquired
	if (acquired == 0) // no header written so far
		write_header()
	Endif
	
	if (GetRTError(0))
		print "Error in function write_sweep 2"
		print GetRTErrMessage()
	endif

//	If (ttl_status == 1) // then remove the digital data and make new wave to be written
//		Make/O/N=(samples*(total_chan_num-1)) tdata
//		if (total_chan_num == 2)
//			tdata[0,samples-1] = datawave[p*2]
//		Endif
//		If(total_chan_num == 3)
//			tdata[0,2*samples-2;2] = datawave[(p/2)*3]
//			tdata[1,2*samples-1;2] = datawave[1+((p-1)/2)*3]
//		Endif
//		If(total_chan_num == 4)
//			tdata[0,3*samples-3;3] = datawave[(p/3)*4]
//			tdata[1,3*samples-2;3] = datawave[1+((p-1)/3)*4]
//			tdata[2,3*samples-1;3] = datawave[2+((p-2)/3)*4]
//		Endif
//		If(total_chan_num == 5)
//			tdata[0,4*samples-4;4] = datawave[(p/4)*5]
//			tdata[1,4*samples-3;4] = datawave[1+((p-1)/4)*5]
//			tdata[2,4*samples-2;4] = datawave[2+((p-2)/4)*5]
//			tdata[3,4*samples-1;4] = datawave[3+((p-3)/4)*5]
//		Endif
//		FBinWrite /F=2 write_file_ref, tdata
//	Endif
//	If (ttl_status == 0)
	FbinWrite /F=2 write_file_ref, datawave
//	Endif
	acquired += 1
End		
	


// will generate and return the header string
function  / S encode_header ()
	String header_string
	
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4,adc_gain5,adc_gain6,adc_gain7
	NVAR freq, mod_freq,total_chan_num, samples,scheme_on
	NVAR wait, acquired,hp0,hp1,hp2,hp3,datesecs
	NVAR cs_0, cs_1 // for switching protocols under continuous mode
	SVAR comment,comment2,seq_in,seq_out,start_time,protocol,scheme, last_modified, saved_version
	string tempstr = ""
	tempstr = num2str(acquired)
	tempstr = padstring(tempstr, 10, 0x20) // to make room for number of sweeps
	header_string = "acquired:" + tempstr    
	header_string += ";hp0:" + num2str(hp0)
	header_string += ";hp1:" + num2str(hp1)
	header_string += ";hp2:" + num2str(hp2)
	header_string += ";hp3:" + num2str(hp3)
//	NoteBook notes Selection={startofFile,EndOfFile}
//	getSelection NoteBook, notes, 2
//	comment = S_Selection
	header_string += ";comment:" + comment
	header_string += ";comment2:" + comment2
	header_string += ";saved_version:" + last_modified
	header_string += ";total_chan_num:" + num2str(total_chan_num)
	header_string += ";seq_in:" + seq_in
	header_string += ";seq_out:" + seq_out
	header_string += ";dac0_gain:" +num2str(dac0_gain)
	header_string += ";dac1_gain:" +num2str(dac1_gain)
	header_string += ";dac2_gain:" +num2str(dac2_gain)
	header_string += ";dac3_gain:" +num2str(dac3_gain)
	header_string += ";adc_gain0:" +num2str(adc_gain0)
	header_string += ";adc_gain1:" +num2str(adc_gain1)
	header_string += ";adc_gain2:" +num2str(adc_gain2)
	header_string += ";adc_gain3:" +num2str(adc_gain3)
	header_string += ";adc_gain4:" +num2str(adc_gain4)
	header_string += ";adc_gain5:" +num2str(adc_gain5)
	header_string += ";adc_gain6:" +num2str(adc_gain6)
	header_string += ";adc_gain7:" +num2str(adc_gain7)
	header_string += ";freq:" + num2str(freq)
	header_string += ";samples:" + num2str(samples)
	header_string += ";cs_0:" + num2str(cs_0)
	header_string += ";cs_1:" + num2str(cs_1)
	header_string += ";scheme_on:" + num2str(scheme_on)	
	header_string += ";start_time:" + secs2Time(Datetime, 1)
	sprintf tempstr, "%40f", Datetime
	header_string += ";datesecs:" + tempstr +";"
	protocol = encode_pro()
	header_string += ";protocol:" + protocol + ";"
	header_string += ";scheme:" + scheme + ";"

	Return(header_string)

End

function decode_header(header_string)
	string header_string
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4,adc_gain5,adc_gain6,adc_gain7
	NVAR freq, total_chan_num, samples,scheme_on
	NVAR wait, acquired,freq,hp0,hp1,hp2,hp3,datesecs
	SVAR comment,comment2,seq_in,seq_out,start_time,protocol,scheme, last_modified, saved_version
	NVAR dac0_psc3_amp
	NVAR old_files
	NVAR init_display // if 1 init display
	NVAR searchEnd_0, searchEnd_1, searchEnd_2, searchEnd_3 //added SPB 4-30-07 for adc3
	NVAR cs_0, cs_1
	acquired = NumberByKey("acquired",header_string)
	total_chan_num = NumberByKey("total_chan_num", header_string)
	if (old_files)
		total_chan_num -= 1 // D was not saved
	Endif
	comment = StringByKey("comment", header_string)
	comment2 = StringByKey("comment2", header_string)
	saved_version = StringByKey("saved_version", header_string)
	hp0 = NumberByKey("hp0", header_string)
	hp1 = NumberByKey("hp1", header_string)
	hp2 = NumberByKey("hp2", header_string)
	hp3 = NumberByKey("hp3", header_string)
	scheme = StringByKey("scheme", header_string)
	seq_in = StringByKey("seq_in", header_string)
	seq_out = StringByKey("seq_out", header_string)
	start_time = StringByKey("start_time", header_string)
	datesecs = NumberByKey("datesecs", header_string)
	if (numtype(datesecs) != 0)
		datesecs = 0
	Endif
	dac0_gain = NumberByKey("dac0_gain", header_string)
	dac1_gain = NumberByKey("dac1_gain", header_string)
	dac2_gain = NumberByKey("dac2_gain", header_string)
	dac3_gain = NumberByKey("dac3_gain", header_string)
	adc_gain0 = NumberByKey("adc_gain0", header_string)
	adc_gain1 = NumberByKey("adc_gain1", header_string)
	adc_gain2 = NumberByKey("adc_gain2", header_string)
	adc_gain3 = NumberByKey("adc_gain3", header_string)
	adc_gain4 = NumberByKey("adc_gain4", header_string)
	adc_gain5 = NumberByKey("adc_gain5", header_string)
	adc_gain6 = NumberByKey("adc_gain6", header_string)
	adc_gain7 = NumberByKey("adc_gain7", header_string)
	freq = NumberByKey("freq", header_string)
	samples = NumberByKey("samples", header_string)
	cs_0 = NumberByKey("cs_0", header_string)
	cs_1 = NumberByKey("cs_1", header_string)
	searchEnd_0 = samples
	searchEnd_1 = samples
	searchEnd_2 = samples
	searchEnd_3 = samples //added SPB 4-30-07
	scheme_on = NumberByKey("scheme_on", header_string)
//	if (scheme_on)
		scheme = StringByKey("scheme", header_string)
		decode_scheme(scheme)
//	Endif
	protocol = StringByKey("protocol", header_string)
	if (strlen(protocol) == 0)
		printf "(decode_header->)protocol = 0\r"
	Else
		decode_pro("protocol")
	Endif
// June-24-2004	
	if (init_display)
		init_g_traces()
		init_g_average(0)
	Endif
End



// will generate and return the header string
function  / S encode_pro()
	
	NVAR amp_type // 0 for Axopatch 200, 1 for MC700
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4,adc_gain5,adc_gain6,adc_gain7
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR freq, total_chan_num, samples,requested
	NVAR wait,freq,hp0,hp1,hp2,hp3,dac0_vc,dac1_vc,dac2_vc
	NVAR amp_change_0, amp_change_1,amp_change_2,amp_change_3 // changing pulse amplitude
	NVAR interval_change_0, interval_change_1, interval_change_2, interval_change_3 
	SVAR seq_in,seq_out
	WAVE dac0_start, dac0_end, dac0_amp
	WAVE dac1_start, dac1_end, dac1_amp
	WAVE dac2_start, dac2_end, dac2_amp
	WAVE dac3_start, dac3_end, dac3_amp

//	WAVE ttl1_start,ttl1_end
	NVAR dac0_pulse_num,dac1_pulse_num,dac2_pulse_num,dac3_pulse_num//,ttl1_pulse_num, ttl2_pulse_num
	NVAR dac0_vc,dac0_cc,dac1_vc,dac1_cc,dac2_cc,dac3_cc,dac3_vc
	NVAR ttl_status,his_flag
	NVAR sine_flag_dac0, sine_flag_dac1, sine_flag_dac2, sine_flag_dac3
	NVAR sine_phase_dac0, sine_phase_dac1, sine_phase_dac2, sine_phase_dac3
	NVAR sine_amp_dac0, sine_amp_dac1, sine_amp_dac2, sine_amp_dac3
	NVAR sine_freq_dac0, sine_freq_dac1, sine_freq_dac2, sine_freq_dac3
	NVAR continuous_flag
	NVAR cont_multi_flag // if 1 continuous with multiple protocols if 0 single protocol
	
// analysis variables
//	NVAR amp_analysis,amp_bl_start, amp_bl_end, amp_start, amp_end,amp_analysis_mode,average_flag
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------


	NVAR dac0_psc_flag,dac0_psc1_amp, dac0_psc2_amp,dac0_psc1_taurise, dac0_psc2_taurise
	NVAR dac0_psc3_amp,dac0_psc3_taurise,dac0_psc3_taudecay,dac0_psc_int2
	NVAR dac0_psc1_taudecay,dac0_psc2_taudecay, dac0_psc_interval, dac0_psc_start
	NVAR dac1_psc_flag,dac1_psc1_amp, dac1_psc2_amp,dac1_psc1_taurise, dac1_psc2_taurise
	NVAR dac1_psc1_taudecay,dac1_psc2_taudecay, dac1_psc_interval, dac1_psc_start
	NVAR dac0_stimfile_flag,dac0_stimfile_scale,stimfile_recycle, stimfile_loc
	NVAR dac1_stimfile_flag,dac1_stimfile_scale,stimfile_loc_start
	SVAR stimfile_name
	NVAR adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag // to indicate averaging
//Analysis
	NVAR analysis_max // for amp analysis 
	WAVE amp_analysis_flag_wave // wave of flags to set which analysis should be carried out
	NVAR disp_0, disp_1, disp_2, disp_3
	WAVE /T analysis_trace_name_wave // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE amp_analysis_mode_wave // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	NVAR draw_flag
	variable i, j


	string pro_string=""

	pro_string += "|total_chan_num>" + num2str(total_chan_num)
	pro_string += "|seq_in>" + seq_in
	pro_string += "|seq_out>" + seq_out
	pro_string += "|amp_type>" +num2str(amp_type)
	pro_string += "|dac0_gain>" +num2str(dac0_gain)
	pro_string += "|dac1_gain>" +num2str(dac1_gain)
	pro_string += "|dac2_gain>" +num2str(dac2_gain)
	pro_string += "|dac3_gain>" +num2str(dac3_gain)
	pro_string += "|adc_gain0>" +num2str(adc_gain0)
	pro_string += "|adc_gain1>" +num2str(adc_gain1)
	pro_string += "|adc_gain2>" +num2str(adc_gain2)
	pro_string += "|adc_gain3>" +num2str(adc_gain3)
	pro_string += "|adc_gain4>" +num2str(adc_gain4)
	pro_string += "|adc_gain5>" +num2str(adc_gain5)
	pro_string += "|adc_gain6>" +num2str(adc_gain6)
	pro_string += "|adc_gain7>" +num2str(adc_gain7)
	pro_string += "|adc_status0>" +num2str(adc_status0)
	pro_string += "|adc_status1>" +num2str(adc_status1)
	pro_string += "|adc_status2>" +num2str(adc_status2)
	pro_string += "|adc_status3>" +num2str(adc_status3)
	pro_string += "|adc_status4>" +num2str(adc_status4)
	pro_string += "|adc_status5>" +num2str(adc_status5)
	pro_string += "|adc_status6>" +num2str(adc_status6)
	pro_string += "|adc_status7>" +num2str(adc_status7)
	pro_string += "|adc0_avg_flag>" +num2str(adc0_avg_flag)
	pro_string += "|adc1_avg_flag>" +num2str(adc1_avg_flag)
	pro_string += "|adc2_avg_flag>" +num2str(adc2_avg_flag)
	pro_string += "|adc3_avg_flag>" +num2str(adc3_avg_flag)
	pro_string += "|disp_0>" +num2str(disp_0)
	pro_string += "|disp_1>" +num2str(disp_1)
	pro_string += "|disp_2>" +num2str(disp_2)
	pro_string += "|disp_3>" +num2str(disp_3)
	pro_string += "|freq>" + num2str(freq)
	pro_string += "|wait>" + num2str(wait)
	pro_string += "|amp_change_0>" + num2str(amp_change_0)
	pro_string += "|amp_change_1>" + num2str(amp_change_1)
	pro_string += "|amp_change_2>" + num2str(amp_change_2)
	pro_string += "|amp_change_3>" + num2str(amp_change_3)
	pro_string += "|ttl_status>" + num2str(ttl_status)
	pro_string += "|dac0_status>" + num2str(dac0_status)
	pro_string += "|dac1_status>" + num2str(dac1_status)
	pro_string += "|dac2_status>" + num2str(dac2_status)
	pro_string += "|dac3_status>" + num2str(dac3_status)	
	pro_string += "|samples>" + num2str(samples)
	pro_string += "|requested>" +num2str(requested)
//	pro_string += "|init_analysis>" +num2str(init_analysis)
	pro_string += "|his_flag>" +num2str(his_flag)	
	pro_string += "|dac0_pulse_num>" + num2str(dac0_pulse_num)
	pro_string += "|dac1_pulse_num>" + num2str(dac1_pulse_num)
	pro_string += "|dac2_pulse_num>" + num2str(dac2_pulse_num)
	pro_string += "|dac3_pulse_num>" + num2str(dac3_pulse_num)

	For (i = 0; i < 16; i += 1)
		WAVE ttl_start = $("ttl"+num2str(i)+"_start")
		WAVE ttl_end = $("ttl"+num2str(i)+"_end")
		NVAR ttl_pulse_num = $("ttl"+num2str(i)+"_pulse_num")
		pro_string += "|ttl"+num2str(i)+"_pulse_num>" + num2str(ttl_pulse_num) //num2str($("ttl"+num2str(i)+"_pulse_num"))
		For (j = 0; j < ttl_pulse_num; j += 1)
			pro_string += "|ttl"+num2str(i)+"_start"+num2str(j)+">" + num2str(ttl_start[j]) // 
			pro_string += "|ttl"+num2str(i)+"_end"+num2str(j)+">" + num2str(ttl_end[j])
		EndFor
	EndFor
//	pro_string += "|ttl1_pulse_num>" + num2str(ttl1_pulse_num)
	pro_string += "|dac0_vc>" + num2str(dac0_vc)
	pro_string += "|dac1_vc>" + num2str(dac1_vc)
	pro_string += "|dac2_vc>" + num2str(dac2_vc)
	pro_string += "|dac3_vc>" + num2str(dac3_vc)
	pro_string += "|hp0>" + num2str(hp0)
	pro_string += "|hp1>" + num2str(hp1)
	pro_string += "|hp2>" + num2str(hp2)
	pro_string += "|hp3>" + num2str(hp3)
	i = 0
	if((dac0_pulse_num > 0) %& (dac0_status == 1))
		Do
			pro_string += "|dac0_start"+num2str(i)+">" + num2str(dac0_start[i]) // dac0_start0 etc.
			pro_string += "|dac0_end"+num2str(i)+">" + num2str(dac0_end[i])
			pro_string += "|dac0_amp"+num2str(i)+">" + num2str(dac0_amp[i])
			i += 1
		While(i<dac0_pulse_num)
	Endif
	i = 0
	if((dac1_pulse_num > 0) %& (dac1_status == 1))
		Do
			pro_string += "|dac1_start"+num2str(i)+">" + num2str(dac1_start[i]) // dac1_start0 etc.
			pro_string += "|dac1_end"+num2str(i)+">" + num2str(dac1_end[i])
			pro_string += "|dac1_amp"+num2str(i)+">" + num2str(dac1_amp[i])
			i += 1
		While(i<dac1_pulse_num)
	Endif
	i = 0
	if((dac2_pulse_num > 0) %& (dac2_status == 1))
		Do
			pro_string += "|dac2_start"+num2str(i)+">" + num2str(dac2_start[i]) // dac1_start0 etc.
			pro_string += "|dac2_end"+num2str(i)+">" + num2str(dac2_end[i])
			pro_string += "|dac2_amp"+num2str(i)+">" + num2str(dac2_amp[i])
			i += 1
		While(i<dac2_pulse_num)
	Endif
	i = 0
	if((dac3_pulse_num > 0) %& (dac3_status == 1))
		Do
			pro_string += "|dac3_start"+num2str(i)+">" + num2str(dac3_start[i]) // dac3_start0 etc.
			pro_string += "|dac3_end"+num2str(i)+">" + num2str(dac3_end[i])
			pro_string += "|dac3_amp"+num2str(i)+">" + num2str(dac3_amp[i])
			i += 1
		While(i<dac3_pulse_num)
	Endif
	i = 0
//	if((ttl1_pulse_num > 0) %& (ttl_status == 1))
//		Do
//			pro_string += "|ttl1_start"+num2str(i)+">" + num2str(ttl1_start[i]) // 
//			pro_string += "|ttl1_end"+num2str(i)+">" + num2str(ttl1_end[i])
//			i += 1
//		While(i<ttl1_pulse_num)
//	Endif
	
	
	pro_string += "|dac0_psc_flag>" + num2str(dac0_psc_flag)
	pro_string += "|dac0_psc2_amp>" + num2str(dac0_psc2_amp)
	pro_string += "|dac0_psc1_amp>" + num2str(dac0_psc1_amp)
	pro_string += "|dac0_psc3_amp>" + num2str(dac0_psc3_amp)
	pro_string += "|dac0_psc1_taurise>" + num2str(dac0_psc1_taurise)
	pro_string += "|dac0_psc2_taurise>" + num2str(dac0_psc2_taurise)
	pro_string += "|dac0_psc3_taurise>" + num2str(dac0_psc3_taurise)
	pro_string += "|dac0_psc1_taudecay>" + num2str(dac0_psc1_taudecay)
	pro_string += "|dac0_psc2_taudecay>" + num2str(dac0_psc2_taudecay)
	pro_string += "|dac0_psc3_taudecay>" + num2str(dac0_psc3_taudecay)
	pro_string += "|dac0_psc_interval>" + num2str(dac0_psc_interval)
	pro_string += "|dac0_psc_int2>" + num2str(dac0_psc_int2)
	pro_string += "|dac0_psc_start>" + num2str(dac0_psc_start)
	pro_string += "|dac1_psc_flag>" + num2str(dac1_psc_flag)
	pro_string += "|dac1_psc2_amp>" + num2str(dac1_psc2_amp)
	pro_string += "|dac1_psc1_amp>" + num2str(dac1_psc1_amp)
	pro_string += "|dac1_psc1_taurise>" + num2str(dac1_psc1_taurise)
	pro_string += "|dac1_psc2_taurise>" + num2str(dac1_psc2_taurise)
	pro_string += "|dac1_psc1_taudecay>" + num2str(dac1_psc1_taudecay)
	pro_string += "|dac1_psc2_taudecay>" + num2str(dac1_psc2_taudecay)
	pro_string += "|dac1_psc_interval>" + num2str(dac1_psc_interval)
	pro_string += "|dac1_psc_start>" + num2str(dac1_psc_start)
	pro_string += "|dac0_stimfile_flag>" + num2str(dac0_stimfile_flag)
	pro_string += "|dac0_stimfile_scale>" + num2str(dac0_stimfile_scale)
	pro_string += "|dac1_stimfile_flag>" + num2str(dac1_stimfile_flag)
	pro_string += "|dac1_stimfile_scale>" + num2str(dac1_stimfile_scale)
	pro_string += "|stimfile_recycle>" + num2str(stimfile_recycle)
	pro_string += "|stimfile_loc>" + num2str(stimfile_loc)
	pro_string += "|sine_flag_dac0>" + num2str(sine_flag_dac0)
	pro_string += "|sine_flag_dac1>" + num2str(sine_flag_dac1)
	pro_string += "|sine_amp_dac0>" + num2str(sine_amp_dac0)
	pro_string += "|sine_amp_dac1>" + num2str(sine_amp_dac1)
	pro_string += "|stimfile_name>" + stimfile_name
	pro_string += "|sine_freq_dac0>" + num2str(sine_freq_dac0)
	pro_string += "|sine_freq_dac1>" + num2str(sine_freq_dac1)
	pro_string += "|sine_phase_dac0>" + num2str(sine_phase_dac0)
	pro_string += "|sine_phase_dac1>" + num2str(sine_phase_dac1)
	pro_string +="|continuous_flag>" + num2str(continuous_flag)
	pro_string +="|cont_multi_flag>" + num2str(cont_multi_flag)
	i = 0
	Do
		pro_string += "|analysis_trace_name"+num2str(i)+">"+analysis_trace_name_wave[i] // name of waves holding the analysis results
		pro_string += "|amp_bl_start"+num2str(i)+">"+ num2str(amp_bl_start_wave[i])//
		pro_string += "|amp_bl_end"+num2str(i)+">"+ num2str(amp_bl_end_wave[i])//
		pro_string += "|amp_start"+num2str(i)+">"+ num2str(amp_start_wave[i])//
		pro_string += "|amp_end"+num2str(i)+">"+ num2str(amp_end_wave[i])//
		pro_string += "|amp_analysis_mode"+num2str(i)+">"+ num2str(amp_analysis_mode_wave[i])//
		pro_string += "|amp_analysis_flag"+num2str(i)+">" + num2str(amp_analysis_flag_wave[i]) // 
		pro_string += "|amp_analysis_flag"+num2str(i)+">" + num2str(amp_analysis_flag_wave[i]) // 
		i += 1
	While (i < analysis_max)
	pro_string += "|draw_flag" + ">" + num2str(draw_flag)

	
	
	
	
//	pro_string +="|amp_analysis>" + num2str(amp_analysis)
//	pro_string +="|amp_analysis_mode>" + num2str(amp_analysis_mode)
//	pro_string +="|average_flag>" + num2str(average_flag)	
//	pro_string +="|amp_bl_start>" + num2str(amp_bl_start)
//	pro_string +="|amp_bl_end>" + num2str(amp_bl_end)
//	pro_string +="|amp_end>" + num2str(amp_end)				
//	pro_string +="|amp_start>" + num2str(amp_start)
//	i = 0
//	Do
//			pro_string += "|amp_analysis_flag"+num2str(i)+">" + num2str(amp_analysis_flag_wave[i]) // 
//			i += 1
//	While(i<analysis_max)
	
	Return(pro_string)

End


// will generate and return the scheme
function  / S encode_scheme()
	NVAR  wait_lf, scheme_repeat,number_of_pro,scheme_type
	NVAR cont_multi_flag
	WAVE scheme_wait // wave of wait time between protocol
	string scheme_string=""
	string tempstr = ""
	variable wait
	variable i
	i = 0
	Do
		tempstr = "!SchemeWait_" + num2str(i) + ")"
		scheme_string += "!SchemeWait_" + num2str(i) + ")" + num2str(scheme_wait[i])
		SVAR pro = $("pro_" + num2str(i))
		scheme_string += "!pro_" + num2str(i) + ")" + pro
		i += 1
	While (i < number_of_pro)
	scheme_string += "!wait_lf)" + num2str(wait_lf)
	scheme_string += "!scheme_repeat)" + num2str(scheme_repeat)
	scheme_string += "!number_of_pro)" + num2str(number_of_pro)
	scheme_string += "!scheme_type)" + num2str(scheme_type)
	scheme_string += "!cont_multi_flag)" + num2str(cont_multi_flag)
	Return(scheme_string)
End



function decode_scheme(scheme_string)
	string scheme_string

	NVAR wait_lf, scheme_repeat,number_of_pro,scheme_type, last_number_of_pro
	NVAR cont_multi_flag
	WAVE scheme_wait=scheme_wait
	variable i, j, temp
	string tempstr
	number_of_pro = NumberByKey("number_of_pro", scheme_string, ")", "!")
	last_number_of_pro = number_of_pro
	i = 0
	Do
		tempstr = "SchemeWait_" + num2str(i)
		scheme_wait[i] = NumberByKey(tempstr, scheme_string, ")", "!")
		SVAR pro = $("pro_" + num2str(i))
		pro = StringByKey("pro_" + num2str(i), scheme_string, ")", "!")
		i += 1
	While(i < number_of_pro)
	wait_lf = NumberByKey("wait_lf", scheme_string, ")", "!")
	scheme_repeat = NumberByKey("scheme_repeat", scheme_string, ")", "!")
	scheme_type = NumberByKey("scheme_type", scheme_string, ")", "!")
	cont_multi_flag = NumberByKey("cont_multi_flag", scheme_string, ")", "!")
End


//------------------------------------------------------
function encode_analysis()
	SVAR analysis_string
	NVAR analysis_max
	WAVE amp_analysis_flag_wave
	NVAR  analysis_num // the number of the analysis  
	NVAR Analysis_Max
	WAVE /T analysis_trace_name_wave // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE amp_analysis_mode_wave // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	variable i, temp
	analysis_string = ""
	i = 0
	Do
		analysis_string += "&analysis_trace_name"+num2str(i)+"~"+analysis_trace_name_wave[i] // name of waves holding the analysis results
		analysis_string += "&amp_bl_start"+num2str(i)+"~"+ num2str(amp_bl_start_wave[i])//
		analysis_string += "&amp_bl_end"+num2str(i)+"~"+ num2str(amp_bl_end_wave[i])//
		analysis_string += "&amp_start"+num2str(i)+"~"+ num2str(amp_start_wave[i])//
		analysis_string += "&amp_end"+num2str(i)+"~"+ num2str(amp_end_wave[i])//
		analysis_string += "&amp_analysis_mode"+num2str(i)+"~"+ num2str(amp_analysis_mode_wave[i])//
		analysis_string += "&amp_analysis_flag"+num2str(i)+"~" + num2str(amp_analysis_flag_wave[i]) // 
		i += 1
	While (i < analysis_max)

End

function decode_analysis()

	SVAR analysis_string
	NVAR analysis_max
	WAVE amp_analysis_flag_wave
	NVAR  analysis_num // the number of the analysis  
	NVAR Analysis_Max
	WAVE/T analysis_trace_name_wave // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE amp_analysis_mode_wave // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	
	variable i, temp
	i = 0
	Do
		analysis_trace_name_wave[i] = StringByKey(("analysis_trace_name"+num2str(i)), analysis_string, "~","&")
		amp_bl_start_wave[i] = NumberByKey(("amp_bl_start"+num2str(i)), analysis_string, "~", "&")
		amp_bl_end_wave[i] = NumberByKey(("amp_bl_end"+num2str(i)), analysis_string, "~", "&")
		amp_start_wave[i] = NumberByKey(("amp_start"+num2str(i)), analysis_string, "~", "&")
		amp_end_wave[i] = NumberByKey(("amp_end"+num2str(i)), analysis_string, "~", "&")
		amp_analysis_mode_wave[i] = NumberByKey(("amp_analysis_mode"+num2str(i)), analysis_string, "~", "&")
		
		i += 1
	While ( i < analysis_max)
	i = 0
	Do
		temp = NumberByKey(("amp_analysis_flag"+num2str(i)), analysis_string, "~", "&")
		if ((temp != 1) && (temp != 0))
			amp_analysis_flag_wave[i] = 0
		Else
			amp_analysis_flag_wave[i] = temp
		Endif
		i += 1
	While(i < analysis_max)
	CheckBox set_Amp_Analysis_flag,win=Amp_Panel,value= amp_analysis_flag_wave[analysis_num]
End

//-----------------------------------------------------

function decode_pro(pro_string_name)
	string pro_string_name


	SVAR pro_string = $pro_string_name
	NVAR amp_type
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4,adc_gain5,adc_gain6,adc_gain7
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag
	NVAR freq, total_chan_num, samples,requested,acquire_mode,old_samples,update
	NVAR wait,pro_wait, freq,mod_freq,hp0,hp1,hp2,hp3,dac0_vc,dac1_vc,dac2_vc,dac3_vc
	SVAR seq_in,seq_out
	WAVE dac0_start, dac0_end, dac0_amp
	WAVE dac1_start, dac1_end, dac1_amp
	WAVE dac2_start, dac2_end, dac2_amp
	WAVE dac3_start, dac3_end, dac3_amp
	WAVE ttl1_start,ttl1_end
	NVAR dac0_pulse_num,dac1_pulse_num,dac2_pulse_num,dac3_pulse_num,ttl1_pulse_num
	NVAR dac0_vc,dac0_cc,dac1_vc,dac1_cc,dac2_cc,dac3_cc
	NVAR ttl_status,init_analysis,his_flag
	NVAR amp_change_0, amp_change_1,amp_change_2,amp_change_3 // changing pulse amplitude
	NVAR interval_change_0, interval_change_1, interval_change_2, interval_change_3 
	NVAR sine_flag_dac0, sine_flag_dac1, sine_phase_dac0
	NVAR sine_phase_dac1, sine_amp_dac0, sine_amp_dac1
	NVAR sine_freq_dac0, sine_freq_dac1,continuous_flag
	NVAR cont_multi_flag // if 1 continuous with multiple protocols if 0 single protocol
// analysis variables

	NVAR analysis_max // for amp analysis 
	WAVE amp_analysis_flag_wave // wave of flags to set which analysis should be carried out
	NVAR disp_0, disp_1, disp_2, disp_3
	WAVE /T analysis_trace_name_wave // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE amp_analysis_mode_wave // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	NVAR draw_flag


//	NVAR amp_analysis,amp_bl_start, amp_bl_end, amp_start, amp_end,amp_analysis_mode,average_flag

	NVAR dac0_psc_flag,dac0_psc1_amp, dac0_psc2_amp,dac0_psc1_taurise, dac0_psc2_taurise
	NVAR dac0_psc3_amp,dac0_psc3_taurise,dac0_psc3_taudecay,dac0_psc_int2
	NVAR dac0_psc1_taudecay,dac0_psc2_taudecay, dac0_psc_interval, dac0_psc_start
	NVAR dac1_psc_flag,dac1_psc1_amp, dac1_psc2_amp,dac1_psc1_taurise, dac1_psc2_taurise
	NVAR dac1_psc1_taudecay,dac1_psc2_taudecay, dac1_psc_interval, dac1_psc_start
	NVAR dac0_stimfile_flag,dac0_stimfile_scale,stimfile_recycle, stimfile_loc
	NVAR dac1_stimfile_flag,dac1_stimfile_scale,stimfile_loc_start
	SVAR stimfile_name
	NVAR old_files
	NVAR analysis_num // the current analysis
//	WAVE amp_analysis_flag_wave
	NVAR check // if = 1 do checkbox
//	NVAR disp_0, disp_1, disp_2, disp_3
	NVAR init_disp
	
	variable i, j, temp
	PauseUpdate
	total_chan_num = NumberByKey("total_chan_num", pro_string, ">", "|")
	if (old_files)
		total_chan_num -= 1 // D was not saved
	Endif
//	if ((acquire_mode == 0) %& (ttl_status == 1))
//		total_chan_num -= 1
//	Endif
	seq_in = StringByKey("seq_in", pro_string, ">", "|")
	seq_out = StringByKey("seq_out", pro_string, ">", "|")
// set the channel average flags	
	adc0_avg_flag = NumberByKey("adc0_avg_flag", pro_string, ">", "|")

	adc1_avg_flag = NumberByKey("adc1_avg_flag", pro_string, ">", "|")

	adc2_avg_flag = NumberByKey("adc2_avg_flag", pro_string, ">", "|")

	adc3_avg_flag = NumberByKey("adc3_avg_flag", pro_string, ">", "|")

	if (check)
		CheckBox /Z AVG0,win=Panel_AQ_C,value=adc0_avg_flag	
		CheckBox /Z AVG1,win=Panel_AQ_C,value=adc1_avg_flag
		CheckBox /Z AVG2,win=Panel_AQ_C,value=adc2_avg_flag
		CheckBox /Z AVG3,win=Panel_AQ_C,value=adc3_avg_flag
	Endif
// get the status of output channels
	ttl_status = NumberByKey("ttl_status", pro_string, ">", "|")
	amp_type = NumberByKey("amp_type", pro_string, ">", "|")
	dac0_status = NumberByKey("dac0_status", pro_string, ">", "|")
	dac1_status = NumberByKey("dac1_status", pro_string, ">", "|")
	dac2_status = NumberByKey("dac2_status", pro_string, ">", "|")
	dac3_status = NumberByKey("dac3_status", pro_string, ">", "|")
	adc_status0 = NumberByKey("adc_status0", pro_string, ">", "|")
	adc_status1 = NumberByKey("adc_status1", pro_string, ">", "|")
	adc_status2 = NumberByKey("adc_status2", pro_string, ">", "|")
	adc_status3 = NumberByKey("adc_status3", pro_string, ">", "|")
	variable temp_var
	if (init_disp)
		temp_var = NumberByKey("disp_0", pro_string, ">", "|")
		if (numtype(temp_var) == 0)
			disp_0 = temp_var
		EndIf
		temp_var = NumberByKey("disp_1", pro_string, ">", "|")
		if (numtype(temp_var) == 0)
			disp_1 = temp_var
		EndIf
		temp_var = NumberByKey("disp_2", pro_string, ">", "|")
		if (numtype(temp_var) == 0)
			disp_2 = temp_var
		EndIf
		temp_var = NumberByKey("disp_3", pro_string, ">", "|")
		if (numtype(temp_var) == 0)
			disp_3 = temp_var
		EndIf
	EndIf
	If (dac0_status)
		hp0 = NumberByKey("hp0", pro_string, ">", "|")
		dac0_gain = NumberByKey("dac0_gain", pro_string, ">", "|")
		adc_gain0 = NumberByKey("adc_gain0", pro_string, ">", "|")
		dac0_vc = NumberByKey("dac0_vc", pro_string, ">", "|")
		if (dac0_vc == 1)
			dac0_cc = 0
		Else
			dac0_cc = 1
		Endif
		if (check)
			CheckBox /Z check_vc0, win=panel_aq_d, value=dac0_vc
			CheckBox /Z check_cc0, win=panel_aq_d, value=dac0_cc
		Endif
		temp = NumberByKey("amp_change_0", pro_string, ">", "|")
		if (numtype(temp) == 0)
			amp_change_0 = temp
		else
			amp_change_0 = 0
		Endif
	EndIf
	If (dac1_status)
		hp1 = NumberByKey("hp1", pro_string, ">", "|")
		dac1_gain = NumberByKey("dac1_gain", pro_string, ">", "|")
		adc_gain1 = NumberByKey("adc_gain1", pro_string, ">", "|")
		dac1_vc = NumberByKey("dac1_vc", pro_string, ">", "|")
		if (dac1_vc == 1)
			dac1_cc = 0
		Else
			dac1_cc = 1
		Endif
		if (check)
			CheckBox /Z check_vc1, win=panel_aq_d, value=dac1_vc
			CheckBox /Z check_cc1, win=panel_aq_d, value=dac1_cc
		Endif
		temp = NumberByKey("amp_change_1", pro_string, ">", "|")
		if (numtype(temp) == 0)
			amp_change_1 = temp
		else
			amp_change_1 = 0
		Endif

	EndIf
	If (dac2_status)
		hp2 = NumberByKey("hp2", pro_string, ">", "|")
		dac2_gain = NumberByKey("dac2_gain", pro_string, ">", "|")
		adc_gain2 = NumberByKey("adc_gain2", pro_string, ">", "|")
		dac2_vc = NumberByKey("dac2_vc", pro_string, ">", "|")
		if (dac2_vc == 1)
			dac2_cc = 0
		Else
			dac2_cc = 1
		Endif
		if (check)
			CheckBox /Z check_vc2, win=panel_aq_d, value=dac2_vc
			CheckBox /Z check_cc2, win=panel_aq_d, value=dac2_cc
		Endif
		temp = NumberByKey("amp_change_2", pro_string, ">", "|")
		if (numtype(temp) == 0)
			amp_change_2 = temp
		else
			amp_change_2 = 0
		Endif
	EndIf
	If (dac3_status)
		hp3 = NumberByKey("hp3", pro_string, ">", "|")
		dac3_gain = NumberByKey("dac3_gain", pro_string, ">", "|")
		adc_gain3 = NumberByKey("adc_gain3", pro_string, ">", "|")
		dac3_vc = NumberByKey("dac3_vc", pro_string, ">", "|")
		if (dac3_vc == 1)
			dac3_cc = 0
		Else
			dac3_cc = 1
		Endif
		if (check)
			CheckBox /Z check_vc3, win=panel_aq_d, value=dac3_vc
			CheckBox /Z check_cc3, win=panel_aq_d, value=dac3_cc		
		Endif
		temp = NumberByKey("amp_change_3", pro_string, ">", "|")
		if (numtype(temp) == 0)
			amp_change_3 = temp
		else
			amp_change_3 = 0
		Endif
	EndIf
	if (check)
	if (dac0_status && adc_status0)
		checkbox ch0, win=panel_aq_d, value = 1
	Else
		checkbox ch0, win=panel_aq_d, value = 0
	Endif
	if (dac1_status && adc_status1)
		checkbox /Z ch1, win=panel_aq_d, value = 1
	Else
		checkbox /Z ch1, win=panel_aq_d, value = 0
	Endif
	if (dac2_status && adc_status2)
		checkbox /Z ch2, win=panel_aq_d, value = 1
	Else
		checkbox /Z ch2, win=panel_aq_d, value = 0
	Endif
	if (dac3_status && adc_status3)
		checkbox /Z ch3, win=panel_aq_d, value = 1
	Else
		checkbox /Z ch3, win=panel_aq_d, value = 0
	Endif
	Endif

//	adc_gain4 = NumberByKey("adc_gain4", pro_string, ">", "|")
//	adc_gain5 = NumberByKey("adc_gain5", pro_string, ">", "|")
//	adc_gain6 = NumberByKey("adc_gain6", pro_string, ">", "|")
//	adc_gain7 = NumberByKey("adc_gain7", pro_string, ">", "|")
//	adc_status0 = NumberByKey("adc_status0", pro_string, ">", "|")
//	adc_status1 = NumberByKey("adc_status1", pro_string, ">", "|")
//	adc_status2 = NumberByKey("adc_status2", pro_string, ">", "|")
//	adc_status3 = NumberByKey("adc_status3", pro_string, ">", "|")
//	adc_status4 = NumberByKey("adc_status4", pro_string, ">", "|")
//	adc_status5 = NumberByKey("adc_status5", pro_string, ">", "|")
//	adc_status6 = NumberByKey("adc_status6", pro_string, ">", "|")
//	adc_status7 = NumberByKey("adc_status7", pro_string, ">", "|")
					
	freq = NumberByKey("freq", pro_string, ">", "|")
	temp = NumberByKey("wait", pro_string, ">", "|")
	if (numtype(temp) == 0)
		pro_wait = temp
		wait = temp
	endif
	
	samples = NumberByKey("samples", pro_string, ">", "|")
//	if (acquire_mode == 1)
//		init_analysis = NumberByKey("init_analysis", pro_string, ">", "|")
//	Endif
//	if (numtype(init_analysis) != 0)
//		init_analysis = 1
//	Endif
//	checkbox check4, win=Panel_AQ_C, value=init_analysis
	his_flag = NumberByKey("his_flag", pro_string, ">", "|")
//	if (check)
//		checkbox check1, win=Panel_AQ_C,value=his_flag
//	Endif
	requested = NumberByKey("requested", pro_string, ">", "|")
	if (dac0_status)
		dac0_pulse_num = NumberByKey("dac0_pulse_num", pro_string, ">", "|")
		dac0_start = 0
		dac0_end = 0
		dac0_amp = 0
		i = 0
		if (dac0_pulse_num > 0)
			Do
				dac0_start[i] = NumberByKey(("dac0_start"+num2str(i)), pro_string, ">", "|")
				dac0_end[i] = NumberByKey(("dac0_end"+num2str(i)), pro_string, ">", "|")
				dac0_amp[i] = NumberByKey(("dac0_amp"+num2str(i)), pro_string, ">", "|")
				i += 1
			While(i < dac0_pulse_num)
		Endif
	Endif
	if (dac1_status)
		dac1_pulse_num = NumberByKey("dac1_pulse_num", pro_string, ">", "|")
		dac1_start = 0
		dac1_end = 0
		dac1_amp = 0
		i = 0
		if (dac1_pulse_num > 0)
			Do
				dac1_start[i] = NumberByKey(("dac1_start"+num2str(i)), pro_string, ">", "|")
				dac1_end[i] = NumberByKey(("dac1_end"+num2str(i)), pro_string, ">", "|")
				dac1_amp[i] = NumberByKey(("dac1_amp"+num2str(i)), pro_string, ">", "|")
				i += 1
			While(i < dac1_pulse_num)
		Endif
	Endif
	if (dac2_status)
		dac2_pulse_num = NumberByKey("dac2_pulse_num", pro_string, ">", "|")
		i = 0
		dac2_start = 0
		dac2_end = 0
		dac2_amp = 0
		if (dac2_pulse_num > 0)
			Do
				dac2_start[i] = NumberByKey(("dac2_start"+num2str(i)), pro_string, ">", "|")
				dac2_end[i] = NumberByKey(("dac2_end"+num2str(i)), pro_string, ">", "|")
				dac2_amp[i] = NumberByKey(("dac2_amp"+num2str(i)), pro_string, ">", "|")
				i += 1
			While(i < dac2_pulse_num)
		Endif
	Endif
	if (dac3_status)
		dac3_pulse_num = NumberByKey("dac3_pulse_num", pro_string, ">", "|")
		dac3_start = 0
		dac3_end = 0
		dac3_amp = 0
		i = 0
		if (dac3_pulse_num > 0)
			Do
				dac3_start[i] = NumberByKey(("dac3_start"+num2str(i)), pro_string, ">", "|")
				dac3_end[i] = NumberByKey(("dac3_end"+num2str(i)), pro_string, ">", "|")
				dac3_amp[i] = NumberByKey(("dac3_amp"+num2str(i)), pro_string, ">", "|")
				i += 1
			While(i < dac3_pulse_num)
		Endif
	Endif
	
	For (i = 0; i < 16; i += 1)
		WAVE ttl_start = $("ttl"+num2str(i)+"_start")
		WAVE ttl_end = $("ttl"+num2str(i)+"_end")
		NVAR ttl_pulse_num = $("ttl"+num2str(i)+"_pulse_num")
		ttl_pulse_num = NumberByKey("ttl"+num2str(i)+"_pulse_num", pro_string, ">", "|")
		For (j = 0; j < ttl_pulse_num; j += 1)
			ttl_start[j] = NumberByKey(("ttl"+num2str(i)+"_start"+num2str(j)), pro_string, ">", "|")
			ttl_end[j] = NumberByKey(("ttl"+num2str(i)+"_end"+num2str(j)), pro_string, ">", "|")
		EndFor
	EndFor

	
	
	
	
	
//	ttl1_pulse_num = NumberByKey("ttl1_pulse_num", pro_string, ">", "|")
//	ttl1_start = 0
//	ttl1_end = 0
	i = 0
//	if (ttl1_pulse_num > 0)
//		Do
//			ttl1_start[i] = NumberByKey(("ttl1_start"+num2str(i)), pro_string, ">", "|")
//			ttl1_end[i] = NumberByKey(("ttl1_end"+num2str(i)), pro_string, ">", "|")
//			i += 1
//		While(i < ttl1_pulse_num)
//	Endif

	dac0_psc_flag = NumberByKey("dac0_psc_flag", pro_string, ">", "|")
	if (dac0_psc_flag)
		dac0_psc1_amp = NumberByKey("dac0_psc1_amp", pro_string, ">", "|")
		dac0_psc2_amp = NumberByKey("dac0_psc2_amp", pro_string, ">", "|")
		dac0_psc3_amp = NumberByKey("dac0_psc3_amp", pro_string, ">", "|")
		dac0_psc1_taurise = NumberByKey("dac0_psc1_taurise", pro_string, ">", "|")
		dac0_psc2_taurise = NumberByKey("dac0_psc2_taurise", pro_string, ">", "|")
		dac0_psc3_taurise = NumberByKey("dac0_psc3_taurise", pro_string, ">", "|")
		dac0_psc1_taudecay = NumberByKey("dac0_psc1_taudecay", pro_string, ">", "|")
		dac0_psc2_taudecay = NumberByKey("dac0_psc2_taudecay", pro_string, ">", "|")
		dac0_psc3_taudecay = NumberByKey("dac0_psc3_taudecay", pro_string, ">", "|")
		dac0_psc_interval = NumberByKey("dac0_psc_interval", pro_string, ">", "|")
		dac0_psc_int2 = NumberByKey("dac0_psc_int2", pro_string, ">", "|")
		dac0_psc_start = NumberByKey("dac0_psc_start", pro_string, ">", "|")
	Endif
	dac1_psc_flag = NumberByKey("dac1_psc_flag", pro_string, ">", "|")
	if (dac1_psc_flag)
		dac1_psc1_amp = NumberByKey("dac1_psc1_amp", pro_string, ">", "|")
		dac1_psc2_amp = NumberByKey("dac1_psc2_amp", pro_string, ">", "|")
		dac1_psc1_taurise = NumberByKey("dac1_psc1_taurise", pro_string, ">", "|")
		dac1_psc2_taurise = NumberByKey("dac1_psc2_taurise", pro_string, ">", "|")
		dac1_psc1_taudecay = NumberByKey("dac1_psc1_taudecay", pro_string, ">", "|")
		dac1_psc2_taudecay = NumberByKey("dac1_psc2_taudecay", pro_string, ">", "|")
		dac1_psc_interval = NumberByKey("dac1_psc_interval", pro_string, ">", "|")
		dac1_psc_start = NumberByKey("dac1_psc_start", pro_string, ">", "|")
	Endif
	dac0_stimfile_flag = NumberByKey("dac0_stimfile_flag", pro_string, ">", "|")
	if (check)
		checkbox check100, win=DAC0_Panel, value=dac0_stimfile_flag
	Endif
	dac1_stimfile_flag = NumberByKey("dac1_stimfile_flag", pro_string, ">", "|")
	
//	if (acquire_mode == 0)
//		stimfile_flag = 0
//	endif
	dac0_stimfile_scale = NumberByKey("dac0_stimfile_scale", pro_string, ">", "|")
	dac1_stimfile_scale = NumberByKey("dac1_stimfile_scale", pro_string, ">", "|")
	stimfile_recycle = NumberByKey("stimfile_recycle", pro_string, ">", "|")
	if (check)
		checkbox check1, win=DAC0_Panel, value = stimfile_recycle
	Endif
	if (acquire_mode == 0)
		stimfile_loc = NumberByKey("stimfile_loc", pro_string, ">", "|")
	endif
	sine_flag_dac0 = NumberByKey("sine_flag_dac0", pro_string, ">", "|")
	sine_amp_dac0 = NumberByKey("sine_amp_dac0", pro_string, ">", "|")
	sine_phase_dac0 = NumberByKey("sine_phase_dac0", pro_string, ">", "|")
	sine_freq_dac0 = NumberByKey("sine_freq_dac0", pro_string, ">", "|")
	sine_flag_dac1 = NumberByKey("sine_flag_dac1", pro_string, ">", "|")
	sine_amp_dac1 = NumberByKey("sine_amp_dac1", pro_string, ">", "|")
	sine_phase_dac1 = NumberByKey("sine_phase_dac1", pro_string, ">", "|")
	sine_freq_dac1 = NumberByKey("sine_freq_dac1", pro_string, ">", "|")
	continuous_flag = NumberByKey("continuous_flag", pro_string, ">", "|")
	cont_multi_flag = NumberByKey("cont_multi_flag", pro_string, ">", "|")
	if (numtype(cont_multi_flag) != 0) // not a normal number
		cont_multi_flag = 0
	Endif

//	average_flag = NumberByKey("average_flag", pro_string, ">", "|")
//	if (numtype(average_flag) != 0)
//		average_flag = 1
//	Endif
//	checkbox check3, win=Panel_AQ_C, value=average_flag
//	if (acquire_mode) // offline ignore analysis settings

	i = 0
	Do
		temp = NumberByKey(("amp_analysis_flag"+num2str(i)), pro_string, ">", "|")
		if ((temp != 1) && (temp != 0))
			amp_analysis_flag_wave[i] = 0
		Else
			amp_analysis_flag_wave[i] = temp
		Endif
		analysis_trace_name_wave[i] = StringByKey(("analysis_trace_name"+num2str(i)), pro_string, ">","|")
		if (strlen(analysis_trace_name_wave[i]) == 0)
			analysis_trace_name_wave[i] = "adc0"
		Endif
		amp_bl_start_wave[i] = NumberByKey(("amp_bl_start"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_bl_start_wave[i]) == 2)
			amp_bl_start_wave[i] = 0
		Endif
		amp_bl_end_wave[i] = NumberByKey(("amp_bl_end"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_bl_end_wave[i]) == 2)
			amp_bl_end_wave[i] = 0
		Endif
		amp_start_wave[i] = NumberByKey(("amp_start"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_start_wave[i]) == 2)
			amp_start_wave[i] = 0
		Endif
		amp_end_wave[i] = NumberByKey(("amp_end"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_end_wave[i]) == 2)
			amp_end_wave[i] = 0
		Endif
		amp_analysis_mode_wave[i] = NumberByKey(("amp_analysis_mode"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_analysis_mode_wave[i]) == 2)
			amp_analysis_mode_wave[i] = 0
		Endif
		i += 1
	While ( i < analysis_max)
	draw_flag = NumberByKey("draw_flag", pro_string, ">", "|")
	if (draw_flag != 0 && draw_flag != 0)
		draw_flag = 0
	Endif
	CheckBox /Z set_Amp_Analysis_flag,win=Amp_Panel,value= amp_analysis_flag_wave[analysis_num]

//		amp_analysis = NumberByKey("amp_analysis", pro_string, ">", "|")
//		amp_analysis_mode = NumberByKey("amp_analysis_mode", pro_string, ">", "|")
//		amp_bl_start = NumberByKey("amp_bl_start", pro_string, ">", "|")
//		amp_bl_end = NumberByKey("amp_bl_end", pro_string, ">", "|")
//		amp_start = NumberByKey("amp_start", pro_string, ">", "|")
//		amp_end = NumberByKey("amp_end", pro_string, ">", "|")					
	//	if (numtype(amp_end) != 0) // if its an old protocol
	//		amp_analysis = 0
	//	endif
//	Endif

	
	stimfile_name = StringByKey("stimfile_name", pro_string, ">", "|")
	
///////////////////////////////////////////////////////////////////////////////////////	for old time sake

	if(1 == NumberByKey("psc_flag", pro_string, ">", "|"))
		dac0_psc1_amp = NumberByKey("psc1_amp", pro_string, ">", "|")
		dac0_psc2_amp = NumberByKey("psc2_amp", pro_string, ">", "|")
		dac0_psc3_amp = NumberByKey("psc3_amp", pro_string, ">", "|")
		dac0_psc1_taurise = NumberByKey("psc1_taurise", pro_string, ">", "|")
		dac0_psc2_taurise = NumberByKey("psc2_taurise", pro_string, ">", "|")
		dac0_psc3_taurise = NumberByKey("psc3_taurise", pro_string, ">", "|")
		dac0_psc1_taudecay = NumberByKey("psc1_taudecay", pro_string, ">", "|")
		dac0_psc2_taudecay = NumberByKey("psc2_taudecay", pro_string, ">", "|")
		dac0_psc3_taudecay = NumberByKey("psc3_taudecay", pro_string, ">", "|")
		dac0_psc_interval = NumberByKey("psc_interval", pro_string, ">", "|")
		dac0_psc_int2 = NumberByKey("psc_int2", pro_string, ">", "|")
		dac0_psc_start = NumberByKey("psc_start", pro_string, ">", "|")
	Endif
	
	
	
	checkbox /Z check10, win=DAC0_Panel,value = dac0_psc_flag
	if (1 == NumberByKey("stimfile_flag", pro_string, ">", "|") )
		dac0_stimfile_flag = 1
		dac0_stimfile_scale = NumberByKey("stimfile_scale", pro_string, ">", "|")
	Endif
	
///////////////////////////////////////////////////////////
	if (check)
	Checkbox /Z check3, win=DAC0_Panel, value=sine_flag_dac0
	Checkbox /Z check0, win=DAC1_panel, value=sine_flag_dac1
	CheckBox /Z check200,win=DAC1_panel,value=dac1_psc_flag
	CheckBox /Z check10,win=DAC0_panel,value=dac0_psc_flag
	Checkbox /Z check2, win=Panel_AQ_C, value=continuous_flag 
	Endif
//	Checkbox set_Amp_Analysis, win=Amp_Panel, value=amp_analysis 
	if (samples != old_samples)
//		printf "samples: %d, old_smaples: %d\r", samples, old_samples
//		PauseUpdate
		Make /O/N=(samples) adc0=0, adc1=0, adc2=0, adc3 =0
	// make 40 waves to be used for averaging 10 protocols 
		Do
			Make /O/N=(samples) $("adc0_avg_"+num2str(i)), $("root:avg:adc0_avg_temp_"+num2str(i))
			SetScale /P x 0, (1.0/freq), "ms", $("adc0_avg_"+num2str(i))
			SetScale d, -200, 200, "pA", $("adc0_avg_"+num2str(i))
			Make /O/N=(samples) $("adc1_avg_"+num2str(i)), $("root:avg:adc1_avg_temp_"+num2str(i))
			SetScale /P x 0, (1.0/freq), "ms", $("adc1_avg_"+num2str(i))
			SetScale d, -200, 200, "pA", $("adc1_avg_"+num2str(i))
			Make /O/N=(samples) $("adc2_avg_"+num2str(i)), $("root:avg:adc2_avg_temp_"+num2str(i))
			SetScale /P x 0, (1.0/freq), "ms", $("adc2_avg_"+num2str(i))
			SetScale d, -200, 200, "pA", $("adc2_avg_"+num2str(i))
			Make /O/N=(samples) $("adc3_avg_"+num2str(i)), $("root:avg:adc3_avg_temp_"+num2str(i))
			SetScale /P x 0, (1.0/freq), "ms", $("adc3_avg_"+num2str(i))
			SetScale d, -200, 200, "pA", $("adc3_avg_"+num2str(i))
			i += 1
		While (i < 20) 
		//adc0_avg=0,adc1_avg_temp=0,adc1_avg=0,adc1_avg_temp=0
		Make /O/N=(samples*total_chan_num) InData
		old_samples = samples
//		ResumeUpdate
	Endif
	old_samples = samples
	set_sweep_time()
//	wavestats /Q/R=[0,(dac0_pulse_num-1)] dac0_start
//	if (V_numNANs != 0)
//		Make /O/N=1000 dac0_start=0, dac0_end=0,dac0_amp=0
//	endif
//	wavestats /Q/R=[0,(dac1_pulse_num-1)] dac1_start
//	if (V_numNANs != 0)
//		Make /O/N=1000 dac1_start=0, dac1_end=0,dac1_amp=0
//	endif
//	wavestats /Q/R=[0,(dac2_pulse_num-1)] dac2_start
//	if (V_numNANs != 0)
//		Make /O/N=1000 dac2_start=0, dac2_end=0,dac2_amp=0
//	endif
//	wavestats /Q/R=[0,(dac3_pulse_num-1)] dac3_start
//	if (V_numNANs != 0)
//		Make /O/N=1000 dac3_start=0, dac3_end=0,dac3_amp=0
//	endif

//	set_stim()

//	SetScale /P x 0, (1.0/freq), "ms", adc0, adc1, adc2, adc3
	//adc0_avg, adc1_avg,adc2_avg
	
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
	if (numtype(dac0_psc3_amp) != 0) // not a number
		dac0_psc3_amp = 0
		dac0_psc3_taurise = 1
		dac0_psc3_taudecay = 1
	Endif
//	i = 0
//	Do
//		temp = NumberByKey(("amp_analysis_flag"+num2str(i)), pro_string, ">", "|")
////		printf "temp: %d\r", temp
//		if ((temp != 1) && (temp != 0))
//			amp_analysis_flag_wave[i] = 0
//		Else
//			amp_analysis_flag_wave[i] = temp
//		Endif
//		i += 1
//	While(i < analysis_max)
//	if (check)
//		CheckBox /Z set_Amp_Analysis_flag,win=Amp_Panel,value= amp_analysis_flag_wave[analysis_num]
//	Endif
	ResumeUpdate
	if (update)
		doupDate
	Endif
End

//-----------------------------------------------------
// for continuous acquisition only
function decode_c_pro(pro_string_name)
	string pro_string_name

	SVAR pro_string = $pro_string_name
	NVAR amp_type
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4,adc_gain5,adc_gain6,adc_gain7
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag
	NVAR freq, total_chan_num, samples,requested,acquire_mode,old_samples,update
	NVAR wait,pro_wait, freq,mod_freq,hp0,hp1,hp2,hp3,dac0_vc,dac1_vc,dac2_vc,dac3_vc
	SVAR seq_in,seq_out
	WAVE dac0_start, dac0_end, dac0_amp
	WAVE dac1_start, dac1_end, dac1_amp
	WAVE dac2_start, dac2_end, dac2_amp
	WAVE dac3_start, dac3_end, dac3_amp
	WAVE ttl1_start,ttl1_end
	NVAR dac0_pulse_num,dac1_pulse_num,dac2_pulse_num,dac3_pulse_num,ttl1_pulse_num
	NVAR dac0_vc,dac0_cc,dac1_vc,dac1_cc,dac2_cc,dac3_cc
	NVAR ttl_status,init_analysis,his_flag

	NVAR sine_flag_dac0, sine_flag_dac1, sine_phase_dac0
	NVAR sine_phase_dac1, sine_amp_dac0, sine_amp_dac1
	NVAR sine_freq_dac0, sine_freq_dac1,continuous_flag
	NVAR amp_change_0, amp_change_1,amp_change_2,amp_change_3 // changing pulse amplitude
	
// analysis variables
	NVAR amp_analysis,amp_bl_start, amp_bl_end, amp_start, amp_end,amp_analysis_mode,average_flag

	NVAR dac0_psc_flag,dac0_psc1_amp, dac0_psc2_amp,dac0_psc1_taurise, dac0_psc2_taurise
	NVAR dac0_psc3_amp,dac0_psc3_taurise,dac0_psc3_taudecay,dac0_psc_int2
	NVAR dac0_psc1_taudecay,dac0_psc2_taudecay, dac0_psc_interval, dac0_psc_start
	NVAR dac1_psc_flag,dac1_psc1_amp, dac1_psc2_amp,dac1_psc1_taurise, dac1_psc2_taurise
	NVAR dac1_psc1_taudecay,dac1_psc2_taudecay, dac1_psc_interval, dac1_psc_start
	NVAR dac0_stimfile_flag,dac0_stimfile_scale,stimfile_recycle, stimfile_loc
	NVAR dac1_stimfile_flag,dac1_stimfile_scale,stimfile_loc_start
	SVAR stimfile_name
	NVAR old_files
	NVAR analysis_max
	NVAR analysis_num // the current analysis
	
	WAVE amp_analysis_flag_wave // wave of flags to set which analysis should be carried out
	NVAR disp_0, disp_1, disp_2, disp_3
	WAVE /T analysis_trace_name_wave // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE amp_analysis_mode_wave // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	
	
	
	NVAR draw_flag
	NVAR check // if = 1 do checkbox
	NVAR disp_0, disp_1, disp_2, disp_3
	NVAR init_disp
	
	variable i, temp
	PauseUpdate
// get the status of output channels
	ttl_status = NumberByKey("ttl_status", pro_string, ">", "|")
	amp_type = NumberByKey("amp_type", pro_string, ">", "|")
	dac0_status = NumberByKey("dac0_status", pro_string, ">", "|")
	dac1_status = NumberByKey("dac1_status", pro_string, ">", "|")
	dac2_status = NumberByKey("dac2_status", pro_string, ">", "|")
	dac3_status = NumberByKey("dac3_status", pro_string, ">", "|")
	adc_status0 = NumberByKey("adc_status0", pro_string, ">", "|")
	adc_status1 = NumberByKey("adc_status1", pro_string, ">", "|")
	adc_status2 = NumberByKey("adc_status2", pro_string, ">", "|")
	adc_status3 = NumberByKey("adc_status3", pro_string, ">", "|")
	
	adc0_avg_flag = NumberByKey("adc0_avg_flag", pro_string, ">", "|")
	adc1_avg_flag = NumberByKey("adc1_avg_flag", pro_string, ">", "|")
	adc2_avg_flag = NumberByKey("adc2_avg_flag", pro_string, ">", "|")
	adc3_avg_flag = NumberByKey("adc3_avg_flag", pro_string, ">", "|")

	
	variable temp_var
	temp = NumberByKey("wait", pro_string, ">", "|")
	if (numtype(temp) == 0)
		pro_wait = temp
		wait = temp
	endif
	
	requested = NumberByKey("requested", pro_string, ">", "|")
	
	if (dac0_status)
		dac0_pulse_num = NumberByKey("dac0_pulse_num", pro_string, ">", "|")
		dac0_start = 0
		dac0_end = 0
		dac0_amp = 0
		temp = NumberByKey("amp_change_0", pro_string, ">", "|")
		if (numtype(temp) == 0)
			amp_change_0 = temp
		else
			amp_change_0 = 0
		Endif
		i = 0
		if (dac0_pulse_num > 0)
			Do
				dac0_start[i] = NumberByKey(("dac0_start"+num2str(i)), pro_string, ">", "|")
				dac0_end[i] = NumberByKey(("dac0_end"+num2str(i)), pro_string, ">", "|")
				dac0_amp[i] = NumberByKey(("dac0_amp"+num2str(i)), pro_string, ">", "|")
				i += 1
			While(i < dac0_pulse_num)
		Endif
	Endif
	if (dac1_status)
		dac1_pulse_num = NumberByKey("dac1_pulse_num", pro_string, ">", "|")
		dac1_start = 0
		dac1_end = 0
		dac1_amp = 0
		temp = NumberByKey("amp_change_1", pro_string, ">", "|")
		if (numtype(temp) == 0)
			amp_change_1 = temp
		else
			amp_change_1 = 0
		Endif

		i = 0
		if (dac1_pulse_num > 0)
			Do
				dac1_start[i] = NumberByKey(("dac1_start"+num2str(i)), pro_string, ">", "|")
				dac1_end[i] = NumberByKey(("dac1_end"+num2str(i)), pro_string, ">", "|")
				dac1_amp[i] = NumberByKey(("dac1_amp"+num2str(i)), pro_string, ">", "|")
				i += 1
			While(i < dac1_pulse_num)
		Endif
	Endif
	if (dac2_status)
		dac2_pulse_num = NumberByKey("dac2_pulse_num", pro_string, ">", "|")
		i = 0
		dac2_start = 0
		dac2_end = 0
		dac2_amp = 0
		temp = NumberByKey("amp_change_2", pro_string, ">", "|")
		if (numtype(temp) == 0)
			amp_change_2 = temp
		else
			amp_change_2 = 0
		Endif
		
		if (dac2_pulse_num > 0)
			Do
				dac2_start[i] = NumberByKey(("dac2_start"+num2str(i)), pro_string, ">", "|")
				dac2_end[i] = NumberByKey(("dac2_end"+num2str(i)), pro_string, ">", "|")
				dac2_amp[i] = NumberByKey(("dac2_amp"+num2str(i)), pro_string, ">", "|")
				i += 1
			While(i < dac2_pulse_num)
		Endif
	Endif
	if (dac3_status)
		dac3_pulse_num = NumberByKey("dac3_pulse_num", pro_string, ">", "|")
		dac3_start = 0
		dac3_end = 0
		dac3_amp = 0
		temp = NumberByKey("amp_change_3", pro_string, ">", "|")
		if (numtype(temp) == 0)
			amp_change_3 = temp
		else
			amp_change_3 = 0
		Endif

		i = 0
		if (dac3_pulse_num > 0)
			Do
				dac3_start[i] = NumberByKey(("dac3_start"+num2str(i)), pro_string, ">", "|")
				dac3_end[i] = NumberByKey(("dac3_end"+num2str(i)), pro_string, ">", "|")
				dac3_amp[i] = NumberByKey(("dac3_amp"+num2str(i)), pro_string, ">", "|")
				i += 1
			While(i < dac3_pulse_num)
		Endif
	Endif
	variable j
	For (i = 0; i < 16; i += 1)
		WAVE ttl_start = $("ttl"+num2str(i)+"_start")
		WAVE ttl_end = $("ttl"+num2str(i)+"_end")
		NVAR ttl_pulse_num = $("ttl"+num2str(i)+"_pulse_num")
		ttl_pulse_num = NumberByKey("ttl"+num2str(i)+"_pulse_num", pro_string, ">", "|")
		For (j = 0; j < ttl_pulse_num; j += 1)
			ttl_start[j] = NumberByKey(("ttl"+num2str(i)+"_start"+num2str(j)), pro_string, ">", "|")
			ttl_end[j] = NumberByKey(("ttl"+num2str(i)+"_end"+num2str(j)), pro_string, ">", "|")
		EndFor
	EndFor
	
	
//	ttl1_pulse_num = NumberByKey("ttl1_pulse_num", pro_string, ">", "|")
//	ttl1_start = 0
//	ttl1_end = 0
//	i = 0
//	if (ttl1_pulse_num > 0)
//		Do
//			ttl1_start[i] = NumberByKey(("ttl1_start"+num2str(i)), pro_string, ">", "|")
//			ttl1_end[i] = NumberByKey(("ttl1_end"+num2str(i)), pro_string, ">", "|")
//			i += 1
//		While(i < ttl1_pulse_num)
//	Endif
	
	i = 0
	Do
		temp = NumberByKey(("amp_analysis_flag"+num2str(i)), pro_string, ">", "|")
		if ((temp != 1) && (temp != 0))
			amp_analysis_flag_wave[i] = 0
		Else
			amp_analysis_flag_wave[i] = temp
		Endif
		analysis_trace_name_wave[i] = StringByKey(("analysis_trace_name"+num2str(i)), pro_string, ">","|")
		if (strlen(analysis_trace_name_wave[i]) == 0)
			analysis_trace_name_wave[i] = "adc0"
		Endif
		amp_bl_start_wave[i] = NumberByKey(("amp_bl_start"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_bl_start_wave[i]) == 2)
			amp_bl_start_wave[i] = 0
		Endif
		amp_bl_end_wave[i] = NumberByKey(("amp_bl_end"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_bl_end_wave[i]) == 2)
			amp_bl_end_wave[i] = 0
		Endif
		amp_start_wave[i] = NumberByKey(("amp_start"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_start_wave[i]) == 2)
			amp_start_wave[i] = 0
		Endif
		amp_end_wave[i] = NumberByKey(("amp_end"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_end_wave[i]) == 2)
			amp_end_wave[i] = 0
		Endif
		amp_analysis_mode_wave[i] = NumberByKey(("amp_analysis_mode"+num2str(i)), pro_string, ">", "|")
		if (numtype(amp_analysis_mode_wave[i]) == 2)
			amp_analysis_mode_wave[i] = 0
		Endif
		i += 1
	While ( i < analysis_max)
		draw_flag = NumberByKey("draw_flag", pro_string, ">", "|")
		if (draw_flag != 1 && draw_flag != 0)
			draw_flag = 0
		Endif
		CheckBox set_Amp_Analysis_flag,win=Amp_Panel,value= amp_analysis_flag_wave[analysis_num]
//
//	
//	
//	
//	
//	
//	
//	amp_analysis = NumberByKey("amp_analysis", pro_string, ">", "|")
//	amp_analysis_mode = NumberByKey("amp_analysis_mode", pro_string, ">", "|")
//	amp_bl_start = NumberByKey("amp_bl_start", pro_string, ">", "|")
//	amp_bl_end = NumberByKey("amp_bl_end", pro_string, ">", "|")
//	amp_start = NumberByKey("amp_start", pro_string, ">", "|")
//	amp_end = NumberByKey("amp_end", pro_string, ">", "|")					
//	i = 0
//	Do
//		temp = NumberByKey(("amp_analysis_flag"+num2str(i)), pro_string, ">", "|")
////		printf "temp: %d\r", temp
//		if ((temp != 1) && (temp != 0))
//			amp_analysis_flag_wave[i] = 0
//		Else
//			amp_analysis_flag_wave[i] = temp
//		Endif
//		i += 1
//	While(i < analysis_max)
//	if (check)
//		CheckBox /Z set_Amp_Analysis_flag,win=Amp_Panel,value= amp_analysis_flag_wave[analysis_num]
//	Endif
	old_samples = samples
	set_sweep_time()
	ResumeUpdate
	if (update)
		doupDate
	Endif
End


function write_header()
	SVAR header_string
	NVAR write_file_ref, header_string_size, header_wave_size,datesecs
	WAVE header_wave
	datesecs = DateTime
	header_string = encode_header()
	header_string_size = strlen(header_string)
	FBinWrite /F=4 write_file_ref, header_string_size
	FBinWrite /F=4 write_file_ref, header_wave_size
	FBinWrite write_file_ref, header_string
	FBinWrite /F=4 write_file_ref, header_wave
	print_header()
End



function read_acquire_header()

	SVAR comment, comment2,seq_in, seq_out, read_file_name, read_datapath
	SVAR header_string,start_time
	NVAR read_file_open, trace_num, trace_end, trace_start
	NVAR acquired, samples, freq, adc_gain0, adc_gain1, adc_gain2, adc_gain3
	NVAR header_wave_size,acquired
	NVAR header_string_size,dac0_vc,dac1_vc,dac2_vc,dac3_vc
	NVAR poisson_scale, wait, ttl_status
	NVAR read_file_ref, total_header_size, total_chan_num
	NVAR adc_status0,adc_status1,adc_status2, adc_status3
	WAVE adc0,adc1,adc2,adc3
	NVAR disp_0, disp_1, disp_2, disp_3
	NVAR init_display
	NVAR adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag
	variable i
//	close /a
	read_file_open = 0
	Open /T="****"/R/P=read_datapath read_file_ref as read_file_name
	FStatus read_file_ref
	if (V_flag == 0)
		beep; beep; beep
		printf "ERROR: read file: %s not valid (acquire_files)\r", read_file_name
		Return(0)
	Endif
	read_file_name = S_fileName
	newpath /Q/O read_datapath, S_Path
	read_file_open = 1
	FBinRead /F=4 read_file_ref, header_string_size
	FBinRead /F=4 read_file_ref, header_wave_size
	header_string = PadString(header_string, header_string_size, 0)
	FBinRead read_file_ref, header_string
	Make /O/N=(header_wave_size) header_wave
	FBinRead /F=4 read_file_ref, header_wave
	decode_header(header_string)
//	if (ttl_status == 1)
//		total_chan_num -= 1
//	endif

// start change June-24
//	adc_status0 = 0 
//	adc_status1 = 0
//	adc_status2 = 0
//	adc_status3 = 0
//	if (total_chan_num >= 1)
//		if (cmpstr(seq_in[0],"0") == 0)
//			adc_status0 = 1
//		Endif
//		if (cmpstr(seq_in[0],"1") == 0)
//			adc_status1 = 1
//		Endif		
//		if (cmpstr(seq_in[0],"2") == 0)
//			adc_status2 = 1
//		Endif
//		if (cmpstr(seq_in[0],"3") == 0)
//			adc_status2 = 1
//		Endif
//	Endif
//	if (total_chan_num >= 2)
//		if (cmpstr(seq_in[1],"0") == 0)
//			adc_status0 = 1
//		Endif
//		if (cmpstr(seq_in[1],"1") == 0)
//			adc_status1 = 1
//		Endif
//		if (cmpstr(seq_in[1],"2") == 0)
//			adc_status2 = 1
//		Endif
//	Endif
	adc0_avg_flag = 0
	adc1_avg_flag = 0
	adc2_avg_flag = 0
	adc3_avg_flag = 0
	Make /O/N=(samples*total_chan_num) InData
	if (adc_status0)
		Make /O/N=(samples) adc0, adc0_avg_0, root:avg:adc0_avg_temp_0
		SetScale /P x, 0, (1.0/freq), "ms", adc0, adc0_avg_0
		adc0_avg_flag = 1
	EndIf
	if (adc_status1)
		Make /O/N=(samples) adc1, adc1_avg_0, root:avg:adc1_avg_temp_0
		SetScale /P x, 0, (1.0/freq), "ms", adc1, adc1_avg_0
		adc1_avg_flag = 1
	EndIf
	if (adc_status2)
		Make /O/N=(samples) adc2, adc2_avg_0, root:avg:adc2_avg_temp_0
		SetScale /P x, 0, (1.0/freq), "ms", adc2, adc2_avg_0
		adc2_avg_flag = 1
	EndIf
	if (adc_status3)
		Make /O/N=(samples) adc3, adc3_avg_0, root:avg:adc3_avg_temp_0
		SetScale /P x, 0, (1.0/freq), "ms", adc3, adc3_avg_0
		adc3_avg_flag = 1
	EndIf

	set_disp_check()
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
	trace_num = 0
	trace_end = acquired-1
	trace_start = 0
	total_header_size = 4 + 4 + header_string_size + header_wave_size * 4
	if (init_display)
		init_g_traces()
	Endif
//	printf "start_time :%s\r", start_time

End

function read_neuron_header()

	SVAR comment=comment, seq_in=seq_in, seq_out=seq_out, read_file_name=read_file_name, read_datapath=read_datapath
	SVAR header_string=header_string,start_time=start_time
	NVAR read_file_open=read_file_open, trace_num=trace_num, trace_end=trace_end, trace_start=trace_start
	NVAR acquired=acquired, samples=samples, freq=freq, adc_gain0=adc_gain0, adc_gain1=adc_gain1
	NVAR header_wave_size=header_wave_size,acquired=acquired
	NVAR header_string_size=header_string_size,dac0_vc=dac0_vc,dac1_vc=dac1_vc
	NVAR poisson_scale=poisson_scale, wait=wait, ttl_status=ttl_status
	NVAR read_file_ref=read_file_ref, total_header_size=total_header_size, total_chan_num=total_chan_num
	NVAR adc_status0=adc_status0,adc_status1=adc_status1
	WAVE adc0=adc0,adc1=adc1
	variable i, temp
	close /a
	read_file_open = 0
	Open /T="****"/R/P=read_datapath read_file_ref as read_file_name
	FStatus read_file_ref
	if (V_flag == 0)
		beep; beep; beep
		printf "ERROR: read file: %s not valid (acquire_files)\r", read_file_name
		Return(0)
	Endif
	read_file_name = S_fileName
	newpath /Q/O read_datapath, S_Path
	read_file_open = 1
	FBinRead /F=5 read_file_ref, header_string_size
	header_string = PadString(header_string, header_string_size, 0)
	FBinRead read_file_ref, header_string
	decode_neuron(header_string)
	total_chan_num = 1
	Make /O/N=(samples*total_chan_num) InData
	Make /O/N=(samples) adc0, adc1
	SetScale /P x, 0, (1.0/freq), "ms", adc0, adc1
	SetScale d, -200, 200, "pA", adc0
	trace_num = 0
	trace_end = acquired-1
	trace_start = 0
	total_header_size = 8 + header_string_size + 2
	FBinRead /F=5 read_file_ref, temp
	printf "temp: %f\r", temp

End


function decode_neuron(header_string)
	string header_string
	
	variable temp
	NVAR acquired=acquired
	NVAR dac0_gain=dac0_gain,dac1_gain=dac1_gain,dac2_gain=dac2_gain,dac3_gain=dac3_gain
	NVAR adc_gain0=adc_gain0,adc_gain1=adc_gain1,adc_gain2=adc_gain2,adc_gain3=adc_gain3
	NVAR adc_gain4=adc_gain4,adc_gain5=adc_gain5,adc_gain6=adc_gain6,adc_gain7=adc_gain7
	NVAR adc_status0=adc_status0,adc_status1=adc_status1,adc_status2=adc_status2,adc_status3=adc_status3
	NVAR adc_status4=adc_status4,adc_status5=adc_status5,adc_status6=adc_status6,adc_status7=adc_status7
	NVAR dac0_status=dac0_status,dac1_status=dac1_status,dac2_status=dac2_status,dac3_status=dac3_status
	NVAR freq=freq, total_chan_num=total_chan_num, samples=samples,requested=requested
	NVAR wait=wait,freq=freq,hp0=hp0,hp1=hp1,old_samples=old_samples, ttl_status=ttl_status
	SVAR seq_in=seq_in,seq_out=seq_out
	WAVE dac0_start=dac0_start, dac0_end=dac0_end, dac0_amp=dac0_amp
	WAVE dac1_start=dac1_start, dac1_end=dac1_end, dac1_amp=dac1_amp
	NVAR dac0_pulse_num=dac0_pulse_num,dac1_pulse_num=dac1_pulse_num,dac0_vc=dac0_vc,dac1_vc=dac1_vc
	NVAR dac0_cc=dac0_cc,dac1_cc=dac1_cc, acquire_mode=acquire_mode

	NVAR sine_flag_dac0=sine_flag_dac0, sine_flag_dac1=sine_flag_dac1, sine_phase_dac0=sine_phase_dac0
	NVAR sine_phase_dac1=sine_phase_dac1, sine_amp_dac0=sine_amp_dac0, sine_amp_dac1=sine_amp_dac1
	NVAR sine_freq_dac0=sine_freq_dac0, sine_freq_dac1=sine_freq_dac1,continuous_flag=continuous_flag

	NVAR dac0_psc_flag=dac0_psc_flag,dac0_psc1_amp=dac0_psc1_amp, dac0_psc2_amp=dac0_psc2_amp,dac0_psc1_taurise=dac0_psc1_taurise, dac0_psc2_taurise=dac0_psc2_taurise
	NVAR dac0_psc1_taudecay=dac0_psc1_taudecay,dac0_psc2_taudecay=dac0_psc2_taudecay, dac0_psc_interval=dac0_psc_interval, dac0_psc_start=dac0_psc_start
	NVAR dac1_psc_flag=dac1_psc_flag,dac1_psc1_amp=dac1_psc1_amp, dac1_psc2_amp=dac1_psc2_amp,dac1_psc1_taurise=dac1_psc1_taurise, dac1_psc2_taurise=dac1_psc2_taurise
	NVAR dac1_psc1_taudecay=dac1_psc1_taudecay,dac1_psc2_taudecay=dac1_psc2_taudecay, dac1_psc_interval=dac1_psc_interval, dac1_psc_start=dac1_psc_start
	
	NVAR dac0_stimfile_flag=dac0_stimfile_flag,dac0_stimfile_scale=dac0_stimfile_scale,stimfile_recycle=stimfile_recycle, stimfile_loc=stimfile_loc
	NVAR dac1_stimfile_flag=dac1_stimfile_flag,dac1_stimfile_scale=dac1_stimfile_scale
	SVAR stimfile_name=stimfile_name
	samples = NumberByKey("noOfPointsPerTraces", header_string, ":", ";")
	acquired = NumberByKey("noOfTraces", header_string, ":", ";")
	temp = NumberByKey("dt", header_string, ":", ";")
	freq = 1/temp
End



function /S next_file_name(file_name)
	String file_name
	
	variable loc, index_num, test_ref
	string index_str = "", pre_name="", old_file_name = "", new_file_name = ""
	old_file_name = file_name
	loc = strsearch(file_name,".", 0)
	index_str = file_name[loc+1, strlen(file_name)]
	pre_name = file_name[0,loc]
	index_num = str2num(index_str)
	index_str = num2str(index_num+1)
	if ((index_num + 1) < 10)
		index_str = "00" + index_str
	Endif
	if (((index_num + 1) < 100) %& ((index_num + 1) > 9))
		index_str = "0" + index_str
	EndIf
	new_file_name = pre_name + index_str
	Return(new_file_name)
End

function para_change()

	SVAR write_file_name=write_file_name
	NVAR write_file_open, acquired
	NVAR samples, freq
	if ((write_file_open == 0) || (acquired == 0))
		acquired = 0
	Else
		close_write_file("")
		acquired = 0
		write_file_name = next_file_name (write_file_name)
		create_data_file()
	Endif
End




Function Read_Igor_Header()
	Silent 1
	SVAR comment=comment, comment2,seq_in=seq_in, seq_out=seq_out, read_file_name=read_file_name, read_datapath=read_datapath
	NVAR read_file_open=read_file_open, trace_num=trace_num, trace_end=trace_end, trace_start=trace_start
	NVAR acquired=acquired, samples=samples, freq=freq, adc_gain0=adc_gain0, adc_gain1=adc_gain1
	NVAR cc_stim_amp=cc_stim_amp, cc_stim_duration=cc_stim_duration, pre_chan=pre_chan
	NVAR poisson_scale=poisson_scale, wait=wait, pulse_num=pulse_num, pulse_inter=pulse_inter, pulse_start=pulse_start
	NVAR bin_header_length=bin_header_length, comment_length=comment_length, sequence_length=sequence_length
	NVAR read_file_ref=read_file_ref, total_header_size=total_header_size, total_chan_num=total_chan_num
	NVAR dac1_vc=dac1_vc,dac0_vc=dac0_vc
	variable i

	read_file_open = 0
	Open /T="****"/R/P=read_datapath read_file_ref as read_file_name
	FStatus read_file_ref
	if (V_flag == 0)
		beep; beep; beep
		printf "ERROR: read file: %s not valid (acquire_files)\r", read_file_name
		Return(0)
	Endif
	read_file_name = S_fileName
	newpath /Q/O read_datapath, S_Path
	FBinRead /F=2 read_file_ref, comment_length
	FBinRead /F=2 read_file_ref, sequence_length
	FBinRead /F=2 read_file_ref, bin_header_length
	comment = ""
	comment = PadString (comment, comment_length, 0)
	seq_in = ""
	seq_in = PadString (seq_in, sequence_length, 0)
	seq_out = ""
	seq_out = PadString (seq_out, sequence_length, 0)
	Make /O/N=(bin_header_length) header_wave
	FBinread read_file_ref, comment
	FBinread read_file_ref, seq_in
	FBinread read_file_ref, seq_out	
	FBinRead /F=4 read_file_ref, header_wave
	FStatus read_file_ref
	total_header_size = V_filePos 
	read_file_open = 1
	acquired = header_wave[0]								
	samples = header_wave[1]
	freq = header_wave[2]
	adc_gain0 = header_wave[3]
	adc_gain1 = header_wave[4]
	cc_stim_amp = header_wave[5]
	cc_stim_duration = header_wave[6]
	pre_chan = header_wave[7]
	poisson_scale = header_wave[8]
	wait = header_wave[9]
	pulse_num = header_wave[10]
	pulse_inter = header_wave[11]
	pulse_start = header_wave[12]
	Make /O/N=(samples*2) InData
	Make /O/N=(samples) adc0, adc1
	SetScale /P x, 0, (1.0/freq), "ms", adc0, adc1
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
	trace_num = 0
	trace_end = acquired-1
	trace_start = 0
End

	
function read_xy_header()

	SVAR comment=comment, seq_in=seq_in, seq_out=seq_out, read_file_name=read_file_name, read_datapath=read_datapath
	NVAR read_file_open=read_file_open, trace_num=trace_num, trace_end=trace_end, trace_start=trace_start
	NVAR acquired=acquired, samples=samples, freq=freq, adc_gain0=adc_gain0, adc_gain1=adc_gain1
	NVAR cc_stim_amp=cc_stim_amp, cc_stim_duration=cc_stim_duration, pre_chan=pre_chan
	NVAR poisson_scale=poisson_scale, wait=wait, pulse_num=pulse_num, pulse_inter=pulse_inter, pulse_start=pulse_start
	NVAR bin_header_length=bin_header_length, comment_length=comment_length, sequence_length=sequence_length,hp0=hp0,hp1=hp1
	NVAR read_file_ref=read_file_ref, total_header_size=total_header_size, total_chan_num=total_chan_num, bin_type=bin_type
	NVAR adc_status0=adc_status0,adc_status1=adc_status1
	WAVE adc0=adc0,adc1=adc1
	variable/ g stim_gain0=1, stim_gain1=1
//	NVAR stim_gain0=stim_gain0, stim_gain1=stim_gain1
	variable temp, tscale
	read_file_open = 0
	Open /T="****"/R/P=read_datapath read_file_ref as read_file_name
	FStatus read_file_ref
	if (V_flag == 0)
		beep; beep; beep
		printf "ERROR: read file: %s not valid(acquire_files)\r", read_file_name
		Return(0)
	Endif 
	read_file_name = S_fileName
	NewPath /Q/O read_datapath, S_path
	read_file_open = 1
	FSetPos read_file_ref, 8
	FBinRead /F=2 read_file_ref, acquired
	FSetPos read_file_ref, 28
	FBinRead /F=2 read_file_ref, total_chan_num
	FSetPos read_file_ref, 18
	FBinRead /F=2 read_file_ref, adc_gain0
	FSetPos read_file_ref, 492
	FBinRead /F=2 read_file_ref, adc_gain1
	if ((total_chan_num == 1) %& (bin_type == 1))
		adc_gain1 = adc_gain0
	Endif
	if ((total_chan_num == 2) %& (bin_type == 2))
		temp = adc_gain1
		adc_gain1 = adc_gain0
		adc_gain0 = temp
	Endif
	FSetPos read_file_ref, 22
	FBinRead /F=2 read_file_ref, samples
	FSetPos read_file_ref, 46
	FBinRead /F=2 read_file_ref, stim_gain0
	FBinRead /F=2 read_file_ref, stim_gain1
	FSetPos read_file_ref, 26
	fBinread /F=2 read_file_ref, hp0
	if ((bin_type == 1) %& (stim_gain0 != 0))
		hp0 *= (4.8828/stim_gain0)
	Endif
	If ((bin_type == 2) %& (stim_gain0 != 0))
		hp0 *= (0.3052/stim_gain0)
	endif 
	FSetPos read_file_ref, 6
	FBinRead/F=2 read_file_ref, temp
	if ((total_chan_num == 2) %& (bin_type != 10))
		adc_status0 = 1
		adc_status1 = 1
	Endif
	if (total_chan_num == 1)
		if ((temp == 0) %& (bin_type == 2))
			adc_status0 = 1
			adc_status1 = 0
		endif
		if ((temp != 0) %& (bin_type == 2))
			adc_status0 = 0
			adc_status1 = 1
		Endif
		if ((temp == 15) %& (bin_type == 1))
			adc_status0 = 1
			adc_status1 = 0
		endif
		If ((temp == 14) %& (bin_type == 1))
			adc_status0 = 0
			adc_status1 = 1
		Endif
	Endif
	samples /= total_chan_num
	FSetPos read_file_ref, 36
	FBinRead /F=3 read_file_ref, freq
	freq /= 1000.0 
	freq /= total_chan_num
	FsetPos read_file_ref, 488
	FbinRead /F=2 read_file_ref, hp1
	if (bin_type == 1)
		hp1 *= 4.8828
	Endif
	If (bin_type == 2)
		hp1 *= 0.3052
	endif 
	FSetPos read_file_ref, 502
	FBinRead /F=4 read_file_ref, wait
	FSetPos read_file_ref, total_header_size
	read_file_open = 1
	trace_num = 0
	trace_end = acquired-1
	trace_start = 0
	Make /O/N=(samples) adc0, adc1
	if (adc_status0 == 0)
		adc0 = NaN
	endif
	if (adc_status1 == 0)
		adc1 = NaN
	Endif
	Make /O/N=(samples*total_chan_num) InData
	if (total_chan_num == 1)
		SetScale /P x, 0, (1.0/freq), "ms", adc0, adc1
	endif
	if (total_chan_num == 2)
		SetScale /P x, 0, (1.0/freq), "ms", adc1
		SetScale /P x, (0.5/freq), (1.0/freq), "ms", adc0
	endif
	SetScale d, -200, 200, "mV", adc0, adc1 
	FSetPos read_file_ref, 516
	FBinRead /F=2 read_file_ref, temp
	if (bin_type == 1)
		tscale = 16.0
	Else
		tscale = 1.0
	Endif
	if (adc_status0 == 1)
		printf "pulse: %.3f\r", (temp * 0.3052*tscale)/stim_gain0
	Else
		printf "pulse: %.3f\r", (temp * 0.3052*tscale)/stim_gain1
	endif
//	if (total_chan_num == 2) // adc0 is the 0 channle in xyplot terminology
//		temp = adc1_gain
//		adc1_gain = adc0_gain
//		adc0_gain = temp
//	Endif  
End
	



function get_next_trace(alternate)
	variable alternate
	NVAR read_file_open=read_file_open, read_file_ref=read_file_ref, trace_num=trace_num
	NVAR samples=samples, adc_gain0, adc_gain1, adc_gain2, adc_gain3,total_chan_num, bin_type
	NVAR acquired=acquired, bin_type=bin_type, total_header_size = total_header_size
	NVAR align_flag=align_flag, amp_analysis=amp_analysis, smooth_flag=smooth_flag,ttl_status=ttl_status
	NVAR spike_cv_flag,adc_status0,adc_status1,adc_status2, adc_status3
	WAVE InData, adc0, adc1,adc2, adc3
	SVAR seq_in

	if ((trace_num+alternate) > acquired)
		Beep; Beep; Beep
		printf "ERROR: last trace: %d (acquire_files)\r", trace_num
		Return(0)
	endif
	if (alternate != 0)
		FSetPos read_file_ref, (total_header_size + trace_num * alternate * samples * 2 * total_chan_num)
	endif
	If (bin_type == 100)
		FBinRead /F=5 read_file_ref, InData
		adc0 = InData
	Else
		FBinRead /F=2 read_file_ref, InData
	Endif
	if ((total_chan_num == 2) %& (bin_type == 0))
		adc0[0,samples-1] = InData[p*2]
		adc1[0,samples-1] = InData[1+p*2]
	endif
	if ((total_chan_num == 2) %& (bin_type == 2) )
		adc0[0,samples-1] = InData[p*2]
		adc1[0,samples-1] = InData[1+p*2]
	endif
	if ((total_chan_num == 2) %& (bin_type == 1) )
		adc1[0,samples-1] = InData[p*2]
		adc0[0,samples-1] = InData[1+p*2]
	endif
//********* Acquire type
	if (bin_type == 10)
	
	variable index = 0
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
	EndIf // bintype == 10
	
	
	
//		if (total_chan_num == 2)
//			if (adc_status2 == 0)
//				adc0[0,samples-1] = InData[p*2]
//				adc1[0,samples-1] = InData[1+p*2]
//			endif
//			if (adc_status0 == 0)
//				adc1[0,samples-1] = InData[p*2]
//				adc2[0,samples-1] = InData[1+p*2]
//			endif
//			if (adc_status1 == 0)
//				adc0[0,samples-1] = InData[p*2]
//				adc2[0,samples-1] = InData[1+p*2]
//			endif
//		Endif
//	Endif
	if ((total_chan_num == 1) %& (adc_status0 == 1))
		adc0[0,samples-1] = InData[p]
	Endif
	if ((total_chan_num == 1) %& (adc_status1 == 1))
		adc1[0,samples-1] = InData[p]
	endif
	if ((total_chan_num == 1) %& (adc_status2 == 1))
		adc2[0,samples-1] = InData[p]
	endif
	if (bin_type == 0 ) 
		adc0 *= (1.0/(3.2 * adc_gain0))
		adc1 *= (1.0/(3.2 * adc_gain1))
		if (adc_gain2 != 0)
			adc2 *= (1.0/(3.2 * adc_gain2))
		endif
	endif
	if (bin_type == 1) // xyplot
		adc0 *= (10000.0/(2048.0 *adc_gain0))
		adc1 *= (10000.0/(2048.0 * adc_gain1))
	Endif
	if (bin_type == 2) // xyplot AT-MIO
		adc0 *= (10000.0/((2048.0 *adc_gain0)*16))
		adc1 *= (10000.0/((2048.0 * adc_gain1)*16))
	Endif
//	trace_num += (1 + alternate)
	if (align_flag == 1)
		align_traces()
	Endif
	if (smooth_flag == 1)
		smooth_trace()
	Endif
	if (amp_analysis == 1)
//		draw_amp(1)
	endif
	if (spike_cv_flag == 1)
//		get_isi("")
	Endif
	Return(1)
End




function get_a_trace(Num)
	Variable Num
	
//						Variable timerRefNum
//					Variable microSeconds
//					timerRefNum = startMSTimer


	NVAR total_header_size, trace_num
	NVAR read_file_open, read_file_ref
	NVAR samples
	NVAR adc_gain0,adc_gain1, adc_gain2, adc_gain3
	NVAR acquired, bin_type, total_chan_num
	NVAR align_flag=align_flag, amp_analysis=amp_analysis, smooth_flag=smooth_flag
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4=adc_status4,adc_status5=adc_status5,adc_status6=adc_status6,adc_status7=adc_status7
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR spike_cv_flag
	NVAR scale_to_vis
	NVAR concat
	WAVE InData, adc0, adc1, adc2, adc3
	
	// the following are used for online amplitude analysis
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
	WAVE concat_0, concat_1, concat_2, concat_3
	
	SVAR seq_in
	variable i
	If (read_file_open != 1)
		Beep; Beep; Beep
		printf "ERROR: from get_a_trace -> file not open (acquire_files)\r"
		return(0)
	Endif
	if (Num > (acquired-1))
		Beep; Beep; Beep
		printf "ERROR: only %d acquired (acquire_files)\r", acquired
		trace_num = acquired-1
		Return(0)
	Endif
	if (Num < 0)
		Beep; Beep; Beep
		printf "ERROR: Num : %d (acquire_files)\r", Num
		trace_num = 0
		Return(0)
	Endif
	FStatus read_file_ref
	if (V_flag == 0)
		beep; beep; beep
		printf "ERROR: from get_a_trace-> read_file_ref not valid (acquire_files)\r"
		return(0)
	Endif
	if (bin_type != 100)
		FSetPos read_file_ref, (total_header_size + Num * samples * 2 * total_chan_num)
		FBinRead /F=2 read_file_ref, InData
//		microSeconds = stopMSTimer(timerRefNum)
//					printf "time (micorsec): %f\r", microSeconds
	endif
	If (bin_type == 100)
		FSetPos read_file_ref, (total_header_size + Num * samples * 8 * total_chan_num)
		FBinRead /F=5 read_file_ref, InData
	Endif
	if ((total_chan_num == 2) %& (bin_type == 0))
		adc0[0,samples-1] = InData[p*2]
		adc1[0,samples-1] = InData[1+p*2]
	endif
	if ((total_chan_num == 2) %& (bin_type == 2))
		adc0[0,samples-1] = InData[p*2]
		adc1[0,samples-1] = InData[1+p*2]
	endif
	if ((total_chan_num == 2) %& (bin_type == 1))
		adc1[0,samples-1] = InData[p*2]
		adc0[0,samples-1] = InData[1+p*2]
	endif
	if (bin_type == 10) // current Acquire type
	variable index = 0
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
	EndIf // bintype == 10
	
	
//	if (bin_type == 10 && concat == 1) // current Acquire type and concatenate 
//	  index = 0
//	  Do
//		If (cmpstr(seq_in[index], "D") != 0)
//			strswitch(seq_in[index])
//			case "0":
////				concat_0[(trace_num*samples),(trace_num*samples+samples)] = adc0
////				if (NUM == 0)
////					Concatenate/NP/O {adc0},concat_0
////				Else
////					Duplicate/O concat_0, temp_con
////					Concatenate/NP/O {temp_con,adc0},concat_0
////				Endif
//				break
//			case "1":
//				if (NUM == 0)
//					Concatenate/NP/O {adc1},concat_1
//				Else
//					Duplicate/O concat_1, temp_con
//					Concatenate/NP/O {temp_con,adc1},concat_1
//				Endif
//				break
//			case "2":
//				if (NUM == 0)
//					Concatenate/NP/O {adc2},concat_2
//				Else
//					Duplicate /O concat_2, temp_con 
//					Concatenate/NP/O {temp_con,adc2},concat_2
//				Endif
//				break
//			case "3":
//				if (NUM == 0)
//					Concatenate/NP/O {adc3},concat_3
//				Else
//					Duplicate/O concat_3, temp_con
//					Concatenate/NP/O {temp_con,adc3},concat_3
//				Endif
//				break
//			EndSwitch
//		Endif
//		index += 1
//	  While (index < total_chan_num)
//	EndIf // bintype == 10
	
	
//	if (total_chan_num == 1)
//		if (adc_status1 == 1)
//			adc1[0,samples-1] = inData[p]
//		else
//			adc0[0,samples-1] = inData[p]
//		endif
//	Endif
//	if (bin_type == 10)
//		if (adc_status0)
//			adc0 *= (1.0/(3.2 * adc_gain0))
//		EndIf
//		if (adc_status1)
//			adc1 *= (1.0/(3.2 * adc_gain1))
//		EndIf
//		if (adc_status2)
//			adc2 *= (1.0/(3.2 * adc_gain2))
//		EndIf
//		if (adc_status3)
//			adc3 *= (1.0/(3.2 * adc_gain3))
//		EndIf
//	endif

//	if (bin_type == 10)
//		adc0 /= (3.2 * adc_gain0)
//	endif 
	if (bin_type == 0) 
		adc0 *= (1.0/(3.2 * adc_gain0))
		adc1 *= (1.0/(3.2 * adc_gain1))
	endif
	if (bin_type == 1) // xyplot
		adc0 *= (10000.0/(2048.0 *adc_gain0))
		adc1 *= (10000.0/(2048.0 * adc_gain1))
	Endif
	if (bin_type == 2) // xyplot 16 bit
		adc0 *= (10000.0/((2048.0 *adc_gain0)*16))
		adc1 *= (10000.0/((2048.0 * adc_gain1)*16))
	Endif
	if (bin_type == 100)
		adc0 = Indata
	Endif
	if (align_flag == 1)
		align_traces()
	Endif
	if (smooth_flag == 1)
		smooth_trace()
	endif
	
	string wavename
	i = 0
	if (draw_flag)
		DoWindow /F G_traces
		setdrawlayer /K progback
		setdrawenv linethick=1.2, linefgc=(0,26112,13056), xcoord=bottom, ycoord=$get_yaxis(analysis_trace_name_wave[i])
		setdrawenv save
	Endif
	Do
		if (amp_analysis_flag_wave[i])
			peak = Get_Amp(amp_analysis_mode_wave[i],analysis_trace_name_wave[i], amp_bl_start_wave[i], amp_bl_end_wave[i], amp_start_wave[i], amp_end_wave[i], "G_traces")
			wavename = ("amp_points_wave_" + num2str(i))
			WAVE tempwave = $wavename
			tempwave[analysed_points_wave[i]]  = peak
			analysed_points_wave[i] += 1
		Endif
		i += 1
	While (i < 10)
	if (update)
		DoUpDate
	Endif
	
	if (amp_analysis == 1)
//		draw_amp(1)
	endif
	if (spike_cv_flag == 1)
		get_isi("")
	Endif
	if (scale_to_vis)
		scale_vis("G_traces")
	Endif
	trace_num = Num
	printf "Read trace # %d\r", trace_num
						
End

function Analyze_trace(trace_name, i)
	string trace_name
	variable i // which analysis
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE analysed_points_wave  // the number of points analysed in the dpoints waves
	WAVE amp_analysis_flag_wave // if 1 do analysis
	WAVE amp_analysis_mode_wave  // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	NVAR acquire_mode, draw_flag, peak, update
	if (draw_flag)
		setdrawlayer /K progback
		setdrawenv linethick=1.2, linefgc=(0,26112,13056), xcoord=bottom, ycoord=$get_yaxis(trace_name)
		setdrawenv save
	Endif
	if (amp_analysis_flag_wave[i])
		peak = Get_Amp(amp_analysis_mode_wave[i],trace_name, amp_bl_start_wave[i], amp_bl_end_wave[i], amp_start_wave[i], amp_end_wave[i],"G_average")
	Endif
End


function Load_Protocol(CntrlName) : ButtonControl
	String CntrlName
	NVAR pro_path
	NVAR average_sweeps, samples, freq
	SVAR protocol
	NVAR init_display
	SVAR pro_name // holds the name of the currently loaded protocol
	variable protocol_size
	variable ref
	string tempstr
	tempstr = ""
	protocol = ""
	Open /T=".pro"/R/M=pro_name/P=pro_path ref
	FStatus ref
	if (V_flag == 0)
		beep; beep; beep
		printf "ERROR: Protocol not loaded\r"
		Return(0)
	Endif
	pro_name = S_fileName
	printf "Current Protocol: %s\r", pro_name
	FBinRead /F=4 ref, protocol_size
	protocol = PadString(protocol, protocol_size, 0)
	FBinRead ref, protocol
	close(ref)
	PauseUpdate
	decode_pro("protocol")
	set_daq(tempstr)
// now make waves
	average_sweeps = 0
	Make /O/N=(samples) adc1=0,adc1_avg=0, adc1_avg_temp=0, adc2=0,adc2_avg=0, adc2_avg_temp=0, adc0=0,adc0_avg=0, adc0_avg_temp=0,adc3=0,adc3_avg=0, adc3_avg_temp=0
	SetScale /P x, 0, (1/freq), "ms",adc0,adc0_avg, adc1,adc1_avg,adc2,adc2_avg,adc3,adc3_avg
	SetScale d 0,0, "mv",adc0,adc0_avg, adc1,adc1_avg,adc2,adc2_avg,adc3,adc3_avg
	if (init_display)
		set_disp_check()
		init_g_average(0)
		init_g_traces()
	Endif
	ResumeUpdate
End

function Load_Scheme(CntrlName) : ButtonControl
	String CntrlName
	NVAR pro_path
	SVAR pro_0, scheme
	NVAR freq
	WAVE adc0, adc0_avg,adc1,adc1_avg,adc2,adc2_avg,adc3,adc3_avg
	variable ref, scheme_size
	string tempstr
	tempstr = ""
	scheme = ""
	Open /T=".sch"/R/P=pro_path ref
	FStatus ref
	if (V_flag == 0)
		beep; beep; beep
		printf "Scheme not loaded\r"
		Return(0)
	Endif
	FBinRead /F=4 ref, scheme_size
	scheme = PadString(scheme, scheme_size, 0)
	FBinRead ref, scheme
	PauseUpdate
	decode_scheme(scheme)
	decode_pro("pro_0")
	SetScale /P x 0, (1.0/freq), "ms", adc0,adc1,adc2,adc3
	SetScale d 0, 0, "pA", adc0, adc1, adc2, adc3
	ResumeUpdate
	set_daq(tempstr)
// set disp according to the channels	
	set_disp_check()
End

function set_disp_check()
	NVAR adc_status0, adc_status1, adc_status2, adc_status3
	NVAR disp_0, disp_1, disp_2, disp_3
	PauseUpdate
// set disp according to the channels	
	disp_0 = adc_status0
	checkbox d0, win=panel_aq_d, value = disp_0
	disp_1 = adc_status1
	checkbox d1, win=panel_aq_d, value = disp_1
	disp_2 = adc_status2
	checkbox d2, win=panel_aq_d, value = disp_2
	disp_3 = adc_status3
	checkbox d3, win=panel_aq_d, value = disp_3
	ResumeUpdate
End




function Load1()
	NVAR pro_path, samples, average_sweeps, freq, init_display
	SVAR pro_name, protocol
	variable ref, protocol_size
	string tempstr, file_name
	tempstr = ""
	protocol = ""
	file_name = "1.pro"
//	Open /T=".pro"/R/M=pro_name/P=pro_path ref
	Open /T="****"/R/P=pro_path ref as "1.pro"

	FStatus ref
	if (V_flag == 0)
		beep; beep; beep
		printf "ERROR: Protocol not loaded\r"
		Return(0)
	Endif
	pro_name = S_fileName
	printf "Current Protocol: %s\r", pro_name
	FBinRead /F=4 ref, protocol_size
	protocol = PadString(protocol, protocol_size, 0)
	FBinRead ref, protocol
	close(ref)
	PauseUpdate
	decode_pro("protocol")
	set_daq(tempstr)
// now make waves
	average_sweeps = 0
	Make /O/N=(samples) adc1=0,adc1_avg=0, adc1_avg_temp=0, adc2=0,adc2_avg=0, adc2_avg_temp=0, adc0=0,adc0_avg=0, adc0_avg_temp=0,adc3=0,adc3_avg=0, adc3_avg_temp=0
	SetScale /P x, 0, (1/freq), "ms",adc0,adc0_avg, adc1,adc1_avg,adc2,adc2_avg,adc3,adc3_avg
	SetScale d 0,0, "mv",adc0,adc0_avg, adc1,adc1_avg,adc2,adc2_avg,adc3,adc3_avg
	if (init_display)
		set_disp_check()
		init_g_average(0)
		init_g_traces()
	Endif
	ResumeUpdate
End

function Load2()
	NVAR pro_path, samples, average_sweeps, freq, init_display
	SVAR pro_name, protocol
	variable ref, protocol_size
	string tempstr
	tempstr = ""
	protocol = ""
	Open /T="****"/R/P=pro_path ref as "2.pro"
	FStatus ref
	if (V_flag == 0)
		beep; beep; beep
		printf "Protocol not loaded\r"
		Return(0)
	Endif
	FBinRead /F=4 ref, protocol_size
	protocol = PadString(protocol, protocol_size, 0)
	FBinRead ref, protocol
	close(ref)
	decode_pro("protocol")
	set_daq(tempstr)
	// now make waves
	average_sweeps = 0
	Make /O/N=(samples) adc1=0,adc1_avg=0, adc1_avg_temp=0, adc2=0,adc2_avg=0, adc2_avg_temp=0, adc0=0,adc0_avg=0, adc0_avg_temp=0,adc3=0,adc3_avg=0, adc3_avg_temp=0
	SetScale /P x, 0, (1/freq), "ms",adc0,adc0_avg, adc1,adc1_avg,adc2,adc2_avg,adc3,adc3_avg
	SetScale d 0,0, "mv",adc0,adc0_avg, adc1,adc1_avg,adc2,adc2_avg,adc3,adc3_avg
	if (init_display)
		set_disp_check()
		init_g_average(0)
		init_g_traces()
	Endif
End

function Load3()
	NVAR pro_path=pro_path
	variable ref, protocol_size
	string protocol, tempstr
	tempstr = ""
	protocol = ""
	Open /T="****"/R/P=pro_path ref as "3.pro"
	FStatus ref
	if (V_flag == 0)
		beep; beep; beep
		printf "Protocol not loaded\r"
		Return(0)
	Endif
	FBinRead /F=4 ref, protocol_size
	protocol = PadString(protocol, protocol_size, 0)
	FBinRead ref, protocol
	decode_pro("protocol")
	set_daq(tempstr)
End

function Load4()
	NVAR pro_path
	SVAR pro_name
	variable ref, protocol_size
	string protocol, tempstr
	tempstr = ""
	protocol = ""
	Open /T="****"/R/P=pro_path ref as "4.pro"
	FStatus ref
	if (V_flag == 0)
		beep; beep; beep
		printf "Protocol not loaded\r"
		Return(0)
	Endif
	FBinRead /F=4 ref, protocol_size
	protocol = PadString(protocol, protocol_size, 0)
	FBinRead ref, protocol
	decode_pro("protocol")
	set_daq(tempstr)
	pro_name = "4.pro"
End


//Macro Save_Protocol(protocol_name)
//	String protocol_name
//	write_protocol(protocol_name)
//End
	
Function/S DoOpenFileDialog(type)
	string type
	SVAR pro_name
	Variable refNum
	String message = "Select a file (protocol: " + pro_name + ")"
	String outputPath
	
	Open/D/T=type/M=message refNum
	outputPath = S_fileName
	print S_fileName
	
	return outputPath		// Will be empty if user canceled
End	
	
	
Function Save_Protocol()
	String protocol
	SVAR pro_name
	NVAR pro_path
	variable ref, protocol_size
	protocol = encode_pro()
	protocol_size = strlen(protocol)
	pro_name = DoOpenFileDialog(".pro")
	Open /P=pro_path/Z ref as pro_name
	FBinWrite /F=4 ref, protocol_size
	FBinWrite ref, protocol
	close ref
	Printf "protocol: %s written\r", pro_name 
End

//Macro Save_Analysis(analysis_name)
//	String analysis_name
//	write_analysis(analysis_name)
//End
	
Function Save_Analysis()

	SVAR analysis_string
	NVAR pro_path=pro_path
	variable ref, analysis_string_size
	string analysis_name
	encode_analysis()
	analysis_string_size = strlen(analysis_string)
	analysis_name = DoOpenFileDialog(".ana")
	Open /Z ref as analysis_name
	FBinWrite /F=4 ref, analysis_string_size
	FBinWrite ref, analysis_string
	close ref
	Printf "analysis: %s written\r", analysis_name 

//	Open /R/Z/P=pro_path ref, as analysis_name
//	if (V_flag != 0) // does not exist
//		Open /P=pro_path ref, as analysis_name
//		FBinWrite /F=4 ref, analysis_string_size
//		FBinWrite ref, analysis_string
//		close ref
//		Printf "analysis: %s written\r", analysis_name 
//	Endif
//	if (V_flag == 0) // file exists
//		beep; beep; beep
//		DoAlert 1, "over write " + analysis_name +" ?" 
//		if (V_flag == 1) // overwrite file
//			Open /P=pro_path ref, as analysis_name
//			FBinWrite /F=4 ref, analysis_string_size
//			FBinWrite ref, analysis_string
//			close ref
//			Printf "analysis: %s written\r", analysis_name 
//		Else
//			return(0)
//		Endif
//	Endif
End

//Macro load_analysis(analysis_name)
//	String analysis_name
//	read_analysis(analysis_name)
//End

 function Read_Analysis()
	NVAR pro_path
	variable ref, analysis_string_size
	string analysis_name = ""
	SVAR analysis_string
//	tempstr = ""
//	protocol = ""
	Open /T=".ana"/R/P=pro_path ref as analysis_name
//	Open /T=".ana"/R/M=analysis_name/P=pro_path ref
	FStatus ref
	if (V_flag == 0)
		beep; beep; beep
		printf "analysis not loaded\r"
		Return(0)
	Endif
	FBinRead /F=4 ref, analysis_string_size
	analysis_string = PadString(analysis_string, analysis_string_size, 0)
	FBinRead ref, analysis_string
	decode_analysis()
End


Function save_a_scheme(CntrlName) : ButtonControl
	String CntrlName
	string scheme_name = ""
	Execute("Save_Scheme()")
End

//Macro Save_Scheme(Scheme_name)
//	String scheme_name
//	write_scheme(scheme_name)
//End
	
Function Save_Scheme()
	String scheme_name

	String scheme_str = ""
	NVAR pro_path
	variable ref, scheme_size
	
	scheme_str = encode_scheme()
	scheme_size = strlen(scheme_str)
	scheme_name = DoOpenFileDialog(".sch")
	Open /Z ref, as scheme_name
//	if (V_flag != 0) // does not exist
//		Open /P=pro_path ref, as scheme_name
		FBinWrite /F=4 ref, scheme_size
		FBinWrite ref, scheme_str
		close ref
		Printf "scheme: %s written\r", scheme_name 
//	Endif
//	if (V_flag == 0) // file exists
//		beep; beep; beep
//		DoAlert 1, "over write " + scheme_name +" ?" 
//		if (V_flag == 1) // overwrite file
//			Open /P=pro_path ref, as scheme_name
//			FBinWrite /F=4 ref, scheme_size
//			FBinWrite ref, scheme_str
//			close ref
//			Printf "scheme: %s written\r", scheme_name 
//		Else
//			return(0)
//		Endif
//	Endif
End





function /S Read_Protocol(protocol_name)
	String protocol_name
	NVAR pro_path=pro_path
	variable ref, protocol_size
	string protocol, tempstr
	tempstr = ""
	protocol = ""
	Open /T="****"/R/P=pro_path ref as protocol_name
	FStatus ref
	if (V_flag == 0)
		beep; beep; beep
		printf "Protocol not loaded\r"
		Return("")
	Endif
	FBinRead /F=4 ref, protocol_size
	protocol = PadString(protocol, protocol_size, 0)
	FBinRead ref, protocol
	Return(protocol)
End

function /S Read_Scheme(scheme_name)
	String scheme_name
	NVAR pro_path=pro_path
	variable ref, scheme_size
	string scheme, tempstr
	tempstr = ""
	scheme = ""
	Open /T="****"/R/P=pro_path ref as scheme_name
	FStatus ref
	if (V_flag == 0)
		beep; beep; beep
		printf "Scheme not loaded\r"
		Return("")
	Endif
	FBinRead /F=4 ref, scheme_size
	scheme = PadString(scheme, scheme_size, 0)
	FBinRead ref, scheme
	Return(scheme)
End


//function Make_a_Scheme(CntrlName) : ButtonControl
//	String CntrlName
//	SVAR scheme=scheme
//	scheme = encode_scheme()
//	Dowindow /K Scheme_Panel
//End


function get_protocols(scheme)
	String scheme
	WAVE protocols=protocols
End

// change an amplitude of a channel in a scheme
function CP(CntrlName) : ButtonControl
	String CntrlName
	NVAR chan_to_change, old_amp0, old_amp1, old_amp2, old_amp3
	SVAR scheme, seq_in, protocol
	NVAR number_of_pro, freq
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR dac0_pulse_num,dac1_pulse_num,dac2_pulse_num,dac3_pulse_num,ttl1_pulse_num
	WAVE dac0_amp
	WAVE dac1_amp
	WAVE dac2_amp
	WAVE dac3_amp
	WAVE adc0, adc0_avg,adc1,adc1_avg,adc2,adc2_avg,adc3,adc3_avg
	string seq_0
	variable i, j
	variable chan_temp, old_amp, new_amp
	string pro_name
	chan_temp = chan_to_change
	Prompt  chan_temp, "Enter channel to change: "		// Set prompt for x param
	DoPrompt "Channel to Change", chan_temp 
	chan_to_change = chan_temp
	Switch(chan_to_change)
		Case 0:
			old_amp = old_amp0
			Break
		Case 1:
			old_amp = old_amp1
			Break
		Case 2:
			old_amp = old_amp2
			Break
		Case 3:
			old_amp = old_amp3
			Break
	EndSwitch
	new_amp = old_amp
	Prompt old_amp, "Enter amplitude to change: "		// Set prompt for y param
	Prompt new_amp, "Enter new amplitude: "		// Set prompt for y param
	DoPrompt "Change amplitude in Scheme", old_amp, new_amp
	if (V_Flag)
		return -1		// User canceled
	endif
// check for consitency across protocols	
	protocol = encode_pro() // save current loaded protocol
	variable start_flag = 1
	for (i = 0; i < number_of_pro; i += 1)
		if (start_flag == 0) // first make changes to currently loaded protocol
			SVAR pro = $("pro_" + num2str(i))
			pro_name = "pro_" + num2str(i)
			decode_pro(pro_name)
		endif
		if ((dac0_status == 1) && (chan_to_change == 0))
			for(j = 0; j < dac0_pulse_num; j += 1)
				printf "2, amp: %f\r", dac0_amp[j]
				if (dac0_amp[j] == old_amp)
					dac0_amp[j] = new_amp
				Endif
				printf "2, amp: %f\r", dac0_amp[j]
			EndFor
		EndIf
		if (chan_to_change == 1)
			for(j = 0; j < dac1_pulse_num; j += 1)
				if (dac1_amp[j] == old_amp)
					dac1_amp[j] = new_amp
				Endif
			EndFor
		EndIf
		if (chan_to_change == 2)
			for(j = 0; j < dac2_pulse_num; j += 1)
				if (dac2_amp[j] == old_amp)
					dac2_amp[j] = new_amp
				Endif
			EndFor
		EndIf
		if (chan_to_change == 3)
			for(j = 0; j < dac3_pulse_num; j += 1)
				if (dac3_amp[j] == old_amp)
					dac3_amp[j] = new_amp
				Endif
			EndFor
		EndIf
		if (start_flag)
			protocol = encode_pro()
			start_flag = 0
		Else
			pro = encode_pro()
		Endif
	EndFor
	scheme = encode_scheme()
	Switch(chan_to_change)
		Case 0:
			old_amp0 = new_amp
			Break
		Case 1:
			old_amp1 = new_amp
			Break
		Case 2:
			old_amp2 = new_amp
			Break
		Case 3:
			old_amp3 = new_amp
			Break
	EndSwitch
	decode_pro("protocol") // now load the modified previously loaded protocol 
End

// change holding potential of a channel in a scheme
function CallCH()
	CH("")
End
function CH(CntrlName) : ButtonControl
	String CntrlName
	NVAR chan_to_change
	SVAR scheme, seq_in
	NVAR number_of_pro, freq
	NVAR hp0, hp1, hp2, hp3
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	string seq_0
	variable i, j
	variable chan_temp, new_hp
	string pro_name
	chan_temp = chan_to_change
	Prompt  chan_temp, "Enter DAC HP to change: "		// Set prompt for x param
	DoPrompt "DAC HP to Change", chan_temp 
	chan_to_change = chan_temp
	Prompt new_hp, "Enter new HP: "		// Set prompt for y param
	DoPrompt "Enter new HP",  new_hp
	if (V_Flag)
		return -1		// User canceled
	endif
// check for consitency across protocols	
	for (i = 0; i < number_of_pro; i += 1)
		SVAR pro = $("pro_" + num2str(i))
		pro_name = "pro_" + num2str(i)
		decode_pro(pro_name)
		if ((dac0_status == 1) && (chan_to_change == 0))
			hp0 = new_hp
			set_hp(0,hp0)
		EndIf
		if (chan_to_change == 1)
			hp1 = new_hp
			set_hp(1,hp1)
		EndIf
		if (chan_to_change == 2)
			hp2 = new_hp
			set_hp(2,hp2)
		EndIf
		if (chan_to_change == 3)
			hp3 = new_hp
			set_hp(3, hp3)
		EndIf
		pro = encode_pro()
	EndFor
	scheme = encode_scheme()
End





function Check_Scheme()
	String CntrlName
	NVAR chan_to_change, old_amp0, old_amp1, old_amp2, old_amp3
	SVAR scheme, seq_in
	NVAR number_of_pro, freq, samples, requested
	NVAR cont_multi_flag, continuous_flag, MaxSamples
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR dac0_vc, dac1_vc, dac2_vc, dac3_vc
	NVAR dac0_pulse_num,dac1_pulse_num,dac2_pulse_num,dac3_pulse_num,ttl1_pulse_num
	WAVE dac0_amp
	WAVE dac1_amp
	WAVE dac2_amp
	WAVE dac3_amp
	WAVE adc0, adc0_avg,adc1,adc1_avg,adc2,adc2_avg,adc3,adc3_avg
	string seq_0
	variable i, j
	variable dac0_vc_first, dac1_vc_first, dac2_vc_first, dac3_vc_first
	variable freq_first, samples_first
	string pro_name
//	Prompt  chan_temp, "Enter channel to change: "		// Set prompt for x param
//	DoPrompt "Channel to Change", chan_temp 
//	Prompt old_amp, "Enter amplitude to change: "		// Set prompt for y param
//	Prompt new_amp, "Enter new amplitude: "		// Set prompt for y param
//	DoPrompt "Change amplitude in Scheme", old_amp, new_amp
//	if (V_Flag)
//		return -1		// User canceled
//	endif


// check for consistency across protocols	
	decode_pro("pro_0")
	variable numberOfChannels, samp_multiplier, total_samp, max_allowed
	if ((continuous_flag == 1) || (cont_multi_flag == 1))
		samp_multiplier = 2
	Else
		samp_multiplier = 1
	Endif
	numberOfChannels = strlen(seq_in)
	total_samp = MaxSamples/(numberOfChannels * samp_multiplier)
	max_allowed = MaxSamples/(numberOfChannels*samp_multiplier)
	if ((numberOfChannels * samples  * samp_multiplier) > MaxSamples)
			printf "Scheme error! maximum number of samples: %.0f\r", total_samp
			Prompt  max_allowed, "SCHEME ERROR: too many samples "
			DoPrompt "Maximum samples allowed: ", max_allowed

	EndIf
	seq_0 = seq_in
	dac0_vc_first = dac0_vc
	dac1_vc_first = dac1_vc
	dac2_vc_first = dac2_vc
	dac3_vc_first = dac3_vc
	freq_first = freq
	samples_first = samples
	for (i = 0; i < number_of_pro; i += 1)
//		SVAR pro = $("pro_" + num2str(i))
		pro_name = "pro_" + num2str(i)
		decode_pro(pro_name)
		if (stringmatch(seq_in, seq_0) != 1)
			printf "Scheme ERROR: seq=%s\r", seq_in
			Prompt  i, "SCHEME ERROR: Sequence changed in protocol "
			DoPrompt "Change of sequence in pro:", i
		Endif
		if ((dac0_vc != dac0_vc_first) || (dac1_vc != dac1_vc_first) || (dac2_vc != dac2_vc_first) || (dac3_vc != dac3_vc_first))
			printf "Scheme error! Mode change\r"
			Prompt  i, "SCHEME ERROR: Mode changed in protocol "
			DoPrompt "Change of mode in protocol: ", i
		Endif
		if (samples != samples_first)
			printf "Scheme ERROR: samples=%.0f\r", samples
			Prompt  i, "SCHEME ERROR: Samples changed in protocol "
			DoPrompt "Change of number of samples in pro:", i
		Endif
		if (freq != freq_first)
			printf "Scheme ERROR: frequency=%f\r", freq
			Prompt  i, "SCHEME ERROR: frequecny changed in protocol "
			DoPrompt "Change of frequency in pro:", i
		Endif
		if (requested < 0)
			printf "Scheme ERROR: requested=%.0f\r", requested
			Prompt  i, "SCHEME ERROR: requested < 0  in protocol: "
			DoPrompt "requested < 0 in a protocol:", i
		Endif

	EndFor
	decode_pro("pro_0") // reset to the first protocol
	set_stim()
End






function write_minis(CntrlName) : ButtonControl
	String CntrlName
	variable ADCchan
	Prompt ADCchan,"enter ADC channel number"
	DoPrompt "Enter ADC channel number: ", ADCchan
	if (V_flag )
		Return(0)
	EndIf
	NVAR write_datapath, bin_header_length, total_header_size
	SVAR comment, comment2, header_string, write_file_name, last_modified, saved_version,seq_in,seq_out
	NVAR write_permit, write_file_open,acquired,total_chan_num, adc1_index, adc_gain1, adc0_index, adc_gain0, adc2_index, adc_gain2, adc3_index, adc_gain3
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	NVAR dac0_status, dac1_status, dac2_status, dac3_status
	NVAR samples, mini_trace_points
	NVAR header_string_size, header_wave_size
	WAVE header_wave
	samples = mini_trace_points
	variable i, mini_file_ref, adc_gain
	Open /D/T="????"/P=write_datapath mini_file_ref
	Open /Z/P=write_datapath mini_file_ref, as S_fileName
	make /O/W/N=(mini_trace_points) datawave 
	total_chan_num = 1 // only one channel is saved
	seq_in = num2str(ADCchan)
	seq_out = num2str(ADCchan)
	adc_status0 = 0
	adc_status1 = 0
	adc_status2 = 0
	adc_status3 = 0
	Switch(ADCchan)
		case 0:
			acquired = adc0_index
			adc_gain = adc_gain0
			adc_status0 = 1
			break
		case 1:
			acquired = adc1_index
			adc_gain = adc_gain1
			adc_status1 = 1
			break
		case 2:
			acquired = adc2_index
			adc_gain = adc_gain2
			adc_status2 = 1
			break
		case 3:
			acquired = adc3_index
			adc_gain = adc_gain3
			adc_status3 = 1
			break			
	EndSwitch
	write_mini_header(mini_file_ref)
	WAVE mini_wave = $("adc"+num2str(ADCchan)+"_mini_wave")
	mini_wave *= (3.2*adc_gain)
	FbinWrite /F=2 mini_file_ref, mini_wave
//	Endfor
//	for (i=0; i < acquired; i = i +1)
//		WAVE tmpw = $("root:minis:adc"+num2str(ADCchan) + "_mini_" + num2str(i))
//		datawave = tmpw * (3.2 * adc_gain)
//		FbinWrite /F=2 mini_file_ref, datawave
//	Endfor
	close(mini_file_ref)
End	



function write_mini_header(mini_file_ref)
	variable mini_file_ref
	SVAR header_string
	SVAR seq_in
	NVAR header_string_size, header_wave_size,datesecs
	WAVE header_wave
	datesecs = DateTime
	header_string = encode_header()
	header_string_size = strlen(header_string)
	FBinWrite /F=4 mini_file_ref, header_string_size
	FBinWrite /F=4 mini_file_ref, header_wave_size
	FBinWrite mini_file_ref, header_string
	FBinWrite /F=4 mini_file_ref, header_wave
	print_header()
End


function MakeDataFile()
    // A data file has to be open with the write permit checked
    // ROIdfofStr has to be defined and ROI traces loaded
    variable num_traces, i
     NVAR total_chan_num 
     NVAR freq
      NVAR samples
      NVAR adc_gain0
      WAVE /T ROIdfofStr
        
        num_traces = numpnts(ROIdfofStr)
        
       // Make /W/O/N=1000 wave1, wave2, wave3 // Normally you would load these waves before running the function so you need to declare them as global 
//      waves as shown below
//      WAVE wave1, wave2, wave3 // if the ROIs names have an index we can write a loop to declare a large number of waves.
        // It would be useful to have a string with the names of the ROIs that can be parsed. This string can be an input to the function. 
        // wave1 = gnoise(1)*4096 // this is just for illustration
         //wave2 = gnoise(1)*4096
         //wave3 = gnoise(1)*4096
         // Now set the relevant variables
         // this has to be done before writing the first sweep 
         total_chan_num = 1
         freq = 0.02 // in kHz
         samples = 1000 // frames
         adc_gain0 = 1
        // now write the binary data which has to be 16 bit signed integer.
        for(i = 0; i < num_traces; i = i+1) 
            Duplicate /o $ROIdfofStr[i], trace
            trace *= 3.2 // to preserve amplitude when reading binary data
            write_sweep(trace)
        endfor
        close_write_file("")
End

Function D_Create()
	String pathName		// Name of symbolic path or "" for dialog.
	String fileName		// File name, partial path, full path or "" for dialog.
	Variable refNum
	String str
	filename="my_ini.txt"
	Open /T=".txt" refNum as fileName
	printf "ref: %d, file name: %s\r", refNum, S_fileName
	Close refNum
	return 0
End

Function InitFromFile(InitFileName)
	string InitFileName
	Variable refNum, lineNumber, len, tmpVar
	NVAR amp_type, risePoints, TraceOffset, jumpTime_0, jumpTime_1, jumpTime_2, jumpTime_3 
	NVAR slope_0, slope_1, slope_2, slope_3
	NVAR MaxSamples
	NVAR event_max
	String str
	// Open file for read.
	
	Open /Z/T=".txt" /R /P=$"pro_path" refNum as  InitFileName//"Acquire_Init.txt"
	lineNumber = 0
	do
		FReadLine refNum, str
		len = strlen(str)
		if (len == 0)
			break						// No more lines to be read
		endif
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////
		tmpVar = NumberByKey("MaxSamples", str)	
		if (numtype(tmpVar) == 0)
			MaxSamples = tmpVar
		Endif
		tmpVar = NumberByKey("amp_type", str)
		if (numtype(tmpVar) == 0)
			amp_type = tmpVar
		Endif
		tmpVar = NumberByKey("event_max", str)
		if (numtype(tmpVar) == 0)
			event_max = tmpVar
		Endif
		tmpVar = NumberByKey("risePoints", str)	
		if (numtype(tmpVar) == 0)
			risePoints = tmpVar
		Endif
		tmpVar = NumberByKey("TraceOffset", str)	
		if (numtype(tmpVar) == 0)
			TraceOffset = tmpVar
		Endif
		tmpVar = NumberByKey("jumpTime_0", str)	
		if (numtype(tmpVar) == 0)
			jumpTime_0 = tmpVar
		Endif
		tmpVar = NumberByKey("jumpTime_1", str)	
		if (numtype(tmpVar) == 0)
			jumpTime_1 = tmpVar
		Endif
		tmpVar = NumberByKey("jumpTime_2", str)	
		if (numtype(tmpVar) == 0)
			jumpTime_2 = tmpVar
		Endif
		tmpVar = NumberByKey("jumpTime_3", str)	
		if (numtype(tmpVar) == 0)
			jumpTime_3 = tmpVar
		Endif
		tmpVar = NumberByKey("slope_0", str)	
		if (numtype(tmpVar) == 0)
			slope_0 = tmpVar
		Endif
		tmpVar = NumberByKey("slope_1", str)	
		if (numtype(tmpVar) == 0)
			slope_1 = tmpVar
		Endif
		tmpVar = NumberByKey("slope_2", str)	
		if (numtype(tmpVar) == 0)
			slope_2 = tmpVar
		Endif
		tmpVar = NumberByKey("slope_3", str)	
		if (numtype(tmpVar) == 0)
			slope_3 = tmpVar
		Endif

/////////////////////////////////////////////////////////////////////////////////////////////////////////
		lineNumber += 1
	while (1)

	Close refNum
	return 0
End



function CCh(CntrlName) : ButtonControl
	String CntrlName
	SVAR scheme, seq_in
	NVAR number_of_pro, freq
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR dac0_pulse_num,dac1_pulse_num,dac2_pulse_num,dac3_pulse_num,ttl1_pulse_num
	WAVE dac0_start, dac0_end, dac0_amp
	WAVE dac1_start, dac1_end, dac1_amp
	WAVE dac2_start, dac2_end, dac2_amp
	WAVE dac3_start, dac3_end, dac3_amp
	Make /O/N=1000 first_start, second_start, first_end, second_end, first_amp, second_amp
	string seq_0
	variable i, j
	variable first_chan, second_chan, first_pulse_num, second_pulse_num
	string pro_name
	Prompt  first_chan, "Enter first DAC : "		// Set prompt for x param
	DoPrompt "Enter First DAC ", first_chan
	Prompt second_chan, "Enter second DAC: "		// Set prompt for y param
	DoPrompt "Enter second DAC",  second_chan
	if (V_Flag)
		return -1		// User canceled
	endif
//printf "first: %f, second: %f\r", first_chan, second_chan	
	for (j = 0; j < number_of_pro; j += 1)
		SVAR pro = $("pro_" + num2str(j))
		pro_name = "pro_" + num2str(j)
		decode_pro(pro_name)
		if (dac0_status == 1)
			if (first_chan == 0)
				first_pulse_num = dac0_pulse_num
//				printf "first_pulse_num = %f\r", first_pulse_num
				For (i = 0; i < dac0_pulse_num; i  += 1)
					first_start[i] =dac0_start[i]
					first_end[i] =dac0_end[i]
					first_amp[i] = dac0_amp[i]
				EndFor
			Endif
			if (second_chan == 0)
				second_pulse_num = dac0_pulse_num
				For (i = 0; i < dac0_pulse_num; i  += 1)
					second_start[i] =dac0_start[i]
					second_end[i] =dac0_end[i]
					second_amp[i] = dac0_amp[i]
				EndFor
			Endif
		EndIf
		if (dac1_status == 1)
			if (first_chan == 1)
				first_pulse_num = dac1_pulse_num
				For (i = 0; i < dac1_pulse_num; i  += 1)
					first_start[i] =dac1_start[i]
					first_end[i] =dac1_end[i]
					first_amp[i] = dac1_amp[i]
				EndFor				
			Endif
			if (second_chan == 1)
				second_pulse_num = dac1_pulse_num
				For (i = 0; i < dac1_pulse_num; i  += 1)
					second_start[i] =dac1_start[i]
					second_end[i] =dac1_end[i]
					second_amp[i] = dac1_amp[i]
				EndFor
			Endif
		EndIf
		if (dac2_status == 1)
			if (first_chan == 2)
				first_pulse_num = dac2_pulse_num
				For (i = 0; i < dac2_pulse_num; i  += 1)
					first_start[i] =dac2_start[i]
					first_end[i] =dac2_end[i]
					first_amp[i] = dac2_amp[i]
				EndFor
			Endif
			if (second_chan == 2)
				second_pulse_num = dac2_pulse_num
				For (i = 0; i < dac2_pulse_num; i  += 1)
					second_start[i] =dac2_start[i]
					second_end[i] =dac2_end[i]
					second_amp[i] = dac2_amp[i]
				EndFor
			Endif
		EndIf
		if (dac3_status == 1)
			if (first_chan == 3)
				first_pulse_num = dac3_pulse_num
				For (i = 0; i < dac3_pulse_num; i  += 1)
					first_start[i] =dac3_start[i]
					first_end[i] =dac3_end[i]
					first_amp[i] = dac3_amp[i]
				EndFor
			Endif
			if (second_chan == 3)
				second_pulse_num = dac3_pulse_num
//				printf "second_pulse_num : %f\r", second_pulse_num
				For (i = 0; i < dac3_pulse_num; i  += 1)
					second_start[i] =dac3_start[i]
					second_end[i] =dac3_end[i]
					second_amp[i] = dac3_amp[i]
				EndFor
			Endif
		EndIf
	/////////////// now exchange pulse num
		if (dac0_status == 1)
			if (first_chan == 0)
				dac0_pulse_num = second_pulse_num
				For (i = 0; i < dac0_pulse_num; i  += 1)
					dac0_start[i]=second_start[i]
					dac0_end[i]=second_end[i]
					dac0_amp[i]=second_amp[i]
				EndFor
			Endif
			if (second_chan == 0)
				dac0_pulse_num = first_pulse_num
				For (i = 0; i < dac0_pulse_num; i += 1)
					dac0_start[i]=first_start[i]
					dac0_end[i]=first_end[i]
					dac0_amp[i]=first_amp[i]
				EndFor
			Endif
		EndIf
		if (dac1_status == 1)
			if (first_chan == 1)
				dac1_pulse_num = second_pulse_num
				For (i = 0; i < dac1_pulse_num; i  += 1)
					dac1_start[i]=second_start[i]
					dac1_end[i]=second_end[i]
					dac1_amp[i]=second_amp[i]
				EndFor
			Endif
			if (second_chan == 1)
				dac1_pulse_num = first_pulse_num
				For (i = 0; i < dac1_pulse_num; i += 1)
					dac1_start[i]=first_start[i]
					dac1_end[i]=first_end[i]
					dac1_amp[i]=first_amp[i]
				EndFor
			Endif
		EndIf
		if (dac2_status == 1)
			if (first_chan == 2)
				dac2_pulse_num = second_pulse_num
				For (i = 0; i < dac2_pulse_num; i  += 1)
					dac2_start[i]=second_start[i]
					dac2_end[i]=second_end[i]
					dac2_amp[i]=second_amp[i]
				EndFor
			Endif
			if (second_chan == 2)
				dac2_pulse_num = first_pulse_num
				For (i = 0; i < dac2_pulse_num; i += 1)
					dac2_start[i]=first_start[i]
					dac2_end[i]=first_end[i]
					dac2_amp[i]=first_amp[i]
				EndFor
			Endif
		EndIf
		if (dac3_status == 1)
			if (first_chan == 3)
				dac3_pulse_num = second_pulse_num
				For (i = 0; i < dac3_pulse_num; i  += 1)
					dac3_start[i]=second_start[i]
					dac3_end[i]=second_end[i]
					dac3_amp[i]=second_amp[i]
				EndFor
			Endif
			if (second_chan == 3)
				dac3_pulse_num = first_pulse_num
				For (i = 0; i < dac3_pulse_num; i += 1)
					dac3_start[i]=first_start[i]
					dac3_end[i]=first_end[i]
					dac3_amp[i]=first_amp[i]
				EndFor
			Endif
		EndIf
		pro = encode_pro()
	EndFor
	scheme = encode_scheme()
End
