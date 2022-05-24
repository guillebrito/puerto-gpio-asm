// Cortex-M3 Devices Generic User Guide: https://developer.arm.com/documentation/dui0552/
// STM32f103xx Family Reference Manual: https://www.st.com/resource/en/reference_manual/cd00171190-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf
// STM32f103c8 Datasheet: https://www.st.com/resource/en/datasheet/stm32f103c8.pdf
// Procedure Call Standard for the Arm Architecture: https://github.com/ARM-software/abi-aa/blob/main/aapcs32/aapcs32.rst
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm
.macro endfun nombre
    .size \nombre, . - \nombre
.endm

.set Pin__puerto,0
.set Pin__numero,4

defun Pin_init
    // R0: self, R1: puerto, R2: numPin
    str R1,[R0,#Pin__puerto]
    str R2,[R0,#Pin__numero]
    bx lr
endfun Pin_init

.set CRL,0x00
.set CRH,0x04
.set IDR,0x08
.set ODR,0x0C
.set BSRR,0x10
.set BRR,0x14
.set MASCARA_BITS_CONFIG, 0xF

defun Pin_configura
    // R0: self, R1: config
    push {R4-R6,LR}
    ldr R2,[R0,#Pin__puerto]      
    ldr R3,[R0,#Pin__numero]   
    mov R12,R1
    movs R6,#CRL
    cmp R3,#7  
    bls 0f
    movs R6,#CRH
    subs R3,#8
0:  ldr R4,[R2,R6]
    movs R5,#MASCARA_BITS_CONFIG
    lsls R3,#2
    lsls R5,R3
    bics R4,R5
    ands R1,#MASCARA_BITS_CONFIG
    lsls R1,R3
    orrs R4,R1
    str  R4,[R2,R6]
    cmp R12,#8
    bne 0f
    movs R1,#0
    bl Pin_escribe
0:  cmp R12,#24
    bne 0f
    movs R1,#1
    bl Pin_escribe    
   //  ands R12,R1,#MASCARA_BITS_CONFIG
   //  cmp R12,#8         //Pregunta si los primeros 4 bits son correspondientes a pull up o dn
   //  bne 0f
   //  ubfx R1,R1,#4,#1 //Extrae de R1 un bit de la pos. 4 y lo guarda en R12
   //  bl Pin_escribe
0:  pop {R4-R6,PC}
endfun Pin_configura



defun Pin_escribe
    // R0: self, R1: valor
    ldr R2,[R0,#Pin__puerto]
    ldr R3,[R0,#Pin__numero]
    cmp R1,#0       //comparo R1
    mov R1,#BRR     //escribo BRR en R1 por defecto
    beq 0f          //si fue R1=0 no modifico R1=BRR
    movs R1,#BSRR   //si fue R1=1 modifico R1=BSRR
0:  movs R0,#1
    lsls R0,R3      //coloco un 1 en el bit correspondiente al pin
    str R0,[R2,R1]  //Seteo o reseteo dicho pin segun R1
    bx lr
endfun Pin_escribe

defun Pin_lee
    // R0: self
    ldr R2,[R0,#Pin__puerto]
    ldr R3,[R0,#Pin__numero]
    ldr R0,[R2,#IDR]   
    movs R1,#1           //pongo un 1 en R1 
    lsls R1,R3           //lo desplazo a la izq el num de pin correspondiente
    ands R0,R1           //realizo op and     
    lsrs R0,R3           //desplazo a la der el num de pin
    bx lr                //R0 tiene el valor de la lectura efectuada
    // R0: valor
endfun Pin_lee
defun Pin_leeSalida
    // R0: self
    ldr R2,[R0,#Pin__puerto]
    ldr R3,[R0,#Pin__numero]
    ldr R0,[R2,#ODR]   
    movs R1,#1           //Idem anterior
    lsls R1,R3
    ands R0,R1
    lsrs R0,R3
    bx lr
    // R0: valor
endfun Pin_leeSalida
