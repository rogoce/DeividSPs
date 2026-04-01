-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 30/08/2006 - Autor: Armando Moreno

drop procedure sp_che64a;

create procedure sp_che64a(a_fecha date, a_fecha2 date)
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   smallint,
		   char(50),
		   char(8),
		   char(8),
		   char(10),
		   date,
		   dec(16,2),
		   char(100),
		   char(100),
		   char(18),
		   char(8),
		   integer;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _nom_recla		char(100);
define _nom_aseg		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _cod_asegurado	char(10);
define _cod_reclamante	char(10);
define _no_reclamo		char(10);
define _monto_tran		dec(16,2);
define _fecha			date;
define _transaccion		char(10);
define _reclamo			char(18);
define _user_added		char(8);
define _no_cheque		integer;

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
		no_cheque
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_no_cheque
   from	chqchmae
  where anulado       = 0
    and autorizado    = 1
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera
	and pagado			= 1
	and en_firma        = 2
	and fecha_impresion between a_fecha and a_fecha2

 foreach
	select cod_tipopago,
		   transaccion,
		   fecha,
		   monto,
		   no_reclamo,
		   user_added
	  into _cod_tipopago,
		   _transaccion,
		   _fecha,
		   _monto_tran,
		   _no_reclamo,
		   _user_added
	  from rectrmae
	 where no_requis = _no_requis

	 select cod_asegurado,
			cod_reclamante,
			numrecla
	   into _cod_asegurado,
			_cod_reclamante,
			_reclamo
	   from recrcmae
	  where no_reclamo = _no_reclamo;

	 select nombre
	   into _nom_tipopago
	   from rectipag
	  where cod_tipopago = _cod_tipopago;

	 select nombre
	   into _nom_recla
	   from cliclien
	  where cod_cliente = _cod_reclamante;

	 select nombre
	   into _nom_aseg
	   from cliclien
	  where cod_cliente = _cod_asegurado;

	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   _periodo_pago,
		   _nom_tipopago,
		   _firma1,
		   _firma2,
		   _transaccion,
		   _fecha,
		   _monto_tran,
		   _nom_aseg,
		   _nom_recla,
		   _reclamo,
		   _user_added,
		   _no_cheque
		   with resume;
 end foreach
   
end foreach

end procedure
