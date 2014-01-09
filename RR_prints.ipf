#pragma rtGlobals=1		// Use modern global access method.

Window RR0() : Graph			// 5 traces for vc_start, cc_step1,cc_step2,cc_sag, vc_end
	PauseUpdate; Silent 1		// building window...
	Display /W=(846.75,47,1359,553.25)/L=Y1/B=X1 vc_start
	AppendToGraph/L=Y2/B=X2 cc_step1
	AppendToGraph/L=Y3/B=X3 cc_step2
	AppendToGraph/L=Y4/B=X4 cc_sag
	AppendToGraph/L=Y5/B=X5 vc_end
	ModifyGraph nticks(Y1)=3,nticks(X1)=2,nticks(Y2)=3,nticks(X2)=2,nticks(Y3)=3,nticks(X3)=2
	ModifyGraph nticks(Y4)=3,nticks(X4)=2,nticks(Y5)=2,nticks(X5)=2
	ModifyGraph lblMargin(Y1)=15,lblMargin(Y2)=15,lblMargin(Y3)=15,lblMargin(Y4)=15
	ModifyGraph lblMargin(Y5)=15
	ModifyGraph standoff(Y1)=0,standoff(X1)=0,standoff(Y2)=0,standoff(X2)=0,standoff(X3)=0
	ModifyGraph standoff(X4)=0,standoff(Y5)=0,standoff(X5)=0
	ModifyGraph lblPosMode(Y1)=1,lblPosMode(Y2)=1,lblPosMode(Y3)=1,lblPosMode(Y4)=1
	ModifyGraph lblPos(Y1)=60,lblPos(X1)=35,lblPos(Y2)=50,lblPos(X2)=35,lblPos(X3)=35
	ModifyGraph lblPos(X4)=35,lblPos(Y5)=30,lblPos(X5)=35
	ModifyGraph btLen=4
	ModifyGraph freePos(Y1)={0,X1}
	ModifyGraph freePos(X1)={0.7,kwFraction}
	ModifyGraph freePos(Y2)={0,X2}
	ModifyGraph freePos(X2)={0.35,kwFraction}
	ModifyGraph freePos(Y3)={0,X3}
	ModifyGraph freePos(X3)={0.35,kwFraction}
	ModifyGraph freePos(Y4)={0,X4}
	ModifyGraph freePos(X4)={0,kwFraction}
	ModifyGraph freePos(Y5)={0,X5}
	ModifyGraph freePos(X5)={0,kwFraction}
	ModifyGraph axisEnab(Y1)={0.7,1}
	ModifyGraph axisEnab(X1)={0,0.45}
	ModifyGraph axisEnab(Y2)={0.35,0.65}
	ModifyGraph axisEnab(X2)={0,0.45}
	ModifyGraph axisEnab(Y3)={0.35,0.65}
	ModifyGraph axisEnab(X3)={0.55,1}
	ModifyGraph axisEnab(Y4)={0,0.3}
	ModifyGraph axisEnab(X4)={0,0.45}
	ModifyGraph axisEnab(Y5)={0,0.3}
	ModifyGraph axisEnab(X5)={0.55,1}
	TextBox/C/N=text0/A=LT/X=1.00/Y=1.00 "\\Z08vc_start"
	TextBox/C/N=text1/A=LT/X=1.00/Y=35.00 "\\Z08cc_step1"
	TextBox/C/N=text2/A=LT/X=55.50/Y=35.00 "\\Z08vc_step2"
	TextBox/C/N=text03/A=LT/X=1.00/Y=75.00 "\\Z08cc_sag"
	//TextBox/C/N=text3/A=LT/X=53.00/Y=0.00 "\\Z07\rRR072512A\rSOM pos cell\rleft claustrum\r25°C, 3mM KCl internal\r\rvc_start:\tRR072512Apt001tr0-21ave"
	//AppendText "cc_step1:\tRR072512Apt007tr2\t\t   0pA, HP-20pA\rcc_step2:\tRR072512Apt010tr1\t\t 200pA, HP-20pA\rcc_sag:\tRR072512Apt013tr0-16\t -30pA, HP-10pA"
	//AppendText "vc_end:\tRR072512Apt015tr10-82ave"
	TextBox/C/N=text3/A=LT/X=53.00/Y=0.00 "\\Z07\rMP_2013-10-22_c2\rsubplate cell\r\r25°C, 3mM KCl internal\r\rvc_start:\tMP_2013-10-22_c2.003 tr0-1017ave"
	AppendText "cc_step1:\tMP_2013-10-22_c2.124 tr2\t\t   150pA, HP 0pA\rcc_step2:\tMP_2013-10-22_c2.125 tr2\t\t   400pA, HP 0pA\rcc_sag:\tMP_2013-10-22_c2.121 tr0-5 ave\t\t-50pA, HP 0pA"
	AppendText "vc_end:\tMP_2013-10-16_c2.129 tr0-200 ave"
	TextBox/C/N=text4/A=LT/X=55.50/Y=75.00 "\\Z08vc_end"
	ModifyGraph fSize(Y1)=12
	ModifyGraph fSize(Y2)=12
	ModifyGraph fSize(X1)=12
	ModifyGraph fSize(X2)=12
	ModifyGraph fSize(Y3)=12
	ModifyGraph fSize(Y4)=12
	ModifyGraph fSize(X4)=12
	ModifyGraph fSize(X5)=12
	ModifyGraph fSize(Y5)=12
	ModifyGraph fSize=12
	TextBox/C/N=text2 "\\Z08cc_step2"
