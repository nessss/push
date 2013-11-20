MidiIn min;
MidiOut mout;

min.open("Ableton Push User Port");
mout.open("Ableton Push User Port");

0=>int padColor;
43=>int pad;

while(min=>now){
	while(min.recv(MidiMsg msg)){
		if(msg.data1==0xB0&msg.data2==79){
			msg.data3+=>padColor;
			128%=>padColor;
			send(0x90,pad,padColor);
			chout<=padColor<=IO.nl();
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
