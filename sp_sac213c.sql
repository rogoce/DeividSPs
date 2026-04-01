-- Consulta de Movimientos de Cuentas Sac x Auxiliar -- Si es produccion 
-- Creado    : 21/04/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac213c('sac','01/07/2011','31/12/2011','BQ050')

DROP PROCEDURE sp_sac213c;
CREATE PROCEDURE sp_sac213c(a_db char(18), a_fecha1 date, a_fecha2 date, a_auxiliar CHAR(5) )
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  smallint,  -- Nivel
		  CHAR(5),	 -- Auxiliar
		  DEC(16,2), -- Db_aux
		  DEC(16,2), -- Cr_aux
		  CHAR(50),	 -- name_reas
		  CHAR(10),	 -- name_reas
		  char(50);

DEFINE i_cuenta			char(12);
DEFINE i_comprobante	CHAR(15);
DEFINE i_fechatrx		DATE;
DEFINE i_no_registro    char(10);
DEFINE i_notrx			INTEGER;
DEFINE i_auxiliar		CHAR(5);
DEFINE i_debito			DEC(15,2);
DEFINE i_credito		DEC(15,2);
DEFINE i_origen			CHAR(15);
DEFINE i_no_documento	CHAR(20);
DEFINE i_no_poliza		CHAR(10);
DEFINE i_no_endoso		CHAR(5);
DEFINE i_no_remesa		CHAR(10);
DEFINE i_renglon		smallint;
DEFINE i_no_tranrec		CHAR(10);
DEFINE _mostrar         CHAR(10);
DEFINE _tipo            CHAR(15);

DEFINE i_neto           DEC(15,2);
DEFINE d_factura		CHAR(10);
DEFINE d_poliza			CHAR(10);
DEFINE d_endoso			CHAR(5);
DEFINE d_debito			DEC(15,2);
DEFINE d_credito		DEC(15,2);
DEFINE d_renglon		smallint;
DEFINE v_no_recibo      CHAR(10);
DEFINE v_tipo_mov		CHAR(3);
DEFINE v_nombre 		CHAR(50);
DEFINE v_prima_bruta	DEC(16,2);
DEFINE v_prima_neta		DEC(16,2);
DEFINE v_impuesto		DEC(16,2);	   		   
DEFINE v_documento		CHAR(20);
define _cia_nom		    char(50);

DEFINE v_nombre_cuenta   CHAR(50);
DEFINE _no_poliza		 CHAR(10);
DEFINE _no_endoso		 CHAR(5);
define _error			integer;
define _error_desc		char(50);

define r_cod_auxiliar   char(5);
define r_debito         DEC(16,2);
define r_credito		DEC(16,2);
define r_desc_rea		char(50);
define _no_factura      char(10);
define _no_remesa       char(10);
define _auxiliar_nom    char(50);
--define r_desc_rea       char(50);

SET ISOLATION TO DIRTY READ;


CREATE TEMP TABLE tmp_aux213c(
		res1_notrx		  integer,	
		res1_linea	      integer,		  
		res1_cuenta       char(12),	 	
		res1_auxiliar     char(5),	 		
		res1_debito       decimal(15,2),	
		res1_credito      decimal(15,2),	
		res1_noregistro   integer, 
		res1_comprobante  char(15),
		res1_remesa       char(10),
		res1_desc_rea     char(50), 
		res1_no_documento char(20),
		res1_no_poliza    char(10),
		PRIMARY KEY(res1_notrx,res1_noregistro,res1_linea,res1_cuenta,res1_auxiliar,res1_remesa)) WITH NO LOG;

