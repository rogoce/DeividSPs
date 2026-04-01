-- Procedimiento que carga la tabla de prima no devengada
-- Creado    : 29/07/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro398;

create procedure sp_pro398(a_no_poliza char(10), a_no_endoso char(5))
returning integer,
	      char(100);

define _error_desc		char(100);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _prima_suscrita	dec(16,2);
define _prima_no_dev	dec(16,2);
define _prima_dif		dec(16,2);
define _ajuste			dec(16,2);
define _existe			smallint;
define _dias			smallint;
define _error_isam		integer;
define _error			integer;
define _vigencia_inic 	date;
define _vigencia_final 	date;
define _fecha			date;

set isolation to dirty read;

--set debug file to "sp_pro398.trc";
--trace on;

begin

on exception set _error,_error_isam,_error_desc
  return _error,_error_desc;
end exception

let _prima_suscrita	= 0.00;
let _prima_no_dev	= 0.00;
let _prima_dif		= 0.00;

select prima_suscrita,
	   vigencia_inic,
	   vigencia_final
  into _prima_suscrita,
	   _vigencia_inic,
	   _vigencia_final
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _prima_suscrita = 0 then
	return 0,'Inserción Exitosa';
end if


select sum(prima_no_devengada)
  into _prima_no_dev
  from prdprinode
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso; 

if _prima_no_dev is null then
	let _prima_no_dev = 0.00;
end if
 
if _prima_suscrita = _prima_no_dev then
	return 0,'Inserción Exitosa';
end if

delete from prdprinode
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

let _dias = (_vigencia_final - _vigencia_inic);

if _dias = 0 then

	insert into prdprinode(
			no_poliza,
			no_endoso,
			fecha,
			prima_no_devengada,
			sac_asientos)
	values	(_no_poliza,
			_no_endoso,
			_vigencia_final,
			_prima_suscrita,
			0);

	let _prima_dif = _prima_suscrita;

else

	let _prima_no_dev = _prima_suscrita / _dias;
	let _fecha        = _vigencia_inic;

	while _fecha < _vigencia_final	

		insert into prdprinode(
				no_poliza,
				no_endoso,
				fecha,
				prima_no_devengada,
				sac_asientos)
		values	(a_no_poliza,
				a_no_endoso,
				_fecha,
				_prima_no_dev,
				0);

		let _prima_dif = _prima_dif + _prima_no_dev;
		let _fecha     = _fecha + 1 units day;

	end while

end if

if _prima_dif <> _prima_suscrita then

	if _prima_dif > _prima_suscrita then
		let _ajuste = -0.01;
	else
		let _ajuste = 0.01;
	end if
	
	foreach
		select no_poliza,
			   no_endoso,
			   fecha
		  into _no_poliza,
			   _no_endoso,
			   _fecha
		  from prdprinode
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		 order by fecha desc
		
		update prdprinode
		   set prima_no_devengada = prima_no_devengada + _ajuste
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and fecha	 = _fecha;

		let _prima_dif = _prima_dif + _ajuste;

		if _prima_dif = _prima_suscrita then
			exit foreach;
		end if
	end foreach
end if

-- Luego de Calculada la prima de cada dia se procede a calcular el resto de los valores
-- Comision Corredor
-- Impuesto
-- Reseguro Cedido
-- Impuesto Reaseguro
-- Comision Reaseguro

foreach
	select prima_no_devengada,
		   fecha
	  into _prima_no_dev,
		   _fecha
	  from prdprinode
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso	
end foreach

return 0,'Inserción Exitosa';

end

end procedure