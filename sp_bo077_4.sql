-- Procedimiento que genera la informacion de las polizas nuevas y renovadas
-- en un rango de fechas 
-- Creado    : 23/02/2011 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_bo077_4;
create procedure "informix".sp_bo077_4(a_fecha_ini date, a_fecha_fin date)
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

define _vigencia_soda	date;
define _vigencia_soda2	date;
define _fecha_pago,_vi_ini      date;
define _reemplaza_pol	char(30);
define _no_renovar,_pagada	smallint;
define _cnt_cam				smallint;
define _fecha_canc,_vigencia_aniv   date;


--set debug file to "sp_bo077.trc";
--trace on;

--drop table tmp_persis;

create temp table tmp_persis(
tipo                smallint,
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
periodo_reno        char(7),
periodo_ini         char(7),
periodo_fin         char(7),
vigencia_ant        date
) with no log;

set isolation to dirty read;

let _vigencia_soda  = mdy(10, 1, 2011);
let _vigencia_soda2 = mdy(10, 1, 2012);

-- Polizas Nuevas (Todos los Ramos)
-- Polizas Renovadas (Menos Salud)
let _vigencia_inic = '01/01/1900';
let _vigen_ini     = '01/01/1900';
let _vigencia_ant  = '01/01/1900';
let _vigencia_act  = '01/01/1900';
let _vigencia_aniv = '01/01/1900';
let _fecha_pago    = '01/01/1900';
let _vi_ini        = '01/01/1900';
let _no_documento  = '';

-- Polizas Renovadas Salud

let _periodo_ini = sp_sis39(a_fecha_ini);
let _periodo_fin = sp_sis39(a_fecha_fin);

foreach
	select no_documento,
		   max(periodo)
	  into _no_documento,
		   _periodo_reno
	  from endedmae
	 where periodo     >= _periodo_ini
	   and periodo     <= _periodo_fin
	   and actualizado = 1
	   and cod_endomov = "014"
	 group by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	select vigencia_inic,
		   estatus_poliza
	  into _vigen_ini,
		   _estatus_poliza
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
	
	select pagada,
		   vigencia_inic,
		   fecha_pago
	  into _pagada,
		   _vi_ini,
		   _fecha_pago				   
	  from emiletra
	 where no_poliza     = _no_poliza
	   and vigencia_inic = _vigencia_aniv_nva;
	   
	if _pagada is null then
		let _pagada = 0;
	end if	
		   
	if _pagada = 0 then        -- tomar en cuenta solo las del primer pago
		insert into tmp_persis(tipo,no_documento, no_pol_renov, no_pol_renov_per,cambio_plan,vigencia_aniv,fecha_pago,pagada,vigencia_inic,vigencia_act,
								periodo_reno,periodo_ini,periodo_fin,vigencia_ant)
		values (2,_no_documento, 0, 0,0,_vigencia_aniv_nva,_fecha_pago,_pagada,_vigen_ini,_vigencia_act,_periodo_reno,_periodo_ini,_periodo_fin,_vigencia_ant);
		continue foreach;
	end if

	insert into tmp_persis(tipo,no_documento, no_pol_renov, no_pol_renov_per,cambio_plan,vigencia_aniv,fecha_pago,pagada,vigencia_inic,vigencia_act,
						   periodo_reno,periodo_ini,periodo_fin,vigencia_ant)
	values (0,_no_documento, 1, 1,0,_vigencia_aniv_nva,_fecha_pago,_pagada,_vigen_ini,_vigencia_act,_periodo_reno,_periodo_ini,_periodo_fin,_vigencia_ant);

end foreach
return 0, 'Proceso Finalizado';
end procedure