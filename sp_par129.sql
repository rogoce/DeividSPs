-- Procedimiento que genera las cancelaciones por lote de las incobrables
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par129;

create procedure "informix".sp_par129()
returning integer,
          char(50);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);

define _error			integer;
define _descripcion		char(50);
define _cantidad		integer;

--set debug file to "sp_par129.trc";
--trace on;

set isolation to dirty read;

begin work;

delete from cobinc04;

let _cantidad = 0;
 
foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado = 1
	and incobrable  = 1
--	and no_documento = "0200-02851-01"
  group by no_documento

	let _cantidad    = _cantidad + 1;
	let _no_poliza   = sp_sis21(_no_documento);
	let _prima_bruta = sp_cob174(_no_documento);

	if _prima_bruta = 0.00 then
		continue foreach;
	end if

--{
	call sp_par130(_no_poliza, "demetrio", _prima_bruta) returning _error, _descripcion;

	if _error <> 0 then

--		trace _no_documento || " " || _error || " " || _descripcion || " " || _prima_bruta; 
		rollback work;
		return _error, _descripcion; 

	end if
--}

	insert into cobinc04
	values (_no_documento, _prima_bruta, "000", 1);

	update emipomae
	   set incobrable   = 0
	 where no_documento = _no_documento;

end foreach

--rollback work;
commit work;

return 0, "Actualizacion Exitosa " || _cantidad || " Registros Procesados"; 

end procedure