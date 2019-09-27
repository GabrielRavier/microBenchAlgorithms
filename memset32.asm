global pdclibMemset
global klibcMemset
global dietLibcMemset
global uClibcMemset
global newlibMemset
global muslMemset
global bionicSSE2AtomMemset
global glibcMemset
global glibcI586Memset
global glibcI686Memset
global asmlibMemset
global bytewiseMemset
global minixMemset
global freeBsdMemset
global inlineStringOpGccMemset
global inlineStringOpGccI386Memset
global inlineStringOpGccI486Memset
global inlineStringOpGccI686Memset
global inlineStringOpGccNoconaMemset

section .text align=16

%define DESTINATION 4
%define FILL 8
%define LENGTH 12

	align 16
pdclibMemset:
	push esi
	push ebx
	mov ebx, [esp + 12]
	mov esi, [esp + 20]
	movzx ecx, byte [esp + 16]
	lea edx, [ebx + esi]

	test esi, esi
	je .return

	mov eax, ebx

.loop:
	inc eax
	mov [eax - 1], cl

	cmp eax, edx
	jne .loop

.return:
	mov eax, ebx
	pop ebx
	pop esi
	ret

	align 16
klibcMemset:
	push edi
	push esi
	mov edx, [esp + 8 + DESTINATION]
	movzx eax, byte [esp + 8 + FILL]
	mov esi, [esp + 8 + LENGTH]

	mov ecx, esi
	shr ecx, 2

	imul eax, 0x1010101
	and esi, 3

	mov edi, edx
	cld
	rep stosd

	mov ecx, esi
	rep stosb

	mov eax, edx
	pop esi
	pop edi
	ret





	align 16
dietLibcMemset:
	push edi
	mov edi, [esp + 4 + DESTINATION]
	mov eax, [esp + 4 + FILL]
	mov ecx, [esp + 4 + LENGTH]
	cld
	push edi
	rep stosb
	pop eax
	pop edi
	ret





	align 16
uClibcMemset:
	push edi
	push ebx
	mov edx, [esp + 8 + DESTINATION]
	mov eax, [esp + 8 + FILL]
	mov ecx, [esp + 8 + LENGTH]
	mov edi, edx
	mov ebx, ecx
	shr ecx, 2
	jz .afterStosd

	movzx eax, al
	imul eax, 0x1010101
	rep stosd

.afterStosd:
	and ebx, 3
	jz .afterLoop

.loop:
	stosb
	dec ebx
	jnz .loop

.afterLoop:
	pop ebx
	mov eax, edx
	pop edi
	ret





	align 16
newlibMemset:
	push ebp
	mov ebp, esp
	push edi
	mov edi, [ebp + 4 + DESTINATION]
	movzx eax, byte [ebp + 4 + FILL]
	mov ecx, [ebp + 4 + LENGTH]
	cld

	cmp ecx, 16
	jbe .finish

	test edi, 7
	je .aligned

	mov [edi], al
	inc edi
	dec ecx
	test edi, 7
	je .aligned

	mov [edi], al
	inc edi
	dec ecx
	test edi, 7
	je .aligned

	mov [edi], al
	inc edi
	dec ecx
	test edi, 7
	je .aligned

	mov [edi], al
	inc edi
	dec ecx
	test edi, 7
	je .aligned

	mov [edi], al
	inc edi
	dec ecx
	test edi, 7
	je .aligned

	mov [edi], al
	inc edi
	dec ecx
	test edi, 7
	je .aligned

	mov [edi], al
	inc edi
	dec ecx

.aligned:
	mov ah, al
	mov edx, eax
	sal edx, 16
	or eax, edx

	mov edx, ecx
	shr ecx, 2
	and edx, 3
	rep stosd
	mov ecx, edx

.finish:
	rep stosb
	mov eax, [ebp + 8]
	lea esp, [ebp - 4]
	pop edi
	leave
	ret





	align 16
muslMemset:
	mov ecx, [esp + LENGTH]
	cmp ecx, 62
	ja .doStosd

	mov dl, [esp + FILL]
	mov eax, [esp + DESTINATION]
	test ecx, ecx
	jz .return

	mov dh, dl

	mov [eax], dl
	mov [eax + ecx - 1], dl
	cmp ecx, 2
	jbe .return

	mov [eax + 1], dx
	mov [eax + ecx - 3], dx
	cmp ecx, 6
	jbe .return

	shl edx, 16
	mov dl, [esp + 8]
	mov dh, [esp + 8]

	mov [eax + 3], edx
	mov [eax + ecx - 7], edx
	cmp ecx, 14
	jbe .return

	mov [eax + 7], edx
	mov [eax + 11], edx
	mov [eax + ecx - 15], edx
	mov [eax + ecx - 11], edx
	cmp ecx, 30
	jbe .return

	mov [eax + 15], edx
	mov [eax + 19], edx
	mov [eax + 23], edx
	mov [eax + 27], edx
	mov [eax + ecx - 31], edx
	mov [eax + ecx - 27], edx
	mov [eax + ecx - 23], edx
	mov [eax + ecx - 19], edx

