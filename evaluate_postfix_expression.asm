.data
	start: .asciiz "Please input a postfix arithmetic expression:\n\0"
	out: .asciiz "The value is: \0"
	error: .asciiz "This is an illegal postfix arithmetic expression.\n\n\0"
	input: .space 100 #make 100bytes to place input
	#answer to place in $t0
	end: .asciiz "\n\n\0"
.text
main:
	li $v0, 4
	la $a0, start
	syscall
	
	li $t0, 0 #initial answer
	li $sp, 0x7fffeffc #initial stack pointer
	
	li $v0, 8 #read  postfix arithmetic expression
	la $a0, input
	li $a1, 100
	syscall
	
	#go to loop to solve
	jal loop
	#go to loop to solve
	
	j main
loop:
	lb $t1, ($a0)
	beq $t1, 46, exit #read "." to go back main
	
	beq $t1, ',', push #store the number to the stack
	#first take out two number to go to pop
	beq $t1, '+', pop 
	beq $t1, '-', test #go to check integer is positive or negative
	beq $t1, '*', pop
	beq $t1, '/', pop
	
	#if is number save to the a2
	li $t4, 1 #mark t4 to check if front of . is number
	sub $t1, $t1, 48 #because ascii 48 is 0
	mul $a2, $a2, 10 
	add $a2, $a2, $t1
	
	addi $a0, $a0, 1 #go to input next byte
	j loop
test: 
	#test integer is positive or negative
	la $t5, ($a0)
	add $t5, $t5, 1 #test  input next byte
	lb $t5, ($t5)
	beq $t5, ',', pop
	beq $t5, 46, pop
	li $t6, 1 #mark integer is negative
	addi $a0, $a0, 1 #go to input next byte
	j loop
exit:
	#show answer
	li $v0, 4
	la $a0, out
	syscall
	li $v0, 1
	lw $t0, 0($sp)
	la $a0, 0($t0)
	syscall
	li $v0, 4
	la $a0, end
	syscall
	#show answer
	jr $ra
wrong:
	li $v0, 4
	la $a0, error
	syscall
	jr $ra
negative:
	sub $a2, $0, $a2
	sw $a2, 0($sp)	#a2 is argument value to store in stack
	li $a2, 0 #clean $a2
	li $t4, 0 #clean mark
	li $t6, 0
	j loop
push:
	addi $a0, $a0, 1 #go to input next byte
	beq $t4, 0, loop
	addi $sp, $sp, -4 #move stack pointer to next value 
	beq $t6, 1, negative
	sw $a2, 0($sp)	#a2 is argument value to store in stack
	li $a2, 0 #clean $a2
	li $t4, 0 #clean mark
	li $t6, 0
	j loop
pop:
	beq $sp, 0x7fffeff8, wrong #if no number can take that is error
	lw $a3, 0($sp) #a3 is value to calculate
	addi $sp, $sp, 4 #move stack pointer to previous value 
	lw $a2, 0($sp) #a2 is value to calculate
	addi $sp, $sp, 4 #move stack pointer to previous value 
	beq $t1, '+', plus
	beq $t1, '-', subtraction
	beq $t1, '*', multiplication
	beq $t1, '/', division
	j wrong
plus:
	add $a2, $a2, $a3
	li $t4, 1 #mark t4 to check if front of . is number
	j push
subtraction:
	sub $a2, $a2, $a3
	li $t4, 1 #mark t4 to check if front of . is number
	j push
multiplication:
	mul $a2, $a2, $a3
	li $t4, 1 #mark t4 to check if front of . is number
	j push
division:
	div $a2, $a2, $a3
	li $t4, 1 #mark t4 to check if front of . is number
	j push
