-- Reporte del Cierre de Caja - Resumen

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_cierre_caja_automatico_reporte - DEIVID, S.A.
  
--drop procedure sp_cob233;

create procedure "informix".sp_cob233(a_no_caja char(10))
returning smallint,
          smallint,
          char(25),
          char(50),
          dec(16,2),
          char(10),
          date,
          char(50),
          smallint;

define _cod_chequera 	char(3); 
define _nombre_caja		char(50);
define _fecha 			date; 
define _en_balance		smallint;

define _cta_cuenta		char(25);
define _cta_nombre		char(50);
define _tipo_pago		smallint;
define _tipo_tarjeta	smallint;
define _importe			dec(16,2);

set isolation to dirty read;

select fecha,
       cod_chequera,
	   en_balance
  into _fecha,
       _cod_chequera,
	   _en_balance
  from cobcieca
 where no_caja = a_no_caja;

select nombre
  into _nombre_caja
  from chqchequ
 where cod_banco    = "146"
   and cod_chequera = _cod_chequera;

foreach
 select tipo_pago,
		tipo_tarjeta, 
		monto,
		cuenta,
		nombre	
   into _tipo_pago,
		_tipo_tarjeta, 
		_importe,
		_cta_cuenta,
		_cta_nombre	
   from cobcieca2
  where no_caja = a_no_caja
  order by renglon

		if _tipo_pago <> 4 then
			let _tipo_tarjeta = 0;
		end if
   
		let _tipo_pago = _tipo_pago + _tipo_tarjeta;

		return _tipo_pago,
			   _tipo_tarjeta,
			   _cta_cuenta,
			   _cta_nombre,
			   _importe,
			   a_no_caja,
			   _fecha,
			   _nombre_caja,
			   _en_balance	
			   with resume;
	
end foreach   		

end procedure