.return:
	ret

.doStosd:
	movzx eax, byte [esp + FILL]
	mov [esp + LENGTH], edi
	imul eax, 0x1010101
	mov edi, [esp + DESTINATION]
	test edi, 0xF
	mov [edi + ecx - 4], eax
	jnz .notF

.finish:
	shr ecx, 2
	rep stosd
	mov eax, [esp + DESTINATION]
	mov edi, [esp + LENGTH]
	ret

.notF:
	xor edx, edx
	sub edx, edi
	and edx, 0xF
	mov [edi], eax
	mov [edi + 4], eax
	mov [edi + 8], eax
	mov [edi + 12], eax
	sub ecx, edx
	add edi, edx
	jmp .finish





%macro bionicSSE2AtomMemsetReturn 0

	mov eax, [esp + 4 + DESTINATION]
	pop ebx
	ret

%endm

%macro bionicSSE2AtomMemsetJmpToJmpTblEntry 1

	call getEipToEbx
	add ebx, %1 - $
	add ebx, [ebx + ecx * 4]
	add edx, ecx
	jmp ebx

%endm

	align 16
getEipToEbx:
	mov ebx, [esp]
	ret

	align 16
bionicSSE2AtomMemset:
	push ebx
	mov ecx, [esp + 4 + LENGTH]

.lengthLoaded:
	movzx eax, byte [esp + 4 + FILL]
	mov ah, al
	mov edx, eax
	shl eax, 16
	or eax, edx
	mov edx, [esp + 4 + DESTINATION]
	cmp ecx, 32
	jae .thirtyTwoBytesOrMore

.writeLess32Bytes:
	bionicSSE2AtomMemsetJmpToJmpTblEntry .tableLess32Bytes

	align 16
.tableLess32Bytes:
	dd .write0Bytes - .tableLess32Bytes
	dd .write1Bytes - .tableLess32Bytes
	dd .write2Bytes - .tableLess32Bytes
	dd .write3Bytes - .tableLess32Bytes
	dd .write4Bytes - .tableLess32Bytes
	dd .write5Bytes - .tableLess32Bytes
	dd .write6Bytes - .tableLess32Bytes
	dd .write7Bytes - .tableLess32Bytes
	dd .write8Bytes - .tableLess32Bytes
	dd .write9Bytes - .tableLess32Bytes
	dd .write10Bytes - .tableLess32Bytes
	dd .write11Bytes - .tableLess32Bytes
	dd .write12Bytes - .tableLess32Bytes
	dd .write13Bytes - .tableLess32Bytes
	dd .write14Bytes - .tableLess32Bytes
	dd .write15Bytes - .tableLess32Bytes
	dd .write16Bytes - .tableLess32Bytes
	dd .write17Bytes - .tableLess32Bytes
	dd .write18Bytes - .tableLess32Bytes
	dd .write19Bytes - .tableLess32Bytes
	dd .write20Bytes - .tableLess32Bytes
	dd .write21Bytes - .tableLess32Bytes
	dd .write22Bytes - .tableLess32Bytes
	dd .write23Bytes - .tableLess32Bytes
	dd .write24Bytes - .tableLess32Bytes
	dd .write25Bytes - .tableLess32Bytes
	dd .write26Bytes - .tableLess32Bytes
	dd .write27Bytes - .tableLess32Bytes
	dd .write28Bytes - .tableLess32Bytes
	dd .write29Bytes - .tableLess32Bytes
	dd .write30Bytes - .tableLess32Bytes
	dd .write31Bytes - .tableLess32Bytes

	align 16
.write28Bytes:
	mov [edx - 28], eax

.write24Bytes:
	mov [edx - 24], eax

.write20Bytes:
	mov [edx - 20], eax

.write16Bytes:
	mov [edx - 16], eax

.write12Bytes:
	mov [edx - 12], eax

.write8Bytes:
	mov [edx - 8], eax

.write4Bytes:
	mov [edx - 4], eax

.write0Bytes:
	bionicSSE2AtomMemsetReturn

	align 16
.write29Bytes:
	mov [edx - 29], eax

.write25Bytes:
	mov [edx - 25], eax

.write21Bytes:
	mov [edx - 21], eax

.write17Bytes:
	mov [edx - 17], eax

.write13Bytes:
	mov [edx - 13], eax

.write9Bytes:
	mov [edx - 9], eax

.write5Bytes:
	mov [edx - 5], eax

.write1Bytes:
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn

	align 16
