pushDisplay pD;
PushCCs pCC;

MidiIn min;
MidiMsg msg;
min.open(2);
<<<min.name()>>>;

pD.clearDisplay();
string cursorThing;
""=>cursorThing;
8=>int pos;
0=>int visible;

10::ms=>dur cRate;

cursorUpdate();
while(min=>now){
    while(min.recv(msg)){
        if(msg.data1==0xB0){
            if(msg.data2==pCC.knobs[0]){
                if(msg.data3<64)msg.data3+=>pos;
                else 128-msg.data3-=>pos;
                if(pos>14)14=>pos;
                if(pos<0)0=>pos;
                cursorUpdate();
            }
        }
        if(msg.data1==0x90){
            if(msg.data2==pCC.touch[0]){
                if(msg.data3==127)1=>visible;
                else 0=>visible;
            }
        }
    }
}


while(samp=>now);


fun void cursorUpdate(){
    if(visible){
        "\003"=>cursorThing;
        for(0=>int i;i<pos;i++){
            cursorThing+"\006"=>cursorThing;
        }
        cursorThing+"\010"=>cursorThing;
        for(0=>int i;i<14-pos;i++){
            cursorThing+"\006"=>cursorThing;
        }
        cursorThing+"\004"=>cursorThing;
        pD.setSegment(0,0,cursorThing);
        pD.updateDisplay();
    }
}
