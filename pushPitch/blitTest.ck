BlitSquare sqr;
sqr => dac;
400 => sqr.freq;

1::second => now;

0 => sqr.gain;
BlitSaw saw;
saw => dac;
400 => saw.freq;

1::second => now;