//Objects
RhythmClock theClock;
MidiBroadcaster mB;
mB.init();
theClock.init();
Push thePush;
//States
8 => int nDrums;
0 => int cDrum => int cPat => int cPage;
1 => int nPages;
1 => int dim;
int cSound[nDrums];
for(0 => int i; i<cSound.cap(); i++) 0 => cSound[i];

5 => int muteColor;
MidiOut mout;
MidiMsg msg;
Pan2 mBus;
mBus.left => dac.chan(0);
mBus.right => dac.chan(1);

moutInit()@=>mout;
thePush.init();
//Knobs
PushKnob knob[nDrums][nPages][4]; //drum, page#, # of knobs
PushKnob mGainKnob;
mGainKnob.init(8,thePush,mB,"Mst Gain");
mGainKnob.cursorStyle(3);
mGainKnob.setLabelPos(7,0);
mGainKnob.setValuePos(7,1);
mGainKnob.setCursorPos(7,2);
mGainKnob.focus(1);
PushKnob tempoKnob;
tempoKnob.init(9,thePush,mB,"Tempo");
tempoKnob.cursorStyle(3);
tempoKnob.valueOffset(50);
tempoKnob.valueScale(400);
tempoKnob.incrementAmt(0.0025);
PushKnob swingKnob;
swingKnob.init(10,thePush,mB,"Swing");
swingKnob.cursorStyle(3);


RStep drumSeqs[8];
for(0=>int i;i<nDrums;i++){
    drumSeqs[i].connectMaster(mBus.left,mBus.right);
    drumSeqs[i].connectQueue(dac.chan(2),dac.chan(3));
    for(0=>int j;j<nPages;j++){
        knob[i][j][0].init(0,thePush,mB,"Gain");
        knob[i][j][0].cursorStyle(3);
        knob[i][j][1].init(1,thePush,mB,"Pitch");
        knob[i][j][1].cursorStyle(2);
        knob[i][j][1].valueScale(2);
        knob[i][j][2].init(2,thePush,mB,"Pan");
        knob[i][j][2].cursorStyle(2);
        knob[i][j][2].valueOffset(-1);
        knob[i][j][2].valueScale(2);
        knob[i][j][3].init(3,thePush,mB,"Sample");
        knob[i][j][3].displaysValue(0);
        knob[i][j][3].textPosY(1);
        knob[i][j][3].cursorStyle(2);
        knob[i][j][3].stringListMode(1);
        spork ~ sampleChange(knob[i][j][3], drumSeqs[i]);
        spork ~ printValue(knob[i][j][0]);
        spork ~ printValue(knob[i][j][1]);
        spork ~ printValue(knob[i][j][2]);
        spork ~ printValue(knob[i][j][3]);
    }
}
page(cDrum,cPage);
thePush.updateDisplay();

//Samples 
"Push/sounds/" => string sampRoot;
["606kck","606kckA","707kck","707kckA","808kckT1",
"808kckT2","808kckT3","808kckT4","808kckT5","808kckX1",
"909kckD1","909kckH1","909kckH2", "909kckH3","EPkck","MBkck1",
"MBkck2","MBkck3","MBkck4","MBkck5","SBkck1"] @=> string nKck[];
["606snr","606snrA","707snr1","707snr2","808snrT1","808snrT2",
"808snrT3","808snrX1","909snrH1","909snrH2","909snrH3","909snrL1",
"909snrL2","EPsnr1"] @=> string nSnr[];
["808clpT1","808clpT2","909clp1","909clp2",
"909clp3","EPclp1","SBclp1"] @=> string nClp[];
["606chh","606chhA","707chh1","808chhT1",
"808chhX1","808chhX2","909chh1","909chh2",
"909chh3","909chh4","SBchh1","SBchh2"] @=> string nChh[];
["606ohh","606ohhA","707ohh","808ohhT1","808ohhT2",
"909ohh1","909ohh2","909ohh3","IMPohh","SBohh","TRXohh"] @=> string nOhh[];

