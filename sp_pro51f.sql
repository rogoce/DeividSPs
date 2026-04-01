-- Procedimiento para calculo de tarifas y primas por cobertura
-- Creado    : 22/01/2009 - Autor: Ricardo Jim‚nez B.
-- SIS v.2.0 d_- DEIVID, S.A.

drop procedure sp_pro51f;

create procedure "informix".sp_pro51f(
a_poliza	char(10),
a_producto	char(5),
a_ramo		char(3),
a_unidad	char(5),
a_cobertura	char(5),
a_suma		dec(16,2),
a_limite_1  dec(16,2),
a_limite_2  dec(16,2))
returning dec(16,2);  -- tarifa por cobertura

define _no_motor          char(30);
define _valor_asignar     char(1);
define _tipo_valor        char(1);
define _busqueda 	      char(1);
define _ld_tarifa         dec(9,5);
define _ld_ded_min        dec(16,2);
define _ld_limite_1       dec(16,2);
define _ld_limite_2	      dec(16,2);
define _ld_suma           dec(16,2);
define _ldv_tar_unica     dec(16,2);
define _ld_valor          dec(16,2);
define _factor_division   smallint;
define _acepta_desc       smallint;
define _tipo_deduc        smallint;
define _ramo_sis          smallint;
define _capacidad         integer;
define _ld_anos,_renglon  integer;
define _cod_tipoveh       char(3);

set isolation to dirty read;

--if a_poliza = '1526607' and  a_cobertura = '00118' then
--set debug file to "sp_pro51t.trc"; 
--trace on; 
--end if                                                  

let _ld_suma		= a_suma;
let _ldv_tar_unica	= 0.00;
let _ld_limite_1	= 0.00;
let _ld_limite_2	= 0.00;
let _ld_ded_min		= 0.00;
let _ld_tarifa		= 0.00;
let _ld_valor		= null;
let _capacidad		= 0;
let _ramo_sis		= 1;
let _ld_anos		= 0;

if a_limite_1 is null then
	let a_limite_1 = 0.00;
end if
if a_limite_2 is null then
	let a_limite_2 = 0.00;
end if

if _ld_suma is null then
   let _ld_suma = 00.00;
end if

select d.valor_asignar,
	   d.tipo_valor,
	   d.factor_division,
	   d.busqueda,
	   d.deducible_min,
	   d.tipo_deducible,
       d.acepta_desc,
       d.valor_tar_unica
  into _valor_asignar,
	   _tipo_valor,
	   _factor_division,
	   _busqueda,
	   _ld_ded_min,
	   _tipo_deduc,
	   _acepta_desc,
	   _ldv_tar_unica
  from prdcobpd d, prdcober c
 where d.cod_cobertura = c.cod_cobertura
   and c.cod_ramo      = a_ramo
   and d.cod_producto  = a_producto
   and c.cod_cobertura = a_cobertura;

{select limite_1,
	   limite_2
  into _ld_limite_1,
	   _ld_limite_2
  from emipocob
 where no_poliza     = a_poliza
   and no_unidad     = a_unidad
   and cod_cobertura = a_cobertura;
}
if _busqueda = "1" then      --secuencial
	foreach
		select valor
		  into _ld_valor
		  from prdtasec
		 where cod_cobertura = a_cobertura
		   and cod_producto  = a_producto
		   and rango_monto1  = a_limite_1
		   and rango_monto2  = a_limite_2
		 order by renglon desc
		exit foreach;
	end foreach

	if _tipo_valor = "T" then--tarifa
	    if _ld_valor is null then
			let _ld_valor = 0;
		end if
		if _factor_division > 0 and _ld_suma <> 0 then
			let _ld_tarifa = (_ld_valor * _factor_division) / _ld_suma;
			let _ld_tarifa = _ld_tarifa /  _factor_division;
			let _ld_tarifa = _ld_tarifa *  _ld_suma;
		else
	        if _ld_suma = 0 then
			    let _ld_tarifa = (_ld_valor * _factor_division);
 			    let _ld_tarifa = _ld_tarifa /  _factor_division;
			else
				let _ld_tarifa = 00.00;
			end if
		end if
	elif _tipo_valor = "P" then

	    if _ld_valor is null then

			select prima_anual
			  into _ld_valor
			  from emipocob
			 where no_poliza     = a_poliza
			   and no_unidad     = a_unidad
			   and cod_cobertura = a_cobertura;

		end if
		let _ld_tarifa =  _ld_valor;
	end if
elif _busqueda = "2" then   --unica

	if _tipo_valor = "P" then --prima
		let _ld_tarifa = _ldv_tar_unica;
	elif _tipo_valor = "T" then --tarifa
		if _factor_division > 0 and _ld_suma <> 0 then
			let _ld_tarifa = _ldv_tar_unica / _factor_division;
			let _ld_tarifa = _ld_tarifa *  _ld_suma;
		else
			let _ld_tarifa = 00.00;
		end if
	end if
elif _busqueda = "5" then   --tipo de vehiculo
		select cod_tipoveh
		  into _cod_tipoveh
		  from emiauto 
		 where no_poliza = a_poliza
		   and no_unidad = a_unidad;
		let _renglon = 0;   
		let _renglon = _cod_tipoveh;
	foreach
		select valor
		  into _ld_tarifa
		  from prdtasec
		 where cod_cobertura = a_cobertura
		   and cod_producto  = a_producto
		   and renglon       = _renglon
		 order by renglon desc
		exit foreach;
	end foreach
	
elif _busqueda in ("3", "4", "6") then --llave ¢ rango

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = a_ramo;

	if _ramo_sis = 1 then
		select no_motor,
		       ano_tarifa
		  into _no_motor,
		       _ld_anos
		  from emiauto 
		 where no_poliza = a_poliza
		   and no_unidad = a_unidad;

 		let _ld_anos = _ld_anos + 1;
		   
		if _ld_anos = 0 then
			let _ld_anos = 1;
		end if		   

--		let _ld_anos = sp_sis61e(_no_motor, a_poliza);

		if _busqueda = '6' then
			select capacidad
			  into _capacidad
			  from emivehic
			 where no_motor = _no_motor;

			let _ld_anos = _capacidad;
		end if
	else
		let _ld_anos = 0;
	end if

	call sp_sis51c(_busqueda, a_producto, a_cobertura, _ld_anos, a_suma) returning _ld_valor;
	
	if  _tipo_valor = "P" then  --prima
		if _ld_valor > 0  then
			let _ld_tarifa = _ld_valor;
		end if
	elif _tipo_valor = "T" then --tarifa
		if _factor_division > 0 then
			if _ld_valor     > 0 then
				let _ld_tarifa = _ld_valor / _factor_division;
				let _ld_tarifa = _ld_tarifa * _ld_suma;
			end if
		end if
	end if
end if

return _ld_tarifa;
end procedure;