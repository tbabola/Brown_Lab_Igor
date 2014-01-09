#pragma rtGlobals=1		// Use modern global access method.

//LAST MODIFIED APRIL 19, 2007 TO ADD CC_0123_GRAPH, SINGLE_0123, SINGLEAVE_0123 options.

Window seal_all3() : Graph
	DoWindow seal_all3
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K seal_all3
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(6,237.8,401.4,416) adc0_avg_0 as "seal_all3 and WC_all3"
	AppendToGraph/L=left_pro1 adc1_avg_1
	AppendToGraph/L=left_pro2 adc2_avg_2
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1_avg_1)=(16384,48896,65280),rgb(adc2_avg_2)=(16384,65280,16384)
	ModifyGraph fSize=6
	ModifyGraph standoff=0
	ModifyGraph lblPos(left)=28,lblPos(left_pro1)=28,lblPos(left_pro2)=28
	ModifyGraph tickUnit=1
	ModifyGraph btLen=3
	ModifyGraph stLen=1
	ModifyGraph freePos(left_pro1)={0,bottom}
	ModifyGraph freePos(left_pro2)={0,bottom}
	ModifyGraph axisEnab(left)={0,0.3}
	ModifyGraph axisEnab(left_pro1)={0.33,0.63}
	ModifyGraph axisEnab(left_pro2)={0.66,0.96}
	Label left "\\Z06Chan 0 (pA)"
	Label left_pro1 "\\Z06Chan 1 (pA)"
	Label left_pro2 "\\Z06Chan 2 (pA)"
	TextBox/N=text0/A=MC/X=46.99/Y=47.77 "\\Z06PRO: Seal_all3\r          WC_all3"
EndMacro

Window CC0_1_graph() : Graph
	DoWindow CC0_1_graph
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K CC0_1_graph
	endif	
	PauseUpdate; Silent 1		// building window...
	Display /W=(6,237.8,401.4,416) adc0_avg_0 as "CC0_1_graph"
	AppendToGraph/L=left_bottom adc1_avg_0
	AppendToGraph/L=right_bottom/B=bottom_right adc0_avg_1
	AppendToGraph/L=right_top/B=bottom_right adc1_avg_1
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1_avg_0)=(16384,48896,65280),rgb(adc1_avg_1)=(16384,48896,65280)
	ModifyGraph fSize=6
	ModifyGraph standoff=0
	ModifyGraph lblPos(left)=28,lblPos(bottom)=32,lblPos(left_bottom)=28
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
	Label left "\\Z06mV"
	Label bottom " "
	Label left_bottom "\\Z06mV"
	Label right_bottom " "
	Label bottom_right " "
	Label right_top " "
	TextBox/N=text0/A=MC/X=47.02/Y=48.17 "\\Z06PRO: S_CC0_1\r        CC0 <--> 1"
	TextBox/N=text1/A=MC/X=-27.43/Y=51.83 "\\Z06CC0 --> 1"
	TextBox/N=text2/A=MC/X=25.38/Y=51.83 "\\Z06CC1 --> 0"
EndMacro

Window CC0_2_graph() : Graph
	DoWindow CC0_2_graph
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K CC0_2_graph
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(6,237.8,401.4,416) adc0_avg_0 as "CC0_2_graph"
	AppendToGraph/L=right_bottom/B=bottom_right adc0_avg_1
	AppendToGraph/L=left_bottom adc2_avg_0
	AppendToGraph/L=right_top/B=bottom_right adc2_avg_1
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc2_avg_0)=(32768,65280,0),rgb(adc2_avg_1)=(32768,65280,0)
	ModifyGraph fSize=6
	ModifyGraph standoff=0
	ModifyGraph lblPos(left)=28,lblPos(bottom)=32,lblPos(left_bottom)=28
	ModifyGraph tickUnit=1
	ModifyGraph btLen=3
	ModifyGraph stLen=1
	ModifyGraph freePos(right_bottom)={0,bottom_right}
	ModifyGraph freePos(bottom_right)=0
	ModifyGraph freePos(left_bottom)={0,bottom}
	ModifyGraph freePos(right_top)={0,bottom_right}
	ModifyGraph axisEnab(left)={0.7,1}
	ModifyGraph axisEnab(bottom)={0,0.45}
	ModifyGraph axisEnab(right_bottom)={0,0.65}
	ModifyGraph axisEnab(bottom_right)={0.55,1}
	ModifyGraph axisEnab(left_bottom)={0,0.65}
	ModifyGraph axisEnab(right_top)={0.7,1}
	Label left "\\Z06mV"
	Label bottom " "
	Label right_bottom " "
	Label bottom_right " "
	Label left_bottom "\\Z06mV"
	Label right_top " "
	TextBox/N=text0/A=MC/X=47.02/Y=48.17 "\\Z06PRO: S_CC0_2\r        CC0 <--> 2"
	TextBox/N=text1/A=MC/X=-27.43/Y=51.83 "\\Z06CC0 --> 2"
	TextBox/N=text2/A=MC/X=25.38/Y=51.83 "\\Z06CC2 --> 0"
EndMacro

Window CC1_2_graph() : Graph
	DoWindow CC1_2_graph
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K CC1_2_graph
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(6,237.8,401.4,416)/L=left_bottom adc2_avg_0 as "CC1_2_graph"
	AppendToGraph/L=right_top/B=bottom_right adc2_avg_1
	AppendToGraph adc1_avg_0
	AppendToGraph/L=right_bottom/B=bottom_right adc1_avg_1
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc2_avg_0)=(32768,65280,0),rgb(adc2_avg_1)=(32768,65280,0),rgb(adc1_avg_0)=(16384,48896,65280)
	ModifyGraph rgb(adc1_avg_1)=(16384,48896,65280)
	ModifyGraph fSize=6
	ModifyGraph standoff=0
	ModifyGraph lblPos(left_bottom)=28,lblPos(bottom)=32,lblPos(left)=28
	ModifyGraph tickUnit=1
	ModifyGraph btLen=3
	ModifyGraph stLen=1
	ModifyGraph freePos(left_bottom)={0,bottom}
	ModifyGraph freePos(right_top)={0,bottom_right}
	ModifyGraph freePos(bottom_right)=0
	ModifyGraph freePos(right_bottom)={0,bottom_right}
	ModifyGraph axisEnab(left_bottom)={0,0.65}
	ModifyGraph axisEnab(bottom)={0,0.45}
	ModifyGraph axisEnab(right_top)={0.7,1}
	ModifyGraph axisEnab(bottom_right)={0.55,1}
	ModifyGraph axisEnab(left)={0.7,1}
	ModifyGraph axisEnab(right_bottom)={0,0.65}
	Label left_bottom "\\Z06mV"
	Label bottom " "
	Label right_top " "
	Label bottom_right " "
	Label left "\\Z06mV"
	Label right_bottom " "
	TextBox/N=text0/A=MC/X=47.02/Y=48.17 "\\Z06PRO: S_CC1_2\r        CC1 <--> 2"
	TextBox/N=text1/A=MC/X=-27.43/Y=51.83 "\\Z06CC1 --> 2"
	TextBox/N=text2/A=MC/X=25.38/Y=51.83 "\\Z06CC2 --> 1"
EndMacro

