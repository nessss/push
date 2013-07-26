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

theRStep.curSound(1);

while(samp=>now);
