--------------------------------------------
--Verificación de comisiones de corredores de pólizas vigentes
--execute procedure sp_aud54('2016-03','2017-03')
--22/07/2016 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_aud54;
create procedure sp_aud54( a_periodo_desde char(7), a_periodo_hasta char(7))
returning	char(20)		as Poliza,
			varchar(100)	as Contratante,
			varchar(30)		as Chasis,
			varchar(30)		as Motor,
			date			as Fecha_Emision,
			date			as Vigencia_inic,
			date			as Vigencia_final,
			dec(16,2)		as Suma_Asegurada,
			dec(16,2)		as Prima,
			date			as Fecha_Cancelacion,
			integer			as Cheque,
			date			as Fecha_Devolucion,
			dec(16,2)		as Monto_Devuelto,
			varchar(100)	as Tipo_Cancelacion;

define _error_desc			varchar(100);
define _nom_cliente			varchar(100);
define _tipo_cancelacion	varchar(50);
define _no_chasis			varchar(30);
define _no_motor			varchar(30);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_requis			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_tipocan			char(3);
define _suma_asegurada		dec(16,2);
define _monto_devuelto		dec(16,2);
define _prima_bruta			dec(16,2);
define _estatus_poliza		smallint;
define _cnt_unidad			smallint;
define _cnt_emis			smallint;
define _cnt_dev				smallint;
define _anulado				smallint;
define _error_isam			integer;
define _no_cheque			integer;
define _error				integer;
define _fecha_cancelacion	date;
define _fecha_devolucion	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_emision		date;
define _fecha_rehab			date;
define _fecha_pago			date;

--set debug file to 'sp_rea27.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return	'',_error_desc,'','',null,null,null,0.00,0.00,null,_error,null,0.00,'';
end exception  

set isolation to dirty read;

foreach
	select distinct p.no_documento,
		   p.no_poliza,
		   max(fecha_emision)
	  into _no_documento,
		   _no_poliza,
		   _fecha_cancelacion
	  from endedmae e, emipomae p
	 where e.no_poliza = p.no_poliza
	   and p.cod_ramo in (select cod_ramo from prdramo where ramo_sis = 1)
	   and e.cod_endomov = '002'
	   and e.periodo between a_periodo_desde and a_periodo_hasta
	   and e.actualizado = 1
	 group by 1,2

	select cod_pagador,
		   estatus_poliza,
		   vigencia_inic,
		   vigencia_final,
		   fecha_suscripcion
	  into _cod_contratante,
		   _estatus_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_emision
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza not in (2,4) then
		select max(fecha_emision)
		  into _fecha_rehab
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov = '003'
		   and fecha_emision >= _fecha_cancelacion
		   and actualizado = 1;

		if _fecha_rehab <= '31/03/2017' then
			continue foreach;
		end if
	end if

	let _monto_devuelto = 0.00;
	let _no_cheque = 0;
	let _fecha_devolucion = null;
	
	foreach
		select no_requis,
			   monto
		  into _no_requis,
			   _monto_devuelto
		  from chqchpol
		 where no_poliza = _no_poliza

		select no_cheque,
			   fecha_impresion,
			   anulado
		  into _no_cheque,
			   _fecha_devolucion,
			   _anulado
		  from chqchmae
		 where no_requis = _no_requis;

		if _anulado = 1 then
			let _monto_devuelto = 0.00;
		end if
	end foreach

	select max(no_endoso)
	  into _no_endoso
	  from endedmae
	 where no_poliza = _no_poliza
	   and fecha_emision = _fecha_cancelacion;

	select cod_tipocan
	  into _cod_tipocan
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	select nombre
	  into _tipo_cancelacion
	  from endtican
	 where cod_tipocan = _cod_tipocan;

	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	foreach
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso

		select nvl(count(*),0)
		  into _cnt_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _cnt_unidad = 0 then
			return	_no_documento,'No Existe en Emipouni',_no_unidad,'',null,null,null,0.00,0.00,null,-1,null,0.00,'' with resume;
			continue foreach;
		else
			select prima_bruta,
				   suma_asegurada
			  into _prima_bruta,
				   _suma_asegurada
			  from emipouni
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
		end if

		select nvl(count(*),0)
		  into _cnt_emis
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = '00000'
		   and no_unidad = _no_unidad;

		if _cnt_emis = 0 then
			select min(fecha_emision)
			  into _fecha_emision
			  from endedmae e, endeduni u
			 where e.no_poliza = u.no_poliza
			   and e.no_endoso = u.no_endoso
			   and e.no_poliza = _no_poliza
			   and e.cod_endomov = '004'
			   and e.actualizado = 1
			   and u.no_unidad = _no_unidad;
		end if

		select nvl(no_chasis,'No Existe Chasis ' || trim(_no_poliza) || trim(_no_unidad)),
			   nvl(v.no_motor,'No Existe Motor ' || trim(_no_poliza) || trim(_no_unidad))
		  into _no_chasis,
			   _no_motor
		  from emiauto a, emivehic v
		 where a.no_motor = v.no_motor
		   and a.no_poliza = _no_poliza
		   and a.no_unidad = _no_unidad;

		return	_no_documento,
				_nom_cliente,
				_no_chasis,
				_no_motor,
				_fecha_emision,
				_vigencia_inic,
				_vigencia_final,
				_suma_asegurada,
				_prima_bruta,
				_fecha_cancelacion,
				_no_cheque,
				_fecha_devolucion,
				_monto_devuelto,
				_tipo_cancelacion with resume;
	end foreach
end foreach

end
end procedure;