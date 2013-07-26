//public class PushKeys{

Push p;
//MidiBroadcaster mB;
//mB.init(2);

TriOsc s[8][8];
ADSR e[8][8];
DLP dlp[8][8];

MidiOut mout;
MidiMsg msg;
mout.open(2);

int c[8][8][2];
int on[8][8];
51=>int reg;
42=>int oct;
int notes[8][8];

for(0=>int i;i<8;i++){
    for(0=>int j;j<8;j++)36+(5*(7-j))+i=>notes[i][j];
}

for(0=>int i;i<8;i++){
    for(0=>int j;j<8;j++){
        reg=>c[i][j][0];
        reg-2=>c[i][j][1];
        0=>on[i][j];
        s[i][j]=>e[i][j]=>dac;
        10::ms=>e[i][j].attackTime;
        20::ms=>e[i][j].decayTime;
        0.6=>e[i][j].sustainLevel;
        100::ms=>e[i][j].releaseTime;
        Std.mtof(notes[i][j])=>s[i][j].freq;
        e[i][j].keyOff();
        20=>dlp[i][j].freq;
        1::ms=>dlp[i][j].rate;
        dlp[i][j].go();
    }
}
oct=>c[0][7][0];
oct=>c[1][0][0];
oct=>c[2][5][0];
oct=>c[4][3][0];
oct=>c[6][1][0];
oct=>c[7][6][0];

oct-1=>c[0][7][1];
oct-1=>c[1][0][1];
oct-1=>c[2][5][1];
oct-1=>c[4][3][1];
oct-1=>c[6][1][1];
oct-1=>c[7][6][1];

lightsOff();
keyLights();

spork~noteOn(2);
spork~touchUpdate();

while(samp=>now);

fun void touchUpdate(){
    while(1::ms=>now){
        for(0=>int i;i<8;i++){
            for(0=>int j;j<8;j++){
                dlp[i][j].val=>e[i][j].gain;
            }
        }
    }
}

fun void freqEnv(DLP dlp){
    20=>dlp.freq;
    10::ms=>now;
    10=>dlp.freq;
}


fun void noteOn(int port){
    0=>int last;
    MidiIn min;
    MidiMsg msg;
    min.open(port);
    while(min=>now){
        while(min.recv(msg)){
            if(p.inGrid(msg.data2)){
                p.gridX(msg.data2)=>int x;
                p.gridY(msg.data2)=>int y;
                if(msg.data1==0x90){      // note on
                    notes[x][y]=>last;
                    msg.data3/127.0=>dlp[x][y].data;
                    e[x][y].keyOn();
                    lightOn(x,y,c[x][y][1]);
                    if(y>0&x>4){
                        lightOn(x-5,y-1,c[x-5][y-1][1]);
                    }
                    if(y<7&x<3){
                        lightOn(x+5,y+1,c[x+5][y+1][1]);
                    }
                }else if(msg.data1==0x80){ // note off
                    e[x][y].keyOff();
                    lightOn(x,y,c[x][y][0]);
                    if(y>0&x>4){
                        lightOn(x-5,y-1,c[x-5][y-1][0]);
                    }
                    if(y<7&x<3){
                        lightOn(x+5,y+1,c[x+5][y+1][0]);
                    }
                }else if(msg.data1==0xA0){ // polyphonic aftertouch
                    //<<<"touchy">>>;
                    msg.data3/127.0=>dlp[x][y].data;
                    //<<<e[x][y].gain(),s[x][y].gain(),e[x][y].last()>>>;
                }
            }
        }
    }
}


fun void keyLights(){
    for(0=>int i;i<8;i++){
        for(0=>int j;j<8;j++)lightOn(i,j,c[i][j][on[i][j]]);
    }
}

fun void lightOn(int x, int y, int c){
    0x90=>msg.data1;
    p.grid[x][y]=>msg.data2;
    c=>msg.data3;
    mout.send(msg);
}

fun void lightOff(int x, int y){
    0x90=>msg.data1;
    p.grid[x][y]=>msg.data2;
    0=>msg.data3;
    mout.send(msg);
}

fun void lightsOff(){
    for(0=>int i;i<8;i++){
        for(0=>int j;j<8;j++)lightOff(i,j);
    }
}


//}