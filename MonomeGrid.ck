/*

  MonomeGrid.ck

  A class for connecting to a monome grid via serialosc

  v0.1

  Copyright 2013 Ben Steinberg

  derived from LiCK Library's

    https://github.com/heuermh/lick/blob/master/Monome.ck

  and Raymond Weitekamp's 

    http://monome.org/docs/_media/app:monomeclass0.4.ck.zip
  
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
*/

public class MonomeGrid
{
  OscRecv client;
  OscSend engine;
  OscEvent press;
  OscEvent tilt;

  Event button;
  //Event tilted;
  
  12002 => int serialOscXmitPort;
  12003 => int serialOscRecvPort;

  "localhost" => string engineHost;

  // define grid size (default 64, use gridSize() for others)
  8 => int xWidth;
  8 => int yHeight;

  //vars
  int x, y, state;
  //float tiltVals[2];
  int enginePort;
  string namespace;
  int clientPort;

  // get list of devices with getDeviceInfo();
  // set size with gridSize(); then
  // call connect() with the appropriate port
  fun void connect(int port)
  {
    port => enginePort;
    _getPrefix() => namespace;
    _getClientPort() => clientPort;
    clientPort => client.port;
    client.listen();
    client.event(namespace + "/grid/key, iii") @=> press;
    client.event(namespace + "/tilt, iiii") @=> tilt;
    spork ~ _waitForEvent();
    //spork ~ _waitForTilt();
    engine.setHost(engineHost, enginePort);
  }

  // returns an array of arrays,
  // [id, type, port] -- decide which you want,
  // then chuck the port to connect()
  fun string[][] getDeviceInfo()
  {
    string result[0][0];
    engine.setHost(engineHost, serialOscXmitPort);
    serialOscRecvPort => client.port; 
    client.listen();
    client.event("/serialosc/device,ssi") @=> OscEvent device_event;
    engine.startMsg ( "/serialosc/list", "si");
    engineHost => engine.addString;
    serialOscRecvPort => engine.addInt;
    device_event => now;
    while (device_event.nextMsg() != 0) {
      device_event.getString() => string id;
      device_event.getString() => string type;
      device_event.getInt() => int port;
      [id, type, Std.itoa(port)] @=> string device[];
      result << device;
    }
    return result;
  }

  //initialize standard sizes: 64, 128h, 128v, 256
  fun void gridSize(string s){
    if (s == "64") {
      8 => xWidth => yHeight;
    }
    if (s == "128h") {
      16 => xWidth;
      8 => yHeight;
    }
    if (s == "128v") {
      8 => xWidth;
      16 => yHeight;
    }
    if (s == "256") {
      16 => xWidth => yHeight;
    }
  }

  fun int _getClientPort()
  {
    engine.setHost(engineHost, enginePort);
    client.event("/sys/port,i") @=> OscEvent dest_event;
    engine.startMsg ( "/sys/info", "si" );
    engineHost => engine.addString;
    serialOscRecvPort => engine.addInt;

    dest_event => now;
    int destport;
    while (dest_event.nextMsg() != 0) {
      dest_event.getInt() => destport;
    }
    //<<< "recv port", destport >>>;
    return destport;
  }

  fun string _getPrefix()
  {
    engine.setHost(engineHost, enginePort);
    client.event("/sys/prefix,s") @=> OscEvent prefix_event;
    engine.startMsg ( "/sys/info", "si" );
    engineHost => engine.addString;
    serialOscRecvPort => engine.addInt;

    prefix_event => now;
    string pfx;
    while (prefix_event.nextMsg() != 0) {
      prefix_event.getString() => pfx;
    }
    //<<< "prefix", pfx >>>;
    return pfx;
  }

  
  fun void _waitForEvent()
  {
    while (true)
      {
	press => now;
	while (press.nextMsg())
	  {
	    press.getInt() => int my_x;
	    press.getInt() => int my_y;
	    press.getInt() => int my_value;
	    if (my_value == 0)
	      {
		_buttonReleased(my_x, my_y);
	      }
	    else
	      {
		_buttonPressed(my_x, my_y);
	      }
	  }
      }
  }

  /*  
  fun void _waitForTilt()
  {
    while (true)
      {
	tilt => now;
	<<< "got", "a tilt" >>>;
	while (tilt.nextMsg())
	  {
	    // press.getInt() => int which;
	    // press.getInt() => int my_x;
	    // press.getInt() => int my_y;
	    // press.getInt() => int my_z;
	    press.getFloat() => float first;
	    press.getFloat() => float next;
	    <<< first, next >>>;
	    //<<< which, my_x, my_y, my_z >>>;
	    //[which, my_x, my_y, my_z] @=> int my_tiltVals[];
	    [first, next] @=> float my_tiltVals[];
	    my_tiltVals @=> tiltVals;
	    tilted.broadcast();
	  }
      }
  }
  */
  
  fun void _buttonPressed(int my_x, int my_y)
  {
    my_x => x;
    my_y => y;
    1 => state;
    button.broadcast();
  }

