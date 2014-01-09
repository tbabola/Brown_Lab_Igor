#pragma rtGlobals=1		// Use modern global access method
#include "acquire_analysis"
#include "acquire_files"
#include "acquire_acquisition"
#include "acquire_display"
#include "spb_graphs"
#include "spb_photofluorcontrol" //added June 1, 2012 to control the photofluor via COM5
#include "RR_graph" //added June 8, 2012 by RR to show four individual avarages during photofluor scheme
#include "RR_prints" //added June 15, 2012 by RR to prepare printout

function init_all()
//	string /g InitFileName = "Acquire_Init.txt"
	NVAR init_analysis=init_analysis
	Execute("init_parameters()")
	init_daq_parameters()
//	printf "init_all(): init_analysis=%d\r", init_analysis
	init_graphs()
	Execute("init_panels()")
//	printf "init_all() 2: init_analysis=%d\r", init_analysis
End

function Init_parameters()


// ---------------------------------   file related parameters -------------------------
	string /g last_modified = "November-8-2007"
	Make /O/T ROIdfofStr //Text wave to contain the names of calcium transient ROIs 
	Make /O/N=1000 ROI_Trace
	variable /g MaxSamples = 1024000 // 
	variable /g micros, ref1 = StartMSTimer
	variable /g start_time
	variable /g check = 1 // if 1 update checkboxes
	variable /g pro_running
	variable /g ptime=0 // pausing during averaging 
	variable /g current_time
	string /g saved_version = last_modified // save current version in header
	variable /g init_display = 1 // if : 1 init display
	variable /g old_files = 0 // to read old style data files
	variable /g concat = 0 // if =1 concatenate traces into concat_0, concat_1 ...
	string /g scheme = ""
	variable /g CurrentProNumber = 0 // the current protocol in scheme
	string /g read_file_name = ""
	string /g write_file_name = "temp_file.000"
	variable /g read_datapath
	NewPath /Q/O read_datapath "C:data"
	variable /g read_file_open = 0
	variable /g stim_file_open = 0
	variable /g write_datapath
	NewPath /Q/O write_datapath "C:data"
	variable /g pro_path
	NewPath /Q/O pro_path "C:data:protocols"
	variable /g bin_header_length
	variable /g total_header_size
	variable /g line_size = 0.9 // used to draw traces
	variable /g draw_flag = 0
	string /g comment = ""
	string /g comment2 = ""
	variable /g ttl_num = 1
	variable /g   write_permit = 0
	variable /g write_file_open  = 0// =1 if open 0 if not
	variable /g acquired = 0// written in the file
	variable /g read_file_ref	
	variable /g write_file_ref
	string /g pro_name = "" // to hold the name of the currently loaded protocol name
	string /g header_string = ""
	variable /g header_string_size = 0
	Make /O/N=1 header_wave // for future binary header stuff
	variable /g header_wave_size = 1
//----------------------------------------------------------------------------------------------
	variable /g acquire_mode = 0
	variable /g average_sweeps = 0 // used when alternating and averaging
	variable /g corr_num = 1024 // used for cross and auto correlation
	variable /g corr_start = 0
	string /g srcWave_0 = "adc0" // first wave for correlation
	string /g srcWave_1 = "adc0" 
	string /g ZoomWindow = "points_0_display" // which window should be zoomed
	variable /g end_analysis = 0
	variable /g segPoints = 1000 // for power spectra
	variable /g segNum = 1
	variable /g sub_trend = 0
	string /g spike_detection_trace_name = "adc0"
	string /g analyzed_trace = "adc0"
	string /g fit_trace_name = "adc0"
	string /g align_trace_name = "adc1"
	string /g amp_trace_name = "adc0"
	variable /g Scale_to_Vis = 0 // if set autoscale visible portion of traces
	variable /g cc_stim_amp=500, cc_stim_duration=30
	variable /g pre_chan=1, poisson_scale=1, pulse_num=1, pulse_inter=100, pulse_start=2500
	variable /g comment_length, sequence_length
	variable /g spike_thresh = -20, spike_duration = 20, analysis_start = 500, analysis_end = 4500
	variable /g bin_size = 10
	variable /g trace_num=0
	variable /g keepADC0 = 0
	variable /g keepADC1 = 0
	variable /g keepADC2 = 0
	variable /g keepADC3 = 0
	variable /g disp_0 = 1
	variable /g disp_1 = 0
	variable /g disp_2 = 0
	variable /g disp_3 = 0
	variable /g trace_start = 0
	variable /g trace_end = 0
	variable /g trace_total = 0
	variable /g update = 1
	variable /g bin_type = 10 // if 1 then xyplot
	variable /g spike_num
	variable /g total_spikes
// these are for function condense	
	variable /g start0_cond = 0
	variable /g end0_cond = 100
	variable /g num_cond = 5
	variable /g flag_cond = 1
// mini analysis globals
	NewDataFolder /O root:minis
	NewDataFolder /O root:avg
	variable /g adc0_index = 0
	variable /g adc1_index = 0
	variable /g adc2_index = 0
	variable /g adc3_index = 0 //added by SPB 4-30-07 for mini_analysis of adc3
	variable /g adc0_index_f = 0
	variable /g adc1_index_f = 0
	variable /g adc2_index_f = 0
	variable /g adc3_index_f = 0 //added by SPB 4-30-07 for mini_analysis of adc3
	variable /g miniFlag = 0
	variable /g miniDuration = 0 //  window in ms beyond peak for which mean is larger than peak/2
	//SPB added all the _3 4-30-2007 for mini_analysis
	variable /g mode_0 = 0, mode_1 = 0, mode_2 = 0, mode_3 = 0
	variable /g risePoints = 4 // used to fit the rise phase +/- around the midpoint
	variable /g searchStart_0 = 0, searchStart_1 = 0, searchStart_2 = 0, searchStart_3 = 0 //SPB added searchStart_3 4-30-07 for mini analysis
	variable /g searchEnd_0 = 1000, searchEnd_1 = 1000, searchEnd_2 = 1000, searchEnd_3 = 1000 //SPB added searchEnd_3 4-30-07 for mini analysis
	variable /g blTime_0 = 2.0,  blTime_1 = 2.0,  blTime_2 = 2.0, blTime_3 = 2.0 // ms
	variable /g LAtime_0 = 2.0, LAtime_1 = 2.0 , LAtime_2 = 2.0, LAtime_3 = 2.0 // ms
	variable /g Threshold_0 = 0.275, Threshold_1 = 0.275, Threshold_2 = 0.275, Threshold_3 = 0.275 // in real units e.g., mV
	variable /g jumpTime_0 = 2.0,  jumpTime_1 = 2.0,  jumpTime_2 = 2.0, jumpTime_3 = 2.0 // jump in ms from start of last event (or end of baseline if rejected event) in ms
	variable /g peakWindowTime_0 = 5.0, peakWindowTime_1 = 5.0,  peakWindowTime_2 = 5.0, peakWindowTime_3 = 5.0
	 variable /g num_prior_traces = 0 // when analyzing multiple files
	variable /g slope_0 = 10, slope_1 = 10, slope_2 = 10, slope_3 = 10 // reject events on slope of baseline	 
	 //Solange
//	variable /g slope_0 = 0.08, slope_1 = 0.08, slope_2 = 0.08 // reject events on slope of baseline
	variable /g autoFlag = 0 // if = 1 do not ask user
	variable /g over_ride_init = 0 // when switching files
	variable /g event_max = 1000 // in detectminis to reject events larger than event_max
	// Solange
	//variable /g event_max = 3 // in detectminis to reject events larger than event_max
	variable /g TraceOffSet = 4000.0 // to mark different traces in table entry of mini time
	variable /g Table_chan = 0 // used to extract columns out of Minis table
	variable /g Table_cnum = 1
	
	Make /O/D/N=(100000,4) Mini_adc0 = NaN
	Make /O/D/N=(100000,4) Mini_adc1 = NaN
	Make /O/D/N=(100000,4) Mini_adc2 = NaN // first column: time, second column: amplitude, third column rise time, fourth slope
	Make /O/D/N=(100000,4) Mini_adc3 = NaN // first column: time, second column: amplitude, third column rise time, fourth slope
	Make /O/D/N=100 results // 0: start, 1: amp
	DoWindow /K Mini_Table
	Edit Mini_adc0,Mini_adc1,Mini_adc2, Mini_adc3
	DoWindow /C Mini_Table
	// final minis
	Make /O/D/N=(100000,4) Mini_adc0_f = NaN
	Make /O/D/N=(100000,4) Mini_adc1_f = NaN
	Make /O/D/N=(100000,4) Mini_adc2_f = NaN // first column: time, second column: amplitude, third column rise time
	Make /O/D/N=(100000,4) Mini_adc3_f = NaN // first column: time, second column: amplitude, third column rise time
	Make /O/D/N=100 results // 0: start, 1: amp
	DoWindow /K Mini_Table_f
	Edit Mini_adc0_f,Mini_adc1_f,Mini_adc2_f,Mini_adc3_f
	DoWindow /C Mini_Table_f
	
//---------------------------------------------	
	variable /g mini_panel_display_flag = 0
	Make /o/n=1000 ExcludeList = NaN
	variable /g ExcludeIndex = 0 // the current index of DonotIncludeList  
	variable /g discriminate = 0
	variable /g dac_num = 0
	variable /g spike_end = 0
	variable /g spike_start = 0
	variable /g beforeSpike = 100
	variable /g afterSpike = 0
	variable /g traces_analyzed=0
	variable /g align_flag = 0
	variable /g align_index = 0
	variable /g align_start = 0
	variable /g align_end = 0
	variable /g Amp_bl_start = 0
	variable /g amp_bl_end = 0
	variable /g amp_start = 0
	variable /g amp_end
	 variable /g chan_to_change, old_amp0, old_amp1, old_amp2, old_amp3, new_amp // to change amplitude in a whole scheme
	variable /g interactive = 1
	variable/g x_window = 100 // for correlation window in ms when freq = 10
	Make /O/N=1 psth, histog_vm
	Make /O/N=1000 adc0=0, adc1=0, adc2=0, adc3=0
	Make /O/N=1000 adc0_avg_0=0, adc1_avg_0=0, adc2_avg_0=0, adc3_avg_0=0
	variable /g mini_trace_points = 2000
//	Make /O/N=(mini_trace_points*10000) adc0_mini_wave = 0
//	Make /O/N=(mini_trace_points*10000) adc1_mini_wave = 0
//	Make /O/N=(mini_trace_points*10000) adc2_mini_wave = 0
//	Make /O/N=(mini_trace_points*10000) adc3_mini_wave = 0
//	Make /O/N=(mini_trace_points) temp_mini_wave = 0 
	variable /g keep_minis = 0 // if =1 make a copy of a portion of the trace
	variable /g mini_pre_points = 200
	Make /O/N=(mini_trace_points) adc0_mini_avg=0, adc1_mini_avg=0, adc2_mini_avg=0, adc3_mini_avg = 0 // average minis ,  //SPB added 4-30-07
	Make /O/N=(mini_trace_points) adc0_mini_avg_temp=0, adc1_mini_avg_temp=0, adc2_mini_avg_temp=0, adc3_mini_avg_temp// average minis ,  //SPB added 4-30-07
	variable /g mini_num_0 = 0
	variable /g mini_num_1 = 0
	variable /g mini_num_2 = 0
	variable /g mini_num_3 = 0  //SPB added 4-30-07
	variable /g miniDrawPre = 10
	variable /g miniDrawPost = 20
	string /g analysis_string = "" // used to encode the analysis parameters
	variable /g analysis_num = 0 // the number of the analysis  
	variable/g Analysis_Max = 10
	string /g InitFileName = "Acquire_Init.txt"
	SVAR InitFileName
	
//********************** Standard, Axopatch200B **********************************************************

	variable /g amp_type = 0 // 0: Axopatch200A/B; 1: MultiClamp 700A/B
	Make /O/N=(Analysis_Max) amp_analysis_mode_wave = 0 // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	Make /O/T/N=(Analysis_Max) analysis_trace_name_wave = "adc0" // names of traces to analyse
	Make /O/N=(Analysis_Max) amp_bl_start_wave = 0
	Make /O/N=(Analysis_Max) amp_bl_end_wave = 0
	//InitFromFile(InitFileName) //read globals from a text file in C://data/protocols/Acquire_init.txt

//*************************** Solange's, MC700A **************************************************************************
//	variable /g amp_type = 1		// MC700A/B
//	Make /O/N=(Analysis_Max) amp_analysis_mode_wave = {10,10,10,0,0,0,0,0,0,0} // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
//	Make /O/T/N=(Analysis_Max) analysis_trace_name_wave = {"adc0","adc1","adc2","adc0","adc0","adc0","adc0","adc0","adc0","adc0"}// names of traces to analyse
//	Make /O/N=(Analysis_Max) amp_bl_start_wave = {10,10,10,0,0,0,0,0,0,0}
//	Make /O/N=(Analysis_Max) amp_bl_end_wave = {20,20,20,0,0,0,0,0,0,0}


//***************************************************************************************************************************
	Make /O/N=(Analysis_Max) amp_end_wave = 0	
	Make /O/N=(Analysis_Max) amp_start_wave = 0
	Make /O/N=(Analysis_Max) analysed_points_wave = 0 // the number of points analysed in the amp_points waves
	Make /O/N=(Analysis_Max) amp_analysis_flag_wave = 0 // if 1 do analysis
	Make /O/N=(Analysis_Max) amp_analysis_peak_points_wave = 0	
	Make /O/T/N=(Analysis_Max) analysis_trace_name_wave = {"adc0","adc0","adc0","adc0","adc0","adc0","adc0","adc0","adc0","adc0"}
//	amp_analysis_flag_wave[0] = 1

	variable i = 0
	string wave_name
	variable points_num = 5000
	Do
		wave_name = ("amp_points_wave_" + num2str(i)) // name of waves holding the analysis results
		Make /O/N=(points_num) $wave_name
		WAVE tempwave = $wave_name
		tempwave = NaN
		i += 1
	While (i < 10)

	


	variable /g amplitude = 0
	variable /g peak = 0
	variable /g peak_dir = -1
	variable /g peak_index = 0
	variable /g peak_points = 0
	variable /g cutoff = 1000
	string /g smooth_trace_name = "adc1"
	variable /g smooth_flag = 0
	variable /g peak_window = 25 // 2.5 ms in 10 KHz 
	variable /g alternate = 1
	variable /g bl_start = 0
	variable /g bl_end = 0
	variable /g f_start = 0
	variable /g f_end = 0
	variable /g tau1 = 0
	variable /g tau2 = 0
	variable /g frac1 = 0
	variable /g frac2 = 0
	variable /g fit_type 
	variable /g bl_avg
	variable /g compare_flag = 0
	variable /g spike_cv = 0
	variable /g spike_cv_flag = 0
	variable /g peak_risetime
	variable /g initialize = 1
	Make /O/N=500 isi_wave
	variable /g peak2peak = 100
	variable /g baseline_points = 3
	variable /g points_to_cross = 10
//	String /g amp_window_name = "G_Traces"
End 

function init_daq_parameters()
	NVAR acquire_mode, amp_type
	variable ag
	if (amp_type == 0)
		ag = 2
	Elseif (amp_type == 1)
		ag = 2.5
	Endif
	variable /g ITC18 = 1 // if :1  run data acquisition (requires ITC18) if 0 use for trouble shooting (w/o ITC18)
	variable /g adc_gain0=ag,adc_gain1=ag,adc_gain2=ag,adc_gain3=ag,adc_gain4=ag,adc_gain5=ag,adc_gain6=ag,adc_gain7=ag
	variable /g adc_status0=1,adc_status1=0,adc_status2=0,adc_status3=0,adc_status4=0,adc_status5=0,adc_status6=0,adc_status7=0
	variable /g smoothAll = 0 // if 1 smooth adc0, adc1, adc2, adc3
	variable /g last_protocol_run_time = 0
	variable /g total_chan_num = 2
	variable /g fake_chan = 0 // to indicate extra dummy channel
	variable /g dac0_vc = 1 // 1 for vc 0 for cc
	variable /g dac0_cc = 0
	variable /g dac1_vc = 1
	variable /g dac1_cc = 0
	variable /g dac2_vc = 1
	variable /g dac2_cc = 0
	variable /g dac3_vc = 1
	variable /g dac3_cc = 0
	variable /g electrode0_res = 0
	variable /g electrode1_res = 0
	variable /g electrode2_res = 0
	variable /g electrode3_res = 0
	string /g seq_in = "0D"
	string /g seq_out = "0D"
	variable /g datesecs = DateTime
	variable /g requested = -1
	variable /g samples = 2000
	variable /g old_samples = 2000
	variable /g analysis_flag = 0
	variable /g histogram_sweeps = 0
	variable /g init_analysis = 1
	variable /g wait = 0
	variable /g pro_wait = 0 // within a protocl
	variable /g freq  = 100.0 // 100.0 KHz
	variable /g period = round(1000/(freq * total_chan_num * 1.25))
	freq = 1000/(period*1.25*total_chan_num) // this may change the frequency to account for rounding
	variable /g pre_chan = 1 // which channel is pre
	variable /g dac0_poisson_scale  = 0 // scaling the poisson stimulation 
	variable /g dac1_poisson_scale  = 0 // scaling the poisson stimulation 
	variable /g dac2_poisson_scale  = 0 // scaling the poisson stimulation 
//	variable /g pulse_num = 1
//	variable /g pulse_inter = 100
//	variable /g pulse_start = 100
	variable /g sampoff = 2
	variable /g cc_stim_amp = 500.0
	variable /g cc_stim_duration = 30.0
	string /g save_file, stim_file
	variable /g recycle_stim = 1
	variable /g syn1_flag = 0
	variable /g syn1_start = 1000
	variable /g syn1_scale = 1
	variable /g stim_start = 0
	variable /g trig_mode = 2 // 2: do not use external trigger; 3: use external trigger 
	variable /g dac0_gain = 50*1.05 // in voltgae clamp of Multiclamp 700A and 200A/B
	variable /g dac1_gain = 50*1.05 // to correct for shunt
	variable /g dac2_gain = 50*1.05
	variable /g dac3_gain = 50*1.05
	variable /g hp0 = 0
	variable /g hp1 = 0 
	variable /g hp2 = 0
	variable /g hp3 = 0 
	variable /g dac0_pulse_num = 1
	variable /g dac1_pulse_num = 1
	variable /g dac2_pulse_num = 1
	variable /g dac3_pulse_num = 1
	variable /g interval_change_0 = 0 // to make a protocol with a changing inter-pulse interval 
	variable /g amp_change_0 = 0 // to make a protocol with changing pulse amplitude
	variable /g interval_change_1 = 0 // to make a protocol with a changing inter-pulse interval 
	variable /g amp_change_1 = 0 // to make a protocol with changing pulse amplitude
	variable /g interval_change_2 = 0 // to make a protocol with a changing inter-pulse interval 
	variable /g amp_change_2 = 0 // to make a protocol with changing pulse amplitude
	variable /g interval_change_3 = 0 // to make a protocol with a changing inter-pulse interval 
	variable /g amp_change_3 = 0 // to make a protocol with changing pulse amplitude

	make_ttl()
	
	
	variable /g dac0_status = 1
	variable /g dac1_status = 0
	variable /g dac2_status = 0
	variable /g dac3_status = 0
	variable /g sweep_time = samples /  freq // in ms
// make 80 waves to be used for averaging 20 protocols
	variable i = 0
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
	variable /g adc0_avg_flag = 1 // as part of a protocol to indicate averaging
	variable /g adc1_avg_flag = 0
	variable /g adc2_avg_flag = 0
	variable /g adc3_avg_flag = 0
// number of sweeps averaged for each protocol up to 20 protocols
	variable /g av_sweeps_0 = 0, av_sweeps_1 = 0, av_sweeps_2 = 0, av_sweeps_3 = 0, av_sweeps_4 = 0, av_sweeps_5 = 0
	variable /g av_sweeps_6 = 0, av_sweeps_7 = 0, av_sweeps_8 = 0, av_sweeps_9 = 0
	variable /g av_sweeps_10 = 0, av_sweeps_11 = 0, av_sweeps_12 = 0, av_sweeps_13 = 0, av_sweeps_14 = 0, av_sweeps_15 = 0
	variable /g av_sweeps_16 = 0, av_sweeps_17 = 0, av_sweeps_18 = 0, av_sweeps_19 = 0	
	make /O/N=(1000) dac0_amp, dac0_start, dac0_end, dac1_amp,dac1_start,dac1_end,dac2_amp,dac2_start,dac2_end, dac3_start, dac3_end,dac3_amp //,ttl1_start, ttl1_end,ttl2_start, ttl2_end
	Make /O/N=(20) scheme_wait = 0
	dac0_amp[0] = 1.0 // mV
	dac0_start[0] = 2.0 // ms 
	dac0_end[0] = 12.0 // ms
	dac1_amp[0] = 1.0 // mV
	dac1_start[0] = 2.0 // ms 
	dac1_end[0] = 12.0 // ms
	dac2_amp[0] = 1.0 // mV
	dac2_start[0] = 2.0 // ms 
	dac2_end[0] = 12.0 // ms
	dac3_amp[0] = 1.0 // mV
	dac3_start[0] = 2.0 // ms 
	dac3_end[0] = 12.0 // ms
	make /O /N=(samples*total_chan_num) StimWave
	make /O/N=(samples*total_chan_num) InData
	make /o /n=(samples) Poisson_Stim, stimfile_wave
	make /o /n=(samples) dac0, dac1, dac2, dac3
	make /o /n=(samples) adc0, adc1,adc2,adc3
	SetScale /P x 0, (1.0/freq), "ms", adc0,adc1,adc2,adc3
	SetScale d 0, 0, "pA", adc0, adc1, adc2, adc3 
	Make /o /n=300 detections
	Make /o /n=100000 total_detections
	Make /o /n=1 psth, histog_vm
	String /g protocol = ""
	String /g pro_0 = ""
	String /g pro_1 = ""
	String /g pro_2 = ""
	String /g pro_3 = ""
	String /g pro_4 = ""
	String /g pro_5 = ""
	String /g pro_6 = ""
	String /g pro_7 = ""
	String /g pro_8 = ""
	String /g pro_9 = ""
	String /g pro_10 = ""
	String /g pro_11 = ""
	String /g pro_12 = ""
	String /g pro_13 = ""
	String /g pro_14 = ""
	String /g pro_15 = ""
	String /g pro_16 = ""
	String /g pro_17 = ""
	String /g pro_18 = ""
	String /g pro_19 = ""
	Make /O/N=20 scheme_wait = 0
	variable /g wait_01 = 0
	variable /g wait_lf = 0
	variable /g scheme_on = 0
	variable /g scheme_type = 1
	variable /g scheme_repeat = -1
	variable /g number_of_pro = 2
	variable /g last_number_of_pro = 2
	variable /g dac0_stimfile_flag = 0
	variable /g dac1_stimfile_flag = 0
	variable /g dac2_stimfile_flag = 0
	variable /g dac3_stimfile_flag = 0
	variable /g stimfile_recycle = 0
	variable /g stimfile_loc = 0
	variable /g pro_0_stimfile_loc = 0
	variable /g pro_1_stimfile_loc = 0
	variable /g dac0_stimfile_scale = 1
	variable /g dac1_stimfile_scale = 1
	variable /g dac2_stimfile_scale = 1
	variable /g dac3_stimfile_scale = 1
	variable /g stimwave_scale = 1
	variable /g stimwave_flag = 0
	string /g Stimfile_name = "stim_file.001"
	string /g StimWave_name = "fast_epsc"
	variable /g stimfile_ref = 0
	variable /g his_flag = 0
	variable /g dac0_psc_flag = 0
	variable /g dac1_psc_flag = 0
	variable /g dac2_psc_flag = 0
	variable /g dac1_stimfile_scale = 1
	variable /g dac2_stimfile_scale = 1
	variable /g dac3_stimfile_scale = 1
	variable /g dac0_psc1_taurise = 0.1, dac0_psc2_taurise = 0.1, dac0_psc3_taurise = 0.1
	variable /g dac0_psc1_taudecay = 3, dac0_psc2_taudecay = 3, dac0_psc3_taudecay = 3
	variable /g dac0_psc1_amp = 100, dac0_psc2_amp = 0, dac0_psc3_amp = 0
	variable /g dac0_psc_interval = 500, dac0_psc_start = 1500, dac0_psc_int2 = 500 // in samples 
	variable /g dac1_psc1_taurise = 0.1, dac1_psc2_taurise = 0.1
	variable /g dac2_psc1_taurise = 0.1, dac2_psc2_taurise = 0.1
	variable /g dac3_psc1_taurise = 0.1, dac3_psc2_taurise = 0.1
	variable /g dac1_psc1_taudecay = 3, dac1_psc2_taudecay = 3
	variable /g dac2_psc1_taudecay = 3, dac2_psc2_taudecay = 3
	variable /g dac3_psc1_taudecay = 3, dac3_psc2_taudecay = 3
	variable /g dac1_psc1_amp = 100, dac1_psc2_amp = 0
	variable /g dac2_psc1_amp = 100, dac2_psc2_amp = 0
	variable /g dac3_psc1_amp = 100, dac3_psc2_amp = 0
	variable /g dac1_psc_interval = 50, dac1_psc_start = 1500 // in samples 
	variable /g dac2_psc_interval = 50, dac2_psc_start = 1500 // in samples 
	variable /g dac3_psc_interval = 50, dac3_psc_start = 1500 // in samples 