EndMacro

Window RR1() : Graph 			// LED stimul with 2 traces (led1 - led2)
	PauseUpdate; Silent 1		// building window...
	Display /W=(835.5,59.75,1347.75,566)/L=Y1/B=X1 led1
	AppendToGraph/L=Y2/B=X2 led2
	ModifyGraph nticks(Y1)=3,nticks(X1)=2,nticks(Y2)=3,nticks(X2)=2
	ModifyGraph lblMargin(Y1)=15,lblMargin(Y2)=15
	ModifyGraph standoff=0
	ModifyGraph lblPosMode(Y1)=1,lblPosMode(Y2)=1
	ModifyGraph lblPos(Y1)=60,lblPos(X1)=35,lblPos(Y2)=50,lblPos(X2)=35
	ModifyGraph btLen=4
	ModifyGraph freePos(Y1)={0,X1}
	ModifyGraph freePos(X1)={0.7,kwFraction}
	ModifyGraph freePos(Y2)={0,X2}
	ModifyGraph freePos(X2)={0.35,kwFraction}
	ModifyGraph axisEnab(Y1)={0.7,1}
	ModifyGraph axisEnab(X1)={0,0.45}
	ModifyGraph axisEnab(Y2)={0.35,0.65}
	ModifyGraph axisEnab(X2)={0,0.45}
	TextBox/C/N=text0/A=LT/X=40.00/Y=1.00 "\\Z08led1"
	TextBox/C/N=text1/A=LT/X=40.00/Y=35.00 "\\Z08led2"
	TextBox/C/N=text3/A=LT/X=53.00/Y=0.00 "\\Z08\rRR072412A\rPV-cre pos cell\rleft claustrum\r\rled1:\tRR072412Apt013ave\r\t500mV LED spot on cell\rled2:\tRR072412Apt015ave"
	AppendText "\t500mV LED spot 0.5mm above cell in WM\r\rLED pulse 10 Hz btw 500 and 1500ms"
EndMacro