.write30Bytes:
	mov [edx - 30], eax

.write26Bytes:
	mov [edx - 26], eax

.write22Bytes:
	mov [edx - 22], eax

.write18Bytes:
	mov [edx - 18], eax

.write14Bytes:
	mov [edx - 14], eax

.write10Bytes:
	mov [edx - 10], eax

.write6Bytes:
	mov [edx - 6], eax

.write2Bytes:
	mov [edx - 2], ax
	bionicSSE2AtomMemsetReturn

	align 16
.write31Bytes:
	mov [edx - 31], eax

.write27Bytes:
	mov [edx - 27], eax

.write23Bytes:
	mov [edx - 23], eax

.write19Bytes:
	mov [edx - 19], eax

.write15Bytes:
	mov [edx - 15], eax

.write11Bytes:
	mov [edx - 11], eax

.write7Bytes:
	mov [edx - 7], eax

.write3Bytes:
	mov [edx - 3], ax
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn

	align 16
.thirtyTwoBytesOrMore:
	movd xmm0, eax
	pshufd xmm0, xmm0, 0
	test edx, 0xF
	jz .aligned16

.notAligned16:
	movdqu [edx], xmm0
	mov eax, edx
	and edx, -0x10
	add edx, 0x10
	sub eax, edx
	add ecx, eax
	movd eax, xmm0

	align 16
.aligned16:
	cmp ecx, 128
	jae .oneHundredTwentyEightBytesOrMore

.aligned16Less128Bytes:
	bionicSSE2AtomMemsetJmpToJmpTblEntry .tableSixteen128Bytes

	align 16
.oneHundredTwentyEightBytesOrMore:
	cmp ecx, (1024 * 1024)
	jae .oneHundredTwentyEightBytesOrMoreNtStart

	cmp ecx, (1024 * 24)
	jae .oneHundredTwentyEightBytesL2Normal

	sub ecx, 128

.oneHundredTwentyEightBytesOrMoreNormal:
	sub ecx, 128
	movdqa [edx], xmm0
	movdqa [edx + 0x10], xmm0
	movdqa [edx + 0x20], xmm0
	movdqa [edx + 0x30], xmm0
	movdqa [edx + 0x40], xmm0
	movdqa [edx + 0x50], xmm0
	movdqa [edx + 0x60], xmm0
	movdqa [edx + 0x70], xmm0
	lea edx, [edx + 128]
	jb .oneHundredTwentyEightBytesLessNormal

	sub ecx, 128
	movdqa [edx], xmm0
	movdqa [edx + 0x10], xmm0
	movdqa [edx + 0x20], xmm0
	movdqa [edx + 0x30], xmm0
	movdqa [edx + 0x40], xmm0
	movdqa [edx + 0x50], xmm0
	movdqa [edx + 0x60], xmm0
	movdqa [edx + 0x70], xmm0
	lea edx, [edx + 128]
	jae .oneHundredTwentyEightBytesOrMoreNormal

.oneHundredTwentyEightBytesLessNormal:
	add ecx, 128
	bionicSSE2AtomMemsetJmpToJmpTblEntry .tableSixteen128Bytes

	align 16
.oneHundredTwentyEightBytesL2Normal:
	prefetcht0 [edx + 0x380]
	prefetcht0 [edx + 0x3C0]
	sub ecx, 128
	movaps [edx], xmm0
	movaps [edx + 0x20], xmm0
	movaps [edx + 0x30], xmm0
	movaps [edx + 0x40], xmm0
	movaps [edx + 0x50], xmm0
	movaps [edx + 0x60], xmm0
	movaps [edx + 0x70], xmm0
	add edx, 128
	cmp ecx, 128
	jae .oneHundredTwentyEightBytesL2Normal

.oneHundredTwentyEightBytesLessL2Normal:
	bionicSSE2AtomMemsetJmpToJmpTblEntry .tableSixteen128Bytes

	align 16
.oneHundredTwentyEightBytesOrMoreNtStart:
	; Optimize this
	sub ecx, (1024 * 1024)
	add ecx, ((1024 * 1024) & 0x7F)
	mov eax, ((1024 * 1024) & 0x7F)
	mov ebx, (1024 * 1024)
	movd eax, xmm0

	align 16
.oneHundredTwentyEightBytesOrMoreSharedCacheLoop:
	prefetcht0 [edx + 0x3C0]
	prefetcht0 [edx + 0x380]
	sub ebx, 0x80
	movdqa [edx], xmm0
	movdqa [edx + 0x10], xmm0
	movdqa [edx + 0x20], xmm0
	movdqa [edx + 0x30], xmm0
	movdqa [edx + 0x40], xmm0
	movdqa [edx + 0x50], xmm0
	movdqa [edx + 0x60], xmm0
	movdqa [edx + 0x70], xmm0
	add edx, 0x80
	cmp ebx, 0x80
	jae .oneHundredTwentyEightBytesOrMoreSharedCacheLoop

	cmp ecx, 0x80
	jb .sharedCacheLoopEnd

	align 16
