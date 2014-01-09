#include <Axis Utilities>

// The SetAxisRange function examines the top graph and autoscales all traces.
// Unlike what Igor does automatically, this function takes into account the range
// of the associated horizontal axis.  That is, if you have set a range for the horizontal
// axis that is less than the full x range of the trace, when Igor autoscales the vertical
// axis it (he?) looks at all the data, not just data that fall within the given X range.
// This function scales the vertical axes only according to the data that fall within
// the given X range.

//Example:
//  Suppose you have a graph with a wave having a range in Y of -40 to 80, and an
//  X range of 0 to 100.  You make a graph, and Igor autoscales to show the data at
//  maximum possible size.  Now you set the range of the X axis to 50 to 80, Igor
//  still sets the range of the vertical axis to -40 to 80, even though some of the data
//  don't show.  Run SetAxisRange(), and the vertical axis is re-scaled to show the 
//  restricted range of data at maximum possible size.

//The function handles waveform data, XY data, multiple vertical axes, and multiple
//instances of the save wave in the graph.  It works only on the top graph.  
//IF YOU HAVE SOME OTHER GRAPH AT THE TOP, YOU RUN THE RISK OF TOTALLY SCREWING IT UP!

//USAGE:
//To use the procedure file, put it into the User Procedures folder in the Igor Pro folder.
//Add this line to the top of your Procedure window:
//#include "SetAxisRange"
//
//When you close the procedure window, the procedure is compiled and ready to go.
//You can execute the function on the command line by typing "SetAxisRange()" on the
//command line, or you can select "Set_Axis_Range" from the Macros menu.
//#include "SetAxisRange"
Menu "Macros"
	"Scale to visible data", set_vis()
end

function set_vis()
	String window_name
	window_name = WinName(0,1)
	printf "window name: %s\r", window_name
	scale_vis(window_name)
End

Function SetAxisRange()

	String WindowName
	String VAxes
	String ThisHAxis, ThisVAxis, TrialVAxis, ThisWave, ThisXWave
	String TrInfo
	
	Variable/C limits
	Variable MyVMin, MyVMax
	Variable XMin, XMax
	
	Variable i,j,k,kiters,n
	
	WindowName=WinName(0,1)
	if (strlen(WindowName) == 0)
		Abort "No graphs"
	endif
	
	DoWindow/F $WindowName
	
	VAxes=HVAxisList("",0)
	if (strlen(VAxes) == 0)
		Abort "No vertical axes in top graph"
	endif
	printf "vertical axis names: %s\r", VAxes
	i = 0
	do
		ThisVAxis=StringFromList(i,VAxes,";")
//print "ThisVAxis = \"", ThisVAxis, "\""
		if (strlen(ThisVAxis) == 0)
			break
		endif
		
		j=0
		MyVMin=NaN
		MyVMax=NaN
		do 
			ThisWave=WaveName("", j, 1)
//print "\tThisWave = \"", ThisWave, "\""
			if (strlen(ThisWave) == 0)
				break
			endif
			n=0
			do
				TrInfo=TraceInfo("", ThisWave, n)
				if (strlen(TrInfo) == 0)
					break
				endif
				TrialVAxis=StringByKey("YAXIS",TrInfo)
				if (cmpstr(TrialVAxis, ThisVAxis) == 0)
					ThisHAxis = StringByKey("XAXIS",TrInfo)
					GetAxis/Q $ThisHAxis
					XMin=V_min
					XMax=V_max
					ThisXWave=StringByKey("XWAVE",TrInfo)
//print "\t\tThisXWave = \"", ThisXWave, "\""
					if (strlen(ThisXWave) == 0)
						WaveStats/Q/R=(XMin,XMax) $ThisWave
						if (numtype(MyVMin) == 2)
							MyVMin=V_min
						else
							if (V_min < MyVMin)
								MyVMin=V_min
							endif
						endif
						if (numtype(MyVMax) == 2)
							MyVMax=V_max
						else
							if (V_max > MyVMax)
								MyVMax=V_max
							endif
						endif
					else
