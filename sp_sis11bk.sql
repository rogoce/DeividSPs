-- Procedimiento para la Conversion de Numeros a Letras 
--
-- Creado    : 01/09/1998 - Autor: Javier Nunez
-- Modificado: 01/09/1998 - Autor: Javier Nunez

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis11;

CREATE PROCEDURE "informix".sp_sis11(neto DECIMAL(16,2))
RETURNING CHAR(250);

BEGIN
  DEFINE sw      SMALLINT;
  DEFINE sw2     SMALLINT;
  DEFINE i       SMALLINT;
  DEFINE a       SMALLINT;
  DEFINE l       SMALLINT;
  DEFINE j       SMALLINT;
  DEFINE bandera SMALLINT;
  DEFINE residuo SMALLINT;
  DEFINE grupos  SMALLINT;
  DEFINE var_centavo   SMALLINT;
  DEFINE ch1     CHAR(1);
  DEFINE ch2     CHAR(1);
  DEFINE ch3     CHAR(1);
  DEFINE tem     CHAR(16);
  DEFINE centavo CHAR(2);
  DEFINE total   CHAR(16);
  DEFINE val_tem INTEGER;
  DEFINE val_cen CHAR(16);
  DEFINE val_let CHAR(250);
  DEFINE _negativo decimal(16,2);

--SET DEBUG FILE TO "c:\sp_sis11.trc";
--trace on;
  SET ISOLATION TO DIRTY READ;

  LET val_let = "";
  LET val_cen = "";
  LET var_centavo = 0;
  LET _negativo = neto;
  if neto < 0 then
	 let neto = abs(neto);
  end if
  LET total = neto;
  LET val_tem = neto; 

--Condicion para poder calcular Centavos
  IF val_tem = 0 THEN
     LET var_centavo = 1;
     LET val_tem = total[3,4];
     LET val_let = "CERO DOLARES CON " || val_tem || "/100";
     RETURN (val_let);
  END IF
  LET total = val_tem;

  LET sw  = 0;
  LET sw2 = 0;
  LET i = 1;
  LET l = LENGTH(total);
  LET val_cen = neto;

  LET centavo = " ";

  IF l = 1 THEN
     LET centavo = val_cen[3,4];
  ELIF l = 2 THEN
     LET centavo = val_cen[4,5];
  ELIF l = 3 THEN
     LET centavo = val_cen[5,6];
  ELIF l = 4 THEN
     LET centavo = val_cen[6,7];
  ELIF l = 5 THEN
     LET centavo = val_cen[7,8];
  ELIF l = 6 THEN
     LET centavo = val_cen[8,9];
  ELIF l = 7 THEN
     LET centavo = val_cen[9,10];
  ELIF l = 8 THEN
     LET centavo = val_cen[10,11];
  ELIF l = 9 THEN
     LET centavo = val_cen[11,12];
  ELIF l = 10 THEN
     LET centavo = val_cen[12,13];
  ELIF l = 11 THEN
     LET centavo = val_cen[13,14];
  ELIF l = 12 THEN
     LET centavo = val_cen[14,15];
  ELIF l = 13 THEN
     LET centavo = val_cen[15,16];
  END IF
  LET tem = l/3;
  LET tem = tem[1] ;
  LET residuo = l - (tem * 3);
  LET grupos = tem;
  IF residuo <> 0 THEN
     LET grupos = grupos + 1;
  END IF

  LET a = 0;
  LET ch1 = "";
  LET ch2 = "";
  LET ch3 = "";

  WHILE (grupos > 0)
     LET grupos = grupos - 1;
     LET bandera = 0;