Window RR2() : Graph 			// LED stimul with 4 traces (led2 - led5)
	PauseUpdate; Silent 1		// building window...
	Display /W=(835.5,59.75,1347.75,566)/L=Y2/B=X2 led2
	AppendToGraph/L=Y3/B=X3 led3
	AppendToGraph/L=Y4/B=X4 led4
	AppendToGraph/L=Y5/B=X5 led5
	ModifyGraph rgb(led4)=(0,43520,65280),rgb(led5)=(0,43520,65280)
	ModifyGraph nticks(Y2)=3,nticks(X2)=2,nticks(Y3)=3,nticks(X3)=2,nticks(Y4)=3,nticks(X4)=2
	ModifyGraph nticks(X5)=2
	ModifyGraph lblMargin(Y2)=15,lblMargin(Y3)=15,lblMargin(Y4)=15,lblMargin(Y5)=15
	ModifyGraph standoff(Y2)=0,standoff(X2)=0,standoff(X3)=0,standoff(X4)=0,standoff(Y5)=0
	ModifyGraph standoff(X5)=0
	ModifyGraph lblPosMode(Y2)=1,lblPosMode(Y3)=1,lblPosMode(Y4)=1,lblPosMode(Y5)=1
	ModifyGraph lblPos(Y2)=50,lblPos(X2)=35,lblPos(X3)=35,lblPos(X4)=35,lblPos(X5)=35
	ModifyGraph btLen(Y2)=4,btLen(X2)=4,btLen(Y3)=4,btLen(X3)=4,btLen(Y4)=4,btLen(X4)=4
	ModifyGraph btLen(X5)=4
	ModifyGraph freePos(Y2)={0,X2}
	ModifyGraph freePos(X2)={0.35,kwFraction}
	ModifyGraph freePos(Y3)={0,X3}
	ModifyGraph freePos(X3)={0.35,kwFraction}
	ModifyGraph freePos(Y4)={0,X4}
	ModifyGraph freePos(X4)={0,kwFraction}
	ModifyGraph freePos(Y5)={0,X5}
	ModifyGraph freePos(X5)={0,kwFraction}
	ModifyGraph axisEnab(Y2)={0.35,0.65}
	ModifyGraph axisEnab(X2)={0,0.45}
	ModifyGraph axisEnab(Y3)={0.35,0.65}
	ModifyGraph axisEnab(X3)={0.55,1}
	ModifyGraph axisEnab(Y4)={0,0.3}
	ModifyGraph axisEnab(X4)={0,0.45}
	ModifyGraph axisEnab(Y5)={0,0.3}
	ModifyGraph axisEnab(X5)={0.55,1}
	TextBox/C/N=text1/A=LT/X=0.50/Y=35.00 "\\Z08led2"
	TextBox/C/N=text2/A=LT/X=55.50/Y=35.00 "\\Z08led3"
	TextBox/C/N=text03/A=LT/X=0.50/Y=70.00 "\\Z08led4"
	TextBox/C/N=text3/A=LT/X=53.00/Y=0.00 "\\Z08\r\\K(65280,0,0)RR072412A \t\\K(0,43520,65280)RR072412B"
	AppendText "\\K(65280,0,0)PV-cre pos cell\t\\K(0,43520,65280)green beads, claustrocortical cell\r\\K(0,0,0)left claustrum\r"
	AppendText "\\K(65280,0,0)led2:\tRR072412ABpt003ave Cell A\r\t500mV LED spot on cell B\rled3:\tRR072412ABpt007tr0-10ave Cell A"
	AppendText "\t500mV LED spot 0.4mm above cell in WM\r\\K(0,43520,65280)led4:\tRR072412ABpt003ave Cell B\r\t500mV LED spot on cell B\rled5:\tRR072412ABpt007ave Cell B"
	AppendText "\t500mV LED spot 0.4mm above cell in WM"
	TextBox/C/N=text4/A=LT/X=55.50/Y=70.00 "\\Z08led5"
EndMacro

