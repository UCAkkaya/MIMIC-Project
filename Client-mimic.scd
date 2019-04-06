//Code for client of MIMIC.

//pseudo osc input message.
/*(
~msg = 4.do{Array.fill(8, {rrand(0.0, 1.0).postln})};
NetAddr.localAddr.sendMsg('/band', "el", ~msg);
)
*/

~events = ~objSpace[\event];

(
~events.do{|events|
	~elgui = EnvirGui(events);
	~egui.parent.name = "electrodes";

	events.do.keys{|key| events.addSpec(key, [0.0, 1.0]) };
	};
)

~objSpace = OSCObjectSpace(~addrBook, true);

Tdef(\changeEvent, { loop{ 0.085.wait;
	~event = ~objSpace[\event];
	~el1 = ~event[\el0].asEvent.asStream.values;
	~el2 = ~event[\el1].asEvent.asStream.values;
	~el3 = ~event[\el2].asEvent.asStream.values;
	~el3 = ~event[\el3].asEvent.asStream.values;
} }).play;



(
~elgui = EnvirGui(~events[\el]);
~egui.parent.name = "electrode";

// with JITLibExtensions, you can add specs to the valdict:
~valdict.addSpec(\blink, [0, 1], );
// are they all unipolar?
~valdict.keys.do { |key|
        ~valdict.addSpec(key, [0.0, 1.0]);
};
)
)

Pdef(\x, Pbind(\instrument, \sine, \amp, 0.1, \dur, Pfunc{~val.linlin(0, 1, 0.5, 1)}, \degree, Prand(~el3*9, inf))).play;
Pdef(\y, Pbind(\instrument, \UCAsaw, \dur, Pfunc{~val.linlin(0, 1, 0.5, 2.0) }, \degree, Prand(~el2*4, inf))).play;
Pdef(\z, Pbind(\instrument, \pingy, \dur, Pfunc{~val.linlin(0, 1, 0.5, 2.0) }, \degree, Prand(~el3*8, inf))).trace.play;

// Boiler code on using the brainwave values.

(
SynthDef(\sine, {arg freq = 120, mod = 0.1, release = 0.25, amp = 0.1, atk = 0.01;
	var sig = Mix.ar( { SinOsc.ar(freq.lag(0.3), 0, SinOsc.ar(mod).range(0.1, 0.8)) }!8) * EnvGen.ar(Env.perc(atk, release), doneAction:2);
	sig = LeakDC.ar(sig);
	ReplaceOut.ar(0, sig * amp);
}).add;

SynthDef(\saw, {
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




//Use linlin or linexp to scale up the value to the appropriate range:
//KEY HERE IS DATA IS SENT EXPONENTIALLY SO YOU DON'T GET THE HIGH 1 VALUE THAT OFTEN.

(
Pdef(\x, Pbind(\instrument, \sine,
	\dur, Pfunc{ ~valdict.betaHi + rrand(0.25, 0.6)},
	\freq, Pfunc{ ~valdict.alpha.linlin(0, 0.5, 120.0, 1220.0) + rrand(10, 100) },
	\mod, Pfunc{ ~valdict.beta + rrand(0.1, 10.0) },
	\release, Pfunc{ ~valdict.alpha},
	\legato, 0.1,
	\amp, Pfunc{ ~valdict.gamma.max(0.9)}
)
);
)

(
var win, text;
win = Window.new("bots", 300@600);
text = TextView(win, win.view.bounds);
~textfunc = {
		text.string = ~event.asString
};
text.syntaxColorize;
win.front;
text.mouseUpAction_{|key, val|
	var ndef = Ndef("node: " ++ val.asString, {
		SinOsc.ar(\freq.kr(100, 0.3));
	});
	ndef[1] = \set -> Pbind(\dur, ~event.asEvent.delta, \freq, Pfunc{~event.asEvent.gamma + val});
	ndef[1..8] = \filter -> {arg in; GVerb.ar(in, mul:0.1)};
	ndef.play(0,2)
};

NdefMixer(s);
)

//try lowering the range of linlin and linexp.
//More importantly for dronning sounds (where brain wave is calmer).

(
Pdef(\drone, Pbind(\instrument, \UCAsaw,
	\atk, 6,
	\release, 6,
	\dur, Pfunc{ ~valdict.betaHi.linexp(0.010, 0.25, 1, 2) + rrand(0.7, 1.6)},
	\freq, Pfunc{ ~valdict.alpha.linexp(0.010, 0.5, 200, 4440) + rrand(10, 100) },
	\filterQ, Pfunc{~valdict.gamma.linlin(0, 0.3, 0.01, 1)},
	\amp, Pfunc{ ~valdict.gamma.max(0.9) + 0.5}
).trace
);
)

//experimental: add specs for each value like this:
Spec.add(\betaHi, [120, 140.0])

// You can use comparison of these values.
// For example BetaHi(or mean of three beta values)/Alpha shows the focus of the subject.

(
Pdef(\drone2, Pbind(\instrument, \UCAsaw,
	\dur, Pfunc{ ~valdict.betaHi/~valdict.alpha}*0.2,
	\freq, Pfunc{ (~valdict.delta/~valdict.gamma) * 40 + rrand(10, 100) },
	\atk, Pfunc{ ~valdict.beta/~valdict.gamma},
	\release, Pfunc{ ~valdict.alpha * ~valdict.delta},
	\legato, 1,
	\amp, Pfunc{ ~valdict.gamma.max(0.9) + 0.1}
).trace
);
)
