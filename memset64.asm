global pdclibMemset
global cloudLibcMemset
global klibcMemset
global dietLibcMemset
global uClibcMemset
global newlibMemset
global muslMemset
global bionicSSE2SlmMemset
global freeBsdMemset
global freeBsdErmsMemset
global inlineStringOpGccMemset
global inlineStringOpGccSkylakeMemset

section .text align=16

	align 16
pdclibMemset:
	mov rax, rdi
	lea r8, [rdi + rdx]
	mov rcx, rdi
	test rdx, rdx
	je .return

.loop:
	inc rcx
	mov [rcx - 1], sil
	cmp rcx, r8
	jne .loop

.return:
	ret





	align 16
cloudLibcMemset:
	mov rax, rdi
	mov rcx, rdi
	cmp rdx, 0x1F
	jbe .small

	test al, 7
	je .aligned

	mov edi, esi
	mov r8, rax

.alignLoop:
	inc r8
	mov rcx, rdx
	sub rcx, r8
	lea r9, [rax + rcx]
	mov [r8 - 1], dil

	test r8b, 7
	jne .alignLoop

.afterAlignLoop:
	movzx edx, sil
	mov rcx, rdx
	sal rcx, 8
	or rcx, rdx

	mov rdx, rcx
	sal rdx, 16
	or rcx, rdx

	mov rdx, rcx
	sal rdx, 32
	or rdx, rcx

	lea rcx, [r9 - 8]
	shr rcx, 3
	lea rcx, [rcx * 8 + r8 + 8]

.wordLoop:
	add r8, 8
	mov [r8 - 8], rdx

	cmp rcx, r8
	jne .wordLoop

	mov rdx, r9
	and edx, 7

.small:
	lea r8, [rcx + rdx]
	test rdx, rdx
	je .return

.endLoop:
	inc rcx
	mov [rcx - 1], sil
	cmp rcx, r8
	jne .endLoop

.return:
	ret

.aligned:
	mov r8, rdi
	mov r9, rdx
	jmp .afterAlignLoop





	align 16
klibcMemset:
	mov rcx, rdx
	movzx eax, sil
	mov rsi, 0x101010101010101
	mov r8, rdi
	shr rcx, 3
	imul rax, rsi
	and edx, 7
	cld
	rep stosq

	mov ecx, edx
	rep stosb

	mov rax, r8
	ret





	align 16
dietLibcMemset:
	movzx eax, sil
	mov rsi, 0x101010101010101
	imul rax, rsi
	mov rsi, rdi
	mov rcx, rdx
	shr rcx, 3
	rep stosq

	mov rcx, rdx
	and rcx, 7
	rep stosb

	mov rax, rsi
	ret





	align 16
uClibcMemset:
	cmp rdx, 7
	mov rcx, rdi
	jbe .less7

	mov r8, 0x101010101010101
	movzx eax, sil
	imul r8, rax

	test edi, 7
	jz .checkLarge

	align 16
.align8:
	mov [rcx], sil
	dec rdx
	inc rcx
	test cl, 7
	jnz .align8

.checkLarge:
	mov rax, rdx
	shr rax, 6
	je .fillFinalBytes

	cmp rdx, 120000
	jae .largeLoop

	align 16
.fill64:
	mov [rcx], r8
	mov [rcx + 8], r8
	mov [rcx + 16], r8
	mov [rcx + 24], r8
	mov [rcx + 32], r8
	mov [rcx + 40], r8
	mov [rcx + 48], r8
	mov [rcx + 56], r8
	add rcx, 64
	dec rax
	jne .fill64

.fillFinalBytes:
	and edx, 0x3F
	mov rax, rdx
	shr rax, 3
	je .after8ByteChunks

.byte8Chunks:
	mov [rcx], r8
	add rcx, 8
	dec rax
	jne .byte8Chunks

.after8ByteChunks:
	and edx, 7

.less7:
	test rdx, rdx
	je .return

.byteLoop:
	mov [rcx], sil
	inc rcx
	dec rdx
	jne .byteLoop

