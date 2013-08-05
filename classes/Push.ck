//  Push class
//  interfacing tools for Push
//  LCD display functions and organized CCs
//  Bruce Lott & Mark Morris 2013

// 0xF0 0x47 0x7F 0x15 [line] 0x0 0x45 0x0 [ASCII chars 0-67] 0xF7
public class Push{
    MidiOut mout;
    MidiMsg msg;
    string lines[4];  // 68 characters long, in 4 groups of 17
    int lineLen;
    string emptyLine;
    //CC you can compare to data2's 
    int grid[8][8]; //x-y
    int sel[8][2];   
    int knobs[11];
    int touch[11];  //0x90
    int bcol0[12];
    int bcol1[10];
    int bcol2[11];
    int bcol3[11];
    int left;
    int right;
    int up;
    int down;
    int pbtouch; //0x90; 0xE0 for value
    
    
    8=>int GRID_WIDTH;
    8=>int GRID_HEIGHT;
    8=>int SEL_WIDTH;
    2=>int SEL_HEIGHT;
    11=>int KNOBS;
    8=>int DISPLAY_KNOBS;
    
    44=>left;
    45=>right;
    46=>up;
    47=>down;
    12=>pbtouch;
    
	int myRainbow[8][3]; 05=>myRainbow[0][0]; 06=>myRainbow[0][1];
	07=>myRainbow[0][2]; 09=>myRainbow[1][0]; 10=>myRainbow[1][1];
	11=>myRainbow[1][2]; 13=>myRainbow[2][0]; 14=>myRainbow[2][1];
	15=>myRainbow[2][2]; 21=>myRainbow[3][0]; 22=>myRainbow[3][1];
	23=>myRainbow[3][2]; 29=>myRainbow[4][0]; 30=>myRainbow[4][1];
	31=>myRainbow[4][2]; 41=>myRainbow[5][0]; 42=>myRainbow[5][1];
	43=>myRainbow[5][2]; 45=>myRainbow[6][0]; 46=>myRainbow[6][1];
	47=>myRainbow[6][2]; 49=>myRainbow[7][0]; 50=>myRainbow[7][1];
	51=>myRainbow[7][2];
    

    //============= --| INITIALIZER |-- =============
    
    fun void init(){
        ccInit();
        /*
		for(0 => int i; i<GRID_WIDTH; i++){
			for(0 => int j; j<GRID_HEIGHT; j++){
        		<<<grid[i][j]>>>;
        	}
        }
        */
        moutInit() @=> mout;
        68=>lineLen;
        for(0=>int i;i<lineLen;i++){
            "\040"+=>emptyLine;
        }
        for(0=>int i;i<lines.cap();i++){
            line(i,emptyLine);
        }
    }
    
    fun int rainbow(int color, int brite){
    	if((color>7|color<0)|(brite>2|brite<0)){
    		return 0;
    	}else return myRainbow[color][brite];
    }
    
