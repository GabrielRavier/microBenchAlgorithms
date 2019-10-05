.macro mkUClibcMemset name, arc700, archs, ll64, dontUsePrealloc

.if !arc700 && !archs
.error "Neither arc700 nor archs is true !"
.endif

ENTRY \name

.if arc700
.set small, 7	; Must be at least 6 to deal with alignment issues

	mov_s r4, r0
	or r12, r0, r2
	bmsk.f r12, 1
	extb_s r1
	asl r3, r1, 8
	beq.d .L\name\()aligned

	or_s r1, r3
	brls r2, \small, .L\name\()tiny

	add r3, r2, r0
	stb r1, [r3, -1]
	bclr_s r3, 0
	stw r1, [r3, -2]
	bmsk.f r12, r0, 1
	add_s r2, r12
	sub.ne r2, 4
	stb.ab r1, [r4, 1]
	and r4, -2
	stw.ab r1, [r4, 2]
	and r4, -4

	; This code address should be aligned for speed
.L\name\()aligned:
	asl r3, r1, 16
	lsr.f lp_count, r2, 2
	or_s r1, r3
	lpne .L\name\()oopEnd

	st.ab r1, [r4, 4]

.L\name\()oopEnd:
	j_s [blink]

	.balign 4
.L\name\()tiny:
	mov.f lp_count, r2
	lpne .L\name\()tinyEnd

	stb.ab r1, [r4, 1]

.L\name\()tinyEnd:
	j_s [blink]

.endif

.if archs
.if dontUsePrealloc
.macro prewrite a, b
	prefetchw [\a, \b]
.endm
.else
.macro prewrite a, b
	prealloc [\a, \b]
.endm
.endif

	prefetchw [r0]	; Prefetch the write location
	mov.f 0, r2

	; If the size is 0
	jz.d [blink]
	mov r3, r0	; Don't clobber ret val

	; If length < 8
	brls.d.nt r2, 8, .L\name\()smallChunk
	mov.f lp_count, r2

	and.f r4, r0, 3
	rsub lp_count, r4, 4
	lpnz @.L\name\()alignDestination

	; Begin loop
	stb.ab r1, [r3, 1]
	sub r2, 1

.L\name\()alignDestination:
	; Destination is aligned
	and r1, 0xFF
	asl r4, 1, 8
	or r4, r1
	asl r5, r4, 0x10
	or r5, r4
	mov r4, r5

	sub3 lp_count, r2, 8
	cmp r2, 0x40
	bmsk.hi r2, 5
	mov.ls lp_count, 0
	add3.hi r2, 8

	; Convert len to dwords, unfold 8 times
	lsr.f lp_count, 6
	lpnz @.L\name\()set64Bytes

	; Loop start
	prewrite r3, 0x40	; Prefetch next write location

.if ll64
	.rept 8
		std.ab r4, [r3, 8]
	.endr
.else
	.rept 16
		st.ab r4, [r3, 4]
	.endr
.endif

.L\name\()set64Bytes:
	lsr.f lp_count, r2, 5
	lpnz .L\name\()set32Bytes

	; Loop start
	prefetchw [r3, 0x20]	; Prefetch the next write location

.if ll64
	.rept 4
		std.ab r4, [r3, 8]
	.endr
.else
	.rept 8
		st.ab r4, [r3, 4]
	.endr
.endif

.L\name\()set32Bytes:
	and.f lp_count, r2, 0x1F	; Last remaining 31 bytes

.L\name\()smallChunk:
	lpnz .L\name\()copy3Bytes

	; Loop start
	stb.ab r1, [r3, 1]

.L\name\()copy3Bytes:
	j [blink]

.endif

.purgem prewrite

END \name

.endm

	mkUClibcMemset uClibcArc700Memset, 1, 0, 0, 0
	mkUClibcMemset uClibcArchsMemset, 0, 1, 0, 0
	mkUClibcMemset uClibcArchs64Memset, 0, 1, 1, 0
	mkUClibcMemset uClibcArchsNoPreallocMemset 0, 1, 0, 1
	mkUClibcMemset uClibcArchs64NoPreallocMemset 0, 1, 1, 1
