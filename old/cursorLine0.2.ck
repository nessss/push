// cursorLine.ck
//  for making a cursor line UI object on Push
//  with an encoder and the display

// 0.2- Changing pos from int to float

PushDisplay pD;
PushCCs pCC;

MidiIn min;
MidiMsg msg;
min.open(2);
<<<min.name()>>>;

pD.clearDisplay();
string cursorThing;
""=>cursorThing;
0.5=>float pos;
0=>int visible;

0.01=>float inc;

cursorUpdate();
while(min=>now){
    while(min.recv(msg)){
        if(msg.data1==0xB0){
            if(msg.data2==pCC.knobs[0]){
                if(msg.data3<64)msg.data3*inc+=>pos;
                else (128-msg.data3)*inc-=>pos;
                if(pos>1)1=>pos;
                if(pos<0)0=>pos;
                cursorUpdate();
            }
        }
        if(msg.data1==0x90){
            if(msg.data2==pCC.touch[0]){
                if(msg.data3==127){
                    1=>visible;
                    cursorUpdate();
                }
                else{
                    0=>visible;
                    pD.clearDisplay();
                }
            }
        }
        if(msg.data1==0x80){
            if(msg.data2==pCC.touch[0]){
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
