//Code for MIMIC client.

//pseudo osc input message.
/*(
~msg = 4.do{Array.fill(8, {rrand(0.0, 1.0).postln})};
NetAddr.localAddr.sendMsg('/band', "el", ~msg);
)
*/

// 1- Communication with Master.
(
~objSpace = OSCObjectSpace(~addrBook, true);

Tdef(\eegCounter, {
	loop{
	~event = ~objSpace[\event];
	~el0 = ~event[\el0].asEvent;
	~el1 = ~event[\el1].asEvent;
	~el2 = ~event[\el2].asEvent;
	~el3 = ~event[\el3].asEvent;
	0.10.wait;
} }).play;

CmdPeriod.add({ "You have deactivated Tdef, rerun now".warn;});

)

// Maybe use of SkipJack will help cmd period issue ?

/*w = SkipJack({
	~el0 = ~event[\el0].asEvent;
	~el1 = ~event[\el1].asEvent;
	~el2 = ~event[\el2].asEvent;
	~el3 = ~event[\el3].asEvent; }, 0.10, name: "eegCounter");
)*/

// 2 - GUI
(
~rgui = EnvirGui(~event, bounds: Rect(100,100,750)); //shows all the vales as a string
~rgui.parent.name = "electrode";
~rgui.parent.alwaysOnTop_(true);

PdefAllGui(20, bounds:Rect(100,100,200,300));
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

SynthDef(\chord,
    { |out=0, freq=440, amp=0.1, pan=0 atk=0.5 rel=6 sus = 0.5|
        var env;
        env = EnvGen.kr(Env([0,1,1,0,], [atk,sus,rel], [1,0,-1]), doneAction:2) ;
        Out.ar(out, Splay.ar(Saw.ar(freq, 0.2))* amp)
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
)

//////////////////////////////////////////////////////////////////////
//Use linlin or linexp to scale up the value to the appropriate range:
//KEY HERE IS DATA IS SENT EXPONENTIALLY SO YOU DON'T GET THE HIGH 1 VALUE THAT OFTEN.
//Please consider checking the data trend
(
Pdef(\x, Pbind(\instrument, \chord,
	\atk, 1,
	\dur, Pfunc{ ~el1.betaHi + rrand(0.25, 1.6)},
	\freq, Pfunc{ ~el1.alpha.linlin(0, 0.5, 80, 200)},
	\trigFreq, Pfunc{ ~el0.beta + rrand(0.1, 10.0) },
	\crushRate, Pfunc{ ~el0.alpha},
	\amp, Pfunc{ ~el1.gamma.max(0.5) / 2},
).trace);
)
//try lowering the range of linlin and linexp.
//More importantly for dronning sounds (where brain wave is calmer).
(
Pdef(\drone, Pbind(\instrument, \UCAsaw,
	\atk, 5,
	\release, 4,
	\dur, Pfunc{ ~el1.betaHi.linexp(0.010, 0.25, 1, 2) + rrand(0.7, 0.9)},
	\freq, Pfunc{ ~el0.beta.linexp(0.010, 0.5, 200, 910) + rrand(10, 100) },
	\filterQ, Pfunc{~el2.gamma},
	\amp, Pfunc{ ~el0.gamma.max(0.9)}).trace);
)
// You can use comparison of these values.
// For example BetaHi(or mean of three beta values)/Alpha shows the focus of the subject.
(
Pdef(\drone2, Pbind(\instrument, \UCAsaw,
	\dur, Pfunc{ ~el1.betaHi/~el1.alpha}*1.25,
	\freq, Pfunc{ (~el2.delta/~el2.gamma) * 40 + rrand(10, 100) },
	\atk, Pfunc{ ~el2.beta/~el3.gamma},
	\release, Pfunc{ ~el0.alpha * ~el0.delta},
	\legato, 1,
	\amp, Pfunc{ ~el0.gamma.max(0.9) + 0.1}).trace);
)
// One example for using all values of one electrode. Check the \freq line.
(
Pdef(\xx, Pbind(\instrument, \UCArhodes,
    \amp, 0.50,
	\atk, Pfunc {~el1.delta.linlin(0.010, 0.7, 0.01, 1)} + 3,
	\rel, 2,
	\scale, #[0, 3, 6, 8, 11, 14, 17],
	\degree, Pseq(~el0.asStream.values.linlin(0.010, 0.20, rrand(-12, 0), 7).asInt, inf),
	\dur, Pfunc {~el1.theta.linlin(0.010, 0.7, 0.5, 1)},
).trace;
)
)