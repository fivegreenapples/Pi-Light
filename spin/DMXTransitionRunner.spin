CON
    TransitionSize = 12 ' 12 bytes to define transitions

OBJ
    byteDisplay                 : "ByteDisplay"

VAR
    byte TransitionData[512 * TransitionSize]
    long ValuesPointer

PUB Start(ChannelValuesPointer) : okay
    ValuesPointer := ChannelValuesPointer
    return TRUE

PUB SetTransition(channel, startVal, stopVal, type, duration)
    BYTE[ValuesPointer][channel] := startVal

PUB SetMultiTransition(channelsAddr, channelCount, startVal, stopVal, type, duration) | chanIdx, chan
    chanIdx := 0
    repeat channelCount
        chan := WORD[channelsAddr][chanIdx]
        BYTE[ValuesPointer][chan] := startVal
        chanIdx++
    