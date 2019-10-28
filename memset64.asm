global pdclibMemset
global cloudlibcMemset
global libFtMemset
global klibcMemset
global neatlibcMemset
global dietlibcMemset
global uClibcMemset
global newlibMemset
global muslMemset
global bionicSSE2SlmMemset
global asmlibSSE2Memset
global freeBsdMemset
global freeBsdErmsMemset
global inlineStringOpGccMemset
global inlineStringOpGccSkylakeMemset

section .text align=16

%define rDestination rdi
%define rDestination32 edi
%define rLength rdx
%define rLength32 edx
%define rLength8 dl
%define rFill rsi
%define rFill32 esi
%define rFill16 si
%define rFill8 sil

	align 16
pdclibMemset:
	mov rax, rDestination
	lea r8, [rDestination + rLength]
	mov rcx, rDestination
	test rLength, rLength
	je .return

.loop:
	inc rcx
	mov [rcx - 1], rFill8
	cmp rcx, r8
	jne .loop

.return:
	ret





	align 16
cloudlibcMemset:
	mov rax, rDestination
	mov rcx, rDestination
	cmp rLength, 0x1F
	jbe .small

	test al, 7
	je .aligned

	mov edi, rFill32
	mov r8, rax

.alignLoop:
	inc r8
	mov rcx, rLength
	sub rcx, r8
	lea r9, [rax + rcx]
	mov [r8 - 1], dil

	test r8b, 7
	jne .alignLoop

.afterAlignLoop:
	movzx edx, rFill8
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
	mov [rcx - 1], rFill8
	cmp rcx, r8
	jne .endLoop

.return:
	ret

.aligned:
	mov r8, rDestination
	mov r9, rLength
	jmp .afterAlignLoop





	align 16
libFtMemset:
	cmp rLength, 0
	je .end

	mov r8, rDestination	; Saving dest to be restored later
	mov rax, rFill
	mov rcx, rLength	; Setting len iterations
	cld	; ++rdi at each iteration
	rep stosb	; *rdi = c

.end:
	mov rax, r8
	ret





	align 16
klibcMemset:
	mov rcx, rLength
	movzx eax, rFill8
	mov rsi, 0x101010101010101
	mov r8, rDestination
	shr rcx, 3
	imul rax, rsi
	and rLength32, 7
	cld
	rep stosq

	mov ecx, rLength32
	rep stosb

	mov rax, r8
	ret





	align 16
neatlibcMemset:
	mov rcx, rLength
	mov rax, rFill
	mov rdx, rDestination
	cld
	rep stosb
	mov rax, rdx
	ret





	align 16
dietlibcMemset:
	movzx eax, rFill8
	mov rsi, 0x101010101010101
	imul rax, rsi
	mov rsi, rDestination
	mov rcx, rLength
	shr rcx, 3
	rep stosq

	mov rcx, rLength
	and rcx, 7
	rep stosb

	mov rax, rsi
	ret





	align 16
uClibcMemset:
	cmp rLength, 7  ; Check for small lengths
	mov rcx, rDestination    ; Save ptr as return value
	jbe .less7

	; Populate 8 bit data to full 64 bit
	mov r8, 0x101010101010101
	movzx eax, rFill8
	imul r8, rax

    test edi, 7	; Check for alignment
	jz .checkLarge

	align 16
.align8:
	; Align pointer to 8 bytes
	mov [rcx], rFill8
	dec rLength
	inc rcx
	test cl, 7
	jnz .align8

.checkLarge:
	; Check for really large regions
	mov rax, rLength
	shr rax, 6
	je .fillFinalBytes

	cmp rLength, 120000
	jae .largeLoop

	align 16
.fill64:
	; Fill 64 bytes
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
	; Fill final bytes
	and edx, 0x3F
	mov rax, rLength
	shr rax, 3
	je .after8ByteChunks

.byte8Chunks:
	; First in chunks of 8 bytes
	mov [rcx], r8
	add rcx, 8
	dec rax
	jne .byte8Chunks

.after8ByteChunks:
	and rLength32, 7

.less7:
	test rLength, rLength
	je .return

