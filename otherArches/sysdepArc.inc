.ifndef SYSDEP_ARC_INC
.set SYSDEP_ARC_INC, 1

.macro uClibcENTRY name

	.text
	.align 4
	.globl \name
	.type \name, @function
\name:

.endm

.macro uClibcEND name

	.size \name, . - \name

.endm

.endif
