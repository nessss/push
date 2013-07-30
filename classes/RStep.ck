//A step sequencer for rhythms for Push
//June, 2012
public class RStep{ //n = number, p = pattern, m = master, h = horizontal, q = cue
    //Variables
    int nSounds, nSteps, nPats, cPat, cSound, pLen, hLen, minPort, moutPort, qL, qR;
    int muted, cued, focused, onClr, offClr, cursorClr, hiClr;
    float mPan, mRate, mGain, qGain;
    SndBuf sounds[]; //samples used by this RStep
    Pan2 gBus, mBus, qBus; // generalBus
    int pats[][]; int firstPad[2]; int stepCCs[];
    //Objects
    RhythmClock theClock;
    Push thePush;
    MidiBroadcaster mB;
    //Midi
    MidiOut mout;
    MidiMsg msg;
    
    //Initializer/Constructor-------------------------------------------
    //starting row, column, horizontal rule, num pats, num steps, sample locations, midi in port, out port, mst outs, cue outs
    fun void init(MidiBroadcaster m, MidiOut mo, int x, int y, int hl, int np, int ns, string s[]){
        m @=> mB;
        mo @=> mout;
        x => firstPad[0];
        y => firstPad[1];
        hl => hLen;
        np => nPats;
        ns => nSteps;
        s.cap() => nSounds;
        nSteps => pLen;
        
        SndBuf soundsCap[nSounds] @=> sounds;
        
        0 => muted, cued, cPat, cSound, mPan;
        0.5 => mGain => qGain;
        1 => focused, mRate;
        qGain => qBus.gain;
        //Colors
        9 => onClr; 
        0 => offClr;
        22 => cursorClr;
        21 => hiClr; //color displayed when cursor is on a step that's on
        
        //Pats
        int tempPats[np][nSteps]; 
        tempPats @=> pats;
        int pubup[0][0] @=> tempPats;   // destroy array?
        
        clearAll();
        
        //SndBuf2 tempSounds[nSounds];    
        for(0 => int i; i<nSounds; i++){
            sounds[i].read(s[i]);
            sounds[i].samples() => sounds[i].pos;
        }
        //Signal routing
        for(0 => int i; i<nSounds; i++){ 
            sounds[i] => gBus;
        }
        gBus => mBus;
        gBus => qBus;
        
        thePush.ccInit();
        int tempStepCCs[nSteps] @=> stepCCs; //Array of CCs
        for(0 => int i; i<hLen; i++){
            for(0 => int j; j<nSteps/hLen; j++){
                thePush.grid[firstPad[0]+i][firstPad[1]-j] => stepCCs[i+(j*hLen)];
            }
        }
        normalizeSounds();
        //Sporks
        spork ~ play();
        spork ~ midiIn();
    }
    fun void init(MidiBroadcaster m, MidiOut mo, string s[]){
        init(m,mo,0,7,8,8,64,s);
    }
    
    //Play Functions---------------------------------------------------
    fun void play(){
        while(theClock.step => now){
            if(pats[cPat][theClock.step.i % pLen]){
                if(muted){ 
                    0 => mBus.gain;
                    trigger(cSound);
                }
                else{
                    mGain => mBus.gain;
                    trigger(cSound);
                }
            }
            if(focused){
                //Last step
                if(!pats[cPat][(theClock.step.i - 1 + pLen) % pLen]){ 
                    midiOut(0x90, stepCCs[(theClock.step.i - 1 + pLen) % pLen], offClr);
                }
                else midiOut(0x90, stepCCs[(theClock.step.i - 1 + pLen) % pLen], onClr);
                //This step
                if(pats[cPat][theClock.step.i % pLen]){ 
                    midiOut(0x90, stepCCs[theClock.step.i % pLen], hiClr);
                }
                else midiOut(0x90, stepCCs[theClock.step.i % pLen], cursorClr);
            }
        }
    }
    
    fun void trigger(int s){ //zero indexed
        if(s<nSounds & s>=0) 0 => sounds[s].pos;
        else <<<"Trigger out of bounds!">>>;
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
            if(theClock.step.i % pLen != i | !theClock.isPlaying()){
                if(pats[cPat][i]) midiOut(0x90, stepCCs[i], onClr);
                else midiOut(0x90, stepCCs[i], offClr);
            }
        }
    }
    //RStep functions--------------------------------------------------
    fun void connectMaster(UGen l, UGen r){
        mBus.left => l;
        mBus.right => r;
    }
    
    fun void connectQueue(UGen l, UGen r){
        qBus.left => l;
        qBus.right => r;
    }
    
    fun void normalizeSounds(){
        for(int i;i<sounds.cap();i++){
            normalizeSndBuf(sounds[i]);
        }
    }
    
    fun void normalizeSndBuf(SndBuf s){
        float max;
        for(int i;i<s.samples();i++){
            if(s.valueAt(i)>max)s.valueAt(i)=>max;
        }
        1.0/max=>s.gain;
    }
    
    fun int cue(){ return cued; }
    fun int cue(int c){
        if(c==0){
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
        if(m==0) 0 => muted;
        else 1 => muted;
        return muted;
    }
    
    fun int focus(){ return focused; }
    fun int focus(int f){
        if(f==0) 0 => focused;
        else 1 => focused;
        return focused;
    }
    
    fun void midiOut(int d1, int d2, int d3){
        d1 => msg.data1;
        d2 => msg.data2;
        d3 => msg.data3;
        mout.send(msg);
    }
    
    fun int curPat(){ return cPat; }
    fun int curPat(int cp){
        if(cp>=0 & cp<nPats) cp => cPat;
        return cPat;
    }
    
    fun int patLen(){ return pLen; }
    fun int patLen(int pl){
        if(pl>0) pl => pLen;
        <<<pLen>>>;
        return pLen;
    }
    
    fun int numPats(){ return nPats; }
    
    fun int numSteps(){ return nSteps; }
    
    fun int numSounds(){ return nSounds; }
    
    fun void clearPat(int p){
        for(0 => int i; i<nSteps; i++) 0 => pats[p][i];
    }
    
    fun void clearAll(){
        for(0 => int i; i<nPats; i++){
            for(0 => int j; j<nSteps; j++) 0 => pats[i][j];
        }
    }
    
    //SndBuf functions------------------------------------------------
    fun int curSound(){ return cSound; }
    fun int curSound(int ns){
        if(ns>=0 & ns<nSounds){ 
            ns => cSound;
            return cSound;
        }
        else if(ns<0) return curSound(0);
        else return curSound(nSounds);
    }
    
    fun float gain(){ return mGain; } 
    fun float gain(float ng){
        if(ng>=0 & ng<=1){
            ng => mGain;
            return mGain;
        }
        else if(ng<0) return gain(0);
        else return gain(1);
    }    
    
    fun float cueGain(){ return qGain;}
    fun float cueGain(float ng){
        if(ng>=0 & ng<=1){
            ng => qGain;
            return qGain;
        }
        else if(ng<0) return cueGain(0);
        else return cueGain(1);
    }
    
    fun float pan(){ return mPan; }
    fun float pan(float np){
        if(np>=0 & np<=1){
            (np - 0.5) * 2 => mPan;
            mPan => mBus.pan, qBus.pan;
            return mPan;
        }
        else if(np<0) return pan(0);
        else return pan(1);
    }
    
    fun float rate(){ return mRate; } 
    fun float rate(float nr){
        if(nr>=0 & nr<=1){
            nr*2 => mRate;
            for(0 => int i; i<nSounds; i++){
                mRate => sounds[i].rate;
            }
        }
        else if(nr<0) return rate(0);
        else return rate(1);
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
}