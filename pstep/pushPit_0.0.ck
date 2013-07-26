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
    mB.init();
    clock.init();
    moutInit() @=> mout;
    push.init();
    pstep.init(mB,mout,2,1);
    clock.play();
}

fun MidiOut moutInit(){
    MidiOut moutCheck[16];
    for(0 => int i; i<moutCheck.cap(); i++){
        moutCheck[i].printerr(0);
        if(moutCheck[i].open(i)){
            if(moutCheck[i].name()=="Ableton Push User Port"){
                <<<"Ablemout!">>>;
                return moutCheck[i];
            }       
        }else return null;
    }
}

fun void midiOut(int d1, int d2, int d3){
    d1 => msg.data1; 
    d2 => msg.data2; 
    d3 => msg.data3;
    mout.send(msg);
}