Window RR3() : Graph		// LED stimul with 5 traces (led1 - led5)
	PauseUpdate; Silent 1		// building window...
	Display /W=(835.5,59.75,1347.75,566)/L=Y1/B=X1 led1
	AppendToGraph/L=Y2/B=X2 led2
	AppendToGraph/L=Y3/B=X3 led3
	AppendToGraph/L=Y4/B=X4 led4
	AppendToGraph/L=Y5/B=X5 led5
	ModifyGraph rgb(led4)=(65280,0,0),rgb(led5)=(65280,0,0)
	ModifyGraph nticks(Y1)=2,nticks(X1)=2,nticks(Y2)=3,nticks(X2)=2,nticks(Y3)=3,nticks(X3)=2
	ModifyGraph nticks(Y4)=3,nticks(X4)=2,nticks(X5)=2
	ModifyGraph lblMargin(Y1)=15,lblMargin(Y2)=15,lblMargin(Y3)=15,lblMargin(Y4)=15
	ModifyGraph lblMargin(Y5)=15
	ModifyGraph standoff(Y1)=0,standoff(Y2)=0,standoff(X2)=0,standoff(X3)=0,standoff(X4)=0
	ModifyGraph standoff(Y5)=0,standoff(X5)=0
	ModifyGraph lblPosMode(Y1)=1,lblPosMode(Y2)=1,lblPosMode(Y3)=1,lblPosMode(Y4)=1
	ModifyGraph lblPosMode(Y5)=1
	ModifyGraph lblPos(X1)=35,lblPos(Y2)=50,lblPos(X2)=35,lblPos(X3)=35,lblPos(X4)=35
	ModifyGraph lblPos(X5)=35
	ModifyGraph btLen(Y1)=4,btLen(X1)=4,btLen(Y2)=4,btLen(X2)=4,btLen(Y3)=4,btLen(X3)=4
	ModifyGraph btLen(Y4)=4,btLen(X4)=4,btLen(X5)=4
	ModifyGraph freePos(Y1)={0,X1}
	ModifyGraph freePos(X1)={0.7,kwFraction}
	ModifyGraph freePos(Y2)={0,X2}
	ModifyGraph freePos(X2)={0.35,kwFraction}
	ModifyGraph freePos(Y3)={0,X3}
	ModifyGraph freePos(X3)={0.35,kwFraction}
	ModifyGraph freePos(Y4)={0,X4}
	ModifyGraph freePos(X4)={0,kwFraction}
	ModifyGraph freePos(Y5)={0,X5}
	ModifyGraph freePos(X5)={0,kwFraction}
	ModifyGraph axisEnab(Y1)={0.7,1}
	ModifyGraph axisEnab(X1)={0,0.45}
	ModifyGraph axisEnab(Y2)={0.35,0.65}
	ModifyGraph axisEnab(X2)={0,0.45}
	ModifyGraph axisEnab(Y3)={0.35,0.65}
	ModifyGraph axisEnab(X3)={0.55,1}
	ModifyGraph axisEnab(Y4)={0,0.3}
	ModifyGraph axisEnab(X4)={0,0.45}
	ModifyGraph axisEnab(Y5)={0,0.3}
	ModifyGraph axisEnab(X5)={0.55,1}
	TextBox/C/N=text1/A=LT/X=0.50/Y=35.00 "\\Z08led2"
	TextBox/C/N=text2/A=LT/X=55.50/Y=35.00 "\\Z08led3"
	TextBox/C/N=text03/A=LT/X=0.50/Y=70.00 "\\Z08led4"
	TextBox/C/N=text3/A=LT/X=53.00/Y=0.00 "\\Z07\rRR072412B\rgreen beads, claustrocortical cell\r\\K(0,0,0)left claustrum\r\rled1:\tRR072412Bpt034ave"
	AppendText "\t500mV LED spot 0.4mm above cell in claustrum\rled2:\tRR072412Bpt035ave\r\t500mV LED spot 0.4mm above cell in WM\rled3:\tRR072412Bpt036ave"
	AppendText "\t50mV LED spot 0.4mm above cell in claustrum\rled4:\tRR072412Bpt037ave\r\t500mV LED spot 1.5mm above cell above claustrum\rled5:\tRR072412Bpt034ave"
	AppendText "\t500mV LED spot 1.5mm above cell in WM"
	TextBox/C/N=text4/A=LT/X=55.50/Y=70.00 "\\Z08led5"
	TextBox/C/N=text0/A=LT/X=0.50/Y=0.50 "\\Z08led1"
EndMacro

Window RR4() : Graph			// connectivity between cell A and B
	PauseUpdate; Silent 1		// building window...
	Display /W=(798,42.5,1310.25,548.75)/L=Y2/B=X2 cnct1AB
	AppendToGraph/R=Y5/B=X2 cnct1ABb
	AppendToGraph/L=Y4/B=X4 cnct1BA
	AppendToGraph/R=Y6/B=X4 cnct1BAb
	ModifyGraph rgb(cnct1ABb)=(0,43520,65280),rgb(cnct1BAb)=(0,43520,65280)
	ModifyGraph nticks(Y2)=2,nticks(X2)=3,nticks(Y5)=3,nticks(Y4)=3,nticks(X4)=3,nticks(Y6)=3
	ModifyGraph lblMargin(Y2)=15,lblMargin(Y5)=10,lblMargin(Y4)=15,lblMargin(Y6)=10
	ModifyGraph standoff(Y2)=0,standoff(X2)=0,standoff(X4)=0
	ModifyGraph axRGB(Y2)=(65280,0,0),axRGB(Y5)=(0,43520,65280),axRGB(Y4)=(65280,0,0)
	ModifyGraph axRGB(Y6)=(0,43520,65280)
	ModifyGraph tlblRGB(Y2)=(65280,0,0),tlblRGB(Y5)=(0,43520,65280),tlblRGB(Y4)=(65280,0,0)
	ModifyGraph tlblRGB(Y6)=(0,43520,65280)
	ModifyGraph lblPosMode(Y2)=1,lblPosMode(Y5)=1,lblPosMode(Y4)=1,lblPosMode(Y6)=1
	ModifyGraph lblPos(Y2)=50,lblPos(X2)=35,lblPos(X4)=35
	ModifyGraph btLen=4
	ModifyGraph freePos(Y2)={0,X2}
	ModifyGraph freePos(X2)={0.35,kwFraction}
	ModifyGraph freePos(Y5)={3500,X2}
	ModifyGraph freePos(Y4)={0,X4}
	ModifyGraph freePos(X4)={0,kwFraction}
	ModifyGraph freePos(Y6)={3500,X4}
	ModifyGraph axisEnab(Y2)={0.35,0.65}
	ModifyGraph axisEnab(Y5)={0.35,0.65}
	ModifyGraph axisEnab(Y4)={0,0.3}
	ModifyGraph axisEnab(Y6)={0,0.3}
	TextBox/C/N=text1/A=LT/X=40.00/Y=35.00 "\\Z08Cell C -> Cell D"
	TextBox/C/N=text03/A=LT/X=40.28/Y=82.70 "\\Z08 Cell D -> Cell C"
	TextBox/C/N=text3/A=LT/X=0.98/Y=3.49 "\\Z08\r\\K(65280,0,0)RR062612C\t\t\t\\K(0,43520,65280)RR062612D"
	AppendText "\\K(65280,0,0)red beads, claustroipsicortical cell\t\\K(0,43520,65280)green beads, claustrocontracortical cell\r\\K(65280,0,0)HP:-1000pA"
	AppendText "\\K(0,0,0)left claustrum\r32°C, 3mM KCl internal\r\rRR062612CD.011\rAverage of 51 traces each"
