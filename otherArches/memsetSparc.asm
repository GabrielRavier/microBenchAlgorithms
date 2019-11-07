	; o0 = destination
	; o1 = length
	; o2 = length

ENTRY dietlibcMemset
	subcc %o2, 1, %o2
	bge,a dietlibcMemset

	stb %o1, [%o0 + %o2]
	retl
	nop
END dietlibcMemset
