(
Window.closeAll;
w = Window("EEGdata", Rect(1200, 100, 630, 690))
.front
.alwaysOnTop_(true);

~deltaSlider1= EZSlider(w, Rect(20, 20, 40, 300) ,"   Delta1" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~deltaSlider2 = EZSlider(w, Rect(70, 20, 40, 300) ,"   Delta2" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~deltaSlider3 = EZSlider(w, Rect(120, 20, 40, 300) ,"   Delta3" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~deltaSlider4 = EZSlider(w, Rect(170, 20, 40, 300) ,"   Delta4" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));

~thetaSlider1 = EZSlider(w, Rect(20, 350, 40, 300) ,"  Theta1" ,[0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~thetaSlider2 = EZSlider(w, Rect(70, 350, 40, 300) ,"  Theta2" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~thetaSlider3 = EZSlider(w, Rect(120, 350, 40, 300) ,"  Theta3" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~thetaSlider4 = EZSlider(w, Rect(170, 350, 40, 300) ,"  Theta4" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));

~alphaSlider1 = EZSlider(w, Rect(220, 20, 40, 300) ," Alpha1" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~alphaSlider2 = EZSlider(w, Rect(270, 20, 40, 300) ," Alpha2" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~alphaSlider3 = EZSlider(w, Rect(320, 20, 40, 300) ," Alpha3" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~alphaSlider4 = EZSlider(w, Rect(370, 20, 40, 300) ," Alpha4" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));

~gammaSlider1 = EZSlider(w, Rect(420, 20, 40, 300) ,"Gamma1" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~gammaSlider2 = EZSlider(w, Rect(470, 20, 40, 300) ,"Gamma2" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~gammaSlider3 = EZSlider(w, Rect(520, 20, 40, 300) ,"Gamma3" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~gammaSlider4 = EZSlider(w, Rect(570, 20, 40, 300) ,"Gamma4" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));

~betaSlider1 = EZSlider(w, Rect(220, 350, 40, 300) ,"  Beta1" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~betaSlider2 = EZSlider(w, Rect(270, 350, 40, 300) ,"  Beta2" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~betaSlider3 = EZSlider(w, Rect(320, 350, 40, 300) ,"  Beta3" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));
~betaSlider4 = EZSlider(w, Rect(370, 350, 40, 300) ,"  Beta4" , [0, 20, 0.01, 0], numberWidth:60,layout:\vert)
.setColors(Color.clear,Color.black)
.font_(Font("Helvetica",11));


~cue = Routine {
	loop{
	~deltaSlider1.value_(~eegBook[\el0][3].linexp(0.0, 1.0, 1, 20));
	~deltaSlider2.value_(~eegBook[\el1][3].linexp(0.0, 1.0, 1, 20));
	~deltaSlider3.value_(~eegBook[\el2][3].linexp(0.0, 1.0, 1, 20));
	~deltaSlider4.value_(~eegBook[\el3][3].linexp(0.0, 1.0, 1, 20));

    ~thetaSlider1.value_(~eegBook[\el0][5].linexp(0.0, 1.0, 1, 20));
	~thetaSlider2.value_(~eegBook[\el1][5].linexp(0.0, 1.0, 1, 20));
	~thetaSlider3.value_(~eegBook[\el2][5].linexp(0.0, 1.0, 1, 20));
	~thetaSlider4.value_(~eegBook[\el3][5].linexp(0.0, 1.0, 1, 20));

	~alphaSlider1.value_(~eegBook[\el0][7].linexp(0.0, 1.0, 1, 20));
	~alphaSlider2.value_(~eegBook[\el1][7].linexp(0.0, 1.0, 1, 20));
	~alphaSlider3.value_(~eegBook[\el2][7].linexp(0.0, 1.0, 1, 20));
	~alphaSlider4.value_(~eegBook[\el3][7].linexp(0.0, 1.0, 1, 20));

	~betaSlider1.value_(~eegBook[\el0][11].linexp(0.0, 1.0, 1, 20));
	~betaSlider2.value_(~eegBook[\el1][11].linexp(0.0, 1.0, 1, 20));
	~betaSlider3.value_(~eegBook[\el2][11].linexp(0.0, 1.0, 1, 20));
	~betaSlider4.value_(~eegBook[\el3][11].linexp(0.0, 1.0, 1, 20));

	~gammaSlider1.value_(~eegBook[\el0][15].linexp(0.0, 1.0, 1, 20));
	~gammaSlider2.value_(~eegBook[\el1][15].linexp(0.0, 1.0, 1, 20));
	~gammaSlider3.value_(~eegBook[\el2][15].linexp(0.0, 1.0, 1, 20));
	~gammaSlider4.value_(~eegBook[\el3][15].linexp(0.0, 1.0, 1, 20));
	0.025.wait;
	}
};

//start the GUI clock
~cue.play(AppClock);

)


// Stop
~cue.stop(AppClock);