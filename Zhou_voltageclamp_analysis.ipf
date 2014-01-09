#pragma rtGlobals=1		// Use modern global access method.
macro zhou_VAnalysis_adc1()
Duplicate/o adc1_avg_0 vtrace
Variable Vbase
Variable Vpeak
Variable Vsteady
Variable Vbasestart = 158
Variable Vbaseend = 258
Variable Vsteadystart=1800
Variable Vsteadyend = 1900
Variable Vpeakstart= 3001
Variable Vpeakend = 3003
Variable Rm
Variable Raccess
WaveStats/R=[Vbasestart, Vbaseend] vtrace
Vbase=V_avg
WaveStats/R = [Vsteadystart, Vsteadyend] vtrace
Vsteady=V_avg
WaveStats/R = [Vpeakstart, Vpeakend] vtrace
Vpeak=V_avg
Rm= 0.005/((Vbase-Vsteady)*10^(-12))
Raccess= 0.005/((Vpeak-Vbase)*10^(-12))
printf "R membrane: %d\r" Rm
printf "Raccess: %d\r" Raccess
Killwaves vtrace
end macro
macro zhou_VAnalysis_adc0()
Duplicate/o adc0_avg_0 vtrace
Variable Vbase
Variable Vpeak
Variable Vsteady
Variable Vbasestart = 158
Variable Vbaseend = 258
Variable Vsteadystart=1800
Variable Vsteadyend = 1900
Variable Vpeakstart= 3001
Variable Vpeakend = 3003
Variable Rm
Variable Raccess
WaveStats/R=[Vbasestart, Vbaseend] vtrace
Vbase=V_avg
WaveStats/R = [Vsteadystart, Vsteadyend] vtrace
Vsteady=V_avg
WaveStats/R = [Vpeakstart, Vpeakend] vtrace
Vpeak=V_avg
Rm= 0.005/((Vbase-Vsteady)*10^(-12))
Raccess= 0.005/((Vpeak-Vbase)*10^(-12))
printf "R membrane: %d\r" Rm
printf "Raccess: %d\r" Raccess
Killwaves vtrace
end macro
macro zhou_VAnalysis_adc2()
Duplicate/o adc2_avg_0 vtrace
Variable Vbase
Variable Vpeak
Variable Vsteady
Variable Vbasestart = 158
Variable Vbaseend = 258
Variable Vsteadystart=1800
Variable Vsteadyend = 1900
Variable Vpeakstart= 3001
Variable Vpeakend = 3003
Variable Rm
Variable Raccess
WaveStats/R=[Vbasestart, Vbaseend] vtrace
Vbase=V_avg
WaveStats/R = [Vsteadystart, Vsteadyend] vtrace
Vsteady=V_avg
WaveStats/R = [Vpeakstart, Vpeakend] vtrace
Vpeak=V_avg
Rm= 0.005/((Vbase-Vsteady)*10^(-12))
Raccess= 0.005/((Vpeak-Vbase)*10^(-12))
printf "R membrane: %d\r" Rm
printf "Raccess: %d\r" Raccess
Killwaves vtrace
end macro
macro Zhou_vcplot_01()
Duplicate/o adc0_avg_0 Va
Duplicate/o adc1_avg_0 Vb
Display Va
ShowTools/a arrow
Display Vb
ShowTools/a arrow
end macro
macro Zhou_pairplot_01()
Duplicate/o adc0_avg_0 pairRr
Duplicate/o adc1_avg_0 pairbb
Display pairRr
AppendToGraph/R pairbb
end macro
macro Zhou_pairplot_10()
Duplicate/o adc0_avg_0 pairr11
Duplicate/o adc1_avg_0 pairb11
Display pairr11
AppendToGraph/R pairb11
end macro
macro Zhou_pairplot_12()
Duplicate/o adc1_avg_0 pairbb
Duplicate/o adc2_avg_0 paircc
Display pairbb
AppendToGraph/R paircc
ModifyGraph rgb(pairbb)=(16384,48896,65280),rgb(paircc)=(0,65280,0)
ModifyGraph axRGB(left)=(16384,48896,65280),tlblRGB(left)=(16384,48896,65280)
ModifyGraph axRGB(right)=(0,65280,0),tlblRGB(right)=(0,65280,0)
end macro
macro Zhou_pairplot_21()
Duplicate/o adc1_avg_0 pairb11
Duplicate/o adc2_avg_0 pairc11
Display pairb11
AppendToGraph/R pairc11
ModifyGraph rgb(pairb11)=(16384,48896,65280),rgb(pairc11)=(0,65280,0)
ModifyGraph axRGB(left)=(16384,48896,65280),tlblRGB(left)=(16384,48896,65280)
ModifyGraph axRGB(right)=(0,65280,0),tlblRGB(right)=(0,65280,0)
end macro
