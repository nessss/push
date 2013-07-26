RhythmClock theClock;
theClock.BPM(120);
theClock.stepSize(theClock.sixteenth);
//theClock.patLen(64);
theClock.swingMode(1);
theClock.play();
PushCCs thePush;
RStep theRStep;
string mysounds[1];
"Push/sounds/kick.wav" => mysounds[0];
theRStep.init(4,4,4,4,16, mysounds);
//spork~midiIn();
theRStep.updateGrid();
theRStep.padOnColor(46);
//1.0/127.0 => float midiNorm;

//spork ~ midiIn();

while(samp=>now);

/*
//Functions
fun void midiIn(){
    MidiIn min;
    MidiMsg msg;
    if(!min.open(5)) me.exit();
    while(min=>now){
        while(min.recv(msg)){
            //if(msg.data1 == 0xB0){
            if(msg.data2 == thePush.knobs[0]){
                theRStep.gain(msg.data3);
            }
            // }
        }
    } 
}
*/