Window CC_0_1_2_graph() : Graph
	DoWindow CC_0_1_2_graph
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K CC_0_1_2_graph
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(1.2,164.6,399,413)/L=Y_1/B=bottom_left adc0_avg_0 as "CC_0_1_2_graph"
	AppendToGraph/L=Y_2/B=bottom_left adc1_avg_0
	AppendToGraph/L=Y_3/B=bottom_left adc2_avg_0
	AppendToGraph/L=Y_mid3/B=bottom_middle adc2_avg_1
	AppendToGraph/L=Y_mid2/B=bottom_middle adc0_avg_1
	AppendToGraph/L=Y_mid1/B=bottom_middle adc1_avg_1
	AppendToGraph/L=Y_right1/B=bottom_right adc2_avg_2
	AppendToGraph/L=Y_right2/B=bottom_right adc0_avg_2
	AppendToGraph/L=Y_right3/B=bottom_right adc1_avg_2
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1_avg_0)=(0,43520,65280),rgb(adc2_avg_0)=(32768,65280,0),rgb(adc2_avg_1)=(32768,65280,0)
	ModifyGraph rgb(adc1_avg_1)=(0,43520,65280),rgb(adc2_avg_2)=(32768,65280,0),rgb(adc1_avg_2)=(0,43520,65280)
	ModifyGraph fSize=5
	ModifyGraph standoff=0
	ModifyGraph lblPos(Y_1)=15,lblPos(bottom_left)=18,lblPos(Y_2)=15,lblPos(Y_3)=15
	ModifyGraph lblPos(bottom_middle)=18,lblPos(bottom_right)=18
	ModifyGraph ZisZ(Y_1)=1,ZisZ(Y_2)=1,ZisZ(Y_3)=1,ZisZ(Y_mid3)=1,ZisZ(Y_mid2)=1,ZisZ(Y_mid1)=1
	ModifyGraph ZisZ(Y_right1)=1,ZisZ(bottom_right)=1,ZisZ(Y_right2)=1,ZisZ(Y_right3)=1
	ModifyGraph zapTZ(Y_1)=1,zapTZ(Y_2)=1,zapTZ(Y_3)=1,zapTZ(Y_mid3)=1,zapTZ(Y_mid2)=1
	ModifyGraph zapTZ(Y_mid1)=1,zapTZ(Y_right1)=1,zapTZ(bottom_right)=1,zapTZ(Y_right2)=1
	ModifyGraph zapTZ(Y_right3)=1
	ModifyGraph zapLZ(Y_1)=1,zapLZ(Y_2)=1,zapLZ(Y_3)=1,zapLZ(Y_mid3)=1,zapLZ(Y_mid2)=1
	ModifyGraph zapLZ(Y_mid1)=1,zapLZ(Y_right1)=1,zapLZ(bottom_right)=1,zapLZ(Y_right2)=1
	ModifyGraph zapLZ(Y_right3)=1
	ModifyGraph tickUnit=1
	ModifyGraph btLen=3
	ModifyGraph freePos(Y_1)={0,bottom_left}
	ModifyGraph freePos(bottom_left)={0,Y_1}
	ModifyGraph freePos(Y_2)={0,bottom_left}
	ModifyGraph freePos(Y_3)={0,bottom_left}
	ModifyGraph freePos(Y_mid3)={0,bottom_middle}
	ModifyGraph freePos(bottom_middle)={0,Y_mid1}
	ModifyGraph freePos(Y_mid2)={0,bottom_middle}
	ModifyGraph freePos(Y_mid1)={0,bottom_middle}
	ModifyGraph freePos(Y_right1)={0,bottom_right}
	ModifyGraph freePos(bottom_right)={0,Y_right1}
	ModifyGraph freePos(Y_right2)={0,bottom_right}
	ModifyGraph freePos(Y_right3)={0,bottom_right}
	ModifyGraph axisEnab(Y_1)={0.8,1}
	ModifyGraph axisEnab(bottom_left)={0.02,0.32}
	ModifyGraph axisEnab(Y_2)={0.37,0.72}
	ModifyGraph axisEnab(Y_3)={0,0.35}
	ModifyGraph axisEnab(Y_mid3)={0,0.35}
	ModifyGraph axisEnab(bottom_middle)={0.36,0.66}
	ModifyGraph axisEnab(Y_mid2)={0.37,0.72}
	ModifyGraph axisEnab(Y_mid1)={0.8,1}
	ModifyGraph axisEnab(Y_right1)={0.8,1}
	ModifyGraph axisEnab(bottom_right)={0.7,1}
	ModifyGraph axisEnab(Y_right2)={0.37,0.72}
	ModifyGraph axisEnab(Y_right3)={0,0.35}
	Label Y_1 "\\Z04mV"
	Label bottom_left "\\Z05ms"
	Label Y_2 "\\Z04mV"
	Label Y_3 "\\Z04mV"
	Label Y_mid3 " "
	Label Y_mid2 " "
	Label Y_mid1 " "
	Label Y_right1 " "
	Label bottom_right "\\Z05ms"
	Label Y_right2 "  "
	Label Y_right3 " "
	TextBox/N=text0/A=MC/X=36.21/Y=50.25 "\\Z06CC2 --> 0 & 1"
	TextBox/N=text1/A=MC/X=-33.77/Y=50.52 "\\Z06CC0 --> 1 & 2"
	TextBox/N=text2/A=MC/X=2.30/Y=50.52 "\\Z06CC1 --> 0 & 2"
EndMacro


Macro Vclamp_resistance(max_value,min_value, step)
	variable max_value, min_value, step
	print (step*(10^-3))/((max_value-min_value)*10^-12)/10^6
endmacro

Macro VCR(step)
	variable step
	print (step*(10^-3))/((vcsr(B)-vcsr(A))*10^-12)/10^6
endmacro

Macro VCinput_evenolderversion(step)
	variable step
	print (step*(10^-3))/((mean(ave_dummy,195,205)-mean(ave_dummy,2.5,7.5))*10^-12)/10^6
endmacro

Macro Iclamp_resistance(max_value,min_value,step)
	variable max_value, min_value, step
	print ((max_value-min_value)*(10^-3))/((step)*10^-12)/10^6
endmacro

