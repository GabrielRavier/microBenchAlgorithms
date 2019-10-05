ENTRY neatlibcMemset
	mov r12, r0

.LNloop:
	subs r2, #1
	bmi .LNreturn

	strb r1, [r0], #1
	b .LNloop

.LNreturn:
	mov r0, r12
	bx lr
END neatlibcMemset





	.thumb_func
ENTRY uClibcThumb1Memset
	mov ip, r0
	cmp r2, #8	; At least 8 bytes to do ?
	bcc .LUfinish

	lsl r3, r1, #8
	orr r1, r3
	lsl r3, r1, #16
	orr r1, r3

	mov r3, #3

.LUalignLoop:
	; Fill up to the first word boundary
	tst r0, r3
	beq .LUalignedLoop

	strb r1, [r0]
	add r0, #1
	sub r2, #1
	b .LUalignLoop

.LUalignedLoop:
	; Fill aligned words
	str r1, [r0]
	add r0, #4
	sub r2, #4
	cmp r2, #4
	bcs .LUalignedLoop

.LUfinish:
	; Fill the remaining bytes
	cmp r2, #0
	beq .LUreturn

.LUfinishLoop:
	strb r1, [r0]
	add r0, #1
	sub r2, #1
	bne .LUfinishLoop

.LUreturn:
	mov r0, ip
	bx lr
END uClibcThumb1Memset





.macro mkUClibcMemset2 name, thumb2

ENTRY \name
	mov a4, a1
	cmp a3, $8	; At least 8 bytes to do ?
	blo .L\name\()less8Left

	orr a2, lsl $8
	orr a2, lsl $16

.L\name\()alignLoop:
	tst a4, $3	; Aligned yet ?
	strneb a2, [a4], $1
	subne a3, $1
	bne .L\name\()alignLoop

	mov ip, a2

.L\name\()bigLoop:
	cmp a3, $8	; 8 bytes still to do ?
	blo .L\name\()less8Left

	.rept 2

		stmia a4!, {a2, ip}
		sub a3, $8
		cmp a3, $8	 ; 8 bytes still to do ?
		blo .L\name\()less8Left

	.endr

	stmia a4!, {a2, ip}
	sub a3, $8
	cmp a3, $8	 ; 8 bytes still to do ?

	stmhsia a4!, {a2, ip}
	subhs a3, $8
	bhs .L\name\()bigLoop

.L\name\()less8Left:
	movs a3	; Anything left ?
	bxeq lr

.if thumb2
.L\name\()endLoop:
	strb a2, [a4], #1
	subs a3, #1
	bne .L\name\()endLoop

	bx lr
.else
	rsb a3, $7
	add pc, a3, lsl $2
	mov r0

	.rept 8

		strb a2, [a4], $1

	.endr

	bx lr

.endif

END \name

.endm

	mkUClibcMemset2 uClibcThumb2Memset, 1
	mkUClibcMemset2 uClibcMemset, 0
