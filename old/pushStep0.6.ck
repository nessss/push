RhythmClock theClock;
theClock.BPM(120);
theClock.stepSize(theClock.sixteenth);
theClock.swingMode(1);
theClock.play();
PushCCs thePush;
RStep theRStep;
string mysounds[2];
"Push/sounds/kick.wav" => mysounds[0];
"Push/sounds/snr.wav" => mysounds[1];
theRStep.init(4,4,4,4,16, mysounds, 3, 3);
theRStep.updateGrid();
theRStep.padOnColor(46);
theRStep.curSound(0);
theRStep.inFocus(1);
PushKnob page0[16][8]; //gain, pan
int cPage;
int cDrum;
int cPat;
RStep drumSeqs[16];
string drumSounds[16][];
"1" => 16
for(0 => int i; i<drums.cap(); i++){
    drums[i].init(0,0,8,4,64,
}

RStep theOtherRStep;
string myothersounds[2];
"Push/sounds/kick.wav" => myothersounds[0];
"Push/sounds/snr.wav" => myothersounds[1];
theOtherRStep.init(0,4,4,4,16, myothersounds, 3, 3);
theOtherRStep.updateGrid();
theOtherRStep.padOnColor(46);
theOtherRStep.curSound(1);

while(samp=>now);
