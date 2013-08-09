MidiIn min;
MidiMsg msg;
min.open("Ableton Push User Port");


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
