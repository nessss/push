//Objects
MidiBroadcaster mB;
RhythmClock clock;
Push push;
RStep rstep[8];

//Variables
int nDrums, cDrum, cPat, cPage, nPages, dim, muteColor;

//Midi
MidiOut mout;
MidiMsg msg;
//Master Bus Signal Chain
Pan2 mBus;

//Knobs
int nKnobs;
PushKnob knob[][][];

init();
<<<"pushStep is ready to go!","">>>;

//Loop
while(samp=>now);

//--------------------------Functions--------------------------
fun void init(){
	mB.init("Ableton Push User Port");
	clock.init();
	push.init();
	8 => nDrums;
	0 => cDrum => cPat => cPage;
	1 => nPages => dim;
	new int[nDrums]@=>cSound;
	for(int i; i<cSound.cap(); i++) 0 => cSound[i];
	5 => muteColor;
	mout.open("Ableton Push User Port");
	0.8=> mBus.gain;
	mBus.left => dac.chan(0);
	mBus.right => dac.chan(1);
	5 => nKnobs;
	new PushKnob[nDrums][nPages][nKnobs]@=>knob;

	for(0=>int i;i<nDrums;i++){
		//Connect
		rstep[i].connectMaster(mBus.left,mBus.right);
		rstep[i].connectQueue(dac.chan(2),dac.chan(3));
		spork~knobValue(knob[i][0][0],rstep[i],0);
		spork~knobValue(knob[i][0][1],rstep[i],1);
		spork~knobValue(knob[i][0][2],rstep[i],2);
		spork~knobValueOffTouch(knob[i][0][4], 0);
		
		for(0=>int j;j<nPages;j++){
			knob[i][j][0].init(0,push,mB,"Gain");
			knob[i][j][0].cursorStyle(3);
			knob[i][j][1].init(1,push,mB,"Pitch");
			knob[i][j][1].cursorStyle(2);
			knob[i][j][1].valueScale(2);
			knob[i][j][2].init(2,push,mB,"Pan");
			knob[i][j][2].cursorStyle(2);
			knob[i][j][2].valueOffset(-1);
			knob[i][j][2].valueScale(2);
			knob[i][j][3].init(3,push,mB,"Sample");
			knob[i][j][3].displaysValue(0);
			knob[i][j][3].textPosY(1);
			knob[i][j][3].cursorStyle(2);
			knob[i][j][3].stringListMode(1);
			knob[i][j][4].init(4,push,mB,"Pat Len");
			knob[i][j][4].cursorStyle(2);
			knob[i][j][4].valueOffset(1);
			knob[i][j][4].valueScale(63);
			knob[i][j][4].incrementAmt(1.0/63.0);
			knob[i][j][4].pos(1);
			knob[i][j][4].displayOnTouch(0);
			spork ~ sampleChange(knob[i][j][3], rstep[i]); //knobValue for sample knob
			spork ~ printValue(knob[i][j][0]);
			spork ~ printValue(knob[i][j][1]);
			spork ~ printValue(knob[i][j][2]);
			spork ~ printValue(knob[i][j][3]);
			spork ~ printValue(knob[i][j][4]);
		}
	}
	for(0=>int i;i<8;i++) lightOn(i,1,push.rainbow(i,1));
	
	
	
	//passing sample select knobs the sample names
	knob[0][0][3].text(kck[0]); knob[0][0][3].stringList(kck);
	knob[1][0][3].text(snr[0]); knob[1][0][3].stringList(snr);
	knob[2][0][3].text(clp[0]); knob[2][0][3].stringList(clp);
	knob[3][0][3].text(chh[0]); knob[3][0][3].stringList(chh);
	knob[4][0][3].text(ohh[0]); knob[4][0][3].stringList(ohh);
	knob[5][0][3].text(ltm[0]); knob[5][0][3].stringList(ltm);
	knob[6][0][3].text(htm[0]); knob[6][0][3].stringList(htm);
	knob[7][0][3].text(cym[0]); knob[7][0][3].stringList(cym);
	
	//Aux Knobs
	PushKnob mGainKnob; //Master Gain
	mGainKnob.init(8,push,mB,"Mst Gain");
	mGainKnob.pos(0.8);
	mGainKnob.cursorStyle(3);
	mGainKnob.setLabelPos(7,0);
	mGainKnob.setValuePos(7,1);
	mGainKnob.setCursorPos(7,2);
	mGainKnob.focus(1);
	PushKnob tempoKnob; //Tempo
	tempoKnob.init(9,push,mB,"Tempo");
	tempoKnob.cursorStyle(3);
	tempoKnob.valueOffset(50);
	tempoKnob.valueScale(400);
	tempoKnob.incrementAmt(0.0025);
	PushKnob swingKnob; //Swing
	swingKnob.init(10,push,mB,"Swing");
	swingKnob.cursorStyle(3);
	spork~printAuxKnob(mGainKnob);
	spork~printAuxKnob(tempoKnob);
	spork~printAuxKnob(swingKnob);
	spork~hideAuxKnob(mGainKnob);
	spork~hideAuxKnob(tempoKnob);
	spork~hideAuxKnob(swingKnob);
	spork~auxKnobValue(mGainKnob,0);
	spork~auxKnobValue(tempoKnob,1);
	spork~auxKnobValue(swingKnob,2);

	//Buttons
	spork ~ playButton();
	spork ~ curDrumButtons();
	spork ~ muteButtons();
	
	//Init some pushStep functions
	push.updateDisplay();
	curDrum(0);
	page(0,0);
	rstep[0].updateGrid();
}


