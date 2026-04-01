-- Consulta de Movimientos de Cuentas Sac x Auxiliar --Si es REMESAS
-- Creado    : 30/03/2010 -- Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac179c('23102020804','REA03102','09/03/2010','72879','RE050')

DROP PROCEDURE sp_sac179c;
CREATE PROCEDURE sp_sac179c(a_cuenta char(12),a_comp CHAR(15),a_fecha DATE,a_sacnotrx integer,a_aux CHAR(5)) 
RETURNING	char(12),		--cuenta 
			char(15), 		--comprobante 
			DATE,			--fecha
			CHAR(10),		-- remesa
			smallint,		-- renglon
			DEC(15,2),		-- debito
			DEC(15,2),		-- credito
			DEC(15,2),		-- neto
			CHAR(10),		-- Recibo
			CHAR(1),		-- Tipo Movimiento
			CHAR(30),		-- Documento
			DEC(16,2), 	 	-- Monto Banco
			DEC(16,2),  	-- Prima
			DEC(16,2),  	-- Impuesto
			CHAR(100);		-- desc_remesa

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
DEFINE d_remesa			CHAR(10);
DEFINE d_debito			DEC(15,2);
DEFINE d_credito		DEC(15,2);
DEFINE d_renglon		smallint;
DEFINE v_no_recibo      CHAR(10);
DEFINE v_tipo_mov		CHAR(1);
DEFINE v_doc_remesa		CHAR(30);
DEFINE v_monto_banco	DEC(16,2);
DEFINE v_prima			DEC(16,2);
DEFINE v_impuesto		DEC(16,2);
DEFINE v_desc_remesa	CHAR(100);

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_reacob(
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
	and a.cuenta = a_cuenta          -- '23102020804'
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

		INSERT INTO tmp_reacob (
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
		 renglon,
		sum(debito),
		sum(credito)
	INTO   d_remesa,
		   d_renglon,
		   d_debito,
	       d_credito
    FROM tmp_reacob
	group by 1,2
	order by 1,2

		if d_debito is null then
			let d_debito = 0; 
		end if
		if d_credito is null then
			let d_credito = 0; 
		end if

		let i_neto = d_debito - d_credito ;

	 SELECT no_recibo,
			tipo_mov,
			doc_remesa,
			monto,
			prima_neta,
			impuesto,
			desc_remesa
	   INTO	v_no_recibo,
			v_tipo_mov,
			v_doc_remesa,
			v_monto_banco,
			v_prima,
			v_impuesto,
			v_desc_remesa 		
	   FROM deivid:cobredet
	  WHERE no_remesa = d_remesa
		AND renglon   = d_renglon ;

  RETURN a_cuenta,
		   a_comp,
		   a_fecha,
		   d_remesa,
		   d_renglon,
		   d_debito,
		   d_credito,
		   i_neto,
			v_no_recibo,
			v_tipo_mov,
			v_doc_remesa,
			v_monto_banco,
			v_prima,
			v_impuesto,
			v_desc_remesa		   		   
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_reacob;
END PROCEDURE					 