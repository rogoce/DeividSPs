--***************************************************************--
-- Procedimiento que acumula primas cobradas del mes que se esta pagando a la tabla chqboagt   2011
--
-- se modifico para que la prima a usar sea la de nuestra participacion. 24/02/2010
--***************************************************************--

-- Creado    : 06/04/2010 - Autor: Armando Moreno M.
-- Modificado: 06/04/2010 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che108aa;

CREATE PROCEDURE sp_che108aa(a_compania CHAR(3),a_sucursal CHAR(3), a_periodo char(7))
RETURNING SMALLINT;

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
define _error           smallint;
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
define _cod_subramo     char(3);
define _concurso        smallint;
define _declarativa     smallint;
define _agente_agrupado char(5);
define _no_documento    char(20);

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

SET ISOLATION TO DIRTY READ;

FOREACH

 SELECT	d.no_poliza,
		d.no_remesa,
		d.renglon,
		d.no_recibo,
		d.fecha,
		d.monto,
		d.prima_neta,
		d.tipo_mov
   INTO	_no_poliza,
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
		   cod_formapag
	  into _cod_grupo,
	       _cod_ramo,
	       _cod_pagador,
	       _cod_contratante,
	       _cod_subramo,
		   _declarativa,
		   _no_documento,
		   _cod_formapag
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

	if _cod_ramo = "016" then	--se incluye colectivo de vida Meleyka 05/07/2011
		let _concurso = 1;
	else
		continue foreach;
	end if

	if _concurso = 0 then		 --excluir Ramos
		continue foreach;
	end if

	if _cod_grupo = "00000" then --excluir estado
		continue foreach;
	end if  	

	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;

	if _cnt > 0 then		--excluir los facultativos
		continue foreach;
	end if

	if _cod_ramo = '009' then	  --No va poliza declarativa de Transporte
		if _declarativa = 1 then
			continue foreach;
		end if
	end if

	if _cod_ramo = '008' or _cod_ramo = '019' or _cod_ramo = '018' then	  --No va poliza de Fianzas ni vida individual ni Salud
		continue foreach;
	end if

	{select cedula
	  into _cedula_paga
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select cedula
	  into _cedula_cont
	  from cliclien
	 where cod_cliente = _cod_contratante;}

   select cod_tipoprod
     into _cod_tipoprod
     from emipomae
    where no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _tipo_prod = 4 THEN	-- excluir Reaseguro Asumido
	   CONTINUE FOREACH;
	END IF

	IF _tipo_prod = 3 THEN	--excluir coas minoritario
	   CONTINUE FOREACH;
	END IF

   if _tipo_prod = 2 then  --coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = "036";    --ancon
   else
		let _porc_coas_ancon = 100;
   end if

	--Buscar forma de pago
	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	if _tipo_forma <> 2 and _tipo_forma <> 3 and _tipo_forma <> 4 then	--2=visa,3=desc salario,4=ach
	else
		continue foreach;  --electronico no va
	end if

   let _prima_r = (_porc_coas_ancon * _prima) / 100;

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

		if _cod_agente IN("01006","00081") then
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

	   {	if trim(_cedula_agt) = trim(_cedula_paga) then
			continue foreach;
		end if
		
		if trim(_cedula_agt) = trim(_cedula_cont) then
			continue foreach;
		end if }

		IF _tipo_agente <> "A" then	--solo agentes
			continue foreach;
		END IF

		IF _estatus_licencia <> "A" then  --El corredor debe estar activo
			continue foreach;
		END IF

	  LET _prima_neta = 0;
	  let _monto_b    = 0;
	  let _prima_n    = 0;
	  LET _prima_neta = _prima_r * (_porc_partic / 100);
	  let _monto_b    = _monto   * (_porc_partic / 100);
	  let _prima_n    = _prima   * (_porc_partic / 100);

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
		agente_agrupado
		)
		VALUES(
		_cod_agente,
		_prima_neta,
		_monto_b,
		_prima_n,
		_agente_agrupado
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