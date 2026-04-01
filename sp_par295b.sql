-- Consulta de Movimientos de Cuentas Sac x Auxiliar -- Si es produccion
-- Creado    : 21/04/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac182('23102020804','REA03102','09/03/2010','72879','RE050')

DROP PROCEDURE sp_par295b;
CREATE PROCEDURE sp_par295b()
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
		  char(10);

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
DEFINE _no_tranrec		CHAR(10);
define _numrecla        char(18);
define _transaccion     char(10);
define _no_reclamo      char(10);


SET ISOLATION TO DIRTY READ;

{CREATE TEMP TABLE tmp_reaprod(
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
		numrecla        char(18)
		) WITH NO LOG;}

let v_nombre = " ";
let v_nombre_cuenta = '';


{FOREACH

	 SELECT numrecla
	   INTO _numrecla
	   FROM c
	  order by numrecla
 
	 select no_reclamo into _no_reclamo from recrcmae
	 where numrecla = _numrecla;

foreach

	 SELECT no_tranrec,transaccion
	   INTO _no_tranrec,_transaccion
	   FROM rectrmae
	  WHERE no_reclamo  = _no_reclamo
	    AND actualizado = 1

	let i_comprobante = _transaccion;

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
		and c.tipo_registro = "3"
		and c.no_tranrec = _no_tranrec

			LET _mostrar = "";

			if trim(i_origen) = "PRODUCCION" then
				LET _tipo = 'No. Factura';
				 SELECT no_factura
				   INTO _mostrar
				   FROM endedmae
				  WHERE no_poliza = i_no_poliza
				    AND	no_endoso = i_no_endoso
				    AND actualizado = 1	  ;	 
			end if
			if trim(i_origen) = "COBROS" then
				LET _tipo = 'No. Remesa';
				 LET _mostrar = i_no_remesa;
		    end if
			if trim(i_origen) = "RECLAMOS" then
				LET _tipo = 'No. transaccion';
				 SELECT transaccion
				   INTO _mostrar
				   FROM rectrmae
				  WHERE no_tranrec = i_no_tranrec
				    AND actualizado = 1;
			end if
			let i_auxiliar = '';

			INSERT INTO tmp_reaprod (
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
			numrecla
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
			_numrecla
			);
	   
	END FOREACH;

END FOREACH;

end foreach	 }

FOREACH
 SELECT no_registro,
        cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO i_no_registro,
        i_cuenta, 
        i_debito, 
        i_credito
   FROM tmp_reaprod
  GROUP BY 1,2
  ORDER BY 1,2

		if i_debito is null then
			let i_debito = 0; 
		end if
		if i_credito is null then
			let i_credito = 0; 
		end if

		LET r_cod_auxiliar = '';
		LET r_debito = 0;
		LET r_credito = 0;
		LET r_desc_rea = '';
		let _cia_nom = '';

   {	RETURN i_cuenta,			
		   v_nombre_cuenta,  
		   i_debito,         
		   i_credito,        
		   _cia_nom,
		   1, 
		   r_cod_auxiliar,
		   r_debito,
		   r_credito,
		   r_desc_rea
		   WITH RESUME;	} 		

		FOREACH
		   select a.cod_auxiliar,
			      a.debito,
			      a.credito
			 into r_cod_auxiliar,
				  r_debito,
				  r_credito
			 from sac999:reacompasiau a
			where a.no_registro = i_no_registro
			  and a.cuenta      = i_cuenta 
			order by 1

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
				   '',
				   i_no_registro
				   WITH RESUME;	 		

		 END FOREACH;

END FOREACH;

  
--DROP TABLE tmp_reaprod;
--DROP TABLE tmp_cglcuentas;
--DROP TABLE tmp_cglterceros;

END PROCEDURE					 