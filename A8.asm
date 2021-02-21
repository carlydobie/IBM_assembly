//KC03D86C JOB ,'Carly Dobie',MSGCLASS=H
//STEP1 EXEC PGM=ASSIST
//STEPLIB DD DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSIN DD *
********************************************
* Assignment 8
*
* NAME: Carly Dobie
********************************************
ENTRY   DSECT
ID      DS    F
STATS   DS    F
STACONT DS    XL1
********************************************
*
* Register Usage in executable code:
*   3        Parameter List
*  15        Base Register 
*
********************************************
* Executable code:
MAIN     CSECT
         STM   14,12,12(13)
         LR    12,15
         USING MAIN,12
         LA    14,MSAVE
         ST    13,4(,14)
         ST    14,8(,13)
         LR    13,14
         LA    1,PARAMS
         L     15,=V(BUILD)
         BALR  14,15
         L     15,=V(PRINT)
         BALR  14,15
         L     15,=V(SORTID)
         BALR  14,15
         L     15,=V(PRINT)
         BALR  14,15
         L     13,4(,13)
         LM    14,15,12(13)
         LM    1,12,24(13)
         BR    14
         LTORG
         ORG   MAIN+((*-MAIN+31)/32)*32
TABLE    DC    16CL9' '     
ENDTABLE DS    0H               Marks the end of TABLE
EOT      DC    A(TABLE)         Address of 1st unused entry in TABLE
PARAMS   DC    A(TABLE)         Parameter list
         DC    A(EOT)
MSAVE    DS    18F
********************************************
*
* Register Usage in BUILD:
*   1        Parameter list
*   2        Address of TABLE
*   3        Address of EOT
*   4
*   5        CVB and byte compression, ID, Test 1,
*            Quiz Total
*   6        CVB and byte compression, Test 2
*   7        CVB and byte compression, No. HWs
*   8        CVB and byte compression, HW Total
*   9        CVB and byte compression, No. Quizzes
*  10        Incomplete flag
*  11        Withdrawal flag
*  12        Base Register 
*
******************************************** 
* Start BUILD subroutine:
* BUILD reads records from an input file and places them into a 
* table 
BUILD    CSECT
         STM   14,12,12(13)     Save the registers
         LR    12,15            Establish 12 as the  
         USING BUILD,12         base register
         LA    14,BSAVE         Point R14 at BSAVE
         ST    13,4(,14)        Save the forward pointer
         ST    14,8(,13)        Save the backward pointer
         LR    13,14            Point R13 at BSAVE
         LM    2,3,0(1)         Load parameter list into 2-3
         USING ENTRY,2          Format for table
READ     XREAD BUFFER,80        Read line of input
         BC    B'0100',ENDREAD  End loop if at EOF
         CR    2,3              See if at end of table
         BE    ENDREAD          End loop if table is full
         SR    5,5              Initialize registers
         SR    6,6              "
         SR    7,7              "
         SR    8,8              "
         SR    9,9              "
         PACK  TEMP(8),BUFFER+1(7)   Pack ID  
         CVB   5,TEMP           Convert ID to binary
         STCM  5,B'1111',ID     Store ID
         PACK  TEMP(8),BUFFER+10(3) Pack Test 1
         CVB   5,TEMP           Convert Test 1 to binary
         SLL   5,25             Move over to bits 0-6
* bit 7 will be for the incomplete flag
*        MVC   BUFFER+31(1),TEMP2
*        L     10,TEMP2
*        C     10,=C'I'
*        BNE   SKIP1
*        ST    10,=B'00000001000000000000000000000000'
*        B     CONT1
SKIP1    SR    10,10
CONT1    PACK  TEMP(8),BUFFER+15(2) Pack Test 2
         CVB   6,TEMP           Convert Test 2 to binary
         SLL   6,17             Move over to bits 8-14
*bit 15 will be for the withdrawal flag
*        MVC   BUFFER+28(1),TEMP2
*        L     11,TEMP2
*        C     11,=C'W'
*        BNE   SKIP2
*        ST    11,=B'00000000000000010000000000000000'
*        B     CONT2
SKIP2    SR    11,11
CONT2    PACK  TEMP(8),BUFFER+20(1) Pack Number of Homeworks
         CVB   7,TEMP           Convert NoHs to binary
         SLL   7,16             Move over to bits 16-18
         PACK  TEMP(8),BUFFER+23(3) Pack Homework Total
         CVB   8,TEMP           Convert to binary
         SLL   8,6              Move over to bits 19-28
         PACK  TEMP(8),BUFFER+34(1) Pack Number of Quizzes
         CVB   9,TEMP           Convert to binary
         AR    5,6              Combine data into one register
         AR    5,7              "
         AR    5,8              "
         AR    5,9              "
         AR    5,10             "
         AR    5,11             "
         STCM  5,B'1111',STATS  Store compressed data in STATS
         PACK  TEMP(8),BUFFER+37(2) Pack quiz total
         CVB   5,TEMP           Convert to binary
         SRL   5,25             Zero out bits 7-32
         SLL   5,25             Move over to bits 0-6
         STCM  5,B'1111',STACONT Store Quiz Total in 9th byte
         LA    2,9(0,2)         Advance to next slot in TABLE
         ST    2,0(0,3)         Store address of 1st unused entry 
         B     READ             Repeat loop
ENDREAD  LM    2,3,0(1)
         XDUMP 0(2),144
         L     13,4(0,13)       Point R13 at caller's save area.              
         LM    14,12,12(13)     Restore the registers. 
         BR    14               Return to the caller.
         LTORG
TEMP     DS    D                For CVB
TEMP2    DS    F 
BUFFER   DS    81C              Input storage area
BSAVE    DS    18F              Save area for BUILD
********************************************
*
* Register Usage in PRINT:    
*   1        Parameter list
*   2        Address of TABLE
*   3        Address of EOT
*   4        Address of BUFFER
*   5        ICM
*  12        Base Register
*
******************************************** 
* Start PRINT subroutine:
* PRINT prints out all the numbers that were saved in TABLE.
PRINT    CSECT
         STM   14,12,12(13)     Save the registers
         LR    12,15            Establish 12 as the        
         USING PRINT,12         base register
         LA    14,PSAVE         Point R14 at PSAVE
         ST    13,4(0,14)       Save the forward pointer
         ST    14,8(0,13)       Save the backward pointer
         LR    13,14            Point R13 at PSAVE
         LM    2,4,0(1)         Unload the parameters
         USING ENTRY,2          Format for table
         XPRNT HEAD,33          Print page header
         XPRNT COLS1,52         Print column headers
         XPRNT COLS2,57         "
PLINE    CR    2,3              See if at end of table
         BE    ENDPRINT         Stop printing at end of table
         MVI   LINE+1,C' '      Clear output line
         MVC   LINE+2(80),LINE+1 "
*Data in ID
         MVC   PID(8),=X'D921202020202020' Format ID
         ICM   5,B'1111',ID     Extract binary ID
         SLL   5,4              Clear data before
         SRL   5,4              Move to the end
         CVD   5,TEMP3          Convert to decimal
         MVC   TEMP4(4),TEMP3+4 Move onto fullword
         ED    PID(8),TEMP4     Apply formatting
*Data in STATS 
*Test 1 is in bits 0-6 (7 bits)
         MVC   TEST1(4),=X'40212020' Format Test 1
         ICM   5,B'1111',STATS
         SRL   5,25              Move to the end
         CVD   5,TEMP3          
         MVC   TEMP4(4),TEMP3+6 
         ED    TEST1(4),TEMP4
*Incomplete flag is in bit 7 (1 bit)  
*Test 2 is in bits 8-14 (7 bits)
         MVC   TEST2(3),=X'402120' Format Test 2
         ICM   5,B'1111',STATS
         SLL   5,8                 Clear data before
         SRL   5,24                Move to the end
         CVD   5,TEMP3
         MVC   TEMP4(4),TEMP3+6
         ED    TEST2(3),TEMP4 
