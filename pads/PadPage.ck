Push push;
PadGroup amen;
amen.grpBus => dac;  
amen.init(push.rainbow(1,1),push.rainbow(0,1)); //init pad group
amen.addPad("Spell/theS", 36); 
amen.addPad("Spell/S", 37); 
amen.addPad("Spell/theU", 38); 
amen.addPad("Spell/U", 39); 
amen.addPad("Spell/theP", 44); 
amen.addPad("Spell/theP", 45); 
amen.addPad("Spell/theP", 46); 
amen.addPad("Spell/theP", 47); 
amen.addPad("Spell/theP", 48); 



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
