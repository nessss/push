// polyPush.ck
// for setting push to polyphonic aftertouch instead of channel aftertouch

MidiOut mout;
MidiMsg msg;

mout.open(2);
<<<mout.name()>>>;

0xF0=>msg.data1;
0x47=>msg.data2;
0x7F=>msg.data3;
mout.send(msg);
0x15=>msg.data1;
0x5C=>msg.data2;
0x00=>msg.data3;
mout.send(msg);
0x01=>msg.data1;
0x00=>msg.data2;
0xF7=>msg.data3;
mout.send(msg);

while(samp=>now);