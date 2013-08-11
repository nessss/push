// pushRack.ck
//
// finger drumming on Ableton Push
string mysounds[8];
Rack rack;
MidiBroadcaster mB;

init();
while(samp=>now);

//Functions
fun void init(){
    mB.init("Ableton Push User Port");
    "909/kck.wav" => mysounds[0];
    "909/snr.wav" => mysounds[1];
    "909/clp.wav" => mysounds[2];
    "909/chh.wav" => mysounds[3];
    "909/ohh.wav" => mysounds[4];
    "909/ltm.wav" => mysounds[5];
    "909/htm.wav" => mysounds[6];
    "909/cym.wav" => mysounds[7];
    rack.init(mB,0,7,4,mysounds);
}