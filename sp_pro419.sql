
-- Procedimiento para insertar el endoso de descuento apoyo COVID-19
-- Amado Perez M - 29/04/2020

drop procedure sp_pro419;
create procedure sp_pro419(a_periodo char(7)) 
returning	{smallint,
			char(100)}
			char(21)		as Poliza,
			varchar(50)		as Contratante,
			char(3)			as Cod_ramo,
			varchar(50)		as Ramo,
			char(5)			as cod_corredor,
			varchar(50)		as Corredor,
			char(3)			as cod_sucursal,
			varchar(50)		as Sucursal,
			char(3)			as cod_formapag,
			varchar(50)		as FormaPago,
			char(5)			as cod_grupo,
			varchar(50)		as Grupo,
			smallint		as NoPagos,
			char(3)			as cod_perpago,
			varchar(50)		as PeriodoPago,
			date			as vigencia_inic,
			date			as vigencia_final,
			dec(16,2)		as suma_asegurada,
			dec(16,2)		as prima_neta,
			dec(16,2)		as impuesto,
			dec(16,2)		as prima_bruta,
			dec(16,2)		as letra,
			dec(16,2)		as letra_sin_imp,
			dec(16,2)		as descuento,
			dec(16,2)		as por_vencer,
			dec(16,2)		as exigible,
			dec(16,2)		as corriente,
			dec(16,2)		as monto_30,
			dec(16,2)		as monto_60,
			dec(16,2)		as monto_90,
			dec(16,2)		as saldo,
			smallint		as aplica,
			varchar(100)	as desc_aplica,
			smallint		as rango;

		   
define _nom_contratante		varchar(50);
define _nom_formapag		varchar(50);
define _nom_sucursal		varchar(50);
define _desc_aplica			varchar(100);
define _nom_perpago			varchar(50);
define _nom_agente			varchar(50);
define _nom_grupo			varchar(50);
define _nom_ramo			varchar(50);
define _error_desc			char(30);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso       	char(5);
define _cod_sucursal		char(3);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_ramo            char(3);
define _null            	char(1);
define _suma_asegurada		dec(16,2);
define _letra_sin_imp		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _descuento			dec(16,2);
define _exigible			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _impuesto			dec(16,2);
define _saldo				dec(16,2);
define _letra				dec(16,2);
define _no_pagos			smallint;
define _aplica				smallint;
define _rango				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _fecha_sus           date;
define _fecha_gestion   	datetime year to second;

--set debug file to "sp_sis418.trc";
--trace on;

set isolation to dirty read;

 	return	'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			0,
			'',
			'',
			null,
			null,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			'',
			'',
			0;


begin

on exception set _error,_error_isam,_error_desc
 	return	_no_documento,
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			0,
			'',
			'',
			null,
			null,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			_error,
			_error_desc || " " || _no_poliza,
			0;
end exception

let _fecha_hoy = current - 1 units day; 


FOREACH
	select mae.no_documento
	  into _no_documento
	  from emipomae mae
     where mae.cod_ramo in ('002')
	   and mae.fecha_suscripcion = _fecha_hoy --poner between desde la fecha que se corrio la ultima vez
	   and mae.cod_subramo = '001'
	   and mae.estatus_poliza = 1
	   and mae.actualizado = 1

--	   and mae.fecha_suscripcion >= '08/06/2020'
--	   and mae.fecha_suscripcion <= _fecha_hoy
	   
 --	   and mae.fecha_suscripcion >= '21/05/2020' --poner between desde la fecha que se corrio la ultima vez
