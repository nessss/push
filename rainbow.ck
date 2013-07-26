// pushRainbow.ck
//  for being cute
PushCCs pCC;
MidiOut mout;
MidiMsg msg;

mout.open(2);
<<<mout.name()>>>;

0x90=>msg.data1;


for(0=>int i;i<8;i++){
    for(0=>int j;j<8;j++){
        pCC.grid[i][j]=>msg.data2;
        if(j==0){
            5=>msg.data3;
        }else if(j==1){
            9=>msg.data3;
        }else if(j==2){
            13=>msg.data3;
        }else if(j==3){
            21=>msg.data3;
        }else if(j==4){
            25=>msg.data3;
        }else if(j==5){
            41=>msg.data3;
        }else if(j==6){
            70=>msg.data3;
        }else if(j==7){
            45=>msg.data3;
        }
    }
}