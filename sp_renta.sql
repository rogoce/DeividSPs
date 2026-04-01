--***********************************************************************************
-- Procedimiento que genera la Bonificacion de Rentabilidad por corredores
--***********************************************************************************
-- execute procedure sp_che94("001","001","2009-12","HGIRON")
-- Creado    : 28/01/2009 - Autor: Henry Giron
-- Modificado: 28/01/2009 - Autor: Henry Giron

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_renta;

CREATE PROCEDURE sp_renta(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
v_periodo_aa        CHAR(7),  -- 2007-12
a_usuario           CHAR(8)
) RETURNING SMALLINT,
          char(50),
		  char(3);

DEFINE _no_poliza       CHAR(10);
define _no_poliza_ap    CHAR(10);
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(16,2); 
DEFINE _porc_comis      DEC(16,2);
DEFINE _porc_comis2     DEC(16,2);
DEFINE _porc_coas_ancon DEC(16,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _cod_ramo1        CHAR(3);  
DEFINE _nombre_ramo     CHAR(50);  
DEFINE _cod_subramo     CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define _cnt             integer;
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
define _per_ini 		char(7);
define _per_ini_ap 		char(7);
define _per_fin_ap 		char(7);
define _pri_sus 		DEC(16,2);
define _error           smallint;
define _filtros			char(255);
define _per_fin_dic     char(7);
define _prima_sus_pag   DEC(16,2);
define _sini_incu		DEC(16,2);
define _fecha_pago      date;
define _renglon         integer;
define _porc_coaseguro	dec(16,4);
define _prima_can		DEC(16,2);
define _sin_pag_aa		DEC(16,2);
define _no_reclamo		char(10);
define _sin_pen_dic		DEC(16,2);
define _sin_pen_aa      DEC(16,2);
define _pri_pag         DEC(16,2);
define _pri_can         DEC(16,2);
define _pri_dev         DEC(16,2);
define v_monto_90       DEC(16,2);
define _prima_orig      DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cod_agente1   	char(5);
define _cantidad        integer;
define _fecha_aa_ini     date;
define _fecha_aa        date;
define _fecha_ap_ini    date;
define _fecha_ap        date;
define _vigente         smallint;
define v_filtros        varchar(255);
define a_periodo        char(7);
define v_periodo_ap     char(7);
define _n_cliente       varchar(100);
define _nueva_renov     char(1);
define _periodo_reno    char(7);
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;
define _no_pol_ren_aa	integer;
define _no_pol_ren_ap	integer;

define _no_pol_nue_aa	integer;
define _no_pol_nue_ap	integer;
define _estatus_poliza	smallint;
define _pri_sus_pag_ap  DEC(16,2);
define _pri_sus_pag_ap_p  DEC(16,2);

define _pri_sus_pag     dec(16,2);
define _pri_sus_pag_p     dec(16,2);

define _pri_pag_ap      DEC(16,2);
define _pri_can_ap      DEC(16,2);
define _pri_dev_ap      DEC(16,2);
define _monto_90_aa     DEC(16,2);
define _monto_90_ap     DEC(16,2);

define _ano				smallint;
define _ano_ant			smallint;

define _cod_agencia		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _vigencia_inic	date;
define _vigencia_final	date;
define _tipo_persona	char(1);
define _nombre_tipo		char(15);
define _concurso		smallint;

define _incremento_psp  dec(16,2);
define _crecimiento     dec(16,2);
define _siniestralidad  dec(16,2);
define _beneficio		dec(16,2);
define _cre_prima_aplica     smallint;
define _min_prima_pag_aplica smallint;
define _sini_aplica          smallint;
define _cnt_ant			integer;
define _cnt_act			integer;  
define _prima_neta		dec(16,2);
define _prima_neta_p		dec(16,2);
define _valor_prima     dec(16,2);
define _porcentaje      dec(16,2);
define _cod_origen      char(3);
define _cod_contr       char(10);
define v_nombre_clte    char(100);
define _valor           dec(16,2);
define _error_isam		integer;
define _error_desc		char(50);
define _tipo			char(1);
define _cod_tipo        char(1);
define _cod_tipo1       char(1);
define _beneficios      smallint;
				  
define _nombre_tipo_g	char(50);
define _tipo_g			char(1);
define _prima_neta_g    decimal(16,2);
define _comision_g		decimal(16,2);
define _porcentaje_g	decimal(16,2);
define _por_cre_g		decimal(16,2);
define _por_sin_g		decimal(16,2);
define _prima_ap_g		decimal(16,2);
define _sini_g          decimal(16,2);
define _sini_i          decimal(16,2);

define _descrip			varchar(100);
define _psp_c           varchar(20);
define _cre_c           varchar(20);
define _sin_c           varchar(20);
define s_psp_c          varchar(20);
define s_cre_c          varchar(20);
define s_sin_c          varchar(20);

define _cnt_ind			smallint;
define a_anio_rev       smallint;

--SET DEBUG FILE TO "sp_che94.trc";
--TRACE ON;

let _error          = 0;
let _prima_can      = 0;
let _pri_can        = 0;
let _siniestralidad = 0;
let _sini_incu      = 0;
let _prima_sus_pag  = 0;
let _pri_dev        = 0;
let _cnt            = 0;
let _pri_pag        = 0;
let _sin_pen_dic    = 0;
let _sin_pen_aa     = 0;
let _sin_pag_aa     = 0;
let v_por_vencer    = 0;
let v_exigible	    = 0;
let v_corriente	    = 0;
let v_monto_30	    = 0;
let v_monto_60	    = 0;
let v_monto_90	    = 0;
let v_saldo         = 0;
let _cantidad       = 0;
let _prima_orig     = 0;

select par_ase_lider,
       par_periodo_act,
	   ult_per_renta
  into _cod_coasegur,  -- 036
	   a_periodo,	   -- 2008-12
	   v_periodo_ap	   -- 2007-12
  from parparam
 where cod_compania = a_compania;

let v_periodo_ap 	= '2008-12';   --borrar esta linea

let a_anio_rev = v_periodo_ap[1,4] + 1 ;
let a_periodo =  a_anio_rev||'-'||'12' ;

let _per_ini        = a_periodo[1,4]||'-'||'01';
let _per_fin_dic    = a_periodo;

let _ano            = a_periodo[1,4];
let _ano            = _ano - 1;

let _per_ini_ap 	= v_periodo_ap[1,4]||'-'||'01';
let _per_fin_ap 	= v_periodo_ap;

let _fecha_aa_ini   = sp_sis36(_per_ini);
let _fecha_aa       = sp_sis36(a_periodo);
let _fecha_ap_ini   = sp_sis36(_per_ini_ap);
let _fecha_ap       = sp_sis36(_per_fin_ap);

delete from chqrenta4 where periodo = a_periodo ;

create temp table tmp_concurso(
no_documento	char(20),
pri_sus_pag		dec(16,2) 	default 0,
pri_pag			dec(16,2) 	default 0,
pri_can			dec(16,2) 	default 0,
pri_dev  		dec(16,2) 	default 0,
sin_pag_aa      dec(16,2) 	default 0,
sin_pen_aa      dec(16,2) 	default 0,
sin_pen_ap      dec(16,2) 	default 0,
no_pol_ren_aa	integer 	default 0,
no_pol_ren_ap	integer 	default 0,
no_pol_nue_aa	integer		default 0,
no_pol_nue_ap	integer		default 0,
pri_sus_pag_ap	dec(16,2) 	default 0,
pri_pag_ap		dec(16,2) 	default 0,
pri_can_ap		dec(16,2) 	default 0,
pri_dev_ap 		dec(16,2) 	default 0
) with no log;	 

SET ISOLATION TO DIRTY READ;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

--**********************
-- Prima Pagada 2009  --
--**********************
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_renglon
   from cobredet
  where periodo     >= _per_ini
    and periodo     <= a_periodo
	and actualizado = 1
	and tipo_mov    in ("P", "N")
	
	let _no_poliza = sp_sis21(_no_documento);

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

	insert into tmp_concurso(no_documento, pri_pag )
	values (_no_documento, _monto);

end foreach

--**********************
-- Prima Pagada 2008  --
--**********************
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_renglon
   from cobredet
  where periodo     >= _per_ini_ap
    and periodo     <= _per_fin_ap
	and actualizado = 1
	and tipo_mov    in ("P", "N")
	
	let _no_poliza = sp_sis21(_no_documento);

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

	insert into tmp_concurso(no_documento, pri_pag_ap)
	values (_no_documento, _monto);

end foreach


--*********************
-- Primas canceladas 2009
--*********************
foreach
 select no_documento,
		sum(prima_suscrita)
   into _no_documento,
		_prima_can
   from endedmae
  where cod_endomov  in ("002", "003") 
    and actualizado  = 1
    and periodo     >= _per_ini
    and periodo     <= a_periodo
  group by no_documento

	
	if _prima_can > 0 then
		continue foreach;
	end if 

	insert into tmp_concurso(no_documento, pri_can)
	values (_no_documento, _prima_can);

end foreach

--**************************
-- Primas canceladas 2008 --
--**************************
foreach
 select no_documento,
		sum(prima_suscrita)
   into _no_documento,
		_prima_can
   from endedmae
  where cod_endomov  in ("002", "003") 
    and actualizado  = 1
	and periodo     >= _per_ini_ap
    and periodo     <= _per_fin_ap
  group by no_documento

	if _prima_can > 0 then
		continue foreach;
	end if 

	insert into tmp_concurso(no_documento, pri_can_ap)
	values (_no_documento, _prima_can);

end foreach

--******************
-- Prima Devuelta 2009
--******************
foreach
	 select no_requis
	   into _no_requis
	   from chqchmae
	  where pagado     = 1
	    and autorizado = 1
		and anulado    = 0
		and periodo     >= _per_ini
        and periodo     <= a_periodo	

	 foreach
	 	 select no_documento,
	 	        prima_neta
	 	   into _no_documento,
	 	        _pri_dev
	 	   from chqchpol
	 	  where no_requis = _no_requis

		 insert into tmp_concurso(no_documento, pri_dev)
		 values (_no_documento, _pri_dev);

     end foreach

end foreach

--***********************
-- Prima Devuelta 2008
--***********************

foreach
	 select no_requis
	   into _no_requis
	   from chqchmae
	  where pagado     = 1
	    and autorizado = 1
		and anulado    = 0
		and periodo     >= _per_ini_ap
        and periodo     <= _per_fin_ap	

   foreach
		 select no_documento,
		        prima_neta
		   into _no_documento,
		        _pri_dev
		   from chqchpol
		  where no_requis = _no_requis

		 insert into tmp_concurso(no_documento, pri_dev_ap)
		 values (_no_documento, _pri_dev);

   end foreach

end foreach

--*********************************
-- Siniestros Pagados Ano Actual 2009--
--*********************************
call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo ) returning _filtros;