-----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
-----*-*   Residuo = 0
-----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
     IF residuo = 0 OR sw = 1  THEN
        IF i = 1 THEN
           LET ch1 = total[1];
           LET ch2 = total[2];
           LET ch3 = total[3];
           LET i = i + 1;
        ELIF i = 2 THEN
           LET ch1 = total[2];
           LET ch2 = total[3];
           LET ch3 = total[4];
           LET i = i + 1;
        ELIF i = 3 THEN
           LET ch1 = total[3];
           LET ch2 = total[4];
           LET ch3 = total[5];
           LET i = i + 1;
        ELIF i = 4 THEN
           LET ch1 = total[4];
           LET ch2 = total[5];
           LET ch3 = total[6];
           LET i = i + 1;
        ELIF i = 5 THEN
           LET ch1 = total[5];
           LET ch2 = total[6];
           LET ch3 = total[7];
           LET i = i + 1;
        ELIF i = 6 THEN
           LET ch1 = total[6];
           LET ch2 = total[7];
           LET ch3 = total[8];
           LET i = i + 1;
        ELIF i = 7 THEN
           LET ch1 = total[7];
           LET ch2 = total[8];
           LET ch3 = total[9];
           LET i = i + 1;
        ELIF i = 8 THEN
           LET ch1 = total[8];
           LET ch2 = total[9];
           LET ch3 = total[10];
           LET i = i + 1;
        ELIF i = 9 THEN
           LET ch1 = total[9];
           LET ch2 = total[10];
           LET ch3 = total[11];
           LET i = i + 1;
        ELIF i = 10 THEN
           LET ch1 = total[10];
           LET ch2 = total[11];
           LET ch3 = total[12];
           LET i = i + 1;
        ELIF i = 11 THEN
           LET ch1 = total[11];
           LET ch2 = total[12];
           LET ch3 = total[13];
           LET i = i + 1;
        ELIF i = 12 THEN
           LET ch1 = total[12];
           LET ch2 = total[13];
           LET ch3 = total[14];
           LET i = i + 1;
        END IF
        LET sw = 1;
        LET sw2 = 1;

        IF ch1 = "1" THEN
           IF (ch2 != "0") OR ( ch3 != "0") THEN
              LET val_let = TRIM(val_let) || " CIENTO ";
           ELSE
              LET val_let = TRIM(val_let) || " CIEN " ;
           END IF
        ELIF ch1 = "2" THEN
           LET val_let = TRIM(val_let) || " DOSCIENTOS ";
        ELIF ch1 = "3" THEN
           LET val_let = TRIM(val_let) || " TRESCIENTOS " ;
        ELIF ch1 = "4" THEN
           LET val_let = TRIM(val_let) || " CUATROCIENTOS " ;
        ELIF ch1 = "5" THEN
           LET val_let = TRIM(val_let) || " QUINIENTOS " ;
        ELIF ch1 = "6" THEN
           LET val_let = TRIM(val_let) || " SEISCIENTOS " ;
        ELIF ch1 = "7" THEN
           LET val_let = TRIM(val_let) || " SETECIENTOS " ;
        ELIF ch1 = "8" THEN
           LET val_let = TRIM(val_let) || " OCHOCIENTOS " ;
        ELIF ch1 = "9" THEN
           LET val_let = TRIM(val_let) || " NOVECIENTOS " ;
        END IF
     END IF
-----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
-----*-*   Residuo = 2
-----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
     IF (residuo = 2) OR (sw = 1) THEN
--      IF sw2 = 0 THEN 
--         LET sw2 = 1;
           IF i = 1 THEN
              LET ch2 = total[1];
              LET ch3 = total[2];
              LET i = i + 1;
           ELIF i = 2 THEN
              LET ch2 = total[2];
              LET ch3 = total[3];
              LET i = i + 1;
           ELIF i = 3 THEN
              LET ch2 = total[3];
              LET ch3 = total[4];
              LET i = i + 1;
           ELIF i = 4 THEN
              LET ch2 = total[4];
              LET ch3 = total[5];
              LET i = i + 1;
           ELIF i = 5 THEN
              LET ch2 = total[5];
              LET ch3 = total[6];
              LET i = i + 1;
           ELIF i = 6 THEN
              LET ch2 = total[6];
              LET ch3 = total[7];
              LET i = i + 1;
           ELIF i = 7 THEN
              LET ch2 = total[7];
              LET ch3 = total[8];
              LET i = i + 1;
           ELIF i = 8 THEN
              LET ch2 = total[8];
              LET ch3 = total[9];
              LET i = i + 1;
           ELIF i = 9 THEN
              LET ch2 = total[9];
              LET ch3 = total[10];
              LET i = i + 1;
           ELIF i = 10 THEN
              LET ch2 = total[10];
              LET ch3 = total[11];
              LET i = i + 1;
           ELIF i = 11 THEN
              LET ch2 = total[11];
              LET ch3 = total[12];
              LET i = i + 1;
           ELIF i = 12 THEN
              LET ch2 = total[12];
              LET ch3 = total[13];
              LET i = i + 1;
           ELIF i = 13 THEN
              LET ch2 = total[13];
              LET ch3 = total[14];
              LET i = i + 1;
           END IF
