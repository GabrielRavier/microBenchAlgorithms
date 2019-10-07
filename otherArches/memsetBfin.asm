ENTRY uClibcMemset
	p0 = r0	; P0 = address
	p2 = r2	; P2 = count
	r3 = r0 + r2	; End
	cc = r2 <= 7(iu)
	if cc jump .LUtooSmall

	r1 = r1.b(z)	; R1 = fill char
	r2 = 3
	r2 = r0 & r2	; Addr bottom two bits
	cc = r2 == 0	; Az set if 0
	if !cc jump .LUforceAlign	; Jump if addr not aligned

.LUaligned:
	p1 = p2 >> 2	; Count = n/4
	r2 = r1 << 8	; Create quad filler
	r2.l = r2.l + r1.l(ns)
	r2.h = r2.l + r1.h(ns)
	p2 = r3

	lsetup(.LUquadLoop, .LUquadLoop) lc0 = p1

.LUquadLoop:
	[p0++] = r2

	cc = p0 == p2
	if !cc jump .LUbytesLeft
	rts

.LUbytesLeft:
	r2 = r3	; End point
	r3 = p0	; Current position
	p2 = r2 - r3	; Bytes left
	p2 = r2

.LUtooSmall:
	cc = p2 == 0	; Check zero count
	if cc jump .Lfinished	; Unusual

.LUbytes:
	lsetup(.LUbyteLoop, .LUbyteLoop) lc0 = p2

.LUbyteLoop:
	b[p0++] = r1

.LUfinished:
	rts

.LUforceAlign:
	cc = bittst(r0, 0)	; Odd byte
	r0 = 4
	r0 = r0 - r2
	p1 = r0
	r0 = p0	; Recover return address
	if !cc jump .LUskip1

	b[p0++] = r1

.LUskip1:
	cc = r2 <= 2	; 2 bytes
	p2 -= p1	; Reduce count
	if !cc jump .LUaligned

	.rept 2

		b[p0++] = r1

	.endr

	jump .LUaligned

END uClibcMemset