foreach
 select doc_poliza,
        pagado_bruto   
   into _no_documento,
        _sin_pag_aa
   from tmp_sinis

	insert into tmp_concurso(no_documento, sin_pag_aa)
	values (_no_documento, _sin_pag_aa);

end foreach

drop table tmp_sinis;

--**********************************************
-- Siniestros Pendientes Diciembre Ano Pasado 2008
--**********************************************

foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_dic
   from rectrmae 
  where cod_compania = a_compania
    and periodo     >= _per_ini_ap
    and periodo     <= _per_fin_ap  
	and actualizado  = 1
  group by no_reclamo
 having sum(variacion) > 0 

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_dic = _sin_pen_dic * (_porc_coaseguro / 100);

	insert into tmp_concurso(no_documento, sin_pen_ap)
	values (_no_documento, _sin_pen_dic);

end foreach

--************************************
-- Siniestros Pendientes Ano Actual 2009
--************************************

foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_aa
   from rectrmae 
  where cod_compania = a_compania
    and periodo     >= _per_ini
    and periodo     <= a_periodo
	and actualizado  = 1
  group by no_reclamo
 having sum(variacion) > 0 

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_aa = _sin_pen_aa * (_porc_coaseguro / 100);

	insert into tmp_concurso(no_documento, sin_pen_aa)
	values (_no_documento, _sin_pen_aa);

