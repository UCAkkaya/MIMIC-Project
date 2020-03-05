// Total of 8 types of data is coming from the master. 7 types of neural oscillations (delta, theta, alpha, betaHigh, beta, betaLow and gamma) for each 4 channel and a BLINK situation which shows if user blinks.
// Neural powers are constrained to 25 microVoltsSquare per Hz and scaled to min 0 max 1.
(
//OSC Communication 
~eegBook = (); //dictionary for spectral power of eeg data

OSCdef(\eegPower, {
arg msg;
msg = msg.round(0.00001);
~eegBook[ msg[1] ] = ([blink: msg[2], delta:msg[3], theta:msg[4], alpha:msg[5], betaLo:msg[6], beta:msg[7], betaHi:msg[8], gamma:msg[9]]);

}, '/test');
)

// TEST with Synthdef
(
SynthDef(\UCAsaw, {
	|atk=2 , sus = 0, rel = 3, freq=222,
	centerFreq=1500, filterQ=0.2,
	out=0,amp=0.4, pan = 0 |
	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0,], [atk,sus,rel], [1,0,-1]), doneAction:2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig,centerFreq,filterQ);
	sig = Pan2.ar(sig, pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;


Pdef( \saw,
Pbind(
	\instrument, \UCAsaw,
	\dur, 1,
	\freq, Pfunc({~eegBook[\el0][7].linexp(0.0, 1.0, 200, 800)}).asStream, //first electrode alpha value 
	\centerFreq, Pfunc({~eegBook[\el0][9].linexp(0.0, 1.0, 400, 1200)}).asStream, // first electrode betaLow value
	\atk, Pfunc({~eegBook[\el0][1].linlin(0, 1, 0.8, 4)}).asStream, //blink value (0,1)
	\rel, 5,
	\amp, 0.65,
	\pan, Pwhite(-0.8, 0.8, inf)
).trace.play);

)

// accessing all the electrode values
~eegBook.keysValuesDo{|key, value| postf("-" ++ [key, value].postln)};

//a better scaling function for generic specification of ranges.
~specs = (
	el1: ControlSpec(1, 10, step: 0.01),
	el2: ControlSpec(1, 20, step: 0.01);
);

x = {|i, val|
	~specs[i].map(val) //first is the el num, second is the value to be scaled up/down.
	/ 1024; //or whatever the maximum value of el is.
};

x.value("el2".asSymbol, 0.1);
