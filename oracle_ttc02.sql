DECLARE
  P_ID NUMBER;
  P_ID1 NUMBER;
  P_ID2 NUMBER;
  P_ID3 NUMBER;
  P_ID4 NUMBER;
  P_ID5 NUMBER;
  P_ID6 NUMBER;
  P_ID7 NUMBER;
  P_ID8 NUMBER;
  P_ID9 NUMBER;
  P_ID10 NUMBER;
  P_ID11 NUMBER;
  P_ID12 NUMBER;
  P_ID13 NUMBER;
  P_ID14 NUMBER;
  A_MOD NUMBER;
BEGIN
  A_MOD := 0;

  CUENTA_RESGISTROS_TEMP(
    P_ID => P_ID,
    P_ID1 => P_ID1,
    P_ID2 => P_ID2,
    P_ID3 => P_ID3,
    P_ID4 => P_ID4,
    P_ID5 => P_ID5,
    P_ID6 => P_ID6,
    P_ID7 => P_ID7,
    P_ID8 => P_ID8,
    P_ID9 => P_ID9,
    P_ID10 => P_ID10,
    P_ID11 => P_ID11,
    P_ID12 => P_ID12,
    P_ID13 => P_ID13,
    P_ID14 => P_ID14,
    A_MOD => A_MOD
  );
  /* Legacy output:*/  
DBMS_OUTPUT.PUT_LINE('TMP_CLIENTE = ' || P_ID);

  :P_ID := P_ID;
  /* Legacy output:*/ 
DBMS_OUTPUT.PUT_LINE('TMP_CUENTAS = ' || P_ID1);
 
  :P_ID1 := P_ID1;
  /* Legacy output:*/ 
DBMS_OUTPUT.PUT_LINE('TMP_PRODUCTOR = ' || P_ID2);
 
  :P_ID2 := P_ID2;
  /* Legacy output:*/  
DBMS_OUTPUT.PUT_LINE('TMP_REASEGURADORAS = ' || P_ID3);

  :P_ID3 := P_ID3;
  /* Legacy output:*/  
DBMS_OUTPUT.PUT_LINE('TMP_TERCEROS = ' || P_ID4);

  :P_ID4 := P_ID4;
  /* Legacy output: */
DBMS_OUTPUT.PUT_LINE('TMP_DET_MOVIM_TECNICO_PRI = ' || P_ID5);
 
  :P_ID5 := P_ID5;
  /* Legacy output:*/ 
DBMS_OUTPUT.PUT_LINE('TMP_DET_MOVIM_REASEGURO_PRI = ' || P_ID6);
 
  :P_ID6 := P_ID6;
  /* Legacy output: */ 
DBMS_OUTPUT.PUT_LINE('TMP_DET_REASEGURO_CARACT_PRI = ' || P_ID7);

  :P_ID7 := P_ID7;
  /* Legacy output: */ 
DBMS_OUTPUT.PUT_LINE('TMP_DET_MOVIM_TECNICO_SIN = ' || P_ID8);

  :P_ID8 := P_ID8;
  /* Legacy output:*/  
DBMS_OUTPUT.PUT_LINE('TMP_DET_MOVIM_REASEGURO_SIN = ' || P_ID9);

  :P_ID9 := P_ID9;
  /* Legacy output:*/ 
DBMS_OUTPUT.PUT_LINE('TMP_DET_REASEGURO_CARACT_SIN = ' || P_ID10);
 
  :P_ID10 := P_ID10;
  /* Legacy output:*/  
DBMS_OUTPUT.PUT_LINE('TMP_CHEQUES = ' || P_ID11);

  :P_ID11 := P_ID11;
  /* Legacy output:*/ 
DBMS_OUTPUT.PUT_LINE('TMP_CHEQUES_AUX = ' || P_ID12);
 
  :P_ID12 := P_ID12;
  /* Legacy output:*/ 
DBMS_OUTPUT.PUT_LINE('TMP_CGLRESUMEN = ' || P_ID13);
 
  :P_ID13 := P_ID13;
  /* Legacy output:*/ 
DBMS_OUTPUT.PUT_LINE('TMP_CGLRESUMEN1 = ' || P_ID14);
 
  :P_ID14 := P_ID14;
--rollback; 
END;