//	acquire_mode = 0 // 1 for acquisition
	variable /g ttl_status = 1
	Make /O/N=5000 psc
	variable /g sine_flag_dac0=0, sine_flag_dac1=0, sine_flag_dac2=0, sine_flag_dac3=0
	variable /g sine_phase_dac0 = 0, sine_phase_dac1 = 0, sine_phase_dac2 = 0, sine_phase_dac3= 0
	variable /g sine_amp_dac0 = 0, sine_amp_dac1 = 0, sine_amp_dac2 = 0, sine_amp_dac3 = 0
	variable /g sine_freq_dac0 = 0, sine_freq_dac1 = 0, sine_freq_dac2 = 0, sine_freq_dac3 = 0
	variable /g continuous_flag = 0
	variable /g cont_multi_flag = 0 // if 1 multiple protocols in continuous mode
	variable/g cs_1 = -1//
	variable/g cs_0  = -1// when sweeps = continuous_switch_1 switch to pro_1, when sweeps=continuous_swich_0 switch
	variable /g current_pro = 0
	variable /g search_flag = 0
//	variable /g threshold = 0 // daq
	variable /g deriv_thresh = 10
	variable /g align_thresh = 0
	variable /g average_flag = 0
	variable /g cross_flag = 0
	protocol = encode_pro()
	pro_0 = protocol
	pro_1 = protocol
	pro_2 = protocol
	pro_3 = protocol
	pro_4 = protocol
	pro_5 = protocol
	pro_6 = protocol
	pro_7 = protocol
	pro_8 = protocol
	pro_9 = protocol
	pro_10 = protocol
	pro_11 = protocol
	pro_12 = protocol
	pro_13 = protocol
	pro_14 = protocol
	pro_15 = protocol
	pro_16 = protocol
	pro_17 = protocol
	pro_18 = protocol
	pro_19 = protocol
End


function set_read_mode()
	init_parameters()
	set_read_parameters()
End

function set_read_parameters()
	NVAR write_permit=write_permit, write_file_open=write_file_open, bin_type=bin_type
	NVAR read_file_open=read_file_open,stim_file_open=stim_file_open,acquire_mode=acquire_mode
	Make /O/N=(1000) dac0_start=0,dac0_end=0,dac0_amp=0,dac1_start=0,dac1_end=0,dac1_amp=0, dac2_start=0,dac2_end=0,dac2_amp=0
	init_all()
	write_permit = 0
	bin_type = 10
	acquire_mode = 0
	if (write_file_open == 1)
		close_write_file("")
	endif
	close /a
	write_file_open = 0
	read_file_open = 0
	stim_file_open = 0
	doWindow /F Panel_C
End

function make_ttl()
	variable i
	NVAR samples
	For(i=0; i<16; i +=1)
		variable /g $("ttl"+num2str(i)+"_pulse_num")
		Make /O/N=(samples) $("ttl"+num2str(i)+"_start")
		Make /O/N=(samples) $("ttl"+num2str(i)+"_end")
	EndFor
End

function kill_all()
	string tmpstr
	string WinName
	variable i, numberofwindows
	
	tmpstr = WinList("*",";","WIN:1") // graphs
	numberofwindows= ItemsInList(tmpstr)
//	printf "number of graphs: %d\r", numberofwindows
	// kill all windows
	For (i = 0; i < numberofwindows; i += 1)
		WinName = StringFromList(i, tmpstr)
		if (0 == strlen(WinName))
			break
		EndIf
		DoWindow /K $WinName
	EndFor
	tmpstr = WinList("*",";","WIN:2") // tables
	numberofwindows= ItemsInList(tmpstr)
	For (i = 0; i < numberofwindows; i += 1)
		WinName = StringFromList(i, tmpstr)
		if (0 == strlen(WinName))
			break
		EndIf
		DoWindow /K $WinName
	EndFor
	tmpstr = WinList("*",";","WIN:64") // panels
	numberofwindows= ItemsInList(tmpstr)
	For (i = 0; i < numberofwindows; i += 1)
		WinName = StringFromList(i, tmpstr)
		if (0 == strlen(WinName))
			break
		EndIf
		DoWindow /K $WinName
	EndFor
	tmpstr = WinList("*",";","WIN:64") // panels
	numberofwindows= ItemsInList(tmpstr)
	For (i = 0; i < numberofwindows; i += 1)
		WinName = StringFromList(i, tmpstr)
		if (0 == strlen(WinName))
			break
		EndIf
		DoWindow /K $WinName
	EndFor
	tmpstr = WinList("*",";","WIN:16") // notebooks
	numberofwindows= ItemsInList(tmpstr)
	For (i = 0; i < numberofwindows; i += 1)
		WinName = StringFromList(i, tmpstr)
		if (0 == strlen(WinName))
			break
		EndIf
		DoWindow /K $WinName
	EndFor
	Killvariables /A
	Killwaves /A
	KillStrings /A
	killdatafolder root:
End


function set_acquire_mode()
	SVAR InitFileName
	variable i
	kill_all()
	init_all()
	init_parameters()
	make_amp_analysis_panel()
	init_daq_parameters()
	set_acquire_parameters()
//	SVAR protocol=protocol
//	protocol = encode_pro()
//	i = 0
//	Do
//		SVAR pro = $("pro_" + num2str(i))
//		pro = protocol
//		i += 1
//	while (i < 5)
end	

function set_acquire_parameters()
	NVAR write_permit=write_permit, write_file_open=write_file_open, bin_type=bin_type,read_file_open=read_file_open
	NVAR acquire_mode=acquire_mode,stim_file_open=stim_file_open
	write_permit = 0
	bin_type = 10 // native acquire binary type
	close /a
	write_file_open = 0
	read_file_open = 0
	stim_file_open = 0
	set_sweep_time()
	Make /O/N=(1000) dac0_start=0,dac0_end=0,dac0_amp=0,dac1_start=0,dac1_end=0,dac1_amp=0, dac2_start=0,dac2_end=0,dac2_amp=0,dac3_start=0,dac3_end=0,dac3_amp=0
	make_ttl()
//	Make /O/N=(1000) ttl1_start=0,ttl1_end=0
// set default pulses	
	dac0_amp[0] = 1.0 // mV
	dac0_start[0] = 2.0 // ms 
	dac0_end[0] = 12.0 // ms
	dac1_amp[0] = 1.0 // mV
	dac1_start[0] = 2.0 // ms 
	dac1_end[0] = 12.0 // ms
	dac2_amp[0] = 1.0 // mV
	dac2_start[0] = 2.0 // ms 
	dac2_end[0] = 12.0 // ms
	dac3_amp[0] = 1.0 // mV
	dac3_start[0] = 2.0 // ms 
	dac3_end[0] = 12.0 // ms

//	init_parameters()
//	init_daq_parameters()
	acquire_mode = 1
	init_graphs()
	init_panels()
	set_daq("")
	set_stim()
	set_in()
	checkbox check0, win=panel_AQ_D, value=write_permit 
	doWindow /F Panel_AQ_C
End


function Init_Panels()
	NVAR requested,hp0,hp1, hp2, hp3,keepADC0,keepADC1,keepADC2,keepADC3	
	NVAR write_permit=write_permit,update=update,init_analysis=init_analysis
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4=adc_gain4,adc_gain5=adc_gain5,adc_gain6=adc_gain6,adc_gain7=adc_gain7
	SVAR write_file_name=write_file_name,seq_in=seq_in,seq_out=seq_out
	NVAR dac0_vc,dac0_cc,dac1_vc,dac1_cc, dac2_vc,dac2_cc,dac3_vc,dac3_cc
	NVAR dac0_stimfile_flag,dac1_stimfile_flag,dac2_stimfile_flag,dac3_stimfile_flag, dac0_stimfile_scale,dac1_stimfile_scale, sdac3_stimfile_scale, timwave_flag,dac2_stimfile_scale
	SVAR StimWave_name=StimWave_name, StimWave_name=Stmwave_name
	NVAR stimfile_recycle=stimfile_recycle, stimfile_loc=stimfile_loc,his_flag=his_flag,initialize=initialize
	NVAR dac0_psc_flag,dac0_psc1_taurise,dac0_psc1_tuadecay,dac0_psc1_amp
	NVAR dac0_psc2_taurise,dac0_psc2_tuadecay,dac0_psc2_amp, dac0_psc_interval
	NVAR dac0_psc3_taurise,dac0_psc3_tuadecay, dac0_psc3_amp,dac0_psc_int2
	NVAR dac0_psc_start,peak_risetime
	NVAR dac1_psc_flag,dac1_psc1_taurise,dac1_psc1_tuadecay,dac1_psc1_amp
	NVAR dac1_psc2_taurise,dac1_psc2_tuadecay,dac1_psc2_amp, dac1_psc_interval
	NVAR dac3_psc_start
	NVAR dac3_psc_flag,dac3_psc1_taurise,dac3_psc1_tuadecay,dac3_psc1_amp
	NVAR dac3_psc2_taurise,dac3_psc2_tuadecay,dac3_psc2_amp, dac3_psc_interval
	NVAR dac3_psc_start	
	NVAR dac2_psc_flag,dac2_psc1_taurise,dac2_psc1_tuadecay,dac2_psc1_amp
	NVAR dac2_psc2_taurise,dac2_psc2_tuadecay,dac2_psc2_amp, dac2_psc_interval
	NVAR dac2_psc_start,traces_analyzed=traces_analyzed
	NVAR sine_flag_dac0,sine_flag_dac1,sine_flag_dac2,sine_flag_dac3,sine_phase_dac0
	NVAR sine_phase_dac1,sine_phase_dac2, sine_amp_dac0, sine_amp_dac1, sine_amp_dac2
	NVAR sine_freq_dac0, sine_freq_dac1, sine_freq_dac2
	NVAR sine_phase_dac3, sine_amp_dac3
	NVAR sine_freq_dac3
	NVAR search_flag=search_flag,align_flag=align_flag, align_thresh=align_thresh,spike_thresh=spike_thresh
	NVAR spike_cv=spike_cv, spike_cv_flag=spike_cv_flag,average_flag=average_flag,his_flag=his_flag,continuous_flag=continuous_flag
	NVAR amp_analysis, analysis_num,acquire_mode, init_display
	variable scale
	scale = 120/screenresolution
	scale = 1
//	SVAR amp_window_name=amp_window_name
	PauseUpdate; Silent 1		// building window...
//------------------------------------------------------------------------
//notebook
	DoWindow /K notes
	if (acquire_mode)
		NewNoteBook /N=notes /F=0 /W=(0,400,200,450)
	Endif
	DoWindow /B notes
//--------------------------------------------------------------------------------------------------------------------
	DoWindow /K More_Analysis_Panel
	NewPanel /W=(scale*677, scale*521, scale*1013, scale*768) as "More Analysis"
	DoWindow /C More_Analysis_Panel
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (49152,65280,32768)
	SetDrawEnv save
	DrawRRect 2,1,122,31
	SetDrawEnv fillpat= 0
	SetDrawEnv save
	DrawRect 1,152,71,176
	SetDrawEnv textrgb= (65280,43520,0)
	SetDrawEnv save
	SetDrawEnv fsize= 14,textrgb= (65280,16384,16384)
	DrawText 2,173,"Average ?"
	SetDrawEnv linethick= 2,linefgc= (0,0,65280)
	SetDrawEnv save
	DrawRRect 2,178,332,230
	SetDrawEnv linethick= 1,linefgc= (0,0,0),fsize= 14,textrgb= (65280,16384,16384)
	DrawText 9,57,"Correlation?"
	DrawRect 333,96,-1,32
//	DrawRect 310,88,326,88
	Button button0,pos={227,3},size={102,19},proc=histo_vm,title="All Point His"
	Button button1,pos={6,6},size={110,20},proc=set_cursors_trace,title="Set: Curs. + trace"
	Button button2,pos={128,1},size={94,22},proc=histo_peaks,title="Peak_Histo"
	Button button3,pos={4,93},size={117,20},proc=STA_fixed,title="STA: Fixed W."
	SetVariable setvar0,pos={128,96},size={100,19},title="S.file_loc"
	SetVariable setvar0,limits={-inf,inf,0},value= stimfile_loc
	SetVariable setvar1,pos={242,96},size={71,19},title="Comp"
	SetVariable setvar1,limits={-inf,inf,0},value= compare_flag
	SetVariable setvar2,pos={141,126},size={69,19},title="DAC#"
	SetVariable setvar2,limits={-inf,inf,0},value= dac_num
	Button button4,pos={6,125},size={119,20},proc=Average_excitation,title="Average Excitation"
	Button init,pos={77,154},size={34,20},proc=query_average,title="Init"
	Button include,pos={120,154},size={50,20},proc=query_average,title="Include"
	Button do_not_include,pos={175,153},size={91,20},proc=query_average,title="Do not include"
	ValDisplay valdisp0,pos={269,154},size={67,18},title="Num"
	ValDisplay valdisp0,limits={0,0,0},barmisc={0,1000},value= #"traces_analyzed"
	Button button2_1,pos={13,183},size={88,20},proc=histo_thresh,title="Thresh Histo"
	SetVariable setvar3,pos={123,185},size={78,19},title="D_Th"
	SetVariable setvar3,limits={-inf,inf,0},value= deriv_thresh
	SetVariable setvar4,pos={128,206},size={73,19},title="Win"
	SetVariable setvar4,limits={-inf,inf,0},value= peak_window
	SetVariable setvar5,pos={244,183},size={73,19},title="S_Th"
	SetVariable setvar5,limits={-inf,inf,0},value= spike_thresh
	SetVariable setvar6,pos={209,206},size={112,19},title="Comp_flag"
	SetVariable setvar6,value= compare_flag
	Button init1,pos={94,33},size={34,20},proc=query_corr,title="Init"
	Button include1,pos={134,36},size={50,20},proc=query_corr,title="Include"
	Button do_not_include1,pos={194,35},size={91,20},proc=query_corr,title="Do not include"
	SetVariable setvar7,pos={8,54},size={122,19},value= corr_num
	SetVariable setvar8,pos={136,54},size={128,19},value= srcWave_0
	SetVariable setvar9,pos={136,72},size={127,19},value= srcWave_1
	ValDisplay position,pos={15,74},size={99,18},title="start"
	ValDisplay position,limits={0,0,0},barmisc={0,1000},mode= 3,value= #"corr_start"
	Button button5,pos={233,122},size={50,20},proc=ps,title="PS",fSize=14,fStyle=1
	Button button5,help={"Cursors mark trace and segment. sub_trend=1 drift"}
	Button button5,fColor=(65280,0,0)

	
//--------------------------------------------------------------------------------------------------------------------
	DoWindow /K Panel_C
	NewPanel /K=1 /W=(scale*675, scale*61, scale*1016, scale*198) as "OFFLINE CONTROLS"
	DoWindow /C Panel_C	
	SetVariable set_read_file_name,pos={0,0},size={180,16},proc=c_Read_Header,title="Read File"
	SetVariable set_read_file_name,value= read_file_name
	Button get_next_file,pos={190,0},size={40,20},proc=next_file,title="+"
	Button get_previous_file,pos={240,0},size={40,20},proc=previous_file,title="-"
	SetVariable set_trace_num,pos={6,48},size={107,16},proc=c_get_a_trace,title="tr_num"
	SetVariable set_trace_num,value= trace_num
	Button get_next,pos={120,47},size={30,20},proc=next,title="+"
	Button get_previous,pos={164,47},size={31,20},proc=previous,title="-"
	PopupMenu popup0,pos={6,75},size={104,24},proc=select_panel,title="Sel. Panel"
	PopupMenu popup0,mode=1,popvalue="Fit",value= #"\"Fit;Histogram;Pre-Process;Amp_Analysis;More_Analysis;View;DAC0;DAC1;DAC2;DAC3;TTL;Minis;Scheme\""
	Button button0,pos={295,73},size={36,20},proc=Do_Average,title="Avg"
	SetVariable setvar0,pos={228,50},size={55,16},title="Alt",value= alternate
	CheckBox check0,pos={245,21},size={41,14},proc=set_update,title="Updt",value= 1
	Button button1,pos={202,25},size={28,20},proc=clean,title="Cln"
	SetVariable setvar1,pos={7,24},size={68,16},title="start",format="%d"
	SetVariable setvar1,limits={-inf,inf,0},value= trace_start
	SetVariable setvar2,pos={92,24},size={67,16},title="end",format="%d"
	SetVariable setvar2,limits={-inf,inf,0},value= trace_end
	CheckBox check1,pos={12,122},size={59,14},proc=set_init_display,title="Init_Disp"
	CheckBox check1,value= 1
	CheckBox check2,pos={12,101},size={75,14},proc=set_init_average,title="Init_analysis"
	CheckBox check2,value= 1
	SetVariable setvar3,pos={243,34},size={68,16},title="ptime"
	SetVariable setvar3,help={"Pause in seconds between traces"},format="%.2f"
	SetVariable setvar3,limits={-inf,inf,0},value= ptime
	SetVariable setvar4,pos={89,99},size={254,18},title="com"
	SetVariable setvar4,labelBack=(0,34816,52224),font="Arial"
	SetVariable setvar4,limits={-inf,inf,0},value= comment,bodyWidth= 226,live= 1
	SetVariable setvar5,pos={87,119},size={243,18},title="com2"
	SetVariable setvar5,labelBack=(0,34816,52224),font="Arial"
	SetVariable setvar5,limits={-inf,inf,0},value= comment2,bodyWidth= 208,live= 1
	SetVariable Cont,pos={214,78},size={52,16},title="Cont",format="%d"
	SetVariable Cont,limits={-inf,inf,0},value= continuous_flag,noedit= 1

//----------------------------------------------------------------------------------------------------------------------------------------------
	NVAR update, adc0_avg_flag
	PauseUpdate; Silent 1		// building window...
	DoWindow /K Panel_AQ_C
	NewPanel /K=1 /W=(671,60,1022,200) as "Acquisition Controls"
	DoWindow /C Panel_AQ_C
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (52224,52224,0)
	DrawRect 245,2,330,97
	Button RUN,pos={2,39},size={61,32},proc=set_run,title="RUN_P"
	Button RUN,help={"Run the current protocol"}
	PopupMenu popup1,pos={4,108},size={101,24},proc=select_DAQ_Panel
	PopupMenu popup1,mode=1,popvalue="set->DAC0",value= #"\"set->DAC0;set->DAC1;set->DAC2;set->DAC3;set->TTL;Pre-Proc;Histogram;Fit;Amp_Analysis;set->DAQ-channels;Make Scheme\""
	Button button0,pos={2,4},size={61,31},proc=single_run,title="Single"
	CheckBox check2,pos={256,3},size={43,14},title="Cont.",variable= continuous_flag
	CheckBox check2,help={"Run protocol or scheme in gap-free mode"}
	Button button1,pos={68,83},size={63,23},proc=load_protocol,title="Load Pro"
	Button button4,pos={68,58},size={62,23},proc=Load_Scheme,title="Load Sch"
	Button RUN_Scheme,pos={2,75},size={61,32},proc=Do_a_Scheme,title="RUN_S"
	Button RUN_Scheme,help={"Run the current scheme"}
	CheckBox check4,pos={77,14},size={45,14},proc=set_init_analysis,title="Init_A"
	CheckBox check4,value= 1
	ValDisplay valdisp0,pos={141,4},size={86,15},title="0",format="%.1f"
	ValDisplay valdisp0,limits={0,0,0},barmisc={0,1000},value= #"electrode0_res"
	ValDisplay valdisp0_1,pos={140,19},size={88,18},title="1",fSize=14,format="%.1f"
	ValDisplay valdisp0_1,limits={0,0,0},barmisc={0,1000},value= #"electrode1_res"
	CheckBox AVG0,pos={256,31},size={43,14},proc=set_average_flag,title="Avg0"
	CheckBox AVG0,value= 1
	CheckBox AVG1,pos={256,45},size={43,14},proc=set_average_flag,title="Avg1"
	CheckBox AVG1,value= 0
	CheckBox AVG2,pos={256,59},size={43,14},proc=set_average_flag,title="Avg2"
	CheckBox AVG2,value= 0
	CheckBox AVG3,pos={256,72},size={43,14},proc=set_average_flag,title="Avg3"
	CheckBox AVG3,value= 0
	ValDisplay valdisp0_2,pos={141,36},size={88,18},title="2",fSize=14,format="%.1f"
	ValDisplay valdisp0_2,limits={0,0,0},barmisc={0,1000},value= #"electrode2_res"
	ValDisplay valdisp0_3,pos={141,53},size={88,18},title="3",fSize=14,format="%.1f"
	ValDisplay valdisp0_3,limits={0,0,0},barmisc={0,1000},value= #"electrode3_res"
	CheckBox init_disp,pos={76,29},size={57,14},proc=set_init_display,title="Init_disp"
	CheckBox init_disp,value= 1
	CheckBox A_Scale,pos={76,44},size={55,14},proc=A_scale,title="A-Scale"
	CheckBox A_Scale,help={"If checked automatic scaling is applied to G_traces, can be toggeled during acquisition using the 's' key (quickly)"}
	CheckBox A_Scale,value= 1
	CheckBox check3,pos={256,16},size={60,14},proc=set_trig,title="Ext. Trig."
	CheckBox check3,help={"If checked acquisition starts after trigger is applied to TRIG IN"}
	CheckBox check3,value= 0
	SetVariable setvar0,pos={161,98},size={182,18},title="com"
	SetVariable setvar0,labelBack=(0,34816,52224),font="Arial"
	SetVariable setvar0,limits={-inf,inf,0},value= comment,bodyWidth= 154,live= 1
	SetVariable setvar1,pos={161,115},size={183,18},title="com2"
	SetVariable setvar1,labelBack=(0,34816,52224),font="Arial"
	SetVariable setvar1,limits={-inf,inf,0},value= comment2,bodyWidth= 148,live= 1
	Button button2,pos={160,74},size={57,20},proc=Close_write_file,title="Close File"
	
	

//-------------------------------------------------------------------------------------------------------------------------------

// Acquisition

	NVAR disp_0, disp_1, disp_2, disp_3
	DoWindow /K panel_AQ_D
	NewPanel /K=1 /W=(scale*676, scale*229, scale*1020, scale*490) as "Acquisition Data"
	DoWindow /C Panel_AQ_D
	
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (39168,39168,39168)
	DrawRect 5,76,260,56
	SetDrawEnv fillfgc= (65280,16384,16384)
	DrawRect 5,106,260,76
	SetDrawEnv fillfgc= (0,43520,65280)
	DrawRect 5,136,260,106
	SetDrawEnv fillfgc= (65280,16384,55552)
	DrawRect 7,224,144,253
	SetDrawEnv fsize= 16
	DrawText 9,98,"0"
	SetDrawEnv fsize= 16
	DrawText 9,129,"1"
	DrawText 45,75,"MODE"
	DrawText 125,75,"GAIN"
	DrawText 205,75,"HP"
	SetDrawEnv fillfgc= (0,65280,0)
	DrawRect 5,166,260,136
	SetDrawEnv fsize= 16
	DrawText 9,162,"2"
	SetDrawEnv fillfgc= (0,0,0)
	DrawRect 5,196,260,166
	SetDrawEnv fsize= 16,textrgb= (65535,65535,65535)
	DrawText 9,192,"3"
	SetDrawEnv fstyle= 1,textrgb= (65280,0,0)
	DrawText 263,75,"Chan."
	SetDrawEnv fstyle= 1,textrgb= (0,39168,0)
	DrawText 304,76,"Disp"
	SetDrawEnv fsize= 18
	DrawText 10,248,"acquired: "
	SetVariable setvar0,pos={6,4},size={132,19},proc=set_samp,title="samples"
	SetVariable setvar0,font="Arial",fSize=14,value= samples
	SetVariable setvar1,pos={147,3},size={138,19},proc=set_freq,title="freq (KHz)"
	SetVariable setvar1,font="Arial",fSize=14,value= freq
	SetVariable setvar7,pos={114,79},size={72,19},proc=set_adc_gain,title=" "
	SetVariable setvar7,font="Arial",fSize=14,value= adc_gain0
	SetVariable setvar8,pos={114,110},size={72,19},proc=set_adc_gain,title=" "
	SetVariable setvar8,font="Arial",fSize=14,value= adc_gain1
	SetVariable setvar10,pos={144,199},size={118,19},title="wait",font="Arial"
	SetVariable setvar10,fSize=14,value= wait
	ValDisplay valdisp1,pos={84,226},size={56,24},fSize=18
	ValDisplay valdisp1,limits={0,0,0},barmisc={0,1000},value= #"acquired"
	SetVariable setvar9,pos={6,199},size={132,19},title="Rqstd",font="Arial"
	SetVariable setvar9,fSize=14,value= requested
	SetVariable setvar11,pos={194,79},size={59,19},proc=p_set_hp,title=" "
	SetVariable setvar11,font="Arial",fSize=14,value= hp0
	SetVariable setvar12,pos={194,110},size={59,19},proc=p_set_hp,title=" "
	SetVariable setvar12,font="Arial",fSize=14,value= hp1
	SetVariable setvar3,pos={5,31},size={190,19},proc=p_create_data_file,title="W_file"
	SetVariable setvar3,fSize=14,value= write_file_name
	CheckBox check0,pos={225,33},size={64,14},proc=set_write_permit,title="W_Permit"
	CheckBox check0,value= 0
	SetDrawEnv fillfgc= (65535,65535,65535)
	DrawRRect 204,27,308,51
	CheckBox check_vc0,pos={30,81},size={32,14},proc=set_vc_cc,title="VC",value= 1
	CheckBox check_cc0,pos={69,81},size={32,14},proc=set_vc_cc,title="CC",value= 0
	CheckBox check_vc1,pos={29,113},size={32,14},proc=set_vc_cc,title="VC",value= 1
	CheckBox check_cc1,pos={69,113},size={32,14},proc=set_vc_cc,title="CC",value= 0
	CheckBox check_vc2,pos={30,145},size={32,14},proc=set_vc_cc,title="VC",value= 1
	CheckBox check_cc2,pos={69,145},size={32,14},proc=set_vc_cc,title="CC",value= 0
	CheckBox check_vc3,pos={30,175},size={32,14},proc=set_vc_cc,title="VC",value= 1
	CheckBox check_cc3,pos={69,175},size={32,14},proc=set_vc_cc,title="CC",value= 0
	SetVariable setvar2,pos={194,140},size={59,19},proc=p_set_hp,title=" "
	SetVariable setvar2,font="Arial",fSize=14,value= hp2
	SetVariable setvar201,pos={194,170},size={59,19},proc=p_set_hp,title=" "
	SetVariable setvar201,font="Arial",fSize=14,value= hp3
	SetVariable setvar801,pos={114,140},size={72,19},proc=set_adc_gain,title=" "
	SetVariable setvar801,font="Arial",fSize=14,value= adc_gain2
	SetVariable setvar80101,pos={114,170},size={72,19},proc=set_adc_gain,title=" "
	SetVariable setvar80101,font="Arial",fSize=14,value= adc_gain3
	CheckBox ch0,pos={273,84},size={16,14},proc=set_chan_status,title="",value= 1
	CheckBox ch1,pos={273,114},size={16,14},proc=set_chan_status,title="",value= 0
	CheckBox ch2,pos={273,144},size={16,14},proc=set_chan_status,title="",value= 0
	CheckBox ch3,pos={273,172},size={16,14},proc=set_chan_status,title="",value= 0
	CheckBox d0,pos={311,85},size={16,14},proc=set_disp_status,title="",value= 1
	CheckBox d1,pos={311,115},size={16,14},proc=set_disp_status,title="",value= 0
	CheckBox d2,pos={311,145},size={16,14},proc=set_disp_status,title="",value= 0
	CheckBox d3,pos={311,173},size={16,14},proc=set_disp_status,title="",value= 0
	Button button0,pos={150,225},size={34,27},proc=set_pulses,title="Train"
	Button button0,help={"Set a train of pulses in the current protocol"}
	Button button0,fColor=(65280,65280,0)
	Button button1,pos={188,225},size={36,26},proc=set_delta,title="Delta"
	Button button1,help={"Set amplitude-delta change of first pulse of current protocol"}
	Button button1,fColor=(65280,65280,0)
	Button button4,pos={227,225},size={32,26},proc=CH,title="HP"
	Button button4,help={"Change the holding potential in one DAC in all the protocols of the current scheme "}
	Button button4,fColor=(65280,65280,0)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

