//Lets you easily call your note lengths
//By Bruce Lott, Mark Morris & Ajay Kapur
public class Tempo{
    
    static dur quarter, eighth, sixteenth, thirtySecond;
    static float theBPM;
    
    fun float BPM(float newBPM){
        newBPM => theBPM;
        60.0/(theBPM) => float SPB; //Seconds per beat
        SPB::second => quarter;
        quarter * 0.5 => eighth;
        eighth * 0.5 => sixteenth;
        sixteenth * 0.5 => thirtySecond;
        return theBPM;
    }
    
    fun float BPM(){
        return theBPM;
    }
}