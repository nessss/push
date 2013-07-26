//A step sequencer for rhythms for Push
//June, 2012
public class RStep{
    int nSounds; //number of samples
    0.5 => float theGain;
    0 => float thePan;
    1 => float theRate;
    
    SndBuf sounds[]; //samples usable by this RStep
    0 => int cSound; //current sound
    int nSteps; //number of steps
    int pLen;  //pattern length 
    int nPats; //number of patterns
    0 => int cPat; //current pattern
    int seqs[][]; //where the patterns are stored
    int firstPad[2]; //the first step on the push
    int hLen; //sequencing rows length before a vertical break
    9 => int pOnClr; //pad on color
    0 => int pOffClr; //pad off color
    22 => int cursorClr;
    21 => int hiClr; //color displayed when cursor is on a step that's on
    1 => int focus;
    int stepCCs[];
    //Objects
    RhythmClock theClock;
    PushCCs theCCs; 
    //Midi
    MidiOut mout;
    MidiMsg msg;
    if(!mout.open(4)) me.exit();
    <<<mout.name()>>>;
    
    //Spork 'em!
    
    //Functions
    fun void init(int r, int c, int hl, int np, int ns, string s[]){ //Only use this function once
        r => firstPad[0];
        c => firstPad[1];
        hl => hLen;
        np => nPats;
        ns => nSteps;
        nSteps => pLen;
        int nseqs[nPats][nSteps];
        nseqs @=> seqs;
        clearAll();
        s.cap() => nSounds;
        SndBuf newSounds[nSounds];
        for(0 => int i; i<nSounds; i++){
            newSounds[i].read(s[i]);
            newSounds[i].samples() => newSounds[i].pos;
            theGain => newSounds[i].gain;
        }
        newSounds @=> sounds;
        for(0 => int i; i<sounds.cap(); i++){
            sounds[i] => dac;
        }
        int nstepCCs[nSteps];
        for(0 => int i; i<nSteps/hLen; i++){
            for(0 => int j; j<hLen; j++){
                theCCs.grid[i+firstPad[0]][j+firstPad[1]] => nstepCCs[j+(i*hLen)];
            }
        }
        nstepCCs @=> stepCCs;
        spork ~ play();
        spork ~ midiIn();
    }
    
    fun void play(){
        while(theClock.step => now){
            if(seqs[cPat][theClock.stepCount() % pLen]) trigger(cSound);
            if(focus){
                updateGrid();
                if(!seqs[cPat][(theClock.stepCount()-1 +pLen) % pLen]) midiOut(0x90, stepCCs[(theClock.stepCount()-1) % pLen], pOffClr);
                if(seqs[cPat][theClock.stepCount() % pLen]) midiOut(0x90, stepCCs[theClock.stepCount() % pLen], hiClr);
                else midiOut(0x90, stepCCs[theClock.stepCount() % pLen], cursorClr);
            }
        }
    }
    
    fun void midiIn(){
        MidiIn min;
        MidiMsg msg;
        if(!min.open(5)) me.exit();
        while(min=>now){
            while(min.recv(msg)){
                if(focus){
                    if(msg.data1==0x90){
                        for(0 => int i; i<nSteps; i++){
                            if(msg.data2 == stepCCs[i]){ 
                                if(seqs[cPat][i]) 0 => seqs[cPat][i];
                                else 1 => seqs[cPat][i]; 
                            }
                        }
                        updateGrid();
                    }
                }
            }
        }
    }
    
    fun void trigger(int s){ //zero indexed
        if(s<nSounds) 0 => sounds[s].pos;
        else <<<"Trigger out of bounds!">>>;
    }
    
    fun void updateGrid(){
        for(0 => int i; i<stepCCs.cap(); i++){
            if(theClock.stepCount() % pLen!=i){
                if(seqs[cPat][i]) midiOut(0x90, stepCCs[i], pOnClr);
                else midiOut(0x90, stepCCs[i], pOffClr);
            }
        }
    }
    
    fun int inFocus(){
        return focus;
    }
    
    fun int inFocus(int f){
        if(f==0 | f==1){
            f => focus;
        }
        return focus;
    }
    
    fun float gain(){
        return theGain;
    }
    
    fun float gain(int ng){
        if(ng>=0 & ng<=1){
            ng => theGain;
            for(0 => int i; i<nSounds; i++){ 
                theGain => sounds[i].gain;
            }
        }
        else <<<"Gain input out of bounds!">>>;
        return theGain;
    }
    
    fun float pan(){
        return thePan;
    }
    
    fun int padOnColor(){
        return pOnClr;
    }
    
    fun int padOnColor(int nc){
        nc => pOnClr;
        return pOnClr;
    }
    
    fun int padOffColor(){
        return pOffClr;
    }
    
    fun int padOffColor(int nc){
        nc => pOffClr;
        return pOffClr;
    }
    
    fun int cursorColor(){
        return cursorClr;
    }
    
    fun int cursorColor(int nc){
        nc => cursorClr;
        return cursorClr;
    }
    
    fun int highlightColor(){
        return hiClr;
    }
    
    fun int highlightColor(int nc){
        nc => hiClr;
        return hiClr;
    }
    
    fun void midiOut(int d1, int d2, int d3){
        d1 => msg.data1;
        d2 => msg.data2;
        d3 => msg.data3;
        mout.send(msg);
    }
    
    fun int curPat(){
        return cPat;
    }
    
    fun int curPat(int cp){
        cp => cPat;
        return cPat;
    }
    
    fun int numSteps(){
        return nSteps;
    }
    
    fun int patLen(){
        return pLen;
    }
    
    fun int patLen(int pl){
        pl => pLen;
        return pLen;
    }
    
    fun int numPats(){
        return nPats;
    }
    
    fun int numPats(int np){
        np => nPats;
        return nPats;
    }
    
    fun int numSounds(){
        return nSounds;
    }
    
    fun int numSounds(int ns){
        ns => nSounds;
        return nSounds;
    }
    
    fun void clearPat(int p){
        for(0 => int i; i<nSteps; i++) 0 => seqs[p][i];
    }
    
    fun void clearAll(){
        for(0 => int i; i<nPats; i++){
            for(0 => int j; j<nSteps; j++) 0 => seqs[i][j];
        }
    }
}