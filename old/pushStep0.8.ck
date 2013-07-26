//Objects
RhythmClock theClock;
theClock.BPM(120);
theClock.stepSize(theClock.sixteenth);
theClock.swingMode(1);
theClock.play();
PushCCs thePush;
//States
3 => int minPort;
3 => int moutPort;
0 => int cPage;
0 => int cPat;
8 => int nDrums;
0 => int cDrum;
int cSound[nDrums];
for(0 => int i; i<cSound.cap(); i++) 0 => cSound[i];
//Midi


//PushKnob page0[8][8]; //gain, pan
RStep drumSeqs[8];
//Samples 
"Push/sounds/" => string sampRoot;
["808kckD1", "808kckD2", "909kckD1"] @=> string kck[];
["808snrT1", "909snrH1"] @=> string snr[];
["808clpT1","909clp1"] @=> string clp[];
["808chhT1","909chh1"] @=> string chh[];
["808ohhT1","909ohh1"] @=> string ohh[];
["808ltmT1","909ltm1"] @=> string ltm[];
["808htmT1","909htm1"] @=> string htm[];
["808cymT1","909crs1", "909cym1"] @=> string cym[];
initSounds();
curDrum(1);
spork ~ curDrumButtons();


while(samp=>now);

//Functions
fun void curDrumButtons(){
    MidiIn min;
    MidiMsg msg;
    if(!min.open(minPort)) me.exit();
    while(min=>now){
        while(min.recv(msg)){
            if(msg.data1==0xB0 & msg.data3){
                for(0 => int i; i<8; i++){
                    if(msg.data2==thePush.sel[0][i]) 
                        curDrum(i);
                }
            }
        }
    }
}

fun int curDrum(){
    return cDrum;
}

fun int curDrum(int nd){
    nd => cDrum;
    for(0 => int i; i<nDrums; i++){
        if(i != cDrum) drumSeqs[i].inFocus(0);
        else drumSeqs[i].inFocus(1);
    }
    return cDrum;
}

fun void initSounds(){
    for(0 => int i; i<kck.cap(); i++) sampRoot + "kck/" + kck[i] + ".wav" => kck[i];
    drumSeqs[0].init(0,0,8,4,64, kck, minPort, moutPort);
    for(0 => int i; i<snr.cap(); i++) sampRoot + "snr/" + snr[i] + ".wav" => snr[i];
    drumSeqs[1].init(0,0,8,4,64, snr, minPort, moutPort);
    for(0 => int i; i<clp.cap(); i++) sampRoot + "clp/" + clp[i] + ".wav" => clp[i];
    drumSeqs[2].init(0,0,8,4,64, clp, minPort, moutPort);
    for(0 => int i; i<chh.cap(); i++) sampRoot + "chh/" + chh[i] + ".wav" => chh[i];
    drumSeqs[3].init(0,0,8,4,64, chh, minPort, moutPort);
    for(0 => int i; i<ohh.cap(); i++) sampRoot + "ohh/" + ohh[i] + ".wav" => ohh[i];
    drumSeqs[4].init(0,0,8,4,64, ohh, minPort, moutPort);
    for(0 => int i; i<ltm.cap(); i++) sampRoot + "ltm/" + ltm[i] + ".wav" => ltm[i];
    drumSeqs[5].init(0,0,8,4,64, ltm, minPort, moutPort);
    for(0 => int i; i<htm.cap(); i++) sampRoot + "htm/" + htm[i] + ".wav" => htm[i];
    drumSeqs[6].init(0,0,8,4,64, htm, minPort, moutPort);
    for(0 => int i; i<cym.cap(); i++) sampRoot + "cym/" + cym[i] + ".wav" => cym[i];
    drumSeqs[7].init(0,0,8,4,64, cym, minPort, moutPort);
}