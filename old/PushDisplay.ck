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
    
    fun void init(){
        mout.open(1);
        <<<mout.name()>>>;
        
        
        68=>lineLen;
        for(0=>int i;i<lineLen;i++){
            "\040"+=>emptyLine;
        }
        for(0=>int i;i<lines.cap();i++){
            setLine(i,emptyLine);
        }
    }
    
    //----------------STRING INTERFACE----------------
    
    fun string getLine(int l){
        if(l>=0&l<4){
            return lines[l];
        }else return "no line "+l;
    }
    
    fun string getSegment(int s,int l){
        if((l>=0&l<4)&&(s>=0&s<4)){
            if(s==3){
                return lines[l].substring(51);
            }else return lines[l].substring(s*17,17);
        }else return "no segment "+s+" on line "+l;
    }
    
    fun void setLine(int l,string nL){
        if(l>=0&l<4){
            if(nL.length()<=68){
                while(nL.length()<68)nL+" "=>nL;
                nL=>lines[l];
            }else <<<"line more than 68 characters long: "+nL.length()>>>;
        }else <<<"no line "+l>>>;
    }
    
    fun void setSegment(int s,int l,string nS){
        if((l>=0&l<4)&&(s>=0&s<4)){
            if(nS.length()<=17){
                while(nS.length()<17)nS+" "=>nS;
                if(s==3)lines[l].replace(51,nS);
                else lines[l].replace(s*17,17,nS);
            }else <<<"segment more than 17 characters long at "+nS.length()+" characters:",nS>>>;
        }else <<<"no segment "+s+" on line "+l>>>;
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