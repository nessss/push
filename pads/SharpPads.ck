Push push;
push.init();
push.clearDisplay();

MidiOut mout;
mout.open("Ableton Push User Port");

for(int i;i<64;i++)
	send(0x90,36+i,0);

for(int i;i<8;i++)
	send(0x90,push.sel[i][1],push.rainbow(i,1));

PadGroup spell;
spell.grpBus => Pan2 master => dac;  
spell.init(push.rainbow(3,1),push.rainbow(5,1)); //init pad group
1=>spell.choke;
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

for(int i;i<spell.pads.cap();i++){
	spell.pads[i].sampler.pitch(0,58);
}

PadGroup acBass;
acBass.grpBus => master;
acBass.init(push.rainbow(5,1),push.rainbow(6,1));
1=>acBass.choke;
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

PadGroup checkIt;
checkIt.grpBus => master;
checkIt.init(push.rainbow(0,1),push.rainbow(1,1));
1=>checkIt.choke;
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

//checkIt.pads[4].sampler.buf[0].startPhase(0.05);
checkIt.pads[10].sampler.buf[0].startPhase(0.05);

PadGroup sharp;
sharp.grpBus => master;
sharp.init(push.rainbow(4,1),push.rainbow(6,1));
1=>sharp.choke;
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

MidiIn min; 
min.open("Ableton Push User Port");


spork ~ midiIn();

chout<="Ready!"<=IO.nl();
while(samp=>now);


fun void midiIn(){
    MidiMsg msg;
    while(min => now){
        while(min.recv(msg)){
            if(msg.data1 == 144 | msg.data1 == 128){
                //<<<msg.data3>>>;
                if(msg.data2>35 & msg.data2<100){
                    spell.checkNote(msg);
                    acBass.checkNote(msg);
                    checkIt.checkNote(msg);
                    sharp.checkNote(msg);
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
