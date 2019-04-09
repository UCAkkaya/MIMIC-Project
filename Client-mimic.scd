//Code for MIMIC client.

//pseudo input message
//Please run after the GUI down there or you'll get errors until you run it.

/*
(
~pseudoBook = ();
~objSpace = OSCObjectSpace(~addrBook, true);
~randomer = {[\el0, \el1, \el2, \el3].do{ |msg|
	var variable;
	variable = Array.fill(8, {rrand(0.0, rrand(0.35,rrand (0.55,0.95)))};);
	~pseudoBook[msg] = ([blink: variable[0], delta:variable[1], theta:variable[2], alpha:variable[3],
				betaLo:variable[4], beta:variable[5], betaHi:variable[6], gamma:variable[7]]);
}};

x = Tdef (\randomer, {
	loop {
		{~randomer.value}.defer;
		~objSpace.put(\event, ~pseudoBook);
		~event = ~objSpace[\event];
		{~windowfunct.value}.defer;
		0.25.wait;
	}}).play;

CmdPeriod.add({ "You have deactivated Tdef, rerun now".warn;});
)
*/

// 111111111 GUI
(
~objSpace = OSCObjectSpace(~addrBook, true);

~windowfunct = {
~event[\el0].asEvent.values.do{
	arg changer, i;
	c[0].children[i].value_(changer)
};
~event[\el1].asEvent.values.do{
	arg changer, i;
	c[1].children[i].value_(changer)
};
~event[\el2].asEvent.values.do{
	arg changer, i;
	c[2].children[i].value_(changer)
};
~event[\el3].asEvent.values.do{
	arg changer, i;
	c[3].children[i].value_(changer)
};
};

w = Window("mimician", Rect(100,100,360,600)).front
.alwaysOnTop_(true);

w.view.decorator = d = FlowLayout(w.bounds, 5@5, 7@7);
c = Array.fill(4, {
	|view|
	view = CompositeView(w, 150@150).background_(Color.rand);
	view.decorator_(FlowLayout(view.bounds, 5@5, 5@5));
});

PdefAllGui(16, w, bounds:Rect(0,0,320, 330));
4.do{|i| Array.fill(8, {Slider(c[i], 140@20)}); };

d.reset;
d.left_(320);
s = StaticText(w, Rect(0, 0, 35, 150));
s.string = "Blink
Delta   Theta      Alpha     BetLo     Beta     BetHi     Gamma";
s.align_(\);

~elgui = EnvirGui(~event, 4, bounds: 1250@50);

)

// 222222 Communication with Master
(
Tdef(\eegCounter, {
	loop{
	~event = ~objSpace[\event];
	~el0 = ~event[\el0].asEvent;
	~el1 = ~event[\el1].asEvent;
	~el2 = ~event[\el2].asEvent;
	~el3 = ~event[\el3].asEvent;
		if (~windowfunct.notNil) {
			{~windowfunct.value}.defer
		};
	0.10.wait;
} }).play;
CmdPeriod.add({ "You have deactivated Tdef, rerun now".warn;});

~elgui = EnvirGui(~event, 4, bounds: 1250@50);

)



//////////////////////////////////////////////////////////////////////////////////

// IMPORTANT!
// In order to use a singular value of choosen electrode you have to implement this:
~el1.alpha //alpha value of the first electrode
~el2.theta // theta value o the third electrode

// IMPORTANT!
// If you want to use every neural power value of choosen electrode you have to use this:
~el1.asStream.values //this will give every power value of the 2nd electrode (including the blink value)
~el2.asStream.values // values of the 3rd electrode

//////////////////////////////////////////////////////////////////////////////////


// Boiler code on using the brainwave values. (still working)
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

SynthDef(\UCAconvolution, {
	|atk=2 , sus = 0, rel = 3, freq=222,
	centerFreq=1500, filterQ=0.2,
	out=0,amp=0.4, pan = 0, kernel|
	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0,], [atk,sus,rel], [1,0,-1]), doneAction:2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig,centerFreq,filterQ);
	sig = Pan2.ar(sig, pan);
	sig = sig * env * amp;
	sig = Convolution.ar(sig, SinOsc.ar(kernel));
	Out.ar(out, sig);
}).add;

SynthDef(\chord,
    { |out=0, freq=440, amp=0.1, pan=0 atk=2 rel=4 lowPassFreq= 400, rq=0.71 revMix = 1|
        var env, sig;
        env = EnvGen.kr(Env.perc(atk, rel), doneAction:2) ;
		sig = (Saw.ar(freq, 0.2) + SinOsc.ar(freq*4)).tanh.sin;
		sig = FreeVerb2.ar(sig, sig.sin, revMix, 99, 0.3);
		sig = BLowPass4.ar(sig,(lowPassFreq)+freq,rq);
		Out.ar(out, Splay.ar(sig, pan));
    }).add;

