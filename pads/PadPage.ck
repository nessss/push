Push push;
PadGroup amen;
amen.grpBus => dac;  
amen.init(push.rainbow(1,1),push.rainbow(0,1)); //init pad group
amen.addPad("amen/snare.aif", 36); 
amen.addPad("amen/kick.aif", 37); 
amen.addPad("amen/snare.aif", 38); 
amen.addPad("amen/kick.aif", 39); 
amen.addPad("amen/snarelet.aif", 44); 
amen.addPad("amen/kicklet2.aif", 45); 
amen.addPad("amen/kicklet1.aif", 46); 
amen.addPad("amen/ride.aif", 47); 
amen.addPad("amen/snare.aif", 48); 



MidiIn min; 
min.open("Ableton Push User Port");


spork ~ midiIn();

while(samp=>now);


fun void midiIn(){
    MidiMsg msg;
    while(min => now){
        while(min.recv(msg)){
            if(msg.data1 == 144 | msg.data1 == 128){
                //<<<msg.data3>>>;
                if(msg.data2>35 & msg.data2<100){
                    amen.checkNote(msg);
                }
            }
        }
    }
}