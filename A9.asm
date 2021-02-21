//KC03D86C JOB ,'Carly Dobie',MSGCLASS=H
//STEP1   EXEC  PGM=ASSIST,PARM='MACRO=H'
//STEPLIB   DD  DSN=KC02293.ASSIST.LOADLIB,DISP=SHR
//SYSPRINT  DD  SYSOUT=*
//SYSIN     DD  * 
********************************************
* Assignment 9
*
* NAME: Carly Dobie
********************************************
********************************************
*
* STRLEN MACRO finds the length of a given string
*
* Register Usage in STRLEN MACRO:    
*   2        Pointer to string &STR
*   3        Length counter
*
******************************************** 
         MACRO 
         STRLEN &STR,&LEN          Local variable &L
         AIF    ('&STR' EQ '').ERROR1 Check params
         AIF    ('&LEN' EQ '').ERROR1 "
         STM     2,3,S&SYSNDX   Save register 2-3
         B      NEXT&SYSNDX     Continue after save area
S&SYSNDX DS     2F              Save area
NEXT&SYSNDX LA     2,&STR       Reg 2 points to string
         SR     3,3             Initialize register 3
.LOOP1   CLI    0(2),X'00'      End of string?
         BE     E&SYSNDX        If so, end macro
         A      3,=F'1'         Add 1 to length
         LA     2,1(0,2)        Move to next character
         AGO    .LOOP1          Repeat loop
E&SYSNDX ST     3,&LEN          Store length
         LM     2,3,S&SYSNDX    Restore registers 
         MEXIT                  Exit macro
.ERROR1  MNOTE  'Missing parameter' Error message
         MEND                   End of macro
********************************************
********************************************
*
* PROD MACRO finds the product of a list of fullwords
*
* Register Usage in PROD MACRO:    
*   2        Product of fullwords
*   3        "
*
******************************************** 
         MACRO
         PROD   &RESULT,&LIST
         LCLA   &PLEN           Local variable &PLEN
&PLEN    SETA   N'&LIST         &PLEN = length of list
         AIF    ('&RESULT' EQ '').ERROR2 If &RESULT is missing
         AIF    ('&LIST' EQ '').ERROR2   If &LIST is missing
         AIF    ('&LIST' EQ '()').ERROR2 If &LIST is empty
         STM    2,3,PSAVE&SYSNDX    Save registers 1 and 2
         AGO    .CONT2          Continue after save area
PSAVE&SYSNDX   DS     2F        Save area
.CONT2   AIF    ('&PLEN' EQ '1').ENDL2 If only one fullword
         L      2,&LIST(&PLEN)  Load fullword into register
.LOOP2   ANOP
&PLEN    SETA   &PLEN-1         Decrement length
         AIF    ('&PLEN' EQ '0').ENDL2 End if list length = 0
         M      2,&LIST(&PLEN)  Multiply values
         AGO    .LOOP2          Repeat loop
.ENDL2   ST     2,&RESULT       Store product in &RESULT
         LM     2,3,PSAVE&SYSNDX    Restore registers  
         MEXIT
.ERROR2  MNOTE  'Missing parameter'
         MEND                   End of macro
/*
//          DD DSN=KC02314.AUTUMN19.CSCI360.HW9.DRIVER,DISP=SHR
//FT05F001  DD DUMMY
//FT06F001  DD SYSOUT=*
//