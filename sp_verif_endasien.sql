-- Procedure que verifica la prima suscrita en endedmae vs la prima suscrita en endasien
-- Creado: 08/10/2012	- Autor: Roman Gordon


drop procedure sp_verif_endasien; 													   
create procedure sp_verif_endasien()
returning char(10),
          char(5),
          dec(16,2);

define v_filtros		char(100);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _tot_pri_sus		dec(16,2);
define _prima_suscrita	dec(16,2);
define _dif_prima		dec(16,2);
define _error			integer;

--set debug file to "sp_verif_endasien.trc";
--trace on;

begin


CALL sp_pro27(
'001',
'001',
'2012-09',
'2012-09',
'*',
'*',
'*',
'*',
'4;Ex',		--Reaseguro Asumido Excluido
'*'
) RETURNING v_filtros;

foreach
	select total_pri_sus,
		   no_poliza,
		   no_endoso
	  into _tot_pri_sus,
	  	   _no_poliza,
	  	   _no_endoso
	  from tmp_prod
	 where cod_ramo in ('001','003')

	select debito + credito
	  into _prima_suscrita
	  from endasien
	 where no_poliza	= _no_poliza
	   and no_endoso	= _no_endoso
	   and cuenta		= '411020101';

	let _prima_suscrita = abs(_prima_suscrita);
	let _tot_pri_susabs = abs(_tot_pri_sus);

	if _prima_suscrita <> _tot_pri_sus then
		let _dif_prima = _tot_pri_sus - _prima_suscrita;
		return _no_poliza,_no_endoso,_dif_prima with resume;
	end if
end foreach
end
end procedure 