// cursorLine.ck
//  for making a cursor line UI object on Push
//  with an encoder and the display

// 0.2- Changing pos from int to float
// 0.3- Finished for now

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

0.005=>float inc;

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
    Math.round(pos*14)$int=>int iPos;
    <<<iPos>>>;
    if(visible){
        displayCursor(0,0,0,iPos);
        displayCursor(0,1,1,iPos);
        displayCursor(0,2,2,iPos);
    }
}

fun void displayCursor(int c,int r,int style,int pos){
    if(style==0){
        if(pos==0){
            "\005"=>cursorThing;
            for(0=>int i;i<15;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }
        else if(pos==1){
            "\003"=>cursorThing;
            for(0=>int i;i<15;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\005"=>cursorThing;
        }
        else{
            "\003"=>cursorThing;
            for(0=>int i;i<pos;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\010"=>cursorThing;
            for(0=>int i;i<14-pos;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }
        pD.setSegment(0,0,cursorThing);
        pD.updateDisplay();
    }
    else if(style==1){
        if(pos==0){
            "\005"=>cursorThing;
        }
        else if(pos==1){
            "\003"=>cursorThing;
            for(0=>int i;i<15;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }
        else{
            "\003"=>cursorThing;
            for(0=>int i;i<pos;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\010"=>cursorThing;
            
        }
        pD.setSegment(1,0,cursorThing);
        pD.updateDisplay();
    }else if(style==2){
        if(pos==0){
            "\003"=>cursorThing;
            for(0=>int i;i<15;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }
        else if(pos==1){
            ""=>cursorThing;
            for(0=>int i;i<16;i++){
                cursorThing+" "=>cursorThing;
            }
            cursorThing+"\005"=>cursorThing;
        }
        else{
            " "=>cursorThing;
            for(0=>int i;i<pos;i++){
                cursorThing+" "=>cursorThing;
            }
            cursorThing+"\010"=>cursorThing;
            for(0=>int i;i<14-pos;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }
        pD.setSegment(2,0,cursorThing);
        pD.updateDisplay();
    }
}