CREATE INDEX idx1_tmp_aux213c ON tmp_aux213c(res1_notrx);
CREATE INDEX idx2_tmp_aux213c ON tmp_aux213c(res1_noregistro);
CREATE INDEX idx3_tmp_aux213c ON tmp_aux213c(res1_linea);
CREATE INDEX idx4_tmp_aux213c ON tmp_aux213c(res1_cuenta);
CREATE INDEX idx5_tmp_aux213c ON tmp_aux213c(res1_auxiliar);
CREATE INDEX idx6_tmp_aux213c ON tmp_aux213c(res1_remesa);
CREATE INDEX idx7_tmp_aux213c ON tmp_aux213c(res1_no_documento);
CREATE INDEX idx8_tmp_aux213c ON tmp_aux213c(res1_no_poliza);

CREATE TEMP TABLE tmp_sac213c(
		cuenta			char(12),
		comprobante		char(15),
		fechatrx		date,
		no_registro		CHAR(10),
		auxiliar     	char(5),
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		origen          char(15),
		no_documento	char(20),
		no_poliza       char(10),
		no_endoso       char(5),
		no_remesa		char(10),
		renglon			smallint,
		no_tranrec		char(10),
		notrx           integer,
		mostrar			char(10),
		tipo            char(15),
		no_factura      char(10),
		auxiliar_nom	char(50)
		) WITH NO LOG; 	

let v_nombre = " ";
let i_comprobante = " ";

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = a_db;

call sp_sac211(a_db, a_fecha1 , a_fecha2 , a_auxiliar, "2" ) returning _error, _error_desc;

--SET DEBUG FILE TO "sp_sac213c.trc";
--trace on;

SELECT ter_descripcion 
  INTO _auxiliar_nom 
  FROM sac:cglterceros
 WHERE ter_codigo = a_auxiliar;

FOREACH 
 SELECT distinct f.no_remesa
   INTO _no_remesa
   FROM cobremae f,tmp_aux t
  WHERE f.no_remesa  = t.no_remesa
    AND f.actualizado = 1

	FOREACH	
		select b.cuenta,
		c.fecha,
		b.no_registro,
		b.debito,
		b.credito,
		decode(c.tipo_registro,"1","PRODUCCION","2","COBROS","3","RECLAMOS"),
		c.no_documento,
		c.no_poliza,
		c.no_endoso,
		c.no_remesa,
		c.renglon,
		c.no_tranrec,
		b.sac_notrx
		into i_cuenta,
			 i_fechatrx,
			 i_no_registro,
			 i_debito,
			 i_credito,
			 i_origen,
			 i_no_documento,
			 i_no_poliza,
			 i_no_endoso,
			 i_no_remesa,
			 i_renglon,
			 i_no_tranrec,
			 i_notrx
		from sac999:reacompasie b, sac999:reacomp c
		where b.no_registro = c.no_registro
		and c.tipo_registro = "2"
		and c.no_remesa = _no_remesa

			LET _mostrar = "";
			if trim(i_origen) = "COBROS" then
				LET _tipo = 'No. Remesa';
				LET _mostrar = i_no_remesa;
		    end if
			LET i_auxiliar = '';

			INSERT INTO tmp_sac213c (
			cuenta,
			comprobante,
			fechatrx,
			no_registro,
			auxiliar,
			debito,
			credito,
			origen,
			no_documento,
			no_poliza,
			no_endoso,
			no_remesa,
			renglon,
			no_tranrec,
			notrx,
			mostrar,
			tipo,
			no_factura,
			auxiliar_nom
			 )
			VALUES (
			i_cuenta,
			i_comprobante,		
			i_fechatrx,
			i_no_registro,
			i_auxiliar,
			i_debito,
			i_credito,
			i_origen,
			i_no_documento,
			i_no_poliza,
			i_no_endoso,
			i_no_remesa,
			i_renglon,
			i_no_tranrec,
			i_notrx,
			_mostrar,
			_tipo,
			_no_remesa,
			_auxiliar_nom
			);

		   	FOREACH
				select a.cod_auxiliar,
				      t.ter_descripcion,
				      sum(a.debito),
				      sum(a.credito)
				 into r_cod_auxiliar,
					  r_desc_rea,
					  r_debito,
					  r_credito	
				 from sac999:reacompasiau a ,tmp_cglterceros t	 
				where a.no_registro  = i_no_registro
				  and a.cod_auxiliar = t.ter_codigo
				  and a.cuenta       = i_cuenta 
				group by 1,2
				order by 1,2


			   	BEGIN
				ON EXCEPTION IN(-239)
				  UPDATE tmp_aux213c
				     SET res1_debito    = res1_debito + r_debito, 
					     res1_credito   = res1_credito + r_credito
				   WHERE res1_notrx     = i_notrx
					 AND res1_cuenta    = i_cuenta 
					 AND res1_auxiliar	= r_cod_auxiliar
					 AND res1_remesa    = _no_remesa; 
				END EXCEPTION 	


					INSERT INTO tmp_aux213c(
					res1_notrx,
					res1_linea,	    
					res1_cuenta,    
					res1_auxiliar,   
					res1_debito,     
					res1_credito,    
					res1_noregistro, 
					res1_comprobante,
					res1_remesa,
					res1_desc_rea,
					res1_no_documento, 
					res1_no_poliza    
					)																	
					VALUES(	
					i_notrx, 
					i_renglon, 
					i_cuenta, 
					r_cod_auxiliar, 
					r_debito, 
					r_credito,    
					i_no_registro, 
					i_comprobante,
					_no_remesa,
					r_desc_rea,
					i_no_documento,
					i_no_poliza										
					 );  
			 END 

			END FOREACH	 

	   
	END FOREACH;