.oneHundredTwentyEightBytesOrMoreNt:
	sub ecx, 0x80
	movntdq [edx], xmm0
	movntdq [edx + 0x10], xmm0
	movntdq [edx + 0x20], xmm0
	movntdq [edx + 0x30], xmm0
	movntdq [edx + 0x40], xmm0
	movntdq [edx + 0x50], xmm0
	movntdq [edx + 0x60], xmm0
	movntdq [edx + 0x70], xmm0
	add edx, 0x80
	cmp ecx, 0x80
	jae .oneHundredTwentyEightBytesOrMoreNt

	sfence

.sharedCacheLoopEnd:
	bionicSSE2AtomMemsetJmpToJmpTblEntry .tableSixteen128Bytes

	align 16
.tableSixteen128Bytes:
	dd .alignedSixteenBytes0 - .tableSixteen128Bytes
	dd .alignedSixteenBytes1 - .tableSixteen128Bytes
	dd .alignedSixteenBytes2 - .tableSixteen128Bytes
	dd .alignedSixteenBytes3 - .tableSixteen128Bytes
	dd .alignedSixteenBytes4 - .tableSixteen128Bytes
	dd .alignedSixteenBytes5 - .tableSixteen128Bytes
	dd .alignedSixteenBytes6 - .tableSixteen128Bytes
	dd .alignedSixteenBytes7 - .tableSixteen128Bytes
	dd .alignedSixteenBytes8 - .tableSixteen128Bytes
	dd .alignedSixteenBytes9 - .tableSixteen128Bytes
	dd .alignedSixteenBytes10 - .tableSixteen128Bytes
	dd .alignedSixteenBytes11 - .tableSixteen128Bytes
	dd .alignedSixteenBytes12 - .tableSixteen128Bytes
	dd .alignedSixteenBytes13 - .tableSixteen128Bytes
	dd .alignedSixteenBytes14 - .tableSixteen128Bytes
	dd .alignedSixteenBytes15 - .tableSixteen128Bytes
	dd .alignedSixteenBytes16 - .tableSixteen128Bytes
	dd .alignedSixteenBytes17 - .tableSixteen128Bytes
	dd .alignedSixteenBytes18 - .tableSixteen128Bytes
	dd .alignedSixteenBytes19 - .tableSixteen128Bytes
	dd .alignedSixteenBytes20 - .tableSixteen128Bytes
	dd .alignedSixteenBytes21 - .tableSixteen128Bytes
	dd .alignedSixteenBytes22 - .tableSixteen128Bytes
	dd .alignedSixteenBytes23 - .tableSixteen128Bytes
	dd .alignedSixteenBytes24 - .tableSixteen128Bytes
	dd .alignedSixteenBytes25 - .tableSixteen128Bytes
	dd .alignedSixteenBytes26 - .tableSixteen128Bytes
	dd .alignedSixteenBytes27 - .tableSixteen128Bytes
	dd .alignedSixteenBytes28 - .tableSixteen128Bytes
	dd .alignedSixteenBytes29 - .tableSixteen128Bytes
	dd .alignedSixteenBytes30 - .tableSixteen128Bytes
	dd .alignedSixteenBytes31 - .tableSixteen128Bytes
	dd .alignedSixteenBytes32 - .tableSixteen128Bytes
	dd .alignedSixteenBytes33 - .tableSixteen128Bytes
	dd .alignedSixteenBytes34 - .tableSixteen128Bytes
	dd .alignedSixteenBytes35 - .tableSixteen128Bytes
	dd .alignedSixteenBytes36 - .tableSixteen128Bytes
	dd .alignedSixteenBytes37 - .tableSixteen128Bytes
	dd .alignedSixteenBytes38 - .tableSixteen128Bytes
	dd .alignedSixteenBytes39 - .tableSixteen128Bytes
	dd .alignedSixteenBytes40 - .tableSixteen128Bytes
	dd .alignedSixteenBytes41 - .tableSixteen128Bytes
	dd .alignedSixteenBytes42 - .tableSixteen128Bytes
	dd .alignedSixteenBytes43 - .tableSixteen128Bytes
	dd .alignedSixteenBytes44 - .tableSixteen128Bytes
	dd .alignedSixteenBytes45 - .tableSixteen128Bytes
	dd .alignedSixteenBytes46 - .tableSixteen128Bytes
	dd .alignedSixteenBytes47 - .tableSixteen128Bytes
	dd .alignedSixteenBytes48 - .tableSixteen128Bytes
	dd .alignedSixteenBytes49 - .tableSixteen128Bytes
	dd .alignedSixteenBytes50 - .tableSixteen128Bytes
	dd .alignedSixteenBytes51 - .tableSixteen128Bytes
	dd .alignedSixteenBytes52 - .tableSixteen128Bytes
	dd .alignedSixteenBytes53 - .tableSixteen128Bytes
	dd .alignedSixteenBytes54 - .tableSixteen128Bytes
	dd .alignedSixteenBytes55 - .tableSixteen128Bytes
	dd .alignedSixteenBytes56 - .tableSixteen128Bytes
	dd .alignedSixteenBytes57 - .tableSixteen128Bytes
	dd .alignedSixteenBytes58 - .tableSixteen128Bytes
	dd .alignedSixteenBytes59 - .tableSixteen128Bytes
	dd .alignedSixteenBytes60 - .tableSixteen128Bytes
	dd .alignedSixteenBytes61 - .tableSixteen128Bytes
	dd .alignedSixteenBytes62 - .tableSixteen128Bytes
	dd .alignedSixteenBytes63 - .tableSixteen128Bytes
	dd .alignedSixteenBytes64 - .tableSixteen128Bytes
	dd .alignedSixteenBytes65 - .tableSixteen128Bytes
	dd .alignedSixteenBytes66 - .tableSixteen128Bytes
	dd .alignedSixteenBytes67 - .tableSixteen128Bytes
	dd .alignedSixteenBytes68 - .tableSixteen128Bytes
	dd .alignedSixteenBytes69 - .tableSixteen128Bytes
	dd .alignedSixteenBytes70 - .tableSixteen128Bytes
	dd .alignedSixteenBytes71 - .tableSixteen128Bytes
	dd .alignedSixteenBytes72 - .tableSixteen128Bytes
	dd .alignedSixteenBytes73 - .tableSixteen128Bytes
	dd .alignedSixteenBytes74 - .tableSixteen128Bytes
	dd .alignedSixteenBytes75 - .tableSixteen128Bytes
	dd .alignedSixteenBytes76 - .tableSixteen128Bytes
	dd .alignedSixteenBytes77 - .tableSixteen128Bytes
	dd .alignedSixteenBytes78 - .tableSixteen128Bytes
	dd .alignedSixteenBytes79 - .tableSixteen128Bytes
	dd .alignedSixteenBytes80 - .tableSixteen128Bytes
	dd .alignedSixteenBytes81 - .tableSixteen128Bytes
	dd .alignedSixteenBytes82 - .tableSixteen128Bytes
	dd .alignedSixteenBytes83 - .tableSixteen128Bytes
	dd .alignedSixteenBytes84 - .tableSixteen128Bytes
	dd .alignedSixteenBytes85 - .tableSixteen128Bytes
	dd .alignedSixteenBytes86 - .tableSixteen128Bytes
	dd .alignedSixteenBytes87 - .tableSixteen128Bytes
	dd .alignedSixteenBytes88 - .tableSixteen128Bytes
	dd .alignedSixteenBytes89 - .tableSixteen128Bytes
	dd .alignedSixteenBytes90 - .tableSixteen128Bytes
	dd .alignedSixteenBytes91 - .tableSixteen128Bytes
	dd .alignedSixteenBytes92 - .tableSixteen128Bytes
	dd .alignedSixteenBytes93 - .tableSixteen128Bytes
	dd .alignedSixteenBytes94 - .tableSixteen128Bytes
	dd .alignedSixteenBytes95 - .tableSixteen128Bytes
	dd .alignedSixteenBytes96 - .tableSixteen128Bytes
	dd .alignedSixteenBytes97 - .tableSixteen128Bytes
	dd .alignedSixteenBytes98 - .tableSixteen128Bytes
	dd .alignedSixteenBytes99 - .tableSixteen128Bytes
	dd .alignedSixteenBytes100 - .tableSixteen128Bytes
	dd .alignedSixteenBytes101 - .tableSixteen128Bytes
	dd .alignedSixteenBytes102 - .tableSixteen128Bytes
	dd .alignedSixteenBytes103 - .tableSixteen128Bytes
	dd .alignedSixteenBytes104 - .tableSixteen128Bytes
	dd .alignedSixteenBytes105 - .tableSixteen128Bytes
	dd .alignedSixteenBytes106 - .tableSixteen128Bytes
	dd .alignedSixteenBytes107 - .tableSixteen128Bytes
	dd .alignedSixteenBytes108 - .tableSixteen128Bytes
	dd .alignedSixteenBytes109 - .tableSixteen128Bytes
	dd .alignedSixteenBytes110 - .tableSixteen128Bytes
	dd .alignedSixteenBytes111 - .tableSixteen128Bytes
	dd .alignedSixteenBytes112 - .tableSixteen128Bytes
	dd .alignedSixteenBytes113 - .tableSixteen128Bytes
	dd .alignedSixteenBytes114 - .tableSixteen128Bytes
	dd .alignedSixteenBytes115 - .tableSixteen128Bytes
	dd .alignedSixteenBytes116 - .tableSixteen128Bytes
	dd .alignedSixteenBytes117 - .tableSixteen128Bytes
	dd .alignedSixteenBytes118 - .tableSixteen128Bytes
	dd .alignedSixteenBytes119 - .tableSixteen128Bytes
	dd .alignedSixteenBytes120 - .tableSixteen128Bytes
	dd .alignedSixteenBytes121 - .tableSixteen128Bytes
	dd .alignedSixteenBytes122 - .tableSixteen128Bytes
	dd .alignedSixteenBytes123 - .tableSixteen128Bytes
	dd .alignedSixteenBytes124 - .tableSixteen128Bytes
	dd .alignedSixteenBytes125 - .tableSixteen128Bytes
	dd .alignedSixteenBytes126 - .tableSixteen128Bytes
	dd .alignedSixteenBytes127 - .tableSixteen128Bytes

