//Trigger test for subsynth
public class TrigTest{
    DataEvent pitch, gate;
    1.0 => gate.f;
    
    spork ~ play();
    
    //Functions
    fun void play(){
        while(true){
            48.0 => pitch.f;
            pitch.broadcast();
            gate.broadcast();
            2::second=>now;
            
            36.0 => pitch.f;
            pitch.broadcast();
            gate.broadcast();
            2::second=>now;
        }
    }
}