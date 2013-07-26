//Makes addressing Push CCs easier
//Note: All are CCs unless otherwise noted
//Bruce Lott & Mark Morris, June 2013
public class PushCCs{
    int grid[8][8]; //row then column
    int sel[2][8];   
    int knobs[11];
    int touch[11]; //Note
    int bcol0[12];
    int bcol1[10];
    int bcol2[11];
    int bcol3[11];
    int left;
    int right;
    int up;
    int down;
    int pbtouch; //Note; Use PB on channel one for value
    
    44=>left;
    45=>right;
    46=>up;
    47=>down;
    12=>pbtouch;
    
    //grid buttons
    for(0 => int i; i<8; i++){
        for(0 => int j; j<8; j++){
            92 + j - (8*i) => grid[i][j];
            //i=>grid[Std.itoa(92 + j - (8*i))]["x"];
            //j=>grid[Std.itoa(92 + j - (8*i))]["y"];
        }
    }
    for(0 => int i; i<8; i++){
        20 + i  => sel[0][i];
        102 + i => sel[1][i];
    }
    //knobs
    for(0 => int i; i<8; i++){
        71 + i => knobs[i];
    }
    for(0 => int i; i<11; i++){
        i => touch[i];
    }
    79 => knobs[8];
    14 => knobs[9];
    15 => knobs[10];
    8 => touch[8];
    10 => touch[9];
    9 => touch[10];
    3 => bcol0[0];
    9 => bcol0[1];
    for(0=>int i;i<4;i++){
        119-i=>bcol0[i+2];
    }
    for(0=>int i;i<6;i++){
        90-i=>bcol0[i+6];
    } 
    //bcol1
    28 => bcol1[0];
    29 => bcol1[1];
    
    for(0 => int i; i<8; i++) 43 - i => bcol1[i+2];
    for(0 => int i; i<3; i++){
        114 - (i*2) => bcol2[i];
        115 - (i*2) => bcol3[i];
    }
    for(0 => int i; i<8; i++){
        62 - (i*2) => bcol2[i+3];
        63 - (i*2) => bcol3[i+3];
    }
}