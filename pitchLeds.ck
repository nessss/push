MidiOut mout;
MidiMsg msg;

mout.open(4);
<<<mout.name(),"">>>;
/*
240=>msg.data1;
 71=>msg.data2;
127=>msg.data3;
mout.send(msg);
 21=>msg.data1;
 99=>msg.data2;
  0=>msg.data3;
mout.send(msg);
  1=>msg.data1;
  4=>msg.data2;
247=>msg.data3;
mout.send(msg);
//mout.open(4);

240=>msg.data1;
 71=>msg.data2;
127=>msg.data3;
mout.send(msg);
 21=>msg.data1;
100=>msg.data2;
  0=>msg.data3;
mout.send(msg);
  8=>msg.data1;
  0=>msg.data2;
  0=>msg.data3;
mout.send(msg);
127=>msg.data1;
247=>msg.data2;
  0=>msg.data3;
mout.send(msg);
/*

fun void touchStripOut(float f){
    1.0/127.0
}
0xEC=>msg.data1;
0x00=>msg.data2;
0xF7=>msg.data3;
mout.send(msg);
*/

while(samp=>now);