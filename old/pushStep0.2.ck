Tempo theTempo;
RhythmClock theClock;
theClock.BPM(120);
theClock.stepSize(theTempo.sixteenth);
//theClock.patLen(64);
theClock.swingMode(1);
theClock.play();
RStep theRStep;
string mysounds[1];
"Push/sounds/kick.wav" => mysounds[0];
theRStep.init(4,4,4,4,16, mysounds);
//spork~midiIn();
theRStep.updateGrid();
theRStep.setColor(46);

while(samp=>now);

//Functions
