--***********************************************************************************
-- Procedimiento que genera el concurso BREEZES por corredores
--***********************************************************************************
-- execute procedure sp_che118("001","001","01/04/2010","30/04/2010","HGIRON","00035;")		
-- Creado    : 15/06/2010 - Autor: Henry Giron
-- Modificado: 15/06/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_che118bk;
CREATE PROCEDURE sp_che118bk(a_compania CHAR(3),a_sucursal CHAR(3),a_fecha1 DATE,a_fecha2 DATE,a_usuario CHAR(8),a_codagente CHAR(255) DEFAULT "*",a_codvend CHAR(255) DEFAULT "*",a_codsuc CHAR(255) DEFAULT "*")
RETURNING CHAR(15),  			-- cod_agente		
		  CHAR(100),			-- nombre_cte	 	
		  CHAR(3), 				-- cod_ramo		
		  CHAR(100), 			-- nombre_ramo		
		  DECIMAL(16,2), 		-- suma_asegurada	
		  DECIMAL(16,2), 		-- prima_sus 		
		  SMALLINT,				-- cant_pol 		
		  DECIMAL(16,2), 		-- prima_cobrada 	
		  DECIMAL(16,2), 		-- utilidad 		
		  CHAR(7),				-- periodo 		
		  DATE,					-- fecha_genera
		  CHAR(50),				-- compania	
		  CHAR(255),		    -- filtros
		  DECIMAL(16,2),		-- SUMA FALTANTE
		  INTEGER,				-- CANT POL FALTANTE
		  CHAR(3),
		  CHAR(50);

define _ano				smallint;
define _mes				smallint;
define _ano_p			char(4);
define _mes_p			char(2);
define _periodo1		char(7);
define _periodo2		char(7);
define _fecha_aa        date;
define _cod_coasegur	char(3);
define v_nombre_cia   	char(50);
define _error           smallint;
define _filtros			char(255);
define _no_documento    char(20); 
define _no_poliza       char(10);
define _cod_ramo        char(3);
define _cod_subramo     char(3);  
define _monto           DEC(16,2);
define _monto_p         DEC(16,2);
define _monto_s         DEC(16,2);
define _fecha           DATE;     
define _prima           DEC(16,2);
define _fecha_pago      date;
define _renglon         integer;
define _porc_coaseguro	dec(16,4);
define _sin_pag			DEC(16,2);
define _cod_grupo       char(5);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _cod_tipoprod    CHAR(3);  
define _tipo_prod       smallint; 
define _cod_tiporamo    CHAR(3);  
define _tipo_ramo       smallint; 
define _nueva_renov     char(1);
define _cod_agencia		char(3);
define _cnt             integer;
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define v_saldo          DEC(16,2);
define v_por_vencer     DEC(16,2);
define v_exigible       DEC(16,2);
define v_corriente      DEC(16,2);
define v_monto_30       DEC(16,2);
define v_monto_60       DEC(16,2);
define _flag            smallint;
define _cod_agente   	char(5);
define _unificar        smallint;
define _cedula_cont		char(30);
define _estatus_licencia char(1);
define _prima_sus_pag   DEC(16,2);
define _sini_incu		DEC(16,2);
define _tipo_persona	char(1);
define _nombre_tipo		char(15);
define v_monto_90       DEC(16,2);
define _prima_orig      DEC(16,2);
define _tipo_pago     	smallint;
define _nombre          CHAR(50); 
define _tipo_agente     CHAR(1);
define _total_prima_cob decimal(16,2);
define _utilidad        decimal(16,2);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _vigencia_inic	date;
define _vigencia_final	date;
define _concurso		smallint;
define _siniestralidad  dec(16,2);
define v_periodo_aa     char(7);
define _monto_30_aa		decimal(16,2);
define _suma_asegurada  decimal(16,2);
define _cod_producto	char(5);
define _tipo_mov        CHAR(1);  
define _nombre_ramo     CHAR(50);  
define _incobrable		smallint;
define _no_licencia     CHAR(10);
define _cod_formapag    char(3);
define _tipo_forma      smallint;
define _cnt_ant			integer;
define _cnt_act			integer;  
define _pri_pag         DEC(16,2);
define _cantidad        integer;
define _n_cliente       varchar(100);
define v_filtros        varchar(255);
define _tipo			char(1);
define _cod_tipo        char(1);
define _pri_sus_pag     dec(16,2);
define _cod_agente1   	char(5);
define _cnt_falta		integer;
define _suma_falta      dec(16,2);
define _n_vendedor      char(50);

--SET DEBUG FILE TO "sp_che118.trc";

let _monto_p        = 0;
let _monto_s        = 0;
let _pri_pag        = 0;
let _sin_pag        = 0;
let _siniestralidad = 0;
let _sini_incu      = 0;
let _prima_sus_pag  = 0;
let v_por_vencer    = 0;
let v_exigible	    = 0;
let v_corriente	    = 0;
let v_monto_30	    = 0;
let v_monto_60	    = 0;
let v_monto_90	    = 0;
let v_saldo         = 0;
let _cantidad       = 0;
let _prima_orig     = 0;
let _monto_30_aa    = 0;
let _cnt            = 0;
let _error          = 0;
let _suma_falta     = 0;
let _cnt_falta      = 0;

select par_ase_lider
  into _cod_coasegur
  from parparam
 where cod_compania = a_compania;
-------------------------------------------------------
-- Periodo 1
-------------------------------------------------------
let _mes = MONTH(a_fecha1);
let _ano = YEAR(a_fecha1);
let _ano_p = _ano;

IF _mes < 10 THEN
	LET _mes_p[1,1] = '0';
	LET _mes_p[2,2] = _mes;
ELSE
	LET _mes_p = _mes;
END IF

LET _periodo1[1,4] = _ano_p;
LET _periodo1[5] = "-";
LET _periodo1[6,7] = _mes_p;

LET _periodo1 = _periodo1;
-------------------------------------------------------
-- Periodo 2
-------------------------------------------------------
let _mes = MONTH(a_fecha2);
let _ano = YEAR(a_fecha2);
let _ano_p = _ano;

IF _mes < 10 THEN
	LET _mes_p[1,1] = '0';
	LET _mes_p[2,2] = _mes;
ELSE
	LET _mes_p = _mes;
END IF

LET _periodo2[1,4] = _ano_p;
LET _periodo2[5] = "-";
LET _periodo2[6,7] = _mes_p;

LET _periodo2 = _periodo2;

-------------------------------------------------------

let _fecha_aa       = sp_sis36(_periodo2);
{delete from tmp_concurso;
delete from tmp_breezes; --where periodo = _periodo2 ;
delete from tmp_40; --where periodo = _periodo2 ;  } 

create temp table tmp_concurso(
no_documento	char(20),
pri_pag			dec(16,2) 	default 0,
sin_pag         dec(16,2) 	default 0
) with no log;	 

create temp table tmp_breezes (
cod_agente 			CHAR(5), 
no_documento 		CHAR(20), 
pri_sus_pag 		DECIMAL(16,2) NOT NULL, 
sini_inc 			DECIMAL(16,2) NOT NULL,
n_agente 			VARCHAR(50), 
cod_contratante 	CHAR(10), 
n_cliente 			VARCHAR(100), 
periodo 			CHAR(7), 
pri_pag 			DECIMAL(16,2), 
monto_30_aa 		DECIMAL(16,2), 
cod_vendedor 		CHAR(3), 
nombre_vendedor 	CHAR(50), 
cod_ramo 			CHAR(3), 
nombre_ramo 		CHAR(50), 
tipo_agente 		CHAR(15), 
suma_asegurada		DECIMAL(16,2),
seleccionado		smallint default 1,
cod_sucursal        char(3)
) with no log;

