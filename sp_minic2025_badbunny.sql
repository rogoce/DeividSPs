--************************************************************************************
-- Procedimiento que genera Mini Convencion NO ME QUIERO IR DE AQUI PUERTO RICO 2025
--************************************************************************************
-- Creado    : 05/09/2023 - Autor: Armando Moreno M.

DROP PROCEDURE sp_minic2025;
CREATE PROCEDURE sp_minic2025(a_compania CHAR(3),a_sucursal CHAR(3))
RETURNING SMALLINT;

DEFINE _no_poliza       CHAR(10);
DEFINE _monto           DEC(16,2);
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
DEFINE _cnt_traspaso    SMALLINT;
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
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
DEFINE _dif		        DEC(16,2);
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
define _prima_sus_pag,_monto_pen   DEC(16,2);
define _sini_incu		DEC(16,2);
define _siniestralidad  DEC(16,2);
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
define _prima_sus_agt   DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cantidad        integer;
define _fecha_aa_ini    date;
define _fecha_aa_fin    date;
define _fecha_ap_ini    date;
define _fecha_ap,_date_added        date;
define _vigente         smallint;
define v_filtros        varchar(255);
define a_periodo        char(7);
define _n_cliente       varchar(100);
define _nueva_renov     char(1);
define _periodo_reno    char(7);
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;
define _no_pol_ren_aa	integer;
define _no_pol_ren_ap	integer;
define _puntos          dec(3,2);
define _puntos_tiene    dec(16,2);
define _no_pol_nue_aa	integer;
define _no_pol_nue_ap	integer;
define _no_pol_nue_ap_per	integer;
define _estatus_poliza	smallint;
define _pri_sus_pag_ap  DEC(16,2);
define _pri_pag_ap      DEC(16,2);
define _pri_can_ap      DEC(16,2);
define _pri_dev_ap      DEC(16,2);
define _monto_90_aa     DEC(16,2);
define _prima_suscrita  DEC(16,2);
define _prima_sus_ramo  DEC(16,2);
define _prima_fac       DEC(16,2);
define _ano				smallint;
define _ano_ant			smallint;
define _cod_agencia		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _vigencia_inic,_fecha_act	date;
define _vigencia_final,_fecha_tope	date;
define _tipo_persona	char(1);
define _nombre_tipo,_reemplaza_pol		char(20);
define _concurso,_unificar smallint;
define _pagada 			   smallint;
DEFINE _porc_partic_agt       DEC(5,2);
define _meses                 smallint;
define _valor                 decimal(16,2);
define _cod_perpago           char(3);
define _cod_agente_anterior   char(5);
define _grupo_agente    char(15);
define _prima_salud,_monto_p     decimal(16,2);
define _prima_cancer    decimal(16,2);
define _prima_auto      decimal(16,2);
define _prima_mr        decimal(16,2);
define _prima_vida      decimal(16,2);

define _pri_sus_ap          DEC(16,2);
define _flag_1,_cnt_cam		smallint;
define _flag_2				smallint;
define _flag_3				smallint;
define _flag_4				smallint;
define _flag_5				smallint;

--SET DEBUG FILE TO "sp_pro868a.trc";
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
let v_monto_90	    = 0;
let _valor          = 0;
let _dif            = 0;
let v_saldo         = 0;
let _cantidad       = 0;
let _prima_orig     = 0;
let _porc_partic_agt = 0;
let _prima_fac       = 0;

let _pri_sus_ap      = 0;
let _flag_1          = 0;
let _flag_2          = 0;
let _flag_3          = 0;
let _flag_4          = 0;
let _flag_5          = 0;
let _cnt_cam         = 0;

let _fecha_act = CURRENT;
let _fecha_aa_ini = "01/02/2025";
let _fecha_aa_fin = "30/06/2025";
let _fecha_tope   = '30/06/2025';
LET _reemplaza_pol = "";

if _fecha_act >= _fecha_aa_ini then		--Para que no comience antes de tiempo el concurso.
	if _fecha_act >= _fecha_tope then	--Para que no siga corriendo, luego de culminado el concurso.
		return 0;
	end if	
