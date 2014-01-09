#pragma rtGlobals=1		// Use modern global access method.
macro tri_spike_0()
	duplicate /o adc0_avg_0 spike_0
	duplicate /o adc1_avg_0 response_1to0
	duplicate /o adc2_avg_0 response_2to0
end macro

macro tri_spike_1()
	duplicate /o adc1_avg_0 spike_1
	duplicate /o adc0_avg_0 response_0to1
	duplicate /o adc2_avg_0 response_2to1
end macro 

macro tri_spike_2()
	duplicate /o adc2_avg_0 spike_2
	duplicate /o adc0_avg_0 response_0to2
	duplicate /o adc1_avg_0 response_1to2
end macro

Window zhou_tri() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(233.25,158,959.25,689)/L=ax_spike_0/B=bot_ax_spike_0 spike_0
	AppendToGraph/L=ax_res_1to0/B=bot_ax_spike_0 response_1to0
	AppendToGraph/L=ax_res_2to0/B=bot_ax_spike_0 response_2to0
	//AppendToGraph/L=ax_res_3to0/B=bot_ax_spike_0 response_3to0
	AppendToGraph/L=ax_spike_1/B=bot_ax_spike_1 spike_1
	AppendToGraph/L=ax_res_0to1/B=bot_ax_spike_1 response_0to1
	AppendToGraph/L=ax_res_2to1/B=bot_ax_spike_1 response_2to1
	//AppendToGraph/L=ax_res_3to1/B=bot_ax_spike_1 response_3to1
	AppendToGraph/L=ax_spike_2/B=bot_ax_spike_2 spike_2
	AppendToGraph/L=ax_res_0to2/B=bot_ax_spike_2 response_0to2
	AppendToGraph/L=ax_res_1to2/B=bot_ax_spike_2 response_1to2
	//AppendToGraph/L=ax_res_3to2/B=bot_ax_spike_2 response_3to2
	//AppendToGraph/L=ax_spike_3/B=bot_ax_spike_3 spike_3
	//AppendToGraph/L=ax_res_0to3/B=bot_ax_spike_3 response_0to3
	//AppendToGraph/L=ax_res_1to3/B=bot_ax_spike_3 response_1to3
	//AppendToGraph/L=ax_res_2to3/B=bot_ax_spike_3 response_2to3
	ModifyGraph rgb(response_1to0)=(32768,54528,65280),rgb(response_2to0)=(0,65280,0)
	//ModifyGraph rgb(response_3to0)=(0,0,0)
	ModifyGraph rgb(spike_1)=(32768,54528,65280),rgb(response_2to1)=(0,65280,0)
	//ModifyGraph rgb(response_3to1)=(0,0,0)
	ModifyGraph rgb(spike_2)=(0,65280,0),rgb(response_0to2)=(65280,0,0)
	ModifyGraph rgb(response_1to2)=(32768,54528,65280)
	//,rgb(response_3to2)=(0,0,0),rgb(spike_3)=(0,0,0)
	//ModifyGraph rgb(response_1to3)=(32768,54528,65280),rgb(response_2to3)=(0,65280,0)
	ModifyGraph fSize=6
	ModifyGraph standoff=0
	ModifyGraph lblPos(bot_ax_spike_0)=18,lblPos(ax_res_1to0)=14,lblPos(ax_res_2to0)=13
	//ModifyGraph lblPos(ax_res_3to0)=10
	ModifyGraph lblLatPos(bot_ax_spike_0)=-4,lblLatPos(ax_res_2to0)=-21//,lblLatPos(ax_res_3to0)=-2
	ModifyGraph tickUnit=1
	ModifyGraph btLen=4
	ModifyGraph freePos(ax_spike_0)={0,bot_ax_spike_0}
	ModifyGraph freePos(bot_ax_spike_0)=0
	ModifyGraph freePos(ax_res_1to0)={0,bot_ax_spike_0}
	ModifyGraph freePos(ax_res_2to0)={0,bot_ax_spike_0}
	//ModifyGraph freePos(ax_res_3to0)={0,bot_ax_spike_0}
	ModifyGraph freePos(ax_spike_1)={0,bot_ax_spike_1}
	ModifyGraph freePos(bot_ax_spike_1)=0
	ModifyGraph freePos(ax_res_0to1)={0,bot_ax_spike_1}
	ModifyGraph freePos(ax_res_2to1)={0,bot_ax_spike_1}
	//ModifyGraph freePos(ax_res_3to1)={0,bot_ax_spike_1}
	ModifyGraph freePos(ax_spike_2)={0,bot_ax_spike_2}
	ModifyGraph freePos(bot_ax_spike_2)=0
	ModifyGraph freePos(ax_res_0to2)={0,bot_ax_spike_2}
	ModifyGraph freePos(ax_res_1to2)={0,bot_ax_spike_2}
	//ModifyGraph freePos(ax_res_3to2)={0,bot_ax_spike_2}
	//ModifyGraph freePos(ax_spike_3)={0,bot_ax_spike_3}
	//ModifyGraph freePos(bot_ax_spike_3)=0
	//ModifyGraph freePos(ax_res_0to3)={0,bot_ax_spike_3}
	//ModifyGraph freePos(ax_res_1to3)={0,bot_ax_spike_3}
	//ModifyGraph freePos(ax_res_2to3)={0,bot_ax_spike_3}
	ModifyGraph axisEnab(ax_spike_0)={0.67,0.97}
	ModifyGraph axisEnab(bot_ax_spike_0)={0.01,0.31}
	ModifyGraph axisEnab(ax_res_1to0)={0.34,0.64}
	ModifyGraph axisEnab(ax_res_2to0)={0.01,0.31}
	//ModifyGraph axisEnab(ax_res_3to0)={0.01,0.24}
	ModifyGraph axisEnab(ax_spike_1)={0.67,0.97}
	ModifyGraph axisEnab(bot_ax_spike_1)={0.34,0.64}
	ModifyGraph axisEnab(ax_res_0to1)={0.34,0.64}
	ModifyGraph axisEnab(ax_res_2to1)={0.01,0.31}
	//ModifyGraph axisEnab(ax_res_3to1)={0.01,0.24}
	ModifyGraph axisEnab(ax_spike_2)={0.67,0.97}
	ModifyGraph axisEnab(bot_ax_spike_2)={0.67,0.97}
	ModifyGraph axisEnab(ax_res_0to2)={0.34,0.64}
	ModifyGraph axisEnab(ax_res_1to2)={0.01,0.31}
	//ModifyGraph axisEnab(ax_res_3to2)={0.01,0.34}
	//ModifyGraph axisEnab(ax_spike_3)={0.8,1}
	//ModifyGraph axisEnab(bot_ax_spike_3)={0.76,0.99}
	//ModifyGraph axisEnab(ax_res_0to3)={0.51,0.74}
	//ModifyGraph axisEnab(ax_res_1to3)={0.26,0.49}
	//ModifyGraph axisEnab(ax_res_2to3)={0.01,0.24}
	Label ax_spike_0 "\\Z06"
EndMacro