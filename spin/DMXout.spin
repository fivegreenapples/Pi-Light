'**************************************
'
'  DMX Transmiter  Ver. 1.03
'
' Modified by Teva McMillan to trasmit DMX
' using Timothy D. Swieter (www.tdswieter.com) DMX recv code as basis
'
'  
'
'Description:
'This program sends out a dmx packet configurable to any length.
'513 bytes is the max the DMX512 spec allows, and the first byte must
'be zero. The is handy in a way as the channels line up to value they are
'called with. Example:
'
' DMXout.Start(0)
'starts driver on a cog and transmiting using port a pin 0
'
' DMXout.Write(2, 255)  
'writes value 255 to channel 2 
'
'
'Don't write anything other then 0 to channel 0 unless you know 
'your hardware uses this for some reason.
'Most hardware will not respond if channel 0 is set to something
'other then 0
'
'The DMX signal is output to a MAX487 where the TTL/CMOS
'levels are converted to RS 485. 
'DMX is connected with 5 or 3 Pin XLR connectors.  Male is on receiving
'and female on sending.  The following circuit is for transmitting only.
{
Schematic                            MAX487E
────────────────────────────         ────────────────────────────
                +5V                      Pins   Names
          ┌────┐                        ────   ─────
      NC ─┤1  8├─┘                          1   RO
   Vdd ┬─┤2  7├── Pin 2 XLR Female        2   RE reciver output enable(active-low)
        └─┤3  6├── Pin 3 XLR Female        3   DE driver output enable(active-high)
P?  ───┤4  5├─┬ Pin 1 XLR Female        4   DI
      1k  └────┘ │                          5   GND
           487                             6   A
                Vss                         7   B
                                            8   VCC
}
'
'DMX Packet information:
'  250KHz. Clock (each bit 4 usec)
'  88 usec break at start of packet (22 low bits)
'  upto 513 bytes (1 start byte, 512 upto data bytes)
' 
'reference: http://www.dmx512-online.com/packt.html
'
'**************************************

CON

  PacketSize = 513

VAR

  'Processor
  long cog                      'Cog flag/ID

  'DMX    
  long TxPin                    'Pin for transmitting data to converter chip
  long BitTime                  'Length of bit
  long Channels                 'Number of channels to send
  long DataPointer              'Point to buffer              
  
  byte DMXdata[PacketSize]      'Array for all DMX values input from other objects

  
PUB start(TransmitPin) : okay

'' Start DMX driver - initialize variables, start a cog
'' returns cog ID (1-8) if good or 0 if no good 

  stop                                                  'Keeps from two cogs running

  'Initialize Variables
  TxPin :=  TransmitPin                                 'Init variable holding transmitting pin
  BitTime  := clkfreq * 4 / 1000000                     '4 usec per bit @ 250K BAUD
  Channels := PacketSize                                'Updates will be faster with lower numbers of channels   
  DataPointer := @DMXdata                               'Pointer to data buffer                        

  'Start a cog with assembly routine
  okay:= cog:= cognew(@Entry, @TxPin) + 1               'Returns 0-8 depending on success/failure

  
PUB stop

'' Stops DMX driver - frees a cog

  if cog                                                'Is cog non-zero?
    cogstop(cog~ - 1)                                   'Yes, stop the cog and then make value zero

  
PUB write(Channel, Value)

'' Write value into channel for transmission

   DMXdata[Channel] := Value

PUB getValuesPointer : ptr

'' returns a pointer to the start of the channel values

    return DataPointer

DAT
'
' Assembly Language DMX Driver
'
                        org
'
' Start of routine
'
Entry                   mov     t1,par                  'get boot parameter

                        rdlong  t2,t1                   'read TxPin, make txmask, set output
                        mov     txmask,#1 
                        shl     txmask,t2
                        mov     dira,txmask

                        add     t1,#4                   'read BitTime into txticks
                        rdlong  txticks,t1

                        add     t1,#4                   'read Channels into txchannels
                        rdlong  txchannels,t1

                        add     t1,#4                   'read DataPointer into txbase
                        rdlong  txbase,t1

                        mov     txcnt,cnt               'set initial cnt target
                        add     txcnt,txticks

' Packet loop: do idle, break, mark after break, data bytes (repeat)

packet                  mov     txdata,#1               'idle 
                        mov     txrep,#1
                        call    #tx

                        mov     txdata,#0               'break
                        mov     txrep,#30
                        call    #tx

                        mov     txdata,#1               'mark after break
                        mov     txrep,#2
                        call    #tx

                        mov     txptr,txbase            'data bytes
                        mov     txbytes,txchannels
:byte                   rdbyte  txdata,txptr
                        shl     txdata,#1
                        or      txdata,h00000600
                        mov     txbits,#11
:bit                    mov     txrep,#1
                        call    #tx                                                                  
                        shr     txdata,#1
                        djnz    txbits,#:bit
                        add     txptr,#1
                        djnz    txbytes,#:byte

                        jmp     #packet                 'repeat                        

'
' Transmit bit in lsb of txdata, repeat txrep times
'
tx                      waitcnt txcnt, txticks          'wait for next cnt target

                        test    txdata,#1       wc      'get bit to send into c 
                        muxc    outa,txmask             'output c to pin

                        djnz    txrep,#tx               'loop txrep times

tx_ret                  ret                        

'
' Initialized Data
'
h00000600               long    $00000600
'
' Uninitialized Data
'
t1                      res     1
t2                      res     1
txticks                 res     1
txchannels              res     1
txbase                  res     1
txmask                  res     1
txcnt                   res     1
txptr                   res     1
txbytes                 res     1
txbits                  res     1
txdata                  res     1
txrep                   res     1
                                           
