CON

    CHANNELS = 513

OBJ
    byteDisplay                 : "ByteDisplay"

VAR
    long Cog
  
    byte ChannelData[CHANNELS]
    long WatchedChannel
    
    long watchStack[100]
  
PUB start : okay
    
    byteDisplay.Init

    '' Start channel watcher - initialize variables, start a cog
    '' returns cog ID (1-8) if good or 0 if no good 

    stop                                        'Keeps from two cogs running
    
    'Initialize Variables
    WatchedChannel  := 1

    'Start a cog with watching routine
    okay := Cog := COGNEW(WatchChanDimmerSim, @watchStack) + 1            'Returns 0-8 depending on success/failure




PUB stop

    '' Stops DMX driver - frees a cog
    
    if Cog                                      'Is cog non-zero?
        COGSTOP(Cog~ - 1)                       'Yes, stop the cog and then make value zero





PUB setWatchedChannel(chan)

    '' Sets which channel to watch

    WatchedChannel := chan






PUB getDataPointer : ptr

    '' returns a pointer to the start of the channel values
    
    ptr := @ChannelData





PUB WatchChan | val
    byteDisplay.Init
    repeat
        'WAITCNT(CNT + (CLKFREQ / 4))       'wait a millisecond
        val := ChannelData[WatchedChannel]
        byteDisplay.Display(val)


PUB WatchChanDimmerSim | val
    byteDisplay.Init
    repeat
        val := ChannelData[WatchedChannel]
        
        byteDisplay.Display(255)
        WAITCNT(10000 + (val * 10000) + CNT)       'wait a millisecond
        
        byteDisplay.Display(0)
        WAITCNT(((255 - val) * 10000) + 10000 + CNT)       'wait a millisecond
        
