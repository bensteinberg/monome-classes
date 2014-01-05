// test file for grid and arc classes

MonomeDevice m;
MonomeGrid grid;
MonomeArc arc;

// an array of arrays: [id, type, port]
m.getDeviceInfo() @=> string devices[][];

for (0 => int i ; i < devices.cap() ; i++) {
  <<< devices[i][0], devices[i][1], devices[i][2] >>>;
  if (devices[i][1] == "monome 128") {   // change to match your device
    <<< "connecting to", "grid" >>>;
    "128h" => grid.gridSize;             // change to match your device
    // connect
    devices[i][2] => Std.atoi => grid.connect;
    // listen for button changes
    spork ~ buttonResponder(grid.button);
    // turn on and listen for tilt
    grid.tiltSet(0,1);
    spork ~ tiltResponder(grid.tilted);
    // test LED methods
    spork ~ test_grid_leds();
  }
  if (devices[i][1] == "monome arc 2") { // change to match your device
    <<< "connecting to", "arc on port", devices[i][2] >>>;
    // connect
    devices[i][2] => Std.atoi => arc.connect;
    // listen for turn
    spork ~ turn_responder(arc.turn);
    // listen for push
    spork ~ push_responder(arc.push);
    // test LED methods
    spork ~ test_arc_leds();
  }
 }
35::second => now;

fun void test_arc_leds()
{

  for ( 0 => int i ; i < 2 ; i++ ) {
    (i, 0) => arc.ledAllSet;
  }
  <<< "testing", "ledSet()" >>>;
  for ( 0 => int i ; i < 2 ; i++ ) {
    for ( 0 => int j ; j < 64 ; j++ ) {
      (i, j, j % 16) => arc.ledSet;
      0.01::second => now;
    }
  }
  <<< "testing", "ledAllSet()" >>>;
  for ( 0 => int i ; i < 2 ; i++ ) {
    for ( 0 => int j ; j < 16 ; j++ ) {
      (i, j) => arc.ledAllSet;
      0.01::second => now;
    }
  }
  0.5::second => now;
  for ( 0 => int i ; i < 2 ; i++ ) {
    (i, 0) => arc.ledAllSet;
  }
  <<< "testing", "ledMap()" >>>;
  for ( 0 => int i ; i < 2 ; i++ ) {
    int map[0];
    for (0 => int j ; j < 64 ; j++ ) {
      map << Math.random2(0,15);
    }
    (i, map) => arc.ledMap;
  }
  0.5::second => now;
  for ( 0 => int i ; i < 2 ; i++ ) {
    (i, 0) => arc.ledAllSet;
  }
  <<< "testing", "ledRange()" >>>;
  for ( 0 => int i ; i < 2 ; i++ ) {
    (i, Math.random2(0,31), Math.random2(32,63), Math.random2(1,15)) => arc.ledRange;
  }
  0.5::second => now;
  for ( 0 => int i ; i < 2 ; i++ ) {
    (i, 0) => arc.ledAllSet;
  }
  <<< "all", "done" >>>;
}

fun void turn_responder(Event e)
{
  while (true) {
    e => now;
    <<< "Turn of", arc.delta, "on encoder", arc.encoder >>>;
    1::ms => now;
  }
}

fun void push_responder(Event e)
{
  while (true) {
    e => now;
    string type;
    if (arc.state == 1) {
      "press" => type;
    } else {
      "release" => type;
    }
    <<< type, "on encoder", arc.pressed >>>;
    1::ms => now;
  }
}

