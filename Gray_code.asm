.data
	start: .asciiz "Please input the number of Gray code bits:\n\0"
	answer: .asciiz "Gray code list:\n\0"
	newline: .asciiz "\n\0"
	headpointer: .space 24 #make 24byte to place one Gray code
.text
main:
	li $v0, 4
	la $a0, start
	syscall
	li $v0, 5
	syscall
	
	li $s0, 0x2f000000
	li $s1, 0x31000000
	li $sp, 0x10010040 #initial stack pointer
	la $t0, 0($v0) #let $t0 put input
	addi $a3, $v0, -1 #for loop boundary
	li $t1, 0 #initial counter
	li $t2, 1 #initial inner layer counter
	
	jal create #create ' 0' '1' to put in stack
	jal loop
	li $v0, 4
	la $a0, answer
	syscall
	
	li $t3, 0
	la $a1, 0x10010058 #$a1 be a stack start pointer
	sll $t2, $t2, 1
	jal show #to show answer
	li $v0, 4
	la $a0, newline
	syscall
	
	j main
show:
	beq $t3, $t2, exit
	li $v0, 4
	la $a0, ($a1)
	syscall	
	addi $a1, $a1, 24
	li $v0, 4
	la $a0, newline
	syscall
	addi $t3, $t3, 1 #++i
	j show
create:
	addi $sp, $sp, 24
	la $a2, '0'
	sw $a2, ($sp)
	addi $sp, $sp, 24
	la $a2, '1'
	sw $a2, ($sp)
	la $a1, 0($sp) 
	jr $ra
loop:
	beq $t1, $a3, exit #let $t1 be counter 
	sll $t2, $t2, 1 #inner layer counter multiply by 2

	addi $t1, $t1, 1 #++i
	li $t3, 0 #initial counter $t3
	la $a1, 0($sp) 
	j nextloop
	j loop
nextloop:
	beq $t3, $t2, loop
	addi $t3, $t3, 1 #++i
	j reflected
reflected:
	lw $t4, 0($a1)
	lw $t5, 4($a1)
	lw $t6, 8($a1)
	lw $t7, 12($a1)
	lw $t8, 16($a1)
	lw $t9, 20($a1)
	sll $t9, $t9, 8
	j multeight_8
	j nextloop
multeight_8:
	slt $a0, $t8, $s0 
	bne $a0, $0, sll_8
	slt $a0, $t8, $s1
	bne $a0, $0, plus_8
	add $t9, $t9, '1' 
	j sll_8
plus_8:
	add $t9, $t9, '0'
	j sll_8
sll_8:
	sll $t8, $t8, 8
	j multeight_7
next:
	add $a0, $t4, '0'
	add $t4, $t4, '1'
	addi $sp, $sp, 24
	sw $t4, 0($sp)
	sw $t5, 4($sp)
	sw $t6, 8($sp)
	sw $t7, 12($sp)
	sw $t8, 16($sp)
	sw $t9, 20($sp)
	sw $a0, 0($a1)
	sw $t5, 4($a1)
	sw $t6, 8($a1)
	sw $t7, 12($a1)
	sw $t8, 16($a1)
	sw $t9, 20($a1)
	addi $a1, $a1, -24
	j nextloop
exit:
	jr $ra
multeight_7:
	slt $a0, $t7, $s0
	bne $a0, $0, sll_7
	slt $a0, $t7, $s1
	bne $a0, $0, plus_7
	add $t8, $t8, '1' 
	j sll_7
plus_7:
	add $t8, $t8, '0'
	j sll_7
sll_7:
	sll $t7, $t7, 8
	j multeight_6
multeight_6:
	slt $a0, $t6, $s0
	bne $a0, $0, sll_6
	slt $a0, $t6, $s1
	bne $a0, $0, plus_6
	add $t7, $t7, '1' 
	j sll_6
plus_6:
	add $t7, $t7, '0'
	j sll_6
sll_6:
	sll $t6, $t6, 8
	j multeight_5
multeight_5:
	slt $a0, $t5, $s0
	bne $a0, $0, sll_5
	slt $a0, $t5, $s1
	bne $a0, $0, plus_5
	add $t6, $t6, '1' 
	j sll_5
plus_5:
	add $t6, $t6, '0'
	j sll_5
sll_5:
	sll $t5, $t5, 8
	j multeight_4
multeight_4:
	slt $a0, $t4, $s0
	bne $a0, $0, sll_4
	slt $a0, $t4, $s1
	bne $a0, $0, plus_4
	add $t5, $t5, '1' 
	j sll_4
plus_4:
	add $t5, $t5, '0'
	j sll_4
sll_4:
	sll $t4, $t4, 8
	j next
