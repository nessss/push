//Objects
MidiBroadcaster mB;
RhythmClock clock;
Push push;
PStep pstep;
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
    pstep.init(mB,mout,push,2,1);
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
            trig.broadcast();
            <<<"pitch!",trig.f>>>;
            if(!pstep.tie[pstep.pPlay][clock.step.i]){
                trig.broadcast();
                <<<"trig!!">>>;
            }else <<<pstep.tie[pstep.pPlay][clock.step.i]>>>;
        }
    }
}

fun void pitchLoop(){
    while(pitch => now) syn.pitchIt(pitch.f);
}

fun void trigLoop(){
    while(trig => now) syn.gateIt();
}

fun void midiOut(int d1, int d2, int d3){
    d1 => msg.data1; 
    d2 => msg.data2; 
    d3 => msg.data3;
    mout.send(msg);
}