//	Make_Amp_Analysis_Panel()
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	NVAR update=update
	DoWindow /K H_panel
	NewPanel /W=(677,522,1015,769) as "HISTOGRAM"
	DoWindow /C H_panel
	Button do_average,pos={182,6},size={80,20},proc=do_average,title="Average"
	SetVariable set_thresh,pos={4,2},size={130,16},title="thresh",format="%.1f"
	SetVariable set_thresh,value= spike_thresh
	SetVariable s_duration_pnts,pos={9,36},size={130,16},title="s_duration_pnts"
	SetVariable s_duration_pnts,format="%d",value= spike_duration
	SetVariable set_a_trace,pos={12,83},size={130,16},title="spike_trace"
	SetVariable set_a_trace,value= spike_detection_trace_name
	Button do_histogram,pos={152,56},size={100,20},proc=b_do_histogram,title="Do Histogram"
	SetVariable set_bin_size,pos={11,61},size={130,16},title="bin_size"
	SetVariable set_bin_size,value= bin_size
	ValDisplay val_spike_num,pos={174,81},size={80,15},title="spike#"
	ValDisplay val_spike_num,limits={0,0,0},barmisc={0,1000},value= #"spike_num"
	Button redo_his,pos={255,57},size={80,20},proc=redo_his,title="Redo_His"
	SetVariable set_discriminate,pos={186,29},size={80,16},title="discrim"
	SetVariable set_discriminate,value= discriminate
	SetVariable set_spike_start,pos={41,108},size={98,16},title="s_start"
	SetVariable set_spike_start,value= spike_start
	SetVariable set_spike_end,pos={45,131},size={98,16},title="s_end"
	SetVariable set_spike_end,value= spike_end
	ValDisplay val_traces_analyzed,pos={6,165},size={98,15},title="#trc_anal"
	ValDisplay val_traces_analyzed,limits={0,0,0},barmisc={0,1000}
	ValDisplay val_traces_analyzed,value= #"traces_analyzed"
	Button button0,pos={150,106},size={67,19},proc=get_isi,title="Get ISI"
	ValDisplay valdisp0,pos={151,133},size={64,15},title="cv",format="%.3f"
	ValDisplay valdisp0,limits={0,0,0},barmisc={0,1000},value= #"spike_cv"
	CheckBox check0,pos={229,107},size={16,14},proc=set_spike_cv_flag,title=""
	CheckBox check0,value= spike_cv_flag
	Button button1,pos={140,165},size={50,20},proc=init_histogram,title="init_His"
	CheckBox check1,pos={201,175},size={55,14},proc=set_init_analysis_flag,title="Init_flag"
	CheckBox check1,value= 1
	Button button2,pos={259,105},size={72,20},proc=set_isi,title="Set ISI"	
	Button button3,pos={265,141},size={50,20},proc=Set_cond,title="condense"
	Button button3,help={"Makes new wave with fewer points where new points are average of WAVE points on both sides. Use append to graph of WAVE_cond"}	
//-----------------------------------------------------------------------------------------------------------------------------------------------------------

	//NVAR smooth_flag=smooth_flag
	DoWindow /K PP_panel
	NewPanel /K=1 /W=(scale*678, scale*521, scale*1014, scale*768) as "PRE-PROCESS"
	DoWindow /C PP_panel
	SetVariable set_align_start,pos={145,3},size={137,19},title="align_start"
	SetVariable set_align_start,format="%d",value= align_start
	SetVariable set_align_end,pos={147,25},size={137,19},title="align_end"
	SetVariable set_align_end,format="%d",value= align_end
	SetVariable set_align_index,pos={140,47},size={144,19},title="align_index"
	SetVariable set_align_index,format="%d",proc=print_index, value= align_index
	CheckBox set_align_flag,pos={35,95},size={48,16},proc=set_align_flag,title="Align"
	CheckBox set_align_flag,value= 0
	SetVariable setvar0,pos={7,2},size={119,19},title="Threshold"
	SetVariable setvar0,value= align_thresh
	SetVariable setvar1,pos={6,26},size={121,19},title="Spike dur"
	SetVariable setvar1,value= spike_duration
	CheckBox check0,pos={34,117},size={64,16},proc=set_smooth,title="Smooth"
	CheckBox check0,value= 0
	SetVariable setvar2,pos={167,161},size={128,19},title="cutoff",value= cutoff
	PopupMenu select_smooth_trace,pos={140,132},size={158,24},proc=Select_Smooth_Trace,title="S_trace"
	PopupMenu select_smooth_trace,mode=2,popvalue="histog_vm",value= #" WaveList (\"*\",\";\", \"\")"
	Button button0,pos={32,65},size={50,20},proc=Select_Align_Par,title="SET"
	SetVariable setvar3,pos={151,74},size={135,19},title="Align_Trace"
	SetVariable setvar3,limits={-Inf,Inf,0},value= align_trace_name
	CheckBox concat,pos={34,143},size={90,15},title="Concatenate"
	CheckBox concat,help={"Concatenate during 'Read'; output: concat_0 etc.; initializes if reading trace 0, otherwise use 'duplicate/o adc0, concat_0' etc."}
	CheckBox concat,font="Arial",fStyle=1,variable= concat
	CheckBox check1,pos={34,130},size={68,14},proc=set_smooth,title="Smooth All"
	CheckBox check1,help={"Filter all valid adc traces"},variable= smoothAll


		
//-----------------------------------------------------------------------------------------------------------------------------------------------------------
	PauseUpdate; Silent 1		// building window...
	DoWindow /K F_panel
	NewPanel /K=1 /W=(scale*678, scale*521, scale*1014, scale*768) as "FIT"
	DoWindow /C F_panel
	SetVariable set_bl_start,pos={1,1},size={107,18},title="bl_start"
	SetVariable set_bl_start,limits={-Inf,Inf,1},value= bl_start
	SetVariable set_bl_end,pos={112,1},size={105,18},title="bl_end"
	SetVariable set_bl_end,limits={-Inf,Inf,1},value= bl_end
	SetVariable set_f_start,pos={4,25},size={102,18},title="f_start"
	SetVariable set_f_start,limits={-Inf,Inf,1},value= f_start
	SetVariable set_f_end,pos={109,25},size={109,18}
	SetVariable set_f_end,limits={-Inf,Inf,1},value= f_end
	SetVariable set_tau1,pos={3,49},size={123,18},format="%.3f"
	SetVariable set_tau1,limits={-Inf,Inf,1},value= tau1
	SetVariable set_tau2,pos={160,50},size={105,18},format="%.3f"
	SetVariable set_tau2,limits={-Inf,Inf,1},value= tau2
	SetVariable set_frac1,pos={4,72},size={124,18},format="%.3f"
	SetVariable set_frac1,limits={-Inf,Inf,1},value= frac1
	Button set_bl,pos={221,1},size={50,20},proc=Set_bl,title="set_bl"
	Button set_fit_range,pos={221,24},size={50,20},proc=Set_fit_range,title="set_f"
	SetVariable set_frac2,pos={166,74},size={96,18},format="%.3f"
	SetVariable set_frac2,limits={-Inf,Inf,1},value= frac2
	PopupMenu popup0,pos={128,125},size={127,24},proc=select_fit,title="Select Fit Type"
	PopupMenu popup0,mode=0,value= #"\"sin-exp;dbl-exp\""
//	PopupMenu select_wave,pos={101,97},size={158,24},proc=Select_fit_trace,title="Select Wave"
//	PopupMenu select_wave,mode=3,value= #" WaveList (\"*\",\";\", \"\")"
	SetVariable setvar0,pos={30,93},size={217,23},fSize=16
	SetVariable setvar0,limits={-inf,inf,0},value= fit_trace_name
	Button button1,pos={55,129},size={28,20},proc=clean,title="Cln"
//----------------------------------------------------------------------------------------------------------------------------------------------------
	PauseUpdate; Silent 1		// building window...
	DoWindow /K View_panel // setting the traces to keep
	NewPanel /K=1 /W=(scale*678, scale*521, scale*1014, scale*768) as "VIEW"
	DoWindow /C View_panel
	SetDrawLayer UserBack
	SetDrawEnv linefgc= (65280,16384,16384),fillpat= 0
	SetDrawEnv save
	DrawRect 3,4,97,34
	SetDrawEnv linefgc= (0,43520,65280)
	SetDrawEnv save
	DrawRect 3,36,102,69
	SetDrawEnv linefgc= (0,52224,0)
	DrawRect 3,73,104,105
	SetDrawEnv linefgc= (0,0,0)
	DrawRect 3,108,104,143
	CheckBox Keepadc0,pos={13,12},size={50,16},proc=set_keep,title="Keep",value= 0
	CheckBox Keepadc1,pos={13,44},size={50,16},proc=set_keep,title="Keep",value= 0
	CheckBox Keepadc2,pos={12,77},size={50,16},proc=set_keep,title="Keep",value= 0
	CheckBox Keepadc3,pos={13,117},size={50,16},proc=set_keep,title="Keep",value= 0
	CheckBox check0,pos={135,6},size={90,15},proc=set_Scale_to_Vis,title="Scale_to_Vis"
	CheckBox check0,font="Arial",variable= Scale_to_Vis
//-----------------------------------------------------------------------------------------------------------------------------------
	
		
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
	PauseUpdate; Silent 1		// building window...
	DoWindow /K DAC1_panel
	NewPanel /W=(scale*678, scale*521, scale*1014, scale*768) as "DAC1"
	DoWindow /C DAC1_panel
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (0,15872,65280)
	DrawRect 4,-2,157,29
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 3,100,297,164
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 297,169,4,237
	SetDrawEnv fillfgc= (43520,43520,43520)
	DrawRect 4,69,298,98
	SetDrawEnv fillfgc= (43520,43520,43520)
	SetDrawEnv save
	SetVariable setvar1,pos={12,5},size={134,21},proc=set_dac1_pulse_num,title="pulse_num"
	SetVariable setvar1,font="Arial",fSize=14
	SetVariable setvar1,limits={-Inf,Inf,1},value= dac1_pulse_num
	ValDisplay valdisp0,pos={166,4},size={125,21},title="time (ms)",font="Arial"
	ValDisplay valdisp0,fSize=14,frame=0,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp0,value= #" sweep_time"
	Button button0,pos={6,33},size={67,30},proc=edit_dac1,title="Edit Stim"
	Button button1,pos={83,33},size={84,31},proc=accept_dac1,title="Accept Stim"
	Button button2,pos={182,35},size={93,30},proc=display_dac1,title="Display Stim"
	CheckBox check20,pos={125,139},size={61,20},proc=set_stimfile,title="S_File",value=dac1_stimfile_flag
	SetVariable setvar4,pos={9,108},size={181,18},title="F_Name"
	SetVariable setvar4,limits={-Inf,Inf,1},value= stimfile_name
	SetVariable setvar5,pos={12,141},size={86,18},title="Scale"
	SetVariable setvar5,limits={-Inf,Inf,1},proc=set_para_change,value= dac1_stimfile_scale
	CheckBox check0,pos={14,74},size={49,20},proc=set_sine_flag,title="Sine",value=sine_flag_dac1
	SetVariable setvar0,pos={16,194},size={74,18},proc=set_para_change,title="amp"
	SetVariable setvar0,limits={-Inf,Inf,0},value= dac1_psc1_amp
	SetVariable setvar2,pos={234,75},size={62,18},proc=set_para_change,title="Freq"
	SetVariable setvar2,limits={-Inf,Inf,0},value= sine_freq_dac1
	SetVariable setvar15,pos={74,75},size={69,18},proc=set_para_change,title="Phase"
	SetVariable setvar15,limits={-Inf,Inf,0},value= sine_phase_dac1
	SetVariable setvar3,pos={150,76},size={81,18},proc=set_para_change,title="Amp"
	SetVariable setvar3,limits={-Inf,Inf,0},value= sine_amp_dac1
	CheckBox check200,pos={19,175},size={47,15},proc=set_psc_flag,title="PSC",value=dac1_psc_flag
	SetVariable setvar20,pos={206,196},size={73,18},proc=set_para_change,title="rise"
	SetVariable setvar20,limits={-Inf,Inf,0},value= dac1_psc1_taurise
	SetVariable setvar30,pos={114,196},size={80,18},proc=set_para_change,title="decay"
	SetVariable setvar30,limits={-Inf,Inf,0},value= dac1_psc1_taudecay
	SetVariable setvar7,pos={186,174},size={95,18},proc=set_para_change,title="Interval"
	SetVariable setvar7,limits={-Inf,Inf,0},value= dac1_psc_interval
	SetVariable setvar8,pos={16,214},size={74,18},proc=set_para_change,title="amp"
	SetVariable setvar8,limits={-Inf,Inf,0},value= dac1_psc2_amp
	SetVariable setvar3_1,pos={114,215},size={80,18},proc=set_para_change,title="decay"
	SetVariable setvar3_1,limits={-Inf,Inf,0},value= dac1_psc2_taudecay
	SetVariable setvar2_1,pos={207,215},size={73,18},proc=set_para_change,title="rise"
	SetVariable setvar2_1,limits={-Inf,Inf,0},value= dac1_psc2_taurise
	SetVariable setvar9,pos={83,175},size={93,18},proc=set_para_change,title="pstart"
	SetVariable setvar9,limits={-Inf,Inf,0},value= dac1_psc_start
	SetVariable setvar6,pos={189,137},size={77,18},title="Loc"
	SetVariable setvar6,limits={-Inf,Inf,1},value= stimfile_loc
	Button set_dac0,pos={301,8},size={30,20},title="dac0",fColor=(65280,16384,16384),proc=select_dac0
	Button set_dac1,pos={302,39},size={30,20},title="dac1",fColor=(0,43520,65280), proc=select_dac1
	Button set_dac2,pos={303,73},size={30,20},title="dac2",fColor=(0,65280,0), proc=select_dac2
	Button set_dac3,pos={303,107},size={30,20},title="dac3",proc=select_dac3
	Button button3,pos={302,141},size={32,19},proc=CP,title="CP"
	Button button3 help={"Replace a pulse amplitude in one DAC in all the protocols of the current scheme "}
	Button button5,pos={302,205},size={32,19},proc=CCh,title="CCh"
	Button button5,fColor=(65280,16384,16384)
	Button button5 help={"Exchange pulses between two protocols in the current scheme "}


//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
	PauseUpdate; Silent 1		// building window...

	DoWindow /K DAC2_panel
	NewPanel /W=(scale*678, scale*521, scale*1014, scale*768) as "DAC2"
	DoWindow /C DAC2_panel
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (0,39168,19712)
	DrawRect 4,-2,157,29
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 3,100,297,164
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 297,169,4,237
	SetDrawEnv fillfgc= (43520,43520,43520)
	DrawRect 4,69,298,98
	SetDrawEnv fillfgc= (43520,43520,43520)
	SetDrawEnv save
	SetVariable setvar1,pos={12,5},size={134,19},proc=set_dac2_pulse_num,title="pulse_num"
	SetVariable setvar1,font="Arial",fSize=14,value= dac2_pulse_num
	ValDisplay valdisp0,pos={166,4},size={125,18},title="time (ms)",font="Arial"
	ValDisplay valdisp0,fSize=14,frame=0,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp0,value= #" sweep_time"
	Button button0,pos={6,33},size={67,30},proc=edit_dac2,title="Edit Stim"
	Button button1,pos={83,33},size={84,31},proc=accept_dac2,title="Accept Stim"
	Button button2,pos={182,35},size={93,30},proc=display_dac2,title="Display Stim"
	CheckBox check20,pos={125,139},size={56,16},proc=set_stimfile,title="S_File"
	CheckBox check20,value= 0
	SetVariable setvar4,pos={9,108},size={181,19},title="F_Name"
	SetVariable setvar4,value= stimfile_name
	SetVariable setvar5,pos={12,141},size={86,19},proc=set_para_change,title="Scale"
	SetVariable setvar5,value= dac2_stimfile_scale
	CheckBox check0,pos={14,74},size={45,16},proc=set_sine_flag,title="Sine"
	CheckBox check0,value= 0
	SetVariable setvar0,pos={16,194},size={74,19},proc=set_para_change,title="amp"
	SetVariable setvar0,limits={-Inf,Inf,0},value= dac2_psc1_amp
	SetVariable setvar2,pos={234,75},size={62,19},proc=set_para_change,title="Freq"
	SetVariable setvar2,limits={-Inf,Inf,0},value= sine_freq_dac2
	SetVariable setvar15,pos={74,75},size={69,19},proc=set_para_change,title="Phase"
	SetVariable setvar15,limits={-Inf,Inf,0},value= sine_phase_dac2
	SetVariable setvar3,pos={150,76},size={81,19},proc=set_para_change,title="Amp"
	SetVariable setvar3,limits={-Inf,Inf,0},value= sine_amp_dac2
	CheckBox check200,pos={19,175},size={45,16},proc=set_psc_flag,title="PSC"
	CheckBox check200,value= 0
	SetVariable setvar20,pos={206,196},size={73,19},proc=set_para_change,title="rise"
	SetVariable setvar20,limits={-Inf,Inf,0},value= dac1_psc2_taurise
	SetVariable setvar30,pos={114,196},size={80,19},proc=set_para_change,title="decay"
	SetVariable setvar30,limits={-Inf,Inf,0},value= dac1_psc2_taudecay
	SetVariable setvar7,pos={186,174},size={95,19},proc=set_para_change,title="Interval"
	SetVariable setvar7,limits={-Inf,Inf,0},value= dac2_psc_interval
	SetVariable setvar8,pos={16,214},size={74,19},proc=set_para_change,title="amp"
	SetVariable setvar8,limits={-Inf,Inf,0},value= dac1_psc2_amp
	SetVariable setvar3_1,pos={114,215},size={80,19},proc=set_para_change,title="decay"
	SetVariable setvar3_1,limits={-Inf,Inf,0},value= dac1_psc2_taudecay
	SetVariable setvar2_1,pos={207,215},size={73,19},proc=set_para_change,title="rise"
	SetVariable setvar2_1,limits={-Inf,Inf,0},value= dac2_psc2_taurise
	SetVariable setvar9,pos={83,175},size={93,19},proc=set_para_change,title="pstart"
	SetVariable setvar9,limits={-Inf,Inf,0},value= dac2_psc_start
	SetVariable setvar6,pos={189,137},size={77,19},title="Loc",value= stimfile_loc
	Button set_dac0,pos={301,8},size={30,20},title="dac0",fColor=(65280,16384,16384),proc=select_dac0
	Button set_dac1,pos={302,39},size={30,20},title="dac1",fColor=(0,43520,65280), proc=select_dac1
	Button set_dac2,pos={303,73},size={30,20},title="dac2",fColor=(0,65280,0), proc=select_dac2
	Button set_dac3,pos={303,107},size={30,20},title="dac3",proc=select_dac3
	Button button3,pos={302,141},size={32,19},proc=CP,title="CP"
	Button button3,fColor=(65280,0,52224)
	Button button3 help={"Replace a pulse amplitude in one DAC in all the protocols of the current scheme "}
	Button button5,pos={302,205},size={32,19},proc=CCh,title="CCh"
	Button button5,fColor=(65280,16384,16384)
	Button button5 help={"Exchange pulses between two protocols in the current scheme "}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PauseUpdate; Silent 1		// building window...
	DoWindow /K DAC3_panel
	NewPanel /W=( scale*678, scale*521, scale*1014, scale*768) as "DAC3"
	DoWindow /C DAC3_panel
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (0,0,0)
	DrawRect 4,-2,157,29
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 3,100,297,164
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 297,169,4,237
	SetDrawEnv fillfgc= (43520,43520,43520)
	DrawRect 4,69,298,98
	SetDrawEnv fillfgc= (43520,43520,43520)
	SetDrawEnv save
	SetVariable setvar1,pos={12,5},size={134,19},proc=set_dac3_pulse_num,title="pulse_num"
	SetVariable setvar1,font="Arial",fSize=14,value= dac3_pulse_num
	ValDisplay valdisp0,pos={166,4},size={125,18},title="time (ms)",font="Arial"
	ValDisplay valdisp0,fSize=14,frame=0,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp0,value= #" sweep_time"
	Button button0,pos={6,33},size={67,30},proc=edit_dac3,title="Edit Stim"
	Button button1,pos={83,33},size={84,31},proc=accept_dac3,title="Accept Stim"
	Button button2,pos={182,35},size={93,30},proc=display_dac3,title="Display Stim"
	CheckBox check20,pos={125,139},size={56,16},proc=set_stimfile,title="S_File"
	CheckBox check20,value= 0
	SetVariable setvar4,pos={9,108},size={181,19},title="F_Name"
	SetVariable setvar4,value= stimfile_name
	SetVariable setvar5,pos={12,141},size={86,19},proc=set_para_change,title="Scale"
	SetVariable setvar5,value= dac3_stimfile_scale
	CheckBox check0,pos={14,74},size={45,16},proc=set_sine_flag,title="Sine"
	CheckBox check0,value= 0
	SetVariable setvar0,pos={16,194},size={74,19},proc=set_para_change,title="amp"
	SetVariable setvar0,limits={-Inf,Inf,0},value= dac3_psc1_amp
	SetVariable setvar2,pos={234,75},size={62,19},proc=set_para_change,title="Freq"
	SetVariable setvar2,limits={-Inf,Inf,0},value= sine_freq_dac3
	SetVariable setvar15,pos={74,75},size={69,19},proc=set_para_change,title="Phase"
	SetVariable setvar15,limits={-Inf,Inf,0},value= sine_phase_dac3
	SetVariable setvar3,pos={150,76},size={81,19},proc=set_para_change,title="Amp"
	SetVariable setvar3,limits={-Inf,Inf,0},value= sine_amp_dac3
	CheckBox check200,pos={19,175},size={45,16},proc=set_psc_flag,title="PSC"
	CheckBox check200,value= 0
	SetVariable setvar20,pos={206,196},size={73,19},proc=set_para_change,title="rise"
	SetVariable setvar20,limits={-Inf,Inf,0},value= dac1_psc3_taurise
	SetVariable setvar30,pos={114,196},size={80,19},proc=set_para_change,title="decay"
	SetVariable setvar30,limits={-Inf,Inf,0},value= dac1_psc3_taudecay
	SetVariable setvar7,pos={186,174},size={95,19},proc=set_para_change,title="Interval"
	SetVariable setvar7,limits={-Inf,Inf,0},value= dac3_psc_interval
	SetVariable setvar8,pos={16,214},size={74,19},proc=set_para_change,title="amp"
	SetVariable setvar8,limits={-Inf,Inf,0},value= dac1_psc3_amp
	SetVariable setvar3_1,pos={114,215},size={80,19},proc=set_para_change,title="decay"
	SetVariable setvar3_1,limits={-Inf,Inf,0},value= dac1_psc3_taudecay
	SetVariable setvar2_1,pos={207,215},size={73,19},proc=set_para_change,title="rise"
	SetVariable setvar2_1,limits={-Inf,Inf,0},value= dac2_psc2_taurise
	SetVariable setvar9,pos={83,175},size={93,19},proc=set_para_change,title="pstart"
	SetVariable setvar9,limits={-Inf,Inf,0},value= dac3_psc_start
	SetVariable setvar6,pos={189,137},size={77,19},title="Loc",value= stimfile_loc
	Button set_dac0,pos={301,8},size={30,20},title="dac0",fColor=(65280,16384,16384),proc=select_dac0
	Button set_dac1,pos={302,39},size={30,20},title="dac1",fColor=(0,43520,65280), proc=select_dac1
	Button set_dac2,pos={303,73},size={30,20},title="dac2",fColor=(0,65280,0), proc=select_dac2
	Button set_dac3,pos={303,107},size={30,20},title="dac3",proc=select_dac3
	Button button3,pos={302,141},size={32,19},proc=CP,title="CP"
	Button button3,fColor=(65280,0,52224)
	Button button3 help={"Replace a pulse amplitude in one DAC in all the protocols of the current scheme "}
	Button button5,pos={302,205},size={32,19},proc=CCh,title="CCh"
	Button button5,fColor=(65280,16384,16384)
	Button button5 help={"Exchange pulses between two protocols in the current scheme "}


