; EE 460N Lab 2 test case
; Name 1: Alan Schwartz        UTEID 1: as237333
; Name 2: Siddhartha Guntupalli UTEID 2: sg59532
;
; One program that exercises every opcode required for lab 2. Each test drops
; its result into the RES block, so the whole run can be checked with a single
; mdump of RES plus one rdump at the end. Expected values are in the comments
; and collected in lab2test.expected.

.ORIG x3000

; ---- setup: LEA, LDW with a positive word offset ----------------------
        LEA R0, DATA            ; R0 = &DATA
        LDW R1, R0, #0          ; R1 = x1234
        LDW R2, R0, #1          ; R2 = xABCD  (offset6 must be shifted left 1)
        LEA R3, RES             ; R3 = &RES

; ---- ADD, both operand forms -----------------------------------------
        ADD R4, R1, #5          ; imm5 -> x1239
        STW R4, R3, #0
        ADD R4, R1, R2          ; SR2  -> xBE01, carry out of bit 15 dropped
        STW R4, R3, #1

; ---- AND, both operand forms -----------------------------------------
        AND R4, R1, #-2         ; imm5 sign-extends to xFFFE -> x1234
        STW R4, R3, #2
        AND R4, R1, R2          ; SR2 -> x0204
        STW R4, R3, #3

; ---- XOR, both operand forms, and NOT --------------------------------
        XOR R4, R1, #15         ; imm5 -> x123B
        STW R4, R3, #4
        XOR R4, R1, R2          ; SR2 -> xB9F9
        STW R4, R3, #5
        NOT R4, R1              ; XOR with imm5 x1F -> xEDCB
        STW R4, R3, #6

; ---- shifts ----------------------------------------------------------
        LSHF R4, R1, #4         ; x2340, bits shifted past 15 are dropped
        STW R4, R3, #7
        RSHFL R4, R2, #4        ; x0ABC, zero fill
        STW R4, R3, #8
        RSHFA R4, R2, #4        ; xFABC, sign fill (xABCD is negative)
        STW R4, R3, #9

; ---- LDB sign extension, on both bytes of a word ---------------------
        LDB R4, R0, #2          ; low byte of xABCD  -> xFFCD
        STW R4, R3, #10
        LDB R4, R0, #3          ; high byte of xABCD -> xFFAB
        STW R4, R3, #11

; ---- BR: taken, not taken, unconditional -----------------------------
        AND R5, R5, #0          ; R5 = 0, sets Z
        BRz BR1                 ; taken
        ADD R5, R5, #9          ; skipped
BR1     ADD R5, R5, #1          ; R5 = 1, sets P
        BRn BR2                 ; not taken, n is clear
        ADD R5, R5, #2          ; R5 = 3
BR2     BRnzp BR3               ; always taken
        ADD R5, R5, #9          ; skipped
BR3     STW R5, R3, #12         ; x0003

; ---- backward branch with a negative PCoffset9 -----------------------
        AND R6, R6, #0
        ADD R6, R6, #5          ; loop counter
        AND R5, R5, #0          ; running sum
LOOP    ADD R5, R5, R6
        ADD R6, R6, #-1
        BRp LOOP
        STW R5, R3, #13         ; 5+4+3+2+1 = x000F

; ---- negative offset6 on STW and LDW ---------------------------------
        LEA R4, RESEND
        STW R1, R4, #-10        ; RESEND-20 = RES+28 -> x1234
        LDW R5, R4, #-26        ; RESEND-52 = DATA   -> x1234
        STW R5, R3, #16

; ---- STB writes one byte and leaves the other alone ------------------
        STB R1, R3, #30         ; low byte of RES+30 -> x0034

; ---- LEA must not disturb the condition codes ------------------------
        AND R5, R5, #0
        ADD R5, R5, #-1         ; R5 = xFFFF, sets N
        LEA R6, DATA            ; must leave N set
        BRn CCOK
        AND R5, R5, #0          ; only reached if LEA clobbered the CCs
        BRnzp CCEND
CCOK    AND R5, R5, #0
        ADD R5, R5, #7          ; x0007 means LEA behaved
CCEND   STW R5, R3, #17

; ---- JMP -------------------------------------------------------------
        AND R5, R5, #0
        ADD R5, R5, #1
        LEA R4, JTGT
        JMP R4
        AND R5, R5, #0          ; skipped if JMP works
JTGT    STW R5, R3, #21         ; x0001

; ---- JSR, JSRR, RET --------------------------------------------------
        JSR SUB1                ; PCoffset11 form
        STW R6, R3, #18         ; SUB1 returns x000A in R6
        STW R7, R3, #19         ; return address JSR left in R7
        LEA R4, SUB2
        JSRR R4                 ; BaseR form
        STW R6, R3, #20         ; SUB2 returns x000B in R6

; ---- TRAP: halt, and R7 holds the incremented PC ---------------------
        HALT

SUB1    AND R6, R6, #0
        ADD R6, R6, #10
        RET                     ; JMP R7

SUB2    AND R6, R6, #0
        ADD R6, R6, #11
        RET

DATA    .FILL x1234
        .FILL xABCD

RES     .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
        .FILL x0000
RESEND  .FILL x5A5A

.END
