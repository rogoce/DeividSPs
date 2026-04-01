-- Porcedure que Determina las polizas desactualizadas hechas denuevo
--Tambien verifica que toda emisión tenga su endoso cero. AMM. 07/11/2024
drop procedure sp_pro177;
create procedure sp_pro177()
returning char(20),
          char(10),
		  smallint,
		  char(10);

define _no_documento	char(20);
define _serie			smallint;
define _serie2			smallint;
define _no_factura		char(10);
define _actualizado		smallint;
define _user_added		char(10);
define _no_poliza,_error_desc		char(10);
define _exito,_cnt			smallint;
define _error           integer;

set isolation to dirty read;

foreach 
	select no_documento,
		   serie,
		   no_factura,
		   no_poliza
	  into _no_documento,
		   _serie,
		   _no_factura,
		   _no_poliza
	  from emipomae
	 where no_factura  is not null
	   and actualizado = 0
     
	foreach
		select serie,
			   actualizado,
			   user_added
		  into _serie2,
			   _actualizado,
			   _user_added
		  from emipomae
		 where no_documento = _no_documento
		   and no_factura   <> _no_factura
		   and actualizado  = 1

		if _serie = _serie2 and _actualizado = 1 then

			{delete from emifacon
			 where no_poliza = _no_poliza
			   and no_endoso = "00000";

			let _exito = sp_sis61(_no_poliza, "00000");}
			
			--call sp_sis61b(_no_poliza) returning _error, _error_desc; --PONER EN COMENTARIO CUANDO SE ELEMINEN LOS REGISTROS.
			
			return _no_documento,_no_factura,_serie,_user_added with resume;
		end if
	end foreach
end foreach
--*******verifica que toda emisión tenga su endoso cero. AMM. 07/11/2024
foreach 
	select no_documento,
		   serie,
		   no_factura,
		   no_poliza
	  into _no_documento,
		   _serie,
		   _no_factura,
		   _no_poliza
	  from emipomae
	 where actualizado = 1
	   and periodo >= '2024-01'
	   
	select count(*)
	  into _cnt
	  from endedmae
	 where actualizado = 1
	   and no_poliza = _no_poliza
       and no_endoso = '00000';
	   
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt = 0 then
		return _no_documento,_no_poliza,_serie,'SinEndCero' with resume;
	end if
end foreach
return "0","",0,"" with resume;
end procedure 