//print "\t\t\tDoing XY branch"
						k=0
						Wave xw=$ThisXWave
						Wave yw=$ThisWave
						kiters=numpnts(xw)
						do
							if ((xw[k] >= XMin) %& (xw[k] <= XMax))
								if (numtype(MyVMin) == 2)
									MyVMin=yw[k]
								else
									if (yw[k] < MyVMin)
										MyVMin=yw[k]
									endif
								endif
								if (numtype(MyVMax) == 2)
									MyVMax=yw[k]
								else
									if (yw[k] > MyVMax)
										MyVMax=yw[k]
									endif
								endif
							endif
	
							k += 1
						while(k < kiters)
					endif
				endif
				n += 1
			while (1)
		
			j += 1
		while (1)
		
		SetAxis $ThisVAxis,MyVMin,MyVMax
	
		i += 1
	while(1)
end

Function Scale_Vis(Window_Name)
	String Window_Name
	
	String VAxes
	String ThisHAxis, ThisVAxis, TrialVAxis, ThisWave, ThisXWave
	String TrInfo
	
	Variable/C limits
	Variable MyVMin, MyVMax
	Variable XMin, XMax
	
	Variable i,j,k,kiters,n
	
	
	
	DoWindow/F $Window_Name
	
	VAxes=HVAxisList("",0)
	if (strlen(VAxes) == 0)
		Abort "No vertical axes in top graph"
	endif
//	printf "vertical axis list: %s\r", VAxes
	i = 0
	do
		ThisVAxis=StringFromList(i,VAxes,";")
//print "ThisVAxis = \"", ThisVAxis, "\""
		if (strlen(ThisVAxis) == 0)
			break
		endif
		
		j=0
		MyVMin=NaN
		MyVMax=NaN
		do 
			ThisWave=WaveName("", j, 1)
//print "\tThisWave = \"", ThisWave, "\""
			if (strlen(ThisWave) == 0)
				break
			endif
			n=0
			do
				TrInfo=TraceInfo("", ThisWave, n)
				if (strlen(TrInfo) == 0)
					break
				endif
				TrialVAxis=StringByKey("YAXIS",TrInfo)
				if (cmpstr(TrialVAxis, ThisVAxis) == 0)
					ThisHAxis = StringByKey("XAXIS",TrInfo)
					GetAxis/Q $ThisHAxis
					XMin=V_min
					XMax=V_max
					ThisXWave=StringByKey("XWAVE",TrInfo)
//print "\t\tThisXWave = \"", ThisXWave, "\""
					if (strlen(ThisXWave) == 0)
						WaveStats/Q/R=(XMin,XMax) $ThisWave
						if (numtype(MyVMin) == 2)
							MyVMin=V_min
						else
							if (V_min < MyVMin)
								MyVMin=V_min
							endif
						endif
						if (numtype(MyVMax) == 2)
							MyVMax=V_max
						else
							if (V_max > MyVMax)
								MyVMax=V_max
							endif
						endif
					else
//print "\t\t\tDoing XY branch"
						k=0
						Wave xw=$ThisXWave
						Wave yw=$ThisWave
						kiters=numpnts(xw)
						do
							if ((xw[k] >= XMin) %& (xw[k] <= XMax))
								if (numtype(MyVMin) == 2)
									MyVMin=yw[k]
								else
									if (yw[k] < MyVMin)
										MyVMin=yw[k]
									endif
								endif
								if (numtype(MyVMax) == 2)
									MyVMax=yw[k]
								else
									if (yw[k] > MyVMax)
										MyVMax=yw[k]
									endif
								endif
							endif
	
							k += 1
						while(k < kiters)
					endif
				endif
				n += 1
			while (1)
		
			j += 1
		while (1)
//		printf "mymin: %.4f, Mymax: %.6f\r", MyVMin, MyVMax
		
		SetAxis $ThisVAxis,MyVMin,MyVMax
	
		i += 1
	while(1)
end

