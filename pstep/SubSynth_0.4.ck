//2 oscillators (coarse/fine tuning)
//2 waveforms
//One filter 
//ADSR for filter
//ADSR for amplitude

//Uses pitch and gate dataEvents to trigger notes

public class SubSynth{
    //Objects
    DLP porto[2];
    //Ugens
    BlitSquare sqr[2]; //waveform 0
    BlitSaw saw[2];    //waveform 1
    Gain mix[2];
    Pan2 pan;
    ADSR ampEnv;
    int cWave[2];
    float coarse[2];
    float fine[2];
    float cPitch;
    float tPitch[2]; //temp
    OscRecv orec;
    
    //Functions
    fun void init(){
        for(int i; i<2 ; i++){ 
            porto[i].go();
            200 => porto[i].freq;
        }
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
        spork ~ fineOSC();
        spork ~ portoLoop(); spork ~ portoOSC();
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
        p => cPitch;
        for(int i; i<2; i++){
            cPitch + coarse[i] + fine[i] => tPitch[i];
            Std.mtof(tPitch[i]) => porto[i].data;
        }
    }
    
    fun void coarseUpdate(int os, float c){
        c=> coarse[os];
        pitchIt(cPitch);
    }
    
    fun void fineUpdate(int os, float f){
        f => fine[os];
        pitchIt(cPitch);
    }
    
    fun void gateIt(){
        ampEnv.keyOn();
        //ampEnv.keyOff();
    }
    
    //OSC loops    
    fun void portoOSC(){
        orec.event("/porto, f") @=> OscEvent ev;
        float f;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                ev.getFloat() * 200 + 1 => f;
                for(int i; i<2; i++) f => porto[i].freq;
            }
        }
    }
    
    fun void mstGainOSC(){
        orec.event("/mgain, f") @=> OscEvent ev;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                ev.getFloat() => pan.gain;
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
                waveSel(ev.getInt(), ev.getInt());
            }
        }
    }
    
    fun void wave1SelOSC(){
        orec.event("/wf, i, i") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
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
        orec.event("/fine, i, f") @=> OscEvent ev;
        int i;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                fineUpdate(ev.getInt(), ev.getFloat());
            }
        }
    }
    
    //Other Loops
    fun void portoLoop(){
        while(samp => now){
            for(int i; i<2; i++){
                porto[i].val => sqr[i].freq;
                porto[i].val => saw[i].freq;
            }
        }
    }
}