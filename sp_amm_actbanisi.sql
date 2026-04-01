-- Proceso que verifica si hay diferencia del impuesto entre endedmae y endeduni
-- Creado    : 08/08/2012 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_amm_actbanisi;
create procedure sp_amm_actbanisi()
returning char(20);

define _error		    integer;
define _no_documento,_error_desc    char(20);
define _no_poliza      char(10);

--set debug file to "sp_pro365.trc";
--trace on;

foreach

	select no_documento
	  into _no_documento
	  from deivid_tmp:act_unity_banisi
	  
    let _no_poliza = sp_sis21(_no_documento);
	  
	CALL sp_pro867(_no_poliza,'R') returning _error, _error_desc; --Insertar en parmailsend para la carta de bienvenida - pol. Ren tala banisi especial
	
	return _no_documento with resume;
end foreach

end procedure