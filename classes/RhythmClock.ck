//A clock for ChucK sequencers!
//By Bruce Lott & Mark Morris

public class RhythmClock{
    
    static dur quarter, eighth, sixteenth, thirtySecond;
    static float theBPM;
    static dur sSize;    //Step size
    static int cnt, playing, pLen;
    static int swMode;      //Swing mode: 0 = 8th, 1 = 16th
    static DataEvent @ step;    // Static reference to non-static data
    DataEvent theStep @=> step; //  to bypass restriction on non-primitive static data       
    Shred going;
    time last;
    
    //Swing Variables
    static float swingDiv;
    static dur tatum;
    float Swing[4];   //16th note swing grid (50 tatums per 16th unswung)
    static float tps; //Tatums per step (unswung)
    
    int active[2];
    int aCnt;
    
    //Functions
    fun void init(){
        200.0=>swingDiv;
        0=>playing;
        BPM(120);     // initializes quarter, eighth, etc.
        swingMode(1);
        swingAmt(0);
        stepSize(sixteenth);
        1=>active[0];
        0=>active[1];
        0=>aCnt;
        patLen(64);
    }
    
    fun void go(int aCnt){
        if(active[aCnt]){
            cnt=>step.i;
            step.broadcast();
        }
        while(true){
            Swing[cnt % 4]::tatum => now;
            if(active[aCnt]){
                (cnt+1)%pLen=>cnt;
                cnt=>step.i;
                step.broadcast();
            }
        }
    }
    
    // transport
    fun void play(){
        if(playing){
            0=>active[aCnt];
            going.exit();
            0 => cnt;
        }
        !aCnt=>aCnt;
        1=>active[aCnt];
        spork ~ go(aCnt) @=> going;
        1 => playing;
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
    
    // setters & getters
    fun float BPM(){ return theBPM; }
    fun float BPM(float newBPM){
        newBPM => theBPM;
        60.0/(theBPM) => float SPB; //Seconds per beat
        SPB::second => quarter;
        quarter * 0.5 => eighth; //Define note lengths
        eighth * 0.5 => sixteenth;
        sixteenth * 0.5 => thirtySecond;
        quarter / swingDiv => tatum; //quarter divided into 200 parts
        (swingDiv / Swing.cap()) => tps;
        for(0 => int i; i < Swing.cap(); i++){
            tps => Swing[i];
        }
        return theBPM;
    }
    
    fun dur stepSize(){ return sSize; }
    fun dur stepSize(dur newSize){
        newSize => sSize;
        return sSize;
    }
    
    fun int patLen(){ return pLen; }
    fun int patLen(int newLen){
        if(newLen>0) newLen => pLen;
        else 1 => pLen;
        return pLen;
    }
    
    fun int swingMode(){ return swMode; }
    fun int swingMode(int newMode){
        newMode => swMode;
        return swMode;
    }
    
    fun void swingAmt(float swingCtrl){
        if(swMode == 1){
            for(0 => int i; i<Swing.cap(); i++){
                if(i % 2 == 0) tps + (swingCtrl*30) => Swing[i];
                else tps - (swingCtrl*30) => Swing[i];
            }
        }
        else{
            for(0 => int i; i<Swing.cap(); i++){
                if(i < 2) tps + (swingCtrl*30) => Swing[i];
                else tps - (swingCtrl*30) => Swing[i];
            }
        }
    }
    
    fun int stepCount(){ return cnt; }
   
    fun int isPlaying(){ return playing; }
    
}