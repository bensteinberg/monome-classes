/*

  MonomeArc.ck

  A class for connecting to a monome arc via serialosc

  v0.1

  Copyright 2013 Ben Steinberg

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

public class MonomeArc
{
  OscRecv client;
  OscSend engine;
  OscEvent rotate;
  OscEvent press;

  Event turn;
  Event turns[4];
  Event push;
  
  12003 => int serialOscRecvPort;

  "localhost" => string engineHost;

  int enginePort;
  string namespace;
  int clientPort;

  // encoder vars
  int encoder;
  int delta;
  // button vars
  int pressed;
  int state;
  
  // get list of devices with getDeviceInfo();
  // call connect() with the appropriate port
  fun void connect(int port)
  {
    port => enginePort;
    serialOscRecvPort => client.port;
    client.listen();
    _getPrefix() => namespace;
    _getClientPort() => clientPort;
    clientPort => client.port;
    client.listen();
    client.event(namespace + "/enc/delta, ii") @=> rotate;
    client.event(namespace + "/enc/key, ii") @=> press;
    spork ~ _waitForEncoder();
    spork ~ _waitForButton();
    engine.setHost(engineHost, enginePort);
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

  
  fun void _waitForEncoder()
  {
    while (true)
      {
	rotate => now;
	while (rotate.nextMsg())
	  {
	    rotate.getInt() => encoder;
	    rotate.getInt() => delta;
	    turn.broadcast();
	    turns[encoder].broadcast();
	  }
      }
  }

  fun void _waitForButton()
  {
    while (true)
      {
	press => now;
	while (press.nextMsg())
	  {
	    press.getInt() => int my_encoder;
	    press.getInt() => int my_state;
	    if (my_state == 0)
	      {
		_buttonReleased(my_encoder);
	      }
	    else
	      {
		_buttonPressed(my_encoder);
	      }
	  }
      }
  }

  fun void _buttonPressed(int my_encoder)
  {
    my_encoder => pressed;
    1 => state;
    push.broadcast();
  }

  fun void _buttonReleased(int my_encoder)
  {
    my_encoder => pressed;
    0 => state;
    push.broadcast();
  }

  // here are the functions for managing LEDs

  fun void ledSet(int my_encoder, int my_led, int my_level)
  {
    engine.startMsg(namespace + "/ring/set", "iii");
    my_encoder => engine.addInt;
    my_led => engine.addInt;
    my_level => engine.addInt;
  }

  fun void ledAllSet(int my_encoder, int my_level)
  {
    engine.startMsg(namespace + "/ring/all", "ii");
    my_encoder => engine.addInt;
    my_level => engine.addInt;
  }

  fun void ledMap(int my_encoder, int my_levels[])
  {
    engine.startMsg(namespace + "/ring/map", "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
    my_encoder => engine.addInt;
    for (0 => int i ; i < 64 ; i++) {
      my_levels[i] => engine.addInt;
    }
  }

  fun void ledRange(int my_encoder, int my_start, int my_end, int my_level)
  {
    engine.startMsg(namespace + "/ring/range", "iiii");
    my_encoder => engine.addInt;
    my_start => engine.addInt;
    my_end => engine.addInt;
    my_level => engine.addInt;
  }
  
}

