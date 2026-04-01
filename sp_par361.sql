-- Procedimiento que genera los registros contables para las remesas de reaseguro
-- 
-- Creado     : 29/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par361;		

create procedure sp_par361(a_no_remesa CHAR(10))
returning integer,
		  char(100);

define _cod_banco		char(3);
define _cod_origen_ban	char(3);
define _cod_origen_rea	char(3);
define _renglon			smallint;
define _tipo			char(2);

define _cuenta_banco	char(25);
define _cuenta			char(25);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _cod_coasegur	char(3);
define _cod_auxiliar	char(5);
define _periodo			char(7);
define _centro_costo	char(3);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _tipo_comp		smallint;
define _monto           dec(16,2);
define _dif             dec(16,2);
define _renglon_s       varchar(3);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

--SET DEBUG FILE TO "sp_par283.trc"; 
--trace on;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Validando los montos por renglon -- Amado 06-09-2017

let _dif = 0;

foreach
	select renglon,
	       debito,
	       credito
	  into _renglon,
	       _debito,
	       _credito
	  from reatrx2
	 where no_remesa = a_no_remesa
	 
	 if _debito is null then
		let _debito = 0.00;
	 end if
	 
	 if _credito is null then
		let _credito = 0.00;
	 end if
	 
	 select sum(monto)
	   into _monto
	   from reatrx3
	  where no_remesa = a_no_remesa
	    and renglon = _renglon;
		
	 if _monto is null then
		let _monto = 0.00;
	 end if
	
	if _monto < 0 then
		let _monto = _monto * (-1);
	end if	
		
    if _debito = 0 then	
		let _dif = _monto - _credito;	
	else
		let _dif = _monto - _debito;	
	end if
	
	if _dif <> 0.00 then
	    let _renglon_s = _renglon;
		exit foreach;
	end if
end foreach

if _dif <> 0.00 then
	return 2, "El monto del renglon " || trim(_renglon_s) || " no es igual al detalle, verifique";
end if

end

return 0, "Actualizacion Exitosa";

end procedure 
