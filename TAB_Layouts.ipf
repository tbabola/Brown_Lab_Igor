#pragma rtGlobals=1		// Use modern global access method.

Function init_pair()
	String cell_a_name, cell_b_name
	
	Prompt cell_a_name, "Cell A:"
	Prompt cell_b_name, "Cell B:"
	DoPrompt "Enter cell names", cell_a_name, cell_b_name
	
	String /G root:cell_a = cell_a_name
	String /G root:cell_b = cell_b_name	
End

Function pair(set)
	Variable set //0 or 1 depending on alternating traces
	
	SVAR cell_a = root:cell_a
	SVAR cell_b = root:cell_b
	if(SVAR_exists(cell_a)==0)
		init_pair()
	endif
	
	Wave adc0_avg_0 = root:adc0_avg_0
	Wave adc1_avg_0 = root:adc1_avg_0
	Wave included_traces = root:included_traces
	Wave disregarded_traces = root:disregarded_traces
	
	String a_name, b_name, included, disregarded
	sprintf a_name "%s_avg_%g" cell_a, set
	sprintf b_name "%s_avg_%g" cell_b, set
	sprintf included "%s_%g_included" cell_a, set
	sprintf disregarded "%s_%g_disregarded" cell_b, set
	Duplicate /O adc0_avg_0 $a_name
	Duplicate /O adc1_avg_0 $b_name
	Duplicate /O included_traces $included
	Duplicate /O disregarded_traces $disregarded
End

Function graph_pair(connection_type, genotype, litter, pair, dateofexperiment, age, red_ap, red_sag, blue_ap, blue_sag)
	String connection_type, genotype, litter, pair
	Variable dateofexperiment, age, red_ap, red_sag, blue_ap, blue_sag
	pair_graph(450, 1050, "AP_Stim")
	pair_graph(1950, 2400, "Short_Stim")
	
	String textbox_text, textbox_text2
	sprintf textbox_text "\\Z08Connection Type:%s\rAge: P%g, Date: %g, Pair: %s\rGenotype: %s, Litter: %s" connection_type, age, dateofexperiment, pair, genotype, litter
	sprintf textbox_text2 "Red AP: %g pA, Red Sag: %g pA\rBlue AP: %g pA, Blue Sag: %g pA" red_ap, red_sag, blue_ap, blue_sag
	TextBox/C/N=text0/X=0/Y=0 textbox_text
	AppendText textbox_text2
	NewLayout
	AppendLayoutObject /R=(74.25,74.25,537.75,392.25) graph AP_Stim
	AppendLayoutObject /R=(74.25,399.75,537.75,717.75) graph Short_Stim
End

Function pair_graph(start_time, end_time, graph_name)
	Variable start_time
	Variable end_time
	String graph_name
	
	SVAR cell_a
	SVAR cell_b
	String a_avg_0, b_avg_0, a_avg_1, b_avg_1
	sprintf a_avg_0 "%s_avg_0", cell_a
	sprintf b_avg_0 "%s_avg_0", cell_b
	sprintf a_avg_1 "%s_avg_1", cell_a
	sprintf b_avg_1 "%s_avg_1", cell_b
	Wave adc0_avg_0 = root:$a_avg_0
	Wave adc1_avg_0 = root:$b_avg_0
	Wave adc0_avg_1 = root:$a_avg_1
	Wave adc1_avg_1 = root:$b_avg_1
	
	DoWindow CC0_1_graph
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K CC0_1_graph
	endif	
	PauseUpdate; Silent 1		// building window...
	Display /W=(6,237.8,401.4,416) adc0_avg_0 as graph_name
	DoWindow /C $graph_name 
	AppendToGraph/L=left_bottom adc1_avg_0
	AppendToGraph/L=right_bottom/B=bottom_right adc0_avg_1
	AppendToGraph/L=right_top/B=bottom_right adc1_avg_1

	ModifyGraph lSize=0.9
	ModifyGraph rgb($nameofwave(adc1_avg_0))=(16384,48896,65280),rgb($nameofwave(adc1_avg_1))=(16384,48896,65280)
	ModifyGraph fSize=10
	ModifyGraph standoff=0
	ModifyGraph tickUnit=1
	ModifyGraph btLen=3
	ModifyGraph stLen=1
	ModifyGraph freePos(left_bottom)={0,bottom}
	ModifyGraph freePos(right_bottom)={0,bottom_right}
	ModifyGraph freePos(bottom_right)=0
	ModifyGraph freePos(right_top)={0,bottom_right}
	ModifyGraph axisEnab(left)={0.7,1}
	ModifyGraph axisEnab(bottom)={0,0.45}
	ModifyGraph axisEnab(left_bottom)={0,0.65}
	ModifyGraph axisEnab(right_bottom)={0,0.65}
	ModifyGraph axisEnab(bottom_right)={0.55,1}
	ModifyGraph axisEnab(right_top)={0.7,1}
	ModifyGraph nTicks(left) = 3
	ModifyGraph nTicks(right_top) = 3
	ModifyGraph nTicks(left_bottom) = 5
	ModifyGraph nTicks(right_bottom) = 5
	ModifyGraph lblPosMode=1
	Label left "\\Z12mV"
	Label bottom "\\Z12Time (ms)"
	Label left_bottom "\\Z12mV"
	Label right_bottom " "
	Label bottom_right "\\Z12Time (ms)"
	Label right_top " "
	
	//Set Axis to Scale and Autoscale on Y based on visible axis
	SetAxis bottom start_time, end_time 
	SetAxis bottom_right start_time, end_time
	SetAxis /A=2 left
	SetAxis /A=2 left_bottom
	SetAxis /A=2 right_top
	SetAxis /A=2 right_bottom
End