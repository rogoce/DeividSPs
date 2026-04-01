-- Consulta de Movimientos de Cuentas Sac x Produccion - Endoso
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac159( '26401','COB12091','18/12/2009','348552')
DROP PROCEDURE sp_sac159;
CREATE PROCEDURE sp_sac159(a_cuenta char(12), a_comp CHAR(15), a_fecha DATE, a_factura CHAR(10)) 
RETURNING	char(12),		--cuenta 
			char(15), 		--comprobante 
			DATE,			--fecha
			CHAR(10),		-- Factura
			DEC(15,2),		-- debito
			DEC(15,2),		-- credito
			DEC(15,2),		-- neto
			CHAR(10),		-- poliza
			CHAR(5),		-- endoso
			DEC(16,2), 	 	-- Prima bruta
			DEC(16,2),  	-- Impuesto
			DEC(16,2),  	-- Prima Neta
			CHAR(50),		-- tipo
			CHAR(20);		-- Documento

DEFINE i_cuenta			char(12);
DEFINE i_origen			char(12);
DEFINE i_comprobante	CHAR(15);
DEFINE i_fechatrx		DATE;
DEFINE i_notrx			INTEGER;
DEFINE i_debito			DEC(15,2);
DEFINE i_credito		DEC(15,2);
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

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_factura(
		cuenta			char(12),
		comprobante		CHAR(15),
		fechatrx		DATE,
		notrx			INTEGER,
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		neto            DEC(15,2)   default 0,
		origen			CHAR(3),
		factura	 		CHAR(10),
		poliza 			CHAR(10),
		endoso			CHAR(5)
		) WITH NO LOG; 	

--  set debug file to "sp_sac152.trc";	
--  trace on;

FOREACH
	select res_notrx,res_origen,res_debito,res_credito
	into i_notrx,i_origen,i_debito,i_credito
	from cglresumen
	where res_cuenta = a_cuenta
	and res_comprobante = a_comp
	and res_fechatrx = a_fecha
	order by res_comprobante,res_fechatrx,res_notrx,res_noregistro,res_origen

	if 	i_origen = 'PRO' then

	   FOREACH
			select no_poliza, no_endoso
			into d_poliza, d_endoso 
			from deivid:endedmae  
			where no_factura = a_factura

			FOREACH
				select no_poliza,no_endoso,sum(debito),sum(credito) 
				into  d_poliza,d_endoso,d_debito,d_credito
				from deivid:endasien
				where sac_notrx = i_notrx
				and cuenta = a_cuenta
				and no_poliza = d_poliza
				and no_endoso = d_endoso
				group by no_poliza,no_endoso
				order by no_poliza,no_endoso

					if d_debito is null then
						let d_debito = 0; 
					end if
					if d_credito is null then
						let d_credito = 0; 
					end if

					let i_neto = d_debito - d_credito ;


					INSERT INTO tmp_factura (
					cuenta,
					comprobante,
					fechatrx,
					notrx,
					debito,
					credito,
					neto,
					origen,
					factura,
					poliza,
					endoso )
					VALUES (
					a_cuenta,
					a_comp,
					a_fecha,
					i_notrx,
					d_debito,
					d_credito,
					i_neto,
					i_origen,
					a_factura,
					d_poliza,
					d_endoso
					);

			END FOREACH;

		END FOREACH;

	end if
   
END FOREACH;

FOREACH	
  SELECT factura,
		poliza,
		endoso,
		sum(debito),
		sum(credito),
		sum(neto)
	INTO   d_factura,
		   d_poliza,
		   d_endoso,
		   d_debito,
	       d_credito,
		   i_neto
    FROM tmp_factura
	where cuenta = 	a_cuenta
	and   comprobante = a_comp
	and   fechatrx  = a_fecha
	and   factura = a_factura
	group by factura,poliza,endoso	
	order by factura,poliza,endoso

	 SELECT cod_endomov,
		    prima_bruta,
		    prima_neta,
		    impuesto
	   INTO	v_tipo_mov,
			v_prima_bruta,
			v_prima_neta,
			v_impuesto 		
	   FROM deivid:endedmae
	  WHERE no_factura = d_factura
		and no_poliza  = d_poliza
		AND no_endoso  = d_endoso ;

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

DROP TABLE tmp_factura;
END PROCEDURE					 				  				  			 