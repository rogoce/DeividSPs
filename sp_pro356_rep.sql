-- Procedimiento que muestra la ultima Distribucion de Reaseguro individual--

drop procedure sp_pro356_rep;
create procedure sp_pro356_rep(a_no_poliza char(10), a_no_unidad char(5))
returning 	decimal(16,2), decimal(16,2), decimal(16,2);

define _cod_cober_reas,_cod_ramo		char(3);
define _cod_contrato		char(5);
define _cod_ruta			char(5);
define _prima,_suma_retencion,_suma_contrato,_suma_facultativo 		decimal(16,2);
define _suma_asegurada,_suma_aseg_tot		decimal(16,2);
define _porc_partic_prima	decimal(10,4);
define _porc_partic_suma	decimal(10,4);
define _orden,_tipo,_no_cambio,_cantidad	smallint;
define _ajustar,_cambio		smallint;
define _cod_contrato_equi   char(5);

set isolation to dirty read;

let _cambio = 0;

select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;
   
select cod_ramo 
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;
 
 let _suma_aseg_tot = 0;
 
 select suma_asegurada
  into _suma_aseg_tot
  from emipouni
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;
 
 select count(*)
  into _cantidad
  from endedmae
 where no_poliza   = a_no_poliza
   and cod_endomov = '017';
   
if _cod_ramo = '019' and _cantidad > 0 then
	let _cambio = 1;
end if

let _suma_retencion   = 0;
let _suma_contrato    = 0;
let _suma_facultativo = 0;

if _cod_ramo <> '019' OR _cambio = 1 then
	foreach
		select cod_cober_reas,
			   orden,
			   porc_partic_suma,
			   porc_partic_prima,
			   cod_contrato
		  into _cod_cober_reas,
			   _orden,
			   _porc_partic_suma,
			   _porc_partic_prima,
			   _cod_contrato
		  from emireaco
		 where no_poliza = a_no_poliza
		   and no_unidad = a_no_unidad
		   and no_cambio = _no_cambio

		select sum(a.suma_asegurada),
			   sum(a.prima),
			   max(a.cod_ruta)
		  into _suma_asegurada,
			   _prima,
			   _cod_ruta
		  from emifacon a, endedmae	b
		 where a.no_poliza      = b.no_poliza
		   and a.no_endoso      = b.no_endoso
		   and a.no_endoso      = "00000"
		   and b.actualizado    = 1
		   and a.no_poliza		= a_no_poliza
		   and a.no_unidad		= a_no_unidad
		   and a.cod_cober_reas	= _cod_cober_reas
		   and a.cod_contrato	= _cod_contrato;
		   		
		if _prima is null And _suma_asegurada is null And _cod_ruta is null then	--AMM 23/05/2025
			continue foreach;
		end if
		   
		if _prima is null and _cod_contrato <> '00649' then 
			select cod_contrato_old
			  into _cod_contrato_equi
			  from camreaco
			 where cod_contrato_new = _cod_contrato;

			select sum(a.suma_asegurada),
				   sum(a.prima),
				   max(a.cod_ruta)
			  into _suma_asegurada,
				   _prima,
				   _cod_ruta
			  from emifacon a, endedmae	b
			 where a.no_poliza      = b.no_poliza
			   and a.no_endoso      = b.no_endoso
			   and b.actualizado    = 1
			   and a.no_poliza		= a_no_poliza
			   and a.no_unidad		= a_no_unidad
			   and a.cod_cober_reas	= _cod_cober_reas
			   and a.cod_contrato	= _cod_contrato_equi;	
		end if	

		if _prima is null and _cod_contrato = '00649' then
			select sum(a.suma_asegurada),
				   sum(a.prima),
				   max(a.cod_ruta)
			  into _suma_asegurada,
				   _prima,
				   _cod_ruta
			  from emifacon a, endedmae	b
			 where a.no_poliza      = b.no_poliza
			   and a.no_endoso      = b.no_endoso
			   and b.actualizado    = 1
			   and a.no_poliza		= a_no_poliza
			   and a.no_unidad		= a_no_unidad
			   and a.cod_cober_reas	= _cod_cober_reas;
		end if
		
		select tipo_contrato
		  into _tipo
		  from reacomae
		 where cod_contrato = _cod_contrato;
		
		if _tipo = 1 then	--Retencion
			let _suma_retencion = _suma_retencion + _suma_asegurada;
		elif _tipo = 3 then --facultativo
			let _suma_facultativo = _suma_facultativo + _suma_asegurada;
		else
			let _suma_contrato = _suma_contrato + _suma_asegurada;
		end if
		if _suma_aseg_tot = _suma_retencion + _suma_facultativo + _suma_contrato then
			exit foreach;
		end if
	end foreach
	return _suma_retencion,_suma_contrato,_suma_facultativo;
else
	foreach
		select orden,
			   cod_contrato,
		       cod_cober_reas,
		       sum(porc_partic_suma),
		       sum(porc_partic_prima)
		  into _orden,
		       _cod_contrato,
               _cod_cober_reas,
               _porc_partic_suma,
			   _porc_partic_prima
		from emifacon a, endedmae	b
		where a.no_poliza    = b.no_poliza
		and a.no_endoso      = b.no_endoso
		and b.actualizado    = 1
		and a.no_poliza		 = a_no_poliza
		and b.no_endoso      = '00000'
		and a.no_unidad		 = a_no_unidad
		group by cod_contrato,cod_cober_reas,orden
		order by orden

		select sum(a.suma_asegurada),
			   sum(a.prima),
			   max(a.cod_ruta)
		  into _suma_asegurada,
			   _prima,
			   _cod_ruta
		  from emifacon a, endedmae	b
		 where a.no_poliza      = b.no_poliza
		   and a.no_endoso      = b.no_endoso
		   and b.actualizado    = 1
		   and a.no_poliza		= a_no_poliza
		   and a.no_unidad		= a_no_unidad
		   and a.cod_cober_reas	= _cod_cober_reas
		   and a.cod_contrato	= _cod_contrato;
		   
		select tipo_contrato
		  into _tipo
		  from reacomae
		 where cod_contrato = _cod_contrato;
		
		if _tipo = 1 then	--Retencion
			let _suma_retencion = _suma_retencion + _suma_asegurada;
		elif _tipo = 3 then --facultativo
			let _suma_facultativo = _suma_facultativo + _suma_asegurada;
		else
			let _suma_contrato = _suma_contrato + _suma_asegurada;
		end if
		if _suma_aseg_tot = _suma_retencion + _suma_facultativo + _suma_contrato then
			exit foreach;
		end if
	end foreach
	return _suma_retencion,_suma_contrato,_suma_facultativo;
end if
end procedure;