.byteLoop:
	; And finally as bytes (up to 7)
	mov [rcx], rFill8
	inc rcx
	dec rLength
	jne .byteLoop

.return:
	; Load result
	mov rax, rDestination	; Start address of destination is result
	ret

	align 16
.largeLoop:
	; Fill 64 bytes without polluting the cache
	; We could use movntq [rcx], xmm0 here to further speed up for large cases but let's not use XMM registers
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
	mov r9, rDestination	; Save return value
	mov rax, rFill
	mov rcx, rLength
	cmp rLength, 16
	jb .byteSet

	mov r8, rDestination	; Align on qword boundary
	and r8, 7
	jz .quadwordAligned

	mov rcx, 8
	sub rcx, r8
	sub rLength, rcx
	rep stosb
	mov rcx, rLength

.quadwordAligned:
	mov r8, 0x101010101010101
	movzx eax, rFill8
	imul rax, r8
	cmp rLength, 256
	jb .quadwordSet

	shr rcx, 7	; Store 128 bytes at a time with minimum cache pollution

	align 16
.loop:
	movnti [rDestination], rax
	movnti [rDestination + 8], rax
	movnti [rDestination + 16], rax
	movnti [rDestination + 24], rax
	movnti [rDestination + 32], rax
	movnti [rDestination + 40], rax
	movnti [rDestination + 48], rax
	movnti [rDestination + 56], rax
	movnti [rDestination + 64], rax
	movnti [rDestination + 72], rax
	movnti [rDestination + 80], rax
	movnti [rDestination + 88], rax
	movnti [rDestination + 96], rax
	movnti [rDestination + 104], rax
	movnti [rDestination + 112], rax
	movnti [rDestination + 120], rax

	lea rDestination, [rDestination + 128]
	dec rcx
	jnz .loop

	sfence
	mov rcx, rLength
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

	mov rcx, rLength
	and rcx, 7
	rep stosb	; Store the remaining bytes

	mov rax, r9
	ret





	align 16
muslMemset:
	movzx rax, rFill8
	mov r8, 0x101010101010101
	imul rax, r8

	cmp rLength, 126
	ja .doStosq

	test rLength32, rLength32
	jz .return

	mov [rDestination], sil
	mov [rDestination + rLength - 1], sil
	cmp edx, 2
	jbe .return

	mov [rDestination + 1], ax
	mov [rDestination + rLength - 3], ax
	cmp edx, 6
	jbe .return

	mov [rDestination + 3], eax
	mov [rDestination + rLength - 7], eax
	cmp edx, 14
	jbe .return

	mov [rDestination + 7], rax
	mov [rDestination + rLength - 15], rax
	cmp edx, 30
	jbe .return

	mov [rDestination + 15], rax
	mov [rDestination + 23], rax
	mov [rDestination + rLength - 31], rax
	mov [rDestination + rLength - 23], rax
	cmp edx, 62
	jbe .return

	mov [rDestination + 31], rax
	mov [rDestination + 39], rax
	mov [rDestination + 47], rax
	mov [rDestination + 55], rax
	mov [rDestination + rLength - 63], rax
	mov [rDestination + rLength - 55], rax
	mov [rDestination + rLength - 47], rax
	mov [rDestination + rLength - 39], rax

.return:
	mov rax, rDestination
	ret

	align 16
.doStosq:
	test rDestination32, 15
	mov r8, rDestination
	mov [rDestination + rLength - 8], rax
	mov rcx, rLength
	jnz .makeAlign

.finishStosq:
	shr rcx, 3
	rep stosq

	mov rax, r8
	ret

	align 16
.makeAlign:
	xor edx, edx
	sub edx, rDestination32
	and edx, 15
	mov [rDestination], rax
	mov [rDestination + 8], rax
	sub rcx, rdx
	add rDestination, rdx
	jmp .finishStosq





	align 16
bionicSSE2SlmMemset:
	mov rax, rDestination
	and rFill, 0xFF
	mov rcx, 0x101010101010101
	imul rcx, rsi
	cmp rLength, 16
	jae .sixteenBytesOrMore

	test rLength8, 8
	jnz .eightTo15Bytes

	test rLength8, 4
	jnz .fourTo7Bytes

	test rLength8, 2
	jnz .twoTo3Bytes

	test rLength8, 1
	jz .return

	mov [rDestination], cl

.return:
	ret

	align 16
.eightTo15Bytes:
	mov [rDestination], rcx
	mov [rDestination + rLength - 8], rcx
	ret

	align 16
.fourTo7Bytes:
	mov [rDestination], ecx
	mov [rDestination + rLength - 4], ecx
	ret

	align 16
.twoTo3Bytes:
	mov [rDestination], cx
	mov [rDestination + rLength - 2], cx
	ret

	align 16
.sixteenBytesOrMore:
	movq xmm0, rcx
	pshufd xmm0, xmm0, 0
	movdqu [rDestination], xmm0
	movdqu [rDestination + rLength - 16], xmm0
	cmp rdx, 32
	jbe .thirtyTwoBytesLess

	movdqu [rDestination + 16], xmm0
	movdqu [rDestination + rLength - 32], xmm0
	cmp rdx, 64
	jbe .sixtyFourBytesLess

	movdqu [rDestination + 32], xmm0
	movdqu [rDestination + 48], xmm0
	movdqu [rDestination + rLength - 64], xmm0
	movdqu [rDestination + rLength - 48], xmm0
	cmp rdx, 128
	ja .oneHundrendTwentyEightBytesMore

.thirtyTwoBytesLess:
.sixtyFourBytesLess:
	ret

	align 16
.oneHundrendTwentyEightBytesMore:
	lea rcx, [rDestination + 64]
	and rcx, -64
	mov r8, rLength
	add rdx, rDestination
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





%macro mkAsmlibLoadParamsAndBroadcastFillExtraParam 0
	movzx eax, rFill8
	mov rcx, rLength
	imul eax, 0x1010101	; Broadcast fill into all bytes of eax
%endmacro

%macro mkAsmlibSSE2StartSSE 0
	; count > 16. Use SSE2
	movd xmm0, eax
	pshufd xmm0, xmm0, 0	; Broadcast c into all bytes of xmm0

	; Store the first unaligned part
	; The size of this part is 1 - 16 bytes
	; It is faster to write 16 bytes, possibly overlapping with the subsequent regular part, than to make possibly mispredicted branches depending on the size of the first part
	movq [rDestination], xmm0
	movq [rDestination + 8], xmm0

	; Check if count very big
	cmp rLength, 1024 * 1024 * 4
	ja .above4Megs	; Use non-temporal store if count > 1M (typical size of cache)
%endmacro

%macro mkAsmlibSSE2ThreeStores 4
.small%1:
	mov [edx + %2], eax

.small%2:
	mov [edx + %3], eax

.small%3:
	mov [edx + %4], eax

.small%4:
%endmacro

%macro mkAsmLibSSE2RegularLoop 3
	; End of regular part
	; Round down dest + count to nearest preceding 16-byte boundary
	lea rLength, [rDestination + rLength - 1]
	and rLength, -0x10

	; Start of regular part
	; Round up dest to next 16-byte boundary
	add rDestination, 0x10
	and rDestination, -0x10

	; -(size of regular part)
	sub rDestination, rLength
	jnl .lastIrregular%2	; Jump if not negative

.regularPartLoop%2:
	; Loop through regular part
	; rLength = end of regular part
	; rDestination = negative index from the end, counting up to zero
	%1 [rLength + rDestination], xmm0
	add edx, 0x10
	jnz .regularPartLoop%2

%if %3 == 1
	sfence
%endif

.lastIrregular%2:
	; Do the last irregular part
	; The size of that part is 1 - 16 bytes
	; It is faster to always write 16 bytes, possibly overlapping with the preceding regular part, than to make possibly mispredicted branches depending on the size of the last part
	mov rax, rDest2
	movq [rax + rCount2 - 0x10], xmm0
	movq [rax + rCount2 - 8], xmm0
	ret
%endmacro

	align 16
asmlibSSE2Memset:
	mkAsmlibLoadParamsAndBroadcastFill
	mov rDest2, rDestination	; Save destination

	cmp rLength, 16
	ja .above16

