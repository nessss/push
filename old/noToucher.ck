Push push;
PushKnob knob;
MidiBroadcaster mB;
push.init();
knob.init(8,push,mB,"Test");
knob.focus(1);

spork ~ noToucher(knob);
while(samp=>now);

fun void noToucher(PushKnob k){
    while(k.touchOff => now){
        <<<"fack">>>;
    }
}