end foreach

let _cnt = 0;

--/***************************************/
--	Se acumulan los totales por periodo
--/***************************************/

foreach
	 select no_documento,
			sum(pri_pag),
		    sum(pri_can),
			sum(pri_dev),
			sum(sin_pag_aa),
			sum(sin_pen_aa),
			sum(sin_pen_ap),
			sum(no_pol_ren_aa),
			sum(no_pol_ren_ap),
			sum(no_pol_nue_aa),
			sum(no_pol_nue_ap),
			sum(pri_pag_ap),
			sum(pri_can_ap),
			sum(pri_dev_ap)
	   into _no_documento,
			_pri_pag,
			_pri_can,
			_pri_dev,
			_sin_pag_aa,
			_sin_pen_aa,
			_sin_pen_dic,
			_no_pol_ren_aa,
			_no_pol_ren_ap,
			_no_pol_nue_aa,
			_no_pol_nue_ap,
			_pri_pag_ap,
			_pri_can_ap,
			_pri_dev_ap
		from tmp_concurso 
	group by no_documento
	order by no_documento

  {	FOREACH
		SELECT no_poliza
		  INTO _no_poliza
		  FROM emipomae
		 WHERE no_documento = _no_documento
		   AND actualizado  = 1
		   and periodo[1,4] = a_periodo[1,4]
	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
	END FOREACH }

	let _no_poliza = sp_sis21(_no_documento);

	 select cod_grupo, 
			cod_ramo, 
			cod_pagador, 
			cod_contratante, 
			cod_tipoprod,
			sucursal_origen,
			cod_subramo
	   into _cod_grupo,
			_cod_ramo,
			_cod_pagador,
			_cod_contratante,
			_cod_tipoprod,
			_cod_agencia,
			_cod_subramo
		from emipomae
	   where no_poliza   = _no_poliza
	     and actualizado = 1;

	 if _cod_grupo = "00000" then -- Excluir estado
		continue foreach;
	 end if

	select beneficios
	  into _beneficios
	  from insagen
	 where codigo_agencia = _cod_agencia;

	 if _beneficios = 0 then -- Excluir sucursales sin estos beneficios
		continue foreach;
	 end if

	 SELECT tipo_produccion
		INTO _tipo_prod
		FROM emitipro
	  WHERE cod_tipoprod = _cod_tipoprod;

	 IF _tipo_prod = 4 or _tipo_prod = 2 THEN 		-- Excluir Reaseguro Asumido y Coas. Mayoritario
		CONTINUE FOREACH;
	 END IF

	 select count(*)
	   into _cnt
	   from emifafac
	  where no_poliza = _no_poliza;

	 if _cnt > 0 then		-- Excluir Facultativos
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

	-- Procedimiento que genera la morosidad para una poliza
	-- basado en la prima neta

	if _pri_pag = 0 then

		let _pri_can     = 0;
		let _pri_dev     = 0;
		let _monto_90_aa = 0;

	else

		CALL sp_par78d(a_compania, a_sucursal, _no_documento, a_periodo, _fecha_aa)
		
		RETURNING v_por_vencer, v_exigible, v_corriente, v_monto_30, v_monto_60, v_monto_90, v_saldo, _prima_orig;

		let _monto_90_aa = v_monto_90; 

	end if

	if _pri_pag_ap = 0 then

		let _pri_can_ap  = 0;
		let _pri_dev_ap  = 0;
		let _monto_90_ap = 0;

	else

		CALL sp_par78d(a_compania, a_sucursal, _no_documento, _per_fin_ap, _fecha_ap)

		RETURNING v_por_vencer, v_exigible, v_corriente, v_monto_30, v_monto_60, v_monto_90, v_saldo, _prima_orig;

		let _monto_90_ap = v_monto_90; 

	end if

	let _prima_sus_pag  = _pri_pag    + _pri_can    - _pri_dev    - _monto_90_aa;
	let _pri_sus_pag_ap = _pri_pag_ap + _pri_can_ap - _pri_dev_ap - _monto_90_ap;
	let _sini_incu      = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

    --/*CATEGORIZAR*/
    --A-AUTOMOVIL                   ="002","020"
    --B-SALUD y HOSPITALIZACION     ="018"
    --C-PATRIMONIALES               ="001","003","005","006","015","011","013","010","009","017","014","021","012","007"
    --D-PERSONAS    				="019","004","016"
    --E-FIANZAS                     ="008","080"

	if  _cod_ramo in ("002","020")  then
	   let _tipo = 'A';
	end if

	if  _cod_ramo = "018"  then
	   let _tipo = 'B';
	end if


	if  _cod_ramo in ("001","003","005","006","015","011","013","010","009","017","014","021","012","007")  then
	   let _tipo = 'C';
	end if


	if  _cod_ramo in ("019","004","016")  then
	   let _tipo = 'D';
	end if


	if  _cod_ramo in ("008","080")  then
	   let _tipo = 'E';
	end if

	 foreach
	  SELECT cod_agente
		 INTO _cod_agente
		 FROM emipoagt
		WHERE no_poliza = _no_poliza
	
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

	  

		--FF SEGUROS no entra en plan de negocios. 17/09/09

		if _cod_agente <> "00873" then --in("01068","01653","01654","01655","01656","01657","01658","01659","01660","01661","01662","01663","01664") then
			continue foreach;
		end if

		insert into chqrenta4(
		cod_agente, 
		no_documento, 
		pri_sus_pag_aa, 
		pri_sus_pag_ap, 
		sini_inc, 
		n_agente, 
		vigenteaa,
		vigenteap, 
		cod_contratante, 
		n_cliente,
		periodo,
		renovaa,
		renovap,
		pri_pag_aa,
		pri_can_aa,
		pri_dev_aa,
		monto_90_aa,
		pri_pag_ap,
		pri_can_ap,
		pri_dev_ap,
		monto_90_ap,
		cod_vendedor,
		nombre_vendedor,
		cod_ramo,
		nombre_ramo,
		tipo_agente,
		tipo
		)
		values(
		_cod_agente, 
		_no_documento, 
		_prima_sus_pag, 
		_pri_sus_pag_ap, 
		_sini_incu, 
		_nombre, 
		_no_pol_nue_aa, 
		_no_pol_nue_ap, 
		_cod_contratante, 
		_n_cliente,
		a_periodo,
		_no_pol_ren_aa,
		_no_pol_ren_ap,
		_pri_pag,
		_pri_can,
		_pri_dev,
		_monto_90_aa,
		_pri_pag_ap,
		_pri_can_ap,
		_pri_dev_ap,
		_monto_90_ap,
		_cod_vendedor,
		_nombre_vendedor,
		_cod_ramo,
		_nombre_ramo,
		_nombre_tipo,
		_tipo
		);

	 end foreach
end foreach

													  
drop table tmp_concurso;  

end  

return 0, 'Actualizacion Exitosa...',a_periodo;

END PROCEDURE;	  