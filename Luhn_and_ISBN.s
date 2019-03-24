				.data
string: 		.space	1024													#string buffer size
Choice:			.asciiz "\n1. Luhn algorithm\n2. Check ISBN(10 or 13)\n3. Exit\n"		#Menu with 2 option
Choice1:		.asciiz "\nEnter: "												#Menu Choice Input
Input:			.asciiz "\nEnter Card Number: "									#Input for Card Number
Valid:			.asciiz "This is a Valid Card"
NotValid:		.asciiz "This is not a Valid Card"
File:			.asciiz	"C:\Users\Ghayasuddin Adam\Desktop\isbn.txt"			#File for ISBN Output
File1:			.asciiz	"C:\Users\Ghayasuddin Adam\Desktop\card.txt"			#File for Card Output
InputISBN:		.asciiz "\nEnter ISBN Number: "									#Input for ISBN Number
newLine:		.asciiz "\n"													#For Printing New Line
Space:			.asciiz "   "													#Printing Space
isValid:		.asciiz "This is a Valid Number"
inValid:		.asciiz "This is not a Valid Number"
				.text

				.globl Slength													#string.length() Function	
Slength:
		li $s0, 0																#s0 = str.length()
		la $t0, string
		
		Counting:																# while(arr[i] != \0)
			lb $t1, ($t0)
			beq $t1, 0, Counted
			
			add $t0, $t0, 1
			add $s0, $s0, 1														#len++
		b Counting

	Counted:
		sub $s0, $s0, 1															#len = len-1  if int arr[3] then last index is 3-1
	
				jr $ra
				.end Slength
	
				.globl LuhnAlgo
LuhnAlgo:																		#Luhn algorithm

		move $t1, $s0 															#moving len into $t1
		sub $t1, $t1, 1															#sub 1 so we add $t1 to string to access last element
		
		li $t2, 0																#$t2 is used for sum
		li $s2, 0																#true , false Flag variable
		
		la $t0, string															#load string
		
		add $t0, $t0, $t1														#add $t1 to access last Element
		
		FOR2:																	#for(int i=last; i = -1; i--)
			beq $t1, -1, Exit							
			
				lb $t4, ($t0)													#load byte from string i.e str[i]
				sub $t4, $t4, 48												#str[i] - 48 , 48 is 0 ascii sub it from number character gives that number
				
				beq $s2, 0, isSecond											#if flag == 0 then it is not second
					mul $t4, $t4, 2												#if it is second digit multiply it by 2
					li $s2, 0													#set flag = false again
					b Cont
					
				isSecond:
					li $s2, 1													#set flag = true if it was false
				Cont:
					div $t5, $t4, 10											#if digit is greater tha 9 divide digit by 10 to get 1 digit 
					mfhi $t6													#mod by 10 to get second digit
					add $t2, $t2, $t5											#add first digit to sum
					add $t2, $t2, $t6											#add second digit to sum
					
					sub $t0, $t0, 1												#arr index --
					sub $t1, $t1, 1												#i--
		b FOR2
		
		Exit:
			div $t2, $t2, 10													#Take sum mod by 10 if ==0 then valid else not valid
			mfhi $s5															#save mod in $s5 to acess in main
		
				jr $ra
				.end LuhnAlgo													#End of Function
	
				.globl ISBN														#ISBN 10 or 13 validation
ISBN:																			
		beq $s0, 13, ISBN13														#if stringLength == 13 move to ISBN 13 else its ISBN 10
			li $s4, 0 															#s4 as sum variable
			li $t0, 0															# i = 0 (Loop variable)
			li $t9, 10															
			la $a1, string														#load string 
			
			FOR1:
				beq $t0, 9, checkLast											#for(int i=0 i=9 i++)				
					lb $t4, ($a1)												
					sub $t4, $t4, 48											#Load in $t4 and sub 48 (Zero Ascii) to get digit
					
					bgt $t4, 9, false
					blt $t4, 0, false											#if digit >9 or <0 than not valid isbn 10
					
					sub $t1, $t9, $t0											
					mul $t4, $t4, $t1
					add $s4, $s4, $t4											# sum = sum + digit * (10 - i)
					
					add $t0, $t0, 1												#increase Loop variable
					add $a1, $a1, 1												#increase index
			b FOR1
			
			checkLast:
				la $a1, string													
				add $a1, $a1, 9													#Load array and add 9 to access last index
				lb $t4, ($a1)	
				sub $t4, $t4, 48												#load value and sub 48 to get digit
				
				beq $t4, 40, X													#last digit == 40 (88 - 48)   88 is X ascii
				beq $t4, 72, X													#OR last digit == 72 (120 - 48)   120 is small x ascii
				bgt $t4, 9, false
				blt $t4, 0, false												#if digit >9 or <0 than not valid isbn 10
				
				add $s4, $s4, $t4												#if not x then simple add its value to sum
				b Mod11
			X:
				add $s4, $s4, 10												#if last digit was x then add 10
				b Mod11															#goto mod 11
				
		ISBN13:
			li $s4, 0 															#sum variable
			li $t0, 0															#loop variable
			la $a1, string														#load str
			
			FOR3:
				beq $t0, 13, Mod10												#while(i == 13)
					lb $t4, ($a1)
					sub $t4, $t4, 48											#Load in $t4 and sub 48 (Zero Ascii) to get digit
					
					bgt $t4, 9, false
					blt $t4, 0, false											#if digit >9 or <0 than not valid isbn 13
					
					add $t1, $t0, 1												#n = i + 1 to get digit position
					div $t1, $t1, 2											
					mfhi $t1													# n mod 2 if == 0 then it is even
					
					bne $t1, 0, loopConti
			
						mul $t4, $t4, 3											#if even then digit * 3
						
				loopConti:
					add $s4, $s4, $t4											#sum = sum + digit
					
					add $t0, $t0, 1												#increase Loop variable
					add $a1, $a1, 1												#increase index
			b FOR3
		
		false:
			li $s5 , 1															#set flag == 1 if isbn not valid 
			b Exit1
		Mod10:
			div $s4, $s4, 10 													#take sum mod 10 if ==0 then isbn 13 is valid
			mfhi $s5
			b Exit1
		Mod11:
			div $s4, $s4, 11 													#take sum mod 11 if ==0 then isbn 10 is valid
			mfhi $s5
		
		Exit1:
				jr $ra
				.end ISBN
	
