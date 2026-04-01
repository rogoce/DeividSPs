-- Reporte para las requisiciones de Reclamos de Salud

-- Creado    : /01/2002 - Autor: Armando Moreno

drop procedure sp_che54a;

create procedure sp_che54a(a_fecha date)
 returning integer;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _fecha_captura	date;
define _a_nombre_de		char(100);
define _tipo_requis     char(1);

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
		fecha_captura,
		tipo_requis
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_fecha_captura,
		_tipo_requis
   from	chqchmae
  where anulado       = 0
    and autorizado    = 1
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera
	and pagado        = 0
	and en_firma      = 0

--	and fecha_captura = a_fecha

 foreach
	select cod_tipopago
	  into _cod_tipopago
	  from rectrmae
	 where no_requis = _no_requis

	exit foreach;
 end foreach

-- Se quita por instruccion del Sr. Murillo segun reunion 01/04/2013
   
 { if _cod_tipopago = "001" and _periodo_pago = 0 and _tipo_requis = "C" then  --> los de ACH no deben ser cambiados ya que cobran diario

	update chqchmae
	   set periodo_pago = 1
	 where no_requis = _no_requis;

	update cliclien
	   set periodo_pago = 1
	 where cod_cliente = _cod_cliente;

  end if }

end foreach

return 0;
end procedure
