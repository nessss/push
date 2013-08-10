public class Rack{
    SndBuf sounds[];
    int firstPad[2];
    int padCCs[];
    int nPads, hLen, pOnClr, pOffClr, velOn, focused; //same as num sounds
    //Objects
    Push push;
    MidiBroadcaster mB;
    //Midi
    int minPort;
    int moutPort;
    MidiOut mout;
    MidiMsg msg;
    <<<mout.name()>>>;
    
    //Functions
        oPort => moutPort;
        r => firstPad[0];
        c => firstPad[1];
    //---------------------------Functions---------------------------\\
    //Initializer
        m @=> mB;
        hl => hLen;
        s.cap() => nPads;
        SndBuf newSounds[nPads];
        9 => pOnClr;  11 => pOffClr;  0 => velOn; //colors
        1 => focused;
        for(0 => int i; i<nPads; i++){
            newSounds[i].read(s[i]);
            newSounds[i].samples() => newSounds[i].pos;
            0.5 => newSounds[i].gain;
        }
        newSounds @=> sounds;
        
        for(0 => int i; i<sounds.cap(); i++){
            sounds[i] => dac;
        }
        int npadCCs[nPads];
        
        for(0 => int i; i<nPads/hLen; i++){
            for(0 => int j; j<hLen; j++){
                push.grid[i+firstPad[0]][j+firstPad[1]] => npadCCs[j+(i*hLen)];
            }
        }
        npadCCs @=> padCCs;
        
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
        MidiIn min;
        MidiMsg msg;
        if(!min.open(minPort)) me.exit();
        while(min=>now){
            while(min.recv(msg)){
                if(msg.data1==0x90){
                    for(0 => int i; i<nPads; i++){
                        if(msg.data2 == padCCs[i]){
                            trigger(i);
                            midiOut(0x90, padCCs[i], pOnClr);
                        }
                    }
                }
                else if(msg.data1==0x80){
                    for(0 => int i; i<nPads; i++){
                        if(msg.data2 == padCCs[i]) midiOut(0x90, padCCs[i], pOffClr);
                    }
                }
            }
        }
    }
    
    fun void trigger(int s){
        if(s<nPads) 0 => sounds[s].pos;
        else <<<"Trigger out of bounds!">>>;
    }
    
    fun void trigger(int s,float v){
        v=>sounds[s].gain;
        if(s<nPads) 0 => sounds[s].pos;
        else <<<"Trigger out of bounds!">>>;
    }
    
    //Utilities     
    fun void midiOut(int d1, int d2, int d3){
        d1 => msg.data1;
        d2 => msg.data2;
        d3 => msg.data3;
        mout.send(msg);
    
    } 
    
    }
}
