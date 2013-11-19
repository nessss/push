public class PadGroup{
    Pad pads[0];
    int onClr;
    int offClr;
    Pan2 grpBus;
    MidiOutUtil mou;
    
    fun void init(int onC, int offC){
        onC => onClr;
        offC => offClr;
        mou.init("Ableton Push User Port");
    }
    
    fun void addPad(string sample, int gPos){
        pads << new Pad;
        pads[pads.cap()-1].init(sample, gPos);
        pads[pads.cap()-1].sampler.output => grpBus;
    }
    
    fun void checkNote(MidiMsg msg){
        for(int i; i<pads.size(); i++){
            if(pads[i].noteNum == msg.data2){ 
                if(msg.data1==0x90){
                    pads[i].sampler.trigger(0);
                    mou.midiOut(144, msg.data2, onClr);
                }
                else if(msg.data1==0x80){ 
                    mou.midiOut(144, msg.data2, offClr);
                }
            }
        }
    }
}