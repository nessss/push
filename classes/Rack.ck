public class Rack{
    SndBuf sounds[];
    Pan2 mBus;
    Dyno limiter;
    int firstPad[2];
    int padCCs[];
    int nPads, hLen, pOnClr, pOffClr, velOn, focused, rev; //same as num sounds
    //Objects
    Push push;
    MidiBroadcaster mB;
    //Midi
    MidiOut mout;
    MidiMsg msg;
    
    //---------------------------Functions---------------------------\\
    //Initializer
    fun void init(MidiBroadcaster m, int x, int y, int hl, string s[]){
        push.init();       
        m @=> mB;
        x => firstPad[0];  y => firstPad[1];
        hl => hLen;
        s.cap() => nPads;
        9 => pOnClr;  11 => pOffClr; //colors 
        1 => focused;
        
        mBus.gain(.2);
        
        mout.open("Ableton Push User Port");
        
        limiter.limit();
        
        new SndBuf[nPads] @=> sounds;
        for(0 => int i; i<nPads; i++){
            sounds[i].read(s[i]);
            sounds[i].samples() => sounds[i].pos;
            0.5 => newSounds[i].gain;
        }
        
        for(int i; i<sounds.cap(); i++){
            sounds[i] => mBus => limiter => dac;
        }
        
        new int[nPads] @=> padCCs;
        for(0 => int i; i<hLen; i++){
            for(0 => int j; j<nPads/hLen; j++){
                push.grid[firstPad[0]+i][firstPad[1]-j] => padCCs[i+(j*hLen)];
                <<<push.grid[firstPad[0]+i][firstPad[1]-j]>>>;
            }
        }
        
        //Sporks
        spork ~ play();
    }
    //Triggers
    fun void trigger(int s){     //full velocity
        if(s<nPads) 0 => sounds[s].pos;
        else <<<"Trigger out of bounds!">>>;
    }
    
    fun void trigger(int s,float v){ //with velocity
        v=>sounds[s].gain;
        if(s<nPads) 0 => sounds[s].pos;
        else <<<"Trigger out of bounds!">>>;
    }
    
    //Parameters
    fun int padOnColor(){ return pOnClr; }
    fun int padOnColor(int nc){ 
        nc => pOnClr; 
        return pOnClr;
    }
    
    fun int padOffColor(){ return pOffClr; }
    fun int padOffColor(int nc){ 
        nc => pOffClr; 
        return pOffClr;
    }
    
    fun int numSounds(){ return nPads; }
    
    fun int numPads(){ return nPads; }
    
    //Loops
    fun void play(){
        MidiMsg msg;
        while(mB.mev=>now){
            mB.mev.msg @=> msg;
            if(focused){
                if(msg.data1==0x90){
                    for(0 => int i; i<nPads; i++){
                        if(msg.data2 == padCCs[i]){
                            if(velOn){
                                trigger(i, midiNomr(msg.data3));
                            }
                            else trigger(i);
                            midiOut(0x90, padCCs[i], pOnClr);
                        }
                    }
                }
                else if(msg.data1==0x80){
                    for(0 => int i; i<nPads; i++){
                        if(msg.data2 == padCCs[i]){ 
                            midiOut(0x90, padCCs[i], pOffClr);
                        }
                    }
                }
            }
        }
    }
    
    //Utilities     
    fun void midiOut(int d1, int d2, int d3){
        d1 => msg.data1;
        d2 => msg.data2;
        d3 => msg.data3;
        mout.send(msg);
    } 
    
    fun float midiNorm(float f){ //turns 0-127 into 0.0-1.0
        return f*(1.0/127.0);
    }
}
