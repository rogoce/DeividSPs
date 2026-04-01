-- Procedimiento que carga la tabla de prima no devengada
-- Creado    : 29/07/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro398b;

create procedure sp_pro398b()
returning integer,
	      char(100);

define _error_desc		char(100);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _prima_suscrita	dec(16,2);
define _prima_no_dev	dec(16,2);
define _prima_dif		dec(16,2);
define _ajuste			dec(16,2);
define _cnt_reg			smallint;
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
  rollback work;	
  return _error,_error_desc;
end exception

let _prima_suscrita	= 0.00;
let _prima_no_dev	= 0.00;
let _prima_dif		= 0.00;

foreach	with hold
	select no_poliza,
		   no_endoso,
		   sum(prima_no_devengada),
		   count(*)
	  into _no_poliza,
		   _no_endoso,
		   _prima_dif,
		   _cnt_reg
	  from prdprinode
	 group by no_poliza,no_endoso
	begin work;

	select vigencia_inic,
		   vigencia_final,
		   prima_suscrita
	  into _vigencia_inic,
		   _vigencia_final,
		   _prima_suscrita
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	   
	let _dias = (_vigencia_final - _vigencia_inic);
	
	if _dias = 0 then
		let _dias = 1;
	end if
	
	let _fecha = _vigencia_inic;

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
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
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
	
	let _prima_no_dev = 0.00;
	let _prima_dif = 0.00;

	commit work;

end foreach

return 0,'Inserción Exitosa';
end
end procedure