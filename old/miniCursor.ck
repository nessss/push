// miniCursor.ck



PushDisplay pD;
PushCCs pCC;

string cursorThing;
float pos;
float inc;
int touchMode;

init();
while(samp=>now);

fun void init(){
    ""   =>cursorThing;
    0.5  =>        pos;
    0.005=>        inc;
    0    =>  touchMode;
    
    pD.clearDisplay();
    cursorUpdate();
    spork~control();
}

fun void control(){
    MidiIn min;
    MidiMsg msg;
    min.open(2);
    <<<min.name()>>>;
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
                        if(touchMode){
                            cursorUpdate();
                        }
                    }
                    else{
                        if(touchMode){
                            pD.clearDisplay();
                        }
                    }
                }
            }
            if(msg.data1==0x80){
                if(msg.data2==pCC.touch[0]){
                }
            }
        }
    }
}

fun void cursorUpdate(){
    Math.round(pos*16)$int=>int iPos;
    //<<<pos>>>;
    if(1){
        displayCursor(0,0,0,iPos);
        displayCursor(0,1,1,iPos);
        displayCursor(0,2,2,iPos);
        displayCursor(0,3,3,iPos);
    }
}

fun void displayCursor(int c,int r,int style,int iPos){
    if(style==0){
        if(iPos==0){
            "\005"=>cursorThing;
            for(0=>int i;i<15;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }else if(iPos==16){
            "\003"=>cursorThing;
            for(0=>int i;i<15;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\005"=>cursorThing;
        }else{
            "\003"=>cursorThing;
            for(0=>int i;i<iPos-1;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\010"=>cursorThing;
            for(0=>int i;i<15-iPos;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }
        pD.setSegment(0,0,cursorThing);
        pD.updateDisplay();
    }
    else if(style==1){
        if(iPos==0){
            "\005"=>cursorThing;
        }
        else if(iPos==16){
            "\003"=>cursorThing;
            for(0=>int i;i<15;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }
        else{
            "\003"=>cursorThing;
            for(0=>int i;i<iPos-1;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\010"=>cursorThing;
            
        }
        pD.setSegment(1,0,cursorThing);
        pD.updateDisplay();
    }else if(style==2){
        if(iPos==0){
            "\003"=>cursorThing;
            for(0=>int i;i<15;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }
        else if(iPos==16){
            ""=>cursorThing;
            for(0=>int i;i<16;i++){
                cursorThing+" "=>cursorThing;
            }
            cursorThing+"\005"=>cursorThing;
        }
        else{
            " "=>cursorThing;
            for(0=>int i;i<iPos-1;i++){
                cursorThing+" "=>cursorThing;
            }
            cursorThing+"\010"=>cursorThing;
            for(0=>int i;i<15-iPos;i++){
                cursorThing+"\006"=>cursorThing;
            }
            cursorThing+"\004"=>cursorThing;
        }
        pD.setSegment(r,c,cursorThing);
        pD.updateDisplay();
    }else if(style==3){
        Math.round(pos*8)$int=>int iPos;
        ""=>cursorThing;
        for(0=>int i;i<Math.round(pos*17)$int;i++){
            "\005"+=>cursorThing;
        }
        if(((pos*34)$int %2)==1){
            for(0=>int i;i<17-iPos;i++){
                "\006"+=>cursorThing;
            }
        }else{
            "\003"+=>cursorThing;
            for(0=>int i;i<16-iPos;i++){
                "\006"+=>cursorThing;
            }
        }
        if(pos==1){
            cursorThing.substring(0,17)=>cursorThing;
        }
        pD.setSegment(r,c,cursorThing);
        pD.updateDisplay();
    }
}