  fun void _buttonReleased(int my_x, int my_y)
  {
    my_x => x;
    my_y => y;
    0 => state;
    button.broadcast();
  }

  // here are the functions for managing LEDs

  fun void ledOn(int my_x, int my_y)
  {
    engine.startMsg(namespace + "/grid/led/set", "iii");
    my_x => engine.addInt;
    my_y => engine.addInt;
    1 => engine.addInt;
  }

  fun void ledOff(int my_x, int my_y)
  {
    engine.startMsg(namespace + "/grid/led/set", "iii");
    my_x => engine.addInt;
    my_y => engine.addInt;
    0 => engine.addInt;
  }

  fun void ledSet(int my_x, int my_y, int val)
  {
    engine.startMsg(namespace + "/grid/led/set", "iii");
    my_x => engine.addInt;
    my_y => engine.addInt;
    val => engine.addInt;
  }

  fun void rowOn(int row)
  {
    if (xWidth == 8) {
      engine.startMsg(namespace + "/grid/led/row", "iii");
      0 => engine.addInt;
      row => engine.addInt;
      255 => engine.addInt;
    }
    if (xWidth == 16) {
      engine.startMsg(namespace + "/grid/led/row", "iiii");
      0 => engine.addInt;
      row => engine.addInt;
      255 => engine.addInt;
      255 => engine.addInt;
    }
  }

  fun void rowOff(int row)
  {
    if (xWidth == 8) {
      engine.startMsg(namespace + "/grid/led/row", "iii");
      0 => engine.addInt;
      row => engine.addInt;
      0 => engine.addInt;
    }
    if (xWidth == 16) {
      engine.startMsg(namespace + "/grid/led/row", "iiii");
      8 => engine.addInt;
      row => engine.addInt;
      0 => engine.addInt;
      0 => engine.addInt;
    }
  }

  fun void rowSet(int offSet, int row, int map[])
  {
    if (xWidth == 8) {
      engine.startMsg(namespace + "/grid/led/row", "iii");
      offSet => engine.addInt;
      row => engine.addInt;
      map[0] => engine.addInt;
    } else if (xWidth == 16) {
      engine.startMsg(namespace + "/grid/led/row", "iiii");
      offSet => engine.addInt;
      row => engine.addInt;
      map[0] => engine.addInt;
      map[1] => engine.addInt;
    }
   }

  fun void columnOn(int col)
  {
    if (yHeight == 8) {
      engine.startMsg(namespace + "/grid/led/col", "iii");
      col => engine.addInt;
      0 => engine.addInt;
      255 => engine.addInt;
    } else if (yHeight == 16) {
      engine.startMsg(namespace + "/grid/led/col", "iiii");
      col => engine.addInt;
      0 => engine.addInt;
      255 => engine.addInt;
      255 => engine.addInt;
    }
  }

  fun void columnOff(int col)
  {
    if (yHeight == 8) {
      engine.startMsg(namespace + "/grid/led/col", "iii");
      col => engine.addInt;
      0 => engine.addInt;
      0 => engine.addInt;
    } else if (yHeight == 16) {
      engine.startMsg(namespace + "/grid/led/col", "iiii");
      col => engine.addInt;
      8 => engine.addInt;
      0 => engine.addInt;
      0 => engine.addInt;
    }
  }

  fun void columnSet(int col, int offSet, int map[])
  {
    if (yHeight == 8) {
      engine.startMsg(namespace + "/grid/led/col", "iii");
      col => engine.addInt;
      offSet => engine.addInt;
      map[0] => engine.addInt;
    } else if (yHeight == 16) {
      engine.startMsg(namespace + "/grid/led/col", "iii");
      col => engine.addInt;
      offSet => engine.addInt;
      map[0] => engine.addInt;
      map[1] => engine.addInt;
    }
  }

  fun void ledAllSet(int val)
  {
    engine.startMsg(namespace + "/grid/led/all", "i");
    val => engine.addInt;
  }

  fun void ledAllOn()
  {
    engine.startMsg(namespace + "/grid/led/all", "i");
    1 => engine.addInt;
  }

  fun void ledAllOff()
  {
    engine.startMsg(namespace + "/grid/led/all", "i");
    0 => engine.addInt;
  }

  fun void ledMap(int x_offset, int y_offset, int vals[])
  {
    engine.startMsg(namespace + "/grid/led/map", "iiiiiiiiii");
    x_offset => engine.addInt;
    y_offset => engine.addInt;
    for (0 => int i ; i < 8 ; i++) {
      vals[i] => engine.addInt;
    }
  }

  fun void ledIntensity(int val)
  {
    engine.startMsg(namespace + "/grid/led/intensity", "i");
    val => engine.addInt;
  }

  /*
  fun void tiltSet(int n, int s)
  {
    engine.startMsg(namespace + "/tilt/set", "ii");
    n => engine.addInt;
    s => engine.addInt;
  }
  */
  
}

