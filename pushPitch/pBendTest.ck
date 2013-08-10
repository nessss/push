<<<"Initializing...","">>>;
MidiIn min;
MidiMsg msg;
MidiOut mout;
min.open("Ableton Push User Port");
mout.open("Ableton Push User Port");
Push p;
p.init();
<<<"Initialized!","">>>;
float f;
Event pbevent;
4=>int lit;
light(lit);
Shred pbshred;
int active;

while(min=>now){
	while(min.recv(msg)){
		if(msg.data1==0xe0){
			(msg.data2+(msg.data3<<4))=>f;
			f/2048=>f;
			8*=>f;
			pbevent.broadcast();
		}else if(msg.data1==0x90){
			if(msg.data2==p.pbtouch){
				if(msg.data3){
					<<<"touch","">>>;
					1=>active;
					spork~pbloop()@=>pbshred;
				}else{
					<<<"no touch","">>>;
					pbshred.exit();
					0=>active;
				}
			}
		}
	}
}

fun void pbloop(){
	f=>float start;
	0=>int offset;
	<<<"start:",start>>>;
	while(pbevent=>now){
		<<<f,Math.fabs(f-start)>>>;
		if(Math.fabs(f-start)>offset+1.0){
			Math.sgn((f-start))$int=>int diff;
			diff+=>lit;
			diff+=>start;
			<<<lit,offset>>>;
			if(lit>7)7=>lit;
			if(lit<0)0=>lit;
			if(active){
				light(lit);
			}
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