fun void test_grid_leds()
{

  int x,y;

  <<< "testing", "ledAllOn() and Off()" >>>;
  grid.ledAllOn();
  0.5::second => now;
  grid.ledAllOff();
  0.5::second => now;
  
  <<< "testing", "ledAllSet" >>>;
  grid.ledAllSet(1);
  0.5::second => now;
  grid.ledAllSet(0);
  0.5::second => now;
  
  <<< "testing", "ledOn() and Off()" >>>;
  for (0 => int i ; i < 16 ; i++) {
    Math.random2(0, grid.xWidth - 1) => x;
    Math.random2(0, grid.yHeight - 1) => y;
    (x,y) => grid.ledOn;
    0.1::second => now;
    (x,y) => grid.ledOff;
  }

  <<< "testing", "ledSet()" >>>;
  for (0 => int i ; i < 16 ; i++) {
    Math.random2(0, grid.xWidth - 1) => x;
    Math.random2(0, grid.yHeight - 1) => y;
    (x,y,1) => grid.ledSet;
    0.1::second => now;
    (x,y,0) => grid.ledSet;
  }

  <<< "testing", "rowOn() and Off()" >>>;
  for (0 => int i ; i < grid.yHeight ; i++) {
    grid.rowOn(i);
    0.1::second => now;
    grid.rowOff(i);
    0.1::second => now;
  }

  <<< "testing", "rowSet()" >>>;
  for (0 => int i ; i < grid.yHeight ; i++) {
    grid.rowSet(0, i, [255, 255]);
    0.1::second => now;
    grid.rowSet(0, i, [0, 0]);
    0.1::second => now;
  }

  <<< "testing", "rowSet()" >>>;
  for (0 => int i ; i < 20 ; i++ ) {
    for (0 => int j ; j < grid.yHeight ; j++) {
      grid.rowSet(0, j, [Math.random2(0,255), Math.random2(0,255)]);
    }
    0.5::second => now;
  }
  
  <<< "testing", "columnOn() and Off()" >>>;
  for (0 => int i ; i < grid.xWidth ; i++) {
    grid.columnOn(i);
    0.1::second => now;
    grid.columnOff(i);
    0.1::second => now;
  }

  <<< "testing", "columnSet()" >>>;
  for (0 => int i ; i < grid.xWidth ; i++) {
    grid.columnSet(i, 0, [255]);
    0.1::second => now;
    grid.columnSet(i, 0, [0]);
    0.1::second => now;
  }

  <<< "testing", "columnSet()" >>>;
  for (0 => int i ; i < 20 ; i++ ) {
    for (0 => int j ; j < grid.xWidth ; j++) {
      grid.columnSet(j, 0, [Math.random2(0,255)]);
    }
    0.2::second => now;
  }
  
  <<< "testing", "ledMap()" >>>;
  for (0 => int i ; i < 8 ; i++) {
    int map[2][0];
    for (0 => int j ; j < 8 ; j++) {
      map[0] << Math.random2(0,255);
    }
    grid.ledMap(0,0,map[0]);
    for (0 => int j ; j < 8 ; j++) {
      map[1] << Math.random2(0,255);
    }
    grid.ledMap(8,0,map[1]);
    0.2::second => now;
  }

  <<< "testing", "ledIntensity()" >>>;
  grid.ledAllOn();
  for (0 => int i ; i < 16 ; i++) {
    0.2::second => now;
    i => grid.ledIntensity;
  }
  
  grid.ledAllOff();
  <<< "goodbye", "!" >>>;
}  

// you have to keep track of the original condition of the tilt sensor,
// as here; you could also write code to "re-zero" the position
fun void tiltResponder(Event e)
{
  -1 => int xOrigin;
  -1 => int yOrigin;
  while (true) {
    e => now;
    if (xOrigin == -1) {
      grid.tiltVals[1] => xOrigin;
      grid.tiltVals[2] => yOrigin;
    }
    if ((Std.abs(grid.tiltVals[1] - xOrigin) > 2) || (Std.abs(grid.tiltVals[2] - yOrigin) > 2)) {
      <<< "tilt!", "" >>>;
      <<< "", "'zero' values:", xOrigin, yOrigin >>>;
      <<< "", "n x y z:", grid.tiltVals[0], grid.tiltVals[1], grid.tiltVals[2], grid.tiltVals[3] >>>;
    }
    1::ms => now;
  }
}


fun void buttonResponder(Event e)
{
  while (true) {
    e => now;
    <<< "button", "!" >>>;
    if (grid.state == 1) {
      grid.ledOn(grid.x, grid.y);
    } else {
      grid.ledOff(grid.x, grid.y);
    }
    <<< grid.x, grid.y, grid.state>>>;
    1::ms => now;
  }
}
  