SynthDef(\UCArhodes,{
	|atk=0.01 , rel = 2, out= 0, freq = 440, amp = 0.3, gate=1, rq=0.5, pan = 0, lowPassFreq=750, filterQ=0.2 |
	var sig, filter, env;
	sig = Pulse.ar(freq* [1,2], Rand(0.200, 0.300), 1);
	env = EnvGen.ar(Env.perc(atk, rel), doneAction: 2);
	sig = BLowPass4.ar(sig,(lowPassFreq)+freq,rq);
	sig = Pan2.ar(sig, pan);
	sig = (sig * env * amp * 0.10).flop.sum.tanh;
	Out.ar(out, sig);
}).add;

SynthDef.new (\sine, {
	|freq=440, atk=0.005, rel=0.3, amp=1, pan=0|
	var sig, env;
	sig = SinOsc.ar (freq);
	env = EnvGen.kr(Env.new ([0,1,0], [atk,rel], [1,-1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

//////////////////////////////////////////////////////////////////////
//Use linlin or linexp to scale up the value to the appropriate range:
//KEY HERE IS DATA IS SENT EXPONENTIALLY SO YOU DON'T GET THE HIGH 1 VALUE THAT OFTEN.
//Please consider checking the data trend
(
Pdef(\drone, Pbind(\instrument, \chord,
	\atk, 3,
	\dur, Pfunc{ ~el1.betaHi + rrand(0.25, 1.6)*2},
	\freq, Pfunc{ ~el1.alpha.linlin(0, 0.5, 200, 800)},
	\lowPassFreq, Pfunc{ ~el0.beta + rrand(0.1, 10.0) },
	\pan, Pfunc{ ~el0.alpha}.linlin(0.0, 0.20, -1, 1),
	\amp, 0.45,
	\revMix, Pfunc{~el3.gamma.linlin(0.0, 1, 0.5, 1)}, //one cool trick for when I move my head to give a near 1 value
	\revRoom, Pfunc{~el2.gamma.linlin(0.0, 1, 0.5, 100)} //one cool trick for when I move my head to give a near 1 value
).trace);
)
//try lowering the range of linlin and linexp.
//if you are using expexp or explin rather than linexp or linlin you do higher ranges
//More importantly for dronning sounds (where brain wave is calmer).
(
Pdef(\sinus, Pbind(\instrument, \UCAsaw,
	\atk, 5,
	\release, 4,
	\dur, Pfunc{ ~el1.betaHi.expexp(0.010, 0.8, 1, 2) + rrand(0.7, 0.9)},
	\freq, Pfunc{ ~el0.beta.expexp(0.010, 1, 2000, 4910) + rrand(10, 100) },
	\filterQ, Pfunc{~el2.gamma},
	\amp, 0.6).trace);
)

(
Pdef(\convol, Pbind(\instrument, \UCAconvolution,
	\kernel, Pfunc{~el0.beta.linlin(0.010, 0.30, 20, 500)},
	\atk, 0.1,
	\release, 2,
	\dur, Pfunc{ ~el1.betaHi.expexp(0.010, 0.8, 1, 2) + rrand(0.7, 0.9)},
	\freq, Pfunc{ ~el0.beta.expexp(0.010, 1, 80, 1000) + rrand(10, 100) },
	\filterQ, Pfunc{~el2.gamma},
	\amp, 0.10);
)
)
// You can use comparison of these values.
// For example BetaHi(or mean of three beta values)/Alpha shows the focus of the subject.

(
Pdef(\drop, Pbind(\instrument, \sine,
	\dur, Pfunc{ ~el1.betaHi/~el1.alpha}+2,
	\freq, Pfunc{ (~el2.delta/~el2.gamma) * 40 + rrand(30, 100) },
	\atk, Pfunc{ ~el2.beta/~el3.gamma},
	\release, Pfunc{ ~el0.alpha * ~el0.delta}*2,
	\amp, 0.6).trace);
)
// One example for using all values of one electrode. Check the \freq line.

(
Pdef(\xxv1, Pbind(\instrument, \UCArhodes,
    \amp, 0.50,
	\atk, Pfunc {~el1.delta.linlin(0.010, 0.7, 0.01, 1)} + 3,
	\rel, 2,
	\scale, #[0, 3, 6, 8, 11, 14, 17],
	\degree, Pseq(~el0.asStream.values.linlin(0.010, 0.20, rrand(-12, 0), 7).asInt, inf),
	\dur, Pfunc {~el1.theta.explin(0.010, 0.7, 0.5, 1)},
	\pan, Pfunc {~el1.gamma.explin(0.0, 0.6, -0.20, 0.20)},
).trace);

Pdef(\xxv2, Pbind(\instrument, \UCArhodes,
    \amp, 0.50,
	\atk, Pfunc {~el1.delta.linlin(0.010, 0.7, 0.01, 1)} + 3,
	\rel, Pfunc {~el1.theta.linlin(0.010, 0.7, 0.5, 1)},
	\scale, #[0, 3, 6, 8, 11, 14, 17],
	\degree, Pseq(~el1.asStream.values.linlin(0.010, 0.40, rrand(-6, 0), 7).asInt, inf),
	\dur, 1,
	\pan, Pfunc {~el1.gamma.linlin(0.010, 0.035, -1, 1)},
).trace);
)