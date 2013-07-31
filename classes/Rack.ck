public class Rack{
    SndBuf sounds[];
    int firstPad[2];
    int padCCs[];
    1 => int nPads; //same as num sounds
    int hLen;
    9 => int pOnClr;
    11 => int pOffClr;
    0 => int velOn;
    //Objects
    Push push;
    //Midi
    int minPort;
    int moutPort;
    MidiOut mout;
    MidiMsg msg;
    <<<mout.name()>>>;
    
    //Functions
    fun void init(int r, int c, int hl, string s[], int nPort, int oPort){
        nPort => minPort;
        oPort => moutPort;
        if(!mout.open(moutPort)) me.exit();
        r => firstPad[0];
        c => firstPad[1];
        hl => hLen;
        s.cap() => nPads;
        SndBuf newSounds[nPads];
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
        spork ~ play();
    }
    
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
    
    fun void midiOut(int d1, int d2, int d3){
        d1 => msg.data1;
        d2 => msg.data2;
        d3 => msg.data3;
        mout.send(msg);
    }  
    
    fun void padOnColor(int nc){
        nc => pOnClr;
    }
    
    fun void padOffColor(int nc){
        nc => pOffClr;
    }
    
    fun int numSounds(){
        return nPads;
    }
    
    fun int numPads(){
        return nPads;
    }
}
