//Objects
MidiBroadcaster mB;
RhythmClock clock;
Push push;
PStep pstep;
PushKnob testKnob;
SubSynth syn;
DataEvent pitch, trig;

MidiOut mout;
MidiMsg msg;

init();

while(samp=>now);

//--------Init-------
fun void init(){
    mB.init("Ableton Push User Port");
    clock.init();
    mout.open("Ableton Push User Port");
    push.init();
	testKnob.init(0,push,mB,"PatLen");
	testKnob.focus(1);
    pstep.init(mB,mout,push,2,1);
	spork~knobLoop(testKnob);
    clock.play();
    clock.patLen(8);
    syn.init();
    1.0 => trig.f;
    spork ~ play();
    spork ~ pitchLoop(); spork ~ trigLoop();
}

//Functions
fun void play(){
    while(clock.step => now){
        if(pstep.noteOn[pstep.pPlay][clock.step.i]){
            pstep.pitches[pstep.pPlay][clock.step.i] => pitch.f;
            pitch.broadcast();
            if(!pstep.tie[pstep.pPlay][clock.step.i]){
                trig.broadcast();
			}
        }
    }
}

fun void knobLoop(PushKnob pK){
	pK.displayUpdate();
	push.updateDisplay();
	while(pK.moved=>now){
		pK.displayUpdate();
		push.updateDisplay();
	}
}
	
fun void pitchLoop(){
    while(pitch => now) syn.pitchIt(pitch.f);
}

fun void trigLoop(){
    while(trig => now) syn.trigIt();
}

fun void midiOut(int d1, int d2, int d3){
    d1 => msg.data1; 
    d2 => msg.data2; 
    d3 => msg.data3;
    mout.send(msg);
}

fun float cvGateOn(){
	1.0=>gateOut.next;
	return 1.0;
}

fun float cvGateOff(){
	0.0=>gateOut.next;
	return 0.0;
}

fun float cvPitch(float p){
	CV.mtocv(p)=>pitchOut.next;
	return CV.mtocv(p);
}
