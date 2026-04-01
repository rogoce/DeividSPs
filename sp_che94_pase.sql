--***********************************************************************************
-- Procedimiento que genera la Bonificacion de rentabilidad por corredores
--***********************************************************************************
-- execute procedure sp_che94_pase("001","001","2010-12","HGIRON")
-- Creado    : 28/01/2009 - Autor: Henry Giron
-- Modificado: 28/01/2009 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- Se cambio el calculo se realiza diario en sp_che115

DROP PROCEDURE sp_che94_pase;
CREATE PROCEDURE sp_che94_pase(
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
DEFINE _unificar        smallint;

define _porc_res_mat	dec(5,2);
define _prima_suscrita  DEC(16,2);
define _pri_cob_dev     dec(16,2);
define _fecha_genera    date;
define _seleccionado	smallint;
define _pri_sus_dev     dec(16,2);



--SET DEBUG FILE TO "sp_che94_pase.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

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
let _fecha_genera   = current;

delete from chqrenta3 where periodo = v_periodo_aa and tipo_g = 'D' ;
delete from chqrenta where periodo = v_periodo_aa and tipo = 'D' ;


--insert chqrenta
foreach
	select cod_agente,
	no_documento,
	pri_sus_pag_aa,
	pri_sus_pag_ap,
	sini_inc,
	n_agente,  		
	cod_contratante,
	n_cliente,
	'2010-12',--periodo,
	0,--renovaa,
	0,--renovap,
	0,--pri_pag_aa,
	0,--pri_can_aa,
	0,--pri_dev_aa,
	monto_90,--monto_90_aa,
	0,--pri_pag_ap,
	0,--pri_can_ap,
	0,--pri_dev_ap,
	0,--monto_90_ap,
	cod_vendedor,
	nombre_vendedor,
	cod_ramo,
	nombre_ramo,
	tipo_agente,
	tipo,
	prima_devengada --pri_sus_dev
	into _cod_agente, 
	 _no_documento, 
	 _prima_sus_pag, 
	 _pri_sus_pag_ap, 
	 _sini_incu, 
	 _nombre, 
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
	 _tipo,
	 _pri_sus_dev
	 from  rentabilidad -- aud_renta
	 where tipo = "D"
--	 where  cod_agente = '00874'  
	 order by  1,2


		insert into chqrenta(
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
		tipo,
		pri_sus_dev
		)
		values(
		_cod_agente, 
		_no_documento, 
		_prima_sus_pag, 
		_pri_sus_pag_ap, 
		_sini_incu, 
		_nombre, 
 		_fecha_genera,
		_fecha_genera,
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
		_tipo,
	    _pri_sus_dev
		);

end foreach

--/***************************************/
-- SE ACUMULARAN POR RAMO - GLOBAL
--/***************************************/

let _cnt_act = 0;
let _cnt_ant = 0;	
let a_periodo = '2010-12';

foreach
   Select cod_agente,
		  tipo,
		  count(*)
	 into _cod_agente, 
		  _cod_tipo,
		  _cnt_act
	 from chqrenta
	where periodo = a_periodo
	  and tipo = "D"
--	  and monto_90_aa = 0
 group by 1,2
 order by 1,2  

   SELECT nombre,
   	      no_licencia
	 INTO _nombre,
		  _no_licencia
	 FROM agtagent
	WHERE cod_agente = _cod_agente;

   foreach
		select tipo,
			   cod_agente,
			   sum(pri_sus_pag_aa),
			   sum(pri_sus_pag_aa),
			   sum(pri_sus_pag_ap),
			   sum(sini_inc),
			   sum(pri_sus_dev) 
		  into _cod_tipo1,
			   _cod_agente1,
			   _prima_neta,
			   _pri_sus_pag, 
			   _pri_sus_pag_ap, 
			   _sini_incu,
			   _prima_suscrita			--	Prima suscrita Devengada
		  from chqrenta
		 where periodo    = a_periodo
		   and cod_agente = _cod_agente
		   and tipo       = _cod_tipo
--	       and monto_90_aa = 0
		 group by tipo,cod_agente

		let _valor       = 0.00;	
		let _valor_prima = 0;
		let _porcentaje  = 0;
	    let _crecimiento = 0;
	    let _siniestralidad = 0;

		if _prima_suscrita is null then
			let _prima_suscrita = 0;
		end if

		--************************************************
		--   Calculos de aud_renta         -- rentabilidad
		--************************************************ 
		foreach
		select porcentaje,por_crecimiento,por_siniestro,comision
		  into _porcentaje,_crecimiento,_siniestralidad,_valor_prima
		  from rentabilidad
		 where cod_agente = _cod_agente
		   and tipo       = _cod_tipo 
	       and monto_90   = 0
		   order by porcentaje desc
		  exit foreach;
		   end foreach

		if _porcentaje <> 0 then

				let _no_poliza = '' ;
				let _no_documento = '' ; 

				let _cod_subramo = '' ; 
				let _cod_origen = '' ; 
				let _cod_contr = '' ; 
				let v_nombre_clte = '' ; 
				let _nombre_ramo = '' ;

                let _tipo_g       = _cod_tipo ;
                let _prima_neta_g = _prima_suscrita; --_prima_neta ;
                let _comision_g   = _valor_prima ;
                let _porcentaje_g = _porcentaje ;
                let _por_cre_g    = _crecimiento ;
                let _por_sin_g    = _siniestralidad ;
                let _prima_ap_g   = _pri_sus_pag_ap ;
			    let _sini_g       = _sini_incu;

				if  _cod_tipo = 'A' then 
				  let _nombre_tipo_g = 'AUTOMOVIL'  ;
                end if
				if  _cod_tipo = 'B' then 
				  let _nombre_tipo_g = 'SALUD'  ;
                end if
				if  _cod_tipo = 'C' then 
				  let _nombre_tipo_g = 'PATRIMONIAL'  ;
                end if
				if _cod_tipo = 'D' then 
				  let _nombre_tipo_g = 'PERSONAS'  ;
                end if
				if  _cod_tipo = 'E' then 
				  let _nombre_tipo_g = 'FIANZAS'  ;
                end if

   				foreach
					select cod_ramo, 
						   sum(pri_sus_pag_aa),
						   sum(pri_sus_pag_aa),
						   sum(pri_sus_pag_ap),
						   sum(sini_inc),
						   sum(pri_sus_dev) 
					  into _cod_ramo,
						   _prima_neta,
						   _pri_sus_pag, 
						   _pri_sus_pag_ap, 
						   _sini_incu,
						   _prima_suscrita			--	Prima suscrita Devengada
					  from chqrenta
					 where periodo    = a_periodo
					   and cod_agente = _cod_agente
					   and tipo       = _cod_tipo
--					   and monto_90_aa = 0
				  group by cod_ramo


						let _valor       = 0.00;	
						let _valor_prima = 0;
						let _porcentaje  = 0;

						if _prima_suscrita is null then
							let _prima_suscrita = 0;
						end if

						--************************************************
						--   Calculos de aud_renta         -- rentabilidad
						--************************************************				
				
						let _incremento_psp       = 0;
						let _crecimiento          = 0;
						let _siniestralidad       = 0;
						let _sini_aplica          = 0;
						let _cre_prima_aplica     = 0;
						let _min_prima_pag_aplica = 0;
						let _beneficio            = 0;				
				
						--************************************************
						--   Calculos para incremeto de PSP 2008 vs 2007
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
						
			  {			if _crecimiento = 0 then
						let _crecimiento = 100;
						end if}
						
						--************************************************
						--    Calculos % de siniestralidad 2008	
						--************************************************
						let _siniestralidad = 0;
						if _pri_sus_pag <> 0 then
							let _siniestralidad = (_sini_incu / _pri_sus_pag) * 100;
						end if				
						 let _sini_i   = _sini_incu;

						--************************************************
						--   Condicionar aud_renta         -- rentabilidad
						--************************************************				
						if _cod_tipo = 'A' then	  --   automovil
				
							if _pri_sus_pag >= 25000 then 
								--let _min_prima_pag_aplica = 1; 
								if _crecimiento >= 40 then
								-- let _cre_prima_aplica = 1;
										
									if _siniestralidad <= 40 then
										let _valor_prima = _prima_neta * (5 / 100);
										let _porcentaje = 5;
									end if	 
				
									if _siniestralidad > 40 and _siniestralidad <= 45 then
										let _valor_prima = _prima_neta * (4 / 100);
										let _porcentaje = 4;
									end if
				
									if _siniestralidad > 45 and _siniestralidad <= 50 then
										let _valor_prima = _prima_neta * (3 / 100);
										let _porcentaje = 3;
									end if
				
								end if					
				
							end if
				
						end if 
				
						if _cod_tipo = 'B' then  --    salud
				
							if _pri_sus_pag >= 15000 then 
								--let _min_prima_pag_aplica = 1; 
								if _crecimiento >= 40 then
								-- let _cre_prima_aplica = 1;
										
									if _siniestralidad <= 40 then
										let _valor_prima = _prima_neta * (5 / 100);
										let _porcentaje = 5;
									end if	 
				
									if _siniestralidad > 40 and _siniestralidad <= 50 then
										let _valor_prima = _prima_neta * (4 / 100);
										let _porcentaje = 4;
									end if
				
									if _siniestralidad > 50 and _siniestralidad <= 60 then
										let _valor_prima = _prima_neta * (3 / 100);
										let _porcentaje = 3;
									end if
				
								end if					
				
							end if
				
						end if 
						
						if _cod_tipo = 'C' then     -- patrimoniales
				
							if _pri_sus_pag >= 15000 then 
								--let _min_prima_pag_aplica = 1; 
								if _crecimiento >= 40 then
								-- let _cre_prima_aplica = 1;
										
									if _siniestralidad <= 30 then
										let _valor_prima = _prima_neta * (5 / 100);
										let _porcentaje = 5;
									end if	 
				
									if _siniestralidad > 30 and _siniestralidad <= 40 then
										let _valor_prima = _prima_neta * (4 / 100);
										let _porcentaje = 4;
									end if
				
									if _siniestralidad > 40 and _siniestralidad <= 50 then
										let _valor_prima = _prima_neta * (3 / 100);
										let _porcentaje = 3;
									end if
				
								end if					
				
							end if
				
						end if 					
				
				
						if _cod_tipo = 'D' then	  --   Personas
				
							if _pri_sus_pag >= 15000 then 
								--let _min_prima_pag_aplica = 1; 
								if _crecimiento >= 40 then
								-- let _cre_prima_aplica = 1;
										
									if _siniestralidad <= 40 then
										let _valor_prima = _prima_neta * (5 / 100);
										let _porcentaje = 5;
									end if	 
				
									if _siniestralidad > 40 and _siniestralidad <= 45 then
										let _valor_prima = _prima_neta * (4 / 100);
										let _porcentaje = 4;
									end if
				
									if _siniestralidad > 45 and _siniestralidad <= 50 then
										let _valor_prima = _prima_neta * (3 / 100);
										let _porcentaje = 3;
									end if
				
								end if					
				
							end if
				
						end if 
				
				
						if _cod_tipo = 'E' then	  --  Fianzas
				
							if _pri_sus_pag >= 50000 then 
								--let _min_prima_pag_aplica = 1; 
								if _crecimiento >= 30 then
								-- let _cre_prima_aplica = 1;
										
									if _siniestralidad <= 10 then
										let _valor_prima = _prima_neta * (3 / 100);
										let _porcentaje = 3;
									end if	
				
								end if 
				
							end if
				
						end if 

						select nombre
						  into _nombre_ramo
						  from prdramo
						 where cod_ramo = _cod_ramo; 

						-- Para el valor de la comision se tomara en base al porcentaje global por prima neta de cada ramo
--						let _valor_prima = _prima_neta * ( _porcentaje_g / 100);   -- calculo en base a Pruima Suscrita Devengada. A.NARANJO f:07/01/2011
						let _valor_prima = _prima_suscrita * ( _porcentaje_g / 100);

						--if 	_cod_agente  not in ("00211","00769","00237") then

							-- Se otorgara el 5% PSP

							INSERT INTO chqrenta3(cod_agente,no_poliza,prima_neta,comision,nombre,no_documento,no_licencia,seleccionado,periodo,fecha_genera,cod_ramo,
											cod_subramo,cod_origen,nombre_cte,por_persistencia,porcentaje,por_cre,por_sin,prima_ap,nombre_ramo,
											nombre_tipo_g,tipo_g,prima_neta_g,comision_g,porcentaje_g,por_cre_g,por_sin_g,prima_ap_g,sini_g,sini )
							VALUES (_cod_agente,_no_poliza,_prima_neta,_valor_prima,_nombre,_no_documento,_no_licencia,0,a_periodo,current,_cod_ramo,
								  _cod_subramo,_cod_origen,v_nombre_clte,_valor,_porcentaje,_crecimiento,_siniestralidad,_pri_sus_pag_ap, _nombre_ramo,
								  _nombre_tipo_g,_tipo_g,_prima_neta_g,_comision_g,_porcentaje_g,_por_cre_g,_por_sin_g,_prima_ap_g,_sini_g,_sini_i  );
--					    end if

				end foreach	 
							
		end if

	end foreach	   

end foreach	 


{--insert chqrenta3
foreach
	select cod_agente,
	' ',--no_poliza,
	pri_sus_pag_aa, --prima_neta,
	pri_sus_dev_max, --comision,
	n_agente, --nombre,
	no_documento,
	'',--no_licencia,
	1, --seleccionado,
	'2010-12', --periodo,
	cod_ramo,
	'',--cod_subramo,
	'',--cod_origen,
	n_cliente,--nombre_cte,
	0,--por_persistencia,
	0,--porcentaje,
	0,--por_cre,
	0,--por_sin,
	0,--prima_ap,
	nombre_ramo,
	nombre_tipo,
	tipo,
	prima_devengada, --prima_neta_g,
	comision, --comision_g,
	porcentaje, --porcentaje_g,
	por_crecimiento,
	por_siniestro,
	0,--prima_ap_g,
	0,--sini_g,
	0--sini
    into _cod_agente,
	 _no_poliza,
	 _prima_neta,
	 _valor_prima,
	 _nombre,
	 _no_documento,
	 _no_licencia,
	 _seleccionado,
	 a_periodo,
	 _cod_ramo,
	 _cod_subramo,
	 _cod_origen,
	 v_nombre_clte,
	 _valor,
	 _porcentaje,
	 _crecimiento,
	 _siniestralidad,
	 _pri_sus_pag_ap,
	 _nombre_ramo,
	 _nombre_tipo_g,
	 _tipo_g,
	 _prima_neta_g,
	 _comision_g,
	 _porcentaje_g,
	 _por_cre_g,
	 _por_sin_g,
	 _prima_ap_g,
	 _sini_g,
	 _sini_i  
	from aud_renta         -- rentabilidad
	 where  porcentaje <> 0 and cod_agente  = '00874'  
--	 order by  4

   SELECT no_licencia
	 INTO _no_licencia
	 FROM agtagent
	WHERE cod_agente = _cod_agente;

		INSERT INTO chqrenta3(
		cod_agente,
		no_poliza,
		prima_neta,
		comision,
		nombre,
		no_documento,
		no_licencia,
		seleccionado,
		periodo,
		fecha_genera,
		cod_ramo,
		cod_subramo,
		cod_origen,
		nombre_cte,
		por_persistencia,
		porcentaje,
		por_cre,
		por_sin,
		prima_ap,
		nombre_ramo,
		nombre_tipo_g,
		tipo_g,
		prima_neta_g,
		comision_g,
		porcentaje_g,
		por_cre_g,
		por_sin_g,
		prima_ap_g,
		sini_g,
		sini )
		VALUES (
		_cod_agente,
		_no_poliza,
		_prima_neta,
		_valor_prima,
		_nombre,
		_no_documento,
		_no_licencia,
		0,
		a_periodo,
		_fecha_genera, --CURRENT to FRANTION(3),
		_cod_ramo,
		_cod_subramo,
		_cod_origen,
		v_nombre_clte,
		_valor,
		_porcentaje,
		_crecimiento,
		_siniestralidad,
		_pri_sus_pag_ap, 
		_nombre_ramo,
		_nombre_tipo_g,
		_tipo_g,
		_prima_neta_g,
		_comision_g,
		_porcentaje_g,
		_por_cre_g,
		_por_sin_g,
		_prima_ap_g,
		_sini_g,
		_sini_i  );


end foreach	}


{foreach
	SELECT cod_agente
	  INTO _cod_agente
	  FROM chqrenta3
     WHERE periodo = a_periodo
	 GROUP BY cod_agente
	 ORDER BY cod_agente

 	call sp_che98(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;

	if _error <> 0 then
		return _error,'Actualizacion Exitosa...Error.',a_periodo;
	end if

end foreach	

update parparam
   set ult_per_renta = a_periodo
 where cod_compania  = a_compania;
 }
end  

return 0, 'Actualizacion Exitosa...',a_periodo;

END PROCEDURE;	  