main:
	li $v0, 4																	#printing menu
	la $a0, Choice
	syscall
	
	Again:
		li $v0, 4
		la $a0, Choice1															#printing input msg for menu
		syscall
	
		li $v0, 5
		syscall
		move $t0, $v0															#taking input for menu
		
		bgt $t0, 3, Again
		blt $t0, 1, Again														#if( >3 or <1) then ask again
		
		beq $t0, 3, EOM2														#if == 3 then exit
		beq $t0, 2, Second														#if == 2 then goto second option
				li $v0, 4
				la $a0, Input										
				syscall															#print input msg
				
				la $a0, string													#load string
				
				li $a1, 1024													#string input size limit
				li $v0, 8														#v0 , 8 take input as string
				syscall
				
				jal Slength														#calculating string length
				jal LuhnAlgo													#call LuhnAlgo function
				
																				#Open the File 
				li $v0, 13														#System call for opening the file
				la $a0, File1
				li $a1, 9														#Opening the File for writing (Flags are 0: Read, 1:Write, 9:Write and append)
				li $a2, 0														#Mode is ignored
				syscall															#Open the File (File descriptor returned in $v0)
				move $t6, $v0
				
																				#writing the File
				li $v0, 15														#System call for writing in the file
				move $a0, $t6													#Copying the file descriptor
				la $a1, newLine													#Address of buffer from which to write
				li $a2, 2														#Buffer length
				syscall
				
				li $v0, 15
				move $a0, $t6
				la $a1, string
				move $a2, $s0
				syscall
				
				li $v0, 15
				move $a0, $t6
				la $a1, Space
				li $a2, 3
				syscall
				
				bne $s5, 0, isNot1												#if == 0 then write valid msg in file else write not valid msg
				
					li $v0, 15
					move $a0, $t6
					la $a1, Valid
					li $a2, 20
					syscall
					
					b END1
				isNot1:
					li $v0, 15
					move $a0, $t6
					la $a1, NotValid
					li $a2, 24
					syscall
				
				END1:															#close the File
					li $v0, 16													#System call for closing the file
					move $a0, $t6												#Copying file descriptor
					syscall
			
			
		b EOM	
		
	Second:
		Again1:
				li $v0, 4
				la $a0, InputISBN
				syscall															#print input msg
				
				la $a0, string													#load string
				
				li $a1, 1024													#string input size limit
				li $v0, 8														#v0 , 8 take input as string
				syscall
				
				jal Slength														#calculating string length
				
				bgt $s0, 13, Again1
				blt $s0, 1, Again1												#if( <1 or >13) then ask again
				
				li $s5, 1; 														#flag = false 
				jal ISBN														#call ISBN function
																				#Open the File 
				li $v0, 13														#System call for opening the file
				la $a0, File						
				li $a1, 9														#Opening the File for writing (Flags are 0: Read, 1:Write, 9:Write and append)
				li $a2, 0														#Mode is ignored
				syscall															#Open the File (File descriptor returned in $v0)
				move $t6, $v0													
				
				li $v0, 15
				move $a0, $t6
				la $a1, newLine
				li $a2, 2
				syscall
				
				li $v0, 15
				move $a0, $t6
				la $a1, string
				move $a2, $s0
				syscall
				
				li $v0, 15
				move $a0, $t6
				la $a1, Space
				li $a2, 3
				syscall
				
				bne $s5, 0, isNot 												#if == 0 then write valid msg in file else write not valid msg
				
					li $v0, 15
					move $a0, $t6
					la $a1, isValid
					li $a2, 22
					syscall
					
					b END
				isNot:
					li $v0, 15
					move $a0, $t6
					la $a1, inValid
					li $a2, 26
					syscall
				
				END:
																				#close the File
					li $v0, 16													#System call for closing the file
					move $a0, $t6												##Copying file descriptor
					syscall
		
	EOM:
		b main
	EOM2:
		li $v0, 10
		syscall
		
	.end main