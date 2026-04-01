--************************************************************
-- Procedimiento que Carga las Bonificaciones de cobranza 2011
--************************************************************

-- Creado    : 27/02/2008 - Autor: Armando Moreno M.
-- Modificado: 27/02/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_che81("001","001","2010-02","informix")

DROP PROCEDURE sp_che81;

CREATE PROCEDURE sp_che81
(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_periodo		    CHAR(7),
a_usuario           CHAR(8)
)
RETURNING SMALLINT;

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_subramo     char(3); 
define _cod_origen      char(3); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50);
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
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
define _fecha_hoy       date;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define _prima_45        DEC(16,2);
define _prima_90		DEC(16,2);
define _prima_r  		DEC(16,2);
define _prima_rr  		DEC(16,2);
define _formula_a  		DEC(16,2);
define _cnt             integer;
define v_monto_30bk		DEC(16,2);
define v_corr			DEC(16,2);
DEFINE _formula_b       DEC(16,2);
define _comision1       DEC(16,2);
define _comision2       DEC(16,2);
define _prima_bruta     DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);				   
define _cedula_paga		char(30);				   
define _cedula_cont		char(30);				   
define _cod_pagador     char(10);				   
define _cod_contratante char(10);				   
define _estatus_licencia char(1);				   
define v_nombre_clte     char(100);				   
define _cod_contr        char(10);
define _error           smallint;				   
define _monto_m			DEC(16,2);				   
define _monto_p			DEC(16,2);				   
define _suc_origen      char(3);				   
define _beneficios      smallint;				   
define _contado         smallint;				   
define _dias            integer;
define _fecha_decla     date;
define _mess            integer;
define _anno            integer;
define _f_ult           date;
define _f_decla_ult     date;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _concurso        smallint;
define _agente_agrupado char(5);
define _prima_cobrada   dec(16,2);
define _prima_cobrada2   dec(16,2);
define _retro            smallint;
define a_periodo_ini    char(7);
define _cod_agente1     char(5);
define _declarativa     smallint;
define _valor           integer;

--SET DEBUG FILE TO "sp_che81.trc";
--TRACE ON;

let _error   = 0;
let _porc_coas_ancon = 0;
let _forma_pag      = 0;
let _porc_comis     = 0;
let _porc_comis2    = 0;
let _prima_45       = 0;
let _prima_90       = 0;
let _cnt            = 0;
let _monto_m        = 0;
let _monto_p        = 0;
let _prima_bruta    = 0;
let _prima_cobrada  = 0;
let _prima_cobrada2 = 0;
let _retro          = 0;
let _declarativa    = 0;
let _valor          = 0;
let a_periodo_ini   = "2011-01";


--return 1;

CREATE TEMP TABLE tmp_boni(
	cod_agente		CHAR(15),
	no_poliza		CHAR(10),
	monto           DEC(16,2),
	prima           DEC(16,2),
	fecha           DATE,
	contado         smallint default 0,
	PRIMARY KEY		(cod_agente, no_poliza)
	) WITH NO LOG;

CREATE INDEX i_boni1 ON tmp_boni(cod_agente);
CREATE INDEX i_boni2 ON tmp_boni(no_poliza);

SET ISOLATION TO DIRTY READ;

delete from chqboni
 where periodo = a_periodo;

let _valor = sp_che108a(a_compania,a_sucursal,a_periodo); --06/04/2010,acumula prima cobrada hasta mes que se va a pagar, para luego evaluar si cumple para el bono.

if _valor <> 0 then
	return 1;
end if

SELECT sum(c.prima_cobrada)
  INTO _prima_cobrada2
  FROM chqboagt c, agtagent h
 WHERE c.cod_agente = h.cod_agente
   AND h.agente_agrupado = "01727";	--01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina

FOREACH
	select cod_agente,
	       sum(prima_cobrada),
		   retroactivo
	  into _cod_agente,
	       _prima_cobrada,
		   _retro
	  from chqboagt
	 group by cod_agente,retroactivo
	 order by cod_agente,retroactivo

	  if _cod_agente in("01221","01727") then 	   --01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 
		 let _prima_cobrada = _prima_cobrada2;
	  end if

	  if _prima_cobrada >= 35000 or _retro = 1 then	--si es >= a 35000, se toma en cuenta al corredor para el pago.
	  else
	  	{if _cod_agente1 in("01001","01002","01609","01005","01000") then --Grupo Abadia 24/05/2010 Armando
			update chqboagt
			   set retroactivo = 1
			 where agente_agrupado = _cod_agente1;

			let _retro = 1;
		else
			continue foreach;
		end if}
		continue foreach;
	  end if


	if _retro = 0 then  --Le voy a pagar retroactivo
		update chqboagt
		   set retroactivo   = 1,
		       periodo_hasta = a_periodo
		 where cod_agente    = _cod_agente;

		let a_periodo_ini  = "2011-01";
	else
		let a_periodo_ini  = a_periodo;
	end if


		FOREACH
			 SELECT	d.no_poliza,
			        d.no_remesa,
			        d.renglon,
			        d.no_recibo,
			        d.fecha,
			        d.monto,
			        d.prima_neta,
			        d.tipo_mov,
					m.cod_banco,
					m.cod_chequera,
					c.porc_partic_agt
			   INTO	_no_poliza,
				    _no_remesa,
				    _renglon,
				    _no_recibo,
				    _fecha,
				    _monto,
				    _prima,
				    _tipo_mov,
					_cod_banco,
					_cod_chequera,
					_porc_partic
			   FROM	cobredet d, cobremae m, cobreagt c
			  WHERE	d.no_remesa    = m.no_remesa
			    AND d.no_remesa    = c.no_remesa
			    AND d.renglon      = c.renglon
			    AND d.cod_compania = a_compania
			    AND d.actualizado  = 1
				AND d.tipo_mov     IN ('P','N')
				AND (month(d.fecha) >= a_periodo_ini[6,7]
				AND  month(d.fecha) <= a_periodo[6,7])
				AND year(d.fecha)  = a_periodo[1,4]
				AND m.tipo_remesa  IN ('A', 'M', 'C')
				AND c.cod_agente   = _cod_agente
		      ORDER BY d.fecha,d.no_recibo,d.no_poliza

			  select cod_grupo, cod_ramo, cod_pagador, cod_contratante,no_documento,sucursal_origen,prima_bruta,cod_subramo,declarativa
			    into _cod_grupo,_cod_ramo,_cod_pagador,_cod_contratante,_no_documento,_suc_origen,_prima_bruta,_cod_subramo,_declarativa
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
			  end if

			  if _concurso = 0 then
			  	continue foreach;
			  end if

			  let _contado = 0;
			  if _cod_banco = "146" then -- caja
					if _cod_chequera = "025" or _cod_chequera = "026" or _cod_chequera = "027" then  --Pago por cobrador rutero
						let _contado = 1;
					end if
			  end if

			  if _cod_ramo = '009' then	  --No va poliza declarativa de Transporte
				if _declarativa = 1 then
					INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Se excluye Pol. Declarativa Transporte.');
					continue foreach;
				end if
			  end if

			  if _cod_ramo = '008' or _cod_ramo = '019' or _cod_ramo = '018' then	  --No va poliza de Fianzas ni vida individual ni Salud
				INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Se excluye Pol. Fianza,Vida Ind.,Salud.');
				continue foreach;
			  end if

			  select cedula
			    into _cedula_paga
			    from cliclien
			   where cod_cliente = _cod_pagador;

			  select cedula
			    into _cedula_cont
			    from cliclien
			   where cod_cliente = _cod_contratante;
			   
			  if _cod_grupo = "00000" then --excluir estado
				INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Se excluye Grupo del Estado.');
				continue foreach;
			  end if  	

			  select count(*)
			    into _cnt
			    from emifafac
			   where no_poliza = _no_poliza;

			  if _cnt > 0 then		--los facultativos se excluyen
				INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'No se permite Facultativos.');
				continue foreach;
			  end if

			  --EXCLUIR DEL CORREDOR TECNICA GRUPO SUNCTRACS RAMO COLECTIVO DE VIDA

			  if _cod_agente  = "00180" and  -- Tecnica de Seguros	--Puesto por Armando, Solicitado por Demetrio segun correo enviado por meleyka 08/09/2011
				 _cod_ramo    = "016"	and  -- Colectivo de vida
				 _cod_grupo   = "01016" then -- Grupo Suntracs

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

			  if _cod_agente in("01221","01727") then 	   --01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 
					let _cod_agente = _agente_agrupado; 
			  end if

			  {if _agente_agrupado <> "01068" then  --FF SEGUROS NO APLICA
			   else
			   		continue foreach;
			   end if}

				--no tomar en cuenta polizas de colectivo de vida grupo suntracs de corredor tecnica de seguros. realizado 15/03/2010 Armando
				{if _cod_agente = "00180" then --Tecnica de seguros
				   if _cod_ramo = '016'	and _cod_grupo = "01016" then  --Colectivo de vida y grupo Suntracs
						continue foreach;
				   end if
				end if}

				--no tomar en cuenta polizas suc origen  075 del corredor ducruet ramo soda. realizado 15/03/2010 Armando
				{if _cod_agente = "00035" then --Ducruet
				   if _cod_ramo = "020" and _suc_origen = "075" then
						continue foreach;
				   end if
				end if}

				{if trim(_cedula_agt) = trim(_cedula_paga) then
					INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Cedula del corredor igual a la del pagador.');
					continue foreach;
				end if}
				
				{if trim(_cedula_agt) = trim(_cedula_cont) then
				   	INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Cedula del corredor igual a la del contratante.');
					continue foreach;
				end if}

				IF _tipo_agente <> "A" then	--solo agentes
					INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Solo se permite Corredores, en el tipo de Agente.');
					continue foreach;
				END IF

				IF _estatus_licencia <> "A" then  --El corredor debe estar activo
					INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'El Corredor debe estar activo.');
					continue foreach;
				END IF

				LET _monto_m = _monto * (_porc_partic / 100);
				LET _monto_p = _prima * (_porc_partic / 100);

				BEGIN

					ON EXCEPTION IN(-239)

					   	UPDATE tmp_boni
						   SET monto      = monto + _monto_m,
						       prima      = prima + _monto_p
						 WHERE cod_agente = _cod_agente
						   AND no_poliza  = _no_poliza;

					END EXCEPTION

					INSERT INTO tmp_boni(cod_agente,no_poliza,monto,prima,fecha,contado)
				    VALUES(_cod_agente,_no_poliza,_monto_m,_monto_p,_fecha,_contado);

				END

		END FOREACH

