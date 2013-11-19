Push push;
push.init();
Clock clock;
clock.init();
MidiLooper mL;
mL.init();
PadGroup amen;
amen.grpBus => dac;  
amen.init(push.rainbow(0,1),push.rainbow(1,1)); //init pad group

amen.addPad("amen/snare.aif", push.grid[0][0]); 
amen.addPad("amen/kick.aif", push.grid[1][0]); 
amen.addPad("amen/snare.aif", push.grid[2][0]); 
amen.addPad("amen/kick.aif", push.grid[3][0]); 

amen.addPad("amen/snarelet.aif", push.grid[0][1]); 
amen.addPad("amen/kicklet2.aif", push.grid[1][1]); 
amen.addPad("amen/kicklet1.aif", push.grid[2][1]); 
amen.addPad("amen/ride.aif", push.grid[3][1]); 
amen.addPad("amen/crash.aif", push.grid[3][2]);



MidiIn min; 
min.open("Ableton Push User Port");


spork ~ midiIn();
spork ~ loopLoop();

while(samp=>now);


fun void midiIn(){
    while(min => now){
        while(min.recv(MidiMsg msg)){
            if(msg.data1 == 0x90 | msg.data1 == 0x80){
                //<<<msg.data3>>>;
                if(msg.data2>35 & msg.data2<85){
                    amen.checkNote(msg);
                    mL.addMsg(msg);
                }
            }
            if(msg.data1==0xB0&msg.data2==85&msg.data3>0){
                if(mL.recording){
                    chout<="Stopping..."<=IO.nl();
                    mL.stop();
                }else{
                    chout<="Recording..."<=IO.nl();
                    mL.record();
                }
            }
        }
    }
}

fun void loopLoop(){
    while(mL.msgReady=>now){
        if(!mL.recording){
            amen.checkNote(mL.curMsg);
            chout<=mL.curMsg.data1<=" "<=mL.curMsg.data2<=" "<=mL.curMsg.data3<=" "<=IO.nl();
        }
    }
}