create temp table tmp_40 (
cod_agente			CHAR(15),  
nombre_cte	 		CHAR(100),
cod_ramo			CHAR(3), 
nombre_ramo			CHAR(100), 
suma_asegurada	 	DECIMAL(16,2), 
prima_sus 			DECIMAL(16,2), 
cant_pol 			SMALLINT,
prima_cobrada 		DECIMAL(16,2), 
utilidad 			DECIMAL(16,2), 
periodo 			CHAR(7),
fecha_genera		DATE,
suma_falta      	DECIMAL(16,2) default 0,
cant_pol_falta      SMALLINT default 0,
cod_vendedor        char(3),
cod_sucursal        char(3)
) with no log; 	 

SET ISOLATION TO DIRTY READ;
LET  v_nombre_cia = sp_sis01(a_compania); 

-------------------------------------------------------
INSERT INTO tmp_concurso(no_documento,pri_pag,sin_pag)
SELECT DISTINCT no_documento,0,0
  FROM emipomae
 WHERE actualizado = 1
   AND fecha_suscripcion between a_fecha1 and a_fecha2
   AND nueva_renov = "N"
   AND cod_ramo in ("001","003","002","020");

--*********************************
-- Siniestros Pagados Año Actual --
--*********************************
call sp_rec01(a_compania, a_sucursal, _periodo1, _periodo2,"*","*","001,002,003,020;",a_codagente,"*","*","*","*" ) returning _filtros;

--TRACE ON;

FOREACH WITH HOLD
	   SELECT no_documento
		 INTO _no_documento
		 FROM tmp_concurso
	 ORDER BY no_documento

		let _no_poliza = sp_sis21(_no_documento);
		let _monto_p   = 0;
		let _monto_s   = 0;

		SELECT cod_ramo,
		       cod_subramo
	      INTO _cod_ramo,
		       _cod_subramo
		  FROM emipomae
	     WHERE no_poliza = _no_poliza;

	    if  _cod_ramo in ("001","003")  then			  -- INCENDIO o MULTIRIESGO
			if  _cod_subramo in ("001","002")  then		  -- RESIDENCIAL o COMERCIAL
			else
				continue foreach;
			end if
	    else
			if  _cod_ramo in ("002","020")	then		  -- AUTO o SODA
			else
				continue foreach;
			end if
	    end if

		--**********************
		-- Prima Pagada       --  						
		--**********************

		foreach
		 select prima_neta,
				fecha,
				renglon,
				no_poliza
		   into _monto,
				_fecha_pago,
				_renglon,
				_no_poliza
		   from cobredet
		  where doc_remesa  = _no_documento
		    and periodo     >= _periodo1
		    and periodo     <= _periodo2
			and actualizado = 1
			and tipo_mov    in ("P","N")			
		  
			select cod_tipoprod
			  into _cod_tipoprod
			  from emipomae
			 where no_poliza = _no_poliza;

			if _cod_tipoprod = "004" then
				continue foreach;
			end if

			if _cod_tipoprod = "001" then

				select porc_partic_coas
				  into _porc_coaseguro
				  from emicoama
				 where no_poliza    = _no_poliza
				   and cod_coasegur = _cod_coasegur;

				if _porc_coaseguro is null then
					let _porc_coaseguro = 0.00;
				end if

				let _monto = _monto * (_porc_coaseguro / 100);
			end if

			insert into tmp_concurso(no_documento, pri_pag,sin_pag)
			values (_no_documento, _monto, 0);

		end foreach

		foreach

			 select pagado_bruto   
			   into _sin_pag
			   from tmp_sinis
			  where doc_poliza   = _no_documento
			    and seleccionado = 1

			  insert into tmp_concurso(no_documento, pri_pag, sin_pag)
			  values (_no_documento,0, _sin_pag);

		end foreach

END FOREACH
Drop table tmp_sinis;
--Drop table tmp_incurrido;

--TRACE Off;

