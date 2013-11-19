public class PadGroup{
    Pad pads[0];
    int onClr;
    int offClr;
    Pan2 grpBus;
    MidiOutUtil mou;
    int choke;
    
    fun void init(int onC, int offC){
        onC => onClr;
        offC => offClr;
        mou.init("Ableton Push User Port");
    }
    
    fun void addPad(string sample, int gPos){
        pads << new Pad;
        pads[pads.cap()-1].init(sample, gPos);
        pads[pads.cap()-1].sampler.output => grpBus;
        mou.midiOut(0x90,gPos,offClr);
    }
    
    fun void checkNote(MidiMsg msg){
        for(int i; i<pads.size(); i++){
            if(pads[i].noteNum == msg.data2){ 
                if(msg.data1 == 144){
                	if(choke){
                		for(int j;j<pads.cap();j++){
                			if(i!=j&pads[j].sampler.isPlaying(0))pads[j].sampler.stop(0);
                		}
                		100::samp=>now;
                	}
                    pads[i].sampler.trigger(0);
                    chout<=pads[i].sampler.isPlaying(0)<=IO.nl();
                    mou.midiOut(144, msg.data2, onClr);
                }
                else{ 
                    mou.midiOut(144, msg.data2, offClr);
                }
            }
        }
    }
}