function two_pro_chan_0_1()
	PauseUpdate; Silent 1		// building window...
	WAVE adc0_avg_0, adc1_avg_0, adc0_avg_1, adc1_avg_1
	DoWindow /K two_pro_chan_0_1_display_0
	Display /W=(1.2,239.6,191.4,413) adc0_avg_0
	DoWindow /C two_pro_chan_0_1_display_0
	AppendToGraph/R adc1_avg_0
	ModifyGraph margin(left)=22,margin(right)=22
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1_avg_0)=(0,43520,65280)
	ModifyGraph tick(left)=2,tick(right)=2
	ModifyGraph font(left)="Arial",font(right)="Arial"
	ModifyGraph fSize(left)=8,fSize(right)=8
	ModifyGraph axOffset(left)=4.14286,axOffset(right)=4.66667
	ModifyGraph tlblRGB(left)=(65280,0,0),tlblRGB(right)=(0,43520,65280)
	ModifyGraph lblPos(left)=44
	ModifyGraph btLen(left)=1,btLen(right)=1
	ModifyGraph btThick(left)=1,btThick(right)=1
	ModifyGraph stLen(left)=0.5,stLen(right)=0.5
	ModifyGraph stThick(left)=1,stThick(right)=1
	Label left "\\u#2"
	Label right "\\u#2"
	DoWindow /K two_pro_chan_0_1_display_1
	Display /W=(196.2,239,400.8,412.4) adc0_avg_1
	DoWindow /C two_pro_chan_0_1_display_1
	AppendToGraph/R adc1_avg_1
	ModifyGraph margin(left)=22,margin(right)=22
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1_avg_1)=(0,43520,65280)
	ModifyGraph tick(left)=2,tick(right)=2
	ModifyGraph font(left)="Arial",font(right)="Arial"
	ModifyGraph fSize(left)=8,fSize(right)=8
	ModifyGraph axOffset(left)=4.14286,axOffset(right)=4.66667
	ModifyGraph tlblRGB(left)=(65280,0,0),tlblRGB(right)=(0,43520,65280)
	ModifyGraph lblPos(left)=44
	ModifyGraph btLen(left)=1,btLen(right)=1
	ModifyGraph btThick(left)=1,btThick(right)=1
	ModifyGraph stLen(left)=0.5,stLen(right)=0.5
	ModifyGraph stThick(left)=1,stThick(right)=1
	Label left "\\u#2"
	Label right "\\u#2"
End


function three_pro_chan_0_1_plot() 
	WAVE adc0_avg_0, adc0_avg_1, adc0_avg_2
	WAVE adc1_avg_0, adc1_avg_1, adc1_avg_2	
	PauseUpdate; Silent 1		// building window...
	DoWindow /K three_pro_chan_0_1_display// kill old window 
	Display /W=(3,229.4,394.8,415.4) adc0_avg_0
	DoWindow /C three_pro_chan_0_1_display // name the new window
	AppendToGraph/L=L1 adc1_avg_0
	AppendToGraph/L=L2/B=B1 adc0_avg_1
	AppendToGraph/L=L3/B=B1 adc1_avg_1
	AppendToGraph/L=L4/B=B3 adc0_avg_2
	AppendToGraph/L=L5/B=B3 adc1_avg_2
	ModifyGraph margin(left)=22,margin(bottom)=22,margin(top)=7,margin(right)=7
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc1_avg_0)=(0,34816,52224),rgb(adc1_avg_1)=(0,43520,65280),rgb(adc1_avg_2)=(0,43520,65280)
	ModifyGraph fSize=8
	ModifyGraph lblPos(left)=47,lblPos(bottom)=21
	ModifyGraph ZisZ(left)=1,ZisZ(L1)=1,ZisZ(L2)=1,ZisZ(L3)=1,ZisZ(L4)=1,ZisZ(L5)=1
	ModifyGraph zapTZ(left)=1,zapTZ(L1)=1,zapTZ(L2)=1,zapTZ(L3)=1,zapTZ(L4)=1
	ModifyGraph freePos(L1)=0
	ModifyGraph freePos(L2)={0.33,kwFraction}
	ModifyGraph freePos(B1)=0
	ModifyGraph freePos(L3)={0.33,kwFraction}
	ModifyGraph freePos(L4)={0.7,kwFraction}
	ModifyGraph freePos(B3)=0
	ModifyGraph freePos(L5)={0.7,kwFraction}
	ModifyGraph axisEnab(left)={0,0.45}
	ModifyGraph axisEnab(bottom)={0,0.3}
	ModifyGraph axisEnab(L1)={0.55,1}
	ModifyGraph axisEnab(L2)={0,0.45}
	ModifyGraph axisEnab(B1)={0.33,0.63}
	ModifyGraph axisEnab(L3)={0.55,1}
	ModifyGraph axisEnab(L4)={0,0.45}
	ModifyGraph axisEnab(B3)={0.7,1}
	ModifyGraph axisEnab(L5)={0.55,1}
	Label left "\\u#2"
	Label bottom "\\u#2"
	Label L1 "\\u#2"
	Label L2 "\\u#2"
	Label B1 "\\u#2"
	Label L3 "\\u#2"
	Label L4 "\\u#2"
	Label B3 "\\u#2"
	Label L5 "\\u#2"	