["606ltm","606htm","606htmA","606ltmA","707ltm",
"707mtm","707htm","808mcoX1","909ltm1","909htm1",
"707cb","707rim","707tamb","808cbT1","808cla1",
"808mar","808rim","909rim","EPshk"] @=> string nLtm[];
["606ltm","606htm","606htmA","606ltmA","707ltm",
"707mtm","707htm","808mcoX1","909ltm1","909htm1",
"707cb","707rim","707tamb","808cbT1","808cla1",
"808mar","808rim","909rim","EPshk"] @=> string nHtm[];
["606cym","606cymA","707csh","707ride","808cym1","808cymT1",
"808cymT2","909csh1", "AMENcsh","EPcsh"] @=> string nCym[];

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

knob[0][0][3].text(nKck[0]);
knob[0][0][3].stringList(nKck);

knob[1][0][3].text(nSnr[0]);
knob[1][0][3].stringList(nSnr);

knob[2][0][3].text(nClp[0]);
knob[2][0][3].stringList(nClp);

knob[3][0][3].text(nChh[0]);
knob[3][0][3].stringList(nChh);

knob[4][0][3].text(nOhh[0]);
knob[4][0][3].stringList(nOhh);

knob[5][0][3].text(nLtm[0]);
knob[5][0][3].stringList(nLtm);

knob[6][0][3].text(nHtm[0]);
knob[6][0][3].stringList(nHtm);

knob[7][0][3].text(nCym[0]);
knob[7][0][3].stringList(nCym);

spork~playButton();
spork~printAuxKnob(mGainKnob);
spork~hideAuxKnob(mGainKnob);
spork~printAuxKnob(tempoKnob);
spork~hideAuxKnob(tempoKnob);
spork~printAuxKnob(swingKnob);
spork~hideAuxKnob(swingKnob);
//PUT RAINBOW IN PUSH CLASS
int rainbow[8][3]; 05=>rainbow[0][0]; 06=>rainbow[0][1];
07=>rainbow[0][2]; 09=>rainbow[1][0]; 10=>rainbow[1][1];
11=>rainbow[1][2]; 13=>rainbow[2][0]; 14=>rainbow[2][1];
15=>rainbow[2][2]; 21=>rainbow[3][0]; 22=>rainbow[3][1];
23=>rainbow[3][2]; 29=>rainbow[4][0]; 30=>rainbow[4][1];
31=>rainbow[4][2]; 41=>rainbow[5][0]; 42=>rainbow[5][1];
43=>rainbow[5][2]; 45=>rainbow[6][0]; 46=>rainbow[6][1];
47=>rainbow[6][2]; 49=>rainbow[7][0]; 50=>rainbow[7][1];
51=>rainbow[7][2];


for(0=>int i;i<8;i++){
    lightOn(i,1,rainbow[i][1]);
    spork~knobValue(knob[i][0][0],drumSeqs[i],0);
    spork~knobValue(knob[i][0][1],drumSeqs[i],1);
    spork~knobValue(knob[i][0][2],drumSeqs[i],2);
}

spork~auxKnobValue(mGainKnob,0);
spork~auxKnobValue(tempoKnob,1);
spork~auxKnobValue(swingKnob,2);

initSounds();
curDrum(1);
spork ~ curDrumButtons();
spork ~ muteButtons();
curDrum(0);
page(0,0);


while(samp=>now);

