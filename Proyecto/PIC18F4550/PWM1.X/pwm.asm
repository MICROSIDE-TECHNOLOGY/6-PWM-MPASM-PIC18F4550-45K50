;====================================================================

	LIST P=18F4550 
	#include "P18f4550.INC" ;ENCABEZADO

;====================================================================
; Bits de configuracion
;--------------------------------------------------------------------

  CONFIG  PLLDIV = 5            ; PLL Prescaler Selection bits (Divide by 5 (20 MHz oscillator input))
  CONFIG  CPUDIV = OSC2_PLL3    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /2][96 MHz PLL Src: /3])
  CONFIG  USBDIV = 2            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes from the 96 MHz PLL divided by 2)
  CONFIG  FOSC = HSPLL_HS       ; Oscillator Selection bits (HS oscillator, PLL enabled (HSPLL))
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)
  CONFIG  PWRT = ON             ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  BOR = SOFT            ; Brown-out Reset Enable bits (Brown-out Reset enabled and controlled by software (SBOREN is enabled))
  CONFIG  BORV = 1              ; Brown-out Reset Voltage bits (Setting 2 4.33V)
  CONFIG  VREGEN = ON           ; USB Voltage Regulator Enable bit (USB voltage regulator enabled)
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
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
	
	ORG	  	0x2008
	RETFIE

	ORG	    	0x2018
	RETFIE
	
;====================================================================
; PROGRAMA PRINCIPAL
;--------------------------------------------------------------------

START			      ; PUNTO DE ENTRADA DEL PROGRAMA EN REINICIO
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