.less16:
	jmp [.jumpTable + ecx * 4]


	align 16
	mkAsmlibSSE2ThreeStores 16, 12, 8, 4

	mov [edx], eax

.small0:
	mkReturnDestinationFromStackNoPop

	align 16
	mkAsmlibSSE2ThreeStores 15, 11, 7, 3
	mov [edx + 1], eax
	mov [edx], al
	mkReturnDestinationFromStackNoPop

	align 16
	mkAsmlibSSE2ThreeStores 14, 10, 6, 2
	mov [edx], ax
	mkReturnDestinationFromStackNoPop

	align 16
	mkAsmlibSSE2ThreeStores 13, 9, 5, 1
	mov [edx], al
	mkReturnDestinationFromStackNoPop

	align 16
.jumpTable:
	dd .small0, .small1, .small2, .small3, .small4, .small5, .small6, .small7, .small8, .small9, .small10, .small11, .small12, .small13, .small14, .small15, .small16

	align 16
.above16:
	mkAsmlibSSE2StartSSE
	mkAsmLibSSE2RegularLoop movdqa, Normal, 0

	align 16
.above4Megs:
	; Use non-temporal stores, same code as above
	mkAsmLibSSE2RegularLoop movdqu, NonTemporal, 0





	align 16
asmlibSSE2v2Memset:
	mkAsmlibLoadParamsAndBroadcastFill

	cmp ecx, 16
	jna asmlibSSE2Memset.less16

	mkAsmlibSSE2StartSSE
	mkAsmLibSSE2RegularLoop movdqa, Normal, 0

.above4Megs:
	; Use non-temporal stores, same code as above
	mkAsmLibSSE2RegularLoop movntdq, NonTemporal, 1





%macro mkAsmlibAVXPrologAVX 1
	; Find last 32 bytes boundary
	mov ecx, eax
	and ecx, -0x20

	; -size of 32-bytes blocks
	sub edx, ecx
	jnb .finish%1	; Jump if not negative

	; Extend value to 256 bits
	vinsertf128	ymm0, xmm0, 1
%endmacro

%macro mkAsmlibAVXFinishAVX 1

.finish%1:
	; The last part from ecx to eax is < 32 bytes. Write 32 bytes with overlap
	movups [eax - 0x20], xmm0
	movups [eax - 0x10], xmm0
	mkReturnDestinationFromStackNoPop

%endmacro

	align 16
asmlibAVXMemset:
	mkAsmlibLoadParamsAndBroadcastFill

.entryAVX512F:
	cmp ecx, 16
	jna asmlibSSE2Memset.less16

	; Length > 16
	movd xmm0, eax
	pshufd xmm0, xmm0, 0	; Broadcast c into all bytes of xmm0
	lea eax, [edx + ecx]	; Point to end

	cmp ecx, 0x20
	jbe .less32

	; Store the first unaligned 16 bytes
	; It is faster to always write 16 bytes, possibly overlapping with the subsequent regular part, than to make possibly mispredicted branches depending on the size of the first part
	movups [edx], xmm0

	; Store another 16 bytes, aligned
	add edx, 0x10
	and edx, -0x10
	movaps [edx], xmm0

	; Go to next 32 bytes boundary
	add edx, 0x10
	and edx, -0x20

	; Check if count very big
	cmp ecx, 1024 * 1024 * 4
	ja .above4Megs	; Use non-temporal stores if count > 4M

	mkAsmlibAVXPrologAVX Normal

.loop32:
	; Loop through 32-byte blocks
	; ecx = end of 32-byte blocks
	; edx = negative index from the end, counting up to zero
	vmovaps [ecx + edx], ymm0
	add edx, 0x20
	jnz .loop32

	vzeroupper
	mkAsmlibAVXFinishAVX Normal

	align 16
.above4Megs:
	; Use non-temporal moves, same code as above
	mkAsmlibAVXPrologAVX NonTemporal

	align 16
