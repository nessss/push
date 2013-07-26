// PushKnob


public class PushKnob{
    PushDisplay pD;
    PushCCs pCC;
    
    MidiIn min;
    MidiMsg msg;
    
    string cursorThing;
    string myLabel;
    
    int myKnob;      // which knob
    
    int displayLabel;// whether to display or not
    int displayValue;
    int displayCursor;
    
    int labelX;      // location for display elements
    int labelY;
    int valX;        
    int valY;
    int cursorX;
    int cursorY;
    
    int touchMode;   // visible only on touch
    int touched;     // being touched currently (regardless of touchMode)
    
    int inFocus;     // only displays or reacts to input when in focus
    
    int selfUpdate;  // whether or not to update the PushDisplay object
    
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
    
    
    //======= --| INITIALIZERS |-- =====
    fun void init(){ // Default
        init(-1,0,pD,2,"");
    }
    
    fun void init(int iKnob,int iTouchMode,PushDisplay iPD,int port,string iLabel){
        if(iKnob>=0&iKnob<11){
            iKnob=>myKnob;
            if(iKnob<8){              //  Knobs 0-7, by default, display their info
                setLabelPos(iKnob,0); // directly below the knob in label, value,
                setValuePos(iKnob,1); // cursor order.
                setCursorPos(iKnob,2);
                
                displaysValue(1);
                displaysCursor(1);
                displaysLabel(1);
            }else{
                setLabelPos(0,0);    //  Knobs 8 & 9 do not display their info
                setValuePos(0,0);    // by default; any implementation that wishes
                setCursorPos(0,0);   // to display their info must either set the
                                     // position manually and set display values to
                displaysValue(0);    // a non-zero value or retrieve the information
                displaysCursor(0);   // and display it manually.
                displaysLabel(0);
            }
        }
        
        0=>selfUpdate;
        0=>inFocus;
        
        if(iTouchMode)1=>touchMode;
        else 0=>touchMode;
        
        iPD@=>pD;
        
        label(iLabel);
        
        ""   =>cursorThing;
        0.5  =>      myPos;
        0.005=>        inc;
        
        if(!touchMode){
            displayUpdate();
        }
        spork~control(port);
        spork~shiftListen();
    }
    
    //======= --| SETTERS & GETTERS |-- =====
    
    // knob
    fun int knob(){
        return myKnob;
    }
    
    fun int knob(int nKnob){
        nKnob=>myKnob;
        if(nKnob>10)-1=>myKnob;
        if(nKnob<0)-1=>myKnob;
        return myKnob;
    }
    
    // pos
    fun float pos(){
        return myPos;
    }
    
    fun float pos(float nPos){
        while(nPos>1)1-=>nPos;
        while(nPos<0)1+=>nPos;
        nPos=>myPos;
        return myPos;
    }
    
    // label
    fun string label(){
        return myLabel;
    }
    
    fun string label(string nLabel){
        if(nLabel.length()>8){
            nLabel.substring(8)=>myLabel;
        }else if(nLabel.length()<8){
            while(nLabel.length()<8){
                " "+=>nLabel;
            }
            nLabel=>myLabel;
        }else nLabel=>myLabel;
        return myLabel;
    }
    
    fun int displaysLabel(){
        return displayLabel;
    }
    
    fun int displaysLabel(int d){
        if(d)1=>displayLabel;
        else 0=>displayLabel;
        return displayLabel;
    }
    
    fun int labelPosX(){
        return labelX;
    }
    
    fun int labelPosX(int x){
        if(x>7)7=>x;
        if(x<0)0=>x;
        x=>labelX;
        return labelX;
    }
    
    fun int labelPosY(){
        return labelY;
    }
    
    fun int labelPosY(int y){
        if(y>7)7=>y;
        if(y<0)0=>y;
        y=>labelY;
        return labelY;
    }
    
    fun void setLabelPos(int x,int y){
        if(x>7)7=>x;
        if(x<0)0=>x;
        if(y>7)7=>y;
        if(y<0)0=>y;
        x=>labelX;
        y=>labelY;
    }
    
    // value
    fun int displaysValue(){
        return displayValue;
    }
    
    fun int displaysValue(int d){
        if(d)1=>displayValue;
        else 1=>displayValue;
        return displayValue;
    }
    
