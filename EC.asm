//KC03D86C JOB ,'Carly Dobie',MSGCLASS=H
//STEP1 EXEC PGM=ASSIST
//STEPLIB DD DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSIN DD *
********************************************
* Assignment Extra Credit
*
* NAME: Carly Dobie
*
* Register Usage:    
*
********************************************
MAIN     CSECT
         USING MAIN,15
READ     XREAD BUFFER,80      Read data from file
         BC    B'0100',DONE   End loop if at EOF
         MVC   TEMP(6),BUFFER Move first num into temp
         CLC   TEMP(6),=C'0'  See if first num is 0
         BNE   NZERO1         Continue if not 0
         MVC   RESULT(8),=P'0' Result is 0
         PACK  NUM2(4),BUFFER+8(4) Store second number
         B     PRINT          Print 
NZERO1   PACK  NUM1(4),BUFFER(6) Store first number
         MVC   TEMP(6),BUFFER+8 Move second num into temp
         CLC   TEMP(6),=C'0' See if second num is 0
         BNE   NZERO2         Continue if not zero
         MVC   RESULT(8),=P'0' Result is 0
         PACK  NUM2(4),BUFFER+8(6) Store second number
         B     PRINT          Print 
NZERO2   PACK  NUM2,BUFFER+8(6) Store second number
         ZAP   VARC(8),NUM1(4)   Copy NUM1 into VARC
         DP    VARC(8),NUM2(4) Divide VARC by NUM2
         MVC   VARD(4),VARC+4  VARD = remainder
         ZAP   RESULT(8),VARC(4)  Copy VARC into RESULT
         MP    RESULT(8),NUM2(4) RESULT = VARC * NUM2
         ZAP   AVARD(8),VARD(4)  Copy VARD into AVARD
         MP    AVARD(8),=PL1'1' AVARD = abs. val. AVARD
         ZAP   VARE(8),NUM2(4)   Copy NUM2 into VARE
         MP    VARE(8),=PL1'1' VARE = abs. val. VARE
         MP    AVARD(8),=PL2'2' AVARD = 2 * AVARD
LOOP     CP    AVARD+4(4),VARE+4(4) See if AVARD >= AVARE
         BNE   NA              If not equal
         BNH   NA              If AVARD is lower
         CP    NUM1(4),=PL1'0' See if NUM1 is 0
         BNH   ELSE            If NUM1 is less than 0
         AP    RESULT(8),=PL1'1' RESULT = RESULT + AVARE
ELSE     SP    RESULT(8),VARE(8) RESULT = RESULT = AVARE
         B     PRINT           Go to PRINT
NA       MVC   RESULT(8),=X'0' If AVARD is less than AVARE
         B     PRINT           Go to PRINT
PRINT    MVC   PNUM1(5),=X'4020202120' Format first number
         MVC   PNUM2(5),=X'4020202120' Format second number
         MVC   PRESULT(5),=X'4020202120' Format result
         ED    PNUM1(5),NUM1   Put first number on line
         ED    PNUM2(5),NUM2   Put second number on line
         ED    RESULT(5),RESULT Put result on line
         XPRNT LINE,20         Print line
         B     READ            Repeat loop until EOF
DONE     XDUMP 
         BR    14 
         LTORG
BUFFER   DS    80C
TEMP     DS    ZL6
VARC     DS    PL8
VARD     DS    PL4
AVARD    DS    PL8
VARE     DS    PL8
NUM1     DS    PL4
NUM2     DS    PL4
RESULT   DS    PL8
LINE     DC    CL1'0'
PNUM1    DS    5C
         DC    2C' '
PNUM2    DS    5C
         DC    2C' '
PRESULT  DS    5C                                      
         END   MAIN 
/*
//FT05F001  DD  DSN=KC02314.AUTUMN19.CSCI360.HWEXDATA,DISP=SHR
//