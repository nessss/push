<<<"Initializing...","">>>;
MidiIn min;
MidiMsg msg;
MidiOut mout;
min.open("Ableton Push User Port");
mout.open("Ableton Push User Port");
Push p;
p.init();
<<<"Initialized!","">>>;

while(min=>now){
	while(min.recv(msg)){
		if(msg.data1==0xe0){
			(msg.data2+(msg.data3<<4))=>float f;
			f/2048=>f;
			8*=>f;
			<<<f>>>;
		}
	}
}

fun void light(int l){
	for(int i;i<8;i++){
		sendMidi(0x90,p.grid[0][i],0);
	}
	sendMidi(0x90,p.grid[0][l],64);
}



fun void sendMidi(int d1,int d2,int d3){
	MidiMsg msg;
	d1=>msg.data1;
	d2=>msg.data2;
	d3=>msg.data3;
	mout.send(msg);
}

<<<"la">>>;
