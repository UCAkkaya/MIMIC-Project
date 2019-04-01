//Code for client of MIMIC.

//boiler values of electrode1:

~valdict = (
	blink: 1.0.rand,
	delta: 1.0.rand,
	theta: 1.0.rand,
	alpha: 1.0.rand,
	betaLo: 1.0.rand,
	beta: 1.0.rand,
	betaHi: 1.0.rand,
	gamma: 1.0.rand
);


//dummy way of updating values on sliders
(
~windowfunc = {
	~sliders[0].value = ~valdict.blink;
	~sliders[1].value = ~valdict.delta;
	~sliders[2].value = ~valdict.theta;
	~sliders[3].value = ~valdict.alpha;
	~sliders[4].value = ~valdict.betaLo;
	~sliders[5].value = ~valdict.beta;
	~sliders[6].value = ~valdict.betaHi;
	~sliders[0].value = ~valdict.gamma;
};
)


~window = Window("electrode").front
.view.layout = HLayout (
* (~sliders = {Slider()} !8) );

~sliders[0].value = 0.1
(
~valdict = ();

OSCdef(\brainIn1, {|msg|
	(1, 3 .. msg.size).do { |i|
		~valdict.put(msg[i], msg[i+1])
 	};
	//~valdict.postln
	~valdict;
	~windowfunc.value;
}, '/el0');
)

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
