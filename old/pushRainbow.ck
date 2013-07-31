// pushRainbow.ck
//  for being cute
PushCCs pCC;
PushDisplay pD;
MidiIn min;
MidiMsg minMsg;
MidiOut mout;
MidiMsg msg;


mout.open(2);
<<<mout.name()>>>;
min.open(2);
<<<min.name()>>>;

0x90=>msg.data1;

int brite[8][8];
int briteSel[2][8];

pD.setLine(0,"\005\006\006\006\006>          \005\005               \005 >\006\006\006\006\006\006\006\006\006\006\006\006\006< |>>>>>          |");
pD.setLine(1,"\005  <\006\006\006\006<       \005\\_______________/ \005_____________\005 |  <<<<<<       |");
pD.setLine(2,"\005      >\006\006\006\006>   \005        \005        /               \\|      >>>>>>   |");
pD.setLine(3,"\005          <\006\006\006\006\005        \005        \005               \005|          <<<<<|");
pD.updateDisplay();

for(0=>int i;i<8;i++){
    for(0=>int j;j<8;j++){
        0=>brite[i][j];
    }
}

spork~fingerLight();

while(10::ms=>now){
    0x90=>msg.data1;
    for(0=>int i;i<8;i++){
        for(0=>int j;j<8;j++){
            pCC.grid[i][j]=>msg.data2;
            if(j==0){
                5=>msg.data3;
            }else if(j==1){
                8=>msg.data3;
            }else if(j==2){
                12=>msg.data3;
            }else if(j==3){
                21=>msg.data3;
            }else if(j==4){
                29=>msg.data3;
            }else if(j==5){
                41=>msg.data3;
            }else if(j==6){
                45=>msg.data3;
            }else if(j==7){
                49=>msg.data3;
            }
            if(!brite[i][j])1+=>msg.data3;
            1+=>msg.data3;
            mout.send(msg);
        }
    }
    0xB0=>msg.data1;
    for(0=>int i;i<2;i++){
        for(0=>int j;j<8;j++){
            pCC.sel[i][j]=>msg.data2;
            if(j==0){
                5=>msg.data3;
            }else if(j==1){
                8=>msg.data3;
            }else if(j==2){
                12=>msg.data3;
            }else if(j==3){
                21=>msg.data3;
            }else if(j==4){
                29=>msg.data3;
            }else if(j==5){
                41=>msg.data3;
            }else if(j==6){
                45=>msg.data3;
            }else if(j==7){
                49=>msg.data3;
            }
            if(!briteSel[i][j])1+=>msg.data3;
            1+=>msg.data3;
            if(i!=0)mout.send(msg);
        }
    }
}

while(samp=>now);


fun void fingerLight(){
    while(min=>now){
        while(min.recv(minMsg)){
            for(0=>int i;i<8;i++){
                for(0=>int j;j<8;j++){
                    if(minMsg.data2==pCC.grid[i][j]){
                        if(minMsg.data1==0x90){
                            1=>brite[i][j];
                        }
                        else if(minMsg.data1==0x80){
                            0=>brite[i][j];
                        }
                    }
                }
            }
            for(0=>int i;i<2;i++){
                for(0=>int j;j<8;j++){
                    if(minMsg.data2==pCC.sel[i][j]){
                        if(minMsg.data3==0x7F){
                            1=>briteSel[i][j];
                        }
                        else if(minMsg.data3==0x00){
                            0=>briteSel[i][j];
                        }
                    }
                }
            }
            if(minMsg.data2==pCC.touch[8]){
                for(0=>int i;i<8;i++){
                    for(0=>int j;j<8;j++){
                        if(minMsg.data1==0x90){
                            if(minMsg.data3==127){
                                1=>briteSel[1][j];
                                1=>brite[i][j];
                            }
                            else 0=>brite[i][j];
                            0=>briteSel[1][j];
                        }
                    }
                }
            }
        }
    }
}