let _cnt = 0;
--/***************************************/
--	Se acumulan los totales por periodo
--/***************************************/
foreach
	 select no_documento,
			sum(pri_pag),
			sum(sin_pag)
	   into _no_documento,
			_pri_pag,
			_sin_pag
		from tmp_concurso 
	group by no_documento
	order by no_documento

   	let _no_poliza = sp_sis21(_no_documento);
	let _suma_asegurada = 0;

	 select cod_grupo, 
			cod_ramo, 
			cod_pagador, 
			cod_contratante, 
			cod_tipoprod,
			sucursal_origen,
			cod_subramo,
			nueva_renov
	   into _cod_grupo,
			_cod_ramo,
			_cod_pagador,
			_cod_contratante,
			_cod_tipoprod,
			_cod_agencia,
			_cod_subramo,
			_nueva_renov
		from emipomae
	   where no_poliza   = _no_poliza
	     and actualizado = 1;

	 if _cod_grupo = "00000" then  -- Excluir estado
		continue foreach;
	 end if

	 select cedula
	   into _cedula_paga
	   from cliclien
	  where cod_cliente = _cod_pagador;

	 select cedula,
			nombre
	   into _cedula_cont,
		    _n_cliente
	   from cliclien
	  where cod_cliente = _cod_contratante;

	 let _flag = 0;

	 foreach
		SELECT cod_agente
		  INTO _cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza

           let _unificar = 0;	 -- 01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente = _cod_agente
		   AND agente_agrupado = "01727";

		   if _unificar <> 0 then
			   let _cod_agente = "01727";
		   end if

		SELECT nombre,
			   tipo_pago,
			   tipo_agente,
			   estatus_licencia,
			   cedula
		  INTO _nombre,
			   _tipo_pago,
			   _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

			if trim(_cedula_agt) = trim(_cedula_paga) then	--Contra pagador
				 let _flag = 1;
				exit foreach;
			end if
			
			if trim(_cedula_agt) = trim(_cedula_cont) then	--Contra Contratante
				 let _flag = 1;
				exit foreach;
			end if

			IF _tipo_agente <> "A" then	--solo agentes
				 let _flag = 1;
				exit foreach;
			END IF

			IF _estatus_licencia <> "A" then  --El corredor debe estar activo
				 let _flag = 1;
				exit foreach;
			END IF

	 end foreach

	 if _flag = 1 then 
		continue foreach; 
	 end if 

	 select suma_asegurada
	   into _suma_asegurada
	   from emipomae
	  where no_poliza   =  _no_poliza
	    and periodo     >= _periodo1
	    and periodo     <= _periodo2
	    and actualizado =  1;

	 if _suma_asegurada is null then
	     let _suma_asegurada = 0;
	 end if

	-- Procedimiento que genera la morosidad para una poliza
	-- basado en la prima neta

	if _pri_pag = 0 then
		let _monto_30_aa = 0;
	else
		CALL sp_par78d(a_compania, a_sucursal, _no_documento, _periodo2, _fecha_aa)
		RETURNING v_por_vencer, v_exigible, v_corriente, v_monto_30, v_monto_60, v_monto_90, v_saldo, _prima_orig;

		let _monto_30_aa = v_monto_30 + v_monto_60 + v_monto_90;

	end if

	if _monto_30_aa > 0  then  -- Condicion morosidad menor a 30
		continue foreach;
	end if  

	let _prima_sus_pag = 0;
	let _prima_sus_pag = _pri_pag  ;  
	let _sini_incu     = _sin_pag ; 

	if _prima_sus_pag = 0 then
		continue foreach;
	end if

	let _siniestralidad = 0;
	let _siniestralidad = (_sini_incu / _prima_sus_pag) * 100;

	if _siniestralidad >= 50 then	 -- Siniestralidad debe ser < 50%
	   continue foreach;
	end if	

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	 foreach
	  SELECT cod_agente
		 INTO _cod_agente
		 FROM emipoagt
		WHERE no_poliza = _no_poliza

           let _unificar = 0;	 -- 01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente = _cod_agente
		   AND agente_agrupado = "01727";

		   if _unificar <> 0 then
			   let _cod_agente = "01727";
		   end if
	
		SELECT nombre,
			   tipo_persona
		  INTO _nombre,
			   _tipo_persona
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		if _tipo_persona = "N" then
			let _nombre_tipo = "INDIVIDUALES";
		else
			let _nombre_tipo = "BROKERS";
		end if

		-- Informacion Necesaria para las Promotorias

		select sucursal_promotoria
		  into _suc_promotoria
		  from insagen
		 where codigo_agencia = _cod_agencia;

		select cod_vendedor
		  into _cod_vendedor
		  from parpromo
		 where cod_agente  = _cod_agente
		   and cod_agencia = _suc_promotoria
		   and cod_ramo	   = _cod_ramo;

		select nombre
		  into _nombre_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor;

		insert into tmp_breezes(
		cod_agente, 
		no_documento, 
		pri_sus_pag, 
		sini_inc, 
		n_agente, 
		cod_contratante, 
		n_cliente,
		periodo,
		pri_pag,
		monto_30_aa,
		cod_vendedor,
		nombre_vendedor,
		cod_ramo,
		nombre_ramo,
		tipo_agente,
		suma_asegurada,
		seleccionado,
		cod_sucursal
		)
		values(
		_cod_agente, 
		_no_documento, 
		_prima_sus_pag, 
		_sini_incu, 
		_nombre, 
		_cod_contratante, 
		_n_cliente,
		_periodo2,
		_pri_pag,
		_monto_30_aa,
		_cod_vendedor,
		_nombre_vendedor,
		_cod_ramo,
		_nombre_ramo,
		_nombre_tipo,
		_suma_asegurada,
		1,
		_suc_promotoria
		);

	 end foreach
