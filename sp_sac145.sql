--**********************************
-- Procedimiento que genera el reporte de Comprobantes actualizados
-- Creado : Henry Giron Fecha : 11/01/2010
-- d_sac_sp_sac145_dw1
-- *********************************
drop procedure sp_sac145;

create procedure sp_sac145(a_db char(18), a_notrx integer, a_comp char(8)) 
returning	char(3),
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
			char(50);

define b_notrx          integer;
define b_tipo           char(2);
define b_comprobante	char(8);
define b_fecha          date;
define b_concepto       char(3);
define b_ccosto         char(3);
define b_descrip        char(50);
define b_monto          decimal(15,2);
define b_moneda         char(2);
define b_debito         decimal(15,2);
define b_credito        decimal(15,2);
define b_status         char(1);
define b_origen         char(3);
define b_usuario        char(15);
define c_notrx          integer;
define c_tipo           char(2);
define c_linea          integer;
define c_cuenta         char(12);
define c_ccosto         char(3);
define c_debito         decimal(15,2);
define c_credito        decimal(15,2);
define c_actlzdo        char(1);

define d_linea          integer;
define d_cuenta         char(12);
define d_auxiliar       char(5);
define d_debito         decimal(15,2);
define d_credito        decimal(15,2);
define total_cr         decimal(15,2);
define total_db         decimal(15,2);
define db               decimal(15,2);
define cr               decimal(15,2);
define l_cuenta     	char(12);
define l_nombre     	char(50);
define l_auxiliar   	char(1);
define l_des3       	char(1);
define l_des2       	char(1);
define l_desc_concepto 	char(30);
define l_desc_ter      	char(35); 
define l_desc1         	char(50); 
define l_desc2         	char(5); 
define _contador		integer;
define _cia_nom			char(50);

define _error			integer;
define _error_desc		char(50);
 
SET ISOLATION TO DIRTY READ;

call sp_sac144(a_db, a_notrx, a_comp ) returning _error, _error_desc;

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = a_db;
 
FOREACH 

  SELECT res_notrx,
         res_tipo_resumen,
         res_comprobante,
         res_fechatrx,
         res_tipcomp,
--         res_ccosto,
         res_descripcion,
         sum(res_debito),
         res_moneda,
         sum(res_debito),
         sum(res_credito),
         res_status,
         res_origen,
         res_usuariocap
    INTO	b_notrx,
	        b_tipo,
	        b_comprobante,
	        b_fecha,
	        b_concepto,
--	        b_ccosto,
	        b_descrip,
	        b_monto,
	        b_moneda,
	        b_debito,
	        b_credito,
	        b_status,
	        b_origen,
	        b_usuario
    FROM tmp_cglresumen
--   WHERE ( res_notrx = 49768 )
--     AND ( res_comprobante like '12-0027')
GROUP BY res_tipo_resumen,
         res_notrx,
         res_comprobante,
         res_fechatrx,
         res_tipcomp,
--         res_ccosto,
         res_descripcion,
         res_moneda,
         res_usuariocap,
         res_usuarioact,
         res_origen,
         res_status,
         res_tabla
                  
    SELECT con_descrip 
      INTO l_desc_concepto
      FROM tmp_cglconcepto
     WHERE con_codigo  = b_concepto;

    LET  l_des2  = "";
    LET  l_desc1 = "";

	-- Validaciones

	  SELECT sum(res_debito),
	         sum(res_credito)
       INTO total_db,
            total_cr
	    FROM tmp_cglresumen;

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
	  SELECT res_notrx,
	         res_tipcomp,
	         res_cuenta,
	         res_ccosto,
	         res_debito,
	         res_credito,
	         res_status,
	         res_noregistro
       INTO c_notrx,
            c_tipo,
            c_cuenta,
            c_ccosto,
            c_debito,
            c_credito,
            c_actlzdo,
			c_linea
	    FROM tmp_cglresumen
--	   WHERE ( tmp_cglresumen.res_notrx = 49768 )
--	     AND ( tmp_cglresumen.res_comprobante like '12-0027')
      ORDER BY res_noregistro

		let _contador = _contador + 1;

		SELECT cta_cuenta, 
		       cta_nombre, 
		       cta_auxiliar
		  INTO l_cuenta,
		       l_nombre,
		       l_auxiliar 
		  FROM tmp_cglcuentas
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
	           _contador,
               _cia_nom
		       WITH RESUME;

		IF l_auxiliar = "S" THEN 
		if (a_comp[1,3] = 'PLA' and c_cuenta = '13601') or (a_comp[1,3] <> 'PLA') then
           SELECT SUM(res1_debito), 
            	  SUM(res1_credito) 
    	     INTO db, 
              	  cr
             FROM tmp_cglresumen1
		    WHERE ( res1_noregistro = c_linea ) AND
		          ( res1_comprobante = b_comprobante) and
				  ( res1_cuenta = c_cuenta);

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
				  SELECT res1_linea,
				         res1_cuenta,
				         res1_auxiliar,
				         res1_debito,
				         res1_credito
				    INTO d_linea,
				         d_cuenta,
				         d_auxiliar,
				         d_debito,
				         d_credito
				    FROM tmp_cglresumen1
				   WHERE ( res1_noregistro = c_linea ) AND
				         ( res1_comprobante = b_comprobante) and
						 ( res1_cuenta = c_cuenta)
				   order by res1_linea

					let _contador = _contador + 1;

					SELECT ter_descripcion 
					  INTO l_nombre 
					  FROM tmp_cglterceros
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
				           _contador,
	                                   _cia_nom
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
		           _contador,
                           _cia_nom 
		           WITH RESUME;

		end if
		end if

	END FOREACH
      
{
    IF l_des2 = "N" THEN

       UPDATE cgltrx1 
          SET trx1_status = "E"
        WHERE cgltrx1.trx1_notrx = b_notrx;

    END IF
}

END FOREACH

--drop table tmp_cglresumen;
--drop table tmp_cglresumen1;
--drop table tmp_cglconcepto;
--drop table tmp_cglcuentas;
--drop table tmp_cglterceros;

END PROCEDURE
  