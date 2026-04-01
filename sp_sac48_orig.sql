DROP PROCEDURE sp_sac48;

CREATE PROCEDURE sp_sac48(
a_concepto 		CHAR(3)  DEFAULT "*",
a_comprobante 	CHAR(8)  DEFAULT "*",
a_notrx 		integer  default 0,
a_usuario 		CHAR(15) DEFAULT "*"
) RETURNING char(3),
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
		    integer;

DEFINE b_notrx          integer;
DEFINE b_tipo           char(2);
DEFINE b_comprobante	char(8);
DEFINE b_fecha          date;
DEFINE b_concepto       char(3);
DEFINE b_ccosto         char(3);
DEFINE b_descrip        char(50);
DEFINE b_monto          decimal(15,2);
DEFINE b_moneda         char(2);
DEFINE b_debito         decimal(15,2);
DEFINE b_credito        decimal(15,2);
DEFINE b_status         char(1);
DEFINE b_origen         char(3);
DEFINE b_usuario        char(15);
DEFINE c_notrx          integer;
DEFINE c_tipo           char(2);
DEFINE c_linea          integer;
DEFINE c_cuenta         char(12);
DEFINE c_ccosto         char(3);
DEFINE c_debito         decimal(15,2);
DEFINE c_credito        decimal(15,2);
DEFINE c_actlzdo        char(1);

DEFINE d_linea          integer;
DEFINE d_cuenta         char(12);
DEFINE d_auxiliar       char(5);
DEFINE d_debito         decimal(15,2);
DEFINE d_credito        decimal(15,2);
DEFINE total_cr         decimal(15,2);
DEFINE total_db         decimal(15,2);
DEFINE db               decimal(15,2);
DEFINE cr               decimal(15,2);
DEFINE l_cuenta     	char(12);
DEFINE l_nombre     	char(50);
DEFINE l_auxiliar   	char(1);
DEFINE l_des3       	char(1);
DEFINE l_des2       	char(1);
DEFINE l_desc_concepto 	char(30);
DEFINE l_desc_ter      	char(35); 
DEFINE l_desc1         	char(50); 
DEFINE l_desc2         	char(5); 
DEFINE _contador		integer;
 
SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT trx1_notrx,
        trx1_tipo,
        trx1_comprobante,
        trx1_fecha,
        trx1_concepto,
        trx1_ccosto,
        trx1_descrip,
        trx1_monto,
        trx1_moneda,
        trx1_debito,
        trx1_credito,
        trx1_status,
        trx1_origen,
        trx1_usuario
   INTO	b_notrx,
        b_tipo,
        b_comprobante,
        b_fecha,
        b_concepto,
        b_ccosto,
        b_descrip,
        b_monto,
        b_moneda,
        b_debito,
        b_credito,
        b_status,
        b_origen,
        b_usuario
   FROM cgltrx1
  WHERE trx1_concepto    MATCHES a_concepto
    AND trx1_comprobante MATCHES a_comprobante
    AND trx1_usuario     MATCHES a_usuario 
    AND trx1_notrx       =       a_notrx
  ORDER BY trx1_concepto
         
    SELECT con_descrip 
      INTO l_desc_concepto
      FROM cglconcepto
     WHERE con_codigo  = b_concepto;

    LET  l_des2  = "";
    LET  l_desc1 = "";

	-- Validaciones

    UPDATE cgltrx1
       SET trx1_status = "I"
     WHERE cgltrx1.trx1_notrx = b_notrx;

	 SELECT sum(trx2_debito),
            sum(trx2_credito)
       INTO total_db,
            total_cr
       FROM cgltrx2
      WHERE cgltrx2.trx2_notrx = b_notrx;

    IF total_db  <> total_cr THEN
       LET  l_des2  = "N";  
    END IF

    IF total_cr  <> b_monto THEN
      LET  l_des2  = "N"; 
    END IF

	if l_des2 = "N" then
      		LET  l_desc1 = "***** COMPROBANTE DESBALANCEADO *****"; 
	END IF

	LET l_desc_ter = '';
	LET d_auxiliar = '';	
	let _contador    = 0;

	FOREACH
	 SELECT trx2_notrx,
	        trx2_tipo,
	        trx2_cuenta,
            trx2_ccosto,
            trx2_debito,
            trx2_credito,
            trx2_actlzdo,
			trx2_linea
       INTO c_notrx,
            c_tipo,
            c_cuenta,
            c_ccosto,
            c_debito,
            c_credito,
            c_actlzdo,
			c_linea
       FROM cgltrx2
      WHERE cgltrx2.trx2_notrx = b_notrx
      ORDER BY trx2_linea

		let _contador = _contador + 1;

		SELECT cta_cuenta, 
		       cta_nombre, 
		       cta_auxiliar
		  INTO l_cuenta,
		       l_nombre,
		       l_auxiliar 
		  FROM cglcuentas
		 WHERE cta_cuenta = c_cuenta;

		IF c_debito IS NULL THEN
			LET c_debito= 0;
		END IF

		IF c_credito IS NULL THEN
			LET c_credito= 0;
		END IF

		LET  db      = 0.00;
		LET  cr      = 0.00;
		LET  l_desc2 = "";
		LET  l_des3  = "N";

		LET d_debito  = 0;
		LET d_credito = 0;

		RETURN b_concepto, 
			   l_desc_concepto, 
	           b_fecha, 
	           b_notrx,
	           b_comprobante, 
	           b_descrip, 
	           b_status, 
	           b_monto,
	           c_cuenta, 
	           l_nombre, 
	           c_debito, 
	           c_credito,
	           d_auxiliar, 
	           l_desc_ter, 
	           null, 
	           null,
	           l_desc1, 
	           l_desc2, 
	           _contador
		       WITH RESUME;

		IF l_auxiliar = "S" THEN 

	           SELECT SUM(trx3_debito), 
                	  SUM(trx3_credito) 
        	     INTO db, 
                  	  cr
	             FROM cgltrx3
	            WHERE cgltrx3.trx3_notrx     = c_notrx
	              AND cgltrx3.trx3_cuenta    = c_cuenta
        	      AND cgltrx3.trx3_lineatrx2 = c_linea;

			LET  l_des2 = "";

			IF db IS NULL THEN
				LET db = 0;
			END IF

		       	IF cr IS NULL THEN
				LET cr = 0;
	       		END IF

			IF c_debito <> db THEN
				LET  l_des2 = "N";
	       		END IF
			       	
			IF c_credito <> cr THEN
				LET  l_des2 = "N";
			END IF

			if l_des2 = "N" then
		      		LET l_desc1 = "***** AUXILIAR DESBALANCEADO *****"; 
			END IF

			FOREACH 
			 SELECT trx3_linea,
	        	    trx3_cuenta,
			        trx3_auxiliar,
			        trx3_debito,
			        trx3_credito
			   INTO d_linea,
			        d_cuenta,
			        d_auxiliar,
			        d_debito,
			        d_credito
			   FROM cgltrx3
			  WHERE trx3_notrx      = c_notrx
			    AND trx3_cuenta     = c_cuenta
			    AND trx3_lineatrx2  = c_linea
			  ORDER BY trx3_linea

				let _contador = _contador + 1;

				SELECT ter_descripcion 
				  INTO l_nombre 
				  FROM cglterceros
				 WHERE ter_codigo = d_auxiliar;

				LET l_desc_ter = d_auxiliar || " " || l_nombre;

			    RETURN b_concepto, 
			           l_desc_concepto, 
			           b_fecha, 
			           b_notrx,
			           b_comprobante, 
			           b_descrip, 
			           b_status, 
			           b_monto,
			           "", 
			           l_desc_ter, 
			           null, 
			           null,
			           d_auxiliar, 
			           l_desc_ter, 
			           d_debito, 
			           d_credito,
			           l_desc1, 
			           l_desc2, 
			           _contador 
			           WITH RESUME;
		
			END FOREACH

			let _contador = _contador + 1;

			LET l_nombre = "T O T A L E S ";
			let c_cuenta = "";

			if l_des2 = "N" then
		      	LET  l_nombre = trim(l_nombre) || "       *** AUXILIAR DESBALANCEADO *****"; 
				let c_cuenta = "**********";
			END IF

		    RETURN b_concepto, 
		           l_desc_concepto, 
		           b_fecha, 
		           b_notrx,
		           b_comprobante, 
		           b_descrip, 
		           b_status, 
		           b_monto,
		           c_cuenta, 
		           l_nombre, 
		           null, 
		           null,
		           d_auxiliar, 
		           l_desc_ter, 
		           db, 
		           cr,
		           l_desc1, 
		           l_desc2, 
		           _contador 
		           WITH RESUME;

		end if

	END FOREACH
      
    IF l_des2 = "N" THEN

       UPDATE cgltrx1 
          SET trx1_status = "E"
        WHERE cgltrx1.trx1_notrx = b_notrx;

    END IF

END FOREACH

END PROCEDURE;
