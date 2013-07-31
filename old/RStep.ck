//A step sequencer for rhythms for Push
//June, 2012
public class RStep{
    int nSounds; //number of samples
    SndBuf sounds[]; //samples usable by this RStep
    0 => int cSound; //current sound
    int nSteps; //number of steps
    int pLen;  //pattern length 
    int nPats; //number of patterns
    0 => int cPat; //current pattern
    0 => int cStep; //current step (updated by clock)
    int seqs[][]; //where the patterns are stored
    int firstPad[2]; //the first step on the push
    int hLen; //sequencing rows length before a vertical break
    9 => int sOnClr; //step on color
    0 => int sOffClr; //step off color
    int stepccs[];
    //Objects
    RhythmClock theClock;
    PushCCs theCCs; //---------------------------FINISH
    //Midi
    MidiOut mout;
    MidiMsg msg;
    if(!mout.open(4)) me.exit();
    <<<mout.name()>>>;
    
    //Spork 'em!
    spork ~ play();
    
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
            0.5 => newSounds[i].gain;
        }
        newSounds @=> sounds;
        for(0 => int i; i<sounds.cap(); i++){
            sounds[i] => dac;
        }
        int nstepccs[nSteps];
        for(0 => int i; i<nSteps/hLen; i++){
            for(0 => int j; j<hLen; j++){
                theCCs.grid[i+firstPad[0]][j+firstPad[1]] => nstepccs[j+(i*hLen)];
            }
        }
        nstepccs @=> stepccs;
    }
    
    fun void play(){
        while(theClock.step => now){
            if(seqs[cPat][theClock.stepCount() % pLen]) trigger(cSound);
        }
    }
    
    fun void trigger(int s){ //zero indexed
        if(s<nSounds) 0 => sounds[s].pos;
        else <<<"Trigger out of bounds!">>>;
    }
    
    fun void updateGrid(){
        for(0 => int i; i<nSteps/hLen; i++){
            for(0 => int j; j<hLen; j++){
                if(seqs[cPat][j+(i*hLen)]) midiOut(0x90, theCCs.grid[i+firstPad[0]][j+firstPad[1]], sOnClr);
                else midiOut(0x90, theCCs.grid[i][j], sOffClr);
            }
        }
    }
    
    fun void setColor(int nClr){
        nClr=>sOnClr;
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