--      END IF

        LET sw = 1 ;
        IF ch2 = "1"  THEN
           LET bandera = 1 ;
           LET i = i + 1 ;
           IF ch3 = "0" THEN
              LET val_let = TRIM(val_let) || " DIEZ " ;
           ELIF ch3 = "1" THEN
              LET val_let = TRIM(val_let) || " ONCE " ;
           ELIF ch3 = "2" THEN
              LET val_let = TRIM(val_let) || " DOCE " ;
           ELIF ch3 = "3" THEN
              LET val_let = TRIM(val_let) || " TRECE " ;
           ELIF ch3 = "4" THEN
              LET val_let = TRIM(val_let) || " CATORCE " ;
           ELIF ch3 = "5" THEN
              LET val_let = TRIM(val_let) || " QUINCE " ;
           ELIF ch3 = "6" THEN 
              LET val_let = TRIM(val_let) || " DIECISEIS " ;
           ELIF ch3 = "7" THEN 
              LET val_let = TRIM(val_let) || " DIECISIETE " ;
           ELIF ch3 = "8" THEN
              LET val_let = TRIM(val_let) || " DIECIOCHO " ;
           ELIF ch3 = "9" THEN 
              LET val_let = TRIM(val_let) || " DIECINUEVE " ;
           END IF
        ELIF ch2 = "2" THEN
           IF ch3 <> "0" THEN
              LET val_let = TRIM(val_let) || " VEINTI" ;
           ELSE 
              LET val_let = TRIM(val_let) || " VEINTE " ;
           END IF
        ELIF ch2 = "3" THEN
           LET val_let = TRIM(val_let) || " TREINTA " ;
        ELIF ch2 = "4" THEN
           LET val_let = TRIM(val_let) || " CUARENTA " ;
        ELIF ch2 = "5" THEN
           LET val_let = TRIM(val_let) || " CINCUENTA " ;
        ELIF ch2 = "6" THEN
           LET val_let = TRIM(val_let) || " SESENTA " ;
        ELIF ch2 = "7" THEN
           LET val_let = TRIM(val_let) || " SETENTA " ;
        ELIF ch2 = "8" THEN
           LET val_let = TRIM(val_let) || " OCHENTA " ;
        ELIF ch2 = "9" THEN
           LET val_let = TRIM(val_let) || " NOVENTA " ;
        END IF
     END IF
-----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
-----*-*   Residuo = 1
-----*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
     IF (residuo = 1) OR (sw = 1) THEN
--      IF sw2 = 0 THEN
        IF bandera != 1 THEN
           IF i = 1 THEN
              LET ch3 = total[1];
              LET i = i + 1;
           ELIF i = 2 THEN
              LET ch3 = total[2];
              LET i = i + 1;
           ELIF i = 3 THEN
              LET ch3 = total[3];
              LET i = i + 1;
           ELIF i = 4 THEN
              LET ch3 = total[4];
              LET i = i + 1;
           ELIF i = 5 THEN
              LET ch3 = total[5];
              LET i = i + 1;
           ELIF i = 6 THEN
              LET ch3 = total[6];
              LET i = i + 1;
           ELIF i = 7 THEN
              LET ch3 = total[7];
              LET i = i + 1;
           ELIF i = 8 THEN
              LET ch3 = total[8];
              LET i = i + 1;
           ELIF i = 9 THEN
              LET ch3 = total[9];
              LET i = i + 1;
           ELIF i = 10 THEN
              LET ch3 = total[10];
              LET i = i + 1;
           ELIF i = 11 THEN
              LET ch3 = total[11];
              LET i = i + 1;
           ELIF i = 12 THEN
              LET ch3 = total[12];
              LET i = i + 1;
           ELIF i = 13 THEN
              LET ch3 = total[13];
              LET i = i + 1;
           ELIF i = 14 THEN
              LET ch3 = total[14];
              LET i = i + 1;
           END IF
--      END IF

