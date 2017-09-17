# MOS6581 SID chip emulator in SystemVerilog

This is a raw code dump of a *very* unfinished MOS6581 emulation project. The code was hacked together while learning Verilog, and may therefore lack some refinement.

Most SID tunes work fine. Even digi-sounds work somehow, despite the slow serial protocol I used for testing. A good next step would be to integrate a 6502 emulator for stand-alone operation or connect it to a real C64.

The wave and envelope generators are based on the Bob Yannes interview, the state-variable filter is inspired by Kebby^Farbrausch's TinySID player, and the rest is similar to the countless other SID projects on the net.

## Usage

The code can be compiled using Altera Quartus Prime 15.1 and was tested on a BeMicro MAX10 board. 

Only two pins are used:

**GPIO_02** - UART input, 115200 8N1

You need a modified SID player on a PC to send register accesses over an USB->UART converter or similar. The protocol is extremely simple:   
    
  * 1st byte: register address 0-31
  * 2nd byte: data to write

This is fast enough for normal SID tunes which write 25 registers at 50 or 60 Hz. SID tunes with digisounds will need a higher baudrate to work correctly.


**GPIO_04** - 16-Bit sigma-delta audio output

Just wire up a 10uF capacitor and a headphone jack in series: 

  * GPIO_04 (J3 Pin 2) - 10uF - Headphones - GND (J3 Pin 12)


## License

Copyright (c)2015-2017 Thomas Kindler <mail_sid@t-kindler.de>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
