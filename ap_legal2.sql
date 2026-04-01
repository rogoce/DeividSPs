-- Procedimiento para la aplicacion de la nueva ley	de seguros

-- Creado    : 04/01/2013 - Autor: Amado Perez
drop procedure ap_legal2;

create procedure ap_legal2()
returning smallint,
          char(250);

define _error					int;
define _error_isam				int;
define _prima_bruta         	dec(16,2);
define _no_documento			char(20);
define _no_factura				char(10);
define _error_desc				varchar(200);
define _periodo                 char(7);
define _fecha       			date;
define _cod_compania, _cod_sucursal	char(3);
define v_saldo                  dec(16,2);
define _user_added 				char(8);
define _no_endoso               char(5);
define _cod_endomov				char(3);
define _cod_tipocalc			char(3);
define _tipo_mov                smallint;
define _no_poliza               char(10);
define _cod_abogado             char(3);
define _cod_formapag        	char(3);


set debug file to "ap_legal2.trc";
trace on;

begin work;

set isolation to dirty read;


begin 
on exception set _error, _error_isam, _error_desc
    rollback work;
	return _error, _error_desc;
end exception

let _fecha = current;

FOREACH	with hold
	select no_poliza,
		   no_endoso,
		   no_documento
	  into _no_poliza,
		   _no_endoso,
		   _no_documento
	  from tmpcoboutle2
	 where procesado = 0

	CALL sp_pro517(_no_poliza, _no_endoso) returning _error, _error_desc; --Nueva ley de seguro

	if _error <> 0 then
	    rollback work;
		return _error, _no_documento || " " || trim(_error_desc);
	else
	   update tmpcoboutle2
	      set procesado = 1
		where no_poliza = _no_poliza;
	end if 


END FOREACH

end

commit work;

return 0,'aplicacion de nueva ley exitoso';

end procedure