.return:
	mov rax, rdi
	ret

	align 16
.largeLoop:
	movnti [rcx], r8
	movnti [rcx + 8], r8
	movnti [rcx + 16], r8
	movnti [rcx + 24], r8
	movnti [rcx + 32], r8
	movnti [rcx + 40], r8
	movnti [rcx + 48], r8
	movnti [rcx + 56], r8
	add rcx, 64
	dec rax
	jne .largeLoop
	jmp .fillFinalBytes





	align 16
newlibMemset:
	mov r9, rdi
	mov rax, rsi
	mov rcx, rdx
	cmp rdx, 16
	jb .byteSet

	mov r8, rdi
	and r8, 7
	jz .quadwordAligned

	mov rcx, 8
	sub rcx, r8
	sub rdx, rcx
	rep stosb
	mov rcx, rdx

.quadwordAligned:
	mov r8, 0x101010101010101
	movzx eax, sil
	imul rax, r8
	cmp rdx, 256
	jb .quadwordSet

	shr rcx, 7

	align 16
.loop:
	movnti [rdi], rax
	movnti [rdi + 8], rax
	movnti [rdi + 16], rax
	movnti [rdi + 24], rax
	movnti [rdi + 32], rax
	movnti [rdi + 40], rax
	movnti [rdi + 48], rax
	movnti [rdi + 56], rax
	movnti [rdi + 64], rax
	movnti [rdi + 72], rax
	movnti [rdi + 80], rax
	movnti [rdi + 88], rax
	movnti [rdi + 96], rax
	movnti [rdi + 104], rax
	movnti [rdi + 112], rax
	movnti [rdi + 120], rax

	lea rdi, [rdi + 128]
	dec rcx
	jnz .loop

	sfence
	mov rcx, rdx
	and rcx, 127
	rep stosb
	mov rax, r9
	ret

	align 16
.byteSet:
	rep stosb
	mov rax, r9
	ret

	align 16
.quadwordSet:
	shr rcx, 3
	rep stosq
	mov rcx, rdx
	and rcx, 7
	rep stosb
	mov rax, r9
	ret





	align 16
muslMemset:
	movzx rax, sil
	mov r8, 0x101010101010101
	imul rax, r8

	cmp rdx, 126
	ja .doStosq

	test edx, edx
	jz .return

	mov [rdi], sil
	mov [rdi + rdx - 1], sil
	cmp edx, 2
	jbe .return

	mov [rdi + 1], ax
	mov [rdi + rdx - 3], ax
	cmp edx, 6
	jbe .return

	mov [rdi + 3], eax
	mov [rdi + rdx - 7], eax
	cmp edx, 14
	jbe .return

	mov [rdi + 7], rax
	mov [rdi + rdx - 15], rax
	cmp edx, 30
	jbe .return

	mov [rdi + 15], rax
	mov [rdi + 23], rax
	mov [rdi + rdx - 31], rax
	mov [rdi + rdx - 23], rax
	cmp edx, 62
	jbe .return

	mov [rdi + 31], rax
	mov [rdi + 39], rax
	mov [rdi + 47], rax
	mov [rdi + 55], rax
	mov [rdi + rdx - 63], rax
	mov [rdi + rdx - 55], rax
	mov [rdi + rdx - 47], rax
	mov [rdi + rdx - 39], rax

.return:
	mov rax, rdi
	ret

	align 16
.doStosq:
	test edi, 15
	mov r8, rdi
	mov [rdi + rdx - 8], rax
	mov rcx, rdx
	jnz .makeAlign

.finishStosq:
	shr rcx, 3
	rep stosq

	mov rax, r8
	ret

	align 16
.makeAlign:
	xor edx, edx
	sub edx, edi
	and edx, 15
	mov [rdi], rax
	mov [rdi + 8], rax
	sub rcx, rdx
	add rdi, rdx
	jmp .finishStosq





	align 16
