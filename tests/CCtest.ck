PushCCs p;

MidiIn min;
MidiMsg msg;

min.open(2);
<<<min.name()>>>;

while(min=>now){
    while(min.recv(msg)){
        if(msg.data1==0x90){
            for(0=>int i;i<8;i++){
                for(0=>int j;j<8;j++){
                    if(msg.data2==p.grid[i][j]){
                        <<<"Grid: "+i+", "+j+", Value: "+msg.data3>>>;
                    }
                }
            }
            for(0=>int i;i<p.touch.cap();i++){
                if(msg.data2==p.touch[i]){
                    <<<"Knob touch: "+i+", Value: "+msg.data3>>>;
                }
            }
            if(msg.data2==p.pbtouch){
                <<<"PB touch, Value: "+msg.data3>>>;
            }
        }
        if(msg.data1==0xB0){
            for(0=>int i;i<2;i++){
                for(0=>int j;j<8;j++){
                    if(msg.data2==p.sel[i][j]){
                        <<<"Select: "+i+", "+j+", Value: "+msg.data3>>>;
                    }
                }
            }
            for(0=>int i;i<p.knobs.cap();i++){
                if(msg.data2==p.knobs[i]){
                    <<<"Knob: "+i+", Value: "+msg.data3>>>;
                }
            }
            for(0=>int i;i<p.bcol0.cap();i++){
                if(msg.data2==p.bcol0[i]){
                    <<<"Button column 0: "+i+", Value: "+msg.data3>>>;
                }
            }
            for(0=>int i;i<p.bcol1.cap();i++){
                if(msg.data2==p.bcol1[i]){
                    <<<"Button column 1: "+i+", Value: "+msg.data3>>>;
                }
            }
            for(0=>int i;i<p.bcol2.cap();i++){
                if(msg.data2==p.bcol2[i]){
                    <<<"Button column 2: "+i+", Value: "+msg.data3>>>;
                }
            }
            for(0=>int i;i<p.bcol3.cap();i++){
                if(msg.data2==p.bcol3[i]){
                    <<<"Button column 3: "+i+", Value: "+msg.data3>>>;
                }
            }
            if(msg.data2==p.left){
                <<<"Left, Value: "+msg.data3>>>;
            }
            if(msg.data2==p.right){
                <<<"Right, Value: "+msg.data3>>>;
            }
            if(msg.data2==p.up){
                <<<"Up, Value: "+msg.data3>>>;
            }
            if(msg.data2==p.down){
                <<<"Down, Value: "+msg.data3>>>;
            }
        }
        if(msg.data1==0xE0){
            <<<"PB: "+((msg.data3<<7)|=>msg.data2)>>>;
        }
        if(msg.data1==0xA0){
            for(0=>int i;i<8;i++){
                for(0=>int j;j<8;j++){
                    if(msg.data2==p.grid[i][j]){
                        <<<"Grid AT: "+i+", "+j+", Value: "+msg.data3>>>;
                    }
                }
            }
        }
    }
}