    fun int valuePosX(){
        return valX;
    }
    
    fun int valuePosX(int x){
        if(x>7)7=>x;
        if(x<0)0=>x;
        x=>valX;
        return valX;
    }
    
    fun int valuePosY(){
        return valY;
    }
    
    fun int valuePosY(int y){
        if(y>7)7=>y;
        if(y<0)0=>y;
        y=>valY;
        return valY;
    }
    
    fun void setValuePos(int x,int y){
        if(x>7)7=>x;
        if(x<0)0=>x;
        if(y>7)7=>y;
        if(y<0)0=>y;
        x=>valX;
        y=>valY;
    }
    
    // cursor
    fun int displaysCursor(){
        return displayCursor;
    }
    
    fun int displaysCursor(int d){
        if(d)1=>displayCursor;
        else 1=>displayCursor;
        return displayCursor;
    }
    
    fun int cursorPosX(){
        return cursorX;
    }
    
    fun int cursorPosX(int x){
        if(x>7)7=>x;
        if(x<0)0=>x;
        x=>cursorX;
        return cursorX;
    }
    
    fun int displayPosY(){
        return cursorY;
    }
    
    fun int cursorPosY(int y){
        if(y>7)7=>y;
        if(y<0)0=>y;
        y=>cursorY;
        return cursorY;
    }
    
    fun void setCursorPos(int x,int y){
        x=>cursorX;
        y=>cursorY;
    }
    
    // focus
    fun int focus(){
        return inFocus;
    }
    
    fun int focus(int f){
        f=>inFocus;
        if(inFocus){
            if(touchMode){
                if(touched){
                    displayUpdate();
                }
            }else displayUpdate();
        }else{
            if(!touched){
                clearValue();
                clearCursor();
            }
        }
        return inFocus;
    }
    
    //================= --| MIDI |-- ===============
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
                            displayUpdate();
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
                                    displayUpdate();
                                }
                                touchOn.broadcast();
                                pD.updateDisplay();
                                1=>touched;
                            }
                        }
                        else{
                            if(touchMode){
                                if(inFocus){
                                    clearCursor();
                                    clearValue();
                                    clearLabel();
                                }
                                touchOff.broadcast();
                                pD.updateDisplay();
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
    
    fun void displayUpdate(){
        Math.round(myPos*16)$int=>int iPos;
        if(inFocus){
            if(displayCursor)makeCursor(cursorX,cursorY,3,iPos);
            if(displayValue)pD.setSubsegment(valX,valY,Std.ftoa(myPos,6));
            if(displayLabel)pD.setSubsegment(labelX,labelY,myLabel);
            if((selfUpdate)&&(displayCursor|displayValue|displayLabel))pD.updateDisplay();
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
        if(selfUpdate)pD.updateDisplay();
    }
    
    fun void clearCursor(){
        if(cursorX%2==0){
            pD.getSegment((cursorX*0.5)$int,cursorY)=>string seg;
            seg.replace(0,8,"        ");
            pD.setSegment((cursorX*0.5)$int,cursorY,seg);
        }else{
            pD.getSegment((cursorX*0.5)$int,cursorY)=>string seg;
            seg.replace(9,"        ");
            pD.setSegment((cursorX*0.5)$int,cursorY,seg);
        }
        if(selfUpdate)pD.updateDisplay();
    }
    
    fun void clearLabel(){
        if(labelX%2==0){
            pD.getSegment((labelX*0.5)$int,labelY)=>string seg;
            seg.replace(0,8,"        ");
            pD.setSegment((labelX*0.5)$int,labelY,seg);
        }else{
            pD.getSegment((labelX*0.5)$int,labelY)=>string seg;
            seg.replace(9,"        ");
            pD.setSegment((labelX*0.5)$int,labelY,seg);
        }
        if(selfUpdate)pD.updateDisplay();
    }
    
    fun void makeCursor(int c,int r,int style,int iPos){
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
            if(selfUpdate)pD.updateDisplay();
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
            if(selfUpdate)pD.updateDisplay();
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
            if(selfUpdate)pD.updateDisplay();
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
            if(selfUpdate)pD.updateDisplay();
        }
    }
}
