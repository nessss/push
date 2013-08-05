
int x;

if(me.args()){
	<<<Std.atoi(me.arg(0))>>>=>x;
}
else 0x7F=>x;
<<<x>>>;
Push push;
push.init();
MidiOut mout;
mout.open("Ableton Push User Port");
MidiMsg msg;
0xB0=>msg.data1;
push.bcol1[2]=>msg.data2;
x=>msg.data3;
mout.send(msg);
<<<"Done!",x>>>;
