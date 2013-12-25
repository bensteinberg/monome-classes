/*

  MonomeDevice.ck

  A class for identifying monome devices via serialosc

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

public class MonomeDevice
{
  OscRecv client;
  OscSend engine;
  
  12002 => int serialOscXmitPort;
  12003 => int serialOscRecvPort;

  "localhost" => string engineHost;

  int enginePort;
  int clientPort;

  // get list of devices with getDeviceInfo():
  // returns an array of arrays,
  // [id, type, port] -- decide which you want,
  // declare an arc or a grid, then
  // chuck the port to  arc.connect() or
  // grid.connect()
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
}

