Push push;
push.init();
push.clearDisplay();

Clock clock;
clock.init(172);
clock.initNetOsc("portocat.local", 98765);

OscRecv orec;
orec.port(98765);
orec.event("/c,f")@=>OscEvent clockMsg;
orec.listen();

//Metro
Impulse metro=>ResonZ rez=>dac.chan(7);
rez => dac.chan(8);
200=>rez.freq;
7=>rez.Q;
.5=>metro.gain;

MidiIn min;
min.open("Ableton Push User Port");

MidiLooper mL[3];
for(int i;i<mL.cap();i++){
    mL[i].init();
    32=>mL[i].clockDiv;
}

MidiOut mout;
mout.open("Ableton Push User Port");

for(int i;i<64;i++)    //clears pads
    send(0x90,36+i,0);

for(int i;i<8;i++)       //sets default off colors?
    send(0x90,push.sel[i][1],push.rainbow(i,1));

PadGroup amen;
amen.grpBus => Pan2 amenBus => Pan2 master; 
master.left => dac.chan(0);
master.right => dac.chan(1);  
amen.init(push.rainbow(0,1),push.rainbow(1,1)); //init pad group
initAmen();

PadGroup slowAmen;
slowAmen.grpBus => amenBus;
slowAmen.init(push.rainbow(0,1),push.rainbow(7,1)); //init pad group
initSlowAmen();

.4 => amenBus.gain;
.7 => master.gain;

PadGroup cold;
cold.grpBus => master;
cold.init(push.rainbow(0,1),push.rainbow(4,1));
initCold();

PadGroup sweet;
sweet.grpBus => master;
sweet.init(push.rainbow(0,1),push.rainbow(6,1));
initSweet();

PadGroup worm;
worm.grpBus => master;
worm.init(push.rainbow(0,1),push.rainbow(3,1));
initWorm();


MidiBroadcaster mB;
mB.init("Ableton Push User Port");

mL[0].initControlButtons(mB,mout,push.grid[0][2],push.grid[1][2],push.grid[2][2]);
mL[1].initControlButtons(mB,mout,push.grid[4][7],push.grid[5][7],push.grid[6][7]);
mL[2].initControlButtons(mB,mout,push.grid[0][6],push.grid[1][6],push.grid[2][6]);

spork ~ midiIn();
for(int i;i<mL.cap();i++) spork~loopLoop(i);
spork~displayClock();

chout<="Ready!"<=IO.nl();

while(samp=>now);


fun void midiIn(){
    //MidiMsg msg;
    while(min => now){
        while(min.recv(MidiMsg msg)){
            if(msg.data1 == 0x90 | msg.data1 == 0x80){ 
                if(msg.data2>35 & msg.data2<100){
                    amen.checkNote(msg);
                    slowAmen.checkNote(msg);
                    cold.checkNote(msg);
                    sweet.checkNote(msg);
                    worm.checkNote(msg);
                    for(int i;i<mL.cap();i++) mL[i].addMsg(msg);
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
        if(!mL[l].recording){
            amen.checkNote(mL[l].curMsg.msg);
            slowAmen.checkNote(mL[l].curMsg.msg);
            worm.checkNote(mL[l].curMsg.msg);
        }
    }
}


fun void displayClock(){
    int i;
    while(clockMsg=>now){
        while(clockMsg.nextMsg()){
            clockMsg.getFloat()$int=>int val;
            (val%2)=>i;
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

fun void initSlowAmen(){
    slowAmen.addPad("amen/snare.aif", push.grid[0][4]); 
    slowAmen.addPad("amen/kick.aif", push.grid[1][4]); 
    slowAmen.addPad("amen/snare.aif", push.grid[2][4]); 
    slowAmen.addPad("amen/kick.aif", push.grid[3][4]); 
    
    slowAmen.addPad("amen/snarelet.aif", push.grid[0][5]); 
    slowAmen.addPad("amen/kicklet2.aif", push.grid[1][5]); 
    slowAmen.addPad("amen/kicklet1.aif", push.grid[2][5]); 
    slowAmen.addPad("amen/ride.aif", push.grid[3][5]); 
    slowAmen.addPad("amen/crash.aif", push.grid[3][6]);
    for(int i; i<slowAmen.pads.cap(); i++)
        slowAmen.pads[i].sampler.pitch(0,50);
}

fun void initCold(){
    cold.addPad("cold_sweat/snare.aif", push.grid[4][0]);
    cold.addPad("cold_sweat/kick.aif", push.grid[5][0]);
    cold.addPad("cold_sweat/snare.aif", push.grid[6][0]);
    cold.addPad("cold_sweat/kick.aif", push.grid[7][0]);
    cold.addPad("cold_sweat/snarelet.aif", push.grid[4][1]);
    cold.addPad("cold_sweat/rush2.aif", push.grid[5][1]);
    cold.addPad("cold_sweat/rush1.aif", push.grid[6][1]);
    1 => cold.sustain[5] => cold.sustain[6];
    cold.addPad("cold_sweat/ride.aif", push.grid[7][1]);
    
}

fun void initSweet(){
    sweet.addPad("sweet_pea/snare.aif", push.grid[4][2]);
    sweet.addPad("sweet_pea/kick.aif", push.grid[5][2]);
    sweet.addPad("sweet_pea/snare.aif", push.grid[6][2]);
    sweet.addPad("sweet_pea/kick.aif", push.grid[7][2]);
    sweet.addPad("sweet_pea/snarelet.aif", push.grid[4][3]);
    sweet.addPad("sweet_pea/rush2.aif", push.grid[5][3]);
    sweet.addPad("sweet_pea/rush1.aif", push.grid[6][3]);
    1 => sweet.sustain[5] => sweet.sustain[6];
    sweet.addPad("sweet_pea/kicklet.aif", push.grid[7][3]);
}

fun void initWorm(){
    worm.addPad("synths/super_sharp_worm.wav", push.grid[4][4]);
    worm.addPad("synths/super_sharp_worm.wav", push.grid[5][4]);
    worm.addPad("synths/super_sharp_worm.wav", push.grid[6][4]);
    worm.addPad("synths/super_sharp_worm.wav", push.grid[7][4]);
    for(0=>int i; i<4; i++) worm.pads[i].sampler.pitch(0,60+i);
    
    worm.addPad("synths/super_sharp_worm.wav", push.grid[4][5]);
    worm.addPad("synths/super_sharp_worm.wav", push.grid[5][5]);
    worm.addPad("synths/super_sharp_worm.wav", push.grid[6][5]);
    worm.addPad("synths/super_sharp_worm.wav", push.grid[7][5]);
    for(4 =>int i; i<8; i++) worm.pads[i].sampler.pitch(0,60+i+1);
    
    worm.addPad("synths/super_sharp_worm.wav", push.grid[4][6]);
    worm.addPad("synths/super_sharp_worm.wav", push.grid[5][6]);
    worm.addPad("synths/super_sharp_worm.wav", push.grid[6][6]);
    worm.addPad("synths/super_sharp_worm.wav", push.grid[7][6]);
    for(8 =>int i; i<12; i++) worm.pads[i].sampler.pitch(0,60+i+2);
    
    for(int i; i<worm.pads.cap(); i++) 1 => worm.sustain[i];
}