bionicSSE2SlmMemset:
	mov rax, rdi
	and rsi, 0xFF
	mov rcx, 0x101010101010101
	imul rcx, rsi
	cmp rdx, 16
	jae .sixteenBytesOrMore

	test dl, 8
	jnz .eightTo15Bytes

	test dl, 4
	jnz .fourTo7Bytes

	test dl, 2
	jnz .twoTo3Bytes

	test dl, 1
	jz .return

	mov [rdi], cl

.return:
	ret

	align 16
.eightTo15Bytes:
	mov [rdi], rcx
	mov [rdi + rdx - 8], rcx
	ret

	align 16
.fourTo7Bytes:
	mov [rdi], ecx
	mov [rdi + rdx - 4], ecx
	ret

	align 16
.twoTo3Bytes:
	mov [rdi], cx
	mov [rdi + rdx - 2], cx
	ret

	align 16
.sixteenBytesOrMore:
	movq xmm0, rcx
	pshufd xmm0, xmm0, 0
	movdqu [rdi], xmm0
	movdqu [rdi + rdx - 16], xmm0
	cmp rdx, 32
	jbe .thirtyTwoBytesLess

	movdqu [rdi + 16], xmm0
	movdqu [rdi + rdx - 32], xmm0
	cmp rdx, 64
	jbe .sixtyFourBytesLess

	movdqu [rdi + 32], xmm0
	movdqu [rdi + 48], xmm0
	movdqu [rdi + rdx - 64], xmm0
	movdqu [rdi + rdx - 48], xmm0
	cmp rdx, 128
	ja .oneHundrendTwentyEightBytesMore

.thirtyTwoBytesLess:
.sixtyFourBytesLess:
	ret

	align 16
.oneHundrendTwentyEightBytesMore:
	lea rcx, [rdi + 64]
	and rcx, -64
	mov r8, rdx
	add rdx, rdi
	and rdx, -64
	cmp rdx, rcx
	je .return

	cmp r8, (1024 * 1024)
	ja .oneHundrendTwentyEightBytesMoreNt

	align 16
.oneHundrendTwentyEightBytesMoreNormal:
	movdqa [rcx], xmm0
	movdqa [rcx + 0x10], xmm0
	movdqa [rcx + 0x20], xmm0
	movdqa [rcx + 0x30], xmm0
	add rcx, 64
	cmp rdx, rcx
	jne .oneHundrendTwentyEightBytesMoreNormal

	ret

	align 16
.oneHundrendTwentyEightBytesMoreNt:
	movntdq [rcx], xmm0
	movntdq [rcx + 0x10], xmm0
	movntdq [rcx + 0x20], xmm0
	movntdq [rcx + 0x30], xmm0
	lea rcx, [rcx + 64]
	cmp rdx, rcx
	jne .oneHundrendTwentyEightBytesMoreNt

	sfence
	ret





%macro mkFreeBsdMemset 1
	; 1 : Whether we have ERMS (Enhanced MOVSB) or not
	mov rax, rdi
	mov rcx, rdx
	movzx r8, sil
	mov r10, 0x101010101010101
	imul r10, r8

	cmp rcx, 32
	jbe .lessEq32

	cmp rcx, 256
	ja .above256

.thirtyTwoByteLoop:
	mov [rdi], r10
	mov [rdi + 8], r10
	mov [rdi + 16], r10
	mov [rdi + 24], r10
	lea rdi, [rdi + 32]
	sub rcx, 32
	cmp rcx, 32
	ja .thirtyTwoByteLoop

	cmp cl, 16
	ja .above16

	; Less than 16 remain
	mov [rdi + rcx - 16], r10
	mov [rdi + rcx - 8], r10
	ret

	align 16
.lessEq32:
	cmp cl, 16
	jl .less16

.above16:
	; Between 16 and 32
	mov [rdi], r10
	mov [rdi + 8], r10
	mov [rdi + rcx - 16], r10
	mov [rdi + rcx - 8], r10
	ret

	align 16
.less16:
	cmp cl, 8
	jl .less8

	mov [rdi], r10
	mov [rdi + rcx - 8], r10
	ret

	align 16
