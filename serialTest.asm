

; PIC16F18313 Configuration Bit Settings

; Assembly source line config statements

#include "p16f18313.inc"

; CONFIG1
; __config 0x17EC
 __CONFIG _CONFIG1, _FEXTOSC_OFF & _RSTOSC_HFINT1 & _CLKOUTEN_OFF & _CSWEN_OFF & _FCMEN_OFF
; CONFIG2
; __config 0x2510
 __CONFIG _CONFIG2, _MCLRE_OFF & _PWRTE_ON & _WDTE_OFF & _LPBOREN_ON & _BOREN_OFF & _BORV_HIGH & _PPS1WAY_OFF & _STVREN_OFF & _DEBUG_OFF
; CONFIG3
; __config 0x1FFC
 __CONFIG _CONFIG3, _WRT_ALL & _LVP_OFF
; CONFIG4
; __config 0x3FFC
 __CONFIG _CONFIG4, _CP_ON & _CPD_ON



        ORG	0000H
        GOTO	MAIN

        ORG	0004H
        RETFIE

CNT	EQU	20h
CNT2	EQU	21h

MAIN
	BANKSEL	PORTA
	CLRF	PORTA	    ;Clear PORTA

	BANKSEL	LATA	    ;Data Latch
	CLRF	LATA

; start A/D configuration
	BANKSEL	ANSELA
	CLRF	ANSELA	    ;digital I/O
	BSF	ANSELA, 0
	BSF	ANSELA, 4
	BSF	ANSELA, 5

	BANKSEL	ADCON0
	MOVLW	b'00000001'
	MOVWF	ADCON0

	CALL	TIMER
; end A/D configuration


	BANKSEL	TRISA	    ;
	MOVLW	B'00110011'   
			    ; RA5,4,0 = Acc. Input
			    ; RA3 = not used = output
			    ; RA2 = TX = output
			    ; RA1 = RX = Input
	MOVWF	TRISA	    
	
; set Rx/Tx pins for USART
	BANKSEL	RXPPS		; set RA1 for RX Input Pin
	MOVLW	b'00001'
	MOVWF	RXPPS

	BANKSEL	RA2PPS
	MOVLW	b'10100'	; EUART CK/TX
	MOVWF	RA2PPS

; enable UART (default ON, no need of this code)
;	BANKSEL	PMD4
;	BCF	PMD4, UART1MD	; enable UART (1 = disable)

; set speed
	BANKSEL	TX1STA
	MOVLW	B'00100100'	; CLOCK-N/A, TX9-OFF, TXENABLE=1, ASYNC
				; N/A, BAUDRATE-HIGH, TR.SR-FULL, TX9D=0
	MOVWF	TX1STA

	BANKSEL	RC1STA
	MOVLW	B'10010000'	; Serial enabled, rx 9bit off, n/a, continuous
				; n/a, no framing error, no overrun error, n/a
	MOVWF	RC1STA

	BANKSEL	BAUD1CON
	MOVLW	b'00000000'	; ro, ro, n/a, idle Tx H, 8 bit, n/a, non wakeup, non auto
	MOVWF	BAUD1CON

	BANKSEL	SP1BRGL
	MOVLW	0CH		; 1MHz / 16 / (12+1) = 4800
	MOVWF	SP1BRGL		; F/16/(X+1)

	BANKSEL	PORTA

ADLOOP
	CALL	TIMER
	BANKSEL	ADCON0
	BSF	ADCON0, ADGO
	BTFSC	ADCON0, ADGO
	GOTO	$-1
	BANKSEL	ADRESL
	MOVFW	ADRESL
	BANKSEL	TX1REG
	MOVWF	TX1REG
	GOTO	ADLOOP


LOOP
	BANKSEL	TX1REG
	MOVLW	'A'
	MOVWF	TX1REG
	CALL	TIMER

	BANKSEL	PORTA
	BCF	PORTA, 0

	BANKSEL	TX1REG
	MOVLW	'B'
	MOVWF	TX1REG
	CALL	TIMER

	BANKSEL	PORTA
	BSF	PORTA, 0
	GOTO	LOOP

TIMER
	BANKSEL	PORTA
	MOVLW	0FFh
	MOVWF	CNT2

TIMER2
	MOVLW	0ffh
	MOVWF	CNT
L2
	DECFSZ	CNT
	GOTO	L2

	DECFSZ	CNT2
	GOTO	TIMER2
	RETURN

	END
