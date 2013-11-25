Push push;
push.init();
push.clearDisplay();

MidiBroadcaster mB;
mB.init("Ableton Push User Port");


Clock clock;
clock.init(170);

OscRecv orec;
orec.port(98765);
orec.event("/c,f")@=>OscEvent clockMsg;
orec.listen();

Impulse metro=>ResonZ rez=>dac;
200=>rez.freq;
1=>rez.Q;
1=>metro.gain;

MidiLooper mL[4];
for(int i;i<mL.cap();i++){
	mL[i].init();
	32=>mL[i].clockDiv;
}


Shred blinkShred[4];
200::ms=>dur blinkDur;

MidiOut mout;
mout.open("Ableton Push User Port");

for(int i;i<64;i++)
	send(0x90,36+i,0);
	
mL[0].initControlButtons(mB,mout,push.grid[4][4],push.grid[5][4],push.grid[5][3]);
mL[1].initControlButtons(mB,mout,push.grid[6][4],push.grid[7][4],push.grid[7][3]);
mL[2].initControlButtons(mB,mout,push.grid[4][2],push.grid[5][2],push.grid[6][2]);
mL[3].initControlButtons(mB,mout,push.grid[5][0],push.grid[6][0],push.grid[7][0]);

for(int i;i<8;i++)
	send(0x90,push.sel[i][1],push.rainbow(i,1));

PadGroup spell;
spell.grpBus.gain(0.6);
spell.grpBus => Pan2 master => dac;  
spell.init(push.rainbow(3,1),push.rainbow(5,1)); //init pad group
1=>spell.choke;
initSpell();

for(int i;i<spell.pads.cap();i++){
	spell.pads[i].sampler.pitch(0,58);
}

PadGroup acBass;
acBass.grpBus => master;
acBass.init(48,69);
1=>acBass.choke;
initAcBass(); 

PadGroup checkIt;
checkIt.grpBus => master;
checkIt.init(push.rainbow(0,1),push.rainbow(1,1));
1=>checkIt.choke;
initCheckIt();


//checkIt.pads[4].sampler.buf[0].startPhase(0.05);
checkIt.pads[10].sampler.buf[0].startPhase(0.05);

PadGroup sharp;
sharp.grpBus.gain(0.6);
sharp.grpBus => master;
sharp.init(push.rainbow(4,1),push.rainbow(6,1));
1=>sharp.choke;
initSharp();

MidiIn min; 
min.open("Ableton Push User Port");

spork ~ midiIn();
for(int i;i<mL.cap();i++){
	spork~loopLoop(i);
}
spork~displayClock();

chout<="Ready!"<=IO.nl();

while(samp=>now);

fun void midiIn(){
    while(min => now){
    	while(min.recv(MidiMsg msg)){
        	if(msg.data1 == 0x90 | msg.data1 == 0x80){ 
            	if(msg.data2>35 & msg.data2<100){
                	spell.checkNote(msg);
                	acBass.checkNote(msg);
                	sharp.checkNote(msg);
                	checkIt.checkNote(msg);
                	for(int i;i<mL.cap();i++){
                		if(mL[i].recording){
                    		mL[i].addMsg(msg);
                    	}
                	}
               	}
            }
        }
    }
}

fun void oldMidiIn(){
	int funBtn[0];
    while(min => now){
        while(min.recv(MidiMsg msg)){
            if(msg.data1 == 144 | msg.data1 == 128){
                //<<<msg.data3>>>;
                if(msg.data2>35 & msg.data2<100){
                	1=>int isNote;
                	for(int i;i<funBtn.cap();i++)
                		if(msg.data2==funBtn[i])0=>isNote;
                	if(isNote){
                    	spell.checkNote(msg);
                    	acBass.checkNote(msg);
                    	checkIt.checkNote(msg);
                    	sharp.checkNote(msg);
                    	for(int i;i<mL.cap();i++){
                    		mL[i].addMsg(msg);
                    	}
                    }else{
                    	for(int i;i<funBtn.cap();i++){
                    		if(msg.data1==0x90&msg.data2==funBtn[i]){
                    			if(i%3==0){
                    				chout<="Recording "<=i/3<=IO.nl();
                    				if(mL[i/3].recording){
                    					mL[i/3].stop();
                    					blinkShred[i/3].exit();
                    					send(0x80,funBtn[i],0);
                    				}else{
                    					mL[i/3].record();
                    					//spork~recordingBlink(funBtn[i])@=>blinkShred[i/3];
                    				}
                    			}else if(i%3==1){
                    				chout<="Clearing "<=i/3<=IO.nl();
                    				mL[i/3].clear();
                    				blinkShred[i/3].exit();
                    				send(0x80,funBtn[i-1],0);
                    			}else if(i%3==2){
                    				if(!mL[i/3].recording){
                    					chout<="Muting "<=i/3<=": "<=!mL[i/3].mute()<=IO.nl();
                    					mL[i/3].mute(!mL[i/3].mute());
                    					blinkShred[i/3].exit();
                    					send(0x80,funBtn[i-2],0);
                    				}
                    			}
                    		}
                    	}
                    }
                }
            }
        }
    }
}

fun MidiMsg copyMsg(MidiMsg inMsg){
    MidiMsg outMsg;
    inMsg.data1=>outMsg.data1;
    inMsg.data2=>outMsg.data2;
    inMsg.data3=>outMsg.data3;
    return outMsg;
}

