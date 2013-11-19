public class MidiOutUtil{
    MidiMsg msg;
    MidiOut mout;
    
    fun void init(string moutName){
        mout.open(moutName);
    }
    fun void midiOut(int d1, int d2, int d3){
        d1 => msg.data1;
        d2 => msg.data2;
        d3 => msg.data3;
        mout.send(msg);
    }
}