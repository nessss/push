public class PadGroup{
    Pad pads[0];
    int sustain[0];
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
        sustain << 0;
        pads[pads.cap()-1].init(sample, gPos);
        pads[pads.cap()-1].sampler.output => grpBus;
        mou.midiOut(0x90,gPos,offClr);
    }

    fun void checkNote(MidiMsg msg){
        for(int i; i<pads.size(); i++){
            if(pads[i].noteNum == msg.data2){ 
<<<<<<< HEAD
                if(msg.data1==0x90){
=======
                if(msg.data1 == 144){
                	if(choke){
                		for(int j;j<pads.cap();j++){
                			if(i!=j&pads[j].sampler.isPlaying(0))pads[j].sampler.stop(0);
                		}
                		100::samp=>now;
                	}
>>>>>>> a11260a11bd2d8eb6170b7e417e2b904df4c09c9
                    pads[i].sampler.trigger(0);
                    mou.midiOut(144, msg.data2, onClr);
                }
                else if(msg.data1==0x80){ 
<<<<<<< HEAD
=======
                	if(sustain[i])
                		pads[i].sampler.stop(0);
>>>>>>> a11260a11bd2d8eb6170b7e417e2b904df4c09c9
                    mou.midiOut(144, msg.data2, offClr);
                }
            }
        }
    }
}