end foreach

LET v_filtros = "";
LET _tipo = "";
--Filtro por Agente
IF a_codagente <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Agente "||TRIM(a_codagente);
	LET _tipo = sp_sis04(a_codagente); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

	UPDATE tmp_breezes
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND cod_agente NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
	UPDATE tmp_breezes
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND cod_agente IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

LET _tipo = "";
--Filtro por Zona
IF a_codvend <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Zona "||TRIM(a_codvend);
	LET _tipo = sp_sis04(a_codvend); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

	UPDATE tmp_breezes
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND cod_vendedor NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
	UPDATE tmp_breezes
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND cod_vendedor IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF
LET _tipo = "";
--Filtro por Sucursal
IF a_codsuc <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsuc);
	LET _tipo = sp_sis04(a_codsuc); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_breezes
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE tmp_breezes
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

--/***************************************/
-- SE ACUMULARAN POR RAMO             	 -- 
--/***************************************/

let _cnt_act = 0;
let _cnt_ant = 0;	
let _pri_sus_pag = 0;
let _cnt_falta   = 0;

foreach

   Select cod_agente,
     	  cod_ramo,
   		  count(*),
		  cod_vendedor
	 into _cod_agente,  
	      _cod_ramo,
		  _cnt_act,
		  _cod_vendedor
	 from tmp_breezes
	where periodo      = _periodo2
	  and seleccionado = 1
 group by 1,2,4
 order by 1,2,4

   -- Cantidad minima de Polizas por Ramos

   let _cnt_falta = 0;

   if _cod_ramo = "002" then
	  let _cnt_falta = 30 - _cnt_act;
	  if _cnt_falta < 0 then
	  	let _cnt_falta = 0;
	  end if
   end if

   if _cod_ramo = "020" then
	  let _cnt_falta = 50 - _cnt_act;
	  if _cnt_falta < 0 then
	  	let _cnt_falta = 0;
	  end if
   end if

   if _cod_ramo = "001" then
	  let _cnt_falta = 30 - _cnt_act;
	  if _cnt_falta < 0 then
	  	let _cnt_falta = 0;
	  end if
   end if

   if _cod_ramo = "003" then
	  let _cnt_falta = 15 - _cnt_act;
	  if _cnt_falta < 0 then
	  	let _cnt_falta = 0;
	  end if

   end if

   SELECT nombre,
   	      no_licencia
	 INTO _nombre,
		  _no_licencia
	 FROM agtagent
	WHERE cod_agente = _cod_agente;

   let _suma_asegurada = 0;
   let _suma_falta     = 0;
   foreach
		select cod_agente,				
			   sum(suma_asegurada),
			   sum(pri_sus_pag)
		  into _cod_agente1,
			   _suma_asegurada,
			   _pri_sus_pag
		  from tmp_breezes
		 where periodo      = _periodo2
		   and cod_agente   = _cod_agente
		   and cod_ramo     = _cod_ramo
		   and seleccionado = 1
		 group by cod_agente, cod_ramo

		  -- Suma Asegurada Minima de Polizas por Ramos

		  if _cod_ramo = "002" then
			let _suma_falta = 12000 - _suma_asegurada;
			if _suma_falta < 0 then
				let _suma_falta = 0;
			end if
			let _total_prima_cob = _pri_sus_pag * _cnt_act;
			let _utilidad        = _pri_sus_pag * _cnt_act * (11/100);
		  end if

		  if _cod_ramo = "020" then
			let _total_prima_cob = _pri_sus_pag * _cnt_act;
			let _utilidad        = _pri_sus_pag * _cnt_act * (32/100);
		  end if

		  if _cod_ramo = "001" then
			let _suma_falta = 50000 - _suma_asegurada;
			if _suma_falta < 0 then
				let _suma_falta = 0;
			end if
			let _total_prima_cob = 	_pri_sus_pag * _cnt_act;
			let _utilidad        = 	_pri_sus_pag * _cnt_act * (3/100);
		  end if

		  if _cod_ramo = "003" then
			let _suma_falta = 15000 - _suma_asegurada;
			if _suma_falta < 0 then
				let _suma_falta = 0;
			end if
			let _total_prima_cob = _pri_sus_pag * _cnt_act;
			let _utilidad        = _pri_sus_pag * _cnt_act * (3/100);
		  end if
	   
		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo; 

		SELECT nombre
		  INTO _nombre
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		INSERT INTO tmp_40(cod_agente, nombre_cte, cod_ramo, nombre_ramo, suma_asegurada, prima_sus, cant_pol, prima_cobrada, utilidad, periodo, fecha_genera,suma_falta,cant_pol_falta,cod_vendedor)
		VALUES ( _cod_agente,_nombre,_cod_ramo,_nombre_ramo,_suma_asegurada, _pri_sus_pag, _cnt_act, _total_prima_cob, _utilidad, _periodo2, current,_suma_falta,_cnt_falta,_cod_vendedor);

   end foreach	

