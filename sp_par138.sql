drop procedure sp_par138;

create procedure sp_par138()
returning smallint,
		  char(50);
		  	
define _no_poliza	char(10);
define _no_endoso	char(5);
define _cantidad	smallint;

let _cantidad = 0;

foreach 
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where actualizado = 1
    and cod_tipocan = "013"

	let _cantidad = _cantidad + 1;

--{
	delete from endedhis
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	CALL sp_pro100(_no_poliza, _no_endoso); -- Historico de endedmae (endedhis)
--}
	
end foreach

return _cantidad, " Registros Procesados con Exito";

end procedure