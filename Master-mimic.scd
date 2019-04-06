//Code for Master MIMIC
// Total of 8 types of data is coming from the master. 7 types of neural oscillations (delta, theta, alpha, betaHigh, beta, betaLow and gamma) for each 4 channel and a BLINK situation which shows if user blinks.
// Neural powers are constrained to 25 microVoltsSquare per Hz and scaled to min 0 max 1.

//OSC Communication
(
~eegBook = (); //dictionary for spectral power of eeg data
~objSpace = OSCObjectSpace(~addrBook, true);

OSCdef(\eegPower, {
	arg msg;
	msg = msg.round(0.00001);
	~eegBook[ msg[1] ] = ([blink: msg[2], delta:msg[3], theta:msg[4], alpha:msg[5], betaLo:msg[6], beta:msg[7], betaHi:msg[8], gamma:msg[9]]);
	~objSpace.put(\event, ~eegBook);
}, '/band').permanent_(true);
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
)
Pdef( \saw,
	Pbind(
		\instrument, \UCAsaw,
		\dur, 1,
		\scale, Scale.major,
		// \ctranspose, 12,
		\degree, Pfunc({(~eegBook[\el0][7].linlin(0.0, 0.09, 1, 12).asInt)}).asStream, //first electrode alpha value
		\centerFreq, Pfunc({~eegBook[\el0][9].linexp(0.0, 0.1, 400, 1200)}).asStream, // first electrode betaLow value
		\atk, 3, // Pfunc({~eegBook[\el0][1].linlin(0, 1, 0.8, 4)}).asStream, //blink value (0,1)
		\rel, 2,
		\amp, 0.65,
		\pan, Pwhite(-0.8, 0.8, inf)))

)

Pdef(\saw).play;