else
	return 0;
end if

let _prima_suscrita  = 0;
let _nombre_tipo     = "";
let _prima_sus_agt   = 0;

delete from miami;

create temp table tmp_caribe(
no_documento		char(20),
pri_sus				dec(16,2) 	default 0,
pri_pag				dec(16,2) 	default 0,
pri_pag_dif			dec(16,2) 	default 0,
cod_ramo            char(3),
pri_sus_ap			dec(16,2) 	default 0,
cod_agente          char(5)
) with no log;

CREATE INDEX xie01_tmp_caribe ON tmp_caribe(no_documento);
CREATE INDEX xie02_tmp_caribe ON tmp_caribe(no_documento,cod_agente);

SET ISOLATION TO DIRTY READ;

--Periodo de Clasificacion: Del 01 de febrero de 2023 al  15 de mayo del 2023
--*****************************
-- Polizas Nuevas
--*****************************
foreach
	select no_documento
	  into _no_documento
	  from emipomae
	 where cod_compania  = a_compania
	   and actualizado   = 1
	   and nueva_renov   = "N"
	   and vigencia_inic between _fecha_aa_ini and _fecha_aa_fin
	   and cod_ramo not in('020')
	 group by no_documento
	 order by no_documento

	let _no_poliza = sp_sis21(_no_documento);
	
	select nueva_renov,
	       no_documento,
		   estatus_poliza,
		   cod_pagador, 
		   cod_contratante,
		   cod_tipoprod,
		   prima_suscrita,
		   cod_grupo,
		   cod_ramo,
		   cod_perpago,
		   cod_subramo,
		   reemplaza_poliza,
		   vigencia_inic,
		   vigencia_final,
		   cod_formapag
	  into _nueva_renov,
	       _no_documento,
		   _estatus_poliza,
		   _cod_pagador,
		   _cod_contratante,
		   _cod_tipoprod,
		   _prima_suscrita,
		   _cod_grupo,
		   _cod_ramo,
		   _cod_perpago,
		   _cod_subramo,
		   _reemplaza_pol,
		   _vigen_ini,
		   _vigencia_final,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	let _reemplaza_pol = TRIM(_reemplaza_pol);
	let _monto_pen = 0;
	let _pagada    = 0;
	let _monto_p   = 0;
	
    if _cod_ramo in('002','023') then  --Ramo de auto y auto flota
		select count(*)
		  into _cnt
		  from emipocob
		 where no_poliza = _no_poliza
		   and cod_cobertura in('01307','00119','00121'); --Coberturas de COLISION
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt > 0 then
		else
			insert into miamiexc(no_poliza,poliza,descripcion,vig_ini,vig_fin,monto_pag,prima_suscrita,tipo)
			values (_no_poliza,_no_documento,'Excluye polizas Auto RC.',_vigen_ini,_vigencia_final,_monto_p,_prima_suscrita,1);
			continue foreach;
		end if
	end if
	
	select sum(monto_pag)
	  into _monto_p
	  from emiletra
	 where no_poliza = _no_poliza;

	if _monto_p is null then
		let _monto_p = 0.00;
	end if
	let _pagada = 0;
	if _monto_p > 0 then
		let _pagada = 1;
	end if
	
	if _cod_formapag = '091' then --Se excluye forma de pago GOB
		insert into miamiexc(no_poliza,poliza,descripcion,vig_ini,vig_fin,monto_pag,prima_suscrita,tipo)
		values (_no_poliza,_no_documento,'Excluye forma de pago GOB.',_vigen_ini,_vigencia_final,_monto_p,_prima_suscrita,1);
		continue foreach;
	end if
	if _cod_grupo in("00000","1000") then -- Excluir Estado
		insert into miamiexc(no_poliza,poliza,descripcion,vig_ini,vig_fin,monto_pag,prima_suscrita,tipo)
		values (_no_poliza,_no_documento,'Grupo de Estado No aplica.',_vigen_ini,_vigencia_final,_monto_p,_prima_suscrita,1);
		continue foreach;
	end if	
	
	if _pagada > 0 then	--Debe tener pagada la primera letra.
	else
		insert into miamiexc(no_poliza,poliza,descripcion,vig_ini,vig_fin,monto_pag,prima_suscrita,tipo)
		values (_no_poliza,_no_documento,'Debe estar pagada la primera letra.',_vigen_ini,_vigencia_final,_monto_p,_prima_suscrita,1);
		continue foreach;
    end if
	--Excluir poliza facultativo
	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;
	if _cnt is null then
		let _cnt = 0;
    end if
	if _cnt > 0 then
		insert into miamiexc(no_poliza,poliza,descripcion,vig_ini,vig_fin,monto_pag,prima_suscrita,tipo)
		values (_no_poliza,_no_documento,'Excluye poliza facultativa.',_vigen_ini,_vigencia_final,_monto_p,_prima_suscrita,1);
		continue foreach;
	end if
	if _cod_ramo = '018' then	--Para salud, debe ser la prima anualizada. si la poliza tiene cambio de producto, NO debe ser considerada como nueva.
		let _cnt_cam = 0;
		IF _reemplaza_pol <> "" or _reemplaza_pol is not null then
			let _cnt_cam = sp_bo077b(_reemplaza_pol);	--Busca si tiene cambio de plan.
			if _cnt_cam > 0 then
	    		insert into miamiexc(no_poliza,poliza,descripcion,vig_ini,vig_fin,monto_pag,prima_suscrita,tipo)
				values (_no_poliza,_no_documento,'Pol. Salud con cambio de plan No aplica.',_vigen_ini,_vigencia_final,_monto_p,_prima_suscrita,1);
				continue foreach;
			end if
		END IF
		select meses
		  into _meses
		  from cobperpa
		 where cod_perpago = _cod_perpago;
		let _valor = 0;
		if _cod_perpago = '001' then
			let _meses = 1;
		end if
		if _cod_perpago = '008' or _cod_perpago = '006' then	--Es anual o inmediata, ya esta el 100% de la prima
			let _meses = 12;
		end if	
		let _valor = 12 / _meses;
		let _prima_suscrita = _prima_suscrita * _valor;
	end if
	
	SELECT tipo_produccion
	   INTO _tipo_prod
	   FROM emitipro
	  WHERE cod_tipoprod = _cod_tipoprod;

    if _tipo_prod in(3, 4) THEN   -- Excluir Coaseguro Minoritario y Reaseguro Asumido
		insert into miamiexc(no_poliza,poliza,descripcion,vig_ini,vig_fin,monto_pag,prima_suscrita,tipo)
		values (_no_poliza,_no_documento,'Pol. Coas.Min y Reas. Asumido No aplica.',_vigen_ini,_vigencia_final,_monto_p,_prima_suscrita,1);
	   CONTINUE FOREACH;
	end if
	
	select count(*)
	  into _cnt
	  from endedmae
	 where actualizado = 1
	   and no_poliza   = _no_poliza
	   and cod_endomov in('002', '003');

	if _cnt > 0 then			--Excluye polizas rehabilitadas y canceladas
		insert into miamiexc(no_poliza,poliza,descripcion,vig_ini,vig_fin,monto_pag,prima_suscrita)
		values (_no_poliza,_no_documento,'Pol. Rehabilitada y Cancelada No aplica.',_vigen_ini,_vigencia_final,_monto_p,_prima_suscrita);
		continue foreach;
	end if 

  	select count(*)
	  into _cnt
	  from endedmae
	 where actualizado = 1
	   and no_poliza   = _no_poliza
	   and cod_endomov in('012','031');

	if _cnt > 0 then			--Excluye Cambio de Corredores
		insert into miamiexc(no_poliza,poliza,descripcion,vig_ini,vig_fin,monto_pag,prima_suscrita)
		values (_no_poliza,_no_documento,'Pol. Cambio o Traspaso de corredores No aplica.',_vigen_ini,_vigencia_final,_monto_p,_prima_suscrita);
		continue foreach;
	end if
	if _nueva_renov = "N" then
		foreach
			SELECT cod_agente,
				   porc_partic_agt
			  INTO _cod_agente_anterior,
				   _porc_partic_agt
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza
			
			let _prima_sus_agt = 0; 
			let _prima_sus_agt = _prima_suscrita * _porc_partic_agt /100;
			
			--********  Unificacion de Agente *******
			call sp_che168(_cod_agente_anterior) returning _error,_cod_agente;
			
			insert into tmp_caribe(no_documento, pri_sus, cod_ramo, cod_agente)
			values (_no_documento, _prima_sus_agt, _cod_ramo, _cod_agente);
		end foreach		
	end if
	
