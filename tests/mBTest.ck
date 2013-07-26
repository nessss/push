MidiBroadcaster mB;
MidiMsg msg;
mB.init(2);

while(mB.onMsg=>now){
    mB.msg()@=>msg;
    <<<msg.data1,msg.data2,msg.data3>>>;
}