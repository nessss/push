// miniCursor.ck


public class PushKnob{
    PushDisplay pD;
    PushCCs pCC;
    
    MidiIn min;
    MidiMsg msg;
    
    string cursorThing;
    string label;
    
    int myKnob;      // which knob
    int value;
    int valX;      // location for value and display
    int valY;
    int display;
    int displayX;
    int displayY;
    int touchMode; // visible only on touch
    int inFocus;
    int touched;
    
    float myPos;
    float inc;
    
    Event shiftOn;
    Event shiftOff;
    Event moved;
    Event touchOn;
    Event touchOff;
    Event increment;
    Event decrement;
    
    //=========== FUNCTIONS ============
    
    fun void init(){
        0    =>     myKnob;
        ""   =>cursorThing;
        0.5  =>      myPos;
        0.005=>        inc;
        1    =>  touchMode;
        0    =>       valX;
        0    =>       valY;
        0    =>   displayX;
        1    =>   displayY;
        1    =>      value;
        1    =>    display;
        1    =>    inFocus;
        
        pD.clearDisplay();
        cursorUpdate();
        spork~control(1);
        spork~shiftListen();
    }
    
    fun void init(int iKnob,int iValX,int iValY,int iDisplayX, int iDisplayY, int iTouchMode,PushDisplay iPD,int port,string iLabel){
        if(iKnob>=0&iKnob<11)iKnob=>myKnob;
        else -1=>myKnob;
        if(iValX>=0&iValX<8)iValX=>valX;
        else -1=>valX;
        if(iValY>=0&iValY<4)iValY=>valY;
        else -1=>valY;
        if(iDisplayX>=0&iDisplayX<8)iDisplayX=>displayX;
        else -1=>displayX;
        if(iDisplayY>=0&iDisplayY<4)iDisplayY=>displayY;
        else -1=>displayY;
        if(iTouchMode==0|iTouchMode==1)iTouchMode=>touchMode;
        else 0=>touchMode;
        iPD@=>pD;
        1=>value;
        1=>display;
        1=>inFocus;
        
        if(iLabel.length()>8){
            iLabel.substring(8)=>label;
        }else if(iLabel.length()<8){
            while(iLabel.length()<8){
                " "+=>iLabel;
            }
        }
        
        ""   =>cursorThing;
        0.5  =>      myPos;
        0.005=>        inc;
        
        if(!touchMode){
            pD.clearDisplay();
            cursorUpdate();
        }
        spork~control(port);
        spork~shiftListen();
    }
    
    fun int knob(){
        return myKnob;
    }
    
    fun int knob(int nKnob){
        nKnob=>myKnob;
        return myKnob;
    }
    
    fun float pos(){
        return myPos;
    }
    
    fun float pos(float nPos){
        nPos=>myPos;
        return myPos;
    }
    
    fun int displaysValue(){
        return value;
    }
    
    fun int displaysValue(int d){
        d=>value;
        return value;
    }
    
    fun int displaysCursor(){
        return display;
    }
    
    fun int displaysCursor(int d){
        d=>display;
        return display;
    }
    
    fun int getValuePosX(){
        return valX;
    }
    
    fun int getValuePosY(){
        return valY;
    }
    
    fun void setValuePos(int x,int y){
        x=>valX;
        y=>valY;
    }
    
    fun int getDisplayPosX(){
        return displayX;
    }
    
    fun int getDisplayPosY(){
        return displayY;
    }
    
    fun void setDisplayPos(int x,int y){
        x=>displayX;
        y=>displayY;
    }
    
    fun int focus(){
        return inFocus;
    }
    
    fun int focus(int f){
        f=>inFocus;
        if(inFocus){
            if(touched){
                cursorUpdate();
            }
        }else{
            if(!touched){
                clearValue();
                clearCursor();
            }
        }
        return inFocus;
    }
    
