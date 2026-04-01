-- Agregar el impuesto a cobmoros

-- Creado    : 05/07/2005 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par158;

create procedure "informix".sp_par158()
returning integer,
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _fecha			date;

define _por_vencer  	dec(16,2);
define _exigible    	dec(16,2);
define _corriente   	dec(16,2);
define _monto_30    	dec(16,2);
define _monto_60    	dec(16,2);
define _monto_90    	dec(16,2);
define _saldo       	dec(16,2);
define _impuesto       	dec(16,2);
define _impuesto_neto  	dec(16,2);

define _por_vencer_neto	dec(16,2);
define _exigible_neto   dec(16,2);
define _corriente_neto  dec(16,2);
define _monto_30_neto   dec(16,2);
define _monto_60_neto   dec(16,2);
define _monto_90_neto   dec(16,2);
define _saldo_neto      dec(16,2);

define _mayor_30        dec(16,2);
define _mayor_60        dec(16,2);
define _mayor_30_neto   dec(16,2);
define _mayor_60_neto   dec(16,2);

define _porc_impuesto	dec(16,2);
define _porc_coaseguro	dec(16,4);

define _cod_tipoprod    char(3);
define _cod_coasegur    char(3);

define _cantidad        integer;
define _error			integer;
define _periodo			char(7);

--set debug file to "sp_cob134.trc";
--trace on;

begin 
on exception set _error
	return _error, "Error de Base de Datos ...";
end exception

set isolation to dirty read;

select par_ase_lider
  into _cod_coasegur
  from parparam;

let _cantidad = 0;

foreach
 select no_documento,
        periodo,
		saldo,
		no_poliza
   into	_no_documento,
        _periodo,
		_saldo,
		_no_poliza
   from cobmoros

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	select sum(i.factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = _no_poliza;  

	if _porc_impuesto is null then
		let _porc_impuesto = 0.00;
	end if

	let _saldo_neto    = _saldo / (1 + (_porc_impuesto / 100));
	let _impuesto      = _saldo - _saldo_neto;
	let _impuesto_neto = _impuesto;
		
	if _cod_tipoprod = "001" then

		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;
		end if

		let _impuesto_neto = _impuesto_neto * (_porc_coaseguro / 100);

	end if

	update cobmoros
	   set saldos_impuesto      = _impuesto,
	       saldos_neto_impuesto = _impuesto_neto
	 where no_documento         = _no_documento
	   and periodo              = _periodo;

end foreach

return 0, "Actualizacion Exitosa";

end 

end procedure