//Functions
fun MidiOut moutInit(){
    MidiOut moutCheck[16];
    for(0 => int i; i<moutCheck.cap(); i++){
        moutCheck[i].printerr(0);
        if(moutCheck[i].open(i)){
            if(moutCheck[i].name()=="Ableton Push User Port"){
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

fun void muteLEDs(){
    for(0 => int i; i<8; i++){
        if(drumSeqs[i].mute()==0){
            midiOut(0xB0, thePush.sel[i][0], 0);
        }
        else midiOut(0xB0, thePush.sel[i][0], muteColor);
    }
}

fun void curDrumLEDs(){
    for(0 => int i; i<8; i++){
        if(i == cDrum){
            midiOut(0xB0, thePush.sel[i][1], rainbow[cDrum][1]);
        }
    }
}

fun void lightOn(int x, int y, int c){
    0xB0 => msg.data1;
    thePush.sel[x][y] => msg.data2;
    c => msg.data3;
    mout.send(msg);
}

fun void lightOff(int x, int y){
    0xB0 => msg.data1;
    thePush.sel[x][y] => msg.data2;
    0 => msg.data3;
    mout.send(msg);
}


fun void sampleChange(PushKnob pk, RStep r){
    while(pk.moved => now) r.curSound(pk.stringNumber());
}

fun void unfocusPages(){ 
    for(0=>int i;i<nDrums;i++){
        for(0=>int j; j<nPages; j++){
            for(0 => int l; l<4; l++){
                knob[i][j][l].focus(0);
            }
        }
    }
}

fun void page(int d, int pg){
    while(pg>=nPages)nPages-=>pg;
    while(pg<0)nPages+=>pg;
    pg=>cPage;
    //<<<"Page "+myPage>>>;
    for(0=>int i;i<nDrums;i++){
        for(0=>int j; j<nPages; j++){
            for(0 => int l; l<4; l++){
                knob[i][j][l].focus(0);
            }
        }
    }
    for(0=>int i;i<4;i++){ //4 is number of knobs
        knob[d][pg][i].focus(1);
    }
    thePush.updateDisplay();
}

fun void printAuxKnob(PushKnob pK){
    while(pK.touchOn=>now){
        unfocusPages();
        pK.focus(1);
        pK.displayUpdate();
        thePush.updateDisplay();
    }
}

fun void hideAuxKnob(PushKnob pK){
    while(pK.touchOff=>now){
        pK.focus(0);
        page(cDrum,cPage);
        pK.displayUpdate();
        thePush.updateDisplay();
    }
}

fun void printValue(PushKnob pK){
    while(pK.moved=>now){
        pK.displayUpdate();
        thePush.updateDisplay();
        //<<<"Knob "+pK.knob()+": "+pK.pos()>>>;
    }
}

fun void auxKnobValue(PushKnob pK, int mode){ //for master gain knob
    while(pK.moved=>now){
        if(mode==0) pK.value() => mBus.gain;
        else if(mode==1) theClock.BPM(pK.value());
        else if(mode==2) theClock.swingAmt(pK.value());
        pK.displayUpdate();
        thePush.updateDisplay();
    }
}

fun void knobValue(PushKnob pK,float f){
    while(pK.moved=>now) pK.value() => f;
}

fun void knobValue(PushKnob pK,int a){
    while(pK.moved=>now) Math.round(pK.value())$int=>a;
}

fun void knobValue(PushKnob pK,RStep rS,int mode){
    while(pK.moved=>now){
        if(mode==0) rS.gain(pK.pos());
        else if(mode==1) rS.rate(pK.pos());
        else if(mode==2) rS.pan(pK.pos());
    }       
}

fun void playButton(){
    MidiMsg msg;
    while(mB.mev=>now){
        mB.mev.msg @=> msg;
        if(msg.data1==0xB0 & msg.data2==thePush.bcol0[11] & msg.data3){
            if(msg.data3) theClock.play();
        }
    }
}

fun void muteButtons(){
    MidiMsg msg;
    while(mB.mev=>now){
        mB.mev.msg @=> msg;
        if(msg.data1==0xB0 & msg.data3){
            for(0 => int i; i<8; i++){
                if(msg.data2==thePush.sel[i][0]){
                    if(drumSeqs[i].mute() == 1){
                        drumSeqs[i].mute(0);
                        lightOff(i,0);
                        //<<<"unMute">>>;
                        //<<<drumSeqs[i].mute()>>>;
                    }
                    else{
                        drumSeqs[i].mute(1);
                        lightOn(i,0,4);
                        //<<<drumSeqs[i].mute()>>>;
                        //<<<"mute">>>;
                    }
                }
            }
        }
    }
}

fun void curDrumButtons(){
    MidiMsg msg;
    while(mB.mev=>now){
        mB.mev.msg @=> msg;
        if(msg.data1==0xB0 & msg.data3){
            for(0 => int i; i<8; i++){
                if(msg.data2==thePush.sel[i][1]){
                    lightOn(cDrum,1,rainbow[cDrum][1]);
                    drumSeqs[cDrum].cue(0);
                    curDrum(i);
                    drumSeqs[cDrum].cue(1);
                    page(cDrum,cPage);
                    lightOn(cDrum,1,rainbow[cDrum][0]);
                }
            }
            drumSeqs[cDrum].updateGrid();
        }
    }
}

fun int curDrum(){ return cDrum; }
fun int curDrum(int nd){
    nd => cDrum;
    for(0 => int i; i<nDrums; i++){
        if(i != cDrum) drumSeqs[i].focus(0);
        else drumSeqs[i].focus(1);
    }
    return cDrum;
}

fun void initSounds(){
    for(0 => int i; i<kck.cap(); i++) sampRoot + "kck/" + kck[i] + ".wav" => kck[i];
    drumSeqs[0].init(mB,mout,kck);
    drumSeqs[0].onColor(rainbow[0][dim]);
    drumSeqs[0].cursorColor(rainbow[3][0]);
    drumSeqs[0].highlightColor(rainbow[2][0]);
    for(0 => int i; i<snr.cap(); i++) sampRoot + "snr/" + snr[i] + ".wav" => snr[i];
    drumSeqs[1].init(mB,mout,snr);
    drumSeqs[1].onColor(rainbow[1][dim]);
    drumSeqs[1].cursorColor(rainbow[4][0]);
    drumSeqs[1].highlightColor(rainbow[3][0]);
    for(0 => int i; i<clp.cap(); i++) sampRoot + "clp/" + clp[i] + ".wav" => clp[i];
    drumSeqs[2].init(mB,mout,clp);
    drumSeqs[2].onColor(rainbow[2][dim]);
    drumSeqs[2].cursorColor(rainbow[5][0]);
    drumSeqs[2].highlightColor(rainbow[4][0]);
    for(0 => int i; i<chh.cap(); i++) sampRoot + "chh/" + chh[i] + ".wav" => chh[i];
    drumSeqs[3].init(mB,mout,chh);
    drumSeqs[3].onColor(rainbow[3][dim]);
    drumSeqs[3].cursorColor(rainbow[6][0]);
    drumSeqs[3].highlightColor(rainbow[5][0]);
    for(0 => int i; i<ohh.cap(); i++) sampRoot + "ohh/" + ohh[i] + ".wav" => ohh[i];
    drumSeqs[4].init(mB,mout,ohh);
    drumSeqs[4].onColor(rainbow[4][dim]);
    drumSeqs[4].cursorColor(rainbow[7][0]);
    drumSeqs[4].highlightColor(rainbow[6][0]);
    for(0 => int i; i<ltm.cap(); i++) sampRoot + "prc/" + ltm[i] + ".wav" => ltm[i];
    drumSeqs[5].init(mB,mout,ltm);
    drumSeqs[5].onColor(rainbow[5][dim]);
    drumSeqs[5].cursorColor(rainbow[0][0]);
    drumSeqs[5].highlightColor(rainbow[7][0]);
    for(0 => int i; i<htm.cap(); i++) sampRoot + "prc/" + htm[i] + ".wav" => htm[i];
    drumSeqs[6].init(mB,mout,htm);
    drumSeqs[6].onColor(rainbow[6][dim]);
    drumSeqs[6].cursorColor(rainbow[1][0]);
    drumSeqs[6].highlightColor(rainbow[0][0]);
    for(0 => int i; i<cym.cap(); i++) sampRoot + "cym/" + cym[i] + ".wav" => cym[i];
    drumSeqs[7].init(mB,mout,cym);
    drumSeqs[7].onColor(rainbow[7][dim]);
    drumSeqs[7].cursorColor(rainbow[2][0]);
    drumSeqs[7].highlightColor(rainbow[1][0]);
}
