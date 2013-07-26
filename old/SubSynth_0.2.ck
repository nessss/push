public class SubSynth{
    DLP slideDLP;
    slideDLP.go();
    //DLP cutoffDLP;
    DataEvent 
    
    //Ugens
    SqrOsc sqr;
    0.0 => sqr.gain;
    SawOsc saw;
    0.7 => saw.gain;
    Pan2 synPan;
    SinOsc OD;
    1 => OD.sync;
    1 => OD.gain;
    LPF LP;
    1 => LP.Q; 
    ADSR ampEnv;
    ADSR LPEnv;
    Shred gateID;
    Dyno synLim;
    synLim.limit();
    
    
    
    //Functions
    fun void init(){
        OD => synPan => ampEnv => LP => synLim => dac;
        sqr => OD;
        saw => OD;
        LPEnv => blackhole;
        
        200.0 => float cutOff;
        0.0 => float LPEnvAmt;
        204.0 => float slideLen;
        ampEnv.set(10::ms, 8::ms, .5, 10::ms);
        LPEnv.set(10::ms,  8::ms,  0,  1::ms);
        
        spork ~ lpCutUpdate();
        spork ~ slideUpdate();
    }
    
    fun void lpCutLoop(){
        while(samp => now){
            (LPEnv.value() * LPEnvAmt) + cutOff => LP.freq;
        }
    }
    
    fun void slideLoop(){
        while(samp => now){
            slideDLP.val => saw.freq;
            slideDLP.val => sqr.freq;
        }
    }
    //*
    fun void gateIt(){
        theTempo.thirtySecond => now;
        ampEnv.keyOff();
        LPEnv.keyOff(); //this one here?
        me.exit;
    }
    *//
    
    fun void gateGo(){
        spork ~ gateIt() @=> gateID;
    }
}