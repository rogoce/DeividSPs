-- Procedimiento que Carga la Siniestralidad acumulada por ajustadores
-- Creado: 12/05/2014 - Autor: Angel Tello
-- 
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec300_JB;

CREATE PROCEDURE "informix".sp_rec300_JB(a_periodo CHAR(7)) 
RETURNING   CHAR(18) as reclamo,
            CHAR(15) as no_reclamo,
            CHAR(10) as cod_asegurado,
            CHAR(100) as asegurado,	
            DEC(16,2) as pagado_total,			
            CHAR(5) as cod_cobertura,
            VARCHAR(100) as cobertura,
            CHAR(10) as estatus,
            CHAR(50) as corredor,
            CHAR(15) as perdida,
            DEC(16,2) as deducible,
            CHAR(20) as poliza,
            VARCHAR(50) as ajustador,
            DATE as fecha_siniestro,
            VARCHAR(50) as marca,
            VARCHAR(50) as modelo,
            CHAR(10) as uso_auto,
			DATE as fecha_reclamo,
			DEC(16,2) as reserva_actual; 			

DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(1);

DEFINE _monto_total     DECIMAL(16,2);
DEFINE _monto_bruto     DECIMAL(16,2);
DEFINE _monto_neto      DECIMAL(16,2);

DEFINE _var_cob_total	DECIMAL(16,2);
DEFINE _var_cob_bruto   DECIMAL(16,2);
DEFINE _var_cob_neto    DECIMAL(16,2);

define _cod_cobertura	char(5);
define _cod_cober_reas	char(3);

DEFINE _incurrido_abierto DEC(16,2);
DEFINE _porc_coas       DECIMAL;
DEFINE _porc_reas       DECIMAL;
DEFINE v_desc_grupo,v_desc_agente   CHAR(50);
DEFINE v_codigo,_cod_agente         CHAR(5);
DEFINE v_saber          CHAR(2);

DEFINE _cod_coasegur    CHAR(3);

DEFINE _no_reclamo,v_no_reclamo,a_no_reclamo      CHAR(10);
DEFINE _no_poliza       CHAR(10);
DEFINE _periodo,_peri,v_periodo,_periodo_rec CHAR(7);
DEFINE _numrecla        CHAR(18);
DEFINE _doc_poliza      CHAR(20);
DEFINE _no_unidad       CHAR(5);
DEFINE _no_tranrec      CHAR(10);

DEFINE _cod_sucursal    CHAR(3);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _ajust_interno   CHAR(3);
DEFINE _cod_evento      CHAR(3);
DEFINE _cod_suceso      CHAR(3);
DEFINE _cod_cliente     CHAR(10);
DEFINE _posible_recobro INT;
DEFINE _cod_acreedor    CHAR(5);
DEFINE _cod_tipoprod    CHAR(3);
DEFINE _periodo_reclamo CHAR(7);
DEFINE _desc_ajus_nomb  CHAR(255);
DEFINE _cod_tipotran    CHAR(3);
define _pago_y_ded		DECIMAL(16,2);
define _salv_y_recup    DECIMAL(16,2);
define _pendiente       smallint;
define _cant_pago       smallint;
define _cnt             integer;
DEFINE _no_documento    CHAR(20);		
DEFINE _no_motor        CHAR(30);
DEFINE _estatus_reclamo char(1);
DEFINE _cod_asegurado   char(10);
DEFINE _fecha_siniestro date;
define _asegurado       varchar(100);
define _estatus         CHAR(10);
define _deducible       DEC(16,2);
define _perdida         CHAR(15);
define _marca			varchar(50);
define _modelo		    varchar(50);
define _cod_marca       char(5);
define _cod_modelo      char(5);
define _cobertura       varchar(100);
define _uso_auto        char(1);
define _ajustador       varchar(50);
DEFINE _perd_total      SMALLINT;
define _fecha_reclamo   date;
define _reserva_actual  DEC(16,2);
define _cnt_cober_reas  smallint;

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02(001, '001');
let v_filtros = null;

-- Tabla Temporal
--DROP TABLE tmp_sinis;

