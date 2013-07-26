//A step sequencer for rhythms for Push
//June, 2012
public class RStep{ //n = number, p = pattern, m = master, h = horizontal
    int nSounds; //number of samples
    0.5 => float theGain;
    0 => float thePan;
    1 => float theRate;
    1 => float mGain; //master gain
    Pan2 mPan; //master stereo bus out
    SndBuf sounds[]; //samples usable by this RStep
    Pan2 pans[];
    0 => int cSound; //current sound
    int nSteps; //number of steps
    int pLen;  //pattern length 
    int nPats; //number of patterns
    0 => int cPat; //current pattern
    int seqs[][]; //where the patterns are stored
    int firstPad[2]; //the first step on the push
    int hLen; //sequencing rows length before a vertical break
    9 => int padOnClr; 
    0 => int padOffClr;
    22 => int cursorClr;
    21 => int hiClr; //color displayed when cursor is on a step that's on
    1 => int focus;
    int stepCCs[];
    //Objects
    RhythmClock theClock;
    Push thePush; 
    //Midi
    MidiOut mout;
    MidiMsg msg;
    int minPort;
    int moutPort;
    
    //Functions
    fun void init(int r, int c, int hl, int np, int ns, string s[], int nPort, int oPort, UGen lf, UGen rt){
        r => firstPad[0];
        c => firstPad[1];
        hl => hLen;
        np => nPats;
        ns => nSteps;
        nPort => minPort;
        oPort => moutPort;
        nSteps => pLen;
        int nseqs[nPats][nSteps];
        nseqs @=> seqs;
        clearAll();
        s.cap() => nSounds;
        SndBuf newSounds[nSounds];
        for(0 => int i; i<nSounds; i++){
            newSounds[i].read(s[i]);
            newSounds[i].samples() => newSounds[i].pos;
            //theGain => newSounds[i].gain;
        }
        newSounds @=> sounds;
        Pan2 npans[nSounds];
        for(0 => int i; i<nSounds; i++){
            sounds[i] => npans[i];
            theGain => npans[i].gain;
        }
        npans @=> pans;
        for(0 => int i; i<nSounds; i++) pans[i] => mPan;
        mPan.left => lf;
        mPan.right => rt;
        int nstepCCs[nSteps];
        for(0 => int i; i<nSteps/hLen; i++){
            for(0 => int j; j<hLen; j++){
                thePush.grid[i+firstPad[0]][j+firstPad[1]] => nstepCCs[j+(i*hLen)];
            }
        }
        nstepCCs @=> stepCCs;
        //Midi Out
        if(!mout.open(moutPort)) me.exit();
        //<<<mout.name()>>>;
        spork ~ play();
        spork ~ midiIn(minPort);
    }
    
    fun void play(){
        while(theClock.step => now){
            if(seqs[cPat][theClock.stepCount() % pLen]) trigger(cSound);
            if(focus){
                updateGrid();
                if(!seqs[cPat][(theClock.stepCount()-1 +pLen) % pLen]) midiOut(0x90, stepCCs[(theClock.stepCount()-1) % pLen], padOffClr);
                if(seqs[cPat][theClock.stepCount() % pLen]) midiOut(0x90, stepCCs[theClock.stepCount() % pLen], hiClr);
                else midiOut(0x90, stepCCs[theClock.stepCount() % pLen], cursorClr);
            }
        }
    }
    
    fun void midiIn(int nPort){
        MidiIn min;
        MidiMsg msg;
        if(!min.open(nPort)) me.exit();
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
                if(seqs[cPat][i]) midiOut(0x90, stepCCs[i], padOnClr);
                else midiOut(0x90, stepCCs[i], padOffClr);
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
    
    fun int curSound(){
        return cSound;
    }
    
    fun int curSound(int ns){
        if(ns>=0 & ns<nSounds) ns => cSound;
        else <<<"curSound input is out of bounds!!">>>;
        return cSound;
    }
    
    fun float gain(){
        return theGain;
    }
    
    fun float gain(float ng){
        if(ng>=0 & ng<=1){
            ng => theGain;
            for(0 => int i; i<nSounds; i++){ 
                theGain => pans[i].gain;
                return theGain;
            }
        }
        else if(ng<0) return gain(0);
        else return gain(1);
    }
    
    fun float pan(){
        return thePan;
    }
    
    fun float pan(float np){
        if(np>=0 & np<=1){
            (np - 0.5) * 2 => thePan;
            for(0 => int i; i<nSounds; i++){
                thePan => pans[i].pan;
                return thePan;
            }
        }
        else if(np<0) return pan(0);
        else return pan(1);
    }
    
    fun float rate(){
        return theRate;
    }
    
    fun float rate(float nr){
        if(nr>=0 & nr<=1){
            nr*2 => theRate;
            for(0 => int i; i<nSounds; i++){
                theRate => sounds[i].rate;
            }
        }
        else <<<"Rate input out of bounds!">>>;
        return theRate;
    }
    
    fun int padOnColor(){
        return padOnClr;
    }
    
    fun int padOnColor(int nc){
        nc => padOnClr;
        return padOnClr;
    }
    
    fun int padOffColor(){
        return padOffClr;
    }
    
    fun int padOffColor(int nc){
        nc => padOffClr;
        return padOffClr;
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