	fun void ccInit(){
		//grid buttons
		for(0 => int i; i<GRID_WIDTH; i++){
			for(0 => int j; j<GRID_HEIGHT; j++){
				36 + i + (8*j) => grid[i][j];
				//i=>grid[Std.itoa(92 + j - (8*i))]["x"];
				//j=>grid[Std.itoa(92 + j - (8*i))]["y"];
			}
		}
		for(0 => int i; i<SEL_WIDTH; i++){
			20 + i  => sel[i][0];
			102 + i => sel[i][1];
		}
		//knobs
		for(0 => int i; i<DISPLAY_KNOBS; i++){
			71 + i => knobs[i];
		}
		for(0 => int i; i<KNOBS; i++){
			i => touch[i];
		}
		
		79 => knobs[8];
		14 => knobs[9];
		15 => knobs[10];
		8 => touch[8];
		10 => touch[9];
		9 => touch[10];
		3 => bcol0[0];
		9 => bcol0[1];
		
		for(0=>int i;i<4;i++){
			119-i=>bcol0[i+2];
		}
		for(0=>int i;i<6;i++){
			90-i=>bcol0[i+6];
		} 
		//bcol1
		28 => bcol1[0];
		29 => bcol1[1];
		
		for(0 => int i; i<8; i++) 43 - i => bcol1[i+2];
		for(0 => int i; i<3; i++){
			114 - (i*2) => bcol2[i];
			115 - (i*2) => bcol3[i];
		}
		for(0 => int i; i<8; i++){
			62 - (i*2) => bcol2[i+3];
			63 - (i*2) => bcol3[i+3];
		}
	}
    
    
    fun MidiOut moutInit(){
        MidiOut moutCheck[16];
        for(0 => int i; i<moutCheck.cap(); i++){
            moutCheck[i].printerr(0);
            if(moutCheck[i].open(i)){
                if(moutCheck[i].name()=="Ableton Push Live Port"){
                    return moutCheck[i];
                }       
            }else return null;
        }
    }
    
    
    fun int inGrid(int a){
        0=>int result;
        for(0=>int i;i<GRID_WIDTH;i++){
            for(0=> int j;j<GRID_HEIGHT;j++)if(a==grid[i][j])1=>result;
        }
        return result;
    }
    
    fun int inSel(int a){
        0=>int result;
        for(0=>int i;i<8;i++){
            for(0=> int j;j<2;j++)if(a==sel[i][j])1=>result;
        }
        return result;
    }
    
    fun int gridX(int a){
        -1=>int result;
        for(0=>int i;i<GRID_WIDTH;i++){
            for(0=> int j;j<GRID_HEIGHT;j++)if(a==grid[i][j])i=>result;
        }
        return result;
    }
    
    fun int gridY(int a){
        -1=>int result;
        for(0=>int i;i<GRID_WIDTH;i++){
            for(0=> int j;j<GRID_HEIGHT;j++)if(a==grid[i][j])j=>result;
        }
        return result;
    }
    
    //----------------STRING INTERFACE----------------
    
    // entire display
    fun string[] display(){return lines;}
    
    fun string[] display(string nD[]){
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
    fun string line(int l){
        if(l>=0&l<lines.cap()){
            return lines[l];
        }else return "no line "+l;
    }
    
    fun string line(int l,string nL){
        if(l>=0&l<lines.cap()){
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
    fun string segment(int s,int l){
        if((l>=0&l<4)&&(s>=0&s<4)){
            if(s==3){
                return lines[l].substring(51);
            }else return lines[l].substring(s*17,17);
        }else return "no segment "+s+" on line "+l;
    }
    
    fun string segment(int s,int l,string nS){
        if((l>=0&l<4)&&(s>=0&s<4)){
            if(nS.length()<=17){
                while(nS.length()<17)nS+" "=>nS;
                if(s==3)lines[l].replace(51,nS);
                else lines[l].replace(s*17,17,nS);
            }else lines[l].replace(s*17,17,nS.substring(0,17));
            return segment(s,l);
        }else return "no segment "+s+" on line "+l;
    }
    
    // subsegment
    fun string subsegment(int s,int l){
        if((l>=0&l<4)&&(s>=0&s<8)){
            if(s%2==0){
                return segment((s*0.5)$int,l).substring(0,8);
            }else return segment((s*0.5)$int,l).substring(9);
        }else return "no subsegment "+s+" on line "+l;
    }
    
    fun string subsegment(int s,int l,string nS){
        if((l>=0&l<4)&&(s>=0&s<8)){
            if(nS.length()<=8){
                while(nS.length()<8)" "+=>nS;
                string seg;
                if(s%2==0){
                    segment((s*0.5)$int,l)=>seg;
                    seg.replace(0,8,nS);
                }else{
                    segment((s*0.5)$int,l)=>seg;
                    seg.replace(9,nS);
                }
                segment((s*0.5)$int,l,seg);
                return subsegment(s,l);
            }else{ // truncate input string
                return subsegment(s,l,nS.substring(0,8));
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
		if(l>=0&l<4){
			line(l,"");
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