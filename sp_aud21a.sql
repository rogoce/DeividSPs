--***********************************************************************************
-- Bonificacion de aud_renta al perido actual -- Tabla de aud_renta progresiva
-- COPIA de sp_aud21 para presentar datos por filtro de corredor. 
-- Realizado: Henry Giron                     -- Fecha: 08/02/2011
--***********************************************************************************
-- execute procedure sp_aud21a("001","001")
-- Creado    : 24/03/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_aud21a;

CREATE PROCEDURE sp_aud21a(a_compania CHAR(3),a_sucursal CHAR(3)) 
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
DEFINE v_monto_60       DEC(16,2);
define v_monto_90       DEC(16,2);
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
define _incremento_psp  dec(16,2);
define _crecimiento     dec(16,2);
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
define _prima_orig      DEC(16,2);
define _prima_suscrita  DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cantidad        integer;
define _fecha_aa_ini     date;
define _fecha_aa        date;
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
define _no_pol_ren_aa_per	integer;
define _no_pol_ren_ap_per	integer;

define _estatus_poliza	smallint;
define _pri_sus_pag_ap  DEC(16,2);
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

define _porc_res_mat	dec(5,2);
define _agente_agrupado char(5);

define _cod_tipo        char(1);
define _n_cod_tipo 	    char(50);
define _pri_sus_pag     dec(16,2);
define _valor_prima     dec(16,2);
define _porcentaje      dec(16,2);
define _prima_max       dec(16,2);
define _pri_devengada   dec(16,2);
define _unificar        smallint;

define _pri_cob_dev     dec(16,2);
define _pri_cob_dev_max dec(16,2);
define _pri_sus_dev     dec(16,2);
define _pri_sus_dev_max dec(16,2);
define _pri_cob         dec(16,2);
define _pri_cob_max     dec(16,2);
define _valor_cob_dev 	dec(16,2);
define _valor_sus_dev 	dec(16,2);
define _valor_cob     	dec(16,2);
define _pri_sus_orig    dec(16,2);
define _porc_res_xramo  dec(16,2);
define _prima_suscrita_ap dec(16,2);


-- SET DEBUG FILE TO "sp_aud21.trc";
-- TRACE ON;

-- Desactivado por Order de Demetrio, para que no afecte los calculos realizados.
-- Return 0;


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
let _pri_sus_pag_ap = 0;
let _prima_suscrita_ap = 0;
let _monto_90_aa    = 0;
let _pri_can		= 0;
let	_pri_dev		= 0;
let _monto_90_ap    = 0;
let _pri_devengada  = 0;
let _pri_cob_dev     = 0;
let _pri_cob_dev_max = 0;
let _pri_cob_max     = 0;
let _pri_cob         = 0;
let _pri_sus_dev     = 0;
let _pri_sus_dev_max = 0;
let _pri_sus         = 0;
let _pri_sus_orig  	  = 0;
let _porc_res_xramo	  = 0;
drop table tmprenta;

--delete from aud_renta;
--delete from tmp_che115;

select par_ase_lider,
       par_periodo_act
  into _cod_coasegur,
	   a_periodo
  from parparam
 where cod_compania = a_compania;

if a_periodo > "2010-12" then
	let a_periodo = "2010-12";
end if

let _per_ini        = "2010-01";
let _per_ini_ap     = "2009-01";
let _ano            = a_periodo[1,4];
let _ano            = _ano - 1;
let _per_fin_ap     = _ano || a_periodo[5,7];

let _per_fin_dic    = "2009-12";         
let _fecha_aa_ini   = sp_sis36(_per_ini);
let _fecha_aa       = sp_sis36(a_periodo);
let _fecha_ap_ini   = sp_sis36(_per_ini_ap);
let _fecha_ap       = sp_sis36(_per_fin_ap);

{create temp table tmp_che115(
no_documento		char(20),
pri_sus_pag			dec(16,2) 	default 0,
pri_pag				dec(16,2) 	default 0,
pri_can				dec(16,2) 	default 0,
pri_dev  			dec(16,2) 	default 0,
sin_pag_aa      	dec(16,2) 	default 0,
sin_pen_aa      	dec(16,2) 	default 0,
sin_pen_ap      	dec(16,2) 	default 0,
no_pol_ren_aa		integer 	default 0,
no_pol_ren_ap		integer 	default 0,
no_pol_nue_aa		integer		default 0,
no_pol_nue_ap		integer		default 0,
no_pol_nue_ap_per	integer		default 0,
pri_sus_pag_ap		dec(16,2) 	default 0,
pri_pag_ap			dec(16,2) 	default 0,
pri_can_ap			dec(16,2) 	default 0,
pri_dev_ap 			dec(16,2) 	default 0,
no_pol_ren_aa_per	integer		default 0,
no_pol_ren_ap_per	integer		default 0,
tipo				integer     default 0
) with no log;}

