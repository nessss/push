Push push;
push.init();
push.clearDisplay();

Clock clock;
clock.init(170);

OscRecv orec;
orec.port(98765);
orec.event("/c,f")@=>OscEvent clockMsg;
orec.listen();

//Metro
Impulse metro=>ResonZ rez=>dac;
200=>rez.freq;
50=>rez.Q;
20=>metro.gain;

MidiLooper mL[1];
for(int i;i<mL.cap();i++){
	mL[i].init();
	32=>mL[i].clockDiv;
}

int funBtn[0];
//amen
funBtn<<push.grid[0][2];//r0
funBtn<<push.grid[1][2];//c0
funBtn<<push.grid[2][2];//m0

Shred blinkShred[4];
200::ms=>dur blinkDur;

MidiOut mout;
mout.open("Ableton Push User Port");

for(int i;i<64;i++)    //clears pads
	send(0x90,36+i,0);

for(int i;i<8;i++)       //sets default off colors?
	send(0x90,push.sel[i][1],push.rainbow(i,1));

PadGroup amen;
amen.grpBus => Pan2 master => dac;  
amen.init(push.rainbow(0,1),push.rainbow(1,1)); //init pad group
initAmen();

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
            if(msg.data1 == 144 | msg.data1 == 128){ 
                //<<<msg.data3>>>;
                if(msg.data2>35 & msg.data2<100){
                	1=>int isNote;
                	for(int i;i<funBtn.cap();i++)
                		if(msg.data2==funBtn[i])0=>isNote;
                	if(isNote){
                    	amen.checkNote(msg);
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
                    					spork~recordingBlink(funBtn[i])@=>blinkShred[i/3];
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

fun void send(int d1,int d2,int d3){
	MidiMsg msg;
	d1=>msg.data1;
	d2=>msg.data2;
	d3=>msg.data3;
	mout.send(msg);
}

fun void recordingBlink(int p){
	while(blinkDur=>now){
		send(0x90,p,push.rainbow(0,0));
		blinkDur=>now;
		send(0x90,p,0);
	}
}

fun void loopLoop(int l){
    while(mL[l].msgReady=>now){
        if(!mL[l].recording){
        	amen.checkNote(mL[l].curMsg);
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

fun void initAmen(){
    amen.addPad("amen/snare.aif", push.grid[0][0]); 
    amen.addPad("amen/kick.aif", push.grid[1][0]); 
    amen.addPad("amen/snare.aif", push.grid[2][0]); 
    amen.addPad("amen/kick.aif", push.grid[3][0]); 
    
    amen.addPad("amen/snarelet.aif", push.grid[0][1]); 
    amen.addPad("amen/kicklet2.aif", push.grid[1][1]); 
    amen.addPad("amen/kicklet1.aif", push.grid[2][1]); 
    amen.addPad("amen/ride.aif", push.grid[3][1]); 
    amen.addPad("amen/crash.aif", push.grid[3][2]);
}