fun void send(int d1,int d2,int d3){
	MidiMsg msg;
	d1=>msg.data1;
	d2=>msg.data2;
	d3=>msg.data3;
	mout.send(msg);
}

fun void loopLoop(int l){
    while(mL[l].curMsg=>now){
    	mL[l].curMsg.msg @=> MidiMsg msg;
        if(!mL[l].recording){
        	spell.checkNote(msg);
        	acBass.checkNote(msg);
        	sharp.checkNote(msg);
            checkIt.checkNote(msg);
        }
    }
}

fun void displayClock(){
	int i;
	while(clockMsg=>now){
		while(clockMsg.nextMsg()){
			clockMsg.getFloat()$int=>int val;
			(val%8)=>i;
			Std.itoa((val/8)%4)=>string clockValue;
			push.subsegment(7,3,clockValue);
			push.updateLine(3);
			if(i==0)
				200=>metro.next;
		}
	}
}


fun void initSpell(){
	spell.addPad("Spell/theS", push.grid[0][7]); 
	spell.addPad("Spell/S", push.grid[0][6]); 
	spell.addPad("Spell/theU", push.grid[1][7]); 
	spell.addPad("Spell/U", push.grid[1][6]); 
	spell.addPad("Spell/theP", push.grid[2][7]); 
	spell.addPad("Spell/P", push.grid[2][6]); 
	spell.addPad("Spell/theE", push.grid[3][7]); 
	spell.addPad("Spell/E", push.grid[3][6]); 
	spell.addPad("Spell/theR", push.grid[4][7]); 
	spell.addPad("Spell/R", push.grid[4][6]); 
	spell.addPad("Spell/theH", push.grid[0][5]); 
	spell.addPad("Spell/H", push.grid[0][4]); 
	spell.addPad("Spell/theA", push.grid[1][5]); 
	spell.addPad("Spell/A", push.grid[1][4]); 
	spell.addPad("Spell/theO", push.grid[2][5]); 
	spell.addPad("Spell/O", push.grid[2][4]); 
	spell.addPad("Spell/theT", push.grid[3][5]); 
	spell.addPad("Spell/T", push.grid[3][4]); 
}

fun void initAcBass(){
	acBass.addPad("AcBass/lo1.wav", push.grid[4][5]);
	acBass.addPad("AcBass/lo2.wav", push.grid[5][5]);
	acBass.addPad("AcBass/hi.wav",  push.grid[5][6]);
	acBass.addPad("AcBass/lo1.wav", push.grid[6][5]);
	acBass.addPad("AcBass/lo2.wav", push.grid[7][5]);
	acBass.addPad("AcBass/hi.wav",  push.grid[7][6]);
	acBass.addPad("AcBass/lo1.wav", push.grid[6][6]);
	acBass.addPad("AcBass/lo2.wav", push.grid[6][7]);
	acBass.addPad("AcBass/hi.wav",  push.grid[7][7]);
	for(int i;i<acBass.pads.cap();i++){
		//acBass.pads[i].sampler.buf[0].startPhase(0.01);
		//acBass.pads[i].sampler.buf[0].endPhase(0.4);
		if(i>2){
			acBass.pads[i].sampler.pitch(0,66);
		}
		if(i>5){
			acBass.pads[i].sampler.pitch(0,65);
		}
		if(i==2)acBass.pads[i].sampler.pitch(0,60.2);
		if(i==5)acBass.pads[i].sampler.pitch(0,66.2);
		if(i==8)acBass.pads[i].sampler.pitch(0,65.2);
	}
}

fun void initCheckIt(){
	checkIt.addPad("CheckIt/Check", push.grid[0][1]);
	checkIt.addPad("CheckIt/I", push.grid[1][1]);
	checkIt.addPad("CheckIt/Fuck", push.grid[2][1]);
	checkIt.addPad("CheckIt/man", push.grid[3][1]);
	checkIt.addPad("CheckIt/Who", push.grid[4][1]);
	checkIt.addPad("CheckIt/mention", push.grid[5][1]);
	checkIt.addPad("CheckIt/Blazin", push.grid[0][0]);
	checkIt.addPad("CheckIt/the", push.grid[1][0]);
	checkIt.addPad("CheckIt/stuff", push.grid[2][0]);
	checkIt.addPad("CheckIt/that", push.grid[3][0]);
	checkIt.addPad("CheckIt/ig", push.grid[4][0]);
	for(int i;i<checkIt.pads.cap();i++){
		checkIt.pads[i].sampler.pitch(0,58);
	}
}

fun void initSharp(){
	sharp.addPad("Sharp/Su.wav", push.grid[0][3]);
	sharp.addPad("Sharp/pa.wav", push.grid[0][2]);
	sharp.addPad("Sharp/Shots.wav", push.grid[1][3]);
	sharp.addPad("Sharp/Sharp.wav", push.grid[1][2]);
	sharp.addPad("Sharp/Shoo.wav", push.grid[2][3]);
	sharp.addPad("Sharp/tah.wav", push.grid[2][2]);
	sharp.addPad("Sharp/Shoo2.wav", push.grid[3][3]);
	sharp.addPad("Sharp/'y.wav", push.grid[3][2]);
	sharp.addPad("gunshot.wav", push.grid[4][3]);
	1=>sharp.sustain[8];
	sharp.pads[8].sampler.buf[0].startPhase(0.01);
}