create temp table tmprenta(
cod_agente	        char(5),
periodo				char(7),
tipo				char(1),
prima_neta			dec(16,2) 	default 0,
comision			dec(16,2) 	default 0,
porcentaje			dec(16,2) 	default 0,
por_crecimiento		dec(16,2) 	default 0,
por_siniestro		dec(16,2) 	default 0,
prima_max			dec(16,2) 	default 0,
pri_cob_dev         dec(16,2) 	default 0,
pri_cob_dev_max     dec(16,2) 	default 0,
pri_sus_dev         dec(16,2) 	default 0,
pri_sus_dev_max     dec(16,2) 	default 0,
pri_cob			    dec(16,2) 	default 0,
pri_cob_max         dec(16,2) 	default 0) with no log;

SET ISOLATION TO DIRTY READ;

--/***************************************/
-- SE ACUMULARAN POR RAMO - GLOBAL
--/***************************************/
foreach
	select tipo,
		   cod_agente,
		   sum(pri_sus_pag_aa),
		   sum(pri_sus_pag_ap),
		   sum(sini_inc),
		   sum(prima_devengada),
		   sum(pri_cob_dev) 
	  into _cod_tipo,
		   _cod_agente,
		   _pri_sus_pag, 	 --prima cobrada
		   _pri_sus_pag_ap, 
		   _sini_incu,
		   _pri_devengada,	 --prima suscrita devengada
		   _pri_cob_dev		 --prima cobrada devengada
	  from aud_renta
	 where periodo    = a_periodo
