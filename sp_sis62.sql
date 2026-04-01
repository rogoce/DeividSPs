drop procedure sp_sis62;

create procedure "informix".sp_sis62()
returning integer,
		  char(50);

define _fecha		date;
define _documento	char(30);
define _monto		dec(16,2);
define _descripcion	char(50);
define _error		integer;

begin work;

begin
on exception set _error
	rollback work;
	return _error, "Error al Actualizar " || _documento;
end exception

foreach
 select fecha,
        documento,
		monto,
		descripcion
   into _fecha,
        _documento,
		_monto,
		_descripcion
   from tmp_aplicar
--  where documento = "173442"

	insert into cobsuspe(
	doc_suspenso,
	cod_compania,
	cod_sucursal,
	monto,
	fecha,
	coaseguro,
	asegurado,
	poliza,
	ramo,
	actualizado,
	user_added,
	date_added
	)
	values(
	_documento,
	"001",
	"001",
	_monto,
	_fecha,
	"",
	_descripcion,
	"",
	"",
	1,
	"demetrio",
	today
	);

end foreach

end

--rollback work;
commit work;
return 0, "Actualizacion Exitosa";
end procedure