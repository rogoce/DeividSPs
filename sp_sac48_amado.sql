--DROP PROCEDURE sp_sac48;

CREATE PROCEDURE sp_sac48(a_concepto CHAR(03) DEFAULT "*",a_comprobante CHAR(8) DEFAULT "*",a_notrx integer ,a_fecha_ini DATE ,a_fecha_fin DATE ,a_usuario CHAR(15) DEFAULT "*") RETURNING  char(3),
	       char(30),
               date,
               integer,
               char(8),
               char(50),
               char(1),
               decimal(15,2),
               char(12),
               char(50),
               decimal(15,2),
               decimal(15,2),
               char(5),
               char(35),
               decimal(15,2),
               decimal(15,2),
               char(50),
               char(5),
			   integer,
			   char(1);

DEFINE b_notrx           integer;
DEFINE b_tipo            char(2);
DEFINE b_comprobante     char(8);
DEFINE b_fecha           date;
DEFINE b_concepto        char(3);
DEFINE b_ccosto          char(3);
DEFINE b_descrip         char(50);
DEFINE b_monto           decimal(15,2);
DEFINE b_moneda          char(2);
DEFINE b_debito          decimal(15,2);
DEFINE b_credito         decimal(15,2);
DEFINE b_status          char(1);
DEFINE b_origen          char(3);
DEFINE b_usuario         char(15);
DEFINE c_notrx           integer;
DEFINE c_tipo            char(2);
DEFINE c_linea           integer;
DEFINE c_cuenta          char(12);
DEFINE c_ccosto          char(3);
DEFINE c_debito          decimal(15,2);
DEFINE c_credito         decimal(15,2);
DEFINE c_actlzdo         char(1);

DEFINE d_linea           integer;
DEFINE d_cuenta          char(12);
DEFINE d_auxiliar        char(5);
DEFINE d_debito          decimal(15,2);
DEFINE d_credito         decimal(15,2);
DEFINE total_cr          decimal(15,2);
DEFINE total_db          decimal(15,2);
DEFINE db                decimal(15,2);
DEFINE cr                decimal(15,2);
DEFINE  l_cuenta     char(12);
DEFINE  l_nombre     char(50);
DEFINE  l_auxiliar   char(1);
DEFINE  l_des3       char(1);
DEFINE  l_des2       char(1);
DEFINE  l_desc_concepto char(30);
DEFINE  l_desc_ter      char(35); 
DEFINE  l_desc1         char(50); 
DEFINE  l_desc2         char(5); 
 
 

------------------------------------------------------
SET ISOLATION TO DIRTY READ;
FOREACH 
 SELECT trx1_notrx,trx1_tipo,trx1_comprobante,trx1_fecha,
        trx1_concepto,trx1_ccosto,trx1_descrip,trx1_monto,
        trx1_moneda,trx1_debito,trx1_credito,trx1_status,
        trx1_origen,trx1_usuario
   INTO	
        b_notrx,b_tipo,b_comprobante,b_fecha,
        b_concepto,b_ccosto,b_descrip,b_monto,
        b_moneda,b_debito,b_credito,b_status,
        b_origen,b_usuario
   FROM cgltrx1
  WHERE trx1_concepto MATCHES a_concepto
    AND trx1_comprobante MATCHES a_comprobante
    AND trx1_notrx >=  a_notrx
    AND trx1_fecha BETWEEN a_fecha_ini AND a_fecha_fin
    AND trx1_usuario MATCHES a_usuario 
  ORDER BY trx1_concepto
         
        LET  l_des2 = "N";
        LET  l_desc1 = "";

        UPDATE cgltrx1
           SET trx1_status = "I"
         WHERE cgltrx1.trx1_notrx = b_notrx;

        SELECT con_descrip INTO l_desc_concepto
          FROM cglconcepto
         WHERE con_codigo  = b_concepto;


	LET total_db = 0.00;
    LET total_cr = 0.00;
	LET l_desc_ter = '';
	LET d_auxiliar = '';	

	FOREACH
	  SELECT trx2_notrx,trx2_tipo,trx2_linea,trx2_cuenta,
                 trx2_ccosto,trx2_debito,trx2_credito,trx2_actlzdo
            INTO c_notrx,c_tipo,c_linea,c_cuenta,
                 c_ccosto,c_debito,c_credito,c_actlzdo
            FROM cgltrx2
           WHERE cgltrx2.trx2_notrx  = b_notrx
           ORDER BY trx2_linea

          LET  l_desc2 = "";

          IF c_debito IS NULL THEN
             LET c_debito= 0;
          END IF

          IF c_credito IS NULL THEN
             LET c_credito= 0;
          END IF

           LET total_db = total_db + c_debito;
           LET total_cr = total_cr + c_credito;
           LET  db     = 0.00;
           LET  cr     = 0.00;
           LET  l_des3 = "N";

            SELECT cta_cuenta, cta_nombre, cta_auxiliar
              INTO l_cuenta,l_nombre,l_auxiliar 
              FROM  cglcuentas
             WHERE cta_cuenta  = c_cuenta;
            
           LET d_debito  = 0;
           LET d_credito = 0;

               RETURN b_concepto, l_desc_concepto, b_fecha, b_notrx,
                      b_comprobante, b_descrip, b_status, b_monto,
                      c_cuenta, l_nombre, c_debito, c_credito,
                      d_auxiliar, l_desc_ter, d_debito, d_credito,
                      l_desc1, l_desc2, c_linea, l_auxiliar  WITH RESUME;

           IF l_auxiliar = "S" THEN 
               SELECT SUM(trx3_debito), SUM(trx3_credito) INTO db, cr
                 FROM cgltrx3
                WHERE cgltrx3.trx3_notrx     = c_notrx
                  AND cgltrx3.trx3_cuenta    = c_cuenta
                  AND cgltrx3.trx3_lineatrx2 = c_linea;

               IF db IS NULL THEN
                  LET db = 0;
               END IF

               IF cr IS NULL THEN
                  LET cr = 0;
               END IF

               IF c_debito <> db THEN
                  LET  l_des3 = "S";
                  LET  l_desc1 = "COMPROBANTE DESBALANCEADO"; 
                  LET  l_desc2 = "*****";
               END IF
               IF c_credito <> cr THEN
                  LET  l_des3 = "S";
                  LET  l_desc1 = "COMPROBANTE DESBALANCEADO"; 
                  LET  l_desc2 = "*****";
               END IF

              FOREACH 
                SELECT trx3_linea,trx3_cuenta,trx3_auxiliar,trx3_debito,trx3_credito
                  INTO d_linea,c_cuenta,l_nombre,c_debito,c_credito
                  FROM cgltrx3
                 WHERE trx3_notrx      = c_notrx
                   AND trx3_cuenta     = c_cuenta
                   AND trx3_lineatrx2  = c_linea
                ORDER BY trx3_linea

                   LET l_desc_ter = '';

                   SELECT ter_descripcion INTO l_desc_ter FROM cglterceros
                    WHERE ter_codigo = d_auxiliar;

                   IF l_desc_ter IS NULL THEN
						LET l_desc_ter = '';	
				   END IF

                   RETURN b_concepto, l_desc_concepto, b_fecha, b_notrx,
                          b_comprobante, b_descrip, b_status, b_monto,
                          c_cuenta, l_nombre, c_debito, c_credito,
                          d_auxiliar, l_desc_ter, d_debito, d_credito,
                          l_desc1, l_desc2, d_linea, l_auxiliar WITH RESUME;
		
              END FOREACH
              IF l_des3 = "S" THEN
                 UPDATE cgltrx1 SET trx1_status = "E"
                  WHERE cgltrx1.trx1_notrx = b_notrx;
              END IF
           END IF
	END FOREACH
      
        IF total_db  <> total_cr THEN
           LET  l_des2 = "N";  
           LET  l_desc1 = "COMPROBANTE DESBALANCEADO"; 
        END IF
 
        IF total_cr  <> b_monto THEN
          LET  l_des2 = "N"; 
          LET  l_desc1 = "COMPROBANTE DESBALANCEADO"; 
        END IF

        IF l_des2 = "N" THEN
           UPDATE cgltrx1 SET trx1_status = "E"
            WHERE cgltrx1.trx1_notrx = b_notrx;
        END IF

        RETURN b_concepto, l_desc_concepto, b_fecha, b_notrx,
               b_comprobante, b_descrip, b_status, b_monto,
               c_cuenta, l_nombre, c_debito, c_credito,
               d_auxiliar, l_desc_ter, d_debito, d_credito,
               l_desc1, l_desc2, 0, l_auxiliar WITH RESUME;

END FOREACH


	    



END PROCEDURE;
