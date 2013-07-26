public class MidiBroadcaster{
    MidiIn min;
    MidiMsg myMsg;
    
    Event onMsg;
    
    fun void init(int port){
        min.open(port);
        <<<"MidiBroadcaster: "+min.name()>>>;
        spork~loop();
    }
    
    fun void loop(){
        while(min=>now){
            while(min.recv(myMsg))onMsg.broadcast();
        }
    }
    
    fun MidiMsg msg(){
        return myMsg;
    }
}