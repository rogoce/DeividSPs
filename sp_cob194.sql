-- Morosidad a una Fecha para pasar a Business Object

-- Creado    : 23/01/2004 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_cob194;

create procedure "informix".sp_cob194(
a_no_documento	char(20),
a_periodo 		char(7)
) returning integer,
            char(50);

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
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_cob134.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

set isolation to dirty read;

let _no_poliza = sp_sis21(a_no_documento);

if _no_poliza is null then
	return 1, "Poliza No Existe";
end if

delete from cobmoros
 where periodo      = a_periodo
   and no_documento = a_no_documento;

select par_ase_lider
  into _cod_coasegur
  from parparam;

let _fecha    = sp_sis36(a_periodo);
let _cantidad = 0;

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
	let _impuesto        = 0.00;

	let _saldo_neto      = 0.00;
	let _por_vencer_neto = 0.00;
	let _exigible_neto   = 0.00;
	let _corriente_neto  = 0.00;
	let _monto_30_neto   = 0.00;
	let _monto_60_neto   = 0.00;
	let _monto_90_neto   = 0.00;
	let _impuesto_neto   = 0.00;

else

	CALL sp_cob33(
		 "001",
		 "001",	
		 a_no_documento,
		 a_periodo,
		 _fecha
		 ) RETURNING _por_vencer,      
					 _exigible,         
					 _corriente,        
					 _monto_30,         
					 _monto_60,         
					 _monto_90,
					 _saldo;         


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
	let _impuesto        = _saldo - _saldo_neto;
	let _impuesto_neto	 = _impuesto;

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
		let _impuesto_neto   = _impuesto_neto   * (_porc_coaseguro / 100);

	end if

end if

let _mayor_30      = _monto_30      + _monto_60 + _monto_90;
let _mayor_60      = _monto_60      + _monto_90;
let _mayor_30_neto = _monto_30_neto + _monto_60_neto + _monto_90_neto;
let _mayor_60_neto = _monto_60_neto + _monto_90_neto;

update cobmoros
   set no_poliza    = _no_poliza
 where no_documento = a_no_documento;

insert into cobmoros(
no_documento,
periodo,
saldo,
por_vencer,
exigible,
corriente,
dias_30,
dias_60,
dias_90,
no_poliza,
saldo_neto,
por_vencer_neto,
exigible_neto,
corriente_neto,
dias_30_neto,
dias_60_neto,
dias_90_neto,
mayor_30,
mayor_60,
mayor_30_neto,
mayor_60_neto,
saldos_impuesto,
saldos_neto_impuesto
)
values(
a_no_documento,
a_periodo,
_saldo,
_por_vencer,
_exigible,
_corriente,
_monto_30,
_monto_60,
_monto_90,
_no_poliza,
_saldo_neto,
_por_vencer_neto,
_exigible_neto,
_corriente_neto,
_monto_30_neto,
_monto_60_neto,
_monto_90_neto,
_mayor_30,
_mayor_60,
_mayor_30_neto,
_mayor_60_neto,
_impuesto,
_impuesto_neto
);

return 0, "Actualizacion Exitosa";

end 

end procedure
