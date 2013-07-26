//2 oscillators (course/fine tuning)
//2 waveforms
//One filter 
//ADSR for filter
//ADSR for amplitude

//Uses pitch and gate dataEvents to trigger notes

public class SubSynth{
    TrigTest trig;
    //Ugens
    UGen osc[2][2]; //[osc][wave]
    BlitSquare sqr[2]; //waveform 0
    BlitSaw saw[2];    //waveform 1
    Gain mix[2];
    ADSR ampEnv;
    int cWave[2];
    //int course[2];
    //float fine[2];
    
    //Functions
    fun void init(){
        oscMix(0, 0.7);
        oscMix(1, 0.0);
        
        for(int i; i<2; i++){
            sqr[i] @=> osc[i][0];
            saw[i] @=> osc[i][1];
            for(int j; j<2; j++){
                osc[i][j] => mix[i];
            }
            mix[i] => dac;
            waveSelect(i,0);
        }
        spork ~ pitchLoop();
        spork ~ gateLoop();
    }
    
    fun float oscMix(int os) { return mix[os].gain(); }
    fun float oscMix(int os, float g){
        if(g>=0 & g<=1) g => mix[os].gain;
        return mix[os].gain();
    }
    
    fun void waveSelect(int os, int wv){
        0 => osc[os][cWave[os]].gain;
        1 => osc[os][wv].gain;
        wv => cWave[os];
    }
    
    fun void pitchLoop(){
        while(trig.pitch => now){
            for(int i; i<2; i++){
                Std.mtof(trig.pitch.f()) => osc[i][cWave[i]].freq;
            }
        }
    }
    
    fun void gateLoop(){
        while(trig.gate => now){
            ampEnv.keyOn();
            ampEnv.keyOff();
        }
    }
}
