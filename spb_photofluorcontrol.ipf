#pragma rtGlobals=1		// Use modern global access method.

function openport_photofluor(CntrlName) : ButtonControl
	String CntrlName
	VDTOperationsPort2 com6
	VDT2 /P=com6 baud=19200, buffer = 4096, databits=8, echo=1, in=0, out=0, stopbits=1, parity=0,  terminalEOL=0
end

function openshutter_photofluor(CntrlName) : ButtonControl
	String CntrlName
	VDTWrite2 "+\r"
	VDTWrite2 "+\r"
end

function closeshutter_photofluor(CntrlName) : ButtonControl
	String CntrlName
	VDTWrite2 "-/r"
end

Window photofluor_controlpanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1603,58,1903,258)
	Button button0,pos={56,5},size={167,28},proc=openport_photofluor,title="Open Photofluor COM6"
	Button button1,pos={14,47},size={105,38},proc=openshutter_photofluor,title="Open Shutter"
	Button button2,pos={155,48},size={120,36},proc=closeshutter_photofluor,title="Close Shutter"
EndMacro