.alignedSixteenBytes112:
	movdqa [edx - 112], xmm0

.alignedSixteenBytes96:
	movdqa [edx - 96], xmm0

.alignedSixteenBytes80:
	movdqa [edx - 96], xmm0

.alignedSixteenBytes64:
	movdqa [edx - 96], xmm0

.alignedSixteenBytes48:
	movdqa [edx - 96], xmm0

.alignedSixteenBytes32:
	movdqa [edx - 96], xmm0

.alignedSixteenBytes16:
	movdqa [edx - 96], xmm0

.alignedSixteenBytes0:
	bionicSSE2AtomMemsetReturn

%macro mkEightupleAligned16 8

	align 16
.alignedSixteenBytes%1:
	movdqa [edx - %1], xmm0

.alignedSixteenBytes%2:
	movdqa [edx - %2], xmm0

.alignedSixteenBytes%3:
	movdqa [edx - %3], xmm0

.alignedSixteenBytes%4:
	movdqa [edx - %4], xmm0

.alignedSixteenBytes%5:
	movdqa [edx - %5], xmm0

.alignedSixteenBytes%6:
	movdqa [edx - %6], xmm0

.alignedSixteenBytes%7:
	movdqa [edx - %7], xmm0

.alignedSixteenBytes%8:

%endm

	mkEightupleAligned16 113, 97, 81, 65, 49, 33, 17, 1
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 114, 98, 82, 66, 50, 34, 18, 2
	mov [edx - 2], ax
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 115, 99, 83, 67, 51, 35, 19, 3
	mov [edx - 3], ax
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 116, 100, 84, 68, 52, 36, 20, 4
	mov [edx - 4], eax
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 117, 101, 85, 69, 53, 37, 21, 5
	mov [edx - 5], eax
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 118, 102, 86, 70, 54, 38, 22, 6
	mov [edx - 6], eax
	mov [edx - 2], ax
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 119, 103, 87, 71, 55, 39, 23, 7
	mov [edx - 7], eax
	mov [edx - 3], ax
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 120, 104, 88, 72, 56, 40, 24, 8
	movq [edx - 8], xmm0
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 121, 105, 89, 73, 57, 41, 25, 9
	movq [edx - 9], xmm0
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 122, 106, 90, 74, 58, 42, 26, 10
	movq [edx - 10], xmm0
	mov [edx - 2], ax
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 123, 107, 91, 75, 59, 43, 27, 11
	movq [edx - 11], xmm0
	mov [edx - 3], ax
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 124, 108, 92, 76, 60, 44, 28, 12
	movq [edx - 12], xmm0
	mov [edx - 4], eax
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 125, 109, 93, 77, 61, 45, 29, 13
	movq [edx - 13], xmm0
	mov [edx - 5], eax
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 126, 110, 94, 78, 62, 46, 30, 14
	movq [edx - 14], xmm0
	mov [edx - 6], eax
	mov [edx - 2], ax
	bionicSSE2AtomMemsetReturn

	mkEightupleAligned16 127, 111, 95, 79, 63, 47, 31, 15
	movq [edx - 15], xmm0
	mov [edx - 7], eax
	mov [edx - 3], ax
	mov [edx - 1], al
	bionicSSE2AtomMemsetReturn





	align 16
