-- Morosidad a una Fecha para pasar a Business Object

-- Creado    : 23/01/2004 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_bo089a;

create procedure "informix".sp_bo089a(
a_periodo char(7),
a_fin_mes smallint default 0	
) returning integer,
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
define _monto_120    	dec(16,2);
define _monto_150    	dec(16,2);
define _monto_180    	dec(16,2);
define _saldo       	dec(16,2);
define _impuesto       	dec(16,2);

define _por_vencer_neto	dec(16,2);
define _exigible_neto   dec(16,2);
define _corriente_neto  dec(16,2);
define _monto_30_neto   dec(16,2);
define _monto_60_neto   dec(16,2);
define _monto_90_neto   dec(16,2);
define _monto_120_neto  dec(16,2);
define _monto_150_neto  dec(16,2);
define _monto_180_neto  dec(16,2);
define _saldo_neto      dec(16,2);
define _impuesto_neto  	dec(16,2);

define _por_vencer_pxc	dec(16,2);
define _exigible_pxc    dec(16,2);
define _corriente_pxc   dec(16,2);
define _monto_30_pxc    dec(16,2);
define _monto_60_pxc    dec(16,2);
define _monto_90_pxc    dec(16,2);
define _monto_120_pxc   dec(16,2);
define _monto_150_pxc   dec(16,2);
define _monto_180_pxc   dec(16,2);
define _saldo_pxc       dec(16,2);
define _impuesto_pxc   	dec(16,2);

define _mayor_30        dec(16,2);
define _mayor_60        dec(16,2);
define _mayor_30_neto   dec(16,2);
define _mayor_60_neto   dec(16,2);
define _mayor_30_pxc    dec(16,2);
define _mayor_60_pxc    dec(16,2);

define _porc_impuesto	dec(16,2);
define _porc_coaseguro	dec(16,4);

define _cod_tipoprod    char(3);
define _cod_coasegur    char(3);

define _cantidad        integer;

define _porc_partic		dec(16,2);
define _tipo_contrato	smallint;
define _cod_contrato	char(5);

define _cod_acreedor	char(5);
define _nombre_acreedor	char(50);
define _cant_acreedor   integer;

define _leasing			smallint;
define _cod_leasing		char(10);
define _nombre_leasing	char(50);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _error_desc2		char(50);

--set debug file to "sp_cob134.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

set isolation to dirty read;

select par_ase_lider
  into _cod_coasegur
  from parparam;

if a_fin_mes = 1 then
	let _fecha = sp_sis36(a_periodo);
else
	let _fecha = today + 1;
end if

let _cantidad = 0;

