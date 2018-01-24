CON
  _CLKMODE = xtal1 + pll16x
  _XINFREQ = 6_000_000
  
  UNIVERSES = 2

OBJ
    serial                      : "FullDuplexSerial"
'    dmxDriver[UNIVERSES]        : "DMXout"
    chanWatcher[UNIVERSES]      : "ChannelWatcher"
    transitioner[UNIVERSES]     : "DMXTransitionRunner"
    
VAR
    word multiCommandChannels[512]
    
PUB main | u
    DIRA[6] := 1
    DIRA[7] := 1
    DIRA[8] := 1
    DIRA[9] := 1
    DIRA[10] := 1
    DIRA[11] := 1
    DIRA[12] := 1
    DIRA[13] := 1
    waitcnt(CNT + CLKFREQ)
    writeByte(170)
    waitcnt(CNT + CLKFREQ)
    writeByte(0)
    waitcnt(CNT + CLKFREQ)
    writeByte(170)
    waitcnt(CNT + CLKFREQ)
    writeByte(0)

    serial.Start(31, 30, 0, 115200)
    repeat u FROM 1 TO UNIVERSES
'        dmxDriver[u].start(20+u)
'        transitioner[u].Start(dmxDriver[u].getDataPointer)
        waitcnt(CNT + CLKFREQ)
        writeByte(u)
        waitcnt(CNT + CLKFREQ)
        writeByte(0)

        chanWatcher[u].start
        waitcnt(CNT + CLKFREQ)
        writeByte(u+32)
        waitcnt(CNT + CLKFREQ)
        writeByte(0)
        chanWatcher[u].setWatchedChannel(100)
        waitcnt(CNT + CLKFREQ)
        writeByte(u+64)
        waitcnt(CNT + CLKFREQ)
        writeByte(0)
        transitioner[u].Start(chanWatcher[u].getDataPointer)
        waitcnt(CNT + CLKFREQ)
        writeByte(u+128)
        waitcnt(CNT + CLKFREQ)
        writeByte(0)


    waitcnt(CNT + CLKFREQ)
    writeByte(170)
    waitcnt(CNT + CLKFREQ)
    writeByte(0)
    waitcnt(CNT + CLKFREQ)
    writeByte(170)
    waitcnt(CNT + CLKFREQ)
    writeByte(0)
  
 
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
    
    writeByte(val)
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

PRI writeByte(val)

    'val := ChannelData[WatchedChannel]

    OUTA[6] := 0
    OUTA[7] := 0
    OUTA[8] := 0
    OUTA[9] := 0
    OUTA[10] := 0
    OUTA[11] := 0
    OUTA[12] := 0
    OUTA[13] := 0

    if val => 128
        OUTA[13] := 1
        val -= 128
    if val => 64
        OUTA[12] := 1
        val -= 64
    if val => 32
        OUTA[11] := 1
        val -= 32
    if val => 16
        OUTA[10] := 1
        val -= 16
    if val => 8
        OUTA[9] := 1
        val -= 8
    if val => 4
        OUTA[8] := 1
        val -= 4
    if val => 2
        OUTA[7] := 1
        val -= 2
    if val => 1
        OUTA[6] := 1
        val -= 1

