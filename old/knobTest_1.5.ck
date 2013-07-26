MidiBroadcaster mB;
Push p;
PushKnob k[8][4];
PushKnob pK;
4=>int pages;
0=>int myPage;
p.init(1);
mB.init(2);

/*
k[0].init(0,0,0,0,1,1,pD);

<<<k[0].getValuePosX()>>>;

*/

string text[8];

for(0=>int i;i<text.cap();i++){
    Std.itoa(i)=>text[i];
}

0=>int t;
0=>int tot;
0=>int wrap;

pK.init(9,p,mB,"");
pK.displaysValue(0);
pK.displaysCursor(0);
pK.focus(1);
for(0=>int i;i<k.cap();i++){
    for(0=>int j;j<pages;j++){
        k[i][j].init(i,p,mB,Std.itoa(i));
        k[i][j].displaysValue(0);
        k[i][j].displaysText(1);
        k[i][j].textPosY(1);
        k[i][j].text(text[0]);
        k[i][j].cursorStyle(2);
        k[i][j].selfIncrement(0);
        spork~printValue(k[i][j]);
        updateText(k[i][j]);
    }
}
page(0);

pageListen();

k[0][0].shiftOn=>now;
<<<"shift">>>;

while(samp=>now);

fun void printValue(PushKnob pK){
    while(pK.moved=>now){
        p.updateDisplay();
        //<<<"Knob "+pK.knob()+": "+pK.pos()>>>;
    }
}

fun void updateText(PushKnob pK){
    spork~incListen(pK,tot);
    spork~decListen(pK,tot);
}

fun void incListen(PushKnob pK,int tot){
    while(pK.increment=>now){
        pK.incVal+=>tot;
        if(tot>20){
            20-=>tot;
            if(!wrap){
                t++;
                if(t>=text.cap())text.cap()-1=>t;
            }else(t+1)%text.cap()=>t;
            changeText(t);
            p.updateDisplay();
        }
    }
}

fun void decListen(PushKnob pK,int tot){
    while(pK.decrement=>now){
        pK.incVal+=>tot;
        if(tot<0){
            20+=>tot;
            if(!wrap){
                t--;
                if(t<0)0=>t;
            }else(t-1+text.cap())%text.cap()=>t;
            changeText(t);
            p.updateDisplay();
        }
    }
}

fun void changeText(int t){
    for(0=>int i;i<k.cap();i++){
        for(0=>int j;j<pages;j++){
            k[i][j].text(text[t]);
        }
    }
}

fun int page(int pg){
    while(pg>=pages)pages-=>pg;
    while(pg<0)pages+=>pg;
    pg=>myPage;
    //<<<"Page "+myPage>>>;
    for(0=>int i;i<8;i++){
        for(0=>int j;j<pages;j++){
            k[i][j].focus(0);
        }
        k[i][myPage].focus(1);
    }
    p.updateDisplay();
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
    while(pK.increment=>now){
        page(page()+1);
    }
}
fun void decListen(){
    while(pK.decrement=>now){
        page(page()-1);
    }
}
