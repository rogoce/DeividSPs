-- Procedimiento que genera la informacion de las polizas nuevas y renovadas
-- en un rango de fechas 
-- Creado    : 23/02/2011 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo077_2gen;
create procedure "informix".sp_bo077_2gen(a_fecha_ini date, a_fecha_fin date, a_fecha_cobro date default "01/01/1900")
returning integer, char(20);

define _no_poliza		char(10);
define _no_documento	char(20);
define _nueva_renov		char(1);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
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
define _periodo_reno	char(7);
define _ano_ant			integer;
define li_dia           integer;
define li_mes           integer;
define li_mvi,li_mpi    integer;

define _fecha_min_pago	date;
define _fecha_pago,_vi_ini      date;
define _reemplaza_pol	char(30);
define _no_renovar,_pagada	smallint;
define _cnt_cam				smallint;
define _fecha_canc,_vigencia_aniv   date;
define _monto               dec(16,2);

--set debug file to "sp_bo077.trc";
--trace on;

--drop table tmp_persis;

create temp table tmp_persis(
no_documento		char(20),
no_pol_nueva		integer		default 0,
no_pol_nueva_per	integer		default 0,
no_pol_renov		integer 	default 0,
no_pol_renov_per	integer		default 0,
cambio_plan         integer     default 0,
vigencia_aniv       date,
fecha_pago          date,
pagada              smallint    default 0,
vigencia_inic       date,
vigencia_act        date,
fecha_canc          date        
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

foreach
	select no_poliza
	  into _no_poliza
	  from endedmae
	 where cod_compania  = "001"
	   and actualizado   = 1
	   and cod_endomov   = "011"
	   and vigencia_inic >= a_fecha_ini
	   and vigencia_inic <= '30/09/2020'
	   and no_documento in(
	   select no_documento from genesis
		where no_estaba = 1)
	 
	let _fecha_canc = null; 

	select nueva_renov,
	       no_documento,
		   vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   cod_subramo,
		   estatus_poliza,
		   reemplaza_poliza,
		   no_renovar,
		   fecha_cancelacion
	  into _nueva_renov,
	       _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _cod_subramo,
		   _estatus_poliza,
		   _reemplaza_pol,
		   _no_renovar,
		   _fecha_canc
	  from emipomae
	 where no_poliza = _no_poliza;

	let _reemplaza_pol = TRIM(_reemplaza_pol);
	let _no_poliza_per = 1;
	if _cod_ramo = "008" then	        --fianza
		let _no_poliza_per = 0;
	elif _cod_ramo = "009" then	        --transporte
		if _cod_subramo = "003" then    --aereo
			let _no_poliza_per = 0;
		elif _cod_subramo = "004" then  --Maritimo
			let _no_poliza_per = 0;
		end if
		if _no_renovar = 1 then
			let _no_poliza_per = 0;
		end if
	elif _cod_ramo = "013" then	        --Montaje
		let _no_poliza_per = 0;
	elif _cod_ramo = "014" then	        --car
		let _no_poliza_per = 0;

	-- Por instrucciones del Sr. Tobias, las Sodas se van a renovar a Partir de Octubre 2012
	-- Demetrio Hurtado (02/10/2012)
	elif _cod_ramo = "020" then	 		--Soda 
		let _no_poliza_per = 0;
	end if

	if _cod_ramo <> "018" then

		if (_vigencia_final - _vigencia_inic) < 365 then
			let _no_poliza_per = 0;
		end if

	end if
    let _pagada  = 0;
	let _cnt_cam = 0;
	let _monto   = 0.00;
	
	select sum(monto),
	       min(fecha),
	       max(fecha)
	  into _monto,
	       _fecha_min_pago,
	       _fecha_pago
      from cobredet
     where no_poliza   = _no_poliza
       and actualizado = 1
	   and fecha       <= a_fecha_cobro;

	if _monto is null then
		let _monto = 0.00;
	end if
	if _fecha_pago is null then
		let _fecha_pago = '01/01/1900';
	end if
	if _nueva_renov = "N" then
		if _cod_ramo = "018" then
			IF _reemplaza_pol <> "" or _reemplaza_pol is not null then
				let _cnt_cam = 0;
				let _cnt_cam = sp_bo077b(_reemplaza_pol);	--Busca si tiene cambio de plan.
			END IF
			let _vigencia_aniv = mdy(month(_vigencia_inic), day(_vigencia_inic), year(a_fecha_fin));
			{select pagada,
			       vigencia_inic,
				   fecha_pago
			  into _pagada,
                   _vi_ini,
                   _fecha_pago				   
			  from emiletra
			 where no_poliza     = _no_poliza
			   and vigencia_inic = _vigencia_aniv;}
		end if
		if _monto >= 1 And _fecha_min_pago <= a_fecha_fin then
			let _pagada = 1;
		end if
   		if _pagada is null then
			let _pagada = 0;
		end if		   
		if _pagada = 0 then
			continue foreach;
		end if
		
		if _cnt_cam > 0 then	   --tiene cambio de plan, debe colocarse como renovada
			insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per,cambio_plan,vigencia_aniv,fecha_pago,pagada,vigencia_inic,vigencia_act,fecha_canc)
			values (_no_documento, 1, 1,1,_vigencia_aniv,_fecha_pago,_pagada,_vi_ini,'01/01/1900','01/01/1900');
		else		
			insert into tmp_persis(no_documento, no_pol_nueva, no_pol_nueva_per,cambio_plan,vigencia_aniv,fecha_pago,pagada,vigencia_inic,vigencia_act,fecha_canc)
			values (_no_documento, 1, _no_poliza_per,0,_vigencia_aniv,_fecha_pago,_pagada,_vigencia_inic,'01/01/1900','01/01/1900');
		end if	

	else
		if _monto >= 1 then
			let _pagada = 1;
		end if
		if _pagada = 0 then
			continue foreach;
		end if
		if _cod_ramo <> "018" then
			insert into tmp_persis(no_documento, no_pol_renov, no_pol_renov_per,cambio_plan,vigencia_aniv,fecha_pago,pagada,vigencia_inic,vigencia_act,fecha_canc)
			values (_no_documento, 1, _no_poliza_per,0,_vigencia_inic,_fecha_pago,_pagada,_vigencia_inic,'01/01/1900','01/01/1900');
		end if
	end if
end foreach

return 0, 'Proceso Finalizado';
end procedure