//A step sequencer for pitches for Push
public class PStep{
    int nPages, pLen, nSteps, nPats, cPage;
    int muted, cued, focused, pPlay, pEdit; //pages of 8 pitches
    int pOnClr, pDimClr, pOffClr; //pitch colors
    int nOnClr, nOffClr; //note on colors
    int tOnClr, tOffClr; //tie on colors
    int cursorClr, hiClr;
    float root, viewAdj, trans;
    DataEvent pitch, gate; //gate has velocity, float 0 -1
    MidiOut mout;
    MidiMsg msg;
    RhythmClock clock;
    Push push;
    MidiBroadcaster mB;
    int tie[][]; int noteOn[][];  //tie to previous note tie[pattern][step]
    float pitches[][];
    
    //Initializer
    fun void init(MidiBroadcaster m, MidiOut mo, Push p, int np, int npg){
		p @=> push;
        m @=> mB;
        mo @=> mout;
        np => nSteps;
        npg => nPages;
        nPages*8 => nSteps => pLen;
        focus(1);
        0 => muted => cued => pPlay => pEdit => cPage; 
        0 => pOffClr;
		0  => nOffClr => tOffClr;
        21 => pOnClr; 
		24 => tOnClr;
		25 => nOnClr;
        19 => pDimClr;
        0.0 => viewAdj => trans;
        60.0 => root;
        new float[nSteps][nPages*8] @=> pitches;
        new int[nSteps][nPages*8] @=> tie @=> noteOn;
        for(int i; i<nSteps; i++){
            for(int j; j<nPages*8; j++){
                root => pitches[i][j];
            }
        }
        spork ~ play();
        spork ~ gridButtons();
        spork ~ onButtons();
        spork ~ tieButtons();
    }
    //Functions
    fun void play(){
        while(clock.step => now){
            if(!muted){
                if(!tie[pPlay][clock.step.i % pLen]){
                    1.0 => gate.f;
                    gate.broadcast();
                }
                if(noteOn[pPlay][clock.step.i % pLen]){
                    pitches[pPlay][clock.step.i%pLen] => pitch.f;
                    pitch.broadcast();
                }
            }
        }
    }
    
    fun void updateStep(int x, int y){
        y+root+viewAdj => pitches[pEdit][x+(cPage*8)];
        for(int i; i<8; i++) midiOut(0x90, push.grid[x][i], pOffClr); //clear column
        if(noteOn[pEdit][x+(cPage*8)]){
            midiOut(0x90, push.grid[x][y], pOnClr);
        }
        else midiOut(0x90, push.grid[x][y], pDimClr);
    }
    
    fun void updateGrid(){
        for(int i; i<8; i++){ //Clear grid
            for(int j; j<8; j++) midiOut(0x90, push.grid[i][j], pOffClr);
        }
        for(int i; i<8; i++){
            if(pitches[pEdit][i+(cPage*8)] > root+viewAdj){ //if pitch is in page range
                if(pitches[pEdit][i+(cPage*8)] < root+viewAdj+8){
                    if(noteOn[pEdit][i+(cPage*8)]){ //if note is on
                        midiOut(0x90, push.grid[i][(pitches[pEdit][i+(cPage*8)]-root+viewAdj) $ int], pOnClr);
                    }else midiOut(0x90, push.grid[i][(pitches[pEdit][i+(cPage*8)]-root+viewAdj) $ int], pDimClr);
                }
            }
        }
    }
    
    fun void gridButtons(){
        MidiMsg msg;
        while(mB.mev=>now){
            if(focused){
                mB.mev.msg @=> msg;
                if(msg.data1==0x90){
                    for(int i; i<8; i++){
                        for(int j; j<8; j++){
                            if(push.grid[i][j]==msg.data2){
                                updateStep(i,j);
                            }
                        }
                    }
                }
            }
        }
    }
    
    fun void onButtons(){
        MidiMsg msg;
        while(mB.mev=>now){
            if(focused){
                mB.mev.msg @=> msg;
                if(msg.data1==0xB0 & msg.data3){
                    for(int i; i<8; i++){
                        if(msg.data2==push.sel[i][0]){
                            if(noteOn[pEdit][i+(cPage*8)]){
                                0 => noteOn[pEdit][i+(cPage*8)];
                                midiOut(0x0,push.sel[i][0], nOffClr);
                                <<<"noteOff: 0">>>;
                                updateStep(i+cPage*8,pitches[pEdit][i+(cPage*8)]$int);
                            }else{
                                1 => noteOn[pEdit][i+(cPage*8)];
                                midiOut(0xB0, push.sel[i][0], nOnClr);
                                <<<"noteOn: 1">>>;
                                updateStep(i+cPage*8,pitches[pEdit][i+(cPage*8)]$int);
                            }
                        }
                    }
                }
            }
        }
    }    
    
    fun void tieButtons(){
        MidiMsg msg;
        while(mB.mev=>now){
            mB.mev.msg @=> msg;
            if(focused){
                if(msg.data1==0xB0 & msg.data3){
                    for(int i; i<8; i++){
                        if(msg.data2==push.sel[i][1]){
                            if(tie[pEdit][i+(cPage*8)]){
                                0 => tie[pEdit][i+(cPage*8)];
                                midiOut(0xB0,push.sel[i][1], tOffClr);
                                <<<"tie: 0">>>;
                            }else{
                                1 => tie[pEdit][i+(cPage*8)];
                                midiOut(0xB0, push.sel[i][1], tOnClr);
                                <<<"tie: 1">>>;
                            }
                        }
                    }
                }
            }
        }
    }
    
    fun int focus(){ return focused; }
    fun int focus(int nf){
        if(nf) 1 => focused;
        else 0 => focused;
        return focused;
    }
    
    fun int numPitchs(){ return nSteps; }
    
    fun int numSteps(){ return nSteps; }
    
    fun void midiOut(int d1, int d2, int d3){
        d1 => msg.data1;
        d2 => msg.data2;
        d3 => msg.data3;
        mout.send(msg);
    }
    
    //Color Functions-------------------------------------------------
    fun int pitchOnColor(){ return pOnClr; }
    fun int pOnColor(int nc){
        nc => pOnClr;
        return pOnClr;
    }
    
    fun int pitchDimColor(){ return pDimClr; }
    fun int pDimColor(int nc){
        nc => pDimClr;
        return pDimClr;
    }
    
    fun int pitchOffColor(){ return pOffClr; }
    fun int pitchOffColor(int nc){
        nc => pOffClr;
        return pOffClr;
    }
    
    fun int noteOnColor(){ return nOnClr; }
    fun int noteOnColor(int nc){
        nc => nOnClr;
        return nOnClr;
    }
    
    fun int noteOffColor(){ return nOffClr; }
    fun int noteOffColor(int nc){
        nc => nOffClr;
        return nOffClr;
    }
    
    fun int tieOnColor(){ return tOnClr; }
    fun int tieOnColor(int nc){
        nc => tOnClr;
        return tOnClr;
    }  
    
    fun int tieOffColor(){ return tOffClr; }
    fun int tieOffColor(int nc){
        nc => tOffClr;
        return tOffClr;
    }
    
    fun int cursorColor(){ return cursorClr; }
    fun int cursorColor(int nc){
        nc => cursorClr;
        return cursorClr;
    }
    
    fun int highlightColor(){ return hiClr; }
    fun int highlightColor(int nc){
        nc => hiClr;
        return hiClr;
    }
}
