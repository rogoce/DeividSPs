--***************************************************************--
-- Procedimiento que acumula primas cobradas del mes que se esta pagando a la tabla chqboagt
-- se modifico para que la prima a usar sea la de nuestra participacion. 24/02/2010
--***************************************************************--

-- Creado    : 05/02/2019 - Autor: Armando Moreno M.
-- Modificado: 05/02/2019 - Autor: Armando Moreno M.

DROP PROCEDURE sp_che108a;
CREATE PROCEDURE sp_che108a(a_compania CHAR(3),a_sucursal CHAR(3), a_periodo char(7))
RETURNING INTEGER;

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_origen      char(3); 
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _nombre          CHAR(50); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50); 
define _forma_pag		smallint;
define _fecha_desde     date;
define _fecha_hasta     date;
define v_corr			DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
DEFINE _periodo_ant     CHAR(7);
define _mes_ant			smallint;
define _ano_ant			smallint;
define _prima_neta		DEC(16,2);
define _vigencia_inic   date;
define _vigencia_final  date;
define _fecha_cancelacion date;
define _renglon         smallint;
define _nueva_renov     char(1);
define _flag            smallint;
define _saldo           dec(16,2);
define _per_cero        char(7);
define _no_remesa       char(10);
define _no_recibo       char(10);
define _cnt             smallint;
define _prima_r         DEC(16,2);
define _monto_b         DEC(16,2);
define _prima_n         DEC(16,2);
define _cod_subramo,_cod_sucursal     char(3);
define _concurso        smallint;
define _declarativa     smallint;
define _agente_agrupado char(5);
define _no_documento    char(20);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define v_por_vencer     DEC(16,2);
define v_exigible       DEC(16,2);
define v_corriente		DEC(16,2);
define v_monto_30		DEC(16,2);
define v_monto_60		DEC(16,2);
define v_monto_45		DEC(16,2);
define v_saldo          DEC(16,2);
define _es_mensual      smallint ;
define _desde			char(7);
define _hasta           char(7);
define _fecha_ini		date;
define _fecha_fin		date;
define _fecha_anulado   date;
define _pagado          smallint;
define _monto_dev       dec(16,2);
define _no_requis		char(10);
define _monto_fac_ac    dec(16,2);
define _monto_fac       dec(16,2);
define _porc_partic_prima dec(16,2);
define _porc_proporcion   dec(16,2);

on exception set _error, _error_isam, _error_desc
   return _error;
end exception


--SET DEBUG FILE TO "sp_che108a.trc";
--TRACE ON;

let _error           = 0;
let _porc_coas_ancon = 0;
let _prima_neta      = 0;
let _cnt             = 0;
let _prima_r         = 0;
let _monto_b         = 0;
let _prima_n         = 0;
let _declarativa     = 0;
let v_por_vencer	 = 0;
let	v_exigible  	 = 0;
let	v_corriente		 = 0;
let	v_monto_30		 = 0;
let	v_monto_60		 = 0;
let	v_saldo     	 = 0;
let _monto_dev 		 = 0;
let _monto_fac_ac    = 0;
let _monto_fac		 = 0;
let _porc_proporcion = 0;
let _porc_partic_prima = 0;

let _desde = null;
let _hasta = null;

