-- Reporte para las requisiciones de Reclamos de Salud no autorizadas por falta de disponibilidad $

-- Creado    : /01/2002 - Autor: Armando Moreno

--drop procedure sp_che65a;

create procedure sp_che65a()
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   smallint,
		   char(50),
		   date;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _fecha_captura	date;
define _a_nombre_de		char(100);
define _firma_electronica smallint;

SET ISOLATION TO DIRTY READ;


select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

select firma_electronica
  into _firma_electronica
  from chqchequ
 where cod_banco    = _cod_banco
   and cod_chequera	= _cod_chequera;

foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		fecha_captura
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_fecha_captura
   from	chqchmae
  where anulado       = 0
    and autorizado    = 0
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera

 foreach
	select cod_tipopago
	  into _cod_tipopago
	  from rectrmae
	 where no_requis = _no_requis

	exit foreach;
 end foreach
   
 select nombre
   into _nom_tipopago
   from rectipag
  where cod_tipopago = _cod_tipopago;

  
 update chqchmae
    set autorizado = 1
  where no_requis = _no_requis;

	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   _periodo_pago,
		   _nom_tipopago,
		   _fecha_captura
		   with resume;

end foreach

end procedure