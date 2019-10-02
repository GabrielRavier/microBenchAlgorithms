ENTRY(neatlibcMemset)
	mov r12, r0

.LNloop:
	subs r2, #1
	bmi .LNreturn

	strb r1, [r0], #1
	b .LNloop

.LNreturn:
	mov r0, r12
	bx lr
END (neatlibcMemset)