SET ISOLATION TO DIRTY READ;
let _fecha_fin = sp_sis36(a_periodo);
let _fecha_ini = sp_sis40b(a_periodo);
FOREACH
	SELECT d.no_poliza,
		   d.no_remesa,
		   d.renglon,
		   d.no_recibo,
		   d.fecha,
		   d.monto,
		   d.prima_neta,
		   d.tipo_mov
	  INTO _no_poliza,
		   _no_remesa,
		   _renglon,
		   _no_recibo,
		   _fecha,
		   _monto,
		   _prima,
		   _tipo_mov
	  FROM	cobredet d, cobremae m
	 WHERE	d.cod_compania = a_compania
	   AND d.actualizado  = 1
	   AND d.tipo_mov     IN ('P','N')
	   AND month(d.fecha) = a_periodo[6,7]
	   AND year(d.fecha)  = a_periodo[1,4]
	   AND d.no_remesa    = m.no_remesa
	   AND m.tipo_remesa  IN ('A', 'M', 'C')
	 ORDER BY d.fecha,d.no_recibo,d.no_poliza

	select cod_grupo,
	       cod_ramo,
	       cod_pagador,
	       cod_contratante,
	       cod_subramo,
		   declarativa,
		   no_documento,
		   cod_formapag,
		   cod_tipoprod,
		   cod_sucursal
	  into _cod_grupo,
	       _cod_ramo,
	       _cod_pagador,
	       _cod_contratante,
	       _cod_subramo,
		   _declarativa,
		   _no_documento,
		   _cod_formapag,
		   _cod_tipoprod,
		   _cod_sucursal
	  from emipomae
	 where no_poliza = _no_poliza;

	select concurso
	  into _concurso
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	if _concurso is null then
		let _concurso = 0;
	end if
	if _concurso = 0 then		 --excluir Ramos
		continue foreach;
	end if
	if _cod_ramo = '009' then	  --No va poliza declarativa de Transporte
		if _declarativa = 1 then
			continue foreach;
		end if
	end if
	if _cod_ramo in('019','018','016','008') then	  --No va poliza de vida individual ni Salud ni colectivas de salud ni fianzas
		continue foreach;
	end if
	if _cod_ramo = '001' and _cod_subramo = '006' then	  --No va poliza de Incendio subramo ZonaLibre
		continue foreach;
	end if
	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _tipo_prod in(4,3) THEN	-- excluir Reaseguro Asumido,excluir coas minoritario
	   CONTINUE FOREACH;
	END IF

    if _tipo_prod = 2 then  -- coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = "036";    --ancon
    else
		let _porc_coas_ancon = 100;
    end if

	if _cod_grupo = '77850' then --Excluir grupo Traspaso Assa - Generali - Banisi correo 17/10/2019 Daivis F.
		continue foreach;
	end if
	--Buscar forma de pago
	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

    let _prima_r = (_porc_coas_ancon * _prima) / 100;

   	CALL sp_cob33e(a_compania,a_sucursal,_no_documento,a_periodo,_fecha) RETURNING v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_45,v_monto_60,v_saldo;

	let v_monto_30  = (v_monto_30  * _porc_coas_ancon) / 100;
	let v_monto_45  = (v_monto_45  * _porc_coas_ancon) / 100;
	let v_monto_60  = (v_monto_60  * _porc_coas_ancon) / 100;

	-- devoluciones de prima
	foreach
		SELECT monto,
			   no_requis
		  into _monto_dev, 
			   _no_requis
		  FROM chqchpol
		 WHERE no_poliza = _no_poliza
		 
		SELECT pagado,
			   fecha_anulado
		  INTO _pagado,
			   _fecha_anulado
		  FROM chqchmae
		 WHERE no_requis = _no_requis
		   and fecha_impresion between _fecha_ini and _fecha_fin;
		IF _pagado = 1 THEN
			IF _fecha_anulado IS NOT NULL THEN
				IF _fecha_anulado >= _fecha_ini and _fecha_anulado <= _fecha_fin THEN
					LET _monto_dev = 0;
				END IF
			END IF			
		ELSE
			LET _monto_dev = 0;
		END IF	

		IF _monto_dev IS NULL THEN
			LET _monto_dev = 0;
		END IF
		let _prima_r = _prima_r - _monto_dev;
	end foreach	
		
	let _monto_fac_ac = 0.00;
	--Quitar facultativo cedido
	foreach
		select porc_partic_prima,
			   porc_proporcion
		  into _porc_partic_prima,
			   _porc_proporcion
		  from cobreaco c, reacomae r
		 where c.no_remesa = _no_remesa
		   and c.renglon = _renglon
		   and r.cod_contrato = c.cod_contrato
		   and r.tipo_contrato = 3

		if _porc_partic_prima is null then
			let _porc_partic_prima = 0.00;
		end if
		
		let _monto_fac = _prima_r * (_porc_partic_prima/100) * (_porc_proporcion/100);
		let _monto_fac_ac = _monto_fac_ac + _monto_fac;
	end foreach
	
	let _prima_r = _prima_r - _monto_fac_ac;
	
	FOREACH
	 SELECT	cod_agente,
			porc_partic_agt,
			porc_comis_agt
	   INTO	_cod_agente,
			_porc_partic,
			_porc_comis
	   FROM	cobreagt
	  WHERE	no_remesa = _no_remesa
	    AND renglon   = _renglon
		
		--Se excluyen '02569','02656' segun correo Jesus 06/08/2019
		if _cod_agente in('02569','02656','02111') then	--se excluyen estos corredores por instr. Analisa, correo del 09/07/2019
			continue foreach;
		end if
		
		SELECT nombre,
		       no_licencia,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula,
			   agente_agrupado
		  INTO _nombre,
		       _no_licencia,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt,
			   _agente_agrupado
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;
		 
		--Excepcion para Directo Ducruet Banisi 02618 correo Analisa lunes 04/02/2019
		if _cod_agente in('02618','02532','02531') then
			let _tipo_agente = 'A';
			if _cod_agente in('02618') then
				let _agente_agrupado = '00035';
			end if
		end if
		if _agente_agrupado in('00035') then --DUCRUET
			if v_monto_60 > 0 then	 
				continue foreach;
			end if
		elif _cod_agente = '02569' then --Acuerdo especial con el corredor Javier Avila
			if v_monto_45 > 0 then
				continue foreach;
			end if
		else	
			if _tipo_forma = 6 then		--corredor remesa
				if v_monto_45 + v_monto_60 > 0 then	 --Morosidad > 45 no se debe tomar en cuenta
					continue foreach;
				end if	
			else
				if v_monto_30 + v_monto_45 + v_monto_60 > 0 then	 --Morosidad > 30 no se debe tomar en cuenta
					continue foreach;
				end if
			end if
		end if
		
		if _cod_agente in("02302","02354") then --Lizsenell Bernal Ramírez , código 02302 se excluye segun correo del 18/05/2016 Analisa Stanziola y 02354 segun correo Analisa 19/05/2016
			continue foreach;
		end if
		--EXCLUIR DEL CORREDOR TECNICA GRUPO SUNCTRACS RAMO COLECTIVO DE VIDA

		if _cod_agente = "00180" and  -- Tecnica de Seguros	--Puesto por Armando, Solicitado por Demetrio segun correo enviado por meleyka 08/09/2011
		   _cod_ramo   = "016"	 and  -- Colectivo de vida
		   _cod_grupo  = "01016" then -- Grupo Suntracs

		   continue foreach;

		end if
		IF _tipo_agente <> "A" then	--solo agentes
			continue foreach;
		END IF

		{IF _estatus_licencia <> "A" then  --El corredor debe estar activo
			continue foreach;
		END IF}

	  LET _prima_neta = 0;
	  let _monto_b    = 0;
	  let _prima_n    = 0;
	  LET _prima_neta = _prima_r * (_porc_partic / 100);
	  let _monto_b    = _monto   * (_porc_partic / 100);
	  let _prima_n    = _prima   * (_porc_partic / 100);

	  if _prima_neta is null then
		let _prima_neta = 0;
	  end if

	  let _es_mensual = 1;
	  let _desde = null;
	  let _hasta = null;

	  if _cod_agente = '00141' then --Si es Uniseguros, No es mensual, se le paga en Enero del sig año.
		  let _es_mensual = 0;
		  let _desde      = '2020-01';
		  let _hasta      = '2020-12';
	  end if

	  BEGIN

		ON EXCEPTION IN(-239,-268)

			UPDATE chqboagt
			   SET prima_cobrada = prima_cobrada + _prima_neta,
				   monto         = monto         + _monto_b,
				   prima_neta    = prima_neta    + _prima_n
			 WHERE cod_agente    = _cod_agente;

		END EXCEPTION

		INSERT INTO chqboagt(
		cod_agente,
		prima_cobrada,
		monto,
		prima_neta,
		agente_agrupado,
		es_mensual,
		desde,
		hasta
		)
		VALUES(
		_cod_agente,
		_prima_neta,
		_monto_b,
		_prima_n,
		_agente_agrupado,
		_es_mensual,
		_desde,
		_hasta
		);

	  END
   	INSERT INTO chqbonoc(
	cod_agente,
	prima_cobrada,
	periodo,
	no_documento
	)
	VALUES(
	_cod_agente,
	_prima_neta,
	a_periodo,
	_no_documento
	);
	END FOREACH
END FOREACH
return 0;
END PROCEDURE;