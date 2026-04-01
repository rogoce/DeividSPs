-- Procedimiento que genera la informacion de las polizas nuevas y renovadas
-- en un rango de fechas 
-- Creado    : 23/02/2011 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo077_per;
create procedure sp_bo077_per(a_fecha_ini date, a_fecha_fin date)
returning integer, char(20);

define _no_poliza		char(10);
define _no_documento	char(20);
define _nueva_renov		char(1);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _cod_perpago		char(3);
define _estatus_poliza	integer;
define _no_poliza_per	integer;

define _vigencia_inic	date;
define _vigencia_final	date;
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;
define _vigencia_aniv_nva date;

define _periodo_ini		char(7);
define _periodo_fin		char(7);
define _ano_ant,_cnt	integer;
define li_dia,_error    integer;
define li_mes,_valor    integer;
define li_mvi,li_mpi    integer;
define _error_desc      varchar(50);

define _fecha_min_pago	date;
define _fecha_pago,_vi_ini      date;
define _reemplaza_pol	char(30);
define _declarativa,_pagada	smallint;
define _cnt_cam,_meses		smallint;
define _fecha_canc,_vigencia_aniv   date;
define _prima_suscrita              dec(16,2);

--set debug file to "sp_bo077.trc";
--trace on;

--drop table tmp_persis;

create temp table tmp_persis(
no_documento		char(20),
no_pol_nueva		integer		default 0,
no_pol_nueva_per	integer		default 0,
no_pol_renov		integer 	default 0,
no_pol_renov_per	integer		default 0,
no_poliza           char(10)
) with no log;

set isolation to dirty read;


-- Polizas Nuevas (Todos los Ramos)
-- Polizas Renovadas (Menos Salud)
let _vigencia_inic = '01/01/1900';
let _vigen_ini     = '01/01/1900';
let _vigencia_ant  = '01/01/1900';
let _vigencia_act  = '01/01/1900';
let _vigencia_aniv = '01/01/1900';
let _fecha_pago    = '01/01/1900';
let _fecha_min_pago = '01/01/1900';
let _vi_ini        = '01/01/1900';
let _no_documento  = '';
let _prima_suscrita = 0.00;

foreach
	select no_poliza
	  into _no_poliza		
	  from endedmae
	 where cod_compania  = "001"
	   and actualizado   = 1
	   and cod_endomov   = "011"
	   and vigencia_inic >= a_fecha_ini
	   and vigencia_inic <= a_fecha_fin
	 
	let _fecha_canc = null; 

	select nueva_renov,
	       no_documento,
		   vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   cod_subramo,
		   estatus_poliza,
		   reemplaza_poliza,
		   fecha_cancelacion,
		   declarativa,
		   prima_suscrita,
		   cod_perpago
	  into _nueva_renov,
	       _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _cod_subramo,
		   _estatus_poliza,
		   _reemplaza_pol,
		   _fecha_canc,
		   _declarativa,
		   _prima_suscrita,
		   _cod_perpago
	  from emipomae
	 where no_poliza = _no_poliza;

	let _reemplaza_pol = TRIM(_reemplaza_pol);
	let _no_poliza_per = 1;

	if _cod_ramo in('008','020') then	--Excluye Fianzas y SODA( por ser daños a tercer)
		continue foreach;
	end if
	
	if _declarativa is null then  --Excluye polizas declarativas
		let _declarativa = 0;
	end if
	if _declarativa = 1 then	--Se excluye polizas declarativas
		continue foreach;
	end if

	select pagada
	  into _pagada
	  from emiletra
	 where no_poliza = _no_poliza
	   and no_letra = 1;
		   
	if _pagada = 0 then        -- tomar en cuenta la primera letra de pago, DEBE ESTAR PAGADA
		call sp_pro525f(_no_poliza) returning _error,_error_desc;
		select pagada
		  into _pagada
		  from emiletra
		 where no_poliza = _no_poliza
		   and no_letra = 1;
		if _pagada = 0 then
			continue foreach;
		end if	
	end if
	
	if _cod_ramo = '018' then	--si es salud hay que anualizar la prima
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
			
	elif _cod_ramo in('002','023') then	--Excluir porlizas de daños a terceros
		select count(*)
		  into _cnt
		  from prdcober
		 where cod_cobertura in(
		select cod_cobertura from emipocob
		 where no_poliza = _no_poliza
		   and cod_cober_reas in('031','034'));

		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt = 0 then
			continue foreach;
		end if
	end if
	if _prima_suscrita <= 250 then
		continue foreach;
	end if
    let _pagada  = 0;
	let _cnt_cam = 0;

	if _nueva_renov = "N" then
		if _cod_ramo = "018" then
			IF _reemplaza_pol <> "" or _reemplaza_pol is not null then
				let _cnt_cam = 0;
				let _cnt_cam = sp_bo077b(_reemplaza_pol);	--Busca si tiene cambio de plan.
			END IF
			let _vigencia_aniv = mdy(month(_vigencia_inic), day(_vigencia_inic), year(a_fecha_fin));
		end if
		
		if _cnt_cam > 0 then	   --tiene cambio de plan, debe colocarse como renovada
			insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per,no_poliza)
			values (_no_documento, 1, 1,_no_poliza);
		else
			insert into tmp_persis(no_documento, no_pol_nueva, no_pol_nueva_per,no_poliza)
			values (_no_documento, 1, _no_poliza_per,_no_poliza);
		end if	
	else
		if _cod_ramo <> "018" then
			insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per,no_poliza)
			values (_no_documento, 1, _no_poliza_per,_no_poliza);
		end if
	end if
end foreach

-- Polizas Renovadas Salud

let _periodo_ini = sp_sis39(a_fecha_ini);
let _periodo_fin = sp_sis39(a_fecha_fin);

foreach
	select no_documento
	  into _no_documento
	  from endedmae
	 where periodo     >= _periodo_ini
	   and periodo     <= _periodo_fin
	   and actualizado = 1
	   and cod_endomov = "014"
	 group by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	select vigencia_inic
	  into _vigen_ini
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _vigen_ini <= a_fecha_fin And _vigen_ini >= a_fecha_ini then
		continue foreach;
	end if
	let _vigencia_aniv = mdy(month(_vigen_ini), day(_vigen_ini), year(a_fecha_fin));
    let _ano_ant = year(a_fecha_fin) -1;	
	if _vigencia_aniv > a_fecha_fin then
		let _vigencia_aniv_nva = mdy(month(_vigen_ini), day(_vigen_ini), _ano_ant);
	elif _vigencia_aniv <= a_fecha_fin then
		let _vigencia_aniv_nva = _vigencia_aniv;
	end if
	
	let _pagada = 0;
	
	foreach
		select pagada,
			   fecha_pago
		  into _pagada,
			   _fecha_pago				   
		  from emiletra
		 where no_poliza     = _no_poliza
		   and vigencia_inic = _vigencia_aniv_nva
		
		exit foreach;
	end foreach	
	   
	if _pagada is null then
		let _pagada = 0;
	end if	
	if _pagada = 0 then
		continue foreach;
	end if

	insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per,no_poliza)
	values (_no_documento, 1, 1,_no_poliza);

end foreach
return 0, 'Proceso Finalizado';
end procedure