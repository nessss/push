// pushKnob string list functionality test


Push p;
p.init(2);
p.clearDisplay();
PushKnob pK;
pK.init(0,p,2,"Strings!");
pK.displaysValue(0);
pK.textPosY(1);
pK.cursorStyle(3);
pK.pos(0);
pK.selfIncrement(0);
pK.focus(1);

<<<pK.stringListMode(1)>>>;

string words[5];

"Meow"=>words[0];
"Nyaa"=>words[1];
"Walf"=>words[2];
"Wuff"=>words[3];
"Flowalf"=>words[4];

pK.stringList(words);

while(pK.listMoved=>now){
    //100::ms=>now;
    //pK.displayUpdate();
    p.updateDisplay();
}