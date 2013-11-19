// master.ck
// for launching pushStep.ck and all of the classes it depends on


Machine.add(me.dir()+"../../chuckStuff/classes/DataEvent.ck");
Machine.add(me.dir()+"../../chuckStuff/classes/MidiEvent.ck");
Machine.add(me.dir()+"../../chuckStuff/classes/MidiBroadcaster.ck");
Machine.add(me.dir()+"../../chuckStuff/classes/Clock.ck");
Machine.add(me.dir()+"../classes/Push.ck");

Machine.add(me.dir()+"../../chuckStuff/classes/Sampler/SndBufPlus.ck");
Machine.add(me.dir()+"../../chuckStuff/classes/Sampler/SndBufN.ck");
Machine.add(me.dir()+"../../chuckStuff/classes/Sampler/Sampler.ck");
Machine.add(me.dir()+"../classes/RStep_Remake.ck");
Machine.add(me.dir()+"../classes/PushKnob.ck");
Machine.add(me.dir()+"/pushStep_Remake.ck");