END FOREACH;

FOREACH
 SELECT no_factura,
        auxiliar_nom,
        cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO _no_factura,
        _auxiliar_nom,
        i_cuenta, 
        i_debito, 
        i_credito
   FROM tmp_sac213c
  GROUP BY 1,2,3
  ORDER BY 1,2,3

		if i_debito is null then
			let i_debito = 0; 
		end if
		if i_credito is null then
			let i_credito = 0; 
		end if

		if _error <> 0 then
		 let v_nombre_cuenta = "";
		else
			 SELECT cta_nombre
			   INTO v_nombre_cuenta
			   FROM tmp_cglcuentas
			  WHERE cta_cuenta = i_cuenta ;
		end if
		LET r_cod_auxiliar = '';
		LET r_debito = 0;
		LET r_credito = 0;
		LET r_desc_rea = '';

	RETURN i_cuenta,			
		   v_nombre_cuenta,  
		   i_debito,         
		   i_credito,        
		   _cia_nom,
		   1, 
		   r_cod_auxiliar,
		   r_debito,
		   r_credito,
		   r_desc_rea,
		   _no_factura,
		   _auxiliar_nom
		   WITH RESUME;	 		

		FOREACH
			select a.res1_auxiliar,
			      t.ter_descripcion,
			      sum(a.res1_debito),
			      sum(a.res1_credito)
			 into r_cod_auxiliar,
				  r_desc_rea,
				  r_debito,
				  r_credito
			 from tmp_aux213c a ,tmp_cglterceros t	 	 
			where a.res1_cuenta = i_cuenta 
			  and a.res1_auxiliar = t.ter_codigo
			  and a.res1_remesa = _no_factura
		    group by 1,2
			order by 1,2

			if r_debito is null then
				let r_debito = 0; 
			end if

			if r_credito is null then
				let r_credito = 0; 
			end if

			RETURN i_cuenta,
				   v_nombre_cuenta,
				   0,
				   0,
				   _cia_nom,
				   2,
				   r_cod_auxiliar,
				   r_debito,
				   r_credito,
				   r_desc_rea,
				   _no_factura,
				   _auxiliar_nom
				   WITH RESUME;	 		

		 END FOREACH;

END FOREACH;
  
DROP TABLE tmp_sac213c;
DROP TABLE tmp_aux213c;
DROP TABLE tmp_cglcuentas;
DROP TABLE tmp_cglterceros;



END PROCEDURE					 