//-----------------------------------------------------------------
//	PauseUpdate; Silent 1		// building window...
//	DoWindow /K ttl1_panel
//	NewPanel /W=( scale*678, scale*521, scale*1014, scale*768) as "ttl1"
//	DoWindow /C ttl1_panel
//	SetDrawLayer UserBack
//	SetDrawEnv fillfgc= (0,15872,65280)
//	DrawRect 4,-2,157,29
//	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
//	DrawRect 297,100,3,169
//	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
//	DrawRect 301,170,8,238
//	SetDrawEnv fillfgc= (43520,43520,43520)
//	DrawRect 4,98,289,69
//	SetDrawEnv fillfgc= (43520,43520,43520)
//	SetDrawEnv save
//	SetVariable setvar1,pos={16,3},size={134,21},proc=set_ttl1_pulse_num,title="pulse_num"
//	SetVariable setvar1,font="Arial",fSize=14
//	SetVariable setvar1,limits={-Inf,Inf,1},value= ttl1_pulse_num
//	ValDisplay valdisp0,pos={165,4},size={125,21},title="time (ms)",font="Arial"
//	ValDisplay valdisp0,fSize=14,frame=0,limits={0,0,0},barmisc={0,1000}
//	ValDisplay valdisp0,value= #" sweep_time"
//	Button button0,pos={11,33},size={67,30},proc=edit_ttl1,title="Edit Stim"
//	Button button1,pos={91,33},size={84,31},proc=accept_ttl1,title="Accept Stim"
//	Button button2,pos={192,34},size={93,30},proc=display_ttl,title="Display TTL"
////	CheckBox check100,pos={219,110},size={65,20},proc=set_stimfile,title="S_File",value=dac0_stimfile_flag
//	SetVariable setvar4,pos={9,108},size={181,18},title="F_Name"
//	SetVariable setvar4,limits={-Inf,Inf,1},value= stimfile_name
//	
//	//-----------------------------------------------------------------
//	PauseUpdate; Silent 1		// building window...
//	DoWindow /K ttl2_panel
//	NewPanel /W=( scale*678, scale*521, scale*1014, scale*768) as "ttl2"
//	DoWindow /C ttl2_panel
//	SetDrawLayer UserBack
//	SetDrawEnv fillfgc= (0,15872,65280)
//	DrawRect 4,-2,157,29
//	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
//	DrawRect 297,100,3,169
//	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
//	DrawRect 301,170,8,238
//	SetDrawEnv fillfgc= (43520,43520,43520)
//	DrawRect 4,98,289,69
//	SetDrawEnv fillfgc= (43520,43520,43520)
//	SetDrawEnv save
//	SetVariable setvar1,pos={16,3},size={134,21},proc=set_ttl2_pulse_num,title="pulse_num"
//	SetVariable setvar1,font="Arial",fSize=14
//	SetVariable setvar1,limits={-Inf,Inf,1},value= ttl2_pulse_num
//	ValDisplay valdisp0,pos={165,4},size={125,21},title="time (ms)",font="Arial"
//	ValDisplay valdisp0,fSize=14,frame=0,limits={0,0,0},barmisc={0,1000}
//	ValDisplay valdisp0,value= #" sweep_time"
//	Button button0,pos={11,33},size={67,30},proc=edit_ttl2,title="Edit Stim"
//	Button button1,pos={91,33},size={84,31},proc=accept_ttl2,title="Accept Stim"
//	Button button2,pos={192,34},size={93,30},proc=display_ttl,title="Display TTL"
////	CheckBox check100,pos={219,110},size={65,20},proc=set_stimfile,title="S_File",value=dac0_stimfile_flag
//	SetVariable setvar4,pos={9,108},size={181,18},title="F_Name"
//	SetVariable setvar4,limits={-Inf,Inf,1},value= stimfile_name
//
//--------------------------------------------------------------------------------------------------------------------------
PauseUpdate; Silent 1		// building window...
	DoWindow /K DAC0_panel
	NewPanel /W=( scale*678, scale*521, scale*1014, scale*768) as "DAC0"
	DoWindow /C DAC0_panel
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (65280,0,0)
	DrawRect 4,-2,157,29
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 297,100,3,169
	SetDrawEnv linethick= 0,fillfgc= (47872,47872,47872)
	DrawRect 301,170,8,238
	SetDrawEnv fillfgc= (43520,43520,43520)
	DrawRect 4,98,289,69
	SetDrawEnv fillfgc= (43520,43520,43520)
	SetDrawEnv save
	SetVariable setvar1,pos={16,3},size={134,19},proc=set_dac0_pulse_num,title="pulse_num"
	SetVariable setvar1,font="Arial",fSize=14,value= dac0_pulse_num
	ValDisplay valdisp0,pos={165,4},size={125,18},title="time (ms)",font="Arial"
	ValDisplay valdisp0,fSize=14,frame=0,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp0,value= #" sweep_time"
	Button button0,pos={11,33},size={67,30},proc=edit_dac0,title="Edit Stim"
	Button button1,pos={91,33},size={84,31},proc=accept_dac0,title="Accept Stim"
	Button button2,pos={192,34},size={93,30},proc=display_dac0,title="Display Stim"
	CheckBox check100,pos={219,110},size={56,16},proc=set_stimfile,title="S_File"
	CheckBox check100,value= 0
	SetVariable setvar4,pos={9,108},size={181,19},title="F_Name"
	SetVariable setvar4,value= stimfile_name
	SetVariable setvar5,pos={12,141},size={86,19},proc=set_para_change,title="Scale"
	SetVariable setvar5,value= dac0_stimfile_scale
	SetVariable setvar6,pos={109,139},size={97,19},proc=set_stim_loc,title="loc"
	SetVariable setvar6,value= stimfile_loc
	CheckBox check1,pos={221,141},size={68,16},proc=set_stimfile_recycle,title="Recycle"
	CheckBox check1,value= 0
	CheckBox check10,pos={3,174},size={45,16},proc=set_psc_flag,title="PSC",value= 0
	SetVariable setvar0,pos={4,193},size={74,19},proc=set_para_change,title="amp"
	SetVariable setvar0,limits={-Inf,Inf,0},value= dac0_psc1_amp
	SetVariable setvar2,pos={207,193},size={73,19},proc=set_para_change,title="rise"
	SetVariable setvar2,limits={-Inf,Inf,0},value= dac0_psc1_taurise
	SetVariable setvar3,pos={108,193},size={80,19},proc=set_para_change,title="decay"
	SetVariable setvar3,limits={-Inf,Inf,0},value= dac0_psc1_taudecay
	SetVariable setvar7,pos={145,171},size={62,19},proc=set_para_change,title="Int"
	SetVariable setvar7,limits={-Inf,Inf,0},value= dac0_psc_interval
	SetVariable setvar8,pos={3,212},size={74,19},proc=set_para_change,title="amp"
	SetVariable setvar8,limits={-Inf,Inf,0},value= dac0_psc2_amp
	SetVariable setvar3_1,pos={107,213},size={80,19},proc=set_para_change,title="decay"
	SetVariable setvar3_1,limits={-Inf,Inf,0},value= dac0_psc2_taudecay
	SetVariable setvar2_1,pos={208,213},size={73,19},proc=set_para_change,title="rise"
	SetVariable setvar2_1,limits={-Inf,Inf,0},value= dac0_psc2_taurise
	SetVariable setvar9,pos={53,172},size={78,19},proc=set_para_change,title="start"
	SetVariable setvar9,limits={-Inf,Inf,0},value= dac0_psc_start
	CheckBox check3,pos={11,74},size={45,16},proc=set_sine_flag,title="Sine"
	CheckBox check3,value= 0
	SetVariable setvar10,pos={59,74},size={69,19},proc=set_para_change,title="Phase"
	SetVariable setvar10,limits={-Inf,Inf,0},value= sine_phase_dac0
	SetVariable setvar11,pos={137,74},size={76,19},proc=set_para_change,title="Amp"
	SetVariable setvar11,limits={-Inf,Inf,0},value= sine_amp_dac0
	SetVariable setvar12,pos={219,74},size={61,19},proc=set_para_change,title="Freq"
	SetVariable setvar12,limits={-Inf,Inf,0},value= sine_freq_dac0
	SetVariable setvar13,pos={216,173},size={77,19},title="Int2"
	SetVariable setvar13,limits={-Inf,Inf,0},value= dac0_psc_int2
	SetVariable setvar14,pos={4,232},size={73,19},title="amp"
	SetVariable setvar14,limits={-Inf,Inf,0},value= dac0_psc3_amp
	SetVariable setvar15,pos={103,231},size={83,19},title="decay"
	SetVariable setvar15,limits={-Inf,Inf,0},value= dac0_psc3_taudecay
	SetVariable setvar16,pos={208,233},size={74,19},title="rise"
	SetVariable setvar16,limits={-Inf,Inf,0},value= dac0_psc3_taurise
	Button set_dac0,pos={301,8},size={30,20},title="dac0",fColor=(65280,16384,16384),proc=select_dac0
	Button set_dac1,pos={302,39},size={30,20},title="dac1",fColor=(0,43520,65280), proc=select_dac1
	Button set_dac2,pos={303,73},size={30,20},title="dac2",fColor=(0,65280,0), proc=select_dac2
	Button set_dac3,pos={303,107},size={30,20},title="dac3",proc=select_dac3
	Button button3,pos={302,141},size={32,19},proc=CP,title="CP"
	Button button3,fColor=(65280,0,52224)
	Button button3 help={"Replace a pulse amplitude in one DAC in all the protocols of the current scheme "}
	Button button5,pos={302,205},size={32,19},proc=CCh,title="CCh"
	Button button5,fColor=(65280,16384,16384)
	Button button5 help={"Exchange pulses between two protocols in the current scheme "}





End

function make_ttl_panel(num)
	variable num // ttl channel number
	NVAR ttl_pulse_num = $("ttl"+num2str(num)+"_pulse_num")
	NVAR sweep_time, ttl_num
	string title
	DoWindow /K ttl_panel
	title = "ttl"+num2str(num)
	NewPanel /W=( 678, 521, 1014, 768) as title
	DoWindow /C ttl_panel
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (0,15872,65280)
	DrawRect 4,-2,157,29
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 297,100,3,169
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 301,170,8,238
	SetDrawEnv fillfgc= (43520,43520,43520)
	DrawRect 4,98,289,69
	SetDrawEnv fillfgc= (43520,43520,43520)
	SetDrawEnv save
	SetVariable setvar1,pos={16,3},size={134,21},title="pulse_num"
	SetVariable setvar1,font="Arial",fSize=14
	SetVariable setvar1,limits={-Inf,Inf,1},value= ttl_pulse_num
	ValDisplay valdisp0,pos={21,73},size={125,21},title="time (ms)",font="Arial"
	ValDisplay valdisp0,fSize=14,frame=0,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp0,value= #" sweep_time"
	string button_title = "Edit_ttl_"+num2str(num) 
	Button $button_title,pos={11,33},size={67,30},proc=edit_ttl,title="Edit Stim_"+num2str(num)
	button_title = "Accept_Stim_"+num2str(num) 
	Button $button_title,pos={91,33},size={84,31},proc=accept_ttl,title="Accept Stim_"+num2str(num)
	Button button2,pos={192,34},size={93,30},proc=display_ttl,title="Display TTL_"+num2str(num)
	SetVariable ttl_num,pos={173,4},size={104,23},title="ttl_num",fSize=16
	SetVariable ttl_num,proc=change_ttl_panel, value=ttl_num

End

