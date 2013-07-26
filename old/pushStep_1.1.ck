//Objects
RhythmClock theClock;
theClock.BPM(120);
theClock.stepSize(theClock.sixteenth);
theClock.swingMode(1);
theClock.play();
Push p;
//States
5 => int minPort;
4 => int moutPort;
0 => int cPat;
8 => int nDrums;
0 => int cDrum;
0 => int cPage;
1 => int nPages;
int cSound[nDrums];
for(0 => int i; i<cSound.cap(); i++) 0 => cSound[i];
p.init(moutPort);
PushKnob k[nDrums][nPages][3]; //drum, page#, # of knobs

for(0=>int i;i<nDrums;i++){
    for(0=>int j;j<nPages;j++){
        k[i][j][0].init(0,0,p,minPort,"Trim");
        k[i][j][1].init(1,0,p,minPort,"Pitch");
        k[i][j][2].init(2,0,p,minPort,"Pan");
        k[i][j][0].focus(1);
        k[i][j][1].focus(1);
        k[i][j][2].focus(1);
        spork ~ printValue(k[i][j][0]);
        spork ~ printValue(k[i][j][1]);
        spork ~ printValue(k[i][j][2]);
        /*
        k[i][j][3].init(3,0,p,minPort,"");
        k[i][j][4].init(4,0,p,minPort,"");
        k[i][j][5].init(5,0,p,minPort,"");
        k[i][j][6].init(6,0,p,minPort,"");
        k[i][j][7].init(7,0,p,minPort,"");
        */
    }
}
/*
for(0=>int i;i<nDrums;i++){
    for(0=>int j;j<pages;j++){
        for(0=>int k;k<8;k++){
            k[i][j][k].init(i,0,pD,2,Std.itoa(i));
            k[i][j][k].valueScale(1000);
            k[i][j][k].valueOffset(0);
            k[i][j][k].valueStyle(1);
            1=>k[i][j][k].useValLabel;
            " ms"=>k[i][j][k].valLabel;
            spork~printValue(k[i][j][k]);
        }
    }
}
*/
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
["606chh","606chhA","707chh1","808chhT1",
"808chhX1","808chhX2","909chh1","909chh2",
"909chh3","909chh4","SBchh1","SBchh2"] @=> string chh[];
["606ohh","606ohhA","707ohh","808ohhT1","808ohhT2",
"909ohh1","909ohh2","909ohh3","IMPohh","SBohh","TRXohh"] @=> string ohh[];

["606ltm","606htm","606htmA","606ltmA","707ltm",
"707mtm","707htm","808mcoX1","909ltm1","909htm1",
"707cb","707rim","707tamb","808cbT1","808cla1",
"808mar","808rim","909rim","EPshk"] @=> string ltm[];
["606ltm","606htm","606htmA","606ltmA","707ltm",
"707mtm","707htm","808mcoX1","909ltm1","909htm1",
"707cb","707rim","707tamb","808cbT1","808cla1",
"808mar","808rim","909rim","EPshk"] @=> string htm[];
["606cym","606cymA","707csh","707ride","808cym1","808cymT1",
"808cymT2","909csh1", "AMENcsh","EPcsh"] @=> string cym[];
initSounds();
curDrum(1);
spork ~ curDrumButtons();


while(samp=>now);

//Functions
fun void printValue(PushKnob pK){
    while(pK.moved=>now){
        p.updateDisplay();
        //<<<"Knob "+pK.knob()+": "+pK.pos()>>>;
    }
}
fun void curDrumButtons(){
    MidiIn min;
    MidiMsg msg;
    if(!min.open(minPort)) me.exit();
    while(min=>now){
        while(min.recv(msg)){
            if(msg.data1==0xB0 & msg.data3){
                for(0 => int i; i<8; i++){
                    if(msg.data2==p.sel[0][i]) 
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
    drumSeqs[0].init(0,0,8,4,64, kck, minPort, moutPort, dac.chan(0), dac.chan(1));
    for(0 => int i; i<snr.cap(); i++) sampRoot + "snr/" + snr[i] + ".wav" => snr[i];
    drumSeqs[1].init(0,0,8,4,64, snr, minPort, moutPort, dac.chan(0), dac.chan(1));
    for(0 => int i; i<clp.cap(); i++) sampRoot + "clp/" + clp[i] + ".wav" => clp[i];
    drumSeqs[2].init(0,0,8,4,64, clp, minPort, moutPort, dac.chan(0), dac.chan(1));
    for(0 => int i; i<chh.cap(); i++) sampRoot + "chh/" + chh[i] + ".wav" => chh[i];
    drumSeqs[3].init(0,0,8,4,64, chh, minPort, moutPort, dac.chan(0), dac.chan(1));
    for(0 => int i; i<ohh.cap(); i++) sampRoot + "ohh/" + ohh[i] + ".wav" => ohh[i];
    drumSeqs[4].init(0,0,8,4,64, ohh, minPort, moutPort, dac.chan(0), dac.chan(1));
    for(0 => int i; i<ltm.cap(); i++) sampRoot + "prc/" + ltm[i] + ".wav" => ltm[i];
    drumSeqs[5].init(0,0,8,4,64, ltm, minPort, moutPort, dac.chan(0), dac.chan(1));
    for(0 => int i; i<htm.cap(); i++) sampRoot + "prc/" + htm[i] + ".wav" => htm[i];
    drumSeqs[6].init(0,0,8,4,64, htm, minPort, moutPort, dac.chan(0), dac.chan(1));
    for(0 => int i; i<cym.cap(); i++) sampRoot + "cym/" + cym[i] + ".wav" => cym[i];
    drumSeqs[7].init(0,0,8,4,64, cym, minPort, moutPort, dac.chan(0), dac.chan(1));
}