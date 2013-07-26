//A clock for your ChucK sequencer!
//By Bruce Lott & Mark Morris

public class RhythmClock{
    
    Tempo theTempo;
    static dur sSize;    //Step size
    //static int pLen;     //Pat length
    static int cnt;      //Current count
    static int playing;
    static int swMode;      //Swing mode: 0 = 8th, 1 = 16th
    static Event @ step;    // Static reference to non-static data
    Event theStep @=> step; //  to bypass restriction on non-primitive static data       
    Shred going;
    
    //Swing Variables
    200.0 => static float swingDiv;
    theTempo.quarter / swingDiv => static dur tatum; //Quarter divided into 200 parts
    float Swing[4];   //16th note swing grid (50 tatums per 16th unswung)
    static float tps; //Tatums per step (unswung)
    (swingDiv / Swing.cap()) => tps;
    for(0 => int i; i < Swing.cap(); i++){
        tps => Swing[i];
    }
    
    init();
    
    //Functions
    private void init(){
        stepSize(theTempo.sixteenth);
        //patLen(64);
        swingMode(1);
        if(!playing){
            spork ~ play();
        }
    }
    
    private void play(){
        if(playing == 1){
            going.exit();
            0 => cnt;
        }
        spork ~ go() @=> going;
        1 => playing;
    }
    
    fun void BPM(float newBPM){
        theTempo.BPM(newBPM);
        theTempo.quarter / swingDiv => tatum; //quarter divided into 200 parts
        (swingDiv / Swing.cap()) => tps;
        for(0 => int i; i < Swing.cap(); i++){
            tps => Swing[i];
        }
    }
    
    fun dur stepSize(){
        return sSize;
    }
    
    fun dur stepSize(dur newSize){
        newSize => sSize;
        return sSize;
    }
    
    //fun int patLen(){
    //    return pLen;
    //}
    
    //fun int patLen(int newLen){
    //    newLen => pLen;
    //    return pLen;
    //}
    
    fun int stepCount(){
        return cnt;
    }
    
    fun void go(){
        while(true){
            step.broadcast();
            Swing[cnt % 4]::tatum => now;
            (cnt+1)/* % pLen*/=>cnt;
        }
    }
    
    fun int isPlaying(){
        return playing;
    }
    
    fun void stop(){
        if(playing){
            going.exit();
            0 => cnt;
            0 => playing;
        }
    }
    
    fun void pause(){
        if(playing){
            going.exit();
            0 => playing;
        }
    }
    
    fun int swingMode(){
        return swMode;
    }
    
    fun int swingMode(int newMode){
        newMode => swMode;
        return swMode;
    }
    
    fun void swingAmt(float swingCtrl){
        if(swMode == 1){
            for(0 => int i; i<Swing.cap(); i++){
                if(i % 2 == 0){
                    tps + (swingCtrl * 30) => Swing[i];
                }
                else{
                    tps - (swingCtrl * 30) => Swing[i];
                }
            }
        }
        else{
            for(0 => int i; i<Swing.cap(); i++){
                if(i < 2){
                    tps + (swingCtrl * 30) => Swing[i];
                }
                else{
                    tps - (swingCtrl * 30) => Swing[i];
                }
            }
        }
    }
}