Window allten_graph() : Graph
	DoWindow allten_graph
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K allten_graph
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(2.4,209,609.6,413)/L=Y_1/B=bottom_left adc0_avg_0 as "allten_graph"
	AppendToGraph/L=Y_2/B=bottom_left adc1_avg_0
	AppendToGraph/L=Y_3/B=bottom_left adc2_avg_0
	AppendToGraph/L=Y_mid1/B=bottom_middle adc0_avg_1
	AppendToGraph/L=Y_mid2/B=bottom_middle adc1_avg_1
	AppendToGraph/L=Y_mid3/B=bottom_middle adc2_avg_1
	AppendToGraph/L=Y_right1/B=bottom_right adc0_avg_2
	AppendToGraph/L=Y_right2/B=bottom_right adc1_avg_2
	AppendToGraph/L=Y_right3/B=bottom_right adc2_avg_2
	AppendToGraph/L=Y_farright1/B=bottom_farright adc0_avg_3
	AppendToGraph/L=Y_farright2/B=bottom_farright adc1_avg_3
	AppendToGraph/L=Y_farright3/B=bottom_farright adc2_avg_3
	AppendToGraph/L=Y_U_farright1/B=bottom_U_farright adc0_avg_4
	AppendToGraph/L=Y_U_farright2/B=bottom_U_farright adc1_avg_4
	AppendToGraph/L=Y_U_farright3/B=bottom_U_farright adc2_avg_4
	AppendToGraph/L=Y_4/B=bottom_left adc0_avg_5
	AppendToGraph/L=Y_5/B=bottom_left adc1_avg_5
	AppendToGraph/L=Y_6/B=bottom_left adc2_avg_5
	AppendToGraph/L=Y_mid4/B=bottom_middle adc0_avg_6
	AppendToGraph/L=Y_mid5/B=bottom_middle adc1_avg_6
	AppendToGraph/L=Y_mid6/B=bottom_middle adc2_avg_6
	AppendToGraph/L=Y_right4/B=bottom_right adc0_avg_7
	AppendToGraph/L=Y_right5/B=bottom_right adc1_avg_7
	AppendToGraph/L=Y_right6/B=bottom_right adc2_avg_7
	AppendToGraph/L=Y_farright4/B=bottom_farright adc0_avg_8
	AppendToGraph/L=Y_farright5/B=bottom_farright adc1_avg_8
	AppendToGraph/L=Y_farright6/B=bottom_farright adc2_avg_8
	AppendToGraph/L=Y_U_farright4/B=bottom_U_farright adc0_avg_9
	AppendToGraph/L=Y_U_farright5/B=bottom_U_farright adc1_avg_9
	AppendToGraph/L=Y_U_farright6/B=bottom_U_farright adc2_avg_9
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc0_avg_0)=(65280,0,0),rgb(adc1_avg_0)=(24576,24576,65280),rgb(adc2_avg_0)=(0,65280,0)
	ModifyGraph rgb(adc0_avg_1)=(65280,0,0),rgb(adc1_avg_1)=(24576,24576,65280),rgb(adc2_avg_1)=(0,65280,0)
	ModifyGraph rgb(adc0_avg_2)=(65280,0,0),rgb(adc1_avg_2)=(24576,24576,65280),rgb(adc2_avg_2)=(0,65280,0)
	ModifyGraph rgb(adc0_avg_3)=(65280,0,0),rgb(adc1_avg_3)=(24576,24576,65280),rgb(adc2_avg_3)=(0,65280,0)
	ModifyGraph rgb(adc0_avg_4)=(65280,0,0),rgb(adc1_avg_4)=(24576,24576,65280),rgb(adc2_avg_4)=(0,65280,0)
	ModifyGraph rgb(adc0_avg_5)=(65280,0,0),rgb(adc1_avg_5)=(24576,24576,65280),rgb(adc2_avg_5)=(0,65280,0)
	ModifyGraph rgb(adc0_avg_6)=(65280,0,0),rgb(adc1_avg_6)=(24576,24576,65280),rgb(adc2_avg_6)=(0,65280,0)
	ModifyGraph rgb(adc0_avg_7)=(65280,0,0),rgb(adc1_avg_7)=(24576,24576,65280),rgb(adc2_avg_7)=(0,65280,0)
	ModifyGraph rgb(adc0_avg_8)=(65280,0,0),rgb(adc1_avg_8)=(24576,24576,65280),rgb(adc2_avg_8)=(0,65280,0)
	ModifyGraph rgb(adc0_avg_9)=(65280,0,0),rgb(adc1_avg_9)=(24576,24576,65280),rgb(adc2_avg_9)=(0,65280,0)
	ModifyGraph tick(Y_1)=2,tick(bottom_left)=2,tick(Y_3)=2,tick(Y_mid1)=2,tick(bottom_middle)=2
	ModifyGraph tick(Y_mid3)=2,tick(Y_right1)=2,tick(bottom_right)=2,tick(Y_right3)=2
	ModifyGraph tick(Y_farright1)=2,tick(bottom_farright)=2,tick(Y_farright3)=2,tick(Y_U_farright1)=2
	ModifyGraph tick(bottom_U_farright)=2,tick(Y_U_farright3)=2,tick(Y_4)=2,tick(Y_6)=2
	ModifyGraph tick(Y_mid4)=2,tick(Y_mid6)=2,tick(Y_right4)=2,tick(Y_right6)=2,tick(Y_farright4)=2
	ModifyGraph tick(Y_farright6)=2,tick(Y_U_farright4)=2,tick(Y_U_farright6)=2
	ModifyGraph fSize=5
	ModifyGraph standoff(Y_1)=0,standoff(bottom_left)=0,standoff(Y_2)=0,standoff(Y_3)=0
	ModifyGraph standoff(Y_mid1)=0,standoff(bottom_middle)=0,standoff(Y_mid2)=0,standoff(Y_mid3)=0
	ModifyGraph standoff(Y_right1)=0,standoff(bottom_right)=0,standoff(Y_right2)=0,standoff(Y_right3)=0
	ModifyGraph standoff(Y_farright1)=0,standoff(bottom_farright)=0,standoff(Y_farright2)=0
	ModifyGraph standoff(Y_farright3)=0,standoff(Y_U_farright1)=0,standoff(Y_4)=0,standoff(Y_5)=0
	ModifyGraph standoff(Y_6)=0,standoff(Y_mid4)=0,standoff(Y_mid5)=0,standoff(Y_mid6)=0
	ModifyGraph standoff(Y_right4)=0,standoff(Y_right5)=0,standoff(Y_right6)=0,standoff(Y_farright4)=0
	ModifyGraph axThick=0.7
	ModifyGraph tlblRGB(Y_1)=(65280,0,0),tlblRGB(Y_2)=(0,15872,65280),tlblRGB(Y_3)=(0,65280,0)
	ModifyGraph tlblRGB(Y_mid1)=(65280,0,0),tlblRGB(Y_mid2)=(0,15872,65280),tlblRGB(Y_mid3)=(0,65280,0)
	ModifyGraph tlblRGB(Y_right1)=(65280,0,0),tlblRGB(Y_right2)=(0,15872,65280),tlblRGB(Y_right3)=(0,65280,0)
	ModifyGraph tlblRGB(Y_farright1)=(65280,0,0),tlblRGB(Y_farright2)=(0,15872,65280)
	ModifyGraph tlblRGB(Y_farright3)=(0,65280,0),tlblRGB(Y_U_farright1)=(65280,0,0)
	ModifyGraph tlblRGB(Y_U_farright2)=(0,15872,65280),tlblRGB(Y_U_farright3)=(0,65280,0)
	ModifyGraph tlblRGB(Y_4)=(65280,0,0),tlblRGB(Y_5)=(0,15872,65280),tlblRGB(Y_6)=(0,65280,0)
	ModifyGraph tlblRGB(Y_mid4)=(65280,0,0),tlblRGB(Y_mid5)=(0,15872,65280),tlblRGB(Y_mid6)=(0,65280,0)
	ModifyGraph tlblRGB(Y_right4)=(65280,0,0),tlblRGB(Y_right5)=(0,15872,65280),tlblRGB(Y_right6)=(0,65280,0)
	ModifyGraph tlblRGB(Y_farright4)=(65280,0,0),tlblRGB(Y_farright5)=(0,15872,65280)
	ModifyGraph tlblRGB(Y_farright6)=(0,65280,0),tlblRGB(Y_U_farright4)=(65280,0,0)
	ModifyGraph tlblRGB(Y_U_farright5)=(0,15872,65280),tlblRGB(Y_U_farright6)=(0,65280,0)
	ModifyGraph alblRGB(Y_1)=(65280,0,0),alblRGB(Y_2)=(0,15872,65280),alblRGB(Y_3)=(0,65280,0)
	ModifyGraph alblRGB(Y_mid1)=(65280,0,0),alblRGB(Y_mid2)=(0,15872,65280),alblRGB(Y_mid3)=(0,65280,0)
	ModifyGraph alblRGB(Y_right1)=(65280,0,0),alblRGB(Y_right2)=(0,15872,65280),alblRGB(Y_right3)=(0,65280,0)
	ModifyGraph alblRGB(Y_farright1)=(65280,0,0),alblRGB(Y_farright2)=(0,15872,65280)
	ModifyGraph alblRGB(Y_farright3)=(0,65280,0),alblRGB(Y_U_farright1)=(65280,0,0)
	ModifyGraph alblRGB(Y_U_farright2)=(0,15872,65280),alblRGB(Y_U_farright3)=(0,65280,0)
	ModifyGraph alblRGB(Y_4)=(65280,0,0),alblRGB(Y_5)=(0,15872,65280),alblRGB(Y_6)=(0,65280,0)
	ModifyGraph alblRGB(Y_mid4)=(65280,0,0),alblRGB(Y_mid5)=(0,15872,65280),alblRGB(Y_mid6)=(0,65280,0)
	ModifyGraph alblRGB(Y_right4)=(65280,0,0),alblRGB(Y_right5)=(0,15872,65280),alblRGB(Y_right6)=(0,65280,0)
	ModifyGraph alblRGB(Y_farright4)=(65280,0,0),alblRGB(Y_farright5)=(0,15872,65280)
	ModifyGraph alblRGB(Y_farright6)=(0,65280,0),alblRGB(Y_U_farright4)=(65280,0,0)
	ModifyGraph alblRGB(Y_U_farright5)=(0,15872,65280),alblRGB(Y_U_farright6)=(0,65280,0)
	ModifyGraph lblPos(Y_1)=15,lblPos(bottom_left)=18,lblPos(Y_2)=15,lblPos(Y_3)=-15
	ModifyGraph lblPos(Y_mid1)=15,lblPos(bottom_middle)=18,lblPos(Y_mid2)=15,lblPos(Y_right1)=15
	ModifyGraph lblPos(bottom_right)=18,lblPos(Y_right2)=15,lblPos(Y_farright1)=15,lblPos(bottom_farright)=18
	ModifyGraph lblPos(Y_farright2)=15,lblPos(Y_U_farright1)=15,lblPos(bottom_U_farright)=18
	ModifyGraph lblPos(Y_U_farright2)=15,lblPos(Y_4)=15,lblPos(Y_5)=15,lblPos(Y_mid5)=15
	ModifyGraph lblPos(Y_right5)=15,lblPos(Y_farright5)=15,lblPos(Y_U_farright5)=15
	ModifyGraph ZisZ(Y_1)=1,ZisZ(Y_2)=1,ZisZ(Y_3)=1,ZisZ(Y_mid1)=1,ZisZ(Y_mid2)=1,ZisZ(Y_mid3)=1
	ModifyGraph ZisZ(Y_right1)=1,ZisZ(bottom_right)=1,ZisZ(Y_right2)=1,ZisZ(Y_right3)=1
	ModifyGraph ZisZ(Y_farright1)=1,ZisZ(bottom_farright)=1,ZisZ(Y_farright2)=1,ZisZ(Y_farright3)=1
	ModifyGraph ZisZ(Y_U_farright1)=1,ZisZ(bottom_U_farright)=1,ZisZ(Y_U_farright2)=1
	ModifyGraph ZisZ(Y_U_farright3)=1,ZisZ(Y_4)=1,ZisZ(Y_5)=1,ZisZ(Y_6)=1,ZisZ(Y_mid4)=1
	ModifyGraph ZisZ(Y_mid5)=1,ZisZ(Y_mid6)=1,ZisZ(Y_right4)=1,ZisZ(Y_right5)=1,ZisZ(Y_right6)=1
	ModifyGraph ZisZ(Y_farright4)=1,ZisZ(Y_farright5)=1,ZisZ(Y_farright6)=1,ZisZ(Y_U_farright4)=1
	ModifyGraph ZisZ(Y_U_farright5)=1,ZisZ(Y_U_farright6)=1
	ModifyGraph zapTZ(Y_1)=1,zapTZ(Y_2)=1,zapTZ(Y_3)=1,zapTZ(Y_mid1)=1,zapTZ(Y_mid2)=1
	ModifyGraph zapTZ(Y_mid3)=1,zapTZ(Y_right1)=1,zapTZ(bottom_right)=1,zapTZ(Y_right2)=1
	ModifyGraph zapTZ(Y_right3)=1,zapTZ(Y_farright1)=1,zapTZ(bottom_farright)=1,zapTZ(Y_farright2)=1
	ModifyGraph zapTZ(Y_farright3)=1,zapTZ(Y_U_farright1)=1,zapTZ(bottom_U_farright)=1
	ModifyGraph zapTZ(Y_U_farright2)=1,zapTZ(Y_U_farright3)=1,zapTZ(Y_4)=1,zapTZ(Y_5)=1
	ModifyGraph zapTZ(Y_6)=1,zapTZ(Y_mid4)=1,zapTZ(Y_mid5)=1,zapTZ(Y_mid6)=1,zapTZ(Y_right4)=1
	ModifyGraph zapTZ(Y_right5)=1,zapTZ(Y_right6)=1,zapTZ(Y_farright4)=1,zapTZ(Y_farright5)=1
	ModifyGraph zapTZ(Y_farright6)=1,zapTZ(Y_U_farright4)=1,zapTZ(Y_U_farright5)=1,zapTZ(Y_U_farright6)=1
	ModifyGraph zapLZ(Y_1)=1,zapLZ(Y_2)=1,zapLZ(Y_3)=1,zapLZ(Y_mid1)=1,zapLZ(Y_mid2)=1
	ModifyGraph zapLZ(Y_mid3)=1,zapLZ(Y_right1)=1,zapLZ(bottom_right)=1,zapLZ(Y_right2)=1
	ModifyGraph zapLZ(Y_right3)=1,zapLZ(Y_farright1)=1,zapLZ(bottom_farright)=1,zapLZ(Y_farright2)=1
	ModifyGraph zapLZ(Y_farright3)=1,zapLZ(Y_U_farright1)=1,zapLZ(bottom_U_farright)=1
	ModifyGraph zapLZ(Y_U_farright2)=1,zapLZ(Y_U_farright3)=1,zapLZ(Y_4)=1,zapLZ(Y_5)=1
	ModifyGraph zapLZ(Y_6)=1,zapLZ(Y_mid4)=1,zapLZ(Y_mid5)=1,zapLZ(Y_mid6)=1,zapLZ(Y_right4)=1
	ModifyGraph zapLZ(Y_right5)=1,zapLZ(Y_right6)=1,zapLZ(Y_farright4)=1,zapLZ(Y_farright5)=1
	ModifyGraph zapLZ(Y_farright6)=1,zapLZ(Y_U_farright4)=1,zapLZ(Y_U_farright5)=1,zapLZ(Y_U_farright6)=1
	ModifyGraph tickExp(Y_U_farright1)=1,tickExp(bottom_U_farright)=1,tickExp(Y_U_farright2)=1
	ModifyGraph tickExp(Y_U_farright3)=1,tickExp(Y_4)=1,tickExp(Y_5)=1,tickExp(Y_6)=1
	ModifyGraph tickExp(Y_mid4)=1,tickExp(Y_mid5)=1,tickExp(Y_mid6)=1,tickExp(Y_right4)=1
	ModifyGraph tickExp(Y_right5)=1,tickExp(Y_right6)=1,tickExp(Y_farright4)=1,tickExp(Y_farright5)=1
	ModifyGraph tickExp(Y_farright6)=1,tickExp(Y_U_farright4)=1,tickExp(Y_U_farright5)=1
	ModifyGraph tickExp(Y_U_farright6)=1
	ModifyGraph tickUnit=1
	ModifyGraph btLen=1
	ModifyGraph tlOffset(Y_2)=-8,tlOffset(Y_mid2)=-8,tlOffset(Y_right2)=-8,tlOffset(Y_farright2)=-8
	ModifyGraph tlOffset(Y_farright3)=-11,tlOffset(Y_U_farright2)=-8,tlOffset(Y_U_farright3)=-11
	ModifyGraph tlOffset(Y_5)=-8,tlOffset(Y_mid5)=-8,tlOffset(Y_right5)=-8,tlOffset(Y_farright5)=-8
	ModifyGraph tlOffset(Y_farright6)=-11,tlOffset(Y_U_farright5)=-8,tlOffset(Y_U_farright6)=-11
	ModifyGraph freePos(Y_1)={0,bottom_left}
	ModifyGraph freePos(bottom_left)={0,Y_1}
	ModifyGraph freePos(Y_2)={0.184,kwFraction}
	ModifyGraph freePos(Y_3)={0.006,kwFraction}
	ModifyGraph freePos(Y_mid1)={0,bottom_middle}
	ModifyGraph freePos(bottom_middle)={0,Y_mid1}
	ModifyGraph freePos(Y_mid2)={0.388,kwFraction}
	ModifyGraph freePos(Y_mid3)={0.21,kwFraction}
	ModifyGraph freePos(Y_right1)={0,bottom_right}
	ModifyGraph freePos(bottom_right)={0,Y_right1}
	ModifyGraph freePos(Y_right2)={0.592,kwFraction}
	ModifyGraph freePos(Y_right3)={0.414,kwFraction}
	ModifyGraph freePos(Y_farright1)={0,bottom_farright}
	ModifyGraph freePos(bottom_farright)={0,Y_farright1}
	ModifyGraph freePos(Y_farright2)={0,bottom_farright}
	ModifyGraph freePos(Y_farright3)={0.796,kwFraction}
	ModifyGraph freePos(Y_U_farright1)={0,bottom_U_farright}
	ModifyGraph freePos(bottom_U_farright)={0,Y_U_farright1}
	ModifyGraph freePos(Y_U_farright2)={0,bottom_U_farright}
	ModifyGraph freePos(Y_U_farright3)={1,kwFraction}
	ModifyGraph freePos(Y_4)={0,bottom_left}
	ModifyGraph freePos(Y_5)={0.184,kwFraction}
	ModifyGraph freePos(Y_6)={0.006,kwFraction}
	ModifyGraph freePos(Y_mid4)={0,bottom_middle}
	ModifyGraph freePos(Y_mid5)={0.388,kwFraction}
	ModifyGraph freePos(Y_mid6)={0.21,kwFraction}
	ModifyGraph freePos(Y_right4)={0,bottom_right}
	ModifyGraph freePos(Y_right5)={0.592,kwFraction}
	ModifyGraph freePos(Y_right6)={0.414,kwFraction}
	ModifyGraph freePos(Y_farright4)={0,bottom_farright}
	ModifyGraph freePos(Y_farright5)={0,bottom_farright}
	ModifyGraph freePos(Y_farright6)={0.796,kwFraction}
	ModifyGraph freePos(Y_U_farright4)={0,bottom_U_farright}
	ModifyGraph freePos(Y_U_farright5)={0,bottom_U_farright}
	ModifyGraph freePos(Y_U_farright6)={1,kwFraction}
	ModifyGraph axisEnab(Y_1)={0.515,1}
	ModifyGraph axisEnab(bottom_left)={0.02,0.184}
	ModifyGraph axisEnab(Y_2)={0.515,1}
	ModifyGraph axisEnab(Y_3)={0.515,1}
	ModifyGraph axisEnab(Y_mid1)={0.515,1}
	ModifyGraph axisEnab(bottom_middle)={0.224,0.388}
	ModifyGraph axisEnab(Y_mid2)={0.515,1}
	ModifyGraph axisEnab(Y_mid3)={0.515,1}
	ModifyGraph axisEnab(Y_right1)={0.515,1}
	ModifyGraph axisEnab(bottom_right)={0.428,0.592}
	ModifyGraph axisEnab(Y_right2)={0.515,1}
	ModifyGraph axisEnab(Y_right3)={0.515,1}
	ModifyGraph axisEnab(Y_farright1)={0.515,1}
	ModifyGraph axisEnab(bottom_farright)={0.632,0.796}
	ModifyGraph axisEnab(Y_farright2)={0.515,1}
	ModifyGraph axisEnab(Y_farright3)={0.515,1}
	ModifyGraph axisEnab(Y_U_farright1)={0.515,1}
	ModifyGraph axisEnab(bottom_U_farright)={0.836,1}
	ModifyGraph axisEnab(Y_U_farright2)={0.515,1}
	ModifyGraph axisEnab(Y_U_farright3)={0.515,1}
	ModifyGraph axisEnab(Y_4)={0,0.485}
	ModifyGraph axisEnab(Y_5)={0,0.485}
	ModifyGraph axisEnab(Y_6)={0,0.485}
	ModifyGraph axisEnab(Y_mid4)={0,0.485}
	ModifyGraph axisEnab(Y_mid5)={0,0.485}
	ModifyGraph axisEnab(Y_mid6)={0,0.485}
	ModifyGraph axisEnab(Y_right4)={0,0.485}
	ModifyGraph axisEnab(Y_right5)={0,0.485}
	ModifyGraph axisEnab(Y_right6)={0,0.485}
	ModifyGraph axisEnab(Y_farright4)={0,0.485}
	ModifyGraph axisEnab(Y_farright5)={0,0.485}
	ModifyGraph axisEnab(Y_farright6)={0,0.485}
	ModifyGraph axisEnab(Y_U_farright4)={0,0.485}
	ModifyGraph axisEnab(Y_U_farright5)={0,0.485}
	ModifyGraph axisEnab(Y_U_farright6)={0,0.485}
	Label Y_1 " "
	Label bottom_left " "
	Label Y_2 " "
	Label Y_3 " "
	Label Y_mid1 " "
	Label bottom_middle " "
	Label Y_mid2 " "
	Label Y_mid3 " "
	Label Y_right1 " "
	Label bottom_right " "
	Label Y_right2 " "
	Label Y_right3 " "
	Label Y_farright1 " "
	Label bottom_farright " "
	Label Y_farright2 " "
	Label Y_farright3 " "
	Label Y_U_farright1 " "
	Label bottom_U_farright " "
	Label Y_U_farright2 " "
	Label Y_U_farright3 " "
	Label Y_4 " "
	Label Y_5 " "
	Label Y_6 " "
	Label Y_mid4 " "
	Label Y_mid5 " "
	Label Y_mid6 " "
	Label Y_right4 " "
	Label Y_right5 " "
	Label Y_right6 " "
	Label Y_farright4 " "
	Label Y_farright5 " "
	Label Y_farright6 " "
	Label Y_U_farright4 " "
	Label Y_U_farright5 " "
	Label Y_U_farright6 " "