--         IF sw2 = 1 THEN
--            LET i = i + 1;
--         END IF
           IF (ch2 != "1") AND ((ch2 != "0") AND ch2 != "2") AND 
              (ch3 != "0") AND (sw = 1) THEN
              LET val_let = TRIM(val_let) ||" Y " ;
           END IF
           LET sw = 1 ;
              IF ch3 = "1" THEN
                 IF ch2 = "2" THEN
                    LET val_let = TRIM(val_let) || "UN " ;
                 ELSE
                    LET val_let = TRIM(val_let) || " UN " ;
                 END IF
              ELIF ch3 = "2" THEN
                 IF ch2 = "2" THEN
                    LET val_let = TRIM(val_let) || "DOS " ;
                 ELSE
                    LET val_let = TRIM(val_let) || " DOS " ;
                 END IF
              ELIF ch3 = "3" THEN
                 IF ch2 = "2" THEN
                    LET val_let = TRIM(val_let) || "TRES " ;
                 ELSE
                    LET val_let = TRIM(val_let) || " TRES " ;
                 END IF
              ELIF ch3 = "4" THEN
                 IF ch2 = "2" THEN
                    LET val_let = TRIM(val_let) || "CUATRO " ;
                 ELSE
                    LET val_let = TRIM(val_let) || " CUATRO " ;
                 END IF
              ELIF ch3 = "5" THEN
                 IF ch2 = "2" THEN
                    LET val_let = TRIM(val_let) || "CINCO " ;
                 ELSE
                    LET val_let = TRIM(val_let) || " CINCO " ;
                 END IF
              ELIF ch3 = "6" THEN
                 IF ch2 = "2" THEN
                    LET val_let = TRIM(val_let) || "SEIS " ;
                 ELSE
                    LET val_let = TRIM(val_let) || " SEIS " ;
                 END IF
              ELIF ch3 = "7" THEN
                 IF ch2 = "2" THEN
                    LET val_let = TRIM(val_let) || "SIETE " ;
                 ELSE
                    LET val_let = TRIM(val_let) || " SIETE " ;
                 END IF
              ELIF ch3 = "8" THEN
                 IF ch2 = "2" THEN
                    LET val_let = TRIM(val_let) || "OCHO " ;
                 ELSE
                    LET val_let = TRIM(val_let) || " OCHO " ;
                 END IF
              ELIF ch3 = "9" THEN
                 IF ch2 = "2" THEN
                    LET val_let = TRIM(val_let) || "NUEVE " ;
                 ELSE
                    LET val_let = TRIM(val_let) || " NUEVE " ;
                 END IF
              END IF
           END IF
     END IF
     IF (ch1 != "0") OR (ch2 != "0") OR (ch3 != "0") THEN
           IF grupos = 1 THEN
              LET val_let = TRIM(val_let) || " MIL " ;
           ELIF grupos = 2 THEN
              IF ch3 = "1" AND residuo = 1 THEN
                 LET val_let = TRIM(val_let) || " MILLON ";
              ELSE
                 LET val_let = TRIM(val_let) || " MILLONES " ;
              END IF 
              LET tem = neto;
              IF tem[2,7] = "000000" THEN
                 LET val_let = TRIM(val_let) || " DE ";
              END IF
           ELIF grupos = 3 THEN
              LET val_let = TRIM(val_let) || " MIL MILLONES " ;
              LET tem = neto;
              IF tem[2,10] = "000000000" THEN
                 LET val_let = TRIM(val_let) || " DE ";
              END IF
           ELIF grupos = 4 THEN
              IF ch3 = "1" THEN
                 LET val_let = TRIM(val_let) || " BILLON ";
              ELSE
                 LET val_let = TRIM(val_let) || " BILLONES " ;
              END IF
              LET tem = neto  ;
              IF tem[2,13] = "000000000000" THEN
                 LET val_let = TRIM(val_let) || " DE ";
              END IF
        END IF
     END IF
  END WHILE
  LET total = neto ;
 IF var_centavo = 0 THEN
   IF val_tem = 1 THEN
     LET val_let = TRIM(val_let) || " DOLAR CON " || TRIM(centavo) || "/100";
   ELSE
    LET val_let = TRIM(val_let) || " DOLARES CON " || TRIM(centavo) || "/100";
   END IF
 ELSE
   LET val_let = TRIM(val_let) || " /100";
 END IF
 if _negativo < 0 then
	let val_let = 'MENOS ' || val_let; 
 end if
RETURN (val_let);
END
END PROCEDURE;