function change_ttl_panel(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName,varStr, varName
	variable varNum
	NVAR sweep_time, ttl_num
	NVAR ttl_pulse_num = $("ttl"+num2str(ttl_num)+"_pulse_num")
	string title
	DoWindow /K ttl_panel
	title = "ttl"+num2str(ttl_num)
	NewPanel /W=( 678, 521, 1014, 768) as title
	DoWindow /C ttl_panel
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (0,15872,65280)
	DrawRect 4,-2,157,29
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 297,100,3,169
	SetDrawEnv linethick= 2,fillfgc= (47872,47872,47872)
	DrawRect 301,170,8,238
	SetDrawEnv fillfgc= (43520,43520,43520)
	DrawRect 4,98,289,69
	SetDrawEnv fillfgc= (43520,43520,43520)
	SetDrawEnv save
	SetVariable setvar1,pos={16,3},size={134,21},title="pulse_num"
	SetVariable setvar1,font="Arial",fSize=14
	SetVariable setvar1,limits={-Inf,Inf,1},value= ttl_pulse_num
	ValDisplay valdisp0,pos={21,73},size={125,21},title="time (ms)",font="Arial"
	ValDisplay valdisp0,fSize=14,frame=0,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp0,value= #" sweep_time"
	string button_title = "Edit_ttl_"+num2str(ttl_num) 
	Button $button_title,pos={11,33},size={67,30},proc=edit_ttl,title="Edit Stim_"+num2str(ttl_num)
	button_title = "Accept_Stim_"+num2str(ttl_num) 
	Button $button_title,pos={91,33},size={84,31},proc=accept_ttl,title="Accept Stim_"+num2str(ttl_num)
	Button button2,pos={192,34},size={93,30},proc=display_ttl,title="Display TTL_"+num2str(ttl_num)
	SetVariable ttl_num,pos={173,4},size={104,23},title="ttl_num",fSize=16
	SetVariable ttl_num,proc=change_ttl_panel, value=ttl_num

End

function Make_Mini_Panel()
	
	NVAR miniFlag,searchEnd_0,searchEnd_1,searchEnd_2, searchEnd_3 //SPB
	NVAR Threshold_0, Threshold_1, Threshold_2, Threshold_3 //SPB
	NVAR LATime_0, LATime_1, LATime_2, LATime_3 //SPB
	NVAR BLTime_0, BLTime_1, BLTime_2, BLTime_3 //SPB
	NVAR jumpTime_0, jumpTime_1, jumpTime_2, jumpTime_3 //SPB
	NVAR adc0_index, adc1_index, adc2_index, adc2_index, adc3_index //SPB
	NVAR searchStart_0, searchStart_1, searchStart_2, searchStart_3 //SPB
	NVAR autoFlag
	NVAR peakWindowTime_0, peakWindowTime_1,  peakWindowTime_2, peakWindowTime_3 //SPB
	NVAR slope_0, slope_1, slope_2, slope_3 //SPB
	NVAR risePoints, over_ride_init

	//modified 4-30-07 by SPB for mini_analysis of ADC3 -- marked with //SPB

	DoWindow /K Minis_Panel
	NewPanel /W=(677,372,1162,689) as "Minis"
	DoWindow /C Minis_Panel
	SetVariable setvar0,pos={15,7},size={118,16},title="TraceOffSet"
	SetVariable setvar0,help={"Offset added to mini time times trace number"}
	SetVariable setvar0,format="%.2f",limits={-inf,inf,0},value= TraceOffSet
	SetVariable setvar1,pos={143,7},size={86,16},title="ABS Max"
	SetVariable setvar1,help={"Maximum absolute acceptable mini (to avoid spikes and glitches)"}
	SetVariable setvar1,limits={-inf,inf,0},value= Event_Max
	
	SetVariable FindMinis,pos={230,7},size={70,16},title="Find Minis"
	SetVariable FindMinis,limits={-inf,inf,0},value= miniFlag
	SetVariable End_001,pos={8,52},size={94,16},title="start_0"
	SetVariable End_001,help={"searchstart_0  in points -- start of analysis for adc0"}
	SetVariable End_001,format="%d",limits={-inf,inf,0},value= searchStart_0
	SetVariable End_0,pos={7,73},size={95,16},title="End_0"
	SetVariable End_0,help={"end of search in points"},format="%d"
	SetVariable End_0,limits={-inf,inf,0},value= searchEnd_0
	SetVariable End_1,pos={5,93},size={97,16},title="Thresh_0"
	SetVariable End_1,help={"threshold crossing in mv or pA"},format="%.3f"
	SetVariable End_1,limits={-inf,inf,0},value= Threshold_0
	SetVariable End_6,pos={8,114},size={94,16},title="LF_0"
	SetVariable End_6,help={"Time interval (in ms) from end of baseline to threshold crossing"}
	SetVariable End_6,format="%.1f",limits={-inf,inf,0},value= LAtime_0
	SetVariable End_9,pos={9,136},size={93,16},title="BL_0"
	SetVariable End_9,help={"Time interval (in ms) to calculate baseline"}
	SetVariable End_9,format="%.1f",limits={-inf,inf,0},value= blTime_0
	
	SetVariable Jump_0,pos={7,156},size={95,16},title="Jump_0"
	SetVariable Jump_0,help={"skip in ms from start of last event if accepted or from end of baseline if rejected automatically"}
	SetVariable Jump_0,format="%.1f",limits={-inf,inf,0},value= jumpTime_0
	SetVariable End_00102,pos={7,176},size={95,16},title="peakwinT_0"
	SetVariable End_00102,help={"Time window (in ms) from end of baseline to locate peak"}
	SetVariable End_00102,format="%.2f",limits={-inf,inf,0},value= peakWindowTime_0
	SetVariable Slope_0,pos={5,197},size={97,16},title="Slope_0"
	SetVariable Slope_0,help={"slope of baseline (in mV/ms or pA/ms) used to reject"}
	SetVariable Slope_0,format="%.2f",limits={-inf,inf,0},value= slope_0
	SetVariable setvar4,pos={7,247},size={129,16},title="risePoints"
	SetVariable setvar4,help={"number of points around the half amplitude used for linear fit"}
	SetVariable setvar4,limits={-inf,inf,0},value= risePoints
	
	SetVariable End_00101,pos={125,52},size={95,16},title="start_1"
	SetVariable End_00101,help={"searchstart_1  in points -- start of analysis for adc1"}
	SetVariable End_00101,format="%d",limits={-inf,inf,0},value= searchStart_1
	SetVariable End_3,pos={124,73},size={96,16},title="End_1"
	SetVariable End_3,help={"end of search in points"},format="%d"
	SetVariable End_3,limits={-inf,inf,0},value= searchEnd_1
	SetVariable End_4,pos={120,93},size={100,16},title="Thresh_1",format="%.3f"
	SetVariable End_4,limits={-inf,inf,0},value= Threshold_1
	SetVariable End_7,pos={129,114},size={91,16},title="LF_1"
	SetVariable End_7,help={"Time interval (in ms) from end of baseline to threshold crossing"}
	SetVariable End_7,format="%.1f",limits={-inf,inf,0},value= LAtime_1
	SetVariable End_03,pos={125,136},size={95,16},title="BL_1"
	SetVariable End_03,help={"Time interval (in ms) to calculate baseline"}
	SetVariable End_03,format="%.1f",limits={-inf,inf,0},value= blTime_1
	SetVariable Jump_1,pos={124,156},size={96,16},title="Jump_1",format="%.1f"
	SetVariable Jump_1,limits={-inf,inf,0},value= jumpTime_1
	SetVariable End_0010201,pos={125,176},size={95,16},title="peakwinT_1"
	SetVariable End_0010201,help={"Time window (in ms) from end of baseline to locate peak"}
	SetVariable End_0010201,format="%.2f"
	SetVariable End_0010201,limits={-inf,inf,0},value= peakWindowTime_1
	
		SetVariable Slope_1,pos={123,197},size={97,16},title="Slope_1"
	SetVariable Slope_1,help={"Slope of baseline (in mV/ms or pA/ms) used for rejection channel 1"}
	SetVariable Slope_1,format="%.2f",limits={-inf,inf,0},value= slope_1
	SetVariable End_0010101,pos={229,52},size={95,16},title="start_2"
	SetVariable End_0010101,help={"searchstart_2  in points -- start of analysis for adc2"}
	SetVariable End_0010101,format="%d",limits={-inf,inf,0},value= searchStart_2
	SetVariable End_2,pos={237,72},size={87,16},title="End_2"
	SetVariable End_2,help={"end of search in points"},format="%d"
	SetVariable End_2,limits={-inf,inf,0},value= searchEnd_2
	SetVariable End_5,pos={240,92},size={84,16},title="Thresh_2",format="%.3f"
	SetVariable End_5,limits={-inf,inf,0},value= Threshold_2
	SetVariable End_8,pos={255,113},size={69,16},title="LF_2"
	SetVariable End_8,help={"Time interval (in ms) from end of baseline to threshold crossing"}
	SetVariable End_8,format="%.1f",limits={-inf,inf,0},value= LAtime_2
	SetVariable End_06,pos={242,135},size={82,16},title="BL_2"
	SetVariable End_06,help={"Time interval (in ms) to calculate baseline"}
	SetVariable End_06,format="%.1f",limits={-inf,inf,0},value= blTime_2
	SetVariable Jump_2,pos={237,155},size={87,16},title="Jump_2",format="%.1f"
	SetVariable Jump_2,limits={-inf,inf,0},value= jumpTime_2
	
	SetVariable End_001020101,pos={229,176},size={95,16},title="peakwinT_2"
	SetVariable End_001020101,help={"Time window (in ms) from end of baseline to locate peak"}
	SetVariable End_001020101,format="%.2f"
	SetVariable End_001020101,limits={-inf,inf,0},value= peakWindowTime_2
	SetVariable Slope_2,pos={227,197},size={97,16},title="Slope_2",format="%.2f"
	SetVariable Slope_2,limits={-inf,inf,0},value= slope_2

	SetVariable End_10,pos={5,218},size={97,16},title="adc0_index",format="%d"
	SetVariable End_10,limits={-inf,inf,0},value= adc0_index
	SetVariable End_1001,pos={123,218},size={97,16},title="adc1_index",format="%d"
	SetVariable End_1001,limits={-inf,inf,0},value= adc1_index
	SetVariable End_100101,pos={227,218},size={97,16},title="adc2_index",format="%d"
	SetVariable End_100101,limits={-inf,inf,0},value= adc2_index
	
	SetVariable FindMinis01,pos={238,27},size={62,16},title="Autoflag",format="%d"
	SetVariable FindMinis01,limits={-inf,inf,0},value= autoFlag
	
	SetVariable setvar2,pos={7,266},size={131,16}
	SetVariable setvar2,help={"jump in samples after spike detection using spike_thresh"}
	SetVariable setvar2,format="%d",limits={-inf,inf,0},value= afterSpike
	SetVariable setvar3,pos={144,294},size={131,16}
	SetVariable setvar3,help={"jump in samples after spike detection using spike_thresh"}
	SetVariable setvar3,format="%d",limits={-inf,inf,0},value= num_prior_traces
	SetVariable setvar5,pos={11,294},size={120,16},title="Over ride init"
	SetVariable setvar5,help={"Prevent initiation of mini index"}
	SetVariable setvar5,limits={-inf,inf,0},value= over_ride_init
	SetVariable setvar6,pos={324,7},size={125,16},title="Mini_panel display"
	SetVariable setvar6,help={"0: displays all traces in mini_panel.  1: Displays only trace with mini detected"}
	SetVariable setvar6,format="%d"
	SetVariable setvar6,limits={-inf,inf,0},value= mini_panel_display_flag
	
	Button Save_Minis,pos={194,257},size={76,20},proc=save_minis,title="Save Minis"
	Button Save_Minis,help={"Copy current mini table and waves to a \"final\" table and waves"}
	Button Recover_Minis,pos={278,255},size={76,20},proc=save_minis,title="Recover Minis"
	Button Recover_Minis,help={"Copy mini waves from the \"final\" onto the current mini waves"}
	Button extract_column,pos={366,256},size={74,18},proc=extract_column,title="extract column"
	Button Exclude,pos={19,26},size={74,18},proc=EditExclude,title="ExcludeList"
	Button Exclude,help={"Edit list of excluded traces"}
	Button Exclude1,pos={115,26},size={74,18},proc=write_minis,title="WriteToFile"
	Button Exclude1,help={"Save minis to a disk file"}	
	
	SetVariable End_0010102,pos={338,53},size={95,16},title="start_3"
	SetVariable End_0010102,help={"searchstart_3  in points -- start of analysis for adc3"}
	SetVariable End_0010102,format="%d",limits={-inf,inf,0},value= searchStart_3
	SetVariable End_04,pos={356,75},size={87,16},title="End_3"
	SetVariable End_04,help={"end of search in points"},format="%d"
	SetVariable End_04,limits={-inf,inf,0},value= searchEnd_3
	SetVariable End_07,pos={359,95},size={84,16},title="Thresh_3",format="%.3f"
	SetVariable End_07,limits={-inf,inf,0},value= Threshold_3
	SetVariable End_09,pos={374,116},size={69,16},title="LF_3"
	SetVariable End_09,help={"Time interval (in ms) from end of baseline to threshold crossing"}
	SetVariable End_09,format="%.1f",limits={-inf,inf,0},value= LAtime_3
	SetVariable End_08,pos={361,138},size={82,16},title="BL_3"
	SetVariable End_08,help={"Time interval (in ms) to calculate baseline"}
	SetVariable End_08,format="%.1f",limits={-inf,inf,0},value= blTime_3
	SetVariable Jump_3,pos={356,158},size={87,16},title="Jump_3",format="%.1f"
	SetVariable Jump_3,limits={-inf,inf,0},value= jumpTime_3
	SetVariable End_001020102,pos={348,179},size={95,16},title="peakwinT_3"
	SetVariable End_001020102,help={"Time window (in ms) from end of baseline to locate peak"}
	SetVariable End_001020102,format="%.2f"
	SetVariable End_001020102,limits={-inf,inf,0},value= peakWindowTime_3
	SetVariable Slope_3,pos={346,200},size={97,16},title="Slope_3",format="%.2f"
	SetVariable Slope_3,limits={-inf,inf,0},value= slope_3
	SetVariable End_100102,pos={346,221},size={97,16},title="adc3_index",format="%d"
	SetVariable End_100102,limits={-inf,inf,0},value= adc3_index
	CheckBox KeepMinis,pos={339,28},size={67,14},title="KeepMinis"
	CheckBox KeepMinis,help={"if checked keep a segment of the wave containing the mini"}
	CheckBox KeepMinis,labelBack=(65280,16384,16384),variable= keep_minis
End





function set_daq_panel()
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4,adc_gain5,adc_gain6,adc_gain7
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	variable scale
	scale = 120/screenresolution
	scale = 1
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=( scale*9, scale*54.2, scale*663, scale*666.2) as "Select DAQ Settings"
	DoWindow /C SL_CH_panel
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (16384,28160,65280)
	DrawRect 7,60,274,328
	SetDrawEnv fillfgc= (65280,32768,32768)
	SetDrawEnv save
	DrawRect 317,59,615,596
	SetDrawEnv fsize= 16
	SetDrawEnv save
	SetDrawEnv fstyle= 1
	DrawText 26,38,"ANALOG OUTPUT CHANNELS"
	SetDrawEnv textrgb= (65280,32768,32768)
	SetDrawEnv save
	SetDrawEnv fstyle= 1,textrgb= (0,0,0)
	DrawText 355,37,"ANALOG INPUT CHANNELS"
	SetDrawEnv fillfgc= (65535,65535,65535)
	DrawRect 17,539,129,602
	DrawRect 135,423,134,423
	CheckBox check0,pos={18,78},size={66,20},title="DAC0",value=dac0_status,proc=set_dac0_status
	CheckBox check1,pos={19,139},size={60,20},title="DAC1",value=dac1_status,proc=set_dac1_status
	CheckBox check2,pos={20,214},size={59,20},title="DAC2",value=dac2_status,proc=set_dac2_status
	CheckBox check3,pos={19,282},size={62,27},title="DAC3",value=dac3_status,proc=set_dac3_status
	SetVariable setvar0,pos={116,75},size={153,21},fSize=14,value=dac0_gain,title="DAC0 Gain",font="Arial"
	SetVariable setvar1,pos={114,138},size={154,21},title="DAC1 Gain",font="Arial",fSize=14,value=dac1_gain
	SetVariable setvar2,pos={112,214},size={150,21},title="DAC2 Gain",font="Arial",fSize=14,value=dac2_gain
	SetVariable setvar3,pos={117,287},size={148,21},title="DAC3 Gain",font="Arial",fSize=14,value=dac3_gain
	CheckBox check4_0,pos={336,69},size={74,20},title="ADC0",value=adc_status0,proc=set_adc_status
	CheckBox check4_1,pos={337,137},size={74,20},title="ADC1",value=adc_status1,proc=set_adc_status
	CheckBox check4_2,pos={335,215},size={74,20},title="ADC2",value=adc_status2,proc=set_adc_status
	CheckBox check4_3,pos={333,286},size={74,20},title="ADC3",value=adc_status3,proc=set_adc_status
	CheckBox check4_4,pos={331,357},size={74,20},title="ADC4",value=adc_status4,proc=set_adc_status
	CheckBox check4_5,pos={334,420},size={74,20},title="ADC5",value=adc_status5,proc=set_adc_status
	CheckBox check4_6,pos={329,494},size={74,20},title="ADC6",value=adc_status6,proc=set_adc_status
	CheckBox check4_7,pos={331,565},size={74,20},title="ADC7",value=adc_status7,proc=set_adc_status
	SetVariable setvar4,pos={438,66},size={155,21},title="ADC0 Gain",font="Arial",fSize=14,proc=set_adc_gain,value=adc_gain0
	SetVariable setvar5,pos={442,136},size={155,21},title="ADC1 Gain",font="Arial",fSize=14,proc=set_adc_gain,value=adc_gain1
	SetVariable setvar6,pos={441,215},size={155,21},title="ADC2 Gain",font="Arial",fSize=14,proc=set_adc_gain,value=adc_gain2
	SetVariable setvar7,pos={441,286},size={155,21},title="ADC3 Gain",font="Arial",fSize=14,proc=set_adc_gain,value=adc_gain3
	SetVariable setvar9,pos={441,356},size={155,21},title="ADC4 Gain",font="Arial",fSize=14,proc=set_adc_gain,value=adc_gain4
	SetVariable setvar11,pos={442,421},size={155,21},title="ADC5 Gain",font="Arial",fSize=14,proc=set_adc_gain,value=adc_gain5
	SetVariable setvar13,pos={443,492},size={155,21},title="ADC6 Gain",font="Arial",fSize=14,proc=set_adc_gain,value=adc_gain6
	SetVariable setvar15,pos={440,558},size={155,21},title="ADC7 Gain",font="Arial",fSize=14,proc=set_adc_gain,value=adc_gain7
	Button button0,pos={37,551},size={71,36},proc=set_daq,title="DONE"	
//	Button button3,pos={265,141},size={50,20},proc=Set_cond,title="condense"	
//	Button button3,help={"Makes new wave with fewer points. Where new points are average of points on both sides. Use append to graph adcX_cond.  "}
End








function set_adc_gain(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName

	para_change()
	
End 

function p_create_data_file(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	
	create_data_file()
	
End 

function set_adc_status(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
// note that the Control name has in the seventh place the adc channle number

	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	NVAR freq, total_chan_num
	variable period

	para_change()
	if (checked)
		if(str2num(CntrlName[7]) == 0)
			adc_status0 = 1
		endif
		if(str2num(CntrlName[7]) == 1)
			adc_status1 = 1
		endif
		if(str2num(CntrlName[7]) == 2)
			adc_status2 = 1
		endif
		if(str2num(CntrlName[7]) == 3)
			adc_status3 = 1
		endif
		if(str2num(CntrlName[7]) == 4)
			adc_status4 = 1
		endif
		if(str2num(CntrlName[7]) == 5)
			adc_status5 = 1
		endif
		if(str2num(CntrlName[7]) == 6)
			adc_status6 = 1
		endif
		if(str2num(CntrlName[7]) == 7)
			adc_status7 = 1
		endif
	else
		if(str2num(CntrlName[7]) == 0)
			adc_status0 = 0
		endif
		if(str2num(CntrlName[7]) == 1)
			adc_status1 = 0
		endif
		if(str2num(CntrlName[7]) == 2)
			adc_status2 = 0
		endif
		if(str2num(CntrlName[7]) == 3)
			adc_status3 = 0
		endif
		if(str2num(CntrlName[7]) == 4)
			adc_status4 = 0
		endif
		if(str2num(CntrlName[7]) == 5)
			adc_status5 = 0
		endif
		if(str2num(CntrlName[7]) == 6)
			adc_status6 = 0
		endif
		if(str2num(CntrlName[7]) == 7)
			adc_status7 = 0
		endif
	Endif
	period  = round(1000/(freq * total_chan_num * 1.25))// used for ITC18
	freq = 1000/(period*1.25*total_chan_num) // changes freq to the real value

End 

function set_disp_status(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR disp_0, disp_1, disp_2, disp_3
	if (checked)
		if(str2num(CntrlName[1]) == 0)
			disp_0 = 1
		endif
		if(str2num(CntrlName[1]) == 1)
			disp_1 = 1
		endif
		if(str2num(CntrlName[1]) == 2)
			disp_2 = 1
		endif
		if(str2num(CntrlName[1]) == 3)
			disp_3 = 1
		endif
	else
		if(str2num(CntrlName[1]) == 0)
			disp_0 = 0
		endif
		if(str2num(CntrlName[1]) == 1)
			disp_1 = 0
		endif
		if(str2num(CntrlName[1]) == 2)
			disp_2 = 0
		endif
		if(str2num(CntrlName[1]) == 3)
			disp_3 = 0
		endif
	Endif
	init_g_traces()
End


function set_chan_status(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
// note that the Control name has in the third place the adc channle number

	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	NVAR dac0_status, dac1_status, dac2_status, dac3_status
	NVAR freq, total_chan_num
	NVAR disp_0, disp_1, disp_2, disp_3
	variable period
// CntrName is "ch" + channel number
	para_change()
	if (checked)
		if(str2num(CntrlName[2]) == 0)
			adc_status0 = 1
			dac0_status = 1
			disp_0 = 1
		endif
		if(str2num(CntrlName[2]) == 1)
			adc_status1 = 1
			dac1_status = 1
			disp_1 = 1
		endif
		if(str2num(CntrlName[2]) == 2)
			adc_status2 = 1
			dac2_status = 1
			disp_2 = 1
		endif
		if(str2num(CntrlName[2]) == 3)
			adc_status3 = 1
			dac3_status = 1
			disp_3 = 1
		endif
	else
		if(str2num(CntrlName[2]) == 0)
			adc_status0 = 0
			dac0_status = 0
			disp_0 = 0
		endif
		if(str2num(CntrlName[2]) == 1)
			adc_status1 = 0
			dac1_status = 0
			disp_1 = 0
		endif
		if(str2num(CntrlName[2]) == 2)
			adc_status2 = 0
			dac2_status = 0
			disp_2 = 0
		endif
		if(str2num(CntrlName[2]) == 3)
			adc_status3 = 0
			dac3_status = 0
			disp_3 = 0
		endif
	Endif
	checkbox d0, win=panel_AQ_D, value=disp_0
	checkbox d1, win=panel_AQ_D, value=disp_1
	checkbox d2, win=panel_AQ_D, value=disp_2
	checkbox d3, win=panel_AQ_D, value=disp_3
	period  = round(1000/(freq * total_chan_num * 1.25))// used for ITC18
	freq = 1000/(period*1.25*total_chan_num) // changes freq to the real value
	set_daq(CntrlName)

	init_g_traces()
End 




function set_stimfile(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR dac0_stimfile_flag,dac1_stimfile_flag,stimfile_loc,stimfile_ref, write_datapath
	NVAR samples,acquire_mode, stim_file_open
	SVAR stimfile_name
	para_change()
	if (checked)
		if (cmpstr(CntrlName[5,7], "100") == 0)
			dac0_stimfile_flag = 1
		Else
			dac1_stimfile_flag = 1
		Endif
		if (stim_file_open == 0)
			Open /R/T="****"/P=write_datapath stimfile_ref
			FStatus stimfile_ref
			if (V_flag != 0)
				stimfile_name = S_fileName
				FSetPos stimfile_ref, (samples*2*stimfile_loc)
				stim_file_open = 1
			Else
				beep; beep; beep
				printf "ERROR: could not open stim file (main)\r"
			Endif
		Endif
	Else
		if (acquire_mode == 0)
			FStatus stimfile_ref
			if (V_Flag != 0 )
				close (stimfile_ref)
				stim_file_open = 0
			Endif
		Endif
		if(cmpstr(CntrlName[5,7], "100") == 0)
			dac0_stimfile_flag = 0
			if (dac1_stimfile_flag == 0)
				FStatus stimfile_ref
				if (V_Flag != 0 )
					close (stimfile_ref)
					stim_file_open = 0
				Endif
			Else
				;
			Endif
		Else
			dac1_stimfile_flag = 0
			if (dac0_stimfile_flag == 0)
				FStatus stimfile_ref
				if (V_Flag != 0 )
					close (stimfile_ref)
					stim_file_open = 0
				Endif
			Else
				;
			Endif
		Endif
	Endif
End

function set_Scale_to_Vis(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR Scale_to_Vis
	if (checked)
		Scale_to_Vis = 1
	Else
		Scale_to_Vis = 0
	Endif
End


function set_dac0_status(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR dac0_status=dac0_status
	para_change()
	if (checked)
		dac0_status = 1
	Else
		dac0_status = 0
	Endif
End


function set_average_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag
	para_change()
	if (Cmpstr(CntrlName[3],"0") == 0)
		if (checked)
			adc0_avg_flag = 1
		Else
			adc0_avg_flag = 0
		EndIf
	Endif
	if (Cmpstr(CntrlName[3],"1") == 0)
		if (checked)
			adc1_avg_flag = 1
		Else
			adc1_avg_flag = 0
		EndIf
	Endif
	if (Cmpstr(CntrlName[3],"2") == 0)
		if (checked)
			adc2_avg_flag = 1
		Else
			adc2_avg_flag = 0
		EndIf
	Endif
	if (Cmpstr(CntrlName[3],"3") == 0)
		if (checked)
			adc3_avg_flag = 1
		Else
			adc3_avg_flag = 0
		EndIf
	Endif
	init_g_average(0)
End

function set_sine_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR sine_flag_dac0=sine_flag_dac0, sine_flag_dac1=sine_flag_dac1
	para_change()
	if (Cmpstr(CntrlName[5],"3") == 0)
		if (checked)
			sine_flag_dac0 = 1
		Else
			sine_flag_dac0 = 0
		Endif
	Else
		if (checked)
			sine_flag_dac1 = 1
		Else
			sine_flag_dac1 = 0
		Endif
	Endif
End

function set_psc_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR dac0_psc_flag=dac0_psc_flag, dac1_psc_flag=dac1_psc_flag
	para_change()
	if (checked)
		if (cmpstr(CntrlName[5,6],"10") == 0)
			dac0_psc_flag = 1
		Else
			dac1_psc_flag = 1
		Endif
	Else
		if (cmpstr(CntrlName[5,6],"10") == 0)
			dac0_psc_flag = 0
		Else
			dac1_psc_flag = 0
		Endif
	Endif
End

function set_keep(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR keepDAC = $CntrlName
	if (checked)
		keepDAC = 1
	Else
		keepDAC = 0
	Endif
End


function set_his_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR his_flag=his_flag
	if (checked)
		his_flag = 1
		DoWindow /F S_Histogram
	Else
		his_flag = 0
	Endif
End


function set_init_display(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR init_display
	if (checked)
		init_display = 1
		init_g_traces()
		init_g_average(1) // bring it to the front
//		DoWindow /F Panel_AQ_C
	Else
		init_display = 0
	Endif
End

function set_init_average(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR initialize
	if (checked)
		initialize = 1
	Else
		initialize = 0
	Endif
End


function set_init_analysis_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR init_analysis=init_analysis
	if (checked)
		init_analysis = 1
		DoWindow /F H_Panel
	Else
		init_analysis = 0
	Endif
End


function set_search_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR search_flag=search_flag
	if (checked)
		search_flag = 1
	Else
		search_flag = 0
	Endif
End

function set_initialize(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR initialize=initialize
	if (checked)
		initialize = 1
	Else
		initialize = 0
	Endif
End



function set_spike_cv_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR spike_cv_flag=spike_cv_flag
	if (checked)
		spike_cv_flag = 1
	Else
		spike_cv_flag = 0
	Endif
End


function set_stimfile_recycle(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR stimfile_recycle=stimfile_recycle
	para_change()
	if (checked)
		stimfile_recycle = 1
	Else
		stimfile_recycle = 0
	Endif
End



function set_vc_cc(CntrlName, checked) : CheckBoxControl
	String CntrlName // should be: check_vc# or check_cc#
	Variable checked
	NVAR amp_type // :0 200A/B; 1: MC700A
	NVAR write_permit,freq,samples
	NVAR dac_vc = $("dac"+CntrlName[8]+"_vc")
	NVAR dac_cc = $("dac"+CntrlName[8]+"_cc")
	WAVE adc = $("adc"+CntrlName[8])
	NVAR dac_gain = $("dac"+CntrlName[8]+"_gain")
	NVAR hp = $("hp"+CntrlName[8])
	NVAR adc_gain = $("adc_gain"+CntrlName[8])
//	Return 0
	if (checked)
		if (cmpstr(CntrlName[6],"v") == 0) // voltage clamp has been checked
			dac_vc = 1
			dac_cc = 0
			if (str2Num(CntrlName[8]) == 0) // 0 channel
				CheckBox check_cc0, value=0 // uncheck cc
			Elseif (str2Num(CntrlName[8]) == 1)						     
				CheckBox check_cc1, value=0 // uncheck cc
			Elseif (str2Num(CntrlName[8]) == 2)						     
				CheckBox check_cc2, value=0 // uncheck cc
			Elseif (str2Num(CntrlName[8]) == 3)						     
				CheckBox check_cc3, value=0 // uncheck cc
			Endif
//			write_permit = 0
//			freq = 100
//			samples = 2000
			dac_gain = 50*1.05 // to adjust for shunt of ITC18 to Multiclamp
			if (amp_type == 1)
				adc_gain = 2.5 // corresponds to 2.5 V/nA in scaled output of MC 700A 
			Else
				adc_gain = 2.0 // 200A/B
			EndIf 
			hp = -70
			SetScale d, -200, 200, "pA", adc
		Else							// current clamp has been checked
			dac_vc = 0
			dac_cc = 1
			if (str2Num(CntrlName[8]) == 0)
				CheckBox check_vc0, value=0 // uncheck vc
			ElseIf(str2Num(CntrlName[8]) == 1) 
				CheckBox check_vc1, value=0 // uncheck vc
			ElseIf(str2Num(CntrlName[8]) == 2)
				CheckBox check_vc2, value=0 // uncheck vc
			ElseIf(str2Num(CntrlName[8]) == 3)
				CheckBox check_vc3, value=0 // uncheck vc
			Endif
//			freq = 10
//			samples = 5000
			if (amp_type == 1)
				dac_gain = 2.5 * 1.05 // for MC700A
			Else
				dac_gain = 0.5 * 1.05
			EndIf
			adc_gain = 100
			hp = 0
			SetScale d, -200, 200, "mV", adc
		Endif
	Else
		if (cmpstr(CntrlName[6],"v") == 0) //  VC has been unchecked
			dac_vc = 0
			dac_cc = 1
			if (str2Num(CntrlName[8]) == 0)
				CheckBox check_cc0, value=1 // check cc
			Elseif (str2Num(CntrlName[8]) == 1)
				CheckBox check_cc1, value=1 // check cc
			Elseif (str2Num(CntrlName[8]) == 2)
				CheckBox check_cc2, value=1 // check cc
			Elseif (str2Num(CntrlName[8]) == 3)
				CheckBox check_cc3, value=1 // check cc
			Endif
//			freq = 10
//			samples = 5000
			if (amp_type == 1)
				dac_gain = 2.5 * 1.05 // MC: 400 pA - V
			Elseif (amp_type == 0)
				dac_gain = 0.5 * 1.05
			EndIf
			adc_gain = 100
			hp = 0
			SetScale d, -200, 200, "mV", adc
		Else
			dac_vc = 0
			dac_cc = 1
			if (str2Num(CntrlName[8]) == 0)
				CheckBox check_vc0, value=1 // check cc
			elseif (str2Num(CntrlName[8]) == 1)
				CheckBox check_vc1, value=1 // check cc
			elseif (str2Num(CntrlName[8]) == 2)
				CheckBox check_vc2, value=1 // check cc
			elseif (str2Num(CntrlName[8]) == 3)
				CheckBox check_vc3, value=1 // check cc
			Endif
//			write_permit = 0
//			samples = 2000
//			freq = 100
			dac_gain = 50*1.05
			if (amp_type == 1)
				adc_gain = 2.5 
			Else
				adc_gain = 2.0
			EndIf
			hp = -70
			SetScale d, -200, 200, "pA", adc
		Endif
	Endif
	set_in()
	set_sweep_time()
	checkbox check0, win=panel_AQ_D, value=write_permit 
	para_change()
End



function set_dac1_status(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR dac1_status=dac1_status
	para_change()
	if (checked)
		dac1_status = 1
	Else
		dac1_status = 0
	Endif
End

function set_dac2_status(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR dac2_status=dac2_status
	para_change()
	if (checked)
		dac2_status = 1
	Else
		dac2_status = 0
	Endif
End

function set_dac3_status(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR dac3_status=dac3_status
	if (checked)
		dac3_status = 1
	Else
		dac3_status = 0
	Endif
End





function set_daq(CntrlName) : ButtonControl
	String CntrlName
	WAVE adc0, adc1, adc2, adc3
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	SVAR seq_in, seq_out
	NVAR total_chan_num, ttl_status, freq
	NVAR fake_chan
	variable dac_sum, adc_sum, i, period
	
	para_change()
	
	period  = round(1000/(freq * total_chan_num * 1.25))// used for ITC18
	freq = 1000/(period*1.25*total_chan_num) // changes freq to the real value

	seq_in = ""
	seq_out = ""
	dac_sum = dac0_status+dac1_status+dac2_status+dac3_status+ttl_status
	// to allow even intervals between samples
	if (dac_sum == 3)
		fake_chan = 1
	Else
		fake_chan = 0
	Endif
// seq_out	
	if (dac0_status == 1)
		seq_out += "0"
	Endif
	if (dac1_status == 1)
		seq_out += "1"
	Endif
	if (dac2_status == 1)
		seq_out += "2"
	Endif
	if (dac3_status == 1)
		seq_out += "3"
	Endif
	if (ttl_status == 1)
		seq_out += "D"
	Endif
	if (fake_chan)
		seq_out += "D"
	EndIf

// seq_in
	if (adc_status0 == 1)
		seq_in += "0"
	Else
		adc0 = 0
	endif
	if (adc_status1 == 1)
		seq_in += "1"
	Else
		adc1 = 0
	endif
	if (adc_status2 == 1)
		seq_in += "2"
	Else
		adc2 = 0
	endif
	if (adc_status3 == 1)
		seq_in += "3"
	Else
		adc3 = 0
	endif
	if (adc_status4 == 1)
		seq_in += "4"
	endif
	if (adc_status5 == 1)
		seq_in += "5"
	endif
	if (adc_status6 == 1)
		seq_in += "6"
	endif
	if (adc_status7 == 1)
		seq_in += "7"
	endif
	if (ttl_status == 1)
		seq_in += "D"
	endif
	if (fake_chan)
		seq_in += "D"
	EndIf
	dac_sum = dac0_status+dac1_status+dac2_status+dac3_status+ttl_status + fake_chan
	adc_sum = adc_status0+adc_status1+adc_status2+adc_status3+adc_status4+adc_status5+adc_status6+adc_status7+ttl_status +fake_chan

	if (dac_sum != adc_sum) // for now
		BEEP; BEEP; BEEP
		printf  "ERROR: dac_sum=%d, adc_sum=%d (main)\r", dac_sum, adc_sum
		printf "dac0_status = %d\r", dac0_status
	else
		total_chan_num = dac_sum
	Endif
	period  = round(1000/(freq * total_chan_num * 1.25))// used for ITC18
	freq = 1000/(period*1.25*total_chan_num) // changes freq to the real value
		if (dac0_status && adc_status0)
		checkbox ch0, win=panel_aq_d, value = 1
	Else
		checkbox ch0, win=panel_aq_d, value = 0
	Endif
	if (dac1_status && adc_status1)
		checkbox ch1, win=panel_aq_d, value = 1
	Else
		checkbox ch1, win=panel_aq_d, value = 0
	Endif
	if (dac2_status && adc_status2)
		checkbox ch2, win=panel_aq_d, value = 1
	Else
		checkbox ch2, win=panel_aq_d, value = 0
	Endif
	if (dac3_status && adc_status3)
		checkbox ch3, win=panel_aq_d, value = 1
	Else
		checkbox ch3, win=panel_aq_d, value = 0
	Endif
	DoWindow /K SL_CH_panel
End



function Init_G_traces()

	NVAR adc_status0, adc_status1, adc_status2, adc_status3
	NVAR disp_0, disp_1, disp_2, disp_3
	NVAR line_size
//	DoWindow /K G_Traces
	PauseUpdate; Silent 1		// building window...
//	Display /W=(4.032,38.432,399.744,214.688)
//	DoWindow /C G_Traces
	DoWindow/F G_Traces
	if (adc_status0 && disp_0)
		checkdisplayed adc0
		if (v_flag==0)
			AppendToGraph/L=left adc0
		Endif
		Modifygraph /z lsize(adc0)=line_size
	EndIf
	if (adc_status1 && disp_1)
		checkdisplayed adc1
		if (v_flag==0)
			AppendToGraph/R adc1
		Endif
		Modifygraph /z lsize(adc1)=line_size
	Endif
	if (adc_status2 && disp_2)
		checkdisplayed adc2
		if (v_flag==0)
			AppendToGraph/L=left2 adc2
			Modifygraph /z lsize(adc2)=line_size
		Endif	
	EndIf
	If (adc_status3 && disp_3)
		checkdisplayed adc3
		if (v_flag==0)
			AppendToGraph/R=right2 adc3	
		Endif
		Modifygraph /z lsize(adc3)=line_size
	EndIf
	if (adc_status0 == 0 || (disp_0 == 0))
		checkdisplayed adc0
		if (V_flag)
			RemoveFromGraph adc0
		Endif
	EndIf
	if (adc_status1 == 0 || (disp_1 == 0))
		checkdisplayed adc1
		if (V_flag)
			RemoveFromGraph adc1
		Endif
	EndIf
	if (adc_status2 == 0 || (disp_2 == 0))
		checkdisplayed adc2
		if (V_flag)
			RemoveFromGraph adc2
		Endif
	EndIf
	if (adc_status3 == 0 || (disp_3 == 0))
		checkdisplayed adc3
		if (V_flag)
			RemoveFromGraph adc3
		Endif
	EndIf
	ModifyGraph/z rgb(adc2)=(0,52224,0),rgb(adc1)=(0,43520,65280),rgb(adc3)=(0,0,0)
	ModifyGraph/z tick(right)=2,tick(right2)=2,tick(left2)=2,tick(left)=2
	ModifyGraph/z font(left)="Arial",font(left2)="Arial",font(right)="Arial",font(right2)="Arial"
	ModifyGraph/z fSize(left)=8,fSize(left2)=8,fSize(right)=8,fSize(right2)=8
	ModifyGraph/z axOffset(right)=4.66667,axOffset(left2)=-10,axOffset(left)=4.14286
	ModifyGraph/z lblPos(left)=44,lblPos(left2)=-6
	ModifyGraph/z lblLatPos(left2)=-1
	ModifyGraph/z lblRot(right2)=-180
	ModifyGraph/z btLen(left)=1,btLen(left2)=1,btLen(right)=1,btLen(right2)=1
	ModifyGraph/z btThick(left)=1,btThick(left2)=1,btThick(right)=1,btThick(right2)=1
	ModifyGraph/z stLen(left)=0.5,stLen(left2)=0.5,stLen(right)=0.5,stLen(right2)=0.5
	ModifyGraph/z stThick(left)=1,stThick(left2)=1,stThick(right)=1,stThick(right2)=1
	if (adc_status0 && disp_0 && ((disp_2 == 0) || (adc_status2 == 0)))
		ModifyGraph/z margin(left)=22
	EndIf
	if ((adc_status0 && disp_0) && ((disp_2 == 1) && (adc_status2 == 1)))
		ModifyGraph/z margin(left)=40
	EndIf

	if (adc_status1 && disp_1 && ((disp_3 == 0) || (adc_status3 == 0)))
		ModifyGraph/z margin(right)=22
	EndIf
	if ((adc_status1 && disp_1) && (disp_3 && adc_status3))
		ModifyGraph/z margin(right)=50
	EndIf
	
	if (adc_status0 && disp_0)
		ModifyGraph/z freePos(left2)=21
	else
		ModifyGraph/z freePos(left2)=5
	EndIf
//	if (adc_status3 && disp_3 && ((disp_1 == 0) || (adc_status1 == 0)))
//		ModifyGraph/z margin(right2)=22
//	EndIf

	if (adc_status1 && disp_1)
		ModifyGraph/z freePos(right2)=28
	else
		ModifyGraph/z freePos(right2)=0
	EndIf
//	if (adc_status0 == 0)
//		ModifyGraph/z freePos(left2)=5
//	Else
//		ModifyGraph/z freePos(left2)=21
//	Endif
//	if (adc_status1 == 0)
//		ModifyGraph/z freePos(right2)=0
//	Else
//		ModifyGraph/z freePos(right2)=20
//	Endif
	Label/z left "\\u#2"
	Label/z left2 "\\u#2"
	Label/z right "\\u#2"
	Label/z right2 "\\u#2"
//	SetAxis/z/A/N=2 left
//	if (adc_status0)
//		Cursor/P A adc0 645;Cursor/P B adc0 745
//	Endif
	ModifyGraph/z tlblRGB(left)=(65280,0,0),tlblRGB(left2)=(0,52224,0);DelayUpdate
	ModifyGraph/z tlblRGB(right)=(0,43520,65280)
End


function Init_G_average(flag)
variable flag

	NVAR adc_status0, adc_status1, adc_status2, adc_status3
	NVAR adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag
	NVAR line_size, init_display

//	DoWindow /K G_Traces
	PauseUpdate; Silent 1		// building window...
//	Display /W=(4.032,38.432,399.744,214.688)
//	DoWindow /C G_Traces
	if (flag) // bring window to the front
		DoWindow/F G_Average
	Endif
	if (adc_status0)
		checkdisplayed /W=G_Average adc0_avg_0
		if (v_flag==0 && init_display)
			AppendToGraph/W=G_Average /L=left adc0_avg_0
		Endif
		Modifygraph /W=G_Average /z lsize(adc0_avg_0)=line_size
	EndIf
	if (adc_status1)
		checkdisplayed /W=G_Average adc1_avg_0
		if (v_flag==0 && init_display)
			AppendToGraph/W=G_Average /R adc1_avg_0
		Endif
		Modifygraph /W=G_Average /z lsize(adc1_avg_0)=line_size
	Endif
	if (adc_status2)
		checkdisplayed /W=G_Average adc2_avg_0
		if (v_flag==0 && init_display)
			AppendToGraph/W=G_Average /L=left2 adc2_avg_0
		Endif
		Modifygraph /W=G_Average /z lsize(adc2_avg_0)=line_size
	EndIf
	If (adc_status3)
		checkdisplayed /W=G_Average adc3_avg_0
		if (v_flag==0 && init_display)
			AppendToGraph/W=G_Average /R=right2 adc3_avg_0
		Endif
		Modifygraph /W=G_Average /z lsize(adc3_avg_0)=line_size
	EndIf
	if (adc_status0 == 0 || (adc0_avg_flag == 0))
		checkdisplayed /W=G_Average adc0_avg_0
		if (V_flag && init_display)
			RemoveFromGraph /W=G_Average adc0_avg_0
		Endif
	EndIf
	if (adc_status1 == 0 || (adc1_avg_flag == 0))
		checkdisplayed /W=G_Average adc1_avg_0
		if (V_flag && init_display)
			RemoveFromGraph /W=G_Average adc1_avg_0
		Endif
	EndIf
	if (adc_status2 == 0 || (adc2_avg_flag == 0))
		checkdisplayed /W=G_Average adc2_avg_0
		if (V_flag && init_display)
			RemoveFromGraph /W=G_Average adc2_avg_0
		Endif
	EndIf
	if (adc_status3 == 0 || (adc3_avg_flag == 0))
		checkdisplayed /W=G_Average adc3_avg_0
		if (V_flag && init_display)
			RemoveFromGraph /W=G_Average adc3_avg_0
		Endif
	EndIf
	
	ModifyGraph/W=G_Average /z rgb(adc2_avg_0)=(0,52224,0),rgb(adc1_avg_0)=(0,43520,65280),rgb(adc3_avg_0)=(0,0,0)
	ModifyGraph/W=G_Average /z tick(right)=2,tick(right2)=2,tick(left2)=2,tick(left)=2
	ModifyGraph/W=G_Average /z font(left)="Arial",font(left2)="Arial",font(right)="Arial",font(right2)="Arial"
	ModifyGraph/W=G_Average /z fSize(left)=8,fSize(left2)=8,fSize(right)=8,fSize(right2)=8
	ModifyGraph/W=G_Average /z axOffset(right)=4.66667,axOffset(left2)=-10,axOffset(left)=4.14286
	ModifyGraph/W=G_Average /z lblPos(left)=44,lblPos(left2)=-6
	ModifyGraph/W=G_Average /z lblLatPos(left2)=-1
	ModifyGraph/W=G_Average /z lblRot(right2)=-180
	ModifyGraph/W=G_Average /z btLen(left)=1,btLen(left2)=1,btLen(right)=1,btLen(right2)=1
	ModifyGraph/W=G_Average /z btThick(left)=1,btThick(left2)=1,btThick(right)=1,btThick(right2)=1
	ModifyGraph/W=G_Average /z stLen(left)=0.5,stLen(left2)=0.5,stLen(right)=0.5,stLen(right2)=0.5
	ModifyGraph/W=G_Average /z stThick(left)=1,stThick(left2)=1,stThick(right)=1,stThick(right2)=1
	
//	-------------
	if (adc_status0 && adc0_avg_flag && ((adc2_avg_flag == 0) || (adc_status2 == 0)))
		ModifyGraph/W=G_Average /z margin(left)=22
	EndIf
	if ((adc_status0 && adc0_avg_flag) && ((adc2_avg_flag == 1) && (adc_status2 == 1)))
		ModifyGraph/W=G_Average /z margin(left)=40
	EndIf

	if (adc_status1 && adc1_avg_flag && ((adc3_avg_flag == 0) || (adc_status3 == 0)))
		ModifyGraph/W=G_Average /z margin(right)=22
	EndIf
	if ((adc_status1 && adc1_avg_flag) && (adc3_avg_flag && adc_status3))
		ModifyGraph/W=G_Average /z margin(right)=50
	EndIf
	
	if (adc_status0 && adc0_avg_flag)
		ModifyGraph/W=G_Average /z freePos(left2)=21
	else
		ModifyGraph/W=G_Average /z freePos(left2)=5
	EndIf
	if (adc_status3 && adc3_avg_flag)
		ModifyGraph/W=G_Average /z freePos(right2)=28
	else
		ModifyGraph/W=G_Average /z freePos(lright2)=0
	EndIf
//	--------------
//	if (adc_status0 && adc0_avg_flag)
//		ModifyGraph/W=G_Average /z freePos(left2)=24
//	else
//		ModifyGraph/W=G_Average /z freePos(left2)=5
//	EndIf
//	if (adc_status3 && adc3_avg_flag)
//		ModifyGraph/W=G_Average /z freePos(right2)=28
//	else
//		ModifyGraph/W=G_Average /z freePos(lright2)=0
//	EndIf
	Label/W=G_Average /z left "\\u#2"
	Label/W=G_Average /z left2 "\\u#2"
	Label/W=G_Average /z right "\\u#2"
	Label/W=G_Average /z right2 "\\u#2"
//	SetAxis/z/A/N=2 left
//	if (adc_status0)
//		Cursor/W=G_Average /P A adc0_avg_0 645;Cursor/P B adc0_avg_0 745
//	Endif
	ModifyGraph/W=G_Average /z tlblRGB(left)=(65280,0,0),tlblRGB(left2)=(0,52224,0);DelayUpdate
	ModifyGraph/W=G_Average /z tlblRGB(right)=(0,43520,65280)
	ResumeUpdate	
End



function init_graphs()

NVAR adc_status0, adc_status1, adc_status2, adc_status3
	DoWindow /K G_Traces
	PauseUpdate; Silent 1		// building window...
	variable scale
	scale = 120/screenresolution
	scale = 1
	
	Display /M/W=(0.0, 0.0, 14.1, 6.5)
	DoWindow /C G_Traces
	init_g_traces()

//	DoWindow /K G_DPoints
//	PauseUpdate; Silent 1		// building window...
//	Display /W=(scale*4.2, scale*234.8, scale*399.6, scale*413.6) dpoints_wave vs dpoints_time as "Data_Points"
//	SetAxis /A/N=2 left
//	DoWindow /C G_DPoints
//	ModifyGraph mode=3
//	ModifyGraph marker=8
//	ModifyGraph rgb=(0,0,0)


	DoWindow /K histo_vm_graph
	Display /W=(scale*4.2, scale*234.2, scale*400.2, scale*412.4) histog_vm
	DoWindow /C histo_vm_graph
	ModifyGraph mode=6
	ModifyGraph rgb=(0,0,0)


	Dowindow /K S_Histogram
	Display /W=(scale*4.2, scale*234.8, scale*399.6, scale*413.6) psth as "S_histogram"
	DoWindow /C S_Histogram
	ModifyGraph mode=6
	ModifyGraph rgb=(0,0,0)

	DoWindow /K ISI_Graph
	Display /W=(scale*6.6, scale*237.8, scale*402, scale*408.8) isi_wave
	doWindow /C ISI_Graph
	ModifyGraph mode=4
	ModifyGraph msize=3
	ModifyGraph marker=19
	ModifyGraph rgb=(0,15872,65280)
//	Cursor A isi_wave leftX(isi_wave);Cursor B isi_wave rightX(isi_wave)
	Dowindow /K G_Average
	Display /M/W=(0.0, 8.0,14.1,14.5)
	DoWindow /c G_Average
	init_g_average(1)
End


function select_dac0(CntrlName) : ButtonControl
	String CntrlName
	DoWindow /F DAC0_panel
	edit_dac0("")
End
function select_dac1(CntrlName) : ButtonControl
	String CntrlName
	DoWindow /F DAC1_panel
	edit_dac1("")
End
function select_dac2(CntrlName) : ButtonControl
	String CntrlName
	DoWindow /F DAC2_panel
	edit_dac2("")
End
function select_dac3(CntrlName) : ButtonControl
	String CntrlName
	DoWindow /F DAC3_panel
	edit_dac3("")
End





Function select_DAQ_Panel(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	NVAR ttl_num // the number of the current TTL channel
	if (popNum == 1)
		doWindow /F DAC0_panel
	Endif
	if (popNum == 2)
		doWindow /F DAC1_Panel
	Endif
	if (popNum == 3)
		doWindow /F DAC2_Panel
	Endif
	if (popnum == 4)
		doWindow /F DAC3_Panel
	Endif
	if (popnum == 5)
		//DoWindow /F ttl1_panel
		make_ttl_panel(ttl_num)
	Endif
	if (popNum == 6)
		doWindow /F PP_Panel
	Endif
	if (popNum == 7)
		doWindow /F H_Panel
	Endif
	if (popNum == 8)
		doWindow /F F_panel
	Endif
	if (popnum == 9)
		Make_Amp_Analysis_Panel()
		doWindow /F AMP_Panel
	Endif
	if (popNum == 10)
		set_daq_panel()
		DoWindow /F SL_CH_panel
	Endif
	if (popnum == 11)
		Make_Scheme_Panel(CtrlName)
	Endif
End


Function select_fit (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	NVAR fit_type=fit_type
	if (popNum == 1)
		fit_type = 1
		fit_exp()
	Endif
	if (popNum == 2)
		fit_type = 2
		fit_exp()
	Endif
	if (popNum == 3)
		fit_type = 3
		fit_exp()
	Endif

End


Function Select_fit_trace(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	 SVAR fit_trace_name=fit_trace_name
	fit_trace_name = popStr
End



Function Select_Align_Trace (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	 SVAR align_trace_name=align_trace_name
	align_trace_name = popStr
End

Function Select_Smooth_Trace (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	 SVAR smooth_trace_name=smooth_trace_name
	smooth_trace_name = popStr
End

Function Select_Align_Par (ctrlName) : ButtonControl
	String ctrlName
//	Variable popNum	// which item is currently selected (1-based)
//	String popStr		// contents of current popup item as string
	SVAR align_trace_name, read_file_name
	NVAR align_start, align_end, align_index
	align_start = pcsr(a)
	align_end = pcsr(b)
	align_index = align_start + 0.5 * (align_end-align_start)
	align_trace_name = csrWave(a)
	printf "Read file name: %s, align parameters: trace: %s, start: %d, end: %d, index: %d\r", read_file_name, align_trace_name, align_start, align_end, align_index
End

Function Select_Amp_Trace (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	 SVAR amp_trace_name=amp_trace_name
	amp_trace_name = popStr
End


function c_get_a_trace(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	NVAR trace_num=trace_num
	get_a_trace(trace_num)
End


function set_dac0_pulse_num(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	WAVE dac0_start=dac0_start, dac0_end=dac0_end, dac0_amp=dac0_amp
	NVAR dac0_pulse_num=dac0_pulse_num
	para_change()
	dac0_start[dac0_pulse_num, ] = 0
	dac0_end[dac0_pulse_num, ] = 0
	dac0_amp[dac0_pulse_num, ] = 0
	set_stim()
	set_in()
End


function set_ttl1_pulse_num(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	WAVE ttl1_start=ttl1_start, ttl1_end=ttl1_end
	NVAR ttl1_pulse_num=ttl1_pulse_num
	para_change()
	ttl1_start[ttl1_pulse_num, ] = 0
	ttl1_end[ttl1_pulse_num, ] = 0
	set_stim()
	set_in()
End


function set_ttl2_pulse_num(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	WAVE ttl2_start=ttl2_start, ttl2_end=ttl2_end
	NVAR ttl2_pulse_num=ttl2_pulse_num
	para_change()
	ttl2_start[ttl2_pulse_num, ] = 0
	ttl2_end[ttl2_pulse_num, ] = 0
	set_stim()
	set_in()
End

function print_index(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	printf "align_index: %d\r", varNum
End

Function ContCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	para_change()
End


function set_para_change(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	para_change()
End

function set_stim_loc(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	NVAR stimfile_ref=stimfile_ref,acquire_mode=acquire_mode,dac0_stimfile_flag=dac0_stimfile_flag
	NVAR samples=samples,freq=freq,dac0_stimfile_scale=dac0_stimfile_scale,stimfile_loc=stimfile_loc
	para_change()
	if ((acquire_mode == 0) %& (dac0_stimfile_flag == 1))
		Make /O/N=(samples) stimfile_wave
		SetScale /P x 0, (1.0/freq), "ms", stimfile_wave
	Endif
	FStatus stimfile_ref
	if (V_flag != 0)
		FSetPos stimfile_ref, (stimfile_loc * samples * 2) 
		FBinRead /F=2 stimfile_ref, stimfile_wave
		stimfile_wave *= dac0_stimfile_scale
	Endif
	DoUpDate
End


function edit_ttl1(CntrlName) : ButtonControl
	String CntrlName
	para_change()
	DoWindow table_ttl1
	if (V_flag == 1)
		DoWindow /F table_ttl1
		Return(0)
	Endif
	edit ttl1_start, ttl1_end
	DoWindow /C table_ttl1
End



function edit_ttl2(CntrlName) : ButtonControl
	String CntrlName
	para_change()
	DoWindow table_ttl2
	if (V_flag == 1)
		DoWindow /F table_ttl2
		Return(0)
	Endif
	edit ttl2_start, ttl2_end
	DoWindow /C table_ttl2
End



function accept_ttl1(CntrlName) : ButtonControl
	String CntrlName
	set_stim()
	DoWindow table_ttl1
	if (V_Flag == 1)
		DoWindow /K table_ttl1
	Endif
	DoWindow ttl_display
	if (V_flag == 1)
		DoWindow /K ttl_display
	Endif
End


function accept_ttl2(CntrlName) : ButtonControl
	String CntrlName
	set_stim()
	DoWindow table_ttl2
	if (V_Flag == 1)
		DoWindow /K table_ttl2
	Endif
	DoWindow ttl_display
	if (V_flag == 1)
		DoWindow /K ttl_display
	Endif
End


function accept_dac0(CntrlName) : ButtonControl
	String CntrlName
	set_stim()
	DoWindow table_dac0
	if (V_Flag == 1)
		DoWindow /K table_dac0
	Endif
	DoWindow stimwave_display
	if (V_flag == 1)
		DoWindow /K stimwave_display
	Endif
End

function set_isi(CntrlName) : ButtonControl
	String CntrlName
	NVAR spike_start, spike_end
	SVAR spike_detection_trace_name
	spike_start =  pcsr(a)
	spike_end =  pcsr(b)
	spike_detection_trace_name = CsrWave(a)
End



function get_isi(CntrlName) : ButtonControl
	String CntrlName
	NVAR samples, spike_thresh, spike_duration,freq
	NVAR spike_start, spike_end
	NVAR spike_cv
	SVAR spike_detection_trace_name
	Make /O/N=500 detections
	variable number_of_spikes, i
	DoWindow /F ISI_Graph
	number_of_spikes = Detect_ap_peaks($spike_detection_trace_name, spike_thresh, spike_duration, spike_start, spike_end, detections)
	if (number_of_spikes <= 2)
		printf "only %d spikes\r", number_of_spikes
		Return(0)
	Endif	
	Make /O/N=(number_of_spikes-1) isi_wave
	i = 0
	do
		isi_wave[i] = detections[i+1] - detections[i]
		i += 1
	While(i < (number_of_spikes-1))
	isi_wave *= (1/freq)
	SetScale d, 0, 1000, "Interval (ms)", isi_wave
	SetScale /P x, 0, 1, "Spike #", isi_wave
	WaveStats /Q isi_wave
	spike_cv = V_sdev / V_avg
End


function display_dac0(CntrlName) : ButtonControl
	String CntrlName
	set_stim()	
	WAVE dac0_stimwave=dac0_stimwave
	NVAR freq=freq, samples=samples, dac0_gain=dac0_gain, dac0_vc=dac0_vc
	variable scale
	scale = 120/screenresolution
	scale = 1
	Make /O/N=(samples) twave
	twave = dac0_stimwave / (3.2 * dac0_gain)
	SetScale /P x, 0, (1/freq), "ms", twave
	if (dac0_vc == 1)
		SetScale d, -200, 200, "mV", twave
	Else
		SetScale d, -200, 200, "pA", twave
	Endif
	DoWindow Excitation_Graph
	if (V_flag == 1)
		DoWindow /F Excitation_Graph
		Return(0)
	Endif
	Display /W=(scale*3.6, scale*236, scale*397.2, scale*412.4) twave	 
	DoWindow /C Excitation_Graph
End




function set_dac1_pulse_num(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	WAVE dac1_start=dac1_start, dac1_end=dac1_end, dac1_amp=dac1_amp
	NVAR dac1_pulse_num=dac1_pulse_num
	para_change()
	dac1_start[dac1_pulse_num, ] = 0
	dac1_end[dac1_pulse_num, ] = 0
	dac1_amp[dac1_pulse_num, ] = 0
	set_stim()
	set_in()
End

function set_dac2_pulse_num(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	WAVE dac2_start=dac2_start, dac2_end=dac2_end, dac2_amp=dac2_amp
	NVAR dac2_pulse_num=dac2_pulse_num
	para_change()
	dac2_start[dac2_pulse_num, ] = 0
	dac2_end[dac2_pulse_num, ] = 0
	dac2_amp[dac2_pulse_num, ] = 0
	set_stim()
	set_in()
End

function set_dac3_pulse_num(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	WAVE dac3_start, dac3_end, dac3_amp
	NVAR dac3_pulse_num
	para_change()
	dac3_start[dac3_pulse_num, ] = 0
	dac3_end[dac3_pulse_num, ] = 0
	dac3_amp[dac3_pulse_num, ] = 0
	set_stim()
	set_in()
End



function accept_dac1(CntrlName) : ButtonControl
	String CntrlName
	set_stim()
	DoWindow table_dac1
	if (V_Flag == 1)
		DoWindow /K table_dac1
	Endif
	DoWindow stimwave_display
	if (V_flag == 1)
		DoWindow /K stimwave_display
	Endif
End

function display_dac1(CntrlName) : ButtonControl
	String CntrlName
	WAVE dac1_stimwave=dac1_stimwave
	NVAR freq=freq, samples=samples, dac0_gain=dac0_gain,dac1_vc=dac1_vc
	Make /O/N=(samples) twave
	variable scale
	scale = 120/screenresolution
	scale = 1
	set_stim()
	twave = dac1_stimwave / (3.2 * dac0_gain)
	DoWindow Excitation_Graph
	if (V_flag == 1)
		DoWindow /F Excitation_Graph
		Return(0)
	Endif
	SetScale /P x, 0, (1/freq), "ms", twave
	if (dac1_vc == 1)
		SetScale d, -200, 200, "mV", twave
	Else
		SetScale d, -200, 200, "pA", twave
	Endif
	Display /W=(scale*3.6, scale*236, scale*397.2, scale*412.4) twave
	DoWindow /C Excitation_Graph
End




function accept_dac2(CntrlName) : ButtonControl
	String CntrlName
	DoWindow table_dac2
	if (V_Flag == 1)
		set_stim()
		DoWindow /K table_dac2
	Endif
	DoWindow stimwave_display
	if (V_flag == 1)
		DoWindow /K stimwave_display
	Endif
End

function accept_dac3(CntrlName) : ButtonControl
	String CntrlName
	DoWindow table_dac3
	if (V_Flag == 1)
		set_stim()
		DoWindow /K table_dac3
	Endif
	DoWindow stimwave_display
	if (V_flag == 1)
		DoWindow /K stimwave_display
	Endif
End


function display_dac2(CntrlName) : ButtonControl
	String CntrlName
	WAVE dac2_stimwave=dac2_stimwave
	NVAR freq=freq, samples=samples, dac2_gain=dac2_gain,dac2_vc=dac2_vc
	Make /O/N=(samples) twave
	variable scale
	scale = 120/screenresolution
	scale = 1
	set_stim()
	twave = dac2_stimwave / (3.2 * dac2_gain)
	DoWindow Excitation_Graph
	if (V_flag == 1)
		DoWindow /F Excitation_Graph
		Return(0)
	Endif
	SetScale /P x, 0, (1/freq), "ms", twave
	if (dac2_vc == 1)
		SetScale d, -200, 200, "mV", twave
	Else
		SetScale d, -200, 200, "pA", twave
	Endif
	Display /W=(scale*3.6, scale*236, scale*397.2, scale*412.4) twave
	DoWindow /C Excitation_Graph
End

function display_dac3(CntrlName) : ButtonControl
	String CntrlName
	WAVE dac3_stimwave
	NVAR freq, samples, dac3_gain,dac3_vc
	Make /O/N=(samples) twave
	variable scale
	scale = 120/screenresolution
	scale = 1
	set_stim()
	twave = dac3_stimwave / (3.2 * dac3_gain)
	DoWindow Excitation_Graph
	if (V_flag == 1)
		DoWindow /F Excitation_Graph
		Return(0)
	Endif
	SetScale /P x, 0, (1/freq), "ms", twave
	if (dac3_vc == 1)
		SetScale d, -200, 200, "mV", twave
	Else
		SetScale d, -200, 200, "pA", twave
	Endif
	Display /W=(scale*3.6, scale*236, scale*397.2, scale*412.4) twave
	DoWindow /C Excitation_Graph
End


function set_sweep_time()
	String CntrlName
	Variable varNum
	String varStr, varName
	NVAR sweep_time, freq, samples,TraceOffSet, sweep_time, continuous_flag
	sweep_time = samples / freq // in ms
	if (continuous_flag)
		TraceOffSet = sweep_time
	Else
		TraceOffSet = 2.5*sweep_time
	Endif
	
	
End


function set_freq(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	NVAR freq, total_chan_num
	variable period = round(1000/(freq * total_chan_num * 1.25))// used for ITC18
	freq = 1000/(period*1.25*total_chan_num) // changes freq to the real value
	para_change()
	set_sweep_time()
	set_stim()
	set_in()
End

function set_samp(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	NVAR samples=samples,old_samples=old_samples
	para_change()
	set_sweep_time()
	set_in()
	set_stim()
	old_samples=samples
End


function Read_Header()
	NVAR bin_type, total_header_size, total_chan_num
	NVAR read_file_open, read_file_ref, init_display
	NVAR stop_averaging // used in query_average
	if (read_file_open == 1)
		close(read_file_ref)
	Endif
	if (bin_type == 0)
		Read_Igor_Header()
		total_chan_num = 2
	Endif
	if ((bin_type == 1) %| (bin_type == 2))
		total_header_size = 1024
		read_xy_header()
	endif
	if (bin_type == 10) // acquire
		read_acquire_header()
	Endif
	if (bin_type == 100)
		read_neuron_header()
	endif
	print_header()
	if (init_display)
		init_g_traces()
		init_g_average(1)
	Endif
	stop_averaging = 0
	get_a_trace(0)
End

function print_header()
	NVAR dac0_gain,dac1_gain,dac2_gain,dac3_gain
	NVAR adc_gain0,adc_gain1,adc_gain2,adc_gain3
	NVAR adc_gain4,adc_gain5,adc_gain6,adc_gain7
	NVAR adc_status0,adc_status1,adc_status2,adc_status3
	NVAR adc_status4,adc_status5,adc_status6,adc_status7
	NVAR dac0_status,dac1_status,dac2_status,dac3_status
	NVAR freq, total_chan_num, samples,requested,acquired
	NVAR wait,freq,hp0,hp1,hp2,hp3,dac0_vc,dac1_vc,dac2_vc,dac3_vc
	SVAR seq_in,seq_out
	SVAR comment, saved_version
	WAVE dac0_start, dac0_end, dac0_amp
	WAVE dac1_start, dac1_end, dac1_amp
	WAVE dac2_start, dac2_end, dac2_amp
	WAVE dac3_start, dac3_end, dac3_amp	
	NVAR dac0_pulse_num,dac1_pulse_num,dac2_pulse_num,dac3_pulse_num
	NVAR dac0_vc,dac0_cc,dac1_vc,dac1_cc,dac2_vc,dac2_cc,dac3_vc,dac3_cc
	NVAR ttl_status=ttl_status,acquire_mode=acquire_mode

	NVAR sine_flag_dac0=sine_flag_dac0, sine_flag_dac1=sine_flag_dac1, sine_phase_dac0=sine_phase_dac0
	NVAR sine_phase_dac1=sine_phase_dac1, sine_amp_dac0=sine_amp_dac0, sine_amp_dac1=sine_amp_dac1
	NVAR sine_freq_dac0=sine_freq_dac0, sine_freq_dac1=sine_freq_dac1,continuous_flag=continuous_flag

	NVAR dac0_psc_flag=dac0_psc_flag,dac0_psc1_amp=dac0_psc1_amp, dac0_psc2_amp=dac0_psc2_amp,dac0_psc1_taurise=dac0_psc1_taurise, dac0_psc2_taurise=dac0_psc2_taurise
	NVAR dac0_psc1_taudecay=dac0_psc1_taudecay,dac0_psc2_taudecay=dac0_psc2_taudecay, dac0_psc_interval=dac0_psc_interval, dac0_psc_start=dac0_psc_start
	NVAR dac1_psc_flag=dac1_psc_flag,dac1_psc1_amp=dac1_psc1_amp, dac1_psc2_amp=dac1_psc2_amp,dac1_psc1_taurise=dac1_psc1_taurise, dac1_psc2_taurise=dac1_psc2_taurise
	NVAR dac1_psc1_taudecay=dac1_psc1_taudecay,dac1_psc2_taudecay=dac1_psc2_taudecay, dac1_psc_interval=dac1_psc_interval, dac1_psc_start=dac1_psc_start
	NVAR dac0_psc3_taudecay=dac0_psc3_taudecay,dac0_psc3_taurise=dac0_psc3_taurise,dac0_psc3_amp=dac0_psc3_amp	
	NVAR dac0_stimfile_flag=dac0_stimfile_flag,dac0_stimfile_scale=dac0_stimfile_scale,stimfile_recycle=stimfile_recycle, stimfile_loc=stimfile_loc
	NVAR dac1_stimfile_flag=dac1_stimfile_flag,dac1_stimfile_scale=dac1_stimfile_scale,datesecs=datesecs
	SVAR stimfile_name=stimfile_name,read_file_name=read_file_name,start_time=start_time,write_file_name=write_file_name

	variable i
	string file_name = ""
	if (acquire_mode == 0)
		file_name = read_file_name
	Else
		file_name = write_file_name
	Endif
	
	printf "----------- %s  (on: %s at: %s) (saved_version: %s)--------------------------------------------\r", file_name, secs2date(datesecs,1),Secs2Time(datesecs,1), saved_version
	print comment
	printf "samples=%d, freq=%.1f, acquired=%d\r", samples, freq,acquired
	if (adc_status0 == 1)
		if (dac0_stimfile_flag == 1)
			printf "dac0_stimfile_scale: %.1f\r", dac0_stimfile_scale
		Endif
		i = 0
		do
			if (dac0_pulse_num == 0)
				break
			Endif
			printf "%d: dac0_start: %.2f, dac0_end: %.1f, dac0_amp: %.2f\r", i, dac0_start[i],dac0_end[0],dac0_amp[i]
			i += 1
		While (i < dac0_pulse_num)
		if (dac0_psc_flag == 1)
			printf "dac0_psc1_amp= %.2f, dac0_psc1_decay=%.2f, dac0_psc1_rise=%.2f\r", dac0_psc1_amp,dac0_psc1_taudecay,dac0_psc1_taurise
			printf "dac0_psc2_amp= %.2f, dac0_psc2_decay=%.2f, dac0_psc2_rise=%.2f\r", dac0_psc2_amp,dac0_psc2_taudecay,dac0_psc2_taurise
			printf "dac0_psc3_amp= %.2f, dac0_psc3_decay=%.2f, dac0_psc3_rise=%.2f\r", dac0_psc3_amp,dac0_psc3_taudecay,dac0_psc3_taurise
		Endif
	Endif
	
	if (adc_status1 == 1)
		if (dac1_stimfile_flag == 1)
			printf "dac1_stimfile_scale: %.1f\r", dac1_stimfile_scale
		Endif
		i = 0
		do
			if (dac1_pulse_num == 0)
				break
			Endif
			printf "%d: dac1_start: %.2f, dac1_end: %.1f, dac1_amp: %.2f\r", i, dac1_start[i],dac1_end[0],dac1_amp[i]
			i += 1
		While (i < dac1_pulse_num)
		if (dac1_psc_flag == 1)
			printf "dac1_psc1_amp= %.2f, dac1_psc1_decay=%.2f, dac1_psc1_rise=%.2f\r", dac1_psc1_amp,dac1_psc1_taudecay,dac1_psc1_taurise
			printf "dac1_psc2_amp= %.2f, dac1_psc2_decay=%.2f, dac1_psc2_rise=%.2f\r", dac1_psc2_amp,dac1_psc2_taudecay,dac1_psc2_taurise
		Endif
	Endif
	if (adc_status2 == 1)
//		if (dac2_stimfile_flag == 1)
//			printf "dac2_stimfile_scale: %.1f\r", dac2_stimfile_scale
//		Endif
		i = 0
		do
			if (dac2_pulse_num == 0)
				break
			Endif
			printf "%d: dac2_start: %.2f, dac2_end: %.1f, dac2_amp: %.2f\r", i, dac2_start[i],dac2_end[0],dac2_amp[i]
			i += 1
		While (i < dac2_pulse_num)
//		if (dac2_psc_flag == 1)
//			printf "dac2_psc1_amp= %.2f, dac2_psc1_decay=%.2f, dac2_psc1_rise=%.2f\r", dac2_psc1_amp,dac2_psc1_taudecay,dac2_psc1_taurise
//			printf "dac2_psc2_amp= %.2f, dac2_psc2_decay=%.2f, dac2_psc2_rise=%.2f\r", dac2_psc2_amp,dac2_psc2_taudecay,dac2_psc2_taurise
//		Endif
	Endif
	if (adc_status3 == 1)
//		if (dac2_stimfile_flag == 1)
//			printf "dac2_stimfile_scale: %.1f\r", dac2_stimfile_scale
//		Endif
		i = 0
		do
			if (dac3_pulse_num == 0)
				break
			Endif
			printf "%d: dac3_start: %.2f, dac3_end: %.1f, dac3_amp: %.2f\r", i, dac3_start[i],dac3_end[0],dac3_amp[i]
			i += 1
		While (i < dac3_pulse_num)
//		if (dac2_psc_flag == 1)
//			printf "dac2_psc1_amp= %.2f, dac2_psc1_decay=%.2f, dac2_psc1_rise=%.2f\r", dac2_psc1_amp,dac2_psc1_taudecay,dac2_psc1_taurise
//			printf "dac2_psc2_amp= %.2f, dac2_psc2_decay=%.2f, dac2_psc2_rise=%.2f\r", dac2_psc2_amp,dac2_psc2_taudecay,dac2_psc2_taurise
//		Endif
	Endif	

	printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++\r"

End


function c_Read_Header(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	read_header()
End

function next(CntrlName) : ButtonControl
	String CntrlName
	NVAR trace_num=trace_num
	get_a_trace(trace_num+1)
End

function next_file(CntrlName) : ButtonControl
	String CntrlName
	SVAR read_file_name=read_file_name, read_datapath=read_datapath
	
	variable loc, index_num, test_ref
	string index_str = "", pre_name="", old_file_name = ""
	old_file_name = read_file_name
	loc = strsearch(read_file_name,".", 0)
	index_str = read_file_name[loc+1, strlen(read_file_name)]
	pre_name = read_file_name[0,loc]
	index_num = str2num(index_str)
	index_str = num2str(index_num+1)
	if ((index_num + 1) < 10)
		index_str = "00" + index_str
	Endif
	if (((index_num + 1) < 100) %& ((index_num + 1) > 9))
		index_str = "0" + index_str
	EndIf
	read_file_name = pre_name + index_str
	// test if file exists
	Open /Z/R/P=read_datapath test_ref as read_file_name
	if (V_flag == 0)
		Close test_ref
		read_header()
	Else
		read_file_name = old_file_name
		Beep; Beep; Beep
		printf "ERROR: from next_file-> could not open: %s (main)\r", read_file_name
		Return(0)
	Endif
End


function previous_file(CntrlName) : ButtonControl
	String CntrlName
	SVAR read_file_name=read_file_name, read_datapath=read_datapath
	variable loc, index_num, test_ref
	string index_str = "", pre_name="", old_file_name = ""
	old_file_name = read_file_name
	loc = strsearch(read_file_name,".", 0)
	index_str = read_file_name[loc+1, strlen(read_file_name)]
	pre_name = read_file_name[0,loc]
	index_num = str2num(index_str)
	index_str = num2str(index_num-1)
	if ((index_num - 1) < 10)
		index_str = "00" + index_str
	Endif
	if (((index_num - 1) < 100) %& ((index_num - 1) > 9))
		index_str = "0" + index_str
	EndIf
	read_file_name = pre_name + index_str
// test if file exists
	Open /Z/R/P=read_datapath test_ref as read_file_name
	if (V_flag == 0)
		Close test_ref
		read_header()
	Else
		read_file_name = old_file_name
		Beep; Beep; Beep
		Return(0)
	Endif
End







function b_do_histogram(CntrlName) : ButtonControl
	String CntrlName
	do_histogram()
End

function init_histogram(CntrlName) : ButtonControl
	String CntrlName
	NVAR total_spikes=total_spikes,histogram_sweeps=histogram_sweeps
	WAVE total_detections=total_detections, psth=psth, histog_vm=histog_vm
	total_detections = 0
	total_spikes = 0
	psth= 0
	histog_vm = 0
	histogram_sweeps = 0
End

function set_update(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR update = update
	if (checked)
		update = 1
	Else
		update = 0
	Endif
End

function set_align_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR align_flag = align_flag
	if (checked)
		align_flag = 1
	Else
		align_flag = 0
	Endif
End


function set_smooth(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR smooth_flag = smooth_flag
	if (checked)
		smooth_flag = 1
	Else
		smooth_flag = 0
	Endif
End



//
//function set_peak_points(CntrlName, varNum, varStr, varName) : SetVariableControl
//	String CntrlName
//	Variable varNum
//	String varStr, varName
//	NVAR peak_points, analysis_num
//	WAVE amp_analysis_peak_points_wave
//	amp_analysis_peak_points_wave[analysis_num] = varNum
//	peak_points = varNum
//End




function previous(CntrlName) : ButtonControl
	String CntrlName
	NVAR trace_num=trace_num
	get_a_trace(trace_num-1)
End

function redo_his(CntrlName) : ButtonControl
	String CntrlName

	WAVE psth=psth, total_detections=total_detections
	NVAR bin_size=bin_size, samples=samples, total_spikes=total_spikes, total_chan_num=total_chan_num, freq=freq, bin_type=bin_type
 	NVAR trace_start=trace_start, trace_end=trace_end,alternate=alternate
 	variable num
 	num = trace_end - trace_start 
 	if (alternate != 0)
 		num /= alternate
 	Endif
	Histogram /B={0, bin_size, (samples/bin_size)} /R=[0, (total_spikes-1)] total_detections, psth
	if (bin_type == 1)
		psth *= ((freq*1000.0/total_chan_num)/(bin_size*num)) 
	Endif
	if ((bin_type == 0) %| (bin_type == 10))
		psth *= ((freq*1000)/(bin_size*num))
	endif
	if ((bin_type == 0) %| (bin_type == 10))
		Setscale /I x, 0, (samples/freq), "ms", psth
	Endif
	if (bin_type == 1)
		SetScale /I x, 0, (samples/(freq/1.0)), "ms", psth
	Endif
	SetScale d, 0, 200, "Frequency (Hz)", psth
	DoUpDate
End

	
function /S get_yaxis(trace)
	String trace
	Variable key_start, key_end, i
	String trace_info = "", yaxis_name = ""
	trace_info = traceinfo("", trace, 0)
	yaxis_name = StringByKey("YAXIS",trace_info)
//	key_start = strsearch(trace_info, "YAXIS:", 0)
//	key_end = strsearch(trace_info, ";", key_start)
//	yaxis_name = trace_info[(key_start+6), (key_end-1)]
	Return(yaxis_name)
End


function run()
	Do_a_Protocol(0)
End

function single()
	String tempstr
	tempstr = ""
	single_run(tempstr)
End

Menu "Help"
	"Acquire_Help"
End

function Acquire_Help()
	opennotebook "C:\Program Files\Wavemetrics\Igor Pro Folder\User Procedures\Acquire_Manual.txt"
End

Menu "macros"
	Submenu "Acquire_commands"
		"RUN/0"
		"Single/9"
		"Load1/1"
		"Load2/2"
		"Load3/3"
		"Load4/4"
		"CallCH/F5"
	End
	"Save_protocol"
	"Save_scheme"
	"Set_Read_Mode"
	"Set_Acquire_Mode"
	"Save_Analysis"
	"Read_Analysis"
End

function Make_Scheme_Panel(CntrlName) : ButtonControl
	String CntrlName
//	printf "CntrlName: %s\r", CntrlName
	WAVE scheme_wait = scheme_wait
	
// these are the numerical vatriables used in the panel they must have the values of the scheme_wait wave
// which is used in the other parts of the program 	

	NVAR number_of_pro, CurrentProNumber, last_number_of_pro // the number of the current protocol
//	SVAR pro_0,pro_1,pro_2,pro_3,pro_4,pro_5,pro_6,pro_7,pro_8,pro_9,pro_10,pro_11,pro_12,pro_13,pro_14,pro_15,pro_16,pro_17,pro_18,pro_19
//	NVAR cs_0, cs_1
	variable /g scheme_wait0, scheme_wait1, scheme_wait2, scheme_wait3, scheme_wait4
	variable /g scheme_wait5, scheme_wait6, scheme_wait7, scheme_wait8, scheme_wait9
	variable /g scheme_wait10, scheme_wait11, scheme_wait12, scheme_wait13, scheme_wait14
	variable /g scheme_wait15, scheme_wait16, scheme_wait17, scheme_wait18, scheme_wait19
	variable scale
	scale = 120/screenresolution
	scale = 1
	variable i
	string tempstr = ""
	

	scheme_wait0 = scheme_wait[0]
	scheme_wait1 = scheme_wait[1]
	scheme_wait2 = scheme_wait[2]
	scheme_wait3 = scheme_wait[3]
	scheme_wait4 = scheme_wait[4]
	scheme_wait5 = scheme_wait[5]
	scheme_wait6 = scheme_wait[6]
	scheme_wait7 = scheme_wait[7]
	scheme_wait8 = scheme_wait[8]
	scheme_wait9 = scheme_wait[9]
	scheme_wait10 = scheme_wait[10]
	scheme_wait11 = scheme_wait[11]
	scheme_wait12 = scheme_wait[12]
	scheme_wait13 = scheme_wait[13]
	scheme_wait14 = scheme_wait[14]
	scheme_wait15 = scheme_wait[15]
	scheme_wait16 = scheme_wait[16]
	scheme_wait17 = scheme_wait[17]
	scheme_wait18 = scheme_wait[18]
	scheme_wait19 = scheme_wait[19]

	PauseUpdate; Silent 1		// building window...
	dowindow /K Scheme_Panel
	NewPanel /W=(scale*217, scale*70, scale*501, scale*684) as "Scheme"	
	Dowindow /C Scheme_panel
	if (stringmatch(CntrlName, "clone"))
		If (number_of_pro > last_number_of_pro) // adding new protocols, first clone last one
			SVAR last_pro = $("pro_" + num2str(last_number_of_pro-1))
			For (i=CurrentProNumber; i < number_of_pro; i += 1)
				SVAR pro_str = $("pro_" + num2str(i))
				pro_str =  last_pro
			EndFor
		EndIf
	Endif
	i = 0
	if (number_of_pro > 1)
		SetVariable setwait0,pos={6,83},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait0,title="Wait 0 to 1"
		Button pro_0,pos={130,83},size={50,20},proc=Get_Pro,title="pro_0"
		i += 1
	Endif
	if (number_of_pro > 2)
		SetVariable setwait1,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait1,title="Wait 1 to 2"
		Button pro_1,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_1"
		i += 1
	Endif
	if (number_of_pro > 3)
		SetVariable setwait2,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait2,title="Wait 2 to 3"
		Button pro_2,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_2"
		i += 1
	Endif
	if (number_of_pro > 4)
		SetVariable setwait3,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait3,title="Wait 3 to 4"
		Button pro_3,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_3"
		i += 1
	Endif
	if (number_of_pro > 5)
		SetVariable setwait4,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait4,title="Wait 4 to 5"
		Button pro_4,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_4"
		i += 1
	Endif
	if (number_of_pro > 6)
		SetVariable setwait5,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait5,title="Wait 5 to 6"
		Button pro_5,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_5"
		i += 1
	Endif
	if (number_of_pro > 7)
		SetVariable setwait6,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait6,title="Wait 6 to 7"
		Button pro_6,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_6"
		i += 1
	Endif
	if (number_of_pro > 8)
		SetVariable setwait7,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait7,title="Wait 6 to 7"
		Button pro_7,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_7"
		i += 1
	Endif
	if (number_of_pro > 9)
		SetVariable setwait8,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait8,title="Wait 8 to 9"
		Button pro_8,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_8"
		i += 1
	Endif
	if (number_of_pro > 10)
		SetVariable setwait9,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait9,title="Wait 9 to 10"
		Button pro_9,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_9"
		i += 1
	Endif
	if (number_of_pro > 11)
		SetVariable setwait10,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait10,title="Wait 10 to 11"
		Button pro_10,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_10"
		i += 1
	Endif
	if (number_of_pro > 12)
		SetVariable setwait11,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait11,title="Wait 11 to 12"
		Button pro_11,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_11"
		i += 1
	Endif
	if (number_of_pro > 13)
		SetVariable setwait12,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait12,title="Wait 12 to 13"	
		Button pro_12,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_12"
		i += 1
	Endif
	if (number_of_pro > 14)
		SetVariable setwait13,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait13,title="Wait 13 to 14"	
		Button pro_13,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_13"
		i += 1
	Endif
	if (number_of_pro > 15)
		SetVariable setwait14,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait14,title="Wait 14 to 15"	
		Button pro_14,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_14"
		i += 1
	Endif
	if (number_of_pro > 16)
		SetVariable setwait15,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait15,title="Wait 15 to 16"	
		Button pro_15,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_15"
		i += 1
	Endif
	if (number_of_pro > 17)
		SetVariable setwait16,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait16,title="Wait 16 to 17"	
		Button pro_16,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_16"
		i += 1
	Endif
	if (number_of_pro > 18)
		SetVariable setwait17,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait17,title="Wait 17 to 18"	
		Button pro_17,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_17"
		i += 1
	Endif
	if (number_of_pro > 19)
		SetVariable setwait18,pos={6,(83+i*25)},size={118,18},limits={-Inf,Inf,1},proc=SetSchemeWait,value= scheme_wait18,title="Wait 18 to 19"	
		Button pro_18,pos={130,83+i*25},size={50,20},proc=Get_Pro,title="pro_18"
		i += 1
	Endif
	last_number_of_pro = number_of_pro




//	SetVariable setvar0,limits={-Inf,Inf,1},value= scheme_wait0
	SetVariable setvar1,pos={6,(83+(number_of_pro-1)*25)},size={116,18},title="Wait L to F"
	SetVariable setvar1,limits={-Inf,Inf,1},value= wait_lf
	tempstr = "pro_" + num2str(i)
	Button $tempstr,pos={130,83+i*25},size={50,20},proc=Get_Pro,title=("pro_"+num2str(i))
	SetVariable setvar2,pos={15,33},size={112,18},limits={-Inf,Inf,1},proc=set_number_of_pro,value= number_of_pro,title="# of Pro"
//	SetVariable setvar2,limits={-Inf,Inf,1},value= number_of_pro
	Button button0,pos={190,200},size={95,37},proc=Make_a_Scheme,title="Make Scheme"
	Button button1,pos={190,149},size={94,41},proc=save_a_scheme,title="Save Scheme"
	Button button4,pos={192,4},size={94,38},proc=Load_Protocol,title="Load Pro"
	SetVariable setvar3,pos={9,59},size={118,18},title="S. Repeat"
	SetVariable setvar3,limits={-Inf,Inf,0},value= scheme_repeat
	SetVariable setvar4,pos={38,8},limits={-Inf,Inf,1},size={90,18},title="Type",value= scheme_type
	Button button2,pos={194,46},size={92,37},proc=Keep_Pro_As,title="Keep as ..."
	Button keep_pro,pos={193,93},size={93,42},proc=Keep_Pro,title=("Keep: pro_"+num2str(CurrentProNumber))
	Button Scheme_Panel,pos={6,567},size={101,40},proc=Kill_Panel,title="Close Window"	
//
//	SetVariable setcs_0,pos={177,293},size={102,16},title="CS_0"	
//	SetVariable setcs_0,help={"In continuous mode: after this #  sweeps from start switch to pro_0 "}
//	SetVariable setcs_0,limits={-inf,inf,0},value= cs_0
//	SetVariable setcs_1,pos={177,329},size={102,16},title="CS_1"
//	SetVariable setcs_1,help={"after this #  of sweeps from start switch to pro_1"}
//	SetVariable setcs_1,limits={-inf,inf,0},value= cs_1
//	SetVariable continuous_multi_flag,pos={177,261},size={102,16},title="cont_multi_flag"
//	SetVariable continuous_multi_flag,help={"set to 0 if only single protocol used in continuous mode"}
//	SetVariable continuous_multi_flag,limits={-inf,inf,0},value= cont_multi_flag

//	Button $"Scheme_Panel",pos={13,198},size={101,40},proc=Kill_Panel,title="Close Window"
End


// enters value of variable into scheme_wait wave
Function SetSchemeWait (ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	WAVE scheme_wait=scheme_wait
	NVAR number_of_pro
	variable i
	i = 0
	Do
		if (stringmatch(ctrlName, ("setwait"+num2str(i))))
			scheme_wait[i] = str2num(varSTR)
		Endif
		i += 1
	While (i < number_of_pro)
End




function Keep_Pro(CntrlName) : ButtonControl
	String CntrlName
	NVAR CurrentProNumber
	NVAR requested
	SVAR pro = $("pro_" + num2str(CurrentProNumber))
	pro = encode_pro()
	if (requested == -1)
		BEEP BEEP BEEP
		printf "Possible ERROR: requested = -1 (main)\r"
	Endif
End

function Keep_Pro_As(CntrlName) : ButtonControl
	String CntrlName
	NVAR requested
	string tempstr = ""
	variable /g number
	Execute("get_a_number()")
	tempstr = "pro_" + num2str(number)
	KillVariables number
	SVAR pro = $tempstr
	pro = encode_pro()
	DoWindow /K protocol_query_panel
	if (requested == -1)
		beep beep beep
		printf "possible ERROR requested = -1 (main)\r"
	Endif
End



Proc get_a_number(num)
	variable num
	variable /g number
	number = num
End


function Kill_Panel(CntrlName) : ButtonControl
	String CntrlName
	DoWindow /K $CntrlName
End




Function Make_Amp_Analysis_Panel()
	PauseUpdate; Silent 1		// building window...
	DoWindow /K Amp_Panel
	WAVE analysis_trace_name_wave  // names of traces to analyse
	WAVE amp_bl_start_wave
	WAVE amp_bl_end_wave
	WAVE amp_start_wave
	WAVE amp_end_wave
	WAVE dpoints_wave_name // name of waves holding the analysis results
	WAVE analysed_points_wave // the number of points in the dpoints waves
	WAVE amp_analysis_flag_wave
	WAVE amp_analysis_mode_wave
	NVAR analysis_num, peak
	WAVE amp_points_wave_0
	SVAR ZoomWindow
	variable n = analysis_num
	variable scale
	variable temp_peak
//	WAVE temp_points = $("amp_points_wave_" + num2str(analysis_num))
//	peak = temp_points[analysed_points_wave[analysis_num]]
	scale = 120/screenresolution
	scale = 1
	NewPanel /W=(678,521,1014,768) as "Amplitude Analysis"
	DoWindow /C Amp_Panel
	SetDrawLayer UserBack
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 5,124,"Detect ?"
	SetDrawEnv textrgb= (52224,0,0)
	DrawText 5,134,"spikes"
	SetVariable set_amp_bl_start,pos={0,2},size={79,16},title="bl_s"
	SetVariable set_amp_bl_start,limits={-inf,inf,0},value= amp_bl_start_wave[n]
	SetVariable set_amp_bl_end,pos={3,23},size={74,16},title="bl_e"
	SetVariable set_amp_bl_end,limits={-inf,inf,0},value= amp_bl_end_wave[n]
	SetVariable set_amp_start,pos={87,3},size={81,16},title="amp_s"
	SetVariable set_amp_start,limits={-inf,inf,0},value= amp_start_wave[n]
	SetVariable set_amp_end,pos={84,23},size={86,16},title="amp_e"
	SetVariable set_amp_end,limits={-inf,inf,0},value= amp_end_wave[n]
	CheckBox /Z set_Amp_Analysis_flag,pos={110,67},size={75,14},proc=set_amp_analysis_flag,title="Do_analysis"
	CheckBox set_Amp_Analysis_flag,help={"Set to apply this analysis protocol; To plot results click Plots manu item"}
	CheckBox set_Amp_Analysis_flag,value=amp_analysis_flag_wave[analysis_num]
	Button set_amp_bl,pos={5,41},size={72,20},proc=Set_amp_bl,title="set_bl"
	Button set_amp_range,pos={92,42},size={72,21},proc=Set_amp,title="set_amp"
	SetVariable set_peak_dir,pos={30,184},size={84,16},title="peak_dir"
	SetVariable set_peak_dir,limits={-inf,inf,0},value= peak_dir
	ValDisplay val_peak,pos={22,64},size={81,15},title="peak",format="%.2f"
	ValDisplay val_peak,limits={0,0,0},barmisc={0,1000}
	ValDisplay val_peak,value= #"peak//amp_points_wave_0[analysed_points_wave[n]]"
	SetVariable set_peak_points,pos={174,85},size={67,16},title="p_points"
	SetVariable set_peak_points,help={"set to 0 if only one point at peak; 1 for three points average etc."}
	SetVariable set_peak_points,limits={-inf,inf,0},value= amp_analysis_peak_points_wave[n]
	ValDisplay valdisp1,pos={177,188},size={80,15},title=" Rise",format="%.2f"
	ValDisplay valdisp1,limits={0,0,0},barmisc={0,1000},value= #"peak_risetime"
	CheckBox check0,pos={8,214},size={52,14},proc=set_search_flag,title="Search"
	CheckBox check0,value= 0
	SetVariable setvar1,pos={95,209},size={98,16},title="Thresh"
	SetVariable setvar1,limits={-inf,inf,0},value= spike_thresh
	SetVariable setvar0,pos={6,84},size={97,18},title="Trace",font="Arial"
	SetVariable setvar0,value= analysis_trace_name_wave[n]
	Button button3,pos={170,36},size={50,33},proc=Init_amp_analysis,title="INIT"
	Button button3,help={"Initialize analysis result waves: 'amp_points_wave_0' etc."}
	SetVariable setvar2,pos={112,84},size={54,16},title="Mode"
	SetVariable setvar2,help={"0: (mean1-mean0); 1: max; -1: min; 10: baseline; 2: integral; 3: wp0/wp1; 5: SD of mean0&mean1"}
	SetVariable setvar2,limits={-inf,inf,0},value= amp_analysis_mode_wave[n]
	Button button4,pos={206,209},size={50,20},proc=Set_Cond,title="Cond"
	Button init,pos={55,109},size={50,20},proc=query_detections,title="Init"
	Button init,help={"Initilize analysis result waves: 'amp_points_wave_0' etc."}
	Button include,pos={119,108},size={50,20},proc=query_detections,title="Accept"
	Button do_not_include,pos={176,107},size={50,20},proc=query_detections,title="Reject"
	ValDisplay valdisp0,pos={229,112},size={60,15},title="n=",format="%.0f"
	ValDisplay valdisp0,limits={0,0,0},barmisc={0,1000},value= #"spikes_accepted"
	SetVariable Amp_Analysis_Num,pos={180,6},size={94,19},proc=set_analysis_num,title="Num"
	SetVariable Amp_Analysis_Num,labelBack=(65280,16384,16384),fSize=14,format="%d"
	SetVariable Amp_Analysis_Num,value= analysis_num
	Button set_dac0,pos={301,8},size={30,20},proc=select_dac0,title="dac0"
	Button set_dac0,fColor=(65280,16384,16384)
	Button set_dac1,pos={302,39},size={30,20},proc=select_dac1,title="dac1"
	Button set_dac1,fColor=(0,43520,65280)
	Button set_dac2,pos={303,73},size={30,20},proc=select_dac2,title="dac2"
	Button set_dac2,fColor=(0,65280,0)
	Button set_dac3,pos={303,107},size={30,20},proc=select_dac3,title="dac3"
	CheckBox check1,pos={248,85},size={47,15},proc=set_draw_flag,title="Draw"
	CheckBox check1,help={"draw analysis lines on trace"},font="Arial"
	CheckBox check1,variable= draw_flag
	Button include1,pos={224,32},size={74,21},proc=query_average,title="Include"
	Button do_not_include1,pos={222,57},size={77,21},proc=query_average,title="Do_not_include"
	SetVariable setvar3,pos={22,147},size={206,16},title="ZoomWindow"
	SetVariable setvar3,help={"1 to expand 2 to shrink named window"}
	SetVariable setvar3,limits={-inf,inf,0},value=ZoomWindow
End

function set_analysis_num(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	Make_Amp_Analysis_Panel()
End

function Set_amp_bl(CntrlName) : ButtonControl
	String CntrlName
	NVAR analysis_num
	WAVE amp_bl_end_wave, amp_bl_start_wave
	WAVE /T analysis_trace_name_wave
	amp_bl_start_wave[analysis_num] =  pcsr(a)
	amp_bl_end_wave[analysis_num] =  pcsr(b)
	analysis_trace_name_wave[analysis_num] = CsrWave(a)
End
function Set_amp(CntrlName) : ButtonControl
	String CntrlName
	NVAR analysis_num
	WAVE amp_end_wave, amp_start_wave
	WAVE /T analysis_trace_name_wave
	amp_start_wave[analysis_num] =  pcsr(a)
	amp_end_wave[analysis_num] =  pcsr(b)
	analysis_trace_name_wave[analysis_num] = CsrWave(a)
End
function set_draw_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR draw_flag
	if (checked)
		draw_flag = 1
	Else
		draw_flag = 0
		clean("") // to remove lines etc.
	Endif
End

Function rescale(ctrlName) : ButtonControl
	String ctrlName
	SetAxis /W=G_Traces /A/N=2 left
	DoUpdate
	GetAxis /W=G_Traces left
	SetAxis /W=G_Traces left V_min,V_max
	SetAxis /Z/W=G_Traces /A/N=2 right
	DoUpdate
	GetAxis /W=G_Traces right
	SetAxis /Z/W=G_Traces right V_min,V_max
End

Function set_trig(CntrlName, checked) : CheckBoxControl
	String CntrlName
	variable checked
	NVAR trig_mode
	if(checked)
		trig_mode = 3
	Else
		trig_mode = 2
	Endif
	DoUpdate
End

Function A_scale(CntrlName, checked) : CheckBoxControl
	String CntrlName
	variable checked
	if (checked)
		SetAxis /Z/W=G_Traces /A/N=1 left
		SetAxis /Z/W=G_Traces /A/N=1 right
		SetAxis /Z/W=G_Traces /A/N=1 left2
		DoUpdate
	Else 
		SetAxis /Z/W=G_Traces /A/N=2 left
		DoUpdate
		GetAxis/W=G_Traces/Q left
		if (V_flag == 0)
//		if (stringmatch(AxisList("G_Traces"),"*left*")) // check if axis is on graph
			GetAxis /Q/W=G_Traces left
			SetAxis /Z/W=G_Traces left V_min,V_max
		Endif
		SetAxis /Z/W=G_Traces /A/N=2 right
		DoUpdate
		GetAxis/W=G_Traces/Q right
		if (V_flag == 0)
			GetAxis /Q/W=G_Traces right
			SetAxis /Z/W=G_Traces right V_min,V_max
		Endif
		SetAxis /Z/W=G_Traces /A/N=2 left2
		DoUpdate
		GetAxis/W=G_Traces/Q left2
		if (V_flag == 0)
			GetAxis /Q/W=G_Traces left2
			SetAxis /Z/W=G_Traces left2 V_min,V_max
		Endif
	Endif
End


Function select_panel (ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	NVAR ttl_num
	if (popNum == 1)
		doWindow /F F_panel
	Endif
	if (popNum == 2)
		doWindow /F H_Panel
	Endif
	if (popNum == 3)
		doWindow /F PP_Panel
	Endif
	if (popnum == 4)
//		doWindow /F AMP_Panel
		Make_amp_analysis_panel()
	Endif
	if (popnum == 5)
		DoWindow /F More_Analysis_panel
	Endif
	if (popnum == 6)
		DoWindow /F View_Panel
	Endif
	if (popnum == 7)
		DoWindow /F DAC0_panel
	Endif
	if (popnum == 8)
		dowindow /F DAC1_panel
	endif
	if (popNum == 9)
		doWindow /F DAC2_Panel
	Endif
	if (popnum == 10)
		doWindow /F DAC3_Panel
	Endif
	if (popnum == 11)
		make_ttl_panel(ttl_num)
	Endif
	if (popnum == 12)
		make_mini_panel()
	Endif
	if (popnum == 13)
		Make_Scheme_Panel("f")
	Endif

End

function clean(CntrlName) : ButtonControl
	String CntrlName
	string /g first_graph, second_graph, third_graph, top_win
	first_graph = WinName(0,1)
	second_graph = WinName(1,1)
	third_graph = WinName(2,1)
	if (cmpstr(first_graph,"S_Histogram") == 0)
		top_win = "S_Histogram"
	Endif
	if (cmpstr(first_graph,"G_Average") == 0)
		top_win = "G_Average"
	Endif
	if (cmpstr(first_graph,"G_Traces") == 0)
		if (cmpstr(second_graph,"G_Average") == 0)
			top_win = "G_Average"
		Endif
		if (cmpstr(second_graph,"S_Histogram") == 0)
			top_win = "S_histogram"
		Endif
	Endif
	print "1: %s, 2: %s, 3: %s\r", first_graph, second_graph, third_graph
	dowindow /f g_average
	SetDrawLayer /K userfront
	textbox /k/n=text0
	SetDrawLayer /K progback
	RemoveFromGraph /Z test_fit
	dowindow /f g_traces
	textbox /k/n=text0
	SetDrawLayer /K progback
	RemoveFromGraph /Z test_fit
	dowindow /f S_Histogram
	textbox /k/n=text0
	SetDrawLayer /K progback
	RemoveFromGraph /Z test_fit
	DoWindow /F $top_win
end


function set_init_analysis(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR init_analysis
	NVAR initialize
	if (checked)
		init_analysis = 1
		DoWindow /F Panel_AQ_C
		initialize = 1
	Else
		init_analysis = 0
		initialize = 0
	Endif
End

function p_set_hp(CntrlName, varNum, varStr, varName) : SetVariableControl
	String CntrlName
	Variable varNum
	String varStr, varName
	variable dac_num
	para_change()
	dac_num = str2num(varName[2])
//	printf "varname: %s\r", varname
	set_hp(dac_num, varNum)
End 


function set_Amp_Analysis_flag(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	WAVE amp_analysis_flag_wave
	NVAR analysis_num
	if (checked)
		amp_analysis_flag_wave[analysis_num] = 1
	Else
		amp_analysis_flag_wave[analysis_num] = 0
//		make_amp_analysis_panel()
//		DoWindow /F Graph1
//		setdrawlayer /k progback
	Endif
End






function accept_ttl(CntrlName) : ButtonControl
	String CntrlName
	set_stim()
	DoWindow /K ttl_table
End

function display_ttl(CntrlName) : ButtonControl
	String CntrlName
	NVAR ttl_num
	set_stim()	
	WAVE ttl_stimwave=ttl_stimwave
	NVAR freq=freq, samples=samples, dac0_gain=dac0_gain, dac0_vc=dac0_vc
	variable scale
	scale = 120/screenresolution
	scale = 1
	Make /O/N=(samples) twave
	twave = (ttl_stimwave & 2^ttl_num)
	SetScale /P x, 0, (1/freq), "ms", twave
	DoWindow ttl_display
	if (V_flag == 1)
		DoWindow /F ttl_display
		Return(0)
	Endif
	Display /W=(scale*3.6, scale*236, scale*397.2, scale*412.4) twave	 
	DoWindow /C ttl_display
End






function set_analysis()
	NVAR analysis_max, draw_flag
	Make /O/N=(Analysis_Max) amp_end_wave = 0	
	Make /O/N=(Analysis_Max) amp_start_wave = 0
	Make /O/N=(Analysis_Max) amp_bl_start_wave = 0
	Make /O/N=(Analysis_Max) amp_bl_end_wave = 0
	Make /O/N=(Analysis_Max) amp_analysis_mode_wave = 0 // 0: difference of averages; 1: positive peak; -1: negative peak; 10 just baseline
	Make /O/N=(Analysis_Max) analysed_points_wave = 0 // the number of points analysed in the amp_points waves
	Make /O/N=(Analysis_Max) amp_analysis_flag_wave = 0 // if 1 do analysis
	Make /O/N=(Analysis_Max) amp_analysis_peak_points_wave = 0	
	Make /O/T/N=(Analysis_Max) analysis_trace_name_wave = {"adc0","adc0","adc0","adc0","adc0","adc0","adc0","adc0","adc0","adc0"}
	draw_flag = 0
End




function Init_amp_analysis(CntrlName) : ButtonControl
	String CntrlName
	WAVE amp_analysis_flag_wave
	WAVE analysed_points_wave
	
	
	string wavename
	variable i
	i = 0
	Do
//		if (amp_analysis_flag_wave[i])
			wavename = ("amp_points_wave_" + num2str(i))
			WAVE tempwave = $wavename
			tempwave  = NaN
			analysed_points_wave[i] = 0
//		Endif
		i += 1
	While (i < 10)
//	query_average("init")
	
End




function single_run(CntrlName) : ButtonControl
	String CntrlName
	NVAR acquired, requested,scheme_on, continuous_flag, cont_multi_flag
	variable store_requested, store_continuous_flag, store_cont_multi_flag
	scheme_on = 0
	store_requested = requested
	requested = 1
	store_continuous_flag = continuous_flag
	continuous_flag = 0
	store_cont_multi_flag = cont_multi_flag
	cont_multi_flag = 0
	init_g_traces()
	Do_a_Protocol(0)
	requested = store_requested
	continuous_flag = store_continuous_flag
	cont_multi_flag = store_cont_multi_flag
End







function Make_a_Scheme(CntrlName) : ButtonControl
	String CntrlName
	SVAR scheme=scheme
	scheme = encode_scheme()
	check_scheme()
	Get_Pro("pro_0") // check scheme runs decode pro_0
End




function Get_Pro(CntrlName) : ButtonControl
	String CntrlName // assumes to be of the form : pro_x where x is the current protocol number
	NVAR CurrentProNumber=CurrentProNumber
	printf "pro name: %s\r", CntrlName
	decode_pro(CntrlName)
	CurrentProNumber = str2num(CntrlName[4,5])
	DoWindow /F Scheme_panel
	Button keep_pro,pos={193,93},size={93,42},proc=Keep_Pro,title=("Keep: pro_"+num2str(CurrentProNumber))
	Make_Scheme_Panel("")
End

Function Set_number_of_pro(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	Make_scheme_panel("clone")
End



function set_run(CntrlName) : ButtonControl
	String CntrlName
	NVAR scheme_on, init_analysis,samples, freq, average_sweeps
	NVAR av_sweeps_0, av_sweeps_1, av_sweeps_2, av_sweeps_3 , av_sweeps_4, av_sweeps_5
	NVAR av_sweeps_6, av_sweeps_7, av_sweeps_8, av_sweeps_9
	NVAR init_analysis, init_display
	NVAR cont_multi_flag
	SVAR protocol
	variable store_cont_multi_flag
	store_cont_multi_flag = cont_multi_flag
	cont_multi_flag = 0
	scheme_on = 0
	PauseUpdate
	if (init_analysis)
		Make /O/N=(samples) adc1=0, adc2=0, adc0=0, adc3=0
		SetScale /P x, 0, (1/freq), "ms",adc0, adc1,adc2, adc3
		SetScale d 0,0, "mv",adc0, adc1,adc2, adc3
	Endif
	if (init_display)
		init_g_traces()
		init_g_average(0)
		av_sweeps_0 = 0
		variable i, m
		i = 0
// use the '0' protocol waves and sweeps count for averaging
//		if (cont_multi_flag)
//			m = 20
//		Else
//			m = 1
//		EndIf
//		Do	
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
//			i += 1
//		While (i < m)
//
	EndIf
		ResumeUpdate
	scheme_on = 0
	para_change() // close the write file and make a new one
	protocol = encode_pro()
	Do_a_Protocol(0)
	decode_pro("protocol")
	cont_multi_flag = store_cont_multi_flag
End


function set_write_permit(CntrlName, checked) : CheckBoxControl
	String CntrlName
	Variable checked
	NVAR write_permit=write_permit
	if (checked)
		write_permit = 1
	SetDrawEnv  fillfgc= (65280,0,52224)
	DrawRRect 204,27,308,51		
// color checkbox RED		
	Else
		write_permit = 0
		SetDrawEnv fillfgc= (65535,65535,65535)
		DrawRRect 204,27,308,51		
// color checkbox blue
	Endif
End


function edit_dac1(CntrlName) : ButtonControl
	String CntrlName
	NVAR write_permit
	DoWindow table_dac1
	if (write_permit != 0)
		para_change()
	endif
	if (V_flag == 1)
		DoWindow /F table_dac1
		Return(0)
	Endif
	
	Edit/W=(407.4,138.8,600,298.4) dac1_start,dac1_end,dac1_amp
	ModifyTable rgb(dac1_start)=(0,34816,52224),rgb(dac1_end)=(0,34816,52224),rgb(dac1_amp)=(0,34816,52224)
	ModifyTable width(Point)=14,width(dac1_start)=47,rgb(dac1_start)=(0,34816,52224)
	ModifyTable width(dac1_end)=44,rgb(dac1_end)=(0,34816,52224),width(dac1_amp)=55
//	ModifyTable rgb(dac1_amp)=(0,34816,52224)
	
	
	
//	edit dac1_start, dac1_end, dac1_amp
//	ModifyTable rgb(dac1_start)=(0,34816,52224),rgb(dac1_end)=(0,34816,52224),rgb(dac1_amp)=(0,34816,52224)
	DoWindow /C table_dac1
End

function edit_dac0(CntrlName) : ButtonControl
	String CntrlName
	NVAR write_permit
	if (write_permit)
		para_change()
	Endif
	DoWindow table_dac0
	if (V_flag == 1)
		DoWindow /F table_dac0
		Return(0)
	Endif
	
	Edit/W=(407.4,138.8,600,298.4) dac0_start,dac0_end,dac0_amp
	ModifyTable rgb(dac0_start)=(65280,0,0),rgb(dac0_end)=(65280,0,0),rgb(dac0_amp)=(65280,0,0)
	ModifyTable width(Point)=14,width(dac0_start)=47
	ModifyTable width(dac0_end)=44,width(dac0_amp)=55
		
//	edit dac0_start, dac0_end, dac0_amp
//	ModifyTable rgb(dac0_start)=(65280,0,0),rgb(dac0_end)=(65280,0,0),rgb(dac0_amp)=(65280,0,0)
	DoWindow /C table_dac0
End

function edit_dac2(CntrlName) : ButtonControl
	String CntrlName
	WAVE dac2_stimwave=dac2_stimwave
	NVAR freq=freq, samples=samples, dac2_vc=dac2_vc
	NVAR write_permit
	DoWindow table_dac2
	if (write_permit)
		para_change()
	endif
	if (V_flag == 1)
		DoWindow /F table_dac2
		Return(0)
	Endif
	
	Edit/W=(407.4,138.8,600,298.4) dac2_start,dac2_end,dac2_amp
	ModifyTable rgb(dac2_start)=(0,39168,19712),rgb(dac2_end)=(0,39168,19712),rgb(dac2_amp)=(0,39168,19712)
	ModifyTable width(Point)=14,width(dac2_start)=47
	ModifyTable width(dac2_end)=44,width(dac2_amp)=55
	
//	edit dac2_start, dac2_end, dac2_amp
//	ModifyTable rgb(dac2_start)=(0,39168,19712),rgb(dac2_end)=(0,39168,19712),rgb(dac2_amp)=(0,39168,19712)
	DoWindow /C table_dac2
End

function edit_dac3(CntrlName) : ButtonControl
	String CntrlName
	WAVE dac3_stimwave
	NVAR freq, samples, dac3_vc, write_permit

	DoWindow table_dac3
	if (write_permit)
		para_change()
	endif
	if (V_flag == 1)
		DoWindow /F table_dac3
		Return(0)
	Endif
	
	Edit/W=(407.4,138.8,600,298.4) dac3_start,dac3_end,dac3_amp
	ModifyTable width(Point)=14,width(dac3_start)=47
	ModifyTable width(dac3_end)=44,width(dac3_amp)=55
		
//	edit dac3_start, dac3_end, dac3_amp
	DoWindow /C table_dac3
End

function edit_ttl(CntrlName) : ButtonControl
	String CntrlName
	NVAR write_permit
	string substr = CntrlName[9]
	variable num = str2num(substr)
	WAVE ttl_start = $("ttl"+num2str(num)+"_start")
	WAVE ttl_end = $("ttl"+num2str(num)+"_end")
	if (write_permit)
		para_change()
	Endif
	edit ttl_start, ttl_end
	DoWindow /C ttl_table
End

function Do_Average(CntrlName) : ButtonControl
	String CntrlName
//	doWindow /F G_average
	NVAR adc_status0, adc_status1, adc_status2, adc_status3
	NVAR adc0_avg_flag, adc1_avg_flag, adc2_avg_flag, adc3_avg_flag
	NVAR init_display, concat, samples, trace_num, trace_end, freq
	variable temp_adc0_avg_flag, temp_adc1_avg_flag, temp_adc2_avg_flag, temp_adc3_avg_flag
	if(concat)
		make/o/n=(samples*trace_end) concat_0=0, concat_1=0, concat_2=0, concat_3=0
		SetScale /P x 0, (1.0/freq), "ms", concat_0, concat_1, concat_2, concat_3
		SetScale d, -200, 200, "pA", concat_0, concat_1, concat_2, concat_3
	Endif
	temp_adc0_avg_flag = adc0_avg_flag
	temp_adc1_avg_flag = adc1_avg_flag
	temp_adc2_avg_flag = adc2_avg_flag
	temp_adc3_avg_flag = adc3_avg_flag
	if (adc_status0)
		adc0_avg_flag = 1
	Endif
	if (adc_status1)
		adc1_avg_flag = 1
	Endif
	if (adc_status2)
		adc2_avg_flag = 1
	Endif
	if (adc_status3)
		adc3_avg_flag = 1
	Endif
	if (init_display)
		init_g_average(0)
	Endif
// restore flags
	adc0_avg_flag = temp_adc0_avg_flag
	adc1_avg_flag = temp_adc1_avg_flag
	adc2_avg_flag = temp_adc2_avg_flag
	adc3_avg_flag = temp_adc3_avg_flag
	variable ref
	ref = startMSTimer
	average()
	printf "average time: %f (ms)\r", stopMSTimer(ref)/1000.0
End