EndMacro

Window amp_points_graph() : Graph
	DoWindow amp_points_graph
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K amp_points_graph
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(405.6,308.6,610.2,415.4) amp_points_wave_0
	AppendToGraph/R amp_points_wave_1
	AppendToGraph/L=left1 amp_points_wave_2
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph rgb(amp_points_wave_1)=(0,15872,65280),rgb(amp_points_wave_2)=(0,65280,0)
	ModifyGraph fSize=6
	ModifyGraph standoff(left)=0,standoff(right)=0,standoff(left1)=0
	ModifyGraph axRGB(left)=(65280,0,0),axRGB(right)=(24576,24576,65280),axRGB(left1)=(0,65280,0)
	ModifyGraph tlblRGB(left)=(65280,0,0),tlblRGB(right)=(24576,24576,65280),tlblRGB(left1)=(0,65280,0)
	ModifyGraph alblRGB(left)=(65280,0,0),alblRGB(right)=(24576,24576,65280),alblRGB(left1)=(0,65280,0)
	ModifyGraph lblPos(left)=51
	ModifyGraph zapTZ(left)=1,zapTZ(right)=1,zapTZ(left1)=1
	ModifyGraph tickUnit(left)=1,tickUnit(right)=1,tickUnit(left1)=1
	ModifyGraph btLen(left)=2,btLen(right)=2,btLen(left1)=2
	ModifyGraph freePos(left1)=-14
	SetAxis left -75,-55
	SetAxis right -75,-55
	SetAxis left1 -75,-55
