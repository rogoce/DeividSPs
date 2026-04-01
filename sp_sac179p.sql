-- Consulta de Movimientos de Cuentas Sac x Auxiliar --Si es produccion
-- Creado    : 30/03/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac179p('23102020804','REA03102','09/03/2010','72879','RE050')

DROP PROCEDURE sp_sac179p;
CREATE PROCEDURE sp_sac179p(a_cuenta char(12),a_comp CHAR(15),a_fecha DATE,a_sacnotrx integer,a_aux CHAR(5)) 
RETURNING char(12),	  --cuenta
		  char(15),	  --comprobante
		  date,		  --fechatrx
		  char(10),	  --factura
		  DEC(16,2),  --debito
		  DEC(16,2),  --credito
		  DEC(16,2),  --neto
		  char(10),	  --poliza
		  char(5),	  --endoso
		  DEC(16,2),  --prima_bruta
		  DEC(16,2),  --impuesto
		  DEC(16,2),  --prima_neta
		  char(50),	  --tipo
		  char(20);	  --documento

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

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_reaprod(
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
		tipo            char(15)
		) WITH NO LOG; 	

let v_nombre = " ";
let i_comprobante = a_comp;

FOREACH	
	select a.cuenta,
	a.fecha,
	a.no_registro,
	a.cod_auxiliar,
	a.debito,
	a.credito,
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
		 i_notrx
	from sac999:reacompasiau a, sac999:reacompasie b, sac999:reacomp c
	where a.periodo = b.periodo
	and a.cuenta = b.cuenta
	and a.tipo_comp = b.tipo_comp
	and a.no_registro = b.no_registro
	and a.no_registro = c.no_registro
   	and b.sac_notrx = a_sacnotrx     --'72879'
	and a.cod_auxiliar = a_aux       --'RE050'
	and a.cuenta = a_cuenta          --'23102020804'
	and a.fecha = a_fecha            --'09/03/2010'

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
		tipo
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
		_tipo
		);
   
END FOREACH;


FOREACH	
  SELECT mostrar,
		sum(debito),
		sum(credito)
	INTO   d_factura,
		   d_debito,
	       d_credito
    FROM tmp_reaprod
	group by 1
	order by 1

		if d_debito is null then
			let d_debito = 0; 
		end if
		if d_credito is null then
			let d_credito = 0; 
		end if

		let i_neto = d_debito - d_credito ;

	 SELECT cod_endomov,
		    prima_bruta,
		    prima_neta,
		    impuesto,
			no_poliza,
			no_endoso
	   INTO	v_tipo_mov,
			v_prima_bruta,
			v_prima_neta,
			v_impuesto,
			d_poliza,
			d_endoso 		
	   FROM deivid:endedmae
	  WHERE no_factura = d_factura;

	select no_documento
	  into v_documento
	  from deivid:emipomae
	 where no_poliza = d_poliza	;

		-- Descripcion de Tipo de Endoso
		if v_tipo_mov = '001' then
			let v_nombre = "AUMENTO DE VIGENCIA";
		elif v_tipo_mov = '002' then
			let v_nombre = "CANCELACION DE POLIZA";
		elif v_tipo_mov = '003' then
			let v_nombre = "REHABILITACION DE POLIZA";
		elif v_tipo_mov = '004' then
			let v_nombre = "INCLUSION DE UNIDADES";
		elif v_tipo_mov = '005' then
			let v_nombre = "ELIMINACION DE UNIDADES";
		elif v_tipo_mov = '006' then
			let v_nombre = "MODIFICACION DE UNIDADES";
		elif v_tipo_mov = '007' then
			let v_nombre = "CONVERSION";
		elif v_tipo_mov = '008' then
			let v_nombre = "REVERSAR";
		elif v_tipo_mov = '009' then
			let v_nombre = "CAMBIO DE NO. MOTOR Y/O CHASIS";
		elif v_tipo_mov = '010' then
			let v_nombre = "CAMBIO DE ACREEDOR(ES)";
		elif v_tipo_mov = '011' then
			let v_nombre = "POLIZA ORIGINAL";
		elif v_tipo_mov = '012' then
			let v_nombre = "CAMBIO DE CORREDORES";
		elif v_tipo_mov = '013' then
			let v_nombre = "CAMBIO DE ASEGURADO Y/O CONTRATANTE";
		elif v_tipo_mov = '014' then
			let v_nombre = "FACTURACION MENSUAL";
		elif v_tipo_mov = '015' then
			let v_nombre = "ENDOSO DESCRIPTIVO";
		elif v_tipo_mov = '016' then
			let v_nombre = "CAMBIO DE REASEGURO GLOBAL";
		elif v_tipo_mov = '017' then
			let v_nombre = "CAMBIO DE REASEGURO INDIVIDUAL";
		elif v_tipo_mov = '018' then
			let v_nombre = "CAMBIO DE COASEGURO";
		elif v_tipo_mov = '019' then
			let v_nombre = "DISMINUCION DE VIGENCIA";
		elif v_tipo_mov = '021' then
			let v_nombre = "RENOVACION DE DIFERIDAS";
		elif v_tipo_mov = '022' then
			let v_nombre = "FACTURACION VIDA INDIVIDUAL";
		elif v_tipo_mov = '023' then
			let v_nombre = "DECLARACIONES";
		end if

	RETURN a_cuenta,
		   a_comp,
		   a_fecha,
		   d_factura,
		   d_debito,
		   d_credito,
		   i_neto,
		   d_poliza,
		   d_endoso,
		   v_prima_bruta,
		   v_impuesto,
		   v_prima_neta,
		   v_nombre,
		   v_documento		   		   
    	 WITH RESUME;

END FOREACH;

  
DROP TABLE tmp_reaprod;
END PROCEDURE					 