*Withdrawal flag is in bit 15 (1 bit)
*Number of Homeworks is in bits 16-18 (3 bits)
         MVC   NUMHOM(2),=X'4021' Format Number of HWs
         ICM   5,B'1111',STATS
         SLL   5,16                 Clear data before
         SRL   5,29                 Move to the end
         CVD   5,TEMP3 
         MVC   TEMP4(4),TEMP3+6
         ED    NUMHOM(2),TEMP4 
*Homework Total is in bits 19-28 (10 bits)
         MVC   HOMETOT(4),=X'40212020' Format HW Total
         ICM   5,B'1111',STATS
         SLL   5,19
         SRL   5,22
         CVD   5,TEMP3
         MVC   TEMP4(4),TEMP3+6
         ED    HOMETOT(4),TEMP4
*Number of Quizzes is in bits 29-31 (3 bits)
         MVC   NUMQUIZ(2),=X'4021' Format No Quizzes
         ICM   5,B'1111',STATS
         SLL   5,29
         SRL   5,29
         CVD   5,TEMP3
         MVC   TEMP4(4),TEMP3+6
         ED    NUMQUIZ(2),TEMP4
*Quiz total is in bits 0-6
         MVC   QUIZTOT(3),=X'402120' Format Quiz Total
         ICM   5,B'1111',STATS
         SRL   5,25
         CVD   5,TEMP3
         MVC   TEMP4(4),TEMP3+6
         ED    QUIZTOT(3),TEMP4
         XPRNT LINE,28           Print LINE    
         LA    2,9(0,2)          Advance table pointer
         B     PLINE             Repeat line loop
* All values in table have been printed.
ENDPRINT L     13,4(0,13)        Point R13 at caller's save area.              
         LM    14,12,12(13)      Restore the registers. 
         BR    14                Return to the caller.
         LTORG
PSAVE    DS    18F               Save area for PRINT
TEMP3    DS    D
TEMP4    DS    F
HEAD     DC    CL1'1'
         DC    CL32'                 CSCI 359 Grades'
COLS1    DC    CL1'-'
         DC    CL51'               Number of Homework Number of'
COLS2    DC    CL57' ID     T1  T2  Homeworks  Total    Quizzes  W? I?'
LINE     DC    CL2'0'
PID      DS    8C
TEST1    DS    4C
TEST2    DS    3C
NUMHOM   DS    2C
HOMETOT  DS    4C
NUMQUIZ  DS    2C 
QUIZTOT  DS    3C 
WITHDRAW DC    CL1' '
INCOMPLE DC    CL1' '
********************************************
*
* Register Usage in SORTID:
*   1        Parameter list
*   2        Address of TABLE
*   3        Address of EOT
*   4        Address of BUFFER
*   5        Pointer to table entry
*  12        Base Register
*
******************************************** 
SORTID   CSECT
         STM   14,12,12(13)     Save the registers
         LR    12,15            Establish 12 as the        
         USING SORTID,12        Base register 
         LA    14,SSAVE         Point R14 at SSAVE
         ST    13,4(0,14)       Save the forward pointer
         ST    14,8(0,13)       Save the backward pointer
         LR    13,14            Point R13 at SSAVE
         LM    2,4,0(1)         Unload the parameters
         USING ENTRY,2          Format for table
*Registers 2 (I) and 5 (J) are pointers to an entry in table
*initially pointing to the beginning of the table
*Register 3 (STOP) is a pointer to the end of the table
BUBSORT  CR    2,3              While I < STOP
         BE    ENDSORT
         ST    5,0(0,2)         J = I
         CR    5,3              While J < STOP
INNERBS  ST    6,0(0,5)         K = J
         LA    5,9(0,5)         Increment J
*        C     
ENDSORT  L     13,4(0,13)       Point R13 at caller's save area.   
         LM    14,12,12(13)     Restore the registers. 
         BR    14               Return to the caller.
         LTORG         
SSAVE    DS    18F              Save area
STEMP    DS    9X
******************************************************
         XDUMP
         END   MAIN             End of source code file
/*
//FT05F001  DD  DSN=KC02314.AUTUMN19.CSCI360.HW8DATA,DISP=SHR
//