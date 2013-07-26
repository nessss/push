PushDisplay pD;
PushKnob k[8][4];
PushKnob p;
4=>int pages;
0=>int myPage;
pD.init();

/*
k[0].init(0,0,0,0,1,1,pD);

<<<k[0].getValuePosX()>>>;

*/

p.init(9,0,pD,2,"");
p.displaysValue(0);
p.displaysCursor(0);
p.focus(1);
for(0=>int i;i<k.cap();i++){
    for(0=>int j;j<pages;j++){
        k[i][j].init(i,0,pD,2,Std.itoa(i));
        k[i][j].valueScale(1000);
        k[i][j].valueOffset(0);
        k[i][j].valueStyle(1);
        1=>k[i][j].useValLabel;
        " ms"=>k[i][j].valLabel;
        spork~printValue(k[i][j]);
    }
}
page(0);

pageListen();

k[0][0].shiftOn=>now;
<<<"shift">>>;

while(samp=>now);

fun void printValue(PushKnob pK){
    while(pK.moved=>now){
        pD.updateDisplay();
        //<<<"Knob "+pK.knob()+": "+pK.pos()>>>;
    }
}

fun int page(int p){
    while(p>=pages)pages-=>p;
    while(p<0)pages+=>p;
    p=>myPage;
    //<<<"Page "+myPage>>>;
    for(0=>int i;i<8;i++){
        for(0=>int j;j<pages;j++){
            k[i][j].focus(0);
        }
        k[i][myPage].focus(1);
    }
    pD.updateDisplay();
    return myPage;
}

fun int page(){
    return myPage;
}

fun void pageListen(){
    spork~incListen();
    spork~decListen();
}

fun void incListen(){
    while(p.increment=>now){
        page(page()+1);
    }
}
fun void decListen(){
    while(p.decrement=>now){
        page(page()-1);
    }
}
