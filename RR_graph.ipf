#pragma rtGlobals=1		// Use modern global access method.

Window RR_four_graph() : Graph
	DoWindow allten_graph
	If (V_flag == 1)					// Set V_flag to 1 if Graph0 window exists.
		DoWindow /K allten_graph
	endif
	PauseUpdate; Silent 1		// building window...
	Display /W=(2.4,209,609.6,413)/L=Y_1/B=bottom_left adc0_avg_3 as "allten_graph"
	AppendToGraph/L=Y_mid1/B=bottom_middle adc0_avg_6
	AppendToGraph/L=Y_right1/B=bottom_right adc0_avg_7
	AppendToGraph/L=Y_farright1/B=bottom_farright adc0_avg_4
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc0_avg_3)=(65280,0,0)
	ModifyGraph rgb(adc0_avg_6)=(65280,0,0)
	ModifyGraph rgb(adc0_avg_7)=(65280,0,0)
	ModifyGraph rgb(adc0_avg_4)=(65280,0,0)
	ModifyGraph tick(Y_1)=2,tick(bottom_left)=2,tick(Y_mid1)=2,tick(bottom_middle)=2
	ModifyGraph tick(Y_right1)=2,tick(bottom_right)=2
	ModifyGraph tick(Y_farright1)=2,tick(bottom_farright)=2
	ModifyGraph fSize=5
	ModifyGraph standoff(Y_1)=0,standoff(bottom_left)=0
	ModifyGraph standoff(Y_mid1)=0,standoff(bottom_middle)=0
	ModifyGraph standoff(Y_right1)=0,standoff(bottom_right)=0
	ModifyGraph standoff(Y_farright1)=0,standoff(bottom_farright)=0
	ModifyGraph axThick=0.7
	ModifyGraph tlblRGB(Y_1)=(65280,0,0)
	ModifyGraph tlblRGB(Y_mid1)=(65280,0,0)
	ModifyGraph tlblRGB(Y_right1)=(65280,0,0)
	ModifyGraph tlblRGB(Y_farright1)=(65280,0,0)
	ModifyGraph alblRGB(Y_1)=(65280,0,0)
	ModifyGraph alblRGB(Y_mid1)=(65280,0,0)
	ModifyGraph alblRGB(Y_right1)=(65280,0,0)
	ModifyGraph alblRGB(Y_farright1)=(65280,0,0)
	ModifyGraph lblPos(Y_1)=15,lblPos(bottom_left)=18
	ModifyGraph lblPos(Y_mid1)=15,lblPos(bottom_middle)=18,lblPos(Y_right1)=15
	ModifyGraph lblPos(bottom_right)=18,lblPos(Y_farright1)=15,lblPos(bottom_farright)=18
	ModifyGraph ZisZ(Y_1)=1,ZisZ(Y_mid1)=1
	ModifyGraph ZisZ(Y_right1)=1,ZisZ(bottom_right)=1
	ModifyGraph ZisZ(Y_farright1)=1,ZisZ(bottom_farright)=1
	ModifyGraph zapTZ(Y_1)=1,zapTZ(Y_mid1)=1
	ModifyGraph zapTZ(Y_right1)=1,zapTZ(bottom_right)=1
	ModifyGraph zapTZ(Y_farright1)=1,zapTZ(bottom_farright)=1
	ModifyGraph zapLZ(Y_1)=1,zapLZ(Y_mid1)=1
	ModifyGraph zapLZ(Y_right1)=1,zapLZ(bottom_right)=1
	ModifyGraph zapLZ(Y_farright1)=1,zapLZ(bottom_farright)=1
	ModifyGraph tickUnit=1
	ModifyGraph btLen=1
	ModifyGraph freePos(Y_1)={0,bottom_left}
	ModifyGraph freePos(bottom_left)={0,Y_1}
	ModifyGraph freePos(Y_mid1)={0,bottom_middle}
	ModifyGraph freePos(bottom_middle)={0,Y_mid1}
	ModifyGraph freePos(Y_right1)={0,bottom_right}
	ModifyGraph freePos(bottom_right)={0,Y_right1}
	ModifyGraph freePos(Y_farright1)={0,bottom_farright}
	ModifyGraph freePos(bottom_farright)={0,Y_farright1}
	ModifyGraph axisEnab(Y_1)={0,1}
	ModifyGraph axisEnab(bottom_left)={0.00,0.220}
	ModifyGraph axisEnab(Y_mid1)={0,1}
	ModifyGraph axisEnab(bottom_middle)={0.260,0.480}
	ModifyGraph axisEnab(Y_right1)={0,1}
	ModifyGraph axisEnab(bottom_right)={0.520,0.740}
	ModifyGraph axisEnab(Y_farright1)={0,1}
	ModifyGraph axisEnab(bottom_farright)={0.780,1}
	Label Y_1 " "
	Label bottom_left " "
	Label Y_mid1 " "
	Label bottom_middle " "
	Label Y_right1 " "
	Label bottom_right " "
	Label Y_farright1 " "
	Label bottom_farright " "
EndMacro