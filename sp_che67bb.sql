
-- Creado    : 04/01/2007 - Autor: Armando Moreno

drop procedure sp_che67bb;

create procedure sp_che67bb(a_no_requis char(10), a_no_cheque integer)
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   smallint,
		   char(8),
		   char(8),
		   integer,
		   date;

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
define _no_cheque,_cant		integer;
define _fecha_impresion date;

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
		no_cheque,
		fecha_impresion
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_no_cheque,
		_fecha_impresion
   from	chqchmae
  where anulado         = 0
	and cod_banco       = _cod_banco
	and cod_chequera    = _cod_chequera
	and pagado			= 0
	and en_firma        = 2
	and no_requis       = a_no_requis
--    and autorizado      = 1	  Amado 26-03-2009

 {select count(*)
   into _cant
   from chqchmae
  where no_cheque    = _no_cheque
	and cod_banco    = _cod_banco
	and cod_chequera = _cod_chequera;

--if _cant > 1 then} 

	update rectrmae
	   set pagado = 1
	 where no_requis   = _no_requis
	   and actualizado = 1;

   	update chqchmae
	   set pagado    = 1,
	       autorizado = 1,	-- Amado 26-03-2009
	       no_cheque = a_no_cheque
	 where no_requis = _no_requis;

	insert into bitache(no_requis, no_cheque)
	values (a_no_requis, a_no_cheque);

	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   _periodo_pago,
		   _firma1,
		   _firma2,
		   _no_cheque,
		   _fecha_impresion
		   with resume;
--end if
end foreach

end procedure
