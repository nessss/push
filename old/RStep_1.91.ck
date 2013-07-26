//A step sequencer for rhythms for Push
//June, 2012
public class RStep{ //n = number, p = pattern, m = master, h = horizontal, q = cue
    int nSounds, nSteps, pLen, tempPats, hLen, minPort, moutPort, qL, qR; //set by init()
    0 => int muted;
    0 => int cued;
    1 => int focused; //focused = visual feedback/midi input
    0 => int cursor; //if cursor is updated or not
    SndBuf sounds[]; //samples used by this RStep
    Pan2 pans[];
    Pan2 mBus; //master stereo bus out
    Pan2 qBus;
    0.5 => float qGain;
    qGain => qBus.gain;
    0 => float thePan;
    1 => float theRate;
    0.5 => float mGain;
    0 => int cSound; 
    0 => int cPat;
    int pats[][]; //where the patterns are stored
    int firstPad[2]; //the first step on the push (y,x cordinate)
    int stepCCs[];
    //LED colors (defaults)
    9 => int onClr; 
    0 => int offClr;
    22 => int cursorClr;
    21 => int hiClr; //color displayed when cursor is on a step that's on
    //Objects
    RhythmClock theClock;
    Push thePush; 
    //Midi
    MidiOut mout;
    MidiMsg msg;
    
    //Initailizer/Constructor-------------------------------------------
    fun void init(int r, int c, int hl, int np, int ns, string s[], int nPort, int oPort, int outL, int outR, int qL, int qR){
        r => firstPad[0];
        c => firstPad[1];
        hl => hLen;
        np => tempPats;
        ns => nSteps;
        s.cap() => nSounds;
        nPort => minPort;
        oPort => moutPort;
        nSteps => pLen;
        
        int tempPats[tempPats][nSteps]; 
        tempPats @=> pats;
        
        clearAll();
        SndBuf tempSounds[nSounds];
        for(0 => int i; i<nSounds; i++){
            tempSounds[i].read(s[i]);
            tempSounds[i].samples() => tempSounds[i].pos;
        }
        tempSounds @=> sounds;
        Pan2 tempPans[nSounds];
        for(0 => int i; i<nSounds; i++){
            sounds[i] => tempPans[i];
        }
        tempPans @=> pans;
        for(0 => int i; i<nSounds; i++){ 
            pans[i] => mBus;
            pans[i] => qBus;
        }
        mBus.left => dac.chan(outL);
        mBus.right => dac.chan(outR);
        qBus.left => dac.chan(qL);
        qBus.right => dac.chan(qR);
        int tempStepCCs[nSteps];
        for(0 => int i; i<nSteps/hLen; i++){
            for(0 => int j; j<hLen; j++){
                thePush.grid[i+firstPad[0]][j+firstPad[1]] => tempStepCCs[j+(i*hLen)];
            }
        }
        tempStepCCs @=> stepCCs;
        //Midi Out
        if(!mout.open(moutPort)) me.exit();
        spork ~ play();
        spork ~ midiIn(minPort);
    }
    
    //Play Functions----------------------------------------------------
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
                updateGrid();
                if(!pats[cPat][(theClock.step.i - 1 + pLen) % pLen]){ 
                    midiOut(0x90, stepCCs[(theClock.step.i - 1 + pLen) % pLen], offClr);
                }
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
    
    fun void midiIn(int nPort){
        MidiIn min;
        MidiMsg msg;
        if(!min.open(nPort)) me.exit();
        while(min=>now){
            while(min.recv(msg)){
                if(focused){
                    if(msg.data1==0x90){
                        for(0 => int i; i<nSteps; i++){
                            if(msg.data2 == stepCCs[i]){ 
                                if(pats[cPat][i]) 0 => pats[cPat][i];
                                else 1 => pats[cPat][i]; 
                            }
                        }
                        updateGrid();
                    }
                }
            }
        }
    }
    
    fun void updateGrid(){
        for(0 => int i; i<stepCCs.cap(); i++){
            if(theClock.step.i % pLen!=i | !theClock.isPlaying()){
                if(pats[cPat][i]) midiOut(0x90, stepCCs[i], onClr);
                else midiOut(0x90, stepCCs[i], offClr);
            }
        }
    }
    //RStep functions--------------------------------------------------
    fun int cue(){
        return cued;
    }
    
    fun int cue(int c){
        if(c == 1){
            1 => cued;
            qGain => qBus.gain;
        }
        else{
            0 => cued;
            0 => qBus.gain;
        }
        return cued;
    }
    
    fun int mute(){
        return muted;
    }
    
    fun int mute(int m){
        m => muted;
        return muted;
    }
    
    fun int focus(){ 
        return focused;
    }
    
    fun int focus(int f){
        if(f==0 | f==1){
            f => focused;
        }
        return focused;
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
        return tempPats;
    }
    
    fun int numPats(int np){
        np => tempPats;
        return tempPats;
    }
    
    fun int numSounds(){
        return nSounds;
    }
    /*
    fun int numSounds(int ns){
        ns => nSounds;
        return nSounds;
    }
    */
    fun void clearPat(int p){
        for(0 => int i; i<nSteps; i++) 0 => pats[p][i];
    }
    
    fun void clearAll(){
        for(0 => int i; i<tempPats; i++){
            for(0 => int j; j<nSteps; j++) 0 => pats[i][j];
        }
    }
    
    //SndBuf functions------------------------------------------------
    fun int curSound(){
        return cSound;
    }
    
    fun int curSound(int ns){
        if(ns>=0 & ns<nSounds){ 
            ns => cSound;
            return cSound;
        }
        else if(ns<0) return curSound(0);
        else return curSound(nSounds);
    }
    
    fun float gain(){
        return mGain;
    }
    
    fun float gain(float ng){
        if(ng>=0 & ng<=1){
            ng => mGain;
            return mGain;
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
            }
            return thePan;
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
        else if(nr<0) return rate(0);
        else return rate(1);
    }
    //Color Functions-------------------------------------------------
    fun int onColor(){
        return onClr;
    }
    
    fun int onColor(int nc){
        nc => onClr;
        return onClr;
    }
    
    fun int offColor(){
        return offClr;
    }
    
    fun int offColor(int nc){
        nc => offClr;
        return offClr;
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
}