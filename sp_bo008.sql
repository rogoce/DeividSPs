-- Cobros por Seccion para Subir a BO
-- 
-- Creado    : 19/06/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/06/2004 - Autor: Demetrio Hurtado Almanza
--

drop procedure sp_bo008;

create procedure "informix".sp_bo008()
returning char(1),
          char(100);
							  
define _no_documento	char(20);		  
define _no_poliza		char(10);
define _periodo			char(7);

define _cobros_neto     dec(16,2);
define _por_vencer_neto dec(16,2);
define _exigible_neto   dec(16,2);
define _corriente_neto  dec(16,2);
define _monto_30_neto   dec(16,2);
define _monto_60_neto   dec(16,2);
define _monto_90_neto   dec(16,2);

define _cod_tipoprod	char(3);
define _porc_impuesto	dec(16,2);
define _porc_coaseguro	dec(16,4);
define _cod_coasegur    char(3);

set isolation to dirty read;

select par_ase_lider
  into _cod_coasegur
  from parparam;

foreach
 select no_poliza,
		cobros_total,
		cobros_por_vencer,
		cobros_exigible,
		cobros_corriente,
		cobros_30,
		cobros_60,
		cobros_90,
		no_documento,
		periodo
   into _no_poliza,
		_cobros_neto,    
		_por_vencer_neto,
		_exigible_neto,  
		_corriente_neto, 
		_monto_30_neto,  
		_monto_60_neto,  
		_monto_90_neto,  
		_no_documento,
		_periodo
   from cobmoros
--  where no_documento = "1802-00013-01"

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

	let _cobros_neto     = _cobros_neto      / (1 + (_porc_impuesto / 100));
	let _por_vencer_neto = _por_vencer_neto  / (1 + (_porc_impuesto / 100));
	let _exigible_neto   = _exigible_neto    / (1 + (_porc_impuesto / 100));
	let _corriente_neto  = _corriente_neto   / (1 + (_porc_impuesto / 100));
	let _monto_30_neto   = _monto_30_neto    / (1 + (_porc_impuesto / 100));
	let _monto_60_neto   = _monto_60_neto    / (1 + (_porc_impuesto / 100));
	let _monto_90_neto   = _monto_90_neto    / (1 + (_porc_impuesto / 100));

	if _cod_tipoprod = "001" then

		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;
		end if

		let _cobros_neto     = _cobros_neto     * (_porc_coaseguro / 100);
		let _por_vencer_neto = _por_vencer_neto * (_porc_coaseguro / 100);
		let _exigible_neto   = _exigible_neto   * (_porc_coaseguro / 100);
		let _corriente_neto  = _corriente_neto  * (_porc_coaseguro / 100);
		let _monto_30_neto   = _monto_30_neto   * (_porc_coaseguro / 100);
		let _monto_60_neto   = _monto_60_neto   * (_porc_coaseguro / 100);
		let _monto_90_neto   = _monto_90_neto   * (_porc_coaseguro / 100);

	end if

	update cobmoros
	   set cobros_total_neto	  =	_cobros_neto,
		   cobros_por_vencer_neto =	_por_vencer_neto,
		   cobros_exigible_neto	  =	_exigible_neto,
		   cobros_corriente_neto  =	_corriente_neto,
		   cobros_30_neto		  =	_monto_30_neto,
		   cobros_60_neto		  =	_monto_60_neto,
		   cobros_90_neto		  =	_monto_90_neto
	 where no_documento           = _no_documento
	   and periodo     			  = _periodo;

end foreach

return 0, "Actualizacion Exitosa";

end procedure