.less8:
	cmp cl, 4
	jl .less4

	mov [rdi], r10d
	mov [rdi + rcx - 4], r10d
	ret

	align 16
.less4:
	cmp cl, 2
	jl .less2

	mov [rdi], r10w
	mov [rdi + rcx - 2], r10w
	ret

	align 16
.less2:
	cmp cl, 0
	je .return

	mov [rdi], r10b

.return:
	ret

	align 16
.above256:
	mov r9, rdi
	mov rax, r10
	test edi, 15
	jnz .unaligned

.doRep:
%if %1 == 1
	; ERMS
	rep stosb
	mov rax, r9
%else
	mov rdx, rcx
	shr rcx, 3
	rep stosq
	mov rax, r9
	and edx, 7
	jnz .last8Bytes

	ret

.last8Bytes:
	mov [rdi + rdx - 8], r10
%endif

	ret

	align 16
.unaligned:
	mov [rdi], r10
	mov [rdi + 8], r10
	mov r8, rdi
	and r8, 15
	lea rcx, [rcx + r8 - 16]
	neg r8
	lea rdi, [rdi + r8 + 16]
	jmp .doRep
%endmacro

	align 16
freeBsdMemset:
	mkFreeBsdMemset 0





	align 16
freeBsdErmsMemset:
	mkFreeBsdMemset 1





	align 16
inlineStringOpGccMemset:
	movzx eax, sil
	mov r8, rdi
	mov rsi, 0x101010101010101
	imul rax, rsi
	cmp rdx, 8
	jnb .aligned

	test dl, 4
	jne .small

	test rdx, rdx
	je .return

	mov [rdi], al
	test dl, 2
	je .return

	mov [rdi + rdx - 2], ax
	jmp .return

	align 16
.aligned:
	mov [rdi], rax
	lea rdi, [rdi + 8]
	mov rcx, r8
	mov [rdi + rdx - 16], ax
	and rdi, -8
	sub rcx, rdi
	add rcx, rdx
	shr rcx, 3
	rep stosq

.return:
	mov rax, r8
	ret

	align 16
.small:
	mov [rdi], eax
	mov [rdi + rdx - 4], eax
	jmp .return





	align 16
inlineStringOpGccSkylakeMemset:
	movzx esi, sil
	mov rcx, 0x101010101010101
	imul rsi, rcx

	mov rax, rdi
	cmp rdx, 0x20
	jnb .toLoop

	test dl, 0x10
	jne .seventeenTo32

	test dl, 8
	jne .nineTo16

	test dl, 4
	jne .fiveTo8

	test rdx, rdx
	jne .oneTo4

.return:
	ret

	align 16
.toLoop:
	mov [rdi], rsi
	mov [rdi + rdx - 32], rsi
	mov [rdi + rdx - 24], rsi
	mov [rdi + rdx - 16], rsi
	mov [rdi + rdx - 8], rsi
	lea rdi, [rdi + 8]
	and rdi, -8

	mov rcx, rax
	sub rcx, rdi
	add rdx, rcx
	and rdx, -0x20
	cmp rdx, 0x20
	jb .return

	and rdx, -0x20
	xor ecx, ecx

.bigLoop:
	mov [rdi + rcx], rsi
	mov [rdi + rcx + 8], rsi
	mov [rdi + rcx + 0x10], rsi
	mov [rdi + rcx + 0x18], rsi
	add rcx, 0x20
	cmp rcx, rdx
	jb .bigLoop

	ret

	align 16
.oneTo4:
	mov [rdi], sil
	test dl, 2
	je .return

	mov [rdi + rdx - 2], si
	ret

	align 16
.seventeenTo32:
	mov [rdi], rsi
	mov [rdi + 8], rsi
	mov [rdi + rdx - 0x10], rsi
	mov [rdi + rdx - 8], rsi
	ret

	align 16
.nineTo16:
	mov [rdi], rsi
	mov [rdi + rdx - 8], rsi
	ret

	align 16
.fiveTo8:
	mov [rdi], esi
	mov [rdi + rdx - 4], esi
	ret
