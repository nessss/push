MidiOut mout;
MidiMsg msg;

mout.open(2);
<<<mout.name()>>>;

144=>msg.data1;
36=>msg.data2;
10=>msg.data3;

mout.send(msg);
for(0=>int i;i<128;i++){
    i=>msg.data3;
    <<<i>>>;
    1200::ms=>now;
    for(0=>int i;i<64;i++){
        i+36=>msg.data2;
        mout.send(msg);
    }
}
while(samp=>now);