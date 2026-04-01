-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 12/07/2006 - Autor: Armando Moreno

drop procedure sp_che55;

create procedure sp_che55(a_fecha date)
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   smallint,
		   char(50),
		   char(8),
		   char(8),
		   datetime year to fraction(5);

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _fecha_time      datetime year to fraction(5);

SET ISOLATION TO DIRTY READ;

select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		firma1,
		firma2,
		fecha_paso_firma
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_fecha_time
   from	chqchmae
  where anulado       = 0
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera
	and pagado        = 0
	and en_firma      = 1
	and fecha_captura = a_fecha

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

	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   _periodo_pago,
		   _nom_tipopago,
		   _firma1,
		   _firma2,
		   _fecha_time
		   with resume;

end foreach

end procedure