END FOREACH

FOREACH

	 select cod_agente,
	        no_poliza,
	        sum(monto),
			sum(prima)
	   into _cod_agente,
	        _no_poliza,
			_monto_m,
			_monto_p
	   from tmp_boni
	  group by 1, 2

	 select fecha
	   into	_fecha_hoy
	   from tmp_boni
	  where cod_agente = _cod_agente
	    and no_poliza  = _no_poliza;

	 select sum(contado)
	   into	_contado
	   from tmp_boni
	  where no_poliza  = _no_poliza;

	 SELECT nombre,
	        no_licencia
	   INTO _nombre,
	        _no_licencia
	   FROM agtagent
	  WHERE cod_agente = _cod_agente;

	 SELECT no_documento,
		    cod_tipoprod,
		    cod_ramo,
		    incobrable,
		    cod_formapag,
			cod_subramo,
			cod_origen,
			cod_contratante
	   INTO _no_documento,
		    _cod_tipoprod,
		    _cod_ramo,	
		    _incobrable,
		    _cod_formapag,
			_cod_subramo,
			_cod_origen,
			_cod_contr
	   FROM emipomae
	  WHERE no_poliza = _no_poliza;

	if _monto_m <= 0 then
		 INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'No se perimite montos menores o igual a cero.');
	 	 continue foreach;
	end if

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _tipo_prod = 4 THEN	-- No Incluye Reaseguro Asumido
	   INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Se excluye reaseguro asumido.');
	   CONTINUE FOREACH;
	END IF

	IF _tipo_prod = 3 THEN	--coas minoritario
	   INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Se excluye Coaseg. Minoritario.');
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
	
	SELECT cod_tiporamo
	  INTO _cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo; 	

	SELECT tipo_ramo
	  INTO _tipo_ramo
	  FROM prdtiram
	 WHERE cod_tiporamo = _cod_tiporamo;

	--Buscar forma de pago
	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	if _tipo_forma <> 2 and _tipo_forma <> 3 and _tipo_forma <> 4 then	--2=visa,3=desc salario,4=ach
		let _forma_pag = 0;		--es voluntario
	else
		let _forma_pag = 1;		--es electronico
		--if _cod_agente in("01001","01002","01609","01005","01000") then --Grupo Abadia 24/05/2010 Armando
		--else
		continue foreach;
	   -- end if
	end if

	let _prima_r     = 0;
	let _prima_rr    = 0;
	let _formula_a   = 0;
	let _porc_comis  = 0;
	let _porc_comis2 = 0;
	let _prima_45    = 0;
	let _prima_90    = 0;
	let _formula_b   = 0;
	let v_corriente  = 0;
	let v_monto_30   = 0;
	let v_monto_60   = 0;
	let v_corr       = 0;
	let v_monto_30bk = 0;

	let _prima_r = _monto_p;
	let _prima_r = (_porc_coas_ancon * _prima_r) / 100;

    if _prima_r is null then
		let _prima_r = 0;
	end if

   	CALL sp_cob33e(a_compania,a_sucursal,_no_documento,a_periodo,_fecha_hoy) RETURNING v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_60,v_saldo;

	let v_corriente = (v_corriente * _porc_coas_ancon) / 100;
	let v_monto_30  = (v_monto_30  * _porc_coas_ancon) / 100;
	let v_monto_60  = (v_monto_60  * _porc_coas_ancon) / 100;

	let v_corr       = v_corriente;
	let v_monto_30bk = v_monto_30;

	--if _cod_agente in("01001","01002","01609","01005","01000") then --Grupo Abadia 24/05/2010 Armando
	--else
  	if v_monto_60 > 0 then	 --Morosidad > 90 no se debe tomar en cuenta
	    INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Se excluye Morosidad a mas de 90.');
		continue foreach;
	end if
	--end if
	if _contado = 1 then --pago por cobrador rutero
		let _porc_comis2 = 1;
	else
		let _porc_comis2 = 3;
	end if
	{if _cod_agente in("01001","01002","01609","01005","01000") then --Grupo Abadia 24/05/2010 Armando
		if _cod_ramo = "002" or _cod_ramo = "020" then              --5% para ramo auto o soda Grupo Abadia
			let _porc_comis2 = 5;
		end if
	end if}

	let _formula_a = _prima_r * (_porc_comis2 / 100);

    SELECT nombre
      INTO v_nombre_clte
      FROM cliclien
     WHERE cod_cliente = _cod_contr;

	let v_corriente = v_corr;

		INSERT INTO chqboni(
		cod_agente,
		no_poliza,
		monto,
		prima,
		comision,
		nombre,
		no_documento,
		no_licencia,
		seleccionado,
		periodo,
		fecha_genera,
		moro_045,
		moro_4690,
		porc_045,
		porc_4690,
		pol_corr,
		pol_0045,
		pol_4690,
		cod_ramo,
		cod_subramo,
		cod_origen,
		comis0045,
		comis4690,
		nombre_cte)
		VALUES (
		_cod_agente,
		_no_poliza,
		_monto_m,
		_monto_p,
		_formula_a,
		_nombre,
		_no_documento,
		_no_licencia,
		0,
		a_periodo,
		current,
		_prima_r,
		_prima_90,
		_porc_comis,
		_porc_comis2,
		v_corriente,
		v_monto_30,
		v_monto_60,
		_cod_ramo,
		_cod_subramo,
		_cod_origen,
		_formula_b,
		_formula_a,
		v_nombre_clte
		);

END FOREACH

foreach

	SELECT cod_agente
	  INTO _cod_agente
	  FROM chqboni
     WHERE periodo = a_periodo
	 GROUP BY cod_agente
	 ORDER BY cod_agente

 	call sp_che82(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;

	if _error <> 0 then
		return _error;
	end if

end foreach

update parparam
   set ult_per_boni = a_periodo
 where cod_compania = a_compania;


DROP TABLE tmp_boni; 

return 0;
END PROCEDURE;