EndMacro

Window CC_0123_graph() : Graph
	DoWindow CC_0123_graph
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K CC_0123_graph
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(4.8,317.6,432.6,566)/L=Y_1/B=bottom_left adc0_avg_0 as "CC_0123_graph"
	AppendToGraph/L=Y_2/B=bottom_left adc1_avg_0
	AppendToGraph/L=Y_3/B=bottom_left adc2_avg_0
	AppendToGraph/L=Y_4/B=bottom_left adc3_avg_0
	AppendToGraph/L=Y_mid3/B=bottom_middle adc2_avg_1
	AppendToGraph/L=Y_mid2/B=bottom_middle adc0_avg_1
	AppendToGraph/L=Y_mid1/B=bottom_middle adc1_avg_1
	AppendToGraph/L=Y_mid4/B=bottom_middle adc3_avg_1
	AppendToGraph/L=Y_right1/B=bottom_right adc2_avg_2
	AppendToGraph/L=Y_right2/B=bottom_right adc0_avg_2
	AppendToGraph/L=Y_right3/B=bottom_right adc1_avg_2
	AppendToGraph/L=Y_right4/B=bottom_right adc3_avg_2
	AppendToGraph/L=Y_farright1/B=bottom_farright adc3_avg_3
	AppendToGraph/L=Y_farright2/B=bottom_farright adc0_avg_3
	AppendToGraph/L=Y_farright3/B=bottom_farright adc1_avg_3
	AppendToGraph/L=Y_farright4/B=bottom_farright adc2_avg_3
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1_avg_0)=(0,43520,65280),rgb(adc2_avg_0)=(32768,65280,0),rgb(adc3_avg_0)=(0,0,0)
	ModifyGraph rgb(adc2_avg_1)=(32768,65280,0),rgb(adc1_avg_1)=(0,43520,65280),rgb(adc3_avg_1)=(0,0,0)
	ModifyGraph rgb(adc2_avg_2)=(32768,65280,0),rgb(adc1_avg_2)=(0,43520,65280),rgb(adc3_avg_2)=(0,0,0)
	ModifyGraph rgb(adc3_avg_3)=(0,0,0),rgb(adc1_avg_3)=(0,43520,65280),rgb(adc2_avg_3)=(0,65280,0)
	ModifyGraph fSize=5
	ModifyGraph standoff=0
	ModifyGraph lblPos(Y_1)=15,lblPos(bottom_left)=18,lblPos(Y_2)=15,lblPos(Y_3)=15
	ModifyGraph lblPos(Y_4)=15,lblPos(bottom_middle)=18,lblPos(bottom_right)=18,lblPos(bottom_farright)=18
	ModifyGraph ZisZ(Y_1)=1,ZisZ(Y_2)=1,ZisZ(Y_3)=1,ZisZ(Y_4)=1,ZisZ(Y_mid3)=1,ZisZ(Y_mid2)=1
	ModifyGraph ZisZ(Y_mid1)=1,ZisZ(Y_mid4)=1,ZisZ(Y_right1)=1,ZisZ(bottom_right)=1
	ModifyGraph ZisZ(Y_right2)=1,ZisZ(Y_right3)=1,ZisZ(Y_right4)=1,ZisZ(Y_farright1)=1
	ModifyGraph ZisZ(bottom_farright)=1,ZisZ(Y_farright2)=1,ZisZ(Y_farright3)=1,ZisZ(Y_farright4)=1
	ModifyGraph zapTZ(Y_1)=1,zapTZ(Y_2)=1,zapTZ(Y_3)=1,zapTZ(Y_4)=1,zapTZ(Y_mid3)=1
	ModifyGraph zapTZ(Y_mid2)=1,zapTZ(Y_mid1)=1,zapTZ(Y_mid4)=1,zapTZ(Y_right1)=1,zapTZ(bottom_right)=1
	ModifyGraph zapTZ(Y_right2)=1,zapTZ(Y_right3)=1,zapTZ(Y_right4)=1,zapTZ(Y_farright1)=1
	ModifyGraph zapTZ(bottom_farright)=1,zapTZ(Y_farright2)=1,zapTZ(Y_farright3)=1,zapTZ(Y_farright4)=1
	ModifyGraph zapLZ(Y_1)=1,zapLZ(Y_2)=1,zapLZ(Y_3)=1,zapLZ(Y_4)=1,zapLZ(Y_mid3)=1
	ModifyGraph zapLZ(Y_mid2)=1,zapLZ(Y_mid1)=1,zapLZ(Y_mid4)=1,zapLZ(Y_right1)=1,zapLZ(bottom_right)=1
	ModifyGraph zapLZ(Y_right2)=1,zapLZ(Y_right3)=1,zapLZ(Y_right4)=1,zapLZ(Y_farright1)=1
	ModifyGraph zapLZ(bottom_farright)=1,zapLZ(Y_farright2)=1,zapLZ(Y_farright3)=1,zapLZ(Y_farright4)=1
	ModifyGraph tickUnit=1
	ModifyGraph btLen=3
	ModifyGraph freePos(Y_1)={0,bottom_left}
	ModifyGraph freePos(bottom_left)={0,Y_1}
	ModifyGraph freePos(Y_2)={0,bottom_left}
	ModifyGraph freePos(Y_3)={0,bottom_left}
	ModifyGraph freePos(Y_4)={0,bottom_left}
	ModifyGraph freePos(Y_mid3)={0,bottom_middle}
	ModifyGraph freePos(bottom_middle)={0,Y_mid1}
	ModifyGraph freePos(Y_mid2)={0,bottom_middle}
	ModifyGraph freePos(Y_mid1)={0,bottom_middle}
	ModifyGraph freePos(Y_mid4)={0,bottom_middle}
	ModifyGraph freePos(Y_right1)={0,bottom_right}
	ModifyGraph freePos(bottom_right)={0,Y_right1}
	ModifyGraph freePos(Y_right2)={0,bottom_right}
	ModifyGraph freePos(Y_right3)={0,bottom_right}
	ModifyGraph freePos(Y_right4)={0,bottom_right}
	ModifyGraph freePos(Y_farright1)={0,bottom_farright}
	ModifyGraph freePos(bottom_farright)={0,Y_1}
	ModifyGraph freePos(Y_farright2)={0,bottom_farright}
	ModifyGraph freePos(Y_farright3)={0,bottom_farright}
	ModifyGraph freePos(Y_farright4)={0,bottom_farright}
	ModifyGraph axisEnab(Y_1)={0.85,1}
	ModifyGraph axisEnab(bottom_left)={0,0.22}
	ModifyGraph axisEnab(Y_2)={0.56,0.82}
	ModifyGraph axisEnab(Y_3)={0.28,0.54}
	ModifyGraph axisEnab(Y_4)={0,0.26}
	ModifyGraph axisEnab(Y_mid3)={0.28,0.54}
	ModifyGraph axisEnab(bottom_middle)={0.26,0.48}
	ModifyGraph axisEnab(Y_mid2)={0.56,0.82}
	ModifyGraph axisEnab(Y_mid1)={0.85,1}
	ModifyGraph axisEnab(Y_mid4)={0,0.26}
	ModifyGraph axisEnab(Y_right1)={0.85,1}
	ModifyGraph axisEnab(bottom_right)={0.52,0.74}
	ModifyGraph axisEnab(Y_right2)={0.56,0.82}
	ModifyGraph axisEnab(Y_right3)={0.28,0.54}
	ModifyGraph axisEnab(Y_right4)={0,0.26}
	ModifyGraph axisEnab(Y_farright1)={0.85,1}
	ModifyGraph axisEnab(bottom_farright)={0.78,1}
	ModifyGraph axisEnab(Y_farright2)={0.56,0.82}
	ModifyGraph axisEnab(Y_farright3)={0.28,0.54}
	ModifyGraph axisEnab(Y_farright4)={0,0.26}
	Label Y_1 "\\Z04mV"
	Label bottom_left "\\Z05ms"
	Label Y_2 "\\Z04mV"
	Label Y_3 "\\Z04mV"
	Label Y_4 " \\Z04mV"
	Label Y_mid3 " "
	Label Y_mid2 " "
	Label Y_mid1 " "
	Label Y_mid4 " "
	Label Y_right1 " "
	Label bottom_right "\\Z05ms"
	Label Y_right2 "  "
	Label Y_right3 " "
	Label Y_right4 " "
	Label Y_farright1 " "
	Label Y_farright2 " "
	Label Y_farright3 " "
	Label Y_farright4 " "
	TextBox/N=text0/A=MC/X=13.65/Y=50.89 "\\Z06CC2 --> 0,1,3"
	TextBox/N=text1/A=MC/X=-39.21/Y=50.64 "\\Z06CC0 --> 1,2,3"
	TextBox/N=text2/A=MC/X=-13.81/Y=50.89 "\\Z06CC1 --> 0,2,3"
	TextBox/N=text3/A=MC/X=40.15/Y=51.40 "\\Z06CC3 --> 0,1,2"