EndMacro



Window RR5() : Graph			//cc_step1,cc_step2,cc_sag
	PauseUpdate; Silent 1		// building window...
	Display /W=(789,95.75,1301.25,602)/L=Y2/B=X2 cc_step1
	AppendToGraph/L=Y3/B=X3 cc_step2
	AppendToGraph/L=Y4/B=X4 cc_sag
	ModifyGraph nticks=2
	ModifyGraph lblMargin(X4)=3
	ModifyGraph standoff=0
	ModifyGraph lblPos(Y2)=45,lblPos(X2)=35,lblPos(Y3)=45,lblPos(X3)=35,lblPos(Y4)=45
	ModifyGraph lblPos(X4)=35
	ModifyGraph btLen=4
	ModifyGraph freePos(Y2)={0,X2}
	ModifyGraph freePos(X2)={0.7,kwFraction}
	ModifyGraph freePos(Y3)={0,X3}
	ModifyGraph freePos(X3)={0.35,kwFraction}
	ModifyGraph freePos(Y4)={0,X4}
	ModifyGraph freePos(X4)={0,kwFraction}
	ModifyGraph axisEnab(Y2)={0.7,1}
	ModifyGraph axisEnab(Y3)={0.35,0.65}
	ModifyGraph axisEnab(Y4)={0,0.3}
	TextBox/C/N=text0/A=MC/X=-43/Y=45 "50 pA"
	TextBox/C/N=text1/A=MC/X=-43/Y=12 "200 pA"
	TextBox/C/N=text2/A=MC/X=-43/Y=-27 "-100 pA"
	TextBox/C/N=text3/A=MC/X=36/Y=45 "\\Z09RR061912B\rred beads\rClaustrocortical projection neuron\r32°C"
EndMacro

