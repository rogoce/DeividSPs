CREATE OR REPLACE PROCEDURE "TTCORP"."CUENTA_RESGISTROS_TEMP" (p_id  OUT NUMBER, p_id1  OUT NUMBER)
IS
BEGIN
   DECLARE
      V_ID NUMBER(20) := 0;
      V_ID1 NUMBER(20) := 0;
      V_ID2 NUMBER(20) := 0;
   BEGIN
     
         BEGIN
            SELECT COUNT(*)
            INTO V_ID
            FROM TMP_CLIENTE
            WHERE IND_ACTUALIZADO <> 2;
            
            SELECT COUNT(*)
            INTO V_ID1
            FROM TMP_CUENTAS
            WHERE IND_ACTUALIZADO <> 2;

            P_ID := V_ID;
            P_ID1 := V_ID1;

           
         EXCEPTION
            WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE('ERROR EN EJECUCION: ' || SQLERRM(SQLCODE));
         END;
   END;
END;