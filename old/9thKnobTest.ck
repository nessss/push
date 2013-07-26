PushKnob pK;
Push thePush;
MidiBroadcaster mB;
mB.init();
thePush.init();

pK.init(8,thePush,mB,"Mst Gain");
pK.focus(1);

<<<mB.name()>>>;
//spork~midiPoop();
spork~fucknuts();

fun void fucknuts(){
    while(pK.moved=>now){
        <<<"NYAN!!!!",pK.pos()>>>;
    }
}

fun void midiPoop(){
    MidiMsg msg;
    while(mB.mev=>now){
        mB.mev.msg@=>msg;
        <<<msg.data1,msg.data2,msg.data3>>>;
    }
}
while(samp=>now);