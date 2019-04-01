//Code for client of MIMIC.

~window = Window("Electrode").front
.view.layout = HLayout (
* (~sliders = {Slider()} !8) );

~windowfunc = {
	~sliders.do{|sl| sl.value = ~valdict.values};
};

//OR

~windowfunc = {
	~sliders.do{|sl|
		~valdict.keysValuesDo{|keys, vals| ~sliders[keys] = sl[vals] }
	}
};

(
~valdict = ();

OSCdef(\brainIn1, {|msg|
	(1, 3 .. msg.size).do { |i|
		~valdict.put(msg[i], msg[i+1]);
 	};
	//~valdict.postln
	{ ~windowfunc.value }.defer;
}, '/el0');
)

//check is working:
~valdict.betaHi;

(
SynthDef(\sine, {arg freq = 120;
	var sig = Mix.ar( { SinOsc.ar(freq) }!8) * EnvGen.ar(Env.sine(0.25), doneAction:2);
	sig = LeakDC.ar(sig);
	Out.ar(0, sig);
}).add;
);


//experimental: add specs for each value like this:
Spec.add(\betaHi, [120, 140.0])

//Use linlin to scale up the value to the appropriate range:
Pdef(\x, Pbind(\instrument, \sine, \dur, 0.25, \freq, Pfunc{ ~valdict.betaLo.linlin(0, 1, 120.0, 1660.0) }) ).play;