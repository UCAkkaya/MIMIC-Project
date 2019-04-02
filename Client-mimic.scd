//Code for client of MIMIC.

//boiler values of electrode1 ONLY for test!
/*
(
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

NetAddr.localAddr.sendMsg('/el0', *~valdict);
)
*/

//Utopia
(
~win = Window("AdHocSociety").front;
~win.layout = VLayout.new.add(~listView = ListView.new);

~addrBook = AddrBook.new;
// to get updates, just add a dependant
~addrBook.addDependant({|addrBook, what, who|
	{~listView.items = addrBook.peers.collectAs({|peer|
		peer.name ++ " | " ++ peer.addr.ip ++ " | " ++ if(peer.online, "online", "offline");
	}, Array)}.defer;
});
~addrBook.addMe;// will automatically add you using your user name
//~addrBook.addMe(\YourNAMEhere);  // or specify your name
~hail = Hail(~addrBook);
)


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


(
~valdict = ();

OSCdef(\brainIn1, {|msg|
	if(~valdict.notNil){
		if(~windowfunc.notNil){
	(1, 3 .. msg.size).do { |i|
		~valdict.put(msg[i], msg[i+1])
 	};
	//~valdict.postln
			{~windowfunc.value}.defer;
		}
	};
}, '/el0');
)

(
SynthDef(\sine, {arg freq = 120;
	var sig = Mix.ar( { SinOsc.ar(freq.lag(0.3)) }!8) * EnvGen.ar(Env.sine(0.25), doneAction:2);
	sig = LeakDC.ar(sig);
	ReplaceOut.ar(0, sig);
}).add;
);


//experimental: add specs for each value like this:
Spec.add(\betaHi, [120, 140.0])

//Use linlin to scale up the value to the appropriate range:
(
Pdef(\x, Pbind(\instrument, \sine,
	\dur, Pfunc{ ~valdict.alpha / 2},
	\freq, Pfunc{ ~valdict.betaLo.linlin(0, 1, 120.0, 1660.0) }) ).play;
)
