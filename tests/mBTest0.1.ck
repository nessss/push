MidiBroadcaster mB;
MidiMsg msg;

mB.init();

spork~listen(0);
spork~listen(1);
spork~listen(2);
spork~listen(3);

while(samp=>now);

fun void listen(int id){
    while(mB.mev=>now){    
        mB.mev.msg@=>msg;    
        <<<id, msg.data1, msg.data2, msg.data3 >>>;    
    }
}