CREATE TEMP TABLE tmp_reclamo_jb(
		no_reclamo           CHAR(10),
		cod_cobertura        CHAR(5),
		reserva_total		dec(16,2) DEFAULT 0 not null,
		reserva_bruto		dec(16,2) DEFAULT 0 not null,
		reserva_neto		dec(16,2) DEFAULT 0 not null,
		pagado_total         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_bruto         DEC(16,2) DEFAULT 0 NOT NULL,
		pagado_neto          DEC(16,2) DEFAULT 0 NOT NULL,
		periodo              CHAR(7)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_pendiente_jb(
       no_reclamo CHAR(10),
	 PRIMARY KEY (no_reclamo)) WITH NO LOG;



foreach 
	select no_reclamo,
		   sum(variacion)
	  into _no_reclamo,	
		   _monto_total
	  from rectrmae 
	 where cod_compania	= 001
	   and periodo     	<= a_periodo 
	   and actualizado  	= 1
	   AND numrecla[1,2] in ('02','20','23')
	 group by no_reclamo
	having sum(variacion) > 0 

	insert into tmp_pendiente_jb 
	 values (_no_reclamo);
end foreach    


FOREACH

-- SELECT FIRST 100 no_reclamo,
 SELECT no_reclamo
   INTO a_no_reclamo
   FROM tmp_pendiente_jb 


	-- Variacion de Reserva
	
	foreach 
	 select no_tranrec,		
		    variacion,
			periodo
	   into _no_tranrec,	
		    _monto_total,
			_peri
	   from rectrmae 
	  where no_reclamo		= a_no_reclamo
	    and periodo     	<= a_periodo
	    and actualizado 	= 1
	--    and cod_compania	= 001
	    and variacion   	<> 0

		-- Informacion de Coaseguro

		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM reccoas
		 WHERE no_reclamo   = a_no_reclamo
		   AND cod_coasegur = _cod_coasegur;

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 0;
		END IF

		foreach
		 select cod_cobertura,
				 variacion
		   into	 _cod_cobertura,
				 _monto_total
		   from rectrcob
		  where no_tranrec = _no_tranrec
			and variacion  <> 0

			select cod_cober_reas
			  into _cod_cober_reas
			  from prdcober
			 where cod_cobertura = _cod_cobertura;	

			 
			--Ajuste de Transacción con Distribución de Reaseguro Incorrecta
			select count(*)
			  into _cnt_cober_reas
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_cober_reas is null then
				let _cnt_cober_reas = 0;
			end if

			if _cnt_cober_reas = 0 then
				if _cod_cober_reas = '002' then
					let _cod_cober_reas = '033';
				elif _cod_cober_reas = '031' then
					if _no_tranrec in ('1555383','1555327') then
						let _cod_cober_reas = '002';
					else
						let _cod_cober_reas = '034';
					end if
				elif _cod_cober_reas = '033' then
					let _cod_cober_reas = '002';
				elif _cod_cober_reas = '034' then
					let _cod_cober_reas = '031';
				end if
			end if

			-- Informacion de Reaseguro
			let _porc_reas = 0;
			foreach
			 select	porc_partic_suma
			   into _porc_reas
			   from rectrrea
			  where no_tranrec     = _no_tranrec
				and cod_cober_reas = _cod_cober_reas
				and tipo_contrato  = 1
				exit foreach;
			end foreach
			
			if _porc_reas is null then
				let _porc_reas = 0;
			end if;
			
			-- Calculos

			LET _monto_bruto = _monto_total / 100 * _porc_coas;
			LET _monto_neto  = _monto_bruto / 100 * _porc_reas;
			
			INSERT INTO tmp_reclamo_jb
			values(
			a_no_reclamo,
			_cod_cobertura,
			_monto_total,
			_monto_bruto,
			_monto_neto,
			0,
			0,
			0,
			_peri);			

		end foreach
    end foreach
	   
	-- Pagos, Salvamentos, Recuperos y Deducibles

	LET _monto_total = 0;
	LET _monto_bruto = 0;
	LET _monto_neto  = 0;
	
	FOREACH
	 SELECT no_reclamo,
			monto,
			periodo,
			no_tranrec,
			cod_tipotran
	   INTO _no_reclamo,
			_monto_total,
			_peri,
			_no_tranrec,
			_cod_tipotran
	   FROM rectrmae
	  WHERE cod_compania = 001
		AND actualizado  = 1
		AND cod_tipotran IN ('004','005','006','007')
	    and periodo     	<= a_periodo 
	--	AND monto        <> 0
		AND no_reclamo = a_no_reclamo

		-- Informacion de Coaseguro

		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM reccoas
		 WHERE no_reclamo   = _no_reclamo
		   AND cod_coasegur = _cod_coasegur;

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 0;
		END IF

		-- Informacion de Reaseguro

		LET _porc_reas = 0;
		
		FOREACH
		 select	porc_partic_suma
		   into _porc_reas
		   from rectrrea
		  where no_tranrec    = _no_tranrec
			and tipo_contrato = 1
			EXIT FOREACH;
		END FOREACH
		  
		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;

		SELECT periodo
		  INTO _periodo_rec
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;
		 
		FOREACH
			SELECT cod_cobertura,
			       monto
			  INTO _cod_cobertura,
			       _monto_total
			  FROM rectrcob
			 WHERE no_tranrec = _no_tranrec
			   AND monto <> 0

			-- Calculos

			LET _monto_bruto = _monto_total / 100 * _porc_coas;
			LET _monto_neto  = _monto_bruto / 100 * _porc_reas;

			-- Actualizacion del Movimiento
			let _pago_y_ded   = 0.00;
			let _salv_y_recup = 0.00;
			let _cant_pago = 0;
			
			if _cod_tipotran in('004','007') then --Pago y deducible
				let _pago_y_ded = _monto_bruto;
			elif  _cod_tipotran in('005','006') then --Salvamento y Recupero
				let _salv_y_recup = _monto_bruto;
			end if	
			
			if _cod_tipotran = '004' then
				let _cant_pago = 1;
			end if

			INSERT INTO tmp_reclamo_jb
			values(
			_no_reclamo,
			_cod_cobertura,
			0,
			0,
			0,
			_monto_total,
			_monto_bruto,
			_monto_neto,
			_peri);
		END FOREACH
	END FOREACH


END FOREACH

BEGIN
	DEFINE _pagado_total  DEC(16,2);
	DEFINE _pagado_bruto  DEC(16,2);
	DEFINE _pagado_neto   DEC(16,2);
		
	FOREACH WITH HOLD
	  
		SELECT SUM(pagado_total),
		       SUM(pagado_bruto), 
		       SUM(pagado_neto),
			   sum(reserva_total),
			   no_reclamo,
		       cod_cobertura
	      INTO _pagado_total,	
			   _pagado_bruto,
			   _pagado_neto,
			   _reserva_actual,
			   _no_reclamo,
			   _cod_cobertura
	      FROM tmp_reclamo_jb
	  GROUP BY no_reclamo, cod_cobertura
	  
	  SELECT numrecla,
	         no_documento,
	         no_motor,
   		     perd_total,
			 estatus_reclamo,
			 cod_asegurado,
			 no_poliza,
			 no_unidad,
			 fecha_siniestro,
			 ajust_interno,
			 fecha_reclamo
		INTO _numrecla,
		     _no_documento,
	         _no_motor,
   		     _perd_total,
			 _estatus_reclamo,
			 _cod_asegurado,
			 _no_poliza,
			 _no_unidad,
			 _fecha_siniestro,
			 _ajust_interno,
			 _fecha_reclamo
		FROM recrcmae
	   WHERE no_reclamo = _no_reclamo;
	   	   
	 select nombre
	   into _asegurado
	   from cliclien
	  where cod_cliente = _cod_asegurado;
	  
		if _estatus_reclamo = 'A' then
			let _estatus = 'ABIERTO';
		elif _estatus_reclamo = 'C' then
			let _estatus = 'CERRADO';
		elif _estatus_reclamo = 'D' then
			let _estatus = 'DECLINADO';
		else
			let _estatus = 'NO APLICA';
		end if
	  
	 select deducible
	   into _deducible
	   from recrccob
	  where no_reclamo = _no_reclamo
	    and cod_cobertura = _cod_cobertura;
	  
	 select nombre
	   into _cobertura
	   from prdcober
	  where cod_cobertura = _cod_cobertura;

     if _perd_total = 1 then
		let _perdida = "PERDIDA TOTAL";
	 else
		let _perdida = "PERDIDA PARCIAL";
	 end if

	 let _uso_auto = null;
	 
	 select uso_auto
	   into _uso_auto
	   from emiauto
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad;
		
     if _uso_auto is null or trim(_uso_auto) = "" then
		foreach
			 select uso_auto
			   into _uso_auto
			   from endmoaut
			  where no_poliza = _no_poliza
				and no_unidad = _no_unidad
			 exit foreach;
		end foreach
	 end if
	 
     select cod_marca,
	        cod_modelo
	   into _cod_marca,
	        _cod_modelo
	   from emivehic
	  where no_motor = _no_motor;
	 
	let _marca = null;
	let _modelo = null;

	if _cod_marca is null then
		let _cod_marca = "";
	else
		select nombre
		  into _marca
		  from emimarca
		 where cod_marca = _cod_marca;
	end if

	if _cod_modelo is null then
		let _cod_modelo = "";
	else
		select nombre
		  into _modelo
		  from emimodel
		 where cod_marca  = _cod_marca
		   and cod_modelo = _cod_modelo;
	end if
	
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		
		exit foreach;
	end foreach
	
	select nombre
	  into v_desc_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	select nombre
	  into _ajustador
	  from recajust
	 where cod_ajustador = _ajust_interno;
		  
	  RETURN _numrecla,
	         _no_reclamo,
	         _cod_asegurado,
			 _asegurado,
   	         _pagado_total,
             _cod_cobertura,
			 _cobertura,
			 _estatus,
			 v_desc_agente,
			 _perdida,
			 _deducible,
			 _no_documento,
			 _ajustador,
			 _fecha_siniestro,
			 _marca,
			 _modelo,
			 (case when _uso_auto = "P" then "PARTICULAR" else "COMERCIAL" end),
			 _fecha_reclamo,
			 _reserva_actual
			 WITH RESUME;
    END FOREACH
END	
  
DROP TABLE tmp_reclamo_jb;
DROP TABLE tmp_pendiente_jb;




END PROCEDURE;
