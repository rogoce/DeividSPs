-- Morosidad a una Fecha para pasar a Business Object

-- Creado    : 23/01/2004 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_cob139;

create procedure sp_cob139(a_periodo char(7))

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

--set debug file to "sp_cob134.trc";
--trace on;

set isolation to dirty read;

select par_ase_lider
  into _cod_coasegur
  from parparam;

let _fecha    = sp_sis36(a_periodo);
let _cantidad = 0;

foreach
 select no_poliza,
        no_documento,
		saldo,
		por_vencer,
		exigible,
		corriente,
		dias_30,
		dias_60,
		dias_90
   into	_no_poliza,
        _no_documento,
		_saldo,
		_por_vencer,
		_exigible,
		_corriente,
		_monto_30,
		_monto_60,
		_monto_90
   from cobmoros

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then

		let _saldo           = 0.00;
		let _por_vencer      = 0.00;
		let _exigible        = 0.00;
		let _corriente       = 0.00;
		let _monto_30        = 0.00;
		let _monto_60        = 0.00;
		let _monto_90        = 0.00;

		let _saldo_neto      = 0.00;
		let _por_vencer_neto = 0.00;
		let _exigible_neto   = 0.00;
		let _corriente_neto  = 0.00;
		let _monto_30_neto   = 0.00;
		let _monto_60_neto   = 0.00;
		let _monto_90_neto   = 0.00;

	else

		select sum(i.factor_impuesto)
		  into _porc_impuesto
		  from emipolim p, prdimpue i
		 where p.cod_impuesto = i.cod_impuesto
		   and p.no_poliza    = _no_poliza;  

		if _porc_impuesto is null then
			let _porc_impuesto = 0.00;
		end if

		let _saldo_neto      = _saldo      / (1 + (_porc_impuesto / 100));
		let _por_vencer_neto = _por_vencer / (1 + (_porc_impuesto / 100));
		let _exigible_neto   = _exigible   / (1 + (_porc_impuesto / 100));
		let _corriente_neto  = _corriente  / (1 + (_porc_impuesto / 100));
		let _monto_30_neto   = _monto_30   / (1 + (_porc_impuesto / 100));
		let _monto_60_neto   = _monto_60   / (1 + (_porc_impuesto / 100));
		let _monto_90_neto   = _monto_90   / (1 + (_porc_impuesto / 100));

		if _cod_tipoprod = "001" then

			select porc_partic_coas
			  into _porc_coaseguro
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = _cod_coasegur;

			if _porc_coaseguro is null then
				let _porc_coaseguro = 0.00;
			end if

			let _saldo_neto      = _saldo_neto      * (_porc_coaseguro / 100);
			let _por_vencer_neto = _por_vencer_neto * (_porc_coaseguro / 100);
			let _exigible_neto   = _exigible_neto   * (_porc_coaseguro / 100);
			let _corriente_neto  = _corriente_neto  * (_porc_coaseguro / 100);
			let _monto_30_neto   = _monto_30_neto   * (_porc_coaseguro / 100);
			let _monto_60_neto   = _monto_60_neto   * (_porc_coaseguro / 100);
			let _monto_90_neto   = _monto_90_neto   * (_porc_coaseguro / 100);

		end if

	end if

	let _mayor_30      = _monto_30 + _monto_60 + _monto_90;
	let _mayor_60      = _monto_60 + _monto_90;
	let _mayor_30_neto = _monto_30_neto + _monto_60_neto + _monto_90_neto;
	let _mayor_60_neto = _monto_60_neto + _monto_90_neto;

	update cobmoros
	   set saldo_neto      = _saldo_neto,
	       por_vencer_neto = _por_vencer_neto,
	       exigible_neto   = _exigible_neto,
	       corriente_neto  = _corriente_neto,
	       dias_30_neto    = _monto_30_neto,
	       dias_60_neto    = _monto_60_neto,
	       dias_90_neto    = _monto_90_neto,
	       mayor_30        = _mayor_30,
	       mayor_60        = _mayor_60,
	       mayor_30_neto   = _mayor_30_neto,
	       mayor_60_neto   = _mayor_60_neto,
	       saldo           = _saldo,
	       por_vencer      = _por_vencer,
	       exigible        = _exigible,
	       corriente       = _corriente,
	       dias_30         = _monto_30,
	       dias_60         = _monto_60,
	       dias_90         = _monto_90
     where no_documento    = _no_documento;

end foreach

end procedure
