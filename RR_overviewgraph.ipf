#pragma rtGlobals=1		// Use modern global access method.

Window Graph0() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(899.25,56,1312.5,550.25) A_80
	AppendToGraph/L=left1 A_200
	AppendToGraph/L=left2 A_neg100
	ModifyGraph lblPos(left)=46,lblPos(left1)=46,lblPos(left2)=46
	ModifyGraph lblLatPos(left)=-7,lblLatPos(left1)=-3,lblLatPos(left2)=-1
	ModifyGraph freePos(left1)=0
	ModifyGraph freePos(left2)=0
	ModifyGraph axisEnab(left)={0.7,1}
	ModifyGraph axisEnab(left1)={0.35,0.65}
	ModifyGraph axisEnab(left2)={0,0.3}
	TextBox/C/N=text0/A=MC/X=-40.00/Y=10.82 "200 pA"
	TextBox/C/N=text1/A=MC/X=-40.00/Y=47.59 "80 pA"
	TextBox/C/N=text2/A=MC/X=-40.00/Y=-28.18 "-100 pA"
	TextBox/C/N=text13/A=MC/X=40.00/Y=47.42 "RR061112A"
EndMacro