--	   and mae.fecha_suscripcion <= '25/05/2020' --poner between desde la fecha que se corrio la ultima vez	   
  
   -- Falta llamado al sp_sis462	
	call sp_sis463(_no_documento,a_periodo) returning _error,_error_desc;
	
	if _error <> 0 then
		return	_no_documento,
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			0,
			'',
			'',
			null,
			null,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			_error,
			_error_desc,
			0;
	end if
	
	foreach
		select mae.no_documento,
			   con.nombre as Contratante,
			   mae.cod_ramo,
			   ram.nombre as ramo,
			   mae.cod_sucursal,
			   suc.descripcion as sucursal,
			   mae.cod_formapag,
			   pag.nombre as FormaPago,
			   mae.cod_grupo,
			   grp.nombre as Grupo,
			   mae.no_pagos,
			   mae.cod_perpago,
			   per.nombre as PerPago,
			   mae.vigencia_inic,
			   mae.vigencia_final,
			   mae.suma_asegurada,
			   mae.prima_neta,
			   mae.impuesto,
			   mae.prima_bruta,
			   mae.prima_bruta/mae.no_pagos as letra,
			   mae.prima_neta/mae.no_pagos as letra_sin_imp,
			   tmp.por_vencer,
			   tmp.exigible,
			   tmp.corriente,
			   tmp.monto_30,
			   tmp.monto_60,
			   tmp.monto_90,
			   tmp.saldo,
			   tmp.aplica,
			   tmp.desc_aplica,
			   mae.no_poliza
		  into _no_documento,
			   _nom_contratante,
			   _cod_ramo,
			   _nom_ramo,
			   _cod_sucursal,
			   _nom_sucursal,
			   _cod_formapag,
			   _nom_formapag,
			   _cod_grupo,
			   _nom_grupo,
			   _no_pagos,
			   _cod_perpago,
			   _nom_perpago,
			   _vigencia_inic,
			   _vigencia_final,
			   _suma_asegurada,
			   _prima_neta,
			   _impuesto,
			   _prima_bruta,
			   _letra,
			   _letra_sin_imp,
			   _por_vencer,
			   _exigible,
			   _corriente,
			   _monto_30,
			   _monto_60,
			   _monto_90,
			   _saldo,
			   _aplica,
			   _desc_aplica,
			   _no_poliza
		  from emipomae mae
		 inner join tmp_poliza tmp
				 on mae.no_poliza = tmp.no_poliza
		 inner join prdramo ram
				 on ram.cod_ramo = mae.cod_ramo
		 inner join insagen suc
				 on suc.codigo_agencia = mae.cod_sucursal
		 inner join cobforpa pag
				 on pag.cod_formapag = mae.cod_formapag
		 inner join cligrupo grp
				 on grp.cod_grupo = mae.cod_grupo
		 inner join cobperpa per
				 on per.cod_perpago = mae.cod_perpago
		 inner join cliclien con
				 on con.cod_cliente = mae.cod_contratante

		if _no_pagos >= 1 and _no_pagos <= 3 then
			let _descuento = _letra * .05;
			let _rango = 1;
		elif _no_pagos >= 4 and _no_pagos <= 5 then
			let _descuento = _letra * .10;
			let _rango = 2;
		elif _no_pagos >= 6 and _no_pagos <= 7 then
			let _descuento = _letra * .15;
			let _rango = 3;
		elif _no_pagos >= 8 then
			let _descuento = _letra * .20;
			let _rango = 4;
		end if

		foreach
			select cor.cod_agente,
				   agt.nombre
			  into _cod_agente,
				   _nom_agente
			  from emipoagt cor
			 inner join agtagent agt
					 on agt.cod_agente = cor.cod_agente
					and cor.no_poliza = _no_poliza 
			 order by cor.porc_partic_agt
			exit foreach;
		end foreach
		
		if _aplica = 1 then
			--endoso de pronto pago
			begin
			on exception set _error,_error_isam,_error_desc
				return	_no_documento,
						'',
						'',
						'',
						'',
						'',
						'',
						'',
						'',
						'',
						'',
						'',
						0,
						'',
						'',
						null,
						null,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						0.00,
						_error,
						_error_desc || " " || _no_poliza,
						0 with resume;
			end exception			
			insert into polcovid(
					periodo,
					no_poliza,
					no_documento,
					prima_bruta,
					user_added)
			values(	a_periodo,
					_no_poliza,
					_no_documento,
					_descuento,
					'DEIVID');
			end
		end if
			
		return	_no_documento,
				_nom_contratante,
				_cod_ramo,
				_nom_ramo,
				_cod_agente,
				_nom_agente,
				_cod_sucursal,
				_nom_sucursal,
				_cod_formapag,
				_nom_formapag,
				_cod_grupo,
				_nom_grupo,
				_no_pagos,
				_cod_perpago,
				_nom_perpago,
				_vigencia_inic,
				_vigencia_final,
				_suma_asegurada,
				_prima_neta,
				_impuesto,
				_prima_bruta,
				_letra,
				_letra_sin_imp,
				_descuento,
				_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo,
				_aplica,
				_desc_aplica,
				_rango with resume;
	end foreach
END FOREACH			

--return 0, "Actualizacion Exitosa...";
end
end procedure;