glibcMemset:
	push edi
	mov ecx, [esp + 4 + LENGTH]
	mov edi, [esp + 4 + DESTINATION]
	movzx eax, byte [esp + 4 + FILL]
	mov edx, edi
	rep stosb
	mov eax, edx
	pop edi
	ret





	align 16
glibcI586Memset:
	push edi
	mov edi, [esp + 4 + DESTINATION]
	mov edx, [esp + 4 + LENGTH]
	mov al, [esp + 4 + FILL]
	mov ah, al
	mov ecx, eax
	shl eax, 16
	mov ax, cx
	cld

	cmp edx, 36
	mov ecx, edx
	jl .return

	mov ecx, edi
	neg ecx
	and ecx, 3
	sub edx, ecx
	rep stosb

	sub edx, 32
	mov ecx, [edi]

	align 16
.loop:
	mov ecx, [edi + 28]
	sub edx, 32
	mov [edi], eax
	mov [edi + 4], eax
	mov [edi + 8], eax
	mov [edi + 12], eax
	mov [edi + 16], eax
	mov [edi + 20], eax
	mov [edi + 24], eax
	mov [edi + 28], eax
	lea edi, [edi + 32]
	jge .loop

	lea ecx, [edx + 32]

.return:
	shr ecx, 2
	rep stosd

	mov ecx, edx
	and ecx, 3
	rep stosb

	mov eax, [esp + 4 + DESTINATION]
	pop edi
	ret





	align 16
