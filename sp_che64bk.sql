-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 12/07/2006 - Autor: Armando Moreno

drop procedure sp_che64bk;

create procedure sp_che64bk()
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   smallint,
		   char(8),
		   char(8),
		   integer,
		   date,
		   datetime year to fraction(5),
  		   dec(16,2);

define _no_requis		char(10);
define _cod_cliente		char(10);
define _monto			dec(16,2);
define _monto_tr		dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _fecha_captura   date;
define _dias            integer;
define _fecha_firma1	datetime year to fraction(5);
define _fecha_firma2	datetime year to fraction(5);
define _fecha_time		datetime year to fraction(5);
define _fecha_hoy_time	datetime year to fraction(5);

SET ISOLATION TO DIRTY READ;

let _fecha_hoy_time = CURRENT;

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
		fecha_captura,
		fecha_firma1,
		fecha_firma2,	
		fecha_paso_firma
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_fecha_captura,
		_fecha_firma1,
		_fecha_firma2,
		_fecha_time
   from	chqchmae
  where anulado       = 0
    and autorizado    = 1
    and pagado		  = 0
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera
	and en_firma      = 1
  order by fecha_captura

  select sum(monto)
    into _monto_tr
	from chqchrec
   where no_requis = _no_requis;

  if _monto_tr <> _monto then
	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   _periodo_pago,
		   _firma1,
		   _firma2,
		   0,
		   _fecha_captura,
		   _fecha_time,
		   _monto_tr
		   with resume;	
  end if

end foreach

end procedure
