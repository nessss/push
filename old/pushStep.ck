Tempo theTempo;
RhythmClock theClock;
theClock.BPM(120);
theClock.stepSize(theTempo.sixteenth);
//theClock.patLen(64);
theClock.swingMode(1);
theClock.play();
RStep theRStep;
string mysounds[1];
"Push/sounds/kick.wav" => mysounds[0];
theRStep.init(0,0,8,4,64, mysounds);
spork~midiIn();
theRStep.updateGrid();

while(samp=>now);

//Functions
fun void midiIn(){
    MidiIn min;
    MidiMsg msg;
    if(!min.open(5)) me.exit();
    while(min=>now){
        while(min.recv(msg)){
            if(msg.data1==0x90){
                for(0 => int i; i<theRStep.numSteps(); i++){
                    if(msg.data2 == theRStep.stepccs[i]/* & msg.data3*/){ 
                        if(theRStep.seqs[theRStep.curPat()][i]) 0 => theRStep.seqs[theRStep.curPat()][i];
                        else 1 => theRStep.seqs[theRStep.curPat()][i]; 
                    }
                }
            }
            theRStep.updateGrid();
        }
    }
}