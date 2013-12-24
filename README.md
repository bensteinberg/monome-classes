monome-classes
==============
MonomeGrid.ck contains a class for using a monome grid in ChucK.  It
is derived from the LicK Library's
[Monome.ck](https://github.com/heuermh/lick/blob/master/Monome.ck) and
Raymond Weiterkamp's
[monomeclass0.4.ck](http://monome.org/docs/_media/app:monomeclass0.4.ck.zip),
but communicates with the grid via serialosc and uses the current
(late 2013) OSC messages.  It does not yet handle tilt or
varibrightness. 

This file will be joined shortly by MonomeArc.ck and examples of use.
For now, add the MonomeGrid.ck shred in the miniAudicle, then add a
shred with code like this:

```
MonomeGrid m;
m.getDeviceInfo() @=> string devices[][];

for (0 => int i ; i < devices.cap() ; i++) {
  <<< devices[i][0], devices[i][1], devices[i][2] >>>;
  if (devices[i][1] == "monome 128") {
    m.gridSize("128h");
    Std.atoi(devices[i][2]) => int port;
    m.connect(port);
  }
}

m.ledAllOn();
0.5::second => now;
m.ledAllOff();

```

Then spork a shred watching for the m.button Event.  

Initialization is a little awkward, but I wanted to accommodate the
lucky few who have multiple grids.