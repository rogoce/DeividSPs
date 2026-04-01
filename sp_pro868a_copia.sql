--***********************************************************************************
-- Procedimiento que genera Mini Convencion MIAMI 2018  --- COPIA PARA DATOS TEMPORAL
--***********************************************************************************
-- Creado    : 29/06/2018 - Autor: Henry Giron _copia detalle de tmpcaribe

DROP PROCEDURE sp_pro868a_copia;
CREATE PROCEDURE sp_pro868a_copia(a_compania CHAR(3),a_sucursal CHAR(3))
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
DEFINE _cnt_traspaso       SMALLINT;
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
DEFINE v_saldo,_monto_pen          DEC(16,2);
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
define _prima_sus_pag   DEC(16,2);
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
define _fecha_ap        date;
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
define _vigencia_inic	date;
define _vigencia_final	date;
define _tipo_persona	char(1);
define _nombre_tipo		char(20);
define _concurso,_unificar smallint;
define _pagada smallint;
DEFINE _porc_partic_agt    DEC(5,2);
define _meses           smallint;
define _valor           decimal(16,2);
define _cod_perpago     char(3);
define _cod_agente_anterior   char(5);

define _pri_sus_ap          DEC(16,2);
define _flag_1				smallint;
define _flag_2				smallint;
define _flag_3				smallint;
define _flag_4				smallint;
define _flag_5				smallint;
define _flag_pago           smallint;
define _no_pagos           smallint;
define _monto_pago          dec(16,2);
define _monto_pago_agt          dec(16,2);

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


let _fecha_aa_ini = "01/03/2018";
let _fecha_aa_fin = "30/06/2018";

let _prima_suscrita  = 0;
let _nombre_tipo     = "";
let _prima_sus_agt   = 0; 


create temp table tmp_caribe(
no_documento		char(20),
pri_sus				dec(16,2) 	default 0,
pri_pag				dec(16,2) 	default 0,
pri_pag_dif			dec(16,2) 	default 0,
cod_ramo            char(3),
pri_sus_ap			dec(16,2) 	default 0,
cod_agente          char(5),
no_pagos			smallint,
flag_pago           smallint,
monto_pago          dec(16,2)
) with no log;

CREATE INDEX xie01_tmp_caribe ON tmp_caribe(no_documento);
CREATE INDEX xie02_tmp_caribe ON tmp_caribe(no_documento,cod_agente);

SET ISOLATION TO DIRTY READ;

--Periodo de Clasificacion: Del 13 de febrero de 2017 al  10 de junio del 2017
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
	   and cod_ramo in('018','003','002','019')
	 group by no_documento
	 order by no_documento

	let _no_poliza = sp_sis21(_no_documento);
    let _flag_pago = 0;
    let _monto_pago = 0;

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
		   no_pagos
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
		   _no_pagos
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _cod_ramo = '018' And _cod_subramo = '012' then --Se excluye colectivo de Miami 07/06/2018
		continue foreach;
	end if

	let _monto_pen = 0;
	let _pagada    = 0;
	select monto_pen
	  into _monto_pen
	  from emiletra
	 where no_poliza = _no_poliza
	   and no_letra  = 1
	   and monto_pag <> 0;
	   
    if _monto_pen is null then
		let _pagada = 0;
	elif _monto_pen <= 10 then
		let _pagada = 1;
	end if

	if _pagada > 0 then	--Debe tener al menos un pago
		select sum(prima_neta)
		  into	_monto_pago
		  from cobredet
		 where actualizado  = 1
		   and no_poliza = _no_poliza
		   and tipo_mov     IN ('P', 'N', 'X')	; 	 
		   if _monto_pago is null then
		       continue foreach;		   
	       end if
	else
		continue foreach;
		{let _flag_pago = 1;
		select sum(prima_neta)
		  into	_monto_pago
		  from cobredet
		 where actualizado  = 1
		   and no_poliza = _no_poliza
		   and tipo_mov     IN ('P', 'N', 'X')	; 	 
		   	if _monto_pago is null then
		       continue foreach;		   
	       end if}
    end if

	if _estatus_poliza = 1 then  --solo polizas vigentes
	else
		continue foreach;
	end if
	if _cod_grupo in("00000","1000") then -- Excluir Estado
		continue foreach;
	end if

	let _prima_fac = 0.00;
	--Quitar el facultativo cedido
	select sum(c.prima)
	  into _prima_fac
	  from emifacon c, reacomae r
	 where c.no_poliza = _no_poliza
	   and c.no_endoso = '00000'
	   and r.cod_contrato = c.cod_contrato
	   and r.tipo_contrato = 3;
	   
	if _prima_fac is null then
		let _prima_fac = 0.00;
	end if
	let _prima_suscrita = _prima_suscrita - _prima_fac;
	if _cod_ramo = '018' then	--Para salud, debe ser la prima anualizada
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
	   CONTINUE FOREACH;
	end if
	
	select count(*)
	  into _cnt
	  from endedmae
	 where actualizado = 1
	   and no_poliza   = _no_poliza
	   and cod_endomov = '003';

	if _cnt > 0 then			--no polizas rehabilitadas
		continue foreach;
	end if 

  	select count(*)
	  into _cnt
	  from endedmae
	 where actualizado = 1
	   and no_poliza   = _no_poliza
	   and cod_endomov in('012','031');

	let _cnt_traspaso = 0;
	if _cnt > 0 then			--no Cambio de Corredores
		select count(*)
		  into _cnt_traspaso
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente in ('00623','01836','01569','01838');

		if _cnt_traspaso is null then
			let _cnt_traspaso = 0;
		end if
		
		if _cnt_traspaso = 0 then
			continue foreach;
		end if
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
			let _monto_pago_agt = 0;  
			let _prima_sus_agt = _prima_suscrita * _porc_partic_agt /100;
			let _monto_pago_agt = _monto_pago * _porc_partic_agt /100;
			
			--********  Unificacion de Agente *******
			call sp_che168(_cod_agente_anterior) returning _error,_cod_agente;
			select tipo_agente,estatus_licencia
			  into _tipo_agente,_estatus_licencia
			  from agtagent
			 where cod_agente = _cod_agente;

			IF _tipo_agente <> "A" OR _estatus_licencia <> "A" then	-- Solo Corredores
				continue foreach;
			END IF

			insert into tmp_caribe(no_documento, pri_sus, cod_ramo, cod_agente,flag_pago,monto_pago,no_pagos)
			values (_no_documento, _prima_sus_agt, _cod_ramo, _cod_agente,_flag_pago,_monto_pago_agt,_no_pagos);
		end foreach		
	end if

end foreach

--drop table tmp_caribe;
return 0;

END PROCEDURE;