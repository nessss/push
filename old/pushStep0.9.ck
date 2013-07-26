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
["606kck","606kckA","707kck","707kckA","808kckT1",
"808kckT2","808kckT3","808kckT4","808kckT5","808kckX1",
"909kckD1","909kckH1","909kckH2", "909kckH3","EPkck","MBkck1",
"MBkck2","MBkck3","MBkck4","MBkck5","SBkck1"] @=> string kck[];
["606snr","606snrA","707snr1","707snr2","808snrT1","808snrT2",
"808snrT3","808snrX1","909snrH1","909snrH2","909snrH3","909snrL1",
"909snrL2","EPsnr1"] @=> string snr[];
["808clpT1","808clpT2","909clp1","909clp2",
"909clp3","EPclp1","SBclp1"] @=> string clp[];
["606chh","606chhA","707chh1","707chhT1",
"808chhT1","808chhX1","808chhX2","909chh1",
"909chh2","909chh3","909chh4","SBchh1","SBchh2"] @=> string chh[];
["606ohh","606ohhA","707ohh","808ohhT1","808ohhT2",
"909ohh1","909ohh2","909ohh3","IMPohh","SBohh","TRXohh"] @=> string ohh[];
/*
["606ltm","606ltmA","707ltm","808mcoX1","909ltm1"] @=> string ltm[];
["606htm","606htmA","707htm","707mtm","909htm1"] @=> string htm[];
*/
["707cb","707rim","707tamb","808cbT1","808cla1",
"808mar","808rim","909rim","EPshk"] @=> string ltm[];
ltm @=> string htm[];
["606cym","606cymA","707csh","707ride","808cym1","808cymT1",
"808cymT2","909csh1", "AMENcsh","EPcsh"] @=> string cym[];
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
    for(0 => int i; i<ltm.cap(); i++) sampRoot + "prc/" + ltm[i] + ".wav" => ltm[i];
    drumSeqs[5].init(0,0,8,4,64, ltm, minPort, moutPort);
    for(0 => int i; i<htm.cap(); i++) sampRoot + "prc/" + htm[i] + ".wav" => htm[i];
    drumSeqs[6].init(0,0,8,4,64, htm, minPort, moutPort);
    for(0 => int i; i<cym.cap(); i++) sampRoot + "cym/" + cym[i] + ".wav" => cym[i];
    drumSeqs[7].init(0,0,8,4,64, cym, minPort, moutPort);
}