fun void muteLEDs(){
    for(0 => int i; i<8; i++){
        if(rstep[i].mute()==0){
            midiOut(0xB0, push.sel[i][0], 0);
        }
        else midiOut(0xB0, push.sel[i][0], muteColor);
    }
}

fun void curDrumLEDs(){
    for(0 => int i; i<8; i++){
        if(i == cDrum){
            midiOut(0xB0, push.sel[i][1], push.rainbow(cDrum,1));
        }
    }
}
//-------THESE ARE FOR SEL BUTTONS ONLY
fun void lightOn(int x, int y, int c){
    0xB0 => msg.data1;
    push.sel[x][y] => msg.data2;
    c => msg.data3;
    mout.send(msg);
}

fun void lightOff(int x, int y){
    0xB0 => msg.data1;
    push.sel[x][y] => msg.data2;
    0 => msg.data3;
    mout.send(msg);
}


fun void sampleChange(PushKnob pK, RStep r){     //Look here!!!!
    while(pK.moved => now) r.curSound(pK.stringNumber());
}

fun void unfocusPages(){ 
    for(0=>int i;i<nDrums;i++){
        for(0=>int j; j<nPages; j++){
            for(0 => int l; l<nKnobs; l++){
                knob[i][j][l].focus(0);
            }
        }
    }
}

fun void page(int d, int pg){
    while(pg>=nPages)nPages-=>pg;
    while(pg<0)nPages+=>pg;
    pg=>cPage;
    for(0=>int i;i<nDrums;i++){
        for(0=>int j; j<nPages; j++){
            for(0 => int l; l<nKnobs; l++){
                knob[i][j][l].focus(0);
            }
        }
    }
    for(0=>int i;i<nKnobs;i++) knob[d][pg][i].focus(1);
    push.updateDisplay();
}

fun void printAuxKnob(PushKnob pK){
    while(pK.touchOn=>now){
        unfocusPages();
        pK.focus(1);
        pK.displayUpdate();
        push.updateDisplay();
    }
}

fun void hideAuxKnob(PushKnob pK){
    while(pK.touchOff=>now){
        pK.focus(0);
        page(cDrum,cPage);
        pK.displayUpdate();
        push.updateDisplay();
    }
}

fun void printValue(PushKnob pK){
    while(pK.moved=>now){
        pK.displayUpdate();
        push.updateDisplay();
    }
}

fun void auxKnobValue(PushKnob pK, int mode){ //for master gain knob
    while(pK.moved=>now){
        if(mode==0) pK.value() => mBus.gain;
        else if(mode==1) clock.BPM(pK.value());
        else if(mode==2) clock.swingAmt(pK.value());
        pK.displayUpdate();
        push.updateDisplay();
    }
}

fun void knobValue(PushKnob pK,RStep rS,int mode){
    while(pK.moved=>now){
        if(mode==0) rS.gain(pK.pos());
        else if(mode==1) rS.rate(pK.pos());
        else if(mode==2) rS.pan(pK.pos());
    }       
}

fun void knobValue(PushKnob pK,float f){
    while(pK.moved=>now) pK.value() => f;
}

fun void knobValue(PushKnob pK,int a){
    while(pK.moved=>now) Math.round(pK.value())$int=>a;
}

fun void knobValueOffTouch(PushKnob pK, int mode){
    while(pK.touchOff=>now){
        if(mode==0 & pK.focus()){
        	pK.value(rstep[cDrum].patLen(pK.value() $ int));
        }
    }
}

fun void playButton(){
    MidiMsg msg;
    while(mB.mev=>now){
        mB.mev.msg @=> msg;
        if(msg.data1==0xB0 & msg.data2==push.bcol0[11] & msg.data3){
            if(msg.data3) clock.play();
        }
    }
}

