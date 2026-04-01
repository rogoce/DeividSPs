-- Reporte para las requisiciones de Reclamos de Salud

-- Creado    : /01/2002 - Autor: Armando Moreno

drop procedure sp_che54;

create procedure sp_che54(a_fecha date)
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

SET ISOLATION TO DIRTY READ;


foreach
select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018'


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
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera
	and fecha_captura = a_fecha
	and pagado        = 0
	and en_firma      = 0

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

--  if _cod_tipopago = "001" and _periodo_pago = 0 then

  {if _cod_tipopago = "001" then	--PROVEEDOR
	update chqchmae
	   set periodo_pago = 1
	 where no_requis = _no_requis;

	update cliclien
	   set periodo_pago = 1
	 where cod_cliente = _cod_cliente;

  end if}

	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   _periodo_pago,
		   _nom_tipopago,
		   _fecha_captura
		   with resume;

end foreach
end foreach

end procedure
