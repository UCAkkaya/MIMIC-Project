// Total of 8 types of data is coming from the master. 7 types of neural oscillations (delta, theta, alpha, betaHigh, beta, betaLow and gamma) for each 4 channel and a BLINK situation which shows if user blinks.
// Neural powers are constrained to 25 microVoltsSquare per Hz and scaled to min 0 max 1.
//Courtesy of Konstantinos the teacher

~eegBook = (); //dictionary for spectral power of eeg data

OSCdef(\eegPower, {
arg msg;
msg = msg.round(0.00001);
~eegBook[ msg[1] ] = ([blink: msg[2], delta:msg[3], theta:msg[4], alpha:msg[5], betaLo:msg[6], beta:msg[7], betaHi:msg[8], gamma:msg[9]]);
}, '/test');

// accessing all the electrode values
~eegBook.keysValuesDo{|key, value| postf("-" ++ [key, value].postln)}

//accessing individual electrode values
(
~eegBook[\el0].postln;
~eegBook[\el1].postln;
~eegBook[\el2].postln;
~eegBook[\el3].postln;
)