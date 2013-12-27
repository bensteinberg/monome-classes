// an example of using the arc to change frequencies of
// an oscillator and its modulator, and of using a map
// to write to the arc's LEDs

// audio network 
SinOsc mod => SinOsc osc => dac;

// modulator settings
250 => mod.gain;
100 => mod.freq;
// oscillator settings
2 => osc.sync;
0.1 => osc.gain;
440.0 => osc.freq;

// monome objects
MonomeDevice m;
MonomeArc arc;

// an array of arrays: [id, type, port]
m.getDeviceInfo() @=> string devices[][];

for (0 => int i ; i < devices.cap() ; i++) {
  <<< devices[i][0], devices[i][1], devices[i][2] >>>;
  if (devices[i][1] == "monome arc 2") {  // change to match your device
    <<< "connecting to", "arc on port", devices[i][2] >>>;
    devices[i][2] => Std.atoi => arc.connect;
  }
 }

// one map for each encoder
int map[2][0];
for (0 => int i ; i < 2 ; i++) {
  [ 8, 15, 8 ] @=> map[i];
  for (0 => int j ; j < 61 ; j++) {
    map[i] << 0;
  }
 }

// write the maps to the LEDs
for ( 0 => int i ; i < 2 ; i++ ) {
  (i, map[i]) => arc.ledMap;
 }
// wait for encoder movement
spork ~ turn_responder(arc.turn);
// report modulator and oscillator frequencies
spork ~ freq_reporter();

while (true) {
  1::second => now;
 }

fun void freq_reporter()
{
  while (true) {
    <<< "mod", mod.freq(), "osc", osc.freq() >>>;
    2::second => now;
  }
}

fun void turn_responder(Event e)
{
  while (true) {
    e => now;
    if (arc.encoder == 0) {
      osc.freq() + arc.delta => osc.freq;
    } else {
      mod.freq() + arc.delta => mod.freq;
    }
    mapshift(arc.encoder, arc.delta);
    (arc.encoder, map[arc.encoder]) => arc.ledMap;
    1::ms => now;
  }
}

// I wonder if/bet there's a faster or better way to do this.
fun void mapshift(int num, int delta)
{
  int tmp[64];
  int newpos;
  for (0 => int i ; i < 64 ; i++) {
    ((i + delta) % 64) => newpos;
    if (newpos < 0) {
      64 + newpos => newpos;
    }
    map[num][i] => tmp[newpos];
  }
  map[num].clear;
  tmp @=> map[num];
}
