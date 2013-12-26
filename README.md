monome-classes
==============
MonomeDevice.ck contains a class for detecting monome devices in ChucK.

MonomeGrid.ck contains a class for using a monome grid in ChucK.  It
is derived from the LicK Library's
[Monome.ck](https://github.com/heuermh/lick/blob/master/Monome.ck) and
Raymond Weiterkamp's
[monomeclass0.4.ck](http://monome.org/docs/_media/app:monomeclass0.4.ck.zip),
but communicates with the grid via serialosc and uses the current
(late 2013) OSC messages.  It does not yet handle tilt or
varibrightness.  Since I am traveling and don't have my grid with me,
I can't confirm that the current file works, but will be able to test
on or around 2013-01-04.  I am not quite happy with the methods
available, and may limit them.

MonomeArc.ck contains a class for using a monome arc in ChucK.
Although it has a mechanism for detecting presses, I have a newer arc
2, so I can't test it.

Together, init.ck and test.ck demonstrate the methods, variables, and
events available.  At the moment, identification and management of
grid size, orientation, and number of arc encoders are left to the user.

arcinit.ck and arctest.ck are an example of using the arc's encoders
to control the frequencies of an oscillator and its modulator, as well
as the use of maps to write to the arc's LEDs.