OBJ
    byteDisplay                 : "ByteDisplay"

VAR
    long Cog
  
    long WatchedChannel
    long ValuesPointer
    
    long watchStack[100]
  
PUB Start(ChannelValuesPointer)
    
    '' Start channel watcher - initialize variables, start a cog

    Stop                                        'Keeps from two cogs running

    ValuesPointer := ChannelValuesPointer
    
    'Initialize Variables
    WatchedChannel  := 1

    'Start a cog with watching routine
    Cog := COGNEW(WatchChan, @watchStack) + 1            'Returns 0-8 depending on success/failure




PUB Stop

    '' Stops DMX driver - frees a cog
    
    if Cog                                      'Is cog non-zero?
        COGSTOP(Cog~ - 1)                       'Yes, stop the cog and then make value zero





PUB setWatchedChannel(chan)

    '' Sets which channel to watch

    WatchedChannel := chan





PUB WatchChan | val
    byteDisplay.Init
    repeat
        'WAITCNT(CNT + (CLKFREQ / 1000))       'wait a millisecond
        val := BYTE[ValuesPointer][WatchedChannel]
        byteDisplay.Display(val)


PUB WatchChanDimmerSim | val
    byteDisplay.Init
    repeat
        val := BYTE[ValuesPointer][WatchedChannel]
        
        byteDisplay.Display(255)
        WAITCNT(10000 + (val * 10000) + CNT)       'wait a millisecond
        
        byteDisplay.Display(0)
        WAITCNT(((255 - val) * 10000) + 10000 + CNT)       'wait a millisecond
        
