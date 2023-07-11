;====================================================================

	LIST P=18F45K50 
	#include "P18f45K50.INC" ;ENCABEZADO

;====================================================================
; Bits de configuracion
;--------------------------------------------------------------------
  CONFIG  PLLSEL = PLL3X        ; PLL Selection (3x clock multiplier)
  CONFIG  CFGPLLEN = ON         ; PLL Enable Configuration bit (PLL Enabled)
  CONFIG  LS48MHZ = SYS48X8     ; Low Speed USB mode with 48 MHz system clock (System clock at 48 MHz, USB clock divider is set to 8)
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection (Internal oscillator)
  CONFIG  nPWRTEN = ON          ; Power-up Timer Enable (Power up timer enabled)
  CONFIG  BORV = 250            ; Brown-out Reset Voltage (BOR set to 2.5V nominal)
  CONFIG  nLPBOR = ON           ; Low-Power Brown-out Reset (Low-Power Brown-out Reset enabled)
  CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bits (WDT disabled in hardware (SWDTEN ignored))
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<5:0> pins are configured as digital I/O on Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)

;====================================================================
; MEMORIA DE DATOS
;--------------------------------------------------------------------

	CBLOCK  0x00
	REG1
	REG2
	REG3
	CONT
	ENDC

;====================================================================
; VECTOR DE INICIO
;--------------------------------------------------------------------

	ORG		0x2000
	GOTO		START
	
	ORG		0x2008
	RETFIE
	
	ORG		0x2018
	RETFIE
	
;====================================================================
; PROGRAMA PRINCIPAL
;--------------------------------------------------------------------

START			      ; PUNTO DE ENTRADA DEL PROGRAMA EN REINICIO
	MOVLW   0x70
    	MOVWF   OSCCON	      ; CONFIGURACION DEL OSCILADOR
        CALL	SETPWM1	      ; CONFIGURACION PWM EN RC2 @ 4kHz
	MOVLW	0x00
	MOVWF	CCPR1L
LOOP
        ; RETARDO 500mS ( 5 x Base 100mS)
	CLRF	CONT
INCREMENT
	MOVFF	CONT,CCPR1L
	CALL 	DELAY_100MS	  ;
	INCFSZ	CONT
	GOTO	INCREMENT
	SETF	CONT
DECREMENT
	MOVFF	CONT,CCPR1L
	CALL 	DELAY_100MS	  ;
	DECFSZ	CONT
	GOTO	DECREMENT
	GOTO	LOOP
			
;====================================================================
; RETARDOS
;--------------------------------------------------------------------

DELAY_100MS			;100mS
	MOVLW	.17	        ;MUEVE LITERAL EN BASE 10 A WREG
	MOVWF	REG1		;MUEVE WREG A REG1
LOOP1	MOVLW	.204
	MOVWF	REG2
LOOP2	MOVLW	.114
	MOVWF	REG3
LOOP3	DECFSZ	REG3		;DECREMENTA REG3, OMITE "GOTO LOOP3" SI REG3 = 0
	GOTO	LOOP3
	DECFSZ	REG2
	GOTO	LOOP2
	DECFSZ	REG1
	GOTO	LOOP1
	RETURN
	
;====================================================================
; GENERADOR PWM
;--------------------------------------------------------------------
SETPWM1
	MOVLW	0x0C	    
	MOVWF	CCP1CON	    ; CONFIGURA MODO PWM EN RC2
	CLRF	CCPR1L	    ; CICLO DE TRABAJO @ 0%
	MOVLW	0xBA	    
	MOVWF	PR2	    ; FRECUENCIA PWM @ 4kHz
	MOVLW	0x07
	MOVWF	T2CON	    ; ACTIVA SALIDA PWM
	BCF     TRISC,2     ; PIN RC2 SE CONFIGURA COMO SALIDA
	RETURN
END