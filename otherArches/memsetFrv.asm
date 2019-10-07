ENTRY uClibcMemset
	orcc.p gr10, gr0, gr5, icc3	; gr5 = count
	andi gr9, #0xFF, gr9
	or.p gr8, gr0, gr4	; gr4 = address
	beqlr icc3, #0

	; Conditionally write a byte to 2-byte align the address
	setlos.p #1, gr6
	andicc gr4, #1, gr0, icc0
	ckne icc0, cc7
	cstb.p gr9, @(gr4, gr0), cc7, #1
	csubcc gr5, gr6, gr5, cc7, #1	; Also set icc3
	cadd.p gr4, gr6, gr4, cc7, #1
	beqlr icc3, #0

	; Conditionally write a word to 4-byte align the address
	andicc.p gr4, #2, gr0, icc0
	subicc gr5, #1, gr0, icc1
	setlos.p #2, gr6
	ckne icc0, cc7
	slli.p gr9, #8, gr12	; Need to double up the pattern
	cknc icc1, cc5
	or.p gr9, gr12, gr12
	andcr cc7, cc5, cc7

	csth.p gr12, @(gr4, gr0), cc7, #1
	csubcc gr5, gr6, gr5, cc7, #1	; Also set icc3
	cadd.p gr4, gr6, gr4, cc7, #1
	beqlr icc3, #0

	; Conditionally write a dword to 8-byte align the address
	andicc.p gr4, #4, gr0, icc0
	subicc gr5, #4, gr0, icc1
	setlos.p #4, gr6
	ckne icc0, cc7
	slli.p gr12, #16, gr13	; Need to quadruple up the pattern
	cknc icc1, cc5
	or.p gr13, gr12, gr12
	andcr cc7, cc5, cc7

	cst.p gr12, @(gr4, gr0), cc7, #1
	csubcc gr5, gr6, gr5, cc7, #1	; Also set icc3
	cadd.p gr4, gr6, gr4, cc7, #1
	beqlr icc3, #0

	or.p gr12, gr13	; Need to octuple up the pattern

	; The address is now 8 byte aligned
	setlos #8, gr7
	subi.p gr4, #8, gr4	; Store with update index also does weird stuff
	setlos #0x40, gr6

	subicc gr5, #0x40, gr0, icc0

.loop:
	cknc icc0, cc7

	.rept 5

		cstdu gr12, @(gr4, gr7), cc7, #1

	.endr

	cstdu.p gr12, @(gr4, gr7), cc7, #1
	csubcc gr5, gr6, gr5, cc7, #1	; Also set icc3
	cstdu.p gr12, @(gr4, gr7), cc7, #1
	subicc gr5, #0x40, gr0, icc0
	cstdu.p gr12, @(gr4, gr7), cc7, #1
	beqlr icc3, #0
	bnc icc0, #2, .loop

	; Now do 32 byte remnant
	subicc.p gr5, #0x20, gr0, icc0
	setlos #0x20, gr6
	cknc icc0, cc7
	cstdu.p gr12, @(gr4, gr7), cc7, #1
	csubcc gr5, gr6, gr5, cc7, #1	; Also set icc3
	cstdu.p gr12, @(gr4, gr7), cc7, #1
	setlos #0x10, gr6
	cstdu.p gr12, @(gr4, gr7), cc7, #1
	beqlr icc3, #0

	; Now do 16 byte remnant
	cknc icc0, cc7
	cstdu.p gr12, @(gr4, gr7), cc7, #1
	csubcc gr5, gr6, gr5, cc7, #1	; Also set icc3
	cstdu.p gr12, @(gr4, gr7), cc7, #1
	beqlr icc3, #0

	; Now do 8 byte remnant
	subicc gr5, #8, gr0, icc1
	cknc icc1, cc7
	cstdu.p gr12, @(gr4, gr7), cc7, #1
	csubcc gr5, gr6, gr5, cc7, #1	; Also set icc3
	beqlr icc3, #0

	; Now do 4 byte remnant
	subicc gr5, #4, gr0, icc1
	addi.p gr4, #4, gr4
	cknc icc0, cc7
	cstu.p gr12, @(gr4, gr7), cc7, #1
	csubcc gr5, gr7, gr5, cc7, #1	; Also set icc3
	subicc.p gr5, #2, gr0, icc1
	beqlr icc3, #0

	; Now do 2 byte remnant
	setlos #2, gr7
	addi.p gr4, #2, gr4
	cknc icc1, cc7
	csthu.p gr12, @(gr4, gr7), cc7, #1
	csubcc gr5, gr7, gr5, cc7, #1	; Also set icc3
	subicc.p gr5, #1, gr0, icc0
	beqlr icc3, #0

	; Now do 1 byte remnant
	setlos #0, gr7
	addi.p gr4, #2, gr4
	cknc icc0, cc7
	cstb.p gr12, @(gr4, gr0), cc7, #1
	bralr
END uClibcMemset
