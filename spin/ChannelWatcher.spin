CON

    CHANNELS = 513

VAR
    long Cog
  
    byte ChannelData[CHANNELS]
    long WatchedChannel
    
    long watchStack[10]
  
PUB start : okay

    '' Start channel watcher - initialize variables, start a cog
    '' returns cog ID (1-8) if good or 0 if no good 

    stop                                        'Keeps from two cogs running
    
    'Initialize Variables
    WatchedChannel  := 1
        
    'Start a cog with watching routine
   ' okay := Cog := COGNEW(watch, @watchStack) + 1            'Returns 0-8 depending on success/failure





PUB stop

    '' Stops DMX driver - frees a cog
    
    if Cog                                      'Is cog non-zero?
        COGSTOP(Cog~ - 1)                       'Yes, stop the cog and then make value zero





PUB setWatchedChannel(chan)

    '' Sets which channel to watch

    WatchedChannel := chan






PUB getDataPointer : ptr

    '' returns a pointer to the start of the channel values
    
    ptr := @ChannelData + 1





PRI watch | val

    DIRA[6] := 1
    DIRA[7] := 1
    DIRA[8] := 1
    DIRA[9] := 1
    DIRA[10] := 1
    DIRA[11] := 1
    DIRA[12] := 1
    DIRA[13] := 1
    repeat
        WAITCNT(CNT + CLKFREQ / 4)       'wait a millisecond
        val := ChannelData[WatchedChannel]

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

