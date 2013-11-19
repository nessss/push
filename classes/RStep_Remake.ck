//A step sequencer for rhythms for Push
//June, 2013
public class RStep extends RhythmSequencer{ //n = number, p = pattern, m = master, h = horizontal, q = cue
    //Variables
    int nSounds, nSteps, nPats, cPat, cSound, pLen, hLen, minPort, moutPort, qL, qR;
    int muted, cued, focused, onClr, offClr, cursorClr, hiClr;
    float mPan, mRate, mGain, qGain;
    SndBuf sounds[]; //samples used by this RStep
    Pan2 gBus, mBus, qBus; // generalBus
    int firstPad[2]; int stepCCs[];
    //Objects
    Clock clock;
    Push push;
    MidiBroadcaster mB;
    RhythmSequencer rseq;
    //Midi
    MidiOut mout;
    MidiMsg msg;
    
    //Initializer/Constructor-------------------------------------------
    //starting row, column, horizontal rule, num pats, num steps, sample locations, midi in port, out port, mst outs, cue outs
    fun void init(MidiBroadcaster m, MidiOut mo, int x, int y, int hl, int np){
        m @=> mB;
        mo @=> mout;
        x => firstPad[0];
        y => firstPad[1];
        hl => hLen;
        np => nPats;
        ns => nSteps;
        nSteps => pLen;
        
        clock.init();
        rseq.init();
        
        0 => muted, cued, cPat, cSound, mPan;
        0.5 => mGain => qGain;
        1 => focused, mRate;
        qGain => qBus.gain;
        //Colors
        9 => onClr; 
        0 => offClr;
        22 => cursorClr;
        21 => hiClr; //color displayed when cursor is on a step that's on
        
        clearAll();
        //Signal routing
        for(0 => int i; i<nSounds; i++){   //!!! CHECK IN HERE !!!
            gBus;
        }
        gBus => mBus;
        gBus => qBus;
        
        push.ccInit();
        int tempStepCCs[nSteps] @=> stepCCs; //Array of CCs
        for(0 => int i; i<hLen; i++){
            for(0 => int j; j<nSteps/hLen; j++){
                push.grid[firstPad[0]+i][firstPad[1]-j] => stepCCs[i+(j*hLen)];
            }
        }
        
        //Sporks
    }
    fun void init(MidiBroadcaster m, MidiOut mo, string s[]){
        init(m,mo,0,7,8,8,64,s);
    }
    
    //Play Functions---------------------------------------------------
    fun void play(){
                          //TRANSLATE THIS !!!!!
    }
    
    fun void midiIn(){
        MidiMsg msg;
        while(mB.mev=>now){
            mB.mev.msg @=> msg;
            if(focused){
                if(msg.data1==0x90){
                    for(0 => int i; i<nSteps; i++){
                        if(msg.data2 == stepCCs[i]){ 
                            if(pats[cPat][i]){
                                0 => pats[cPat][i];
                                midiOut(0x90, stepCCs[i], offClr);
                            }
                            else{
                                1 => pats[cPat][i]; 
                                midiOut(0x90, stepCCs[i], onClr);
                            }
                        }
                    }
                    updateGrid();
                }
            }
        }
    }
    
    fun void updateGrid(){ //updates step grid. if step is playing, highlight it
        for(0 => int i; i<stepCCs.cap(); i++){ 
            if(clock.step.i % pLen != i | !clock.isPlaying()){
                if(pats[cPat][i]) midiOut(0x90, stepCCs[i], onClr);
                else midiOut(0x90, stepCCs[i], offClr);
            }
        }
    }
    
     
    fun int cue(){ return cued; }
    fun int cue(int c){
        if(!c){
            0 => cued;
            0 => qBus.gain;
        }
        else{
            1 => cued;
            qGain => qBus.gain;
        }
        return cued;
    }
    
    fun int mute(){ return muted; }
    fun int mute(int m){
        if(!m) 0 => muted;
        else 1 => muted;
        return muted;
    }
    
    fun int focus(){ return focused; }
    fun int focus(int f){
        if(!f) 0 => focused;
        else 1 => focused;
        return focused;
    }
    
    fun int curPat(){ return cPat; }
    fun int curPat(int cp){
        if(cp>=0 & cp<nPats) cp => cPat;
        return cPat;
    }
    
    fun int patLen(){ return pLen; }
    fun int patLen(int pl){
        if(pl>0) pl => pLen;
        return pLen;
    }
    
    fun float gain(){ return mGain; } 
    fun float gain(float ng){
        sanityCheck(ng) => mGain;
        return mGain;
    }    
    
    fun float cueGain(){ return qBus.gain();}
    fun float cueGain(float ng){
        sanityCheck(ng) => qBus.gain;
        return qBus.gain();
    }
    
    fun float pan(){ return mPan; }
    fun float pan(float np){
        if(np>=0 & np<=1){
            np*2 - 1 => mPan;
            mPan => mBus.pan, qBus.pan;
            return mPan;
        }
        else if(np<0) return pan(0);
        else return pan(1);
    }
    
    
    //Color Functions-------------------------------------------------
    fun int onColor(){ return onClr; }
    fun int onColor(int nc){
        nc => onClr;
        return onClr;
    }
    
    fun int offColor(){ return offClr; }
    fun int offColor(int nc){
        nc => offClr;
        return offClr;
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
    
    //Utilities    
    fun void midiOut(int d1, int d2, int d3){
        d1 => msg.data1;
        d2 => msg.data2;
        d3 => msg.data3;
        mout.send(msg);
    }   
    
     fun float sanityCheck(float f){ //clips to 0.0-1.0
        if(f<0) return 0.0;
        else if(f>1) return 1.0;
        else return f;
    }
    
}