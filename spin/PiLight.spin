CON
  _CLKMODE = xtal1 + pll16x
  _XINFREQ = 6_000_000
  
  UNIVERSES = 1

OBJ
    serial                      : "FullDuplexSerial"
    dmxDriver[UNIVERSES]        : "DMXout"
    chanWatcher[UNIVERSES]      : "ChannelWatcher"
    transitioner[UNIVERSES]     : "DMXTransitionRunner"
    byteDisplay                 : "ByteDisplay"
    
VAR
    word multiCommandChannels[512]
    
PUB main | u
   
    serial.Start(31, 30, 0, 115200)

    u := 0
    repeat UNIVERSES
        dmxDriver[u].start(26+u)
        transitioner[u].Start(dmxDriver[u].getValuesPointer)
        chanWatcher[u].Start(dmxDriver[u].getValuesPointer)
        chanWatcher[u].setWatchedChannel(7)

        u++


 
    repeat
        decodeCommand(serial.Rx) 'Rx blocks until a byte is read


PRI decodeCommand(command) | universe
    universe := (command & $C0) >> 6
    if universe >= UNIVERSES
        ignoreCommand
        return
        
    case command
        1: decodeSetSingle(universe)
        2: decodeSetMulti(universe)
        OTHER: ignoreCommand


PRI decodeSetSingle(universe) | chanLSB, chan, val
    serial.Rx 'length, ignored
    chanLSB := serial.Rx 'channel LSB
    chan := serial.Rx 'channel MSB
    chan <<= 8
    chan += chanLSB
    val := serial.Rx
    
    'byteDisplay.Display(val)
    transitioner[universe].SetTransition(chan, val, val, 0, 0)

PRI decodeSetMulti(universe) | cmdLength, chanCount, chanIdx, chanLSB, chan, val
    cmdLength := serial.Rx 'length, indicates how many channels
    chanCount := (cmdLength - 1) / 2
    chanIdx := 0
    repeat chanCount
        chanLSB := serial.Rx 'channel LSB
        chan := serial.Rx 'channel MSB
        chan <<= 8
        chan += chanLSB
        multiCommandChannels[chanIdx] := chan
        chanIdx++
    val := serial.Rx
    
    transitioner[universe].SetMultiTransition(@multiCommandChannels, chanCount, val, val, 0, 0)

    
PRI ignoreCommand | cmdLength
    cmdLength := serial.Rx
    repeat cmdLength
        serial.Rx

