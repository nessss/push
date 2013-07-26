//2 oscillators (coarse/fine tuning)
//2 waveforms
//One filter 
//ADSR for filter
//ADSR for amplitude

//Uses pitch and gate dataEvents to trigger notes

public class SubSynth{
    //Objects
    DLP glide[2];
    //Ugens
    BlitSquare sqr[2]; //waveform 0
    BlitSaw saw[2];    //waveform 1
    Gain mix[2];
    Pan2 pan;
    ADSR ampEnv;
    int cWave[2];
    float coarse[2];
    float fine[2];
    float cPitch[2];
    OscRecv orec;
    
    //Functions
    fun void init(){
        for(int i; i<2 ; i++) glide[i].go();
        oscMix(0, 0.7);
        oscMix(1, 0.0);
        
        ampEnv.set( 10::ms, 8::ms, .5, 200::ms );
        
        for(int i; i<2; i++){
            sqr[i] => mix[i];
            saw[i] => mix[i];
            mix[i] => ampEnv;
            waveSel(i,0);
        }
        ampEnv => pan => dac;
        
        12001 => orec.port;
        orec.listen();
        
        spork ~ mstGainOSC();
        spork ~ oscMixOSC();
        spork ~ wave0SelOSC(); spork ~ wave1SelOSC();
        spork ~ coarseOSC();
    }
    
    fun float oscMix(int os) { return mix[os].gain(); }
    fun float oscMix(int os, float g){
        if(g>=0 & g<=1) g => mix[os].gain;
        return mix[os].gain();
    }
    
    fun void waveSel(int os, int wv){
        if(cWave[os]==0) 0 => sqr[os].gain;
        else 0 => saw[os].gain;
        wv =>  cWave[os];
        if(wv==0) 1 => sqr[os].gain;
        else 1 => saw[os].gain;
    }
    
    fun void pitchIt(float p){
        for(int i; i<2; i++){
            p + coarse[i] + fine[i] => cPitch[i];
            Std.mtof(cPitch[i]) => sqr[i].freq;
            Std.mtof(cPitch[i]) => saw[i].freq;
        }
    }
    
    fun void pitchIt(int os, float p){
        for(int i; i<2; i++){
            p + coarse[os] + fine[os] => cPitch[os];
            Std.mtof(cPitch[os]) => sqr[os].freq;
            Std.mtof(cPitch[os]) => saw[os].freq;
        }
    }
    
    fun void coarseUpdate(int os, float c){
        cPitch[os] + (coarse[os]*(-1)) => cPitch[os];
        c => coarse[os];
        coarse[os] +=> cPitch[os];
        pitchIt(os, cPitch[os]);
    }
    
    fun void gateIt(){
        ampEnv.keyOn();
        //ampEnv.keyOff();
    }
    
    //OSC loops
    fun void mstGainOSC(){
        orec.event("/mgain, f") @=> OscEvent ev;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                ev.getFloat() => pan.gain;
                <<<pan.gain()>>>;
            }
        }
    }
    
    fun void oscMixOSC(){
        orec.event("/omix, f") @=> OscEvent ev;
        float f;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                ev.getFloat() => f;
                Math.cos((f)*pi)*0.5+0.5 => mix[0].gain;
                Math.cos((f+1)*pi)*0.5+0.5 => mix[1].gain;
            }
        }
    }
    
    fun void wave0SelOSC(){
        orec.event("/wf, i, i") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                <<<"wf0">>>;
                waveSel(ev.getInt(), ev.getInt());
            }
        }
    }
    
    fun void wave1SelOSC(){
        orec.event("/wf, i, i") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                <<<"wf1">>>;
                waveSel(ev.getInt(), ev.getInt());
            }
        }
    }
    
    fun void coarseOSC(){ //i = osc, f = coarse pitch
        orec.event("/cors, i, f") @=> OscEvent ev;
        int i;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                coarseUpdate(ev.getInt(), ev.getFloat());
            }
        }
    }
    
    fun void fineOSC(){
        
    }
    
    //Other Loops
    fun void slideLoop(){
        while(samp => now){
            for(int i; i<2; i++){
                slideDLP.val => sqr[i].freq;
                slideDLP.val => saw[i].freq;
            }
        }
    }
}
