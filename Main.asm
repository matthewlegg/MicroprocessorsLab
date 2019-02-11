	#include p18f87k22.inc

	extern  LCD_Setup, LCD_Write_Message, LCD_clear, Line_set_2, Line_set_1,LCD_Write_Hex ; external LCD subroutines
	extern  Press_test, Keypad_Setup
	extern  Multiply_Setup, multiply		    ; external ADC routines
	extern  DAC_Setup, time_sec, time_min, time_hour
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
delay_cnt_2 res 1   ; reserve one byte for counter in the delay routine
 
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "I am alarm clock\n"	; message, plus carriage return
	constant    myTable_l=.17	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup LCD
	call    Keypad_Setup	; setup Keypad
	call	Multiply_Setup	; setup ADC
	goto	start
	
	; ******* Main programme ****************************************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	
	call    LCD_clear
	call    Line_set_2
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	call    Line_set_1
	
       	call    DAC_Setup
magic_code
	movff time_hour, WREG
	call multiply
	call LCD_Write_Hex
	movff time_min, WREG
	call multiply
	call LCD_Write_Hex
	movff time_sec, WREG
	call multiply
	call LCD_Write_Hex
	call Line_set_1
	bra magic_code

	goto	$		; goto current line in code
	
	
	; a delay subroutine if you need one, times around loop in delay_count

delay_4us		    ; delay given in chunks of 4 microsecond in W
	movwf	delay_count   ; now need to multiply by 16
	swapf   delay_count,F ; swap nibbles
	movlw	0x0f	    
	andwf	delay_count,W ; move low nibble to W
	movwf	delay_cnt_2   ; then to cnt_h
	movlw	0xf0	    
	andwf	delay_count,F ; keep high nibble in cnt_l
	call	delay
	return

delay			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1	decf 	delay_count,F	; no carry when 0x00 -> 0xff
	subwfb 	delay_cnt_2,F	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return
	
	end