Window RR6() : Graph			//Photofluor stimul on and off
	PauseUpdate; Silent 1		// building window...
	Display /W=(721.5,44,1368,568.25)/L=Y2/B=X2 cc_step1
	AppendToGraph/L=Y3/B=X3 cc_step2
	AppendToGraph/L=Y4/B=X4 cc_sag
	AppendToGraph/L=Y1/B=X1 fluor_on
	AppendToGraph/L=Y0/B=X0 fluor_off
	ModifyGraph nticks=2
	ModifyGraph lblMargin(X4)=3
	ModifyGraph standoff(Y2)=0,standoff(X2)=0,standoff(Y3)=0,standoff(X3)=0,standoff(Y4)=0
	ModifyGraph standoff(X4)=0,standoff(Y1)=0,standoff(X1)=0,standoff(X0)=0
	ModifyGraph lblPos(Y2)=45,lblPos(X2)=35,lblPos(Y3)=45,lblPos(X3)=35,lblPos(Y4)=45
	ModifyGraph lblPos(X4)=35,lblPos(Y1)=45,lblPos(X1)=35,lblPos(Y0)=45,lblPos(X0)=35
	ModifyGraph btLen(Y2)=4,btLen(X2)=4,btLen(Y3)=4,btLen(X3)=4,btLen(Y4)=4,btLen(X4)=4
	ModifyGraph btLen(Y1)=4,btLen(X1)=4,btLen(X0)=4
	ModifyGraph freePos(Y2)={0,X2}
	ModifyGraph freePos(X2)={0.7,kwFraction}
	ModifyGraph freePos(Y3)={0,X3}
	ModifyGraph freePos(X3)={0.7,kwFraction}
	ModifyGraph freePos(Y4)={0,X4}
	ModifyGraph freePos(X4)={0.35,kwFraction}
	ModifyGraph freePos(Y1)={0,X2}
	ModifyGraph freePos(X1)={0,kwFraction}
	ModifyGraph freePos(Y0)={0,X0}
	ModifyGraph freePos(X0)={0,kwFraction}
	ModifyGraph axisEnab(Y2)={0.7,1}
	ModifyGraph axisEnab(X2)={0,0.45}
	ModifyGraph axisEnab(Y3)={0.7,1}
	ModifyGraph axisEnab(X3)={0.55,1}
	ModifyGraph axisEnab(Y4)={0.35,0.65}
	ModifyGraph axisEnab(X4)={0,0.45}
	ModifyGraph axisEnab(Y1)={0,0.3}
	ModifyGraph axisEnab(X1)={0,0.45}
	ModifyGraph axisEnab(Y0)={0,0.3}
	ModifyGraph axisEnab(X0)={0.55,1}
	TextBox/C/N=text0/A=MC/X=-45.00/Y=45.00 "\\Z1080 pA"
	TextBox/C/N=text1/A=LC/X=56.00/Y=44.96 "\\Z10500 pA"
	TextBox/C/N=text2/A=MC/X=-45.00/Y=6.00 "\\Z10\r-50 pA"
	TextBox/C/N=text3/A=LC/X=55.00/Y=3.84 "\\Z09RR060712A\rAAV2/1 synapsin mCherry\rPFC, VCtx & SCtx\ripsi claustral cell\r32°C"
	TextBox/C/N=text4/A=MC/X=-45.00/Y=-25.00 "\\Z09light on"
	TextBox/C/N=text5/A=LC/X=56.00/Y=-24.96 "\\Z09light off"
	TextBox/C/N=text6/A=LC/X=55.00/Y=-8.48 "\\Z09\rlight at pos. 3 / transmission 20%\rshutter open 10Hz between 500ms and 1500ms,\r10ms each"
EndMacro



Window RR7() : Graph  			//Photofluor stimul on and off and led
	PauseUpdate; Silent 1		// building window...
	Display /W=(775.5,44,1426.5,582.5)/L=L0/B=B0 vc_start
	AppendToGraph/L=L1/B=B1 cc_step1
	AppendToGraph/L=L2/B=B2 cc_sag
	AppendToGraph/L=L3/B=B3 cc_led1
	AppendToGraph/L=L6/B=B6 cc_fluor_on
	AppendToGraph/L=L7/B=B7 cc_fluor_off
	AppendToGraph/L=L4/B=B4 cc_led2
	AppendToGraph/L=L5/B=B5 cc_led3
	ModifyGraph nticks(L0)=3,nticks(B0)=3,nticks(L1)=3,nticks(B1)=2,nticks(L2)=3,nticks(B2)=2
	ModifyGraph nticks(L3)=3,nticks(B3)=2,nticks(L4)=3,nticks(B4)=2,nticks(L5)=3,nticks(B5)=2
	ModifyGraph nticks(L6)=3,nticks(B6)=2,nticks(L7)=3,nticks(B7)=2
	ModifyGraph lblMargin(L0)=14,lblMargin(L1)=14,lblMargin(L2)=14,lblMargin(L3)=14
	ModifyGraph lblMargin(L4)=14,lblMargin(L5)=14,lblMargin(L6)=14,lblMargin(L7)=14
	ModifyGraph standoff(L0)=0,standoff(B0)=0,standoff(L1)=0,standoff(B1)=0,standoff(L2)=0
	ModifyGraph standoff(B2)=0,standoff(L3)=0,standoff(B3)=0,standoff(L4)=0,standoff(B4)=0
	ModifyGraph standoff(L5)=0,standoff(B5)=0,standoff(L6)=0,standoff(B6)=0,standoff(B7)=0
	ModifyGraph lblPosMode(L0)=1,lblPosMode(B0)=2,lblPosMode(B1)=2,lblPosMode(L2)=1
	ModifyGraph lblPosMode(B2)=2,lblPosMode(L3)=1,lblPosMode(B3)=2,lblPosMode(L4)=1
	ModifyGraph lblPosMode(B4)=2,lblPosMode(L5)=1,lblPosMode(B5)=2,lblPosMode(L6)=1
	ModifyGraph lblPosMode(B6)=2,lblPosMode(L7)=1,lblPosMode(B7)=2
	ModifyGraph lblPos(L0)=52,lblPos(B0)=37,lblPos(L1)=35,lblPos(L2)=52
	ModifyGraph btLen=4
	ModifyGraph freePos(L0)={0,B0}
	ModifyGraph freePos(B0)=-287
	ModifyGraph freePos(L1)={0,B1}
	ModifyGraph freePos(B1)=-287
	ModifyGraph freePos(L2)={0,B2}
	ModifyGraph freePos(B2)=-193
	ModifyGraph freePos(L3)={0,B3}
	ModifyGraph freePos(B3)=-193
	ModifyGraph freePos(L4)={0,B4}
	ModifyGraph freePos(B4)=-96
	ModifyGraph freePos(L5)={0,B5}
	ModifyGraph freePos(B5)=-96
	ModifyGraph freePos(L6)={0,B6}
	ModifyGraph freePos(B6)=0
	ModifyGraph freePos(L7)={0,B7}
	ModifyGraph freePos(B7)=0
	ModifyGraph axisEnab(L0)={0.8,1}
	ModifyGraph axisEnab(B0)={0,0.45}
	ModifyGraph axisEnab(L1)={0.8,1}
	ModifyGraph axisEnab(B1)={0.55,1}
	ModifyGraph axisEnab(L2)={0.537,0.738}
	ModifyGraph axisEnab(B2)={0,0.45}
	ModifyGraph axisEnab(L3)={0.537,0.737}
	ModifyGraph axisEnab(B3)={0.55,1}
	ModifyGraph axisEnab(L4)={0.267,0.467}
	ModifyGraph axisEnab(B4)={0,0.45}
	ModifyGraph axisEnab(L5)={0.267,0.467}
	ModifyGraph axisEnab(B5)={0.55,1}
	ModifyGraph axisEnab(L6)={0,0.2}
	ModifyGraph axisEnab(B6)={0,0.45}
	ModifyGraph axisEnab(L7)={0,0.2}
	ModifyGraph axisEnab(B7)={0.55,1}
