PUB Init
    DIRA[3] := 1
    DIRA[4] := 1
    DIRA[5] := 1
    DIRA[6] := 1
    DIRA[7] := 1
    DIRA[8] := 1
    DIRA[9] := 1
    DIRA[10] := 1
    DIRA[11] := 1
    DIRA[12] := 1
    DIRA[13] := 1
    DIRA[14] := 1

PUB Display(val)

    OUTA[3] := 0
    OUTA[4] := 0
    OUTA[5] := 0
    OUTA[6] := 0
    OUTA[7] := 0
    OUTA[8] := 0
    OUTA[9] := 0
    OUTA[10] := 0
    OUTA[11] := 0
    OUTA[12] := 0
    OUTA[13] := 0
    OUTA[14] := 0

    if val => 128
        OUTA[14] := 1
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
        OUTA[8] := 1
        val -= 8
    if val => 4
        OUTA[7] := 1
        val -= 4
    if val => 2
        OUTA[5] := 1
        val -= 2
    if val => 1
        OUTA[3] := 1
        val -= 1

