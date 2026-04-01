-- Validacion para los Movimientos de Afectacion al Catalogo de las Remesas de Cobros

-- Creado    : 15/03/2013 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_cob324;

create procedure "informix".sp_cob324(a_no_remesa char(10))
returning integer, 
          char(100);

define _doc_remesa  	char(30);
define _cod_auxiliar    char(5);
define _cta_auxiliar	char(1);
define _renglon    		smallint; 
define _monto			dec(16,2);
define _fecha			date;
define _user_added		char(8);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select fecha,
       user_added
  into _fecha,
       _user_added
  from cobremae
 where no_remesa = a_no_remesa;

foreach	
 select doc_remesa,
        cod_auxiliar,
	    renglon,
		monto
   into _doc_remesa,
        _cod_auxiliar,
	    _renglon,
		_monto
   from cobredet
  where no_remesa = a_no_remesa
    and tipo_mov  = 'M'

	-- Validacion para las cuentas que no permiten movimientos

	call sp_sac226(_doc_remesa) returning _error, _error_desc;

	if _error <> 0 then

		call sp_sac228(_doc_remesa, _error_desc, "COB", a_no_remesa, _monto, _fecha, _user_added) returning _error, _error_desc;

	end if

	-- Validacion para los Auxiliares

	select cta_auxiliar
	  into _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = _doc_remesa;

	if _cta_auxiliar = "S"   and
	   _cod_auxiliar is null then
		return 1, "Falta Capturar el Codigo del Auxiliar del Renglon #: " || _renglon;
	end if

end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure

