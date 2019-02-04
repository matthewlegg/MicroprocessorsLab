#include p18f87k22.inc

    global DAC_Setup

int_hi code 0x0008 ; high vector, no low vector
    
    btfss INTCON,TMR0IF ; check that this is timer0 interrupt 
    retfie FAST ; if not then return 
    incf LATD ; increment PORTD 
    decf LATE
    bcf INTCON,TMR0IF ; clear interrupt flag
    incf LATE
    retfie FAST ; fast return from interrupt

DAC code

DAC_Setup
    clrf TRISD ; Set PORTD as all outputs 
    clrf LATD ; Clear PORTD outputs 
    movlw b'10000000' ; Set timer0 to 16-bit, Fosc/4/256 
    movwf T0CON ; = 62.5KHz clock rate, approx 1sec rollover
    movlw 0xFE
    movwf TRISE
    movlw 0x01
    movwf LATE
    bsf INTCON,TMR0IE ; Enable timer0 interrupt 
    bsf INTCON,GIE ; Enable all interrupts return
    return
    
    end


