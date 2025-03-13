CYCLE		equ	0xC00
TIME		equ	0xC01
INSTRET		equ	0xC02

		org	0

		li	x1, 0x555
		li	x2, -2
		beq	x1, x0, broken		; BEQ not taken
		bne	x0, x1, okay_1		; BNE taken
		beq	x0, x0, broken
okay_1		bne	x1, x1, broken		; BNE not taken
		beq	x1, x1, okay_2		; BEQ taken
		beq	x0, x0, broken
okay_2		blt	x1, x0, broken		; BLT not taken
		bge	x1, x0, okay_3		; BGE taken
		beq	x0, x0, broken
okay_3		bge	x0, x1, broken		; BGE not taken
		blt	x0, x1, okay_4		; BLT taken
		beq	x0, x0, broken
okay_4		blt	x1, x2, broken		; BLT not taken
		blt	x2, x1, okay_5		; BLT taken
		beq	x0, x0, broken
okay_5		bge	x2, x1, broken		; BGE not taken
		bge	x1, x2, okay_6		; BGE taken
		beq	x0, x0, broken
okay_6		blt	x2, x2, broken		; BLT not taken
		bge	x2, x2, okay_7		; BGE taken
		beq	x0, x0, broken
okay_7		bltu	x2, x1, broken		; BLTU not taken
		bltu	x1, x2, okay_8		; BLTU taken
		beq	x0, x0, broken
okay_8		bgeu	x1, x2, broken		; BGEU not taken
		bgeu	x2, x1, okay_9		; BGEU taken
		beq	x0, x0, broken
okay_9		bltu	x1, x1, broken		; BLTU not taken
		bgeu	x1, x1, okay_10		; BGEU taken
		beq	x0, x0, broken

okay_10		jal	call_1
		j	over

call_2		nop				; Two nested routines
		jalr	x0, [x5]
		beq	x0, x0, broken

call_1		jal	x5, call_2
		ret
		beq	x0, x0, broken


over		call	call_1

		addi	x1, x0, 1		; Test simple additions
		add	x1, x1, x1		; x1 := 2
		li	x3, 2			; x3 := 2
		bne	x1, x3, broken2
		add	x3, x3, x2		; x3 := 0
		bne	x0, x3, broken2
		sub	x3, x0, x2		; x3 := 2
		bne	x3, x1, broken2
		addi	x3, x3, 2		; x3 := 4
		slli	x1, x1, 1		; x1 := 4
		bne	x3, x1, broken2
		li	x4, 3
		sll	x3, x3, x4		; x3 := 32
		addi	x1, x1, 28		; x1 := 32
		bne	x3, x1, broken2
		slti	x4, x3, 32		; x4 := false
		bgtz	x4, broken2
		slti	x4, x3, 33		; x4 := true
		beqz	x4, broken2
		slt	x4, x3, x1		; x4 := false
		bnez	x4, broken2
		slt	x4, x1, x3		; x4 := false
		bnez	x4, broken2
		slt	x4, x1, x2		; x4 := false
		bnez	x4, broken2
		slt	x4, x2, x1		; x4 := true
		beqz	x4, broken2
		sltu	x4, x2, x1		; x4 := false
		bnez	x4, broken2
		li	x1, -1			; x1 := -1
		sltu	x4, x1, x2		; x4 := false
		bnez	x4, broken2
		sltu	x4, x2, x1		; x4 := true
		beqz	x4, broken2
		xor	x4, x1, x2		; x4 := 1
		addi	x5, x4, -1
		bnez	x5, broken2
; and						; Waiting to be done
; or
; srl
; sll

		la	x6, string_1
		li	x7, 16

loop_1		lbu	x8, [x6]		; Need expanding properly
		lb	x8, [x6]
		addi	x6, x6, 1
		addi	x7, x7, -1
		bgtz	x7, loop_1

		la	x6, string_1
		li	x7, 8

loop_2		lhu	x8, [x6]
		lh	x8, [x6]
		addi	x6, x6, 2
		addi	x7, x7, -1
		bgtz	x7, loop_2

		la	x6, string_1
		li	x7, 4

loop_3		lwu	x8, [x6]
		lw	x8, [x6]
		addi	x6, x6, 4
		subi	x7, x7, 1		; Added this mnemonic
		bgtz	x7, loop_3

		li	x7, 0x33221100
		lw	x8, -16[x6]
		bne	x8, x7, broken3

		la	x6, word_1
		li	x8, 0x12345678
		sw	x8, [x6]
		lb	x7, 2[x6]
		srli	x9, x8, 16
		andi	x9, x9, 0xFF
		bne	x7, x9, broken3
		beq	x7, x9, end
		; Removed MUL/DIV/CSR

end
        li      x10, 100000000  ; 2-second delay at 50 MHz

delay_loop
        addi    x10, x10, -1
        bnez    x10, delay_loop

		addi	x6, x6, 4
		subi	x6, x6, -4
		addi	x7, x7, -1
		subi	x7, x7, +1

stop        ebreak ; Move away so branch prediction doesn't reset LEDs 
        j       stop

string_1	defb	0x00, 0x11, 0x22, 0x33
		defb	0x44, 0x55, 0x66, 0x77
		defb	0x88, 0x99, 0xAA, 0xBB
		defb	0xCC, 0xDD, 0xEE, 0xFF

		align

word_1		defw	0


broken		beq	x0, x0, broken
broken2		j	 broken2
broken3		j	 broken3

		addi	x2, x0, -2

		slt	x3, x1, x2
		slt	x3, x2, x1
		sltu	x3, x1, x2
		sltu	x3, x2, x1

		lw	x4, 0[x0]
		lh	x4, 0[x0]
		lh	x4, 2[x0]
		lb	x4, 0[x0]
		lb	x4, 1[x0]
		lb	x4, 2[x0]
		lb	x4, 3[x0]

		sb	x2, 1[x0]

;label_0
;label_1		bne	x1, x0, label_1
;label_2		blt	x1, x0, label_0
