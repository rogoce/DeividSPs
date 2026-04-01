-- procedure que arreglas los motivos de cancelacion por endosos que esta mal

drop procedure sp_pro160;

create procedure "informix".sp_pro160()
returning integer,
          char(50);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_tipocan		char(3);
define _fecha			date;
define _user			char(8);
define _cod_no_renov	char(3);

define _contador 		integer;

set isolation to dirty read;

let _contador = 0;

foreach
 select no_poliza
   into _no_poliza
   from emipomae
  where estatus_poliza = 2
    and cod_no_renov   is null
	and renovada       = 0
--	and no_documento   = "0100-00001-99"
	
	let _contador  = _contador + 1;
	let _no_endoso = null;

	 select max(no_endoso)
	   into _no_endoso
	   from endedmae
	  where no_poliza   = _no_poliza
	    and cod_endomov = "002"
	    and actualizado = 1;

	if _no_endoso is not null then
		
		select cod_tipocan,
		       fecha_emision,
			   user_added
		  into _cod_tipocan,
		       _fecha,
			   _user
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		SELECT cod_no_renov
		  INTO _cod_no_renov
		  FROM endtican
		 WHERE cod_tipocan = _cod_tipocan;

		UPDATE emipomae
		   SET cod_no_renov   = _cod_no_renov,
			   fecha_no_renov = _fecha,
			   user_no_renov  = _user,
			   no_renovar     = 1
		 WHERE no_poliza      = _no_poliza;
		
		DELETE FROM emirepol
		 WHERE no_poliza = _no_poliza;

	end if

	if _contador > 5000 then
		exit foreach;
	end if

end foreach

return _contador, " Registros procesados";

end procedure