End


function adc2_avg_01_plot()

	WAVE adc2_avg_0, adc2_avg_1

	PauseUpdate; Silent 1		// building window...
	DoWindow /K adc2_avg_01_display// kill old window 
	Display /W=(0,227,399.6,411.2)/L=left2 adc2_avg_0
	DoWindow /C adc2_avg_01_display
	AppendToGraph/R adc2_avg_1
	ModifyGraph margin(left)=22
	ModifyGraph lSize=0.9
	ModifyGraph rgb(adc2_avg_0)=(0,52224,0),rgb(adc2_avg_1)=(0,0,0)
	ModifyGraph tick(left2)=2
	ModifyGraph font(left2)="Arial"
	ModifyGraph fSize(left2)=8
	ModifyGraph axOffset(left2)=-10
	ModifyGraph tlblRGB(left2)=(0,52224,0)
	ModifyGraph lblPos(left2)=-6
	ModifyGraph lblLatPos(left2)=-1
	ModifyGraph btLen(left2)=1
	ModifyGraph btThick(left2)=1
	ModifyGraph stLen(left2)=0.5
	ModifyGraph stThick(left2)=1
	ModifyGraph freePos(left2)=5
	Label left2 "\\u#2"
End

function Plot_Points_0_1()
	PauseUpdate; Silent 1		// building window...
	WAVE amp_points_wave_0, amp_points_wave_1
	DoWindow /K Points_0_1_Display
	Display /W=(3,227,396.6,411.2) amp_points_wave_0 as "Analysis 0 & 1"
	AppendToGraph/R amp_points_wave_1
	DoWindow /C Points_0_1_Display
	ModifyGraph gFont="Arial",gfSize=6
	ModifyGraph mode=4
	ModifyGraph marker(amp_points_wave_0)=8,marker(amp_points_wave_1)=5
	ModifyGraph rgb(amp_points_wave_1)=(0,0,0)
	ModifyGraph axRGB(left)=(65280,0,0)
	ModifyGraph tlblRGB(left)=(65280,0,0)
	ModifyGraph alblRGB(left)=(65280,0,0)
End


function plot_points_2()
	WAVE amp_points_wave_2
	PauseUpdate; Silent 1		// building window...
	DoWindow /K points_2_display // kill old window 
	Display /W=(410.4,309.8,615,426.8) amp_points_wave_2 as "Analysis 2"
	DoWindow /C points_2_display
	ModifyGraph gfSize=6
	ModifyGraph axOffset(left)=-2.66667,axOffset(bottom)=0.538462
	ModifyGraph mode=4
	ModifyGraph marker=8
//	SetAxis bottom 0,200
End

