// pushDisplay.ck
//  a quest to make an interface to easily write to
//  push's LCD display
//  Bruce Lott & Mark Morris 2013

// 0xF0 0x47 0x7F 0x15 [line] 0x0 0x45 0x0 [ASCII chars 0-67] 0xF7
public class PushDisplay{
    MidiOut mout;
    MidiMsg msg;
    string lines[4];  // 68 characters long, in 4 groups of 17
    int lineLen;
    string emptyLine;
    
    fun void init(MidiOut mo){
        mo @=> mout;
        
        68=>lineLen;
        for(0=>int i;i<lineLen;i++){
            "\040"+=>emptyLine;
        }
        for(0=>int i;i<lines.cap();i++){
            setLine(i,emptyLine);
        }
    }
    
    //----------------STRING INTERFACE----------------
    
    // entire display
    fun string[] getDisplay(){
        return lines;
    }
    
    fun string[] setDisplay(string nD[]){
        if(nD.cap()==4){
            for(0=>int i;i<4;i++){
                if(nD[i].length()!=68){
                    if(nD[i].length()>68){
                        nD[i].substring(0,68)=>nD[i];
                    }
                    while(nD[i].length()<68){
                        " "+=>nD[i];
                    }
                }
            }
            nD@=>lines;
            return lines;
        }else{
            <<<"String array not of capacity 4">>>;
            return nD;
        }
    }
    
    // line
    fun string getLine(int l){
        if(l>=0&l<4){
            return lines[l];
        }else return "no line "+l;
    }
    
    fun string setLine(int l,string nL){
        if(l>=0&l<4){
            if(nL.length()<=68){
                while(nL.length()<68)nL+" "=>nL;
                nL=>lines[l];
            }else{
                nL.substring(0,68)=>lines[l];
            }
            return lines[l];
        }else return "no line "+l;
    }
    
    // segment
    fun string getSegment(int s,int l){
        if((l>=0&l<4)&&(s>=0&s<4)){
            if(s==3){
                return lines[l].substring(51);
            }else return lines[l].substring(s*17,17);
        }else return "no segment "+s+" on line "+l;
    }
    
    fun string setSegment(int s,int l,string nS){
        if((l>=0&l<4)&&(s>=0&s<4)){
            if(nS.length()<=17){
                while(nS.length()<17)nS+" "=>nS;
                if(s==3)lines[l].replace(51,nS);
                else lines[l].replace(s*17,17,nS);
            }else lines[l].replace(s*17,17,nS.substring(0,17));
            return getSegment(s,l);
        }else return "no segment "+s+" on line "+l;
    }
    
    // subsegment
    fun string getSubsegment(int s,int l){
        if((l>=0&l<4)&&(s>=0&s<8)){
            if(s%2==0){
                return getSegment((s*0.5)$int,l).substring(0,8);
            }else return getSegment((s*0.5)$int,l).substring(9);
        }else return "no subsegment "+s+" on line "+l;
    }
    
    fun string setSubsegment(int s,int l,string nS){
        if((l>=0&l<4)&&(s>=0&s<8)){
            if(nS.length()<=8){
                while(nS.length()<8)" "+=>nS;
                string seg;
                if(s%2==0){
                    getSegment((s*0.5)$int,l)=>seg;
                    seg.replace(0,8,nS);
                }else{
                    getSegment((s*0.5)$int,l)=>seg;
                    seg.replace(9,nS);
                }
                setSegment((s*0.5)$int,l,seg);
                return getSubsegment(s,l);
            }else{ // truncate input string
                return setSubsegment(s,l,nS.substring(0,8));
            }
        }else return "no subsegment "+s+" on line "+l;
    }
    
    
    
    //----------------UPDATE FUNCTIONS----------------
    
    fun void clearDisplay(){
        for(0=>int i;i<lines.cap();i++){
            clearLine(i);
        }
    }
    
    fun void clearLine(int l){
        setLine(l,"");
        0xF0=>msg.data1;
        0x47=>msg.data2;
        0x7F=>msg.data3;
        mout.send(msg);
        0x15=>msg.data1;
        0x1C+l=>msg.data2;
        0=>msg.data3;
        mout.send(msg);
        0=>msg.data1;
        0xF7=>msg.data2;
        0=>msg.data3;
        mout.send(msg);
    }
    
    fun void updateDisplay(){
        for(0=>int i;i<lines.cap();i++){
            updateLine(i);
        }
    }
    
    fun void updateLine(int l){
        if(l<4&l>=0){
            0xF0=>msg.data1;
            0x47=>msg.data2;
            0x7F=>msg.data3;
            mout.send(msg);
            0x15=>msg.data1;
            0x18+l=>msg.data2;
            0=>msg.data3;
            mout.send(msg);
            0x45=>msg.data1;
            0=>msg.data2;
            lines[l].charAt(0)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(1)=>msg.data1;
            lines[l].charAt(2)=>msg.data2;
            lines[l].charAt(3)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(4)=>msg.data1;
            lines[l].charAt(5)=>msg.data2;
            lines[l].charAt(6)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(7)=>msg.data1;
            lines[l].charAt(8)=>msg.data2;
            lines[l].charAt(9)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(10)=>msg.data1;
            lines[l].charAt(11)=>msg.data2;
            lines[l].charAt(12)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(13)=>msg.data1;
            lines[l].charAt(14)=>msg.data2;
            lines[l].charAt(15)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(16)=>msg.data1;
            lines[l].charAt(17)=>msg.data2;
            lines[l].charAt(18)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(19)=>msg.data1;
            lines[l].charAt(20)=>msg.data2;
            lines[l].charAt(21)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(22)=>msg.data1;
            lines[l].charAt(23)=>msg.data2;
            lines[l].charAt(24)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(25)=>msg.data1;
            lines[l].charAt(26)=>msg.data2;
            lines[l].charAt(27)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(28)=>msg.data1;
            lines[l].charAt(29)=>msg.data2;
            lines[l].charAt(30)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(31)=>msg.data1;
            lines[l].charAt(32)=>msg.data2;
            lines[l].charAt(33)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(34)=>msg.data1;
            lines[l].charAt(35)=>msg.data2;
            lines[l].charAt(36)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(37)=>msg.data1;
            lines[l].charAt(38)=>msg.data2;
            lines[l].charAt(39)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(40)=>msg.data1;
            lines[l].charAt(41)=>msg.data2;
            lines[l].charAt(42)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(43)=>msg.data1;
            lines[l].charAt(44)=>msg.data2;
            lines[l].charAt(45)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(46)=>msg.data1;
            lines[l].charAt(47)=>msg.data2;
            lines[l].charAt(48)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(49)=>msg.data1;
            lines[l].charAt(50)=>msg.data2;
            lines[l].charAt(51)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(52)=>msg.data1;
            lines[l].charAt(53)=>msg.data2;
            lines[l].charAt(54)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(55)=>msg.data1;
            lines[l].charAt(56)=>msg.data2;
            lines[l].charAt(57)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(58)=>msg.data1;
            lines[l].charAt(59)=>msg.data2;
            lines[l].charAt(60)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(61)=>msg.data1;
            lines[l].charAt(62)=>msg.data2;
            lines[l].charAt(63)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(64)=>msg.data1;
            lines[l].charAt(65)=>msg.data2;
            lines[l].charAt(66)=>msg.data3;
            mout.send(msg);
            lines[l].charAt(67)=>msg.data1;
            0xF7=>msg.data2;
            0=>msg.data3;
            mout.send(msg);
        }else<<<"cannot update line "+l>>>;
    }
}