--	   and monto_90   = 0
	 group by cod_agente,tipo
	 order by cod_agente,tipo

	let _valor_prima = 0;
	let _porcentaje  = 0;
	let _prima_max   = 0;
	let _pri_cob_dev_max = 0;
	let _pri_cob_max = 0;
	let _valor_cob_dev = 0;
	let _valor_sus_dev = 0;
	let _valor_cob     = 0;
	let _pri_cob       = 0;
	let _pri_sus_dev     = 0;
	let _pri_sus_dev_max = 0;

	let _pri_cob       = _pri_sus_pag;
	let _pri_sus_dev   = _pri_devengada;

	let _prima_max = (_pri_sus_pag * 15)/100;
	let _pri_cob_max = (_pri_sus_pag * 15)/100;
	let _pri_cob_dev_max = (_pri_cob_dev * 15)/100;
	let _pri_sus_dev_max = (_pri_devengada * 15)/100;

	--************************************************
	--   Calculos de aud_renta
	--************************************************ 
	if _pri_sus_pag = 0  then	  
		continue foreach;
	end if

	let _incremento_psp       = 0;
	let _crecimiento          = 0;
	let _siniestralidad       = 0;			
	let _valor_prima          = 0;
	let _porcentaje			  = 0;
	let _valor_cob_dev        = 0;
	let _valor_cob			  = 0;

	--************************************************
	--   Calculos para incremeto de PSP 2010 vs 2009
	--************************************************
	let _incremento_psp  = _pri_sus_pag - _pri_sus_pag_ap ;				

	--************************************************
	--   Calculos % de crecimiento de PSP
	--************************************************
	if _pri_sus_pag_ap <> 0 then
		let _crecimiento = ((_pri_sus_pag - _pri_sus_pag_ap) / _pri_sus_pag_ap) * 100;
	else
		let _crecimiento = 100; 
	end if
	
	{if _crecimiento = 0 then 
		let _crecimiento = 100; 
	end if		}
	--************************************************
	--    Calculos % de siniestralidad 2010	
	--************************************************
	let _siniestralidad = 0;
	if _pri_devengada <> 0 then
		let _siniestralidad = (_sini_incu / _pri_devengada) * 100;
	else
		continue foreach;
	end if						
	--************************************************
	--   Condicionar aud_renta
	--************************************************
	if _cod_tipo = 'A' then	  --   automovil
		if _pri_sus_pag >= 25000 then 
			if _crecimiento >= 40 then						
				if _siniestralidad <= 40 then
					let _porcentaje = 5;
				end if	 
				if _siniestralidad > 40 and _siniestralidad <= 45 then
					let _porcentaje = 4;
				end if
				if _siniestralidad > 45 and _siniestralidad <= 50 then
					let _porcentaje = 3;
				end if
			end if					
		end if
	end if 

	if _cod_tipo = 'B' then  --    salud
		if _pri_sus_pag >= 15000 then 
			if _crecimiento >= 40 then						
				if _siniestralidad <= 40 then
					let _porcentaje = 5;
				end if	 
				if _siniestralidad > 40 and _siniestralidad <= 50 then
					let _porcentaje = 4;
				end if
			end if					
		end if
	end if 
	
	if _cod_tipo = 'C' then     -- patrimoniales
		if _pri_sus_pag >= 15000 then 
			if _crecimiento >= 40 then						
				if _siniestralidad <= 30 then
					let _porcentaje = 5;
				end if	 
				if _siniestralidad > 30 and _siniestralidad <= 40 then
					let _porcentaje = 4;
				end if
				if _siniestralidad > 40 and _siniestralidad <= 50 then
					let _porcentaje = 3;
				end if
			end if					
		end if
	end if 					

	if _cod_tipo = 'D' then	  --   Personas
		if _pri_sus_pag >= 15000 then 
			if _crecimiento >= 40 then	
				if _siniestralidad <= 40 then
					let _porcentaje = 5;
				end if	 
				if _siniestralidad > 40 and _siniestralidad <= 45 then
					let _porcentaje = 4;
				end if
				if _siniestralidad > 45 and _siniestralidad <= 50 then
					let _porcentaje = 3;
				end if
			end if					
		end if
	end if 	  

	if _cod_tipo = 'E' then	  --  Fianzas
		if _pri_sus_pag >= 50000 then 
			if _crecimiento >= 30 then						
				if _siniestralidad <= 10 then
					let _porcentaje = 3;
				end if	 			   
			end if					
		end if
	end if 		  	
																																		         
	if _porcentaje <> 0 then																											     
		-- Para el valor de la comision se tomara en base al porcentaje 																			    
		--let _valor_prima = _pri_sus_pag * ( _porcentaje / 100);
		let _valor_prima = _pri_devengada * ( _porcentaje / 100);

		let _valor_cob     = _pri_sus_pag * ( _porcentaje / 100);
		let _valor_cob_dev = _pri_cob_dev * ( _porcentaje / 100);
		let _valor_sus_dev = _pri_devengada * ( _porcentaje / 100);

	   --	if _valor_prima > _pri_sus_dev_max then
	   --	   let _valor_prima = _pri_sus_dev_max ;
	   --	end if

	   {	if 	_valor_prima > _prima_max then
			let _valor_prima = _prima_max ;
			let _valor_cob_dev = _pri_cob_dev_max;
			let _valor_cob = _pri_cob_max;
		end if  }
																																	    
    	INSERT INTO tmprenta(cod_agente,periodo,tipo,prima_neta,comision,porcentaje,por_crecimiento,por_siniestro,prima_max,pri_cob_dev_max, pri_sus_dev_max,pri_cob_max) 		  
		VALUES (_cod_agente,a_periodo,_cod_tipo,_pri_sus_pag,_valor_prima,_porcentaje,_crecimiento,_siniestralidad,_prima_max,_valor_cob_dev,_valor_sus_dev,_valor_cob) ; 	      

	end if
end foreach	   

foreach
	select cod_agente,
		   periodo,
		   tipo,
		   prima_neta,
		   comision,
		   porcentaje,
		   por_crecimiento,
		   por_siniestro,
		   prima_max,
		   pri_cob_dev_max,     
		   pri_sus_dev_max,
		   pri_cob_max         
	  into _cod_agente,
		   a_periodo,
		   _cod_tipo,
		   _pri_sus_pag,
		   _valor_prima,
		   _porcentaje,
		   _crecimiento,
		   _siniestralidad,
		   _prima_max,
		   _pri_cob_dev_max,     
		   _pri_sus_dev_max,
		   _pri_cob_max  
	from tmprenta
	order by 2,1,3 

		update aud_renta
		set prima_neta      = _pri_sus_pag,
			comision        = _valor_prima,
			porcentaje      = _porcentaje,
			por_crecimiento = _crecimiento,
			por_siniestro   = _siniestralidad,
			prima_max       = _prima_max,
		    pri_cob_dev_max	= pri_cob_dev*_porcentaje/100,  
		    pri_sus_dev_max	= pri_sus_dev*_porcentaje/100, 
		    pri_cob_max     = pri_cob*_porcentaje/100    
	  where periodo         = a_periodo
		and cod_agente      = _cod_agente
		and tipo            = _cod_tipo ;
--		and monto_90        = 0;		

end foreach	  


--drop table tmp_che115;
--drop table tmprenta;

return 0;

END PROCEDURE;