end foreach
--************************************
foreach
	select no_documento,
	       cod_agente,
		   sum(pri_sus)
	  into _no_documento,
	       _cod_agente,
		   _prima_suscrita
	  from tmp_caribe
	 group by no_documento,cod_agente
	 order by no_documento,cod_agente

	let _no_poliza = sp_sis21(_no_documento);

	select sucursal_origen,cod_ramo, cod_contratante,cod_subramo
	  into _cod_agencia, _cod_ramo, _cod_pagador,_cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select cedula
      into _cedula_paga
      from cliclien
     where cod_cliente = _cod_pagador;	  

	 select nombre
	   into _nombre_ramo
	   from prdramo
	  where cod_ramo = _cod_ramo;

	let _puntos_tiene  = 0;
	let _flag          = 0;
	if _cod_ramo in('004','018','019','001','003','017') then
		let _puntos = 1.20;
	elif _cod_ramo in('006','015','009','014','022','010','011','013','002','023') then
		let _puntos = 1.00;
	end if
	select nombre,
		   tipo_agente,
		   estatus_licencia,
		   cedula
	  into _nombre,
		   _tipo_agente,
		   _estatus_licencia,
		   _cedula_agt
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if trim(_cedula_agt) = trim(_cedula_paga) then	-- Contra contratante
		continue foreach;
	end if

	IF _tipo_agente <> "A" then	-- Solo Corredores
		let _flag = 1;
	END IF

	IF _estatus_licencia <> "A" then  -- El corredor debe estar activo
		let _flag = 1;
	END IF
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
	 
	--*************
	foreach
		{select sum(pri_dev_aa)
		  into _pri_dev_ap
		  from milan08
		 where cod_agente = _cod_agente}
		 
		--Se crea esta tabla para usar las primas suscritas de la galeria de corredores, en lugar de la convencion.
		select prima_suscrita
		  into _pri_dev_ap
		  from deivid_tmp:galeria_corredor
		 where cod_agente = _cod_agente
	 
		select date_added
		  into _date_added
		  from agtagent
		 where cod_agente = _cod_agente;	  
		  
		if _pri_dev_ap > 500000 then
			let _nombre_tipo = "Rango 1";
		elif _pri_dev_ap > 350000 then
			let _nombre_tipo = "Rango 2";
		elif _pri_dev_ap > 250000 then
			let _nombre_tipo = "Rango 3";
		elif _pri_dev_ap > 150000 then
			let _nombre_tipo = "Rango 4";
		else
			let _nombre_tipo = "Rango 5";
		end if

		if year(_date_added) = 2025 then --ES AGENTE NUEVO, LO COLOCO EN RANGO 6
			let _nombre_tipo = "Rango 6";
		end if
		 
		if _flag = 0 then
			let _puntos_tiene = _prima_suscrita * _puntos;
			
			insert into miami(
			cod_agente,
			no_documento,
			n_agente,
			prima_sus_nva,
			cod_vendedor,
			nombre_vendedor,
			cod_ramo,
			nombre_ramo,
			rango,
			punto,
			puntos_tiene
			)
			values(
			_cod_agente, 
			_no_documento, 
			_nombre,
			_prima_suscrita,
			_cod_vendedor,
			_nombre_vendedor,
			_cod_ramo,
			_nombre_ramo,
			_nombre_tipo,
			_puntos,
			_puntos_tiene);
		end if
	end foreach
    --************* 
end foreach
drop table tmp_caribe;
return 0;
END PROCEDURE;