end foreach	 

foreach
	 select cod_agente, 
			nombre_cte, 
			cod_ramo, 
			nombre_ramo, 
			suma_asegurada, 
			prima_sus, 
			cant_pol, 
			prima_cobrada, 
			utilidad, 
			periodo, 
			fecha_genera,
			suma_falta,
			cant_pol_falta,
			cod_vendedor
	   into _cod_agente,
	        _nombre,
	        _cod_ramo,
	        _nombre_ramo,
	        _suma_asegurada, 
	        _pri_sus_pag, 
	        _cnt_act, 
	        _total_prima_cob, 
	        _utilidad, 
	        _periodo2, 
	        _fecha,
			_suma_falta,
			_cnt_falta,
			_cod_vendedor
       from tmp_40	
	  Order by 1,3

	  select nombre
	    into _n_vendedor
		from agtvende
	   where cod_vendedor = _cod_vendedor;

		RETURN _cod_agente,
		       _nombre,
		       _cod_ramo,
		       _nombre_ramo,
		       _suma_asegurada, 
		       _pri_sus_pag, 
		       _cnt_act, 
		       _total_prima_cob, 
		       _utilidad, 
		       _periodo2, 
		       _fecha,
			   v_nombre_cia,
			   v_filtros,
			   _suma_falta,
			   _cnt_falta,
			   _cod_vendedor,
			   _n_vendedor
		       WITH RESUME;

end foreach		
											  
drop table tmp_concurso;  
drop table tmp_breezes; 
drop table tmp_40; 

--end  

--return 0, 'Actualizacion Exitosa...',a_periodo;

END PROCEDURE;	  	 