EndMacro

Window RR8() : Graph			// 5 traces cc_1, cc_2, cc_3, cc_4, cc_5
	PauseUpdate; Silent 1		// building window...
	Display /W=(585,71.75,1097.25,578)/L=Y1/B=X1 cc_1
	AppendToGraph/R=Y1b/B=X1 cc_1b
	AppendToGraph/L=Y2/B=X2 cc_2
	AppendToGraph/R=Y2b/B=X2 cc_2b
	AppendToGraph/L=Y3/B=X3 cc_3
	AppendToGraph/R=Y3b/B=X3 cc_3b
	AppendToGraph/L=Y4/B=X4 cc_4
	AppendToGraph/R=Y4b/B=X4 cc_4b
	AppendToGraph/L=Y5/B=X5 cc_5
	AppendToGraph/R=Y5b/B=X5 cc_5b
	ModifyGraph rgb(cc_1b)=(0,43520,65280),rgb(cc_2b)=(0,43520,65280),rgb(cc_3b)=(0,43520,65280)
	ModifyGraph rgb(cc_4b)=(0,43520,65280),rgb(cc_5b)=(0,43520,65280)
	ModifyGraph nticks=3
	ModifyGraph fSize=10
	ModifyGraph lblMargin(Y1)=10,lblMargin(X1)=15,lblMargin(Y1b)=15,lblMargin(Y2)=10
	ModifyGraph lblMargin(X2)=15,lblMargin(Y2b)=10,lblMargin(Y3)=10,lblMargin(X3)=15
	ModifyGraph lblMargin(Y3b)=10,lblMargin(Y4)=10,lblMargin(X4)=15,lblMargin(Y4b)=10
	ModifyGraph lblMargin(Y5)=10,lblMargin(X5)=15,lblMargin(Y5b)=10
	ModifyGraph standoff(Y1)=0,standoff(X1)=0,standoff(Y1b)=0,standoff(Y2)=0,standoff(X2)=0
	ModifyGraph standoff(Y2b)=0,standoff(X3)=0,standoff(Y3b)=0,standoff(X4)=0,standoff(Y4b)=0
	ModifyGraph standoff(Y5)=0,standoff(X5)=0,standoff(Y5b)=0
	ModifyGraph axRGB(Y1)=(65280,0,0),axRGB(Y1b)=(0,43520,65280),axRGB(Y2)=(65280,0,0)
	ModifyGraph axRGB(Y2b)=(0,43520,65280),axRGB(Y3)=(65280,0,0),axRGB(Y3b)=(0,43520,65280)
	ModifyGraph axRGB(Y4)=(65280,0,0),axRGB(Y4b)=(65280,0,0),axRGB(Y5b)=(0,43520,65280)
	ModifyGraph tlblRGB(Y1)=(65280,0,0),tlblRGB(Y1b)=(0,43520,65280),tlblRGB(Y2)=(65280,0,0)
	ModifyGraph tlblRGB(Y2b)=(0,43520,65280),tlblRGB(Y3)=(65280,0,0),tlblRGB(Y3b)=(0,43520,65280)
	ModifyGraph tlblRGB(Y4)=(65280,0,0),tlblRGB(Y4b)=(65280,0,0),tlblRGB(Y5b)=(0,43520,65280)
	ModifyGraph lblPosMode(Y1)=1,lblPosMode(Y2)=1,lblPosMode(Y2b)=1,lblPosMode(Y3)=1
	ModifyGraph lblPosMode(Y3b)=1,lblPosMode(Y4)=1,lblPosMode(Y4b)=1,lblPosMode(Y5)=1
	ModifyGraph lblPosMode(Y5b)=1
	ModifyGraph lblPos(Y1)=60,lblPos(X1)=35,lblPos(Y1b)=35,lblPos(Y2)=50,lblPos(X2)=35
	ModifyGraph lblPos(Y2b)=35,lblPos(X3)=35,lblPos(X4)=35,lblPos(Y5)=30,lblPos(X5)=35
	ModifyGraph btLen=4
	ModifyGraph freePos(Y1)={0,X1}
	ModifyGraph freePos(X1)={0.7,kwFraction}
	ModifyGraph freePos(Y1b)={4000,X1}
	ModifyGraph freePos(Y2)={0,X2}
	ModifyGraph freePos(X2)={0.35,kwFraction}
	ModifyGraph freePos(Y2b)={4000,X2}
	ModifyGraph freePos(Y3)={0,X3}
	ModifyGraph freePos(X3)={0.35,kwFraction}
	ModifyGraph freePos(Y3b)={4000,X3}
	ModifyGraph freePos(Y4)={0,X4}
	ModifyGraph freePos(X4)={0,kwFraction}
	ModifyGraph freePos(Y4b)={4000,X4}
	ModifyGraph freePos(Y5)={0,X5}
	ModifyGraph freePos(X5)={0,kwFraction}
	ModifyGraph freePos(Y5b)={4000,X5}
	ModifyGraph axisEnab(Y1)={0.7,1}
	ModifyGraph axisEnab(X1)={0,0.45}
	ModifyGraph axisEnab(Y1b)={0.7,1}
	ModifyGraph axisEnab(Y2)={0.35,0.65}
	ModifyGraph axisEnab(X2)={0,0.45}
	ModifyGraph axisEnab(Y2b)={0.35,0.65}
	ModifyGraph axisEnab(Y3)={0.35,0.65}
	ModifyGraph axisEnab(X3)={0.55,1}
	ModifyGraph axisEnab(Y3b)={0.35,0.65}
	ModifyGraph axisEnab(Y4)={0,0.3}
	ModifyGraph axisEnab(X4)={0,0.45}
	ModifyGraph axisEnab(Y4b)={0,0.3}
	ModifyGraph axisEnab(Y5)={0,0.3}
	ModifyGraph axisEnab(X5)={0.55,1}
	ModifyGraph axisEnab(Y5b)={0,0.3}
	TextBox/C/N=text0/A=LT/X=1.00/Y=1.00 "\\Z08cc_1"
	TextBox/C/N=text1/A=LT/X=1.00/Y=35.00 "\\Z08cc_2"
	TextBox/C/N=text2/A=LT/X=55.50/Y=35.00 "\\Z08cc_3"
	TextBox/C/N=text03/A=LT/X=1.00/Y=70.00 "\\Z08cc_4"
	TextBox/C/N=text3/A=LT/X=53.00/Y=0.00 "\\Z07\r\\K(65280,0,0)RR072612B\t\\K(0,43520,65280)RR072612D"
	AppendText "\\K(65280,0,0)PV-cre pos cell\t\\K(0,43520,65280)green beads, claustrocortical cell\r\\K(0,0,0)left claustrum\r32°C, 3mM KCl internal\r"
	AppendText "cc_1:\tRR072612Dpt013tr007\rcc_2:\tRR072612Dpt013tr012\rcc_3:\tRR072612Dpt013tr015\rcc_4:\tRR072612Dpt013tr024"
	TextBox/C/N=text4/A=LT/X=55.50/Y=70.00 "\\Z08cc_5"
EndMacro
