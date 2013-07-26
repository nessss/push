public class MidiBroadcaster{
    MidiIn min;
    MidiMsg msg;
    MidiEvent mev;
    Shred loopShred;
    
    MidiIn minCheck[16];
    
    int devices;
    
    for( int i; i < minCheck.cap(); i++ ){
        // no print err
        minCheck[i].printerr( 0 );
        
        // open the device
        if( minCheck[i].open( i ) ){
            if(minCheck[i].name()=="Ableton Push User Port"){
                minCheck[i]@=>min;
                break;
            }
        }else break;
    }
    
    fun void init(){
        //<<<min.name(),"">>>;
        spork~loop()@=>loopShred;
    }
    
    fun string name(){
        return min.name();
    }
    
    fun void loop(){
        while(min=>now){
            while(min.recv(msg)){
                msg@=>mev.msg;
                mev.broadcast();
            }
        }
    }
    
    fun void kill(){
        loopShred.exit();
    }
    
}