fun void muteButtons(){
    MidiMsg msg;
    while(mB.mev=>now){
        mB.mev.msg @=> msg;
        if(msg.data1==0xB0 & msg.data3){
            for(0 => int i; i<8; i++){
                if(msg.data2==push.sel[i][0]){
                    if(rstep[i].mute() == 1){
                        rstep[i].mute(0);
                        lightOff(i,0);
                    }else{
                        rstep[i].mute(1);
                        lightOn(i,0,4);
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
                if(msg.data2==push.sel[i][1]){
                    lightOn(cDrum,1,push.rainbow(cDrum,1));
                    rstep[cDrum].cue(0);
                    curDrum(i);
                    rstep[cDrum].cue(1);
                    page(cDrum,cPage);
                    lightOn(cDrum,1,push.rainbow(cDrum,0));
                }
            }
            rstep[cDrum].updateGrid();
        }
    }
}

fun int curDrum(){ return cDrum; }
fun int curDrum(int nd){
    nd => cDrum;
    for(0 => int i; i<nDrums; i++){
        if(i != cDrum) rstep[i].focus(0);
        else rstep[i].focus(1);
    }
    return cDrum;
}

fun void midiOut(int d1, int d2, int d3){
    d1 => msg.data1; 
    d2 => msg.data2; 
    d3 => msg.data3;
    mout.send(msg);
}

fun void initSounds(){
	string path[kck.cap()];
    for(0 => int i; i<kck.cap(); i++) sampRoot + "kck/" + kck[i] + ".wav" => path[i];
    rstep[0].init(mB,mout,path);
    rstep[0].onColor(push.rainbow(0,dim));
    rstep[0].cursorColor(push.rainbow(3,0));
    rstep[0].highlightColor(push.rainbow(2,0));
    new string[snr.cap()]@=>path;
    for(0 => int i; i<snr.cap(); i++) sampRoot + "snr/" + snr[i] + ".wav" => path[i];
    rstep[1].init(mB,mout,path);
    rstep[1].onColor(push.rainbow(1,dim));
    rstep[1].cursorColor(push.rainbow(4,0));
    rstep[1].highlightColor(push.rainbow(3,0));
    new string[clp.cap()]@=>path;
    for(0 => int i; i<clp.cap(); i++) sampRoot + "clp/" + clp[i] + ".wav" => path[i];
    rstep[2].init(mB,mout,path);
    rstep[2].onColor(push.rainbow(2,dim));
    rstep[2].cursorColor(push.rainbow(5,0));
    rstep[2].highlightColor(push.rainbow(4,0));
    new string[chh.cap()]@=>path;
    for(0 => int i; i<chh.cap(); i++) sampRoot + "chh/" + chh[i] + ".wav" => path[i];
    rstep[3].init(mB,mout,path);
    rstep[3].onColor(push.rainbow(3,dim));
    rstep[3].cursorColor(push.rainbow(6,0));
    rstep[3].highlightColor(push.rainbow(5,0));
    new string[ohh.cap()]@=>path;
    for(0 => int i; i<ohh.cap(); i++) sampRoot + "ohh/" + ohh[i] + ".wav" => path[i];
    rstep[4].init(mB,mout,path);
    rstep[4].onColor(push.rainbow(4,dim));
    rstep[4].cursorColor(push.rainbow(7,0));
    rstep[4].highlightColor(push.rainbow(6,0));
    new string[ltm.cap()]@=>path;
    for(0 => int i; i<ltm.cap(); i++) sampRoot + "prc/" + ltm[i] + ".wav" => path[i];
    rstep[5].init(mB,mout,path);
    rstep[5].onColor(push.rainbow(5,dim));
    rstep[5].cursorColor(push.rainbow(0,0));
    rstep[5].highlightColor(push.rainbow(7,0));
    new string[htm.cap()]@=>path;
    for(0 => int i; i<htm.cap(); i++) sampRoot + "prc/" + htm[i] + ".wav" => path[i];
    rstep[6].init(mB,mout,path);
    rstep[6].onColor(push.rainbow(6,dim));
    rstep[6].cursorColor(push.rainbow(1,0));
    rstep[6].highlightColor(push.rainbow(0,0));
    new string[cym.cap()]@=>path;
    for(0 => int i; i<cym.cap(); i++) sampRoot + "cym/" + cym[i] + ".wav" => path[i];
    rstep[7].init(mB,mout,path);
    rstep[7].onColor(push.rainbow(7,dim));
    rstep[7].cursorColor(push.rainbow(2,0));
    rstep[7].highlightColor(push.rainbow(1,0));
}