function plot_points_0()
	WAVE amp_points_wave_0
	PauseUpdate; Silent 1		// building window...
	DoWindow /K points_0_display // kill old window 
	Display /W=(410.4,309.8,615,426.8) amp_points_wave_0 as "Analysis 0"
	DoWindow /C points_0_display
	ModifyGraph gfSize=6
	ModifyGraph axOffset(left)=-2.66667,axOffset(bottom)=0.538462
	ModifyGraph mode=4
	ModifyGraph marker=8
//	SetAxis bottom 0,200
End

function plot_points_1()
	WAVE amp_points_wave_1
	PauseUpdate; Silent 1		// building window...
	DoWindow /K points_1_display // kill old window 
	Display /W=(410.4,309.8,615,426.8) amp_points_wave_1 as "Analysis 1"
	DoWindow /C points_1_display
	ModifyGraph gfSize=6
	ModifyGraph axOffset(left)=-2.66667,axOffset(bottom)=0.538462
	ModifyGraph mode=4
	ModifyGraph marker=8
//	SetAxis bottom 0,200
End


Menu "Plots"
		"adc2_avg_01_plot"
		"three_pro_chan_0_1_plot"
		"two_pro_chan_0_1"
		"Plot_points_0"
		"Plot_points_1"
		"Plot_points_2"
		"Plot_Points_0_1"
		"three_chan_0_1_2"
End

// cursors determine the trace and baseline
function zero_trace(flag, output_win_name)
	variable flag
	string output_win_name // for output
	variable /g index
	variable baseline
	string name
	if (flag == -1)
		index += 1 
	Else
		index = flag
	Endif
	Make /O wave_temp
	Duplicate /O $(CsrWave(a,WinName(0,1))) wave_temp
	Rename wave_temp, $(CsrWave(a,WinName(0,1)) + "_" + num2str(index))
	baseline = mean($(CsrWave(a,WinName(0,1)) + "_" + num2str(index)), xcsr(a), xcsr(b))
	wave_temp -= baseline
	AppendToGraph /W=$output_win_name $(CsrWave(a,WinName(0,1)) + "_" + num2str(index))
End

#pragma rtGlobals=1		// Use modern global access method.

function three_chan_0_1_2()
	DoWindow /K three_chan_avg
	Display /W=(0,233,399,413.6)/L=L3 adc0_avg_0 as "three_chan_avg"
	DoWindow /C three_chan_avg
	AppendToGraph/L=L2 adc1_avg_0
	AppendToGraph/L=L1 adc2_avg_0
	ModifyGraph rgb(adc1_avg_0)=(0,12800,52224),rgb(adc2_avg_0)=(0,52224,0)
	ModifyGraph fSize=6
	ModifyGraph standoff=0
	ModifyGraph tlblRGB(L3)=(65280,0,0),tlblRGB(L2)=(0,12800,52224),tlblRGB(L1)=(0,52224,0)
	ModifyGraph alblRGB(L3)=(65280,0,0),alblRGB(L2)=(0,12800,52224),alblRGB(L1)=(0,52224,0)
	ModifyGraph btLen=4
	ModifyGraph freePos(L3)=0
	ModifyGraph freePos(L2)=0
	ModifyGraph freePos(L1)=0
	ModifyGraph axisEnab(L3)={0.7,1}
	ModifyGraph axisEnab(L2)={0.35,0.65}
	ModifyGraph axisEnab(L1)={0,0.3}
End


function ChangeAxis(zoom,WindowName)
	variable zoom // if 1 expand if -1 shrink
	string WindowName
//	string list
	variable axis_max
	GetAxis /Q/W=$WindowName $"bottom"
	axis_max = V_max
//	list = tracenamelist(WindowName,";",1)
//	WAVE windowTrace = $StringFromList(0, list)	
//	WaveStats /Q windowTrace
	if (zoom == 1)
		SetAxis /W=$WindowName bottom 0, axis_max/2
	ElseIf (zoom == -1)	
		SetAxis /W=$WindowName bottom 0, axis_max*2
	EndIf
End