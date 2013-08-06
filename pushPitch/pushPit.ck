//Objects
MidiBroadcaster mB;
RhythmClock clock;
Push push;
PStep pstep;

MidiOut mout;
MidiMsg msg;

init();

while(samp=>now);

//Functions
fun void init(){
    mB.init("Ableton Push User Port");
    clock.init();
    mout.open("Ableton Push User Port");
    push.init();
    pstep.init(mB,mout,push,2,1);
    clock.play();
}

fun void midiOut(int d1, int d2, int d3){
    d1 => msg.data1; 
    d2 => msg.data2; 
    d3 => msg.data3;
    mout.send(msg);
}