glibcI686Memset:
	cld
	push edi
	mov edx, [esp + 4 + DESTINATION]
	mov ecx, [esp + 4 + LENGTH]
	movzx eax, byte [esp + 4 + FILL]
	jecxz .return

	mov edi, edx
	and edx, 3
	jz .aligned
	jp .misaligned3

	stosb
	dec ecx
	jz .return

.misaligned3:
	stosb
	dec ecx
	jz .return

	xor edx, 1
	jnz .aligned

	stosb
	dec ecx

.aligned:
	mov edx, ecx
	shr ecx, 2
	and edx, 3
	imul eax, 0x1010101
	rep stosd
	mov ecx, edx
	rep stosb

.return:
	mov eax, [esp + 4 + DESTINATION]
	pop edi
	ret





	align 16
asmlibMemset:
	mov edx, [esp + DESTINATION]
	xor eax, eax
	mov al, [esp + FILL]
	mov ecx, [esp + LENGTH]

	imul eax, 0x1010101
	push edi
	mov edi, edx
	cmp ecx, 4
	jb .less4

.checkAligned:
	test edi, 3
	jz .aligned

.unalignedLoop:
	mov [edi], al
	inc edi
	dec ecx
	test edi, 3
	jnz .unalignedLoop

.aligned:
	mov edx, ecx
	shr ecx, 2
	cld
	rep stosd

	mov ecx, edx
	and ecx, 3

.less4:
	rep stosb
	pop edi
	mov eax, [esp + DESTINATION]
	ret





	align 16
bytewiseMemset:
	push ebx
	mov edx, [esp + 4 + LENGTH]
	mov ebx, [esp + 4 + DESTINATION]
	movzx ecx, byte [esp + 4 + FILL]

	test edx, edx
	je .return

	add edx, ebx
	mov eax, ebx

.loop:
	inc eax
	mov [eax - 1], cl
	cmp eax, edx
	jne .loop

.return:
	mov eax, ebx
	pop ebx
	ret





	align 16
minixMemset:
	push ebp
	mov ebp, esp
	push edi
	mov edi, [ebp + 4 + DESTINATION]
	movzx eax, byte [ebp + 4 + FILL]
	mov ecx, [ebp + 4 + LENGTH]
	cld
	cmp ecx, 16
	jb .sByte

	test edi, 1
	jne .sByte

	test edi, 2
	jne .sWord

.slWord:
	mov ah, al
	mov edx, eax
	sal edx, 16
	or edx, eax
	shrd edx, ecx, 2
	shr ecx, 2

	rep stosd
	shld ecx, edx, 2

.sWord:
	mov ah, al
	shr ecx, 1

	rep stosw
	adc ecx, ecx

.sByte:
	rep stosb

.done:
	mov eax, [ebp + 4 + DESTINATION]
	pop edi
	pop ebp
	ret





	align 16
freeBsdMemset:
	push edi
	push ebx
	mov edi, [esp + 8 + DESTINATION]
	movzx eax, byte [esp + 8 + FILL]	; Unsigned char, zero extend
	mov ecx, [esp + 8 + LENGTH]
	push edi	; Push address of buffer

	cld	; Set fill direction forwards

	; If the string is too short, it's really not worth the overhead of aligning to word boundries, etc.  So we jump to a plain unaligned set.
	cmp ecx, 0xF
	jle .finish

	mov ah, al	; Copy char to all bytes in word
	mov edx, eax
	sal eax, 16
	or eax, edx

	mov edx, edi	; Compute misalignment
	neg edx
	and edx, 3
	mov ebx, ecx
	sub ebx, edx

	mov ecx, edx	; Set until word aligned
	rep stosb

	mov ecx, ebx
	shr ecx, 2	; Set by words
	rep stosd

	mov ecx, ebx	; Set remainder by bytes
	and ecx, 3

