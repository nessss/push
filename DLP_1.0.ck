public class DLP{ //data lowpass filter
    Step stp => LPF lp => blackhole;
    10 => lp.freq;
    0.1 => lp.Q;
    0.0 => float data;
    0.0 => float val;
    samp => dur rate; //how much computation
    Shred updater;
    
    private void update(){
        while(rate => now){
            data => stp.next;
            lp.last() => val;
        }
    }
    
    fun void go(){
        spork~update() @=> updater;
    }
    
    fun void stop(){
        updater.exit();
    }
    fun void freq(float f){
        f => lp.freq;
    } 
}   