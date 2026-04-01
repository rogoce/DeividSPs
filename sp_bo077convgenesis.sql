-- Procedimiento que genera la informacion de las polizas nuevas para la convencion Madrid-Marruecos 2019
-- en un rango de fechas

--drop procedure sp_bo077convgenesis;
create procedure "informix".sp_bo077convgenesis(a_fecha_ini date, a_fecha_fin date)
returning integer, char(50);

define _no_poliza		char(10);
define _no_documento	char(20);
define _nueva_renov		char(1);
define _cod_ramo		char(3);
define _cod_perpago     char(3);
define _estatus_poliza	integer;
define _no_poliza_per,_error	integer;

define _vigencia_inic	date;
define _vigencia_final	date;
define _periodo_ini		char(7);
define _periodo_fin		char(7);
define _meses           smallint;
define _valor,_pagada   smallint;
define _prima_suscrita  dec(16,2);
define _reemplaza_pol   char(20);
define _cnt_cam         smallint;
define _error_desc      char(50);


--set debug file to "sp_bo077conv.trc";
--trace on;

--drop table tmp_persis;

create temp table tmp_persis(
no_documento		char(20),
no_pol_nueva		integer		default 0,
no_pol_nueva_per	integer		default 0,
prima_suscrita		dec(16,2) 	default 0
) with no log;

set isolation to dirty read;

let _periodo_ini = sp_sis39(a_fecha_ini);
let _periodo_fin = sp_sis39(a_fecha_fin);
let _cnt_cam     = 0;
let _reemplaza_pol = "";

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
	 
	select nueva_renov,
	       no_documento,
		   vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   estatus_poliza,
		   prima_suscrita,
		   cod_perpago,
		   reemplaza_poliza
	  into _nueva_renov,
	       _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza,
		   _prima_suscrita,
		   _cod_perpago,
		   _reemplaza_pol
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	let _reemplaza_pol = TRIM(_reemplaza_pol);
	if _estatus_poliza = 2 then  --No debe estar cancelada
		continue foreach;
	end if
	
	select pagada
	  into _pagada
	  from emiletra
	 where no_poliza = _no_poliza
	   and no_letra = 1;
		   
	if _pagada = 0 then        -- tomar en cuenta la primera letra de pago
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
	
	let _no_poliza_per = 1;

	if _cod_ramo <> "018" then

		if (_vigencia_final - _vigencia_inic) < 365 then
			let _no_poliza_per = 0;
		end if

	end if
	if _nueva_renov = "N" then
		if _cod_ramo <> '018' then
			select sum(a.prima_suscrita)
			  into _prima_suscrita
			  from endedmae a, emipomae p
			 where a.no_poliza = p.no_poliza
			   and a.no_poliza = _no_poliza
			   and a.actualizado  = 1
			   and a.periodo between _periodo_ini and _periodo_fin;
		else
			IF _reemplaza_pol <> "" or _reemplaza_pol is not null then
				let _cnt_cam = 0;
				let _cnt_cam = sp_bo077b(_reemplaza_pol);	--Busca si tiene cambio de plan.
				if _cnt_cam is null then
					let _cnt_cam = 0;
				end if
				if _cnt_cam > 0 then
					continue foreach;
				end if
			end if
			--Para salud, debe ser la prima anualizada
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
		if _prima_suscrita >= 150 then
			insert into tmp_persis(no_documento, no_pol_nueva, no_pol_nueva_per,prima_suscrita)
			values (_no_documento, 1, _no_poliza_per,_prima_suscrita);
		end if
	end if
end foreach
return 0, "Actualizacion Exitosa";
end procedure