.finish:
	rep stosb

	pop eax	; Pop address of buffer
	pop ebx
	pop edi
	ret





	align 16
inlineStringOpGccMemset:
	push edi
	movzx eax, byte [esp + 4 + FILL]
	mov ecx, [esp + 4 + LENGTH]
	imul eax, 0x1010101
	mov edx, [esp + 4 + DESTINATION]
	cmp ecx, 4
	jnb .aligned

	test ecx, ecx
	jne .align

.return:
	mov eax, edx
	pop edi
	ret

	align 16
.aligned:
	mov [ecx + edx - 4], eax
	dec ecx
	shr ecx, 2
	mov edi, edx
	rep stosd

	mov eax, edx
	pop edi
	ret

	align 16
.align:
	mov [edx], al
	test cl, 2
	je .return

	mov [ecx + edx - 3], ax
	jmp .return





	align 16
inlineStringOpGccI386Memset:
	push edi
	mov ecx, [esp + 4 + LENGTH]
	mov edi, [esp + 4 + DESTINATION]
	mov al, [esp + 4 + FILL]
	rep stosb

	mov eax, [esp + 4 + DESTINATION]
	pop edi
	ret





	align 16
inlineStringOpGccI486Memset:
	push edi
	push ebx
	mov edx, [esp + 8 + DESTINATION]
	mov ecx, [esp + 8 + LENGTH]
	xor eax, eax
	mov al, [esp + 8 + FILL]
	mov ah, al
	mov edi, eax
	sal edi, 16
	or eax, edi

	cmp ecx, 4
	jnb .aligned

	test ecx, ecx
	jne .align

.return:
	mov eax, edx
	pop ebx
	pop edi
	ret

	align 16
.aligned:
	mov [edx], eax
	mov [edx + ecx - 4], eax
	lea edi, [edx + 4]
	and edi, -4
	mov ebx, edx
	sub ebx, edi
	add ecx, ebx
	shr ecx, 2
	rep stosd

	mov eax, edx
	pop ebx
	pop edi
	ret

	align 16
.align:
	mov [edx], al
	test cl, 2
	je .return

	mov [edx + ecx - 2], al
	jmp .return





	align 16
inlineStringOpGccI686Memset:
	push edi
	push ebx
	mov edx, [esp + 8 + LENGTH]
	mov ebx, [esp + 8 + DESTINATION]
	cmp edx, 8
	mov edi, ebx
	jnb .large

.afterAligned:
	and edx, 7
	je .return

	xor eax, eax

.byteLoop:
	movzx ecx, byte [esp + 8 + FILL]
	mov [edi + eax], cl
	inc eax
	cmp eax, edx
	jb .byteLoop

.return:
	mov eax, ebx
	pop ebx
	pop edi
	ret

	align 16
.large:
	movzx eax, byte [esp + 8 + FILL]
	imul eax, 0x1010101
	test bl, 1
	jne .do1Byte

.check2Bytes:
	test edi, 2
	jne .do2Bytes

.check4Bytes:
	test edi, 4
	jne .do4Bytes

.aligned:
	mov ecx, edx
	and edx, 3
	shr ecx, 2
	rep stosd
	jmp .afterAligned

	align 16
.do1Byte:
	mov [ebx], al
	lea edi, [ebx + 1]
	dec edx
	jmp .check2Bytes

	align 16
.do2Bytes:
	mov [edi], ax
	sub edx, 2
	add edi, 2
	jmp .check4Bytes

	align 16
.do4Bytes:
	mov [edi], eax
	sub edx, 4
	add edi, 4
	jmp .aligned





	align 16
inlineStringOpGccNoconaMemset:
	push edi
	push ebx
	mov ebx, [esp + 8 + DESTINATION]
	mov edx, [esp + 8 + LENGTH]
	mov edi, ebx
	cmp edx, 4
	jnb .large

.afterAligned:
	and edx, 3
	je .return

	xor eax, eax

.byteLoop:
	movzx ecx, byte [esp + 8 + FILL]
	mov [edi + eax], cl
	inc eax
	cmp eax, edx
	jb .byteLoop

.return:
	mov eax, ebx
	pop ebx
	pop edi
	ret

	align 16
.large:
	movzx eax, byte [esp + 8 + FILL]
	mov ah, al
	mov ecx, eax
	sal ecx, 16
	or eax, ecx
	test bl, 1
	jne .doStosb

.checkStosw:
	test edi, 2
	jne .doStosw

.aligned:
	mov ecx, edx
	shr ecx, 2
	rep stosd
	jmp .afterAligned

	align 16
.doStosb:
	stosb
	dec edx
	jmp .checkStosw

	align 16
.doStosw:
	stosw
	sub edx, 2
	jmp .aligned