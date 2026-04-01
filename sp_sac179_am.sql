--ARMANDO MORENO M.
--24/09/2025 SOLICITADO POR JOSUE

-- execute procedure sp_sac179('23102020804','REA03102','09/03/2010','RE050')
--SE DEBE INSERTAR EL LA TABLA deivid_tmp:comprobantes EL COMPROBANTE Y LA FECHA ANTES DE EJECUTARSE.

DROP PROCEDURE sp_sac179_am;
CREATE PROCEDURE sp_sac179_am(a_cuenta char(12),a_comp CHAR(15),a_fecha DATE,a_fecha2 date,a_aux CHAR(5)) 
RETURNING	char(12),	--cuenta
			char(15),	--comprobante
			date,		--fechatrx
			char(5),	--auxiliar
			DEC(15,2),	--debito
			DEC(15,2),	--credito
			char(15),	--origen
			char(20),	--no_documento
			char(10),	--no_tranrec
			char(10),	--mostrar
			char(15);	--tipo

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

SET ISOLATION TO DIRTY READ;

drop table if exists tmp_reasiento;

CREATE TEMP TABLE tmp_reasiento(
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

--  set debug file to "sp_sac179.trc";	
--  trace on;
FOREACH
	select comprobante,
	       fecha
	  into a_comp,
	       a_fecha
	  from deivid_tmp:comprobantes	   
    	  

	let i_comprobante = a_comp;
	let a_fecha2      = a_fecha;

	FOREACH
		select a.cuenta,
		a.fecha,
		a.no_registro,
		a.cod_auxiliar,
		a.debito,
		a.credito,
		decode(c.tipo_registro,"1","PRODUCCION","2","COBROS","3","RECLAMOS", "4", "CHEQUES", "5", "ANULADOS"),
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
		from sac999:reacompasiau a, sac999:reacompasie b, sac999:reacomp c, cglresumen v, cglresumen1 p
		where a.periodo = b.periodo
		and a.cuenta = b.cuenta
		and a.tipo_comp = b.tipo_comp
		and a.no_registro = b.no_registro
		and a.no_registro = c.no_registro
		and b.sac_notrx = v.res_notrx
		and v.res_noregistro = p.res1_noregistro
		and v.res_comprobante = a_comp
		and p.res1_auxiliar = a_aux
		and p.res1_cuenta = a_cuenta
		and a.cod_auxiliar = a_aux
		and a.cuenta = a_cuenta
		and a.fecha >= a_fecha
		and a.fecha <= a_fecha2

			LET _mostrar = "";

			if trim(i_origen) = "PRODUCCION" then
				continue foreach;

				LET _tipo = 'No. Factura';
				 SELECT no_factura
				   INTO _mostrar
				   FROM endedmae
				  WHERE no_poliza = i_no_poliza
					AND	no_endoso = i_no_endoso
					AND actualizado = 1	  ;	 

			elif trim(i_origen) = "COBROS" then
			continue foreach;
				LET _tipo = 'No. Remesa';
				 LET _mostrar = i_no_remesa;

			elif trim(i_origen) = "RECLAMOS" then
				LET _tipo = 'No. transaccion';
				 SELECT transaccion
				   INTO _mostrar
				   FROM rectrmae
				  WHERE no_tranrec = i_no_tranrec
					AND actualizado = 1;

			elif trim(i_origen) = "CHEQUES" then
			continue foreach;
				LET _tipo = 'No. Requisicion';
				LET _mostrar = i_no_remesa;

			elif trim(i_origen) = "ANULADOS" then
			continue foreach;
				LET _tipo = 'No. Requisicion';
				LET _mostrar = i_no_remesa;

			end if

			INSERT INTO tmp_reasiento (
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
	  SELECT cuenta,
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
			INTO i_cuenta,
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
		FROM tmp_reasiento     
		order by 2,1,15

	  RETURN i_cuenta,
			i_comprobante,
			i_fechatrx,
			i_auxiliar,
			i_debito,
			i_credito,
			i_origen,
			i_no_documento,
			i_no_tranrec,
			_mostrar,
			_tipo		   
			 WITH RESUME;

		delete from tmp_reasiento;
	END FOREACH;
END FOREACH;
END PROCEDURE					 