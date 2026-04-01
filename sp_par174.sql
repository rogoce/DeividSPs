-- Conversion de la tabla de CAJS

--drop procedure sp_par174;

create procedure "informix".sp_par174()
returning integer,
          char(50);

define _numero			integer;
define _nombre			char(50);
define _apellido		char(50);
define _nombre_razon	char(100);
define _cedula			char(30);
define _fecha_nac		date;
define _codigo			char(10);

define _ced_prov		char(2);
define _ced_av			char(2);
define _ced_tomo		char(4);
define _ced_folio		char(5);

define _error_int		integer;
define _error_desc		char(50);
define _contador		integer;

--set debug file to "sp_par174.trc";
--trace on;

begin work;

begin
on exception set _error_int
	rollback work;
	return _error_int, _error_desc;
end exception

let _error_desc = "Lectura de la Tabla Cajs";

let _contador = 0;

foreach
 select numero,
       	fecha_deivid,
       	cedula_deivid,
		nombre_deivid,
		nombre,
		apellido,
		ced_prov,
		ced_av,
		ced_tomo,
		ced_asiento
  into _numero,
        _fecha_nac,
        _cedula,
		_nombre_razon,
		_nombre,
		_apellido,
		_ced_prov,
		_ced_av,
		_ced_tomo,
		_ced_folio
   from cajs
  where codigo_deivid is null
  order by numero

	let _contador = _contador + 1;

	let _error_int  = 0;
	let _error_desc = "Procesando Cliente " || _cedula;

	let _codigo = null;

   foreach
	select cod_cliente
	  into _codigo
	  from clicajs
	 where cedula = _cedula
		exit foreach;
	end foreach

	if _codigo is null then

		call sp_par176(_nombre, _apellido, _nombre_razon, _cedula, _fecha_nac, _ced_prov, _ced_av, _ced_tomo, _ced_folio)
		     returning _error_int, _error_desc, _codigo;

	end if

	if _error_int = 0 then

		update cajs									      
		   set codigo_deivid = _codigo
		 where numero        = _numero;
	
	else
			
		rollback work;
		return _error_int, _error_desc;

	end if

	if _contador > 1000 then
		exit foreach;
	end if

end foreach          		

end

commit work;
--rollback work;

return 0, "Actualizacion Exitosa";

end procedure
