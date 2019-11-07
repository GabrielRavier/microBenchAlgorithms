    ; r3 = destination
    ; r4 = fill
    ; r5 = length

ENTRY memsetCompilerWritersGuide
    mr r0, r5   ; length
    mr r31, r3
    cmplwi cr1, r0, 3   ; Total against 3
    rlwimi r5, r4, 8, 16, 23    ; Low half word of r5 = 2 copies of fill
    rlwimi r5, 16, 0, 15    ; r5 = 4 copies of fill
    ble cr1, .Ldone ; if (total <= 3)

    andi. r6, r3, 3  ; low 2 bits of destination
    cmpwi cr1, r6, 2
    beq cr0, .LwordAligned    ; If (length & 3 == 0)

    ; Not word aligned
    subf r0, r6, r0
    beq cr1, .LhwordAligned

    ; Not hword aligned
    stb r5, (r31)   ; Store 1 byte
    addi r31, 1
    blt cr1, .LwordAligned  ; Remainder is word aligned

.LhwordAligned:
    ; hword aligned
    sth r5, (r31)
    addi r31, 2

.LwordAligned:
    ; word aligned
    cmpwi cr0, r0, 0    ; Compare r0 to 0
    srwi r6, r0, 3  ; length / 8
    cmplwi cr2, r0, 8   ; total vs 8
    mtctr r6    ; ctr = amount of 8 byte blocks
    addi r31, -4    ; r31 = r3 - 4
    blt cr2, .Ldone ; total < 8
    andi. r0, 7 ; r0 = total % 8

.Lloop:
    stw r5, 4(r31)
    stw r5, 8(r31)  ; issue 2 aligned stores per iteration
    bdnz .Lloop ; loop till no more 8-byte blocks

.Ldone:
    beqlr cr0   ; return if 0 bytes left
    mtctr r0    ; ctr = amount of bytes left
    addi r31, -1

.LbyteLoop:
    stbu r5, 1(r31)
    bdnz .LbyteLoop
    blr ; return, r3 = destination
END memsetCompilerWritersGuide