foreach
 select no_documento
   into	_no_documento
   from emipoliza
   where no_documento in('0207-01609-01','0215-00519-03','0414-00016-01','1608-00138-01','1609-00199-01','1609-00217-01','1609-00378-01','1609-00414-01','1611-00012-01','1612-00035-01','1614-00608-09','1614-00979-09','1614-01071-09','1800-00035-01','1801-00459-01','1801-00460-01','1801-00549-01','1802-00129-01','1806-00777-01','1806-01172-01','1810-00609-01')

	let _error_desc2 = "Numero de Poliza";

	let _no_poliza = sp_sis21(_no_documento);

	if _no_poliza is null then
		continue foreach;
	end if

	select cod_tipoprod,
	       leasing
	  into _cod_tipoprod,
	       _leasing
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Acreedor Hipotecario

	let _nombre_acreedor = null;

	foreach
     select cod_acreedor, 
            count(*)
	   into _cod_acreedor,
	        _cant_acreedor
       from emipoacr
      where no_poliza = _no_poliza
      group by 1
      order by 2 desc
      
		select nombre
		  into _nombre_acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor; 

		exit foreach;

	end foreach      	        

	-- Leasing

	let _nombre_leasing = null;

	if _leasing = 1 then

		foreach
		 select cod_asegurado
		   into _cod_leasing
		   from emipouni
		  where no_poliza = _no_poliza

			select nombre
			  into _nombre_leasing
			  from cliclien
			 where cod_cliente = _cod_leasing;

			exit foreach;

		end foreach

	end if

	if _cod_tipoprod = "004" then

		let _saldo           = 0.00;
		let _por_vencer      = 0.00;
		let _exigible        = 0.00;
		let _corriente       = 0.00;
		let _monto_30        = 0.00;
		let _monto_60        = 0.00;
		let _monto_90        = 0.00;
		let _monto_120       = 0.00;
		let _monto_150       = 0.00;
		let _monto_180       = 0.00;
		let _impuesto        = 0.00;

		let _saldo_pxc       = 0.00;
		let _por_vencer_pxc  = 0.00;
		let _exigible_pxc    = 0.00;
		let _corriente_pxc   = 0.00;
		let _monto_30_pxc    = 0.00;
		let _monto_60_pxc    = 0.00;
		let _monto_90_pxc    = 0.00;
		let _monto_120_pxc   = 0.00;
		let _monto_150_pxc   = 0.00;
		let _monto_180_pxc   = 0.00;
		let _impuesto_pxc    = 0.00;

		let _saldo_neto      = 0.00;
		let _por_vencer_neto = 0.00;
		let _exigible_neto   = 0.00;
		let _corriente_neto  = 0.00;
		let _monto_30_neto   = 0.00;
		let _monto_60_neto   = 0.00;
		let _monto_90_neto   = 0.00;
		let _monto_120_neto  = 0.00;
		let _monto_150_neto  = 0.00;
		let _monto_180_neto  = 0.00;
		let _impuesto_neto   = 0.00;

	else

		let _error_desc2 = "Calculando Morosidad";

		CALL sp_cob245(
			 "001",
			 "001",	
			 _no_documento,
			 a_periodo,
			 _fecha
			 ) RETURNING _por_vencer,      
						 _exigible,         
						 _corriente,        
						 _monto_30,         
						 _monto_60,         
						 _monto_90,
						 _monto_120,
 						 _monto_150,
						 _monto_180,
						 _saldo;         
	
		-- Primas por Cobrar sin Impuestos

		let _error_desc2 = "Calculando Morosidad sin impuestos";

		select sum(i.factor_impuesto)
		  into _porc_impuesto
		  from emipolim p, prdimpue i
		 where p.cod_impuesto = i.cod_impuesto
		   and p.no_poliza    = _no_poliza;  

		if _porc_impuesto is null then
			let _porc_impuesto = 0.00;
		end if

		let _por_vencer_pxc	= _por_vencer	/ (1 + (_porc_impuesto / 100));
		let _exigible_pxc 	= _exigible   	/ (1 + (_porc_impuesto / 100));
		let _corriente_pxc  = _corriente    / (1 + (_porc_impuesto / 100));
		let _monto_30_pxc   = _monto_30     / (1 + (_porc_impuesto / 100));
		let _monto_60_pxc   = _monto_60     / (1 + (_porc_impuesto / 100));
		let _monto_90_pxc   = _monto_90     / (1 + (_porc_impuesto / 100));
		let _monto_120_pxc  = _monto_120    / (1 + (_porc_impuesto / 100));
		let _monto_150_pxc  = _monto_150    / (1 + (_porc_impuesto / 100));
		let _monto_180_pxc  = _monto_180    / (1 + (_porc_impuesto / 100));
		let _saldo_pxc   	= _saldo     	/ (1 + (_porc_impuesto / 100));

		let _impuesto_pxc = _saldo - _saldo_pxc;
		let _impuesto     = _saldo - _saldo_pxc;

		-- Primas por Cobrar - Coaseguro Mayoritario

		let _saldo_neto      = _saldo_pxc;
		let _por_vencer_neto = _por_vencer_pxc;
		let _exigible_neto   = _exigible_pxc;
		let _corriente_neto  = _corriente_pxc;
		let _monto_30_neto   = _monto_30_pxc;
		let _monto_60_neto   = _monto_60_pxc;
		let _monto_90_neto   = _monto_90_pxc;
		let _monto_120_neto  = _monto_120_pxc;
		let _monto_150_neto  = _monto_150_pxc;
		let _monto_180_neto  = _monto_180_pxc;
		let _impuesto_neto   = _impuesto_pxc;	

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
			let _monto_120_neto  = _monto_120_neto  * (_porc_coaseguro / 100);
			let _monto_150_neto  = _monto_150_neto  * (_porc_coaseguro / 100);
			let _monto_180_neto  = _monto_180_neto  * (_porc_coaseguro / 100);
			let _impuesto_neto   = _impuesto_neto   * (_porc_coaseguro / 100);	

		end if

	end if

	let _mayor_30      = _monto_30      + _monto_60 + _monto_90;
	let _mayor_60      = _monto_60      + _monto_90;
	let _mayor_30_neto = _monto_30_neto + _monto_60_neto + _monto_90_neto;
	let _mayor_60_neto = _monto_60_neto + _monto_90_neto;
	let _mayor_30_pxc  = _monto_30_pxc  + _monto_60_pxc + _monto_90_pxc;
	let _mayor_60_pxc  = _monto_60_pxc  + _monto_90_pxc;

	let _error_desc2 = "Insert Cobmoros";

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
	dias_120,
	dias_150,
	dias_180,
	no_poliza,
	saldo_neto,
	por_vencer_neto,
	exigible_neto,
	corriente_neto,
	dias_30_neto,
	dias_60_neto,
	dias_90_neto,
	dias_120_neto,
	dias_150_neto,
	dias_180_neto,
	mayor_30,
	mayor_60,
	mayor_30_neto,
	mayor_60_neto,
	saldos_impuesto,
	saldos_neto_impuesto,
	saldo_pxc,
	por_vencer_pxc,
	exigible_pxc,
	corriente_pxc,
	monto_30_pxc,
	monto_60_pxc,
	monto_90_pxc,
	dias_120_pxc,
	dias_150_pxc,
	dias_180_pxc,
	mayor_30_pxc,
	mayor_60_pxc,
	impuesto_pxc,
	acreedor,
	nombre_leasing
	)
	values(
	_no_documento,
	a_periodo,
	_saldo,
	_por_vencer,
	_exigible,
	_corriente,
	_monto_30,
	_monto_60,
	_monto_90,
	_monto_120,
	_monto_150,
	_monto_180,
	_no_poliza,
	_saldo_neto,
	_por_vencer_neto,
	_exigible_neto,
	_corriente_neto,
	_monto_30_neto,
	_monto_60_neto,
	_monto_90_neto,
	_monto_120_neto,
	_monto_150_neto,
	_monto_180_neto,
	_mayor_30,
	_mayor_60,
	_mayor_30_neto,
	_mayor_60_neto,
	_impuesto,
	_impuesto_neto,
	_saldo_pxc,
	_por_vencer_pxc,
	_exigible_pxc,
	_corriente_pxc,
	_monto_30_pxc,
	_monto_60_pxc,
	_monto_90_pxc,
	_monto_120_pxc,
	_monto_150_pxc,
	_monto_180_pxc,
	_mayor_30_pxc,
	_mayor_60_pxc,
	_impuesto_pxc,
	_nombre_acreedor,
	_nombre_leasing
	);

end foreach

return 0, "Actualizacion Exitosa";

end 

end procedure
