//Code for client of MIMIC.

//boiler values of electrode1 ONLY for practise!

/*(
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
)*/


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

// Chat
~chatter = Chatter(~addrBook);

~win.layout.add(VLayout(StaticText().string_("Chatter"), ~textField = TextField(), ~textView = TextView()));
~textField.action_({|v| ~chatter.send(v.string); v.string = "" });
// to get updates, just add a dependant
~chatter.addDependant({|chatter, what, who, chat|
	chat = chat.asString;
	{ ~textView.string_(who ++ ": " ++ chat ++ "\n" ++ ~textView.string) }.defer;
	// Shout
	if (chat.beginsWith(NMLShout.tag)) {
		defer {
			NMLShout((chat.drop(NMLShout.tag.size).reject(_ == $\n) + ("/" ++ who)));
			{~win.front;}.defer(0.1);
		}
	};
});
s.reboot;
~objSpace = OSCObjectSpace(~addrBook, true);
)

// cleanup
~chatter.free; ~win.close;

~objSpace = OSCObjectSpace(~addrBook, true);
~event[\el0].asEvent.alpha// use singular values like this.

//For example, you can assign the electrode on a variable and access it this way.
~el1 = ~event[\el0].asEvent.asStream.values; //use all event as array.

//GUI occasionally check if you are getting values or not.
(

w = Window("MIMIC", Rect(100,100, 285, 400)).front.alwaysOnTop_(true);
w.view.decorator = FlowLayout( w.view.bounds, 5@5, 15@5 );
(~sliders = {Slider(w)} !8);
StaticText(w,275@20).string_("Blink    Delta   Theta   Alpha   BetaL   Beta   BetaH   Gam");
PdefAllGui(16, w);



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


//Recieving the values

~objSpace[\event][\el0]; //Tdef ?


// Boiler code on using the brainwave values.

(
SynthDef(\sine, {arg freq = 120, mod = 0.1, release = 0.25, amp = 0.1, atk = 0.01;
	var sig = Mix.ar( { SinOsc.ar(freq.lag(0.3), 0, SinOsc.ar(mod).range(0.1, 0.8)) }!8) * EnvGen.ar(Env.perc(atk, release), doneAction:2);
	sig = LeakDC.ar(sig);
	ReplaceOut.ar(0, sig * amp);
}).add;

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