EndMacro

Window SINGLEAVE_0123() : Graph
	DoWindow SINGLEAVE_0123
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K SINGLEAVE_0123
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(-1.2,319.4,403.2,567.8)/L=Y_1/B=bottom_left adc0_avg_0 as "SINGLEAVE_0123"
	AppendToGraph/L=Y_2/B=bottom_left adc1_avg_0
	AppendToGraph/L=Y_3/B=bottom_left adc2_avg_0
	AppendToGraph/L=Y_4/B=bottom_left adc3_avg_0
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1_avg_0)=(0,43520,65280),rgb(adc2_avg_0)=(32768,65280,0),rgb(adc3_avg_0)=(0,0,0)
	ModifyGraph fSize=5
	ModifyGraph standoff=0
	ModifyGraph lblPos(Y_1)=15,lblPos(bottom_left)=18,lblPos(Y_2)=15,lblPos(Y_3)=15
	ModifyGraph lblPos(Y_4)=15
	ModifyGraph ZisZ(Y_1)=1,ZisZ(Y_2)=1,ZisZ(Y_3)=1,ZisZ(Y_4)=1
	ModifyGraph zapTZ(Y_1)=1,zapTZ(Y_2)=1,zapTZ(Y_3)=1,zapTZ(Y_4)=1
	ModifyGraph zapLZ(Y_1)=1,zapLZ(Y_2)=1,zapLZ(Y_3)=1,zapLZ(Y_4)=1
	ModifyGraph tickUnit=1
	ModifyGraph btLen=3
	ModifyGraph freePos(Y_1)={0,bottom_left}
	ModifyGraph freePos(bottom_left)={0,Y_1}
	ModifyGraph freePos(Y_2)={0,bottom_left}
	ModifyGraph freePos(Y_3)={0,bottom_left}
	ModifyGraph freePos(Y_4)={0,bottom_left}
	ModifyGraph axisEnab(Y_1)={0.77,1}
	ModifyGraph axisEnab(Y_2)={0.52,0.75}
	ModifyGraph axisEnab(Y_3)={0.27,0.5}
	ModifyGraph axisEnab(Y_4)={0.02,0.25}
	Label Y_1 "\\Z04mV"
	Label bottom_left "\\Z05ms"
	Label Y_2 "\\Z04mV"
	Label Y_3 "\\Z04mV"
	Label Y_4 " \\Z04mV"
EndMacro

Window SINGLE_0123() : Graph
	DoWindow SINGLE_0123
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K SINGLE_0123
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(-1.2,319.4,403.2,567.8)/L=Y_1/B=bottom_left adc0 as "SINGLE_0123"
	AppendToGraph/L=Y_2/B=bottom_left adc1
	AppendToGraph/L=Y_3/B=bottom_left adc2
	AppendToGraph/L=Y_4/B=bottom_left adc3
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1)=(0,43520,65280),rgb(adc2)=(32768,65280,0),rgb(adc3)=(0,0,0)
	ModifyGraph fSize=5
	ModifyGraph standoff=0
	ModifyGraph lblPos(Y_1)=15,lblPos(bottom_left)=18,lblPos(Y_2)=15,lblPos(Y_3)=15
	ModifyGraph lblPos(Y_4)=15
	ModifyGraph ZisZ(Y_1)=1,ZisZ(Y_2)=1,ZisZ(Y_3)=1,ZisZ(Y_4)=1
	ModifyGraph zapTZ(Y_1)=1,zapTZ(Y_2)=1,zapTZ(Y_3)=1,zapTZ(Y_4)=1
	ModifyGraph zapLZ(Y_1)=1,zapLZ(Y_2)=1,zapLZ(Y_3)=1,zapLZ(Y_4)=1
	ModifyGraph tickUnit=1
	ModifyGraph btLen=3
	ModifyGraph freePos(Y_1)={0,bottom_left}
	ModifyGraph freePos(bottom_left)={0,Y_1}
	ModifyGraph freePos(Y_2)={0,bottom_left}
	ModifyGraph freePos(Y_3)={0,bottom_left}
	ModifyGraph freePos(Y_4)={0,bottom_left}
	ModifyGraph axisEnab(Y_1)={0.77,1}
	ModifyGraph axisEnab(Y_2)={0.52,0.75}
	ModifyGraph axisEnab(Y_3)={0.27,0.5}
	ModifyGraph axisEnab(Y_4)={0.02,0.25}
	Label Y_1 "\\Z04mV"
	Label bottom_left "\\Z05ms"
	Label Y_2 "\\Z04mV"
	Label Y_3 "\\Z04mV"
	Label Y_4 " \\Z04mV"
EndMacro

Window CC_0123_allspikes() : Graph
	DoWindow CC_0123_allspikes
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K CC_0123_allspikes
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(1.2,221.6,745.8,564.2)/R=Y_2_R/B=bottom_left adc0_avg_0 as "CC_0123_allspikes"
	AppendToGraph/L=Y_farright1/B=bottom_farright adc3_avg_3
	AppendToGraph/R=Y_farright3_R/B=bottom_farright adc3_avg_3
	AppendToGraph/R=Y_farright4_R/B=bottom_farright adc3_avg_3
	AppendToGraph/L=Y_1/B=bottom_left adc0_avg_0
	AppendToGraph/R=Y_3_R/B=bottom_left adc0_avg_0
	AppendToGraph/R=Y_4_R/B=bottom_left adc0_avg_0
	AppendToGraph/R=Y_mid3_R/B=bottom_middle adc1_avg_1
	AppendToGraph/R=Y_mid2_R/B=bottom_middle adc1_avg_1
	AppendToGraph/L=Y_mid1/B=bottom_middle adc1_avg_1
	AppendToGraph/R=Y_mid4_R/B=bottom_middle adc1_avg_1
	AppendToGraph/L=Y_2/B=bottom_left adc1_avg_0
	AppendToGraph/L=Y_3/B=bottom_left adc2_avg_0
	AppendToGraph/L=Y_4/B=bottom_left adc3_avg_0
	AppendToGraph/L=Y_mid3/B=bottom_middle adc2_avg_1
	AppendToGraph/L=Y_mid2/B=bottom_middle adc0_avg_1
	AppendToGraph/L=Y_mid4/B=bottom_middle adc3_avg_1
	AppendToGraph/L=Y_right1/B=bottom_right adc2_avg_2
	AppendToGraph/R=Y_right2_R/B=bottom_right adc2_avg_2
	AppendToGraph/R=Y_right3_R/B=bottom_right adc2_avg_2
	AppendToGraph/R=Y_right4_R/B=bottom_right adc2_avg_2
	AppendToGraph/L=Y_right2/B=bottom_right adc0_avg_2
	AppendToGraph/R=Y_farright2_R/B=bottom_farright adc3_avg_3
	AppendToGraph/L=Y_right3/B=bottom_right adc1_avg_2
	AppendToGraph/L=Y_right4/B=bottom_right adc3_avg_2
	AppendToGraph/L=Y_farright2/B=bottom_farright adc0_avg_3
	AppendToGraph/L=Y_farright3/B=bottom_farright adc1_avg_3
	AppendToGraph/L=Y_farright4/B=bottom_farright adc2_avg_3
	ModifyGraph lSize(adc0_avg_0)=0.25,lSize(adc3_avg_3)=0.9,lSize(adc3_avg_3#1)=0.25
	ModifyGraph lSize(adc3_avg_3#2)=0.25,lSize(adc0_avg_0#1)=0.5,lSize(adc0_avg_0#2)=0.25
	ModifyGraph lSize(adc0_avg_0#3)=0.25,lSize(adc1_avg_1)=0.25,lSize(adc1_avg_1#1)=0.25
	ModifyGraph lSize(adc1_avg_1#2)=0.9,lSize(adc1_avg_1#3)=0.25,lSize(adc1_avg_0)=0.9
	ModifyGraph lSize(adc2_avg_0)=0.9,lSize(adc3_avg_0)=0.9,lSize(adc2_avg_1)=0.9,lSize(adc0_avg_1)=0.9
	ModifyGraph lSize(adc3_avg_1)=0.9,lSize(adc2_avg_2)=0.9,lSize(adc2_avg_2#1)=0.25
	ModifyGraph lSize(adc2_avg_2#2)=0.25,lSize(adc2_avg_2#3)=0.25,lSize(adc0_avg_2)=0.9
	ModifyGraph lSize(adc3_avg_3#3)=0.25,lSize(adc1_avg_2)=0.9,lSize(adc3_avg_2)=0.9
	ModifyGraph lSize(adc0_avg_3)=0.9,lSize(adc1_avg_3)=0.9,lSize(adc2_avg_3)=0.9
	ModifyGraph rgb(adc3_avg_3)=(0,0,0),rgb(adc3_avg_3#1)=(0,0,0),rgb(adc3_avg_3#2)=(0,0,0)
	ModifyGraph rgb(adc1_avg_1)=(0,43520,65280),rgb(adc1_avg_1#1)=(0,43520,65280),rgb(adc1_avg_1#2)=(0,43520,65280)
	ModifyGraph rgb(adc1_avg_1#3)=(0,43520,65280),rgb(adc1_avg_0)=(0,43520,65280),rgb(adc2_avg_0)=(32768,65280,0)
	ModifyGraph rgb(adc3_avg_0)=(0,0,0),rgb(adc2_avg_1)=(32768,65280,0),rgb(adc3_avg_1)=(0,0,0)
	ModifyGraph rgb(adc2_avg_2)=(32768,65280,0),rgb(adc2_avg_2#1)=(0,65280,0),rgb(adc2_avg_2#2)=(0,65280,0)
	ModifyGraph rgb(adc2_avg_2#3)=(0,65280,0),rgb(adc3_avg_3#3)=(0,0,0),rgb(adc1_avg_2)=(0,43520,65280)
	ModifyGraph rgb(adc3_avg_2)=(0,0,0),rgb(adc1_avg_3)=(0,43520,65280),rgb(adc2_avg_3)=(0,65280,0)
	ModifyGraph fSize=5
	ModifyGraph standoff=0
	ModifyGraph axRGB(Y_2_R)=(65535,65535,65535),axRGB(Y_3_R)=(65535,65535,65535),axRGB(Y_4_R)=(65535,65535,65535)
	ModifyGraph axRGB(Y_mid2_R)=(65535,65535,65535),axRGB(Y_mid3_R)=(65535,65535,65535)
	ModifyGraph axRGB(Y_mid4_R)=(65535,65535,65535),axRGB(Y_right2_R)=(65535,65535,65535)
	ModifyGraph axRGB(Y_right3_R)=(65535,65535,65535),axRGB(Y_right4_R)=(65535,65535,65535)
	ModifyGraph axRGB(Y_farright2_R)=(65535,65535,65535),axRGB(Y_farright3_R)=(65535,65535,65535)
	ModifyGraph axRGB(Y_farright4_R)=(65535,65535,65535)
	ModifyGraph tlblRGB(Y_2_R)=(65535,65535,65535),tlblRGB(Y_3_R)=(65535,65535,65535)
	ModifyGraph tlblRGB(Y_4_R)=(65535,65535,65535),tlblRGB(Y_mid2_R)=(65535,65535,65535)
	ModifyGraph tlblRGB(Y_mid3_R)=(65535,65535,65535),tlblRGB(Y_mid4_R)=(65535,65535,65535)
	ModifyGraph tlblRGB(Y_right2_R)=(65535,65535,65535),tlblRGB(Y_right3_R)=(65535,65535,65535)
	ModifyGraph tlblRGB(Y_right4_R)=(65535,65535,65535),tlblRGB(Y_farright2_R)=(65535,65535,65535)
	ModifyGraph tlblRGB(Y_farright3_R)=(65535,65535,65535),tlblRGB(Y_farright4_R)=(65535,65535,65535)
	ModifyGraph alblRGB(Y_2_R)=(65535,65535,65535),alblRGB(Y_3_R)=(65535,65535,65535)
	ModifyGraph alblRGB(Y_4_R)=(65535,65535,65535),alblRGB(Y_mid2_R)=(65535,65535,65535)
	ModifyGraph alblRGB(Y_mid3_R)=(65535,65535,65535),alblRGB(Y_mid4_R)=(65535,65535,65535)
	ModifyGraph alblRGB(Y_right2_R)=(65535,65535,65535),alblRGB(Y_right3_R)=(65535,65535,65535)
	ModifyGraph alblRGB(Y_right4_R)=(65535,65535,65535),alblRGB(Y_farright2_R)=(65535,65535,65535)
	ModifyGraph alblRGB(Y_farright3_R)=(65535,65535,65535),alblRGB(Y_farright4_R)=(65535,65535,65535)
	ModifyGraph lblPos(Y_1)=15,lblPos(bottom_left)=18,lblPos(Y_2)=15,lblPos(Y_3)=15
	ModifyGraph lblPos(Y_4)=15,lblPos(bottom_middle)=18,lblPos(bottom_right)=18,lblPos(bottom_farright)=18
	ModifyGraph ZisZ(Y_1)=1,ZisZ(Y_2)=1,ZisZ(Y_3)=1,ZisZ(Y_4)=1,ZisZ(Y_mid3)=1,ZisZ(Y_mid2)=1
	ModifyGraph ZisZ(Y_mid1)=1,ZisZ(Y_mid4)=1,ZisZ(Y_right1)=1,ZisZ(bottom_right)=1
	ModifyGraph ZisZ(Y_right2)=1,ZisZ(Y_right3)=1,ZisZ(Y_right4)=1,ZisZ(Y_farright1)=1
	ModifyGraph ZisZ(bottom_farright)=1,ZisZ(Y_farright2)=1,ZisZ(Y_farright3)=1,ZisZ(Y_farright4)=1
	ModifyGraph zapTZ(Y_1)=1,zapTZ(Y_2)=1,zapTZ(Y_3)=1,zapTZ(Y_4)=1,zapTZ(Y_mid3)=1
	ModifyGraph zapTZ(Y_mid2)=1,zapTZ(Y_mid1)=1,zapTZ(Y_mid4)=1,zapTZ(Y_right1)=1,zapTZ(bottom_right)=1
	ModifyGraph zapTZ(Y_right2)=1,zapTZ(Y_right3)=1,zapTZ(Y_right4)=1,zapTZ(Y_farright1)=1
	ModifyGraph zapTZ(bottom_farright)=1,zapTZ(Y_farright2)=1,zapTZ(Y_farright3)=1,zapTZ(Y_farright4)=1
	ModifyGraph zapLZ(Y_1)=1,zapLZ(Y_2)=1,zapLZ(Y_3)=1,zapLZ(Y_4)=1,zapLZ(Y_mid3)=1
	ModifyGraph zapLZ(Y_mid2)=1,zapLZ(Y_mid1)=1,zapLZ(Y_mid4)=1,zapLZ(Y_right1)=1,zapLZ(bottom_right)=1
	ModifyGraph zapLZ(Y_right2)=1,zapLZ(Y_right3)=1,zapLZ(Y_right4)=1,zapLZ(Y_farright1)=1
	ModifyGraph zapLZ(bottom_farright)=1,zapLZ(Y_farright2)=1,zapLZ(Y_farright3)=1,zapLZ(Y_farright4)=1
	ModifyGraph tickUnit(Y_1)=1,tickUnit(bottom_left)=1,tickUnit(Y_2)=1,tickUnit(Y_3)=1
	ModifyGraph tickUnit(Y_4)=1,tickUnit(Y_mid3)=1,tickUnit(bottom_middle)=1,tickUnit(Y_mid2)=1
	ModifyGraph tickUnit(Y_mid1)=1,tickUnit(Y_mid4)=1,tickUnit(Y_right1)=1,tickUnit(bottom_right)=1
	ModifyGraph tickUnit(Y_right2)=1,tickUnit(Y_right3)=1,tickUnit(Y_right4)=1,tickUnit(Y_farright1)=1
	ModifyGraph tickUnit(bottom_farright)=1,tickUnit(Y_farright2)=1,tickUnit(Y_farright3)=1
	ModifyGraph tickUnit(Y_farright4)=1
	ModifyGraph btLen(Y_1)=3,btLen(bottom_left)=3,btLen(Y_2)=3,btLen(Y_3)=3,btLen(Y_4)=3
	ModifyGraph btLen(Y_mid3)=3,btLen(bottom_middle)=3,btLen(Y_mid2)=3,btLen(Y_mid1)=3
	ModifyGraph btLen(Y_mid4)=3,btLen(Y_right1)=3,btLen(bottom_right)=3,btLen(Y_right2)=3
	ModifyGraph btLen(Y_right3)=3,btLen(Y_right4)=3,btLen(Y_farright1)=3,btLen(bottom_farright)=3
	ModifyGraph btLen(Y_farright2)=3,btLen(Y_farright3)=3,btLen(Y_farright4)=3,btLen(Y_2_R)=3
	ModifyGraph btLen(Y_3_R)=3,btLen(Y_4_R)=3,btLen(Y_mid2_R)=3,btLen(Y_mid3_R)=3,btLen(Y_mid4_R)=3
	ModifyGraph btLen(Y_right2_R)=3,btLen(Y_right3_R)=3,btLen(Y_right4_R)=3,btLen(Y_farright2_R)=5
	ModifyGraph btLen(Y_farright3_R)=3,btLen(Y_farright4_R)=3
	ModifyGraph freePos(Y_1)={0,bottom_left}
	ModifyGraph freePos(bottom_left)={0,Y_1}
	ModifyGraph freePos(Y_2)={0,bottom_left}
	ModifyGraph freePos(Y_3)={0,bottom_left}
	ModifyGraph freePos(Y_4)={0,bottom_left}
	ModifyGraph freePos(Y_mid3)={0,bottom_middle}
	ModifyGraph freePos(bottom_middle)={0,Y_mid1}
	ModifyGraph freePos(Y_mid2)={0,bottom_middle}
	ModifyGraph freePos(Y_mid1)={0,bottom_middle}
	ModifyGraph freePos(Y_mid4)={0,bottom_middle}
	ModifyGraph freePos(Y_right1)={0,bottom_right}
	ModifyGraph freePos(bottom_right)={0,Y_right1}
	ModifyGraph freePos(Y_right2)={0,bottom_right}
	ModifyGraph freePos(Y_right3)={0,bottom_right}
	ModifyGraph freePos(Y_right4)={0,bottom_right}
	ModifyGraph freePos(Y_farright1)={0,bottom_farright}
	ModifyGraph freePos(bottom_farright)={0,Y_1}
	ModifyGraph freePos(Y_farright2)={0,bottom_farright}
	ModifyGraph freePos(Y_farright3)={0,bottom_farright}
	ModifyGraph freePos(Y_farright4)={0,bottom_farright}
	ModifyGraph freePos(Y_2_R)={0.78,kwFraction}
	ModifyGraph freePos(Y_3_R)={0.78,kwFraction}
	ModifyGraph freePos(Y_4_R)={0.78,kwFraction}
	ModifyGraph freePos(Y_mid2_R)={0.52,kwFraction}
	ModifyGraph freePos(Y_mid3_R)={0.52,kwFraction}
	ModifyGraph freePos(Y_mid4_R)={0.52,kwFraction}
	ModifyGraph freePos(Y_right2_R)={0.26,kwFraction}
	ModifyGraph freePos(Y_right3_R)={0.26,kwFraction}
	ModifyGraph freePos(Y_right4_R)={0.26,kwFraction}
	ModifyGraph freePos(Y_farright2_R)={0,kwFraction}
	ModifyGraph freePos(Y_farright3_R)={0,kwFraction}
	ModifyGraph freePos(Y_farright4_R)={0,kwFraction}
	ModifyGraph tickEnab(Y_2_R)={1000,inf}
	ModifyGraph tickEnab(Y_3_R)={1000,inf}
	ModifyGraph tickEnab(Y_4_R)={1000,inf}
	ModifyGraph tickEnab(Y_mid2_R)={1000,inf}
	ModifyGraph tickEnab(Y_mid3_R)={1000,inf}
	ModifyGraph tickEnab(Y_mid4_R)={1000,inf}
	ModifyGraph tickEnab(Y_right2_R)={1000,inf}
	ModifyGraph tickEnab(Y_right3_R)={1000,inf}
	ModifyGraph tickEnab(Y_right4_R)={1000,inf}
	ModifyGraph tickEnab(Y_farright2_R)={1000,inf}
	ModifyGraph tickEnab(Y_farright3_R)={1000,inf}
	ModifyGraph tickEnab(Y_farright4_R)={1000,inf}
	ModifyGraph axisEnab(Y_1)={0.85,1}
	ModifyGraph axisEnab(bottom_left)={0,0.22}
	ModifyGraph axisEnab(Y_2)={0.56,0.82}
	ModifyGraph axisEnab(Y_3)={0.28,0.54}
	ModifyGraph axisEnab(Y_4)={0,0.26}
	ModifyGraph axisEnab(Y_mid3)={0.28,0.54}
	ModifyGraph axisEnab(bottom_middle)={0.26,0.48}
	ModifyGraph axisEnab(Y_mid2)={0.56,0.82}
	ModifyGraph axisEnab(Y_mid1)={0.85,1}
	ModifyGraph axisEnab(Y_mid4)={0,0.26}
	ModifyGraph axisEnab(Y_right1)={0.85,1}
	ModifyGraph axisEnab(bottom_right)={0.52,0.74}
	ModifyGraph axisEnab(Y_right2)={0.56,0.82}
	ModifyGraph axisEnab(Y_right3)={0.28,0.54}
	ModifyGraph axisEnab(Y_right4)={0,0.26}
	ModifyGraph axisEnab(Y_farright1)={0.85,1}
	ModifyGraph axisEnab(bottom_farright)={0.78,1}
	ModifyGraph axisEnab(Y_farright2)={0.56,0.82}
	ModifyGraph axisEnab(Y_farright3)={0.28,0.54}
	ModifyGraph axisEnab(Y_farright4)={0,0.26}
	ModifyGraph axisEnab(Y_2_R)={0.56,0.82}
	ModifyGraph axisEnab(Y_3_R)={0.28,0.54}
	ModifyGraph axisEnab(Y_4_R)={0,0.26}
	ModifyGraph axisEnab(Y_mid2_R)={0.56,0.82}
	ModifyGraph axisEnab(Y_mid3_R)={0.28,0.54}
	ModifyGraph axisEnab(Y_mid4_R)={0,0.26}
	ModifyGraph axisEnab(Y_right2_R)={0.56,0.84}
	ModifyGraph axisEnab(Y_right3_R)={0.28,0.54}
	ModifyGraph axisEnab(Y_right4_R)={0,0.26}
	ModifyGraph axisEnab(Y_farright2_R)={0.56,0.82}
	ModifyGraph axisEnab(Y_farright3_R)={0.28,0.54}
	ModifyGraph axisEnab(Y_farright4_R)={0,0.26}
	Label Y_1 "\\Z04mV"
	Label bottom_left "\\Z05ms"
	Label Y_2 "\\Z04mV"
	Label Y_3 "\\Z04mV"
	Label Y_4 " \\Z04mV"
	Label Y_mid3 " "
	Label Y_mid2 " "
	Label Y_mid1 " "
	Label Y_mid4 " "
	Label Y_right1 " "
	Label bottom_right "\\Z05ms"
	Label Y_right2 "  "
	Label Y_right3 " "
	Label Y_right4 " "
	Label Y_farright1 " "
	Label Y_farright2 " "
	Label Y_farright3 " "
	Label Y_farright4 " "
	TextBox/N=text0/A=MC/X=21.19/Y=51.09 "\\Z06CC2 --> 0,1,3"
	TextBox/N=text1/A=MC/X=-31.62/Y=50.00 "\\Z06CC0 --> 1,2,3"
	TextBox/N=text2/A=MC/X=-5.38/Y=50.18 "\\Z06CC1 --> 0,2,3"
	TextBox/N=text3/A=MC/X=47.43/Y=50.55 "\\Z06CC3 --> 0,1,2"
EndMacro


Window amp_points_wave_0_graph() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(771.75,344.75,1418.25,451.25) amp_points_wave_0
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph fSize=6
	ModifyGraph standoff(left)=0
	ModifyGraph axRGB(left)=(65280,0,0)
	ModifyGraph tlblRGB(left)=(65280,0,0)
	ModifyGraph alblRGB(left)=(65280,0,0)
	ModifyGraph lblPos(left)=51
	ModifyGraph zapTZ(left)=1
	ModifyGraph tickUnit(left)=1
	ModifyGraph btLen(left)=2
	SetAxis bottom 0,1000
EndMacro




//print mean(single_pulse_r_all,xcsr(A),xcsr(B))