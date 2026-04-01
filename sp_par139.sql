drop procedure sp_par139;

create procedure sp_par139()
returning integer,
          char(50);

define _periodo		char(7);
define _no_remesa	char(10);
define _cantidad	integer;
define _cantidad_bo	integer;
define _cantidad_er	integer;
define _tipo_remesa char(1);

define _cant_aut	smallint;
define _mes_aut		char(100);
define _error		integer;
define _descripcion	char(50);

set isolation to dirty read;

begin
on exception set _error
	return _error, _descripcion;
end exception

select cob_periodo
  into _periodo
  from parparam
 where cod_compania = "001";

let _cantidad    = 0;
let _cantidad_bo = 0;
let _cantidad_er = 0;

foreach
 select no_remesa,
        tipo_remesa
   into _no_remesa,
        _tipo_remesa
   from cobremae
  where actualizado = 0
	and periodo     < _periodo
	and no_remesa   <> '692473'

	let _descripcion = "Procesando Remesa " || _no_remesa;
	let _cantidad    = _cantidad + 1;

{
	if _tipo_remesa = "A" then
		
		call sp_cob127(_no_remesa) returning _cant_aut, _mes_aut;

		if _cantidad = 0 then

			let _cantidad_bo = _cantidad_bo + 1;

		else

			let _cantidad_er = _cantidad_er + 1;

		end if

	else
}
		let _descripcion = "Borrando Cobreagt " || _no_remesa;
		delete from cobreagt where no_remesa = _no_remesa;

		let _descripcion = "Borrando Cobredet " || _no_remesa;
		delete from cobredet where no_remesa = _no_remesa;

		let _descripcion = "Borrando Cobremae " || _no_remesa;
		delete from cobremae where no_remesa = _no_remesa;

		let _cantidad_bo = _cantidad_bo + 1;

--	end if

end foreach

end

return 0, " Procesadas " || _cantidad || " Borradas " || _cantidad_bo || " No Borradas " || _cantidad_er;

end procedure 