.loop32NonTemporal:
	; Loop through 32-byte blocks
	; ecx = end of 32-byte blocks
	; edx = negative index from the end, counting up to zero
	vmovntps [ecx + edx], ymm0
	add edx, 0x20
	jnz .loop32NonTemporal

	sfence
	vzeroupper
	mkAsmlibAVXFinishAVX NonTemporal

.less32:
	; 16 < count <= 32
	movups [edx], xmm0
	movups [eax - 0x10], xmm0
	mkReturnDestinationFromStackNoPop





%macro mkAsmlibAVX512SaveAndBroadcastIntoZmm 0

	push edi
	mov edi, edx	; Save dest
	vpbroadcastd zmm0, eax	; Broadcast further into 64 bytes

%endmacro

	align 16
asmlibAVX512FMemset:
	mkAsmlibLoadParamsAndBroadcastFill
	cmp ecx, 0x80
	jbe asmlibAVXMemset.entryAVX512F	; Use AVX code if count <= 0x80

	mkAsmlibAVX512SaveAndBroadcastIntoZmm
	jmp asmlibAVX512BWMemset.entryAVX512F	; Use AVX512BW code





	align 16
asmlibAVX512BWMemset:
	mkAsmlibLoadParamsAndBroadcastFill
	mkAsmlibAVX512SaveAndBroadcastIntoZmm

	cmp ecx, 0x40
	jbe .less40

	cmp ecx, 0x80
	jbe .less80	; Use simpler code if count <= 0x80

.entryAVX512F:
	; Count > 0x80
	; Store first 0x40 bytes
	vmovdqu64 [edx], zmm0

	; Find first 0x40 boundary
	add edx, 0x40
	and edx, -0x40

	; Find last 0x40 boundary
	lea eax, [edi + ecx]
	and eax, -0x40
	sub edx, eax	; Negative count from last 0x40 boundary

	; Check if count very big
	cmp ecx, 1024 * 1024 * 4
	ja .above4Megs	; Use non-temporal store if count > 4M

.avx512MainLoop:
	vmovdqa64 [eax + edx], zmm0
	add edx, 0x40
	jnz .avx512MainLoop

.finish:
	; Remaining 0-0x3F bytes
	; Overlap previous bytes
	vmovdqu64 [edi + ecx - 0x40], zmm0
	vzeroupper	; Might not be needed
	mov eax, edi	; Return destination
	pop edi
	ret

	align 16
.above4Megs:
	vmovntdq [eax + edx], zmm0
	add edx, 0x40
	jnz .above4Megs

	sfence
	jmp .finish

	align 16
.less80:
	; Short counts, AVX512BW-only
	; Count = 0x41-0x80
	vmovdqu64 [edx], zmm0
	add edx, 0x40
	sub ecx, 0x40

.less40:
	; Count = 0-0x40
	or eax, -1		; If count = 1-31 | If count = 32-63
	bzhi eax, eax, ecx	; count 1s        | all 1's
	kmovd k1, eax
	xor eax, eax
	sub ecx, 0x20
	cmovb ecx, eax	; 0               | count-32
	dec eax
	bzhi eax, eax, ecx
	kmovd k2, eax	; 0               | count-32 1s
	kunpckdq k3, k2, k1	; Low 32 bits from k1, high 32 bits from k2 : total = count 1s
	vmovdqu8 [edx]{k3}, zmm0
	vzeroupper
	mov eax, edi	; Return destination
	pop edi
	ret





%macro mkFreeBsdMemset 1
	; 1 : Whether we have ERMS (Enhanced MOVSB) or not
	mov rax, rDestination
	mov rcx, rLength
	movzx r8, rFill8
	mov r10, 0x101010101010101
	imul r10, r8

	cmp rcx, 32
	jbe .lessEq32

	cmp rcx, 256
	ja .above256

.thirtyTwoByteLoop:
	mov [rDestination], r10
	mov [rDestination + 8], r10
	mov [rDestination + 16], r10
	mov [rDestination + 24], r10
	lea rDestination, [rDestination + 32]
	sub rcx, 32
	cmp rcx, 32
	ja .thirtyTwoByteLoop

	cmp cl, 16
	ja .above16

	; Less than 16 remain
	mov [rDestination + rcx - 16], r10
	mov [rDestination + rcx - 8], r10
	ret

	align 16
.lessEq32:
	cmp cl, 16
	jl .less16

.above16:
	; Between 16 and 32
	mov [rDestination], r10
	mov [rDestination + 8], r10
	mov [rDestination + rcx - 16], r10
	mov [rDestination + rcx - 8], r10
	ret

	align 16
.less16:
	cmp cl, 8
	jl .less8

	mov [rDestination], r10
	mov [rDestination + rcx - 8], r10
	ret

	align 16
.less8:
	cmp cl, 4
	jl .less4

	mov [rDestination], r10d
	mov [rDestination + rcx - 4], r10d
	ret

	align 16
.less4:
	cmp cl, 2
	jl .less2

	mov [rDestination], r10w
	mov [rDestination + rcx - 2], r10w
	ret

	align 16
.less2:
	cmp cl, 0
	je .return

	mov [rDestination], r10b

.return:
	ret

	align 16
.above256:
	mov r9, rDestination
	mov rax, r10
	test rDestination32, 0xF
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
	mov [rDestination], r10
	mov [rDestination + 8], r10
	mov r8, rDestination
	and r8, 15
	lea rcx, [rcx + r8 - 16]
	neg r8
	lea rDestination, [rDestination + r8 + 16]
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
	movzx eax, rFill8
	mov r8, rDestination
	mov rsi, 0x101010101010101
	imul rax, rsi
	cmp rLength, 8
	jnb .aligned

	test rLength8, 4
	jne .small

	test rLength, rLength
	je .return

	mov [rDestination], al
	test rLength8, 2
	je .return

	mov [rDestination + rLength - 2], ax
	jmp .return

	align 16
.aligned:
	mov [rDestination], rax
	lea rDestination, [rDestination + 8]
	mov rcx, r8
	mov [rDestination + rdx - 16], ax
	and rdi, -8
	sub rcx, rdi
	add rcx, rLength
	shr rcx, 3
	rep stosq

.return:
	mov rax, r8
	ret

	align 16
.small:
	mov [rDestination], eax
	mov [rDestination + rLength - 4], eax
	jmp .return





	align 16
inlineStringOpGccSkylakeMemset:
	movzx rFill32, rFill8
	mov rcx, 0x101010101010101
	imul rFill, rcx

	mov rax, rDestination
	cmp rLength, 0x20
	jnb .toLoop

	test rLength8, 0x10
	jne .seventeenTo32

	test rLength8, 8
	jne .nineTo16

	test rLength8, 4
	jne .fiveTo8

	test rLength, rLength
	jne .oneTo4

.return:
	ret

	align 16
.toLoop:
	mov [rDestination], rFill
	mov [rDestination + rLength - 32], rFill
	mov [rDestination + rLength - 24], rFill
	mov [rDestination + rLength - 16], rFill
	mov [rDestination + rLength - 8], rFill
	lea rDestination, [rDestination + 8]
	and rDestination, -8

	mov rcx, rax
	sub rcx, rDestination
	add rdx, rcx
	and rdx, -0x20
	cmp rdx, 0x20
	jb .return

	and rdx, -0x20
	xor ecx, ecx

.bigLoop:
	mov [rDestination + rcx], rFill
	mov [rDestination + rcx + 8], rFill
	mov [rDestination + rcx + 0x10], rFill
	mov [rDestination + rcx + 0x18], rFill
	add rcx, 0x20
	cmp rcx, rdx
	jb .bigLoop

	ret

	align 16
.oneTo4:
	mov [rDestination], rFill8
	test rLength8, 2
	je .return

	mov [rDestination + rLength - 2], rFill16
	ret

	align 16
.seventeenTo32:
	mov [rDestination], rFill
	mov [rDestination + 8], rFill
	mov [rDestination + rLength - 0x10], rFill
	mov [rDestination + rLength - 8], rFill
	ret

	align 16
.nineTo16:
	mov [rDestination], rFill
	mov [rDestination + rLength - 8], rFill
	ret

	align 16
.fiveTo8:
	mov [rDestination], rFill32
	mov [rDestination + rLength - 4], rFill32
	ret