    fun void control(int port){
        MidiIn min;
        MidiMsg msg;
        min.open(port);
        <<<min.name()>>>;
        while(min=>now){
            while(min.recv(msg)){
                if(msg.data1==0xB0){
                    if(inFocus){
                        if(msg.data2==pCC.knobs[myKnob]){
                            if(msg.data3<64){
                                msg.data3*inc+=>myPos; // increment
                                increment.broadcast();
                            }else{
                                (128-msg.data3)*inc-=>myPos;      // decrement
                                decrement.broadcast();
                            }
                            if(myPos>1)1=>myPos;       // clip to 0 and 1
                            if(myPos<0)0=>myPos;
                            cursorUpdate();
                            moved.broadcast();
                        }
                    }else if(msg.data2==pCC.bcol0[0]){
                        if(msg.data3==0x7F)shiftOn.broadcast();   
                        else shiftOff.broadcast();                 
                    }
                }
                if(msg.data1==0x90){
                    if(msg.data2==pCC.touch[myKnob]){
                        if(msg.data3==127){
                            if(touchMode){
                                if(inFocus){
                                    cursorUpdate();
                                }
                                touchOn.broadcast();
                                1=>touched;
                            }
                        }
                        else{
                            if(touchMode){
                                if(inFocus){
                                    clearCursor();
                                    clearValue();
                                }
                                touchOff.broadcast();
                                0=>touched;
                            }
                        }
                    }
                }
            }
        }
    }
    
    fun void shiftListen(){
        while(true){
            shiftOn=>now;
            0.4*=>inc;
            shiftOff=>now;
            2.5*=>inc;
        }
    }
    
    fun void cursorUpdate(){
        Math.round(myPos*16)$int=>int iPos;
        //<<<myPos>>>;
        if(inFocus){
            if(display){
                displayCursor(displayX,displayY,3,iPos);
            }
            if(value){
                if(valX%2==0){
                    pD.getSegment((valX*0.5)$int,valY)=>string seg;
                    seg.replace(0,8,Std.ftoa(myPos,6));
                    pD.setSegment((valX*0.5)$int,valY,seg);
                }else{
                    pD.getSegment((valX*0.5)$int,valY)=>string seg;
                    seg.replace(9,Std.ftoa(myPos,6));
                    pD.setSegment((valX*0.5)$int,valY,seg);
                }
            }
            if(display|value)pD.updateDisplay();
        }
    }
    
    fun void clearValue(){
        if(valX%2==0){
            pD.getSegment((valX*0.5)$int,valY)=>string seg;
            seg.replace(0,8,"        ");
            pD.setSegment((valX*0.5)$int,valY,seg);
        }else{
            pD.getSegment((valX*0.5)$int,valY)=>string seg;
            seg.replace(9,"        ");
            pD.setSegment((valX*0.5)$int,valY,seg);
        }
        pD.updateDisplay();
    }
    
    fun void clearCursor(){
        if(valX%2==0){
            pD.getSegment((displayX*0.5)$int,displayY)=>string seg;
            seg.replace(0,8,"        ");
            pD.setSegment((displayX*0.5)$int,displayY,seg);
        }else{
            pD.getSegment((displayX*0.5)$int,displayY)=>string seg;
            seg.replace(9,"        ");
            pD.setSegment((displayX*0.5)$int,displayY,seg);
        }
        pD.updateDisplay();
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
            pD.setSegment(c,r,cursorThing);
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
            pD.setSegment(c,r,cursorThing);
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
            Math.round(myPos*8)$int=>int iPos;
            ""=>cursorThing;
            for(0=>int i;i<Math.round(myPos*8)$int;i++){
                "\005"+=>cursorThing;
            }
            if(((myPos*16)$int %2)==1){
                for(0=>int i;i<8-iPos;i++){
                    "\006"+=>cursorThing;
                }
            }else{
                "\003"+=>cursorThing;
                for(0=>int i;i<7-iPos;i++){
                    "\006"+=>cursorThing;
                }
            }
            if(myPos==1){
                cursorThing.substring(0,8)=>cursorThing;
            }
            if(c%2==0){
                pD.getSegment((c*0.5)$int,r)=>string seg;
                seg.replace(0,8,cursorThing);
                pD.setSegment((c*0.5)$int,r,seg);
            }else{
                pD.getSegment((c*0.5)$int,r)=>string seg;
                seg.replace(9,cursorThing);
                pD.setSegment((c*0.5)$int,r,seg);
            }
            pD.updateDisplay();
        }
    }
}
