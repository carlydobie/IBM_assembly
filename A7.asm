//KC03D86C JOB ,'Carly Dobie',MSGCLASS=H
//STEP1 EXEC PGM=ASSIST
//STEPLIB DD DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSIN DD *
********************************************
* Assignment 7
*
* NAME: Carly Dobie
********************************************
ENTRY   DSECT
ID      DS    F
LNAME   DS    12C
FNAME   DS    10C
SCORE1  DS    PL2
SCORE2  DS    PL2
SCORE3  DS    PL2
********************************************
*
* Register Usage in executable code:
*   1        Parameter List
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
         L     15,=V(TRANS)
         BALR  14,15
         L     13,4(,13)
         LM    14,15,12(13)
         LM    1,12,24(13)
         BR    14
         LTORG
MSAVE    DS    18F
         ORG   MAIN+((*-MAIN+31)/32)*32
TABLE    DS    60CL32      
ENDTABLE DS    0H               Marks the end of TABLE
EOT      DC    A(TABLE)         Address of 1st unused entry in TABLE
BUFFER   DS    80C              Input storage area
PARAMS   DC    A(TABLE)         Parameter list
         DC    A(EOT)
         DC    A(BUFFER)
********************************************
*
* Register Usage in BUILD:
*   1        TRT: address of found character
*   2        (last 2 bytes) TRT: the value
*   3        Parameter list
*   4        Address of TABLE
*   5        Address of EOT
*   6        Address of BUFFER
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
         LM    4,6,0(1)         Load parameter list into 2-4
         USING ENTRY,4          Format for table
READ     XREAD 0(0,6),80        Read line of input
         BC    B'0100',ENDREAD  End loop if at EOF
         MVC   LNAME(10),0(4)   Store client's last name      
         CLC   LNAME(8),=CL8'DONOTPUT' See if input is the delimiter
         BE    ENDREAD          End loop if delimeter is reached
         MVC   FNAME(10),12(4)  Store client's first name
         MVC   ID(8),24(4)      Store client's ID
         MVC   TEMP(7),34(4) 
         PACK  BALANCE(4),34(7,4) Store balance
         MVC   SIGN(1),41(4)    Store the sign 
         CLC   SIGN,=CL1'+'     Check sign of balance
         BE    POS              If positive, skip next step      
         MP    BALANCE(4),=PL1'-1' If negative, multiply by -1
POS      LA    2,32(0,2)        Advance to next slot in TABLE
         B     READ             Repeat loop
ENDREAD  ST    2,0(0,3)         Store address of 1st unused entry 
         L     13,4(0,13)       Point R13 at caller's save area.              
         LM    14,12,12(13)     Restore the registers. 
         BR    14               Return to the caller.
         LTORG
TEMP     DS    CL7
SIGN     DS    CL1
BSAVE    DS    18F              Save area for BUILD
********************************************
*
* Register Usage in PRINT:
*        
*   1        Parameter list
*   2        Address of TABLE
*   3        Address of EOT
*   8        Counter for table entries
*  10        Page number
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
         LM    2,3,0(1)         Unload the parameters
         USING ENTRY,2          Format for table
         SR    10,10            Clear the page counter
         ZAP   PNUM(3),=PL1'0' Initialize page number
PHEAD    CR    2,3              See if at end of table
         BE    ENDPRINT         Stop printing at end of table
         SR    8,8              Clear the entry counter
         AP    PNUM(3),=PL1'1'  Increment page number
         XDUMP
         MVC   PAGE(3),=X'402120' Format page number for printing
         ED    PAGE(3),PNUM     Apply formatting to page number
         XPRNT HEAD,54          Print page header
PLINE    MVI   LINE+1,C' '      Clear output line
         MVC   LINE+2(84),LINE+1
         MVC   PLNAME(10),LNAME  Store FNAME for printing
         MVC   PFNAME(10),FNAME  Store LNAME for printing
         MVC   PID(8),ID         Store ID for printing
         MVC   PBAL(10),=X'4020206B2021204B2020' Format BAL
         LA    1,PBAL+6          Initialize reg 1 to use EDMK
         EDMK  PBAL(10),BALANCE  Store BAL for printing
         XDUMP
         XPRNT LINE,39           Print LINE
         A     8,=F'1'           Increment entry counter
         C     8,=F'15'          Check if 15 entries on page
         BE    PHEAD             Start next page if 15 entries
         LA    2,32(0,2)         Advance table pointer
         B     PLINE             Repeat line loop
* All values in table have been printed.
ENDPRINT L     13,4(0,13)        Point R13 at caller's save area.              
         LM    14,12,12(13)      Restore the registers. 
         BR    14                Return to the caller.
         LTORG
PSAVE    DS    18F              Save area for PRINT
********************************************
*
* Register Usage in TRANS:
* 
*
******************************************** 
TRANS    CSECT
         STM   14,12,12(13)     Save the registers
         LR    12,15            Establish 12 as the        
         USING TRANS,12         base register 
         LA    14,TSAVE         Point R14 at TSAVE
         ST    13,4(0,14)       Save the forward pointer
         ST    14,8(0,13)       Save the backward pointer
         LR    13,14            Point R13 at TSAVE
         LM    2,4,0(1)         Unload the parameters
ENDTLOOP LM    14,12,12(13)     Restore the registers. 
         BR    14               Return to the caller.
         LTORG         
TSAVE    DS    18F
******************************************************
         XDUMP
         END   MAIN             End of source code file
/*
//FT05F001  DD  DSN=KC02314.AUTUMN19.CSCI360.HW7DATA,DISP=SHR
//