-- (Proceso diario) para buscar las requisiciones de firma electronica
-- Para poder agregar mas transacciones de reclamos a una misma 

-- Modificado: 14/06/2006 - Autor: Armando Moreno Montenegro

drop procedure sp_trx_anulacion;
create procedure sp_trx_anulacion()
 returning  char(10),	--no_requis
			smallint;

define _no_requis			char(10);
define _no_reclamo			char(10);
define _transaccion			char(10);
define _cod_ramo			char(3);
define _flag				smallint;
define _cod_banco			char(3);
define _cod_chequera		char(3);
define _mon					dec(16,2);

SET ISOLATION TO DIRTY READ;

let _mon = 0;

foreach
	select transaccion
	  into _transaccion
	  from deivid_tmp:carga_anula_trx

	call sp_rec76c(_transaccion) returning _no_requis,_flag;
	
	return _no_requis,_flag with resume;
end foreach


return "",0;
end procedure
