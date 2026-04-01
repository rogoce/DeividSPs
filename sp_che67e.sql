
-- Creado    : 16/01/2007 - Autor: Armando Moreno

drop procedure sp_che67e;

create procedure sp_che67e(a_fecha1 date, a_fecha2 date)
 returning integer,date,char(10),dec(16,2);

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
define _no_cheque,_cant,_no_cheque2		integer;
define _fecha_impresion date;

SET ISOLATION TO DIRTY READ;

select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

let _fecha = sp_sis26();

foreach
 select	count(*),
		no_cheque
   into	_cant,
		_no_cheque
   from	chqchmae
  where anulado         = 0
    and autorizado      = 1
	and cod_banco       = _cod_banco
	and cod_chequera    = _cod_chequera
	and pagado			= 1
	and fecha_impresion between a_fecha1 and a_fecha2
	group by no_cheque
	order by no_cheque

	if _cant > 1 then

		foreach
			
			select fecha_impresion,
			       no_requis,
				   monto
			  into _fecha_impresion,
			       _no_requis,
				   _monto_tran
			  from chqchmae
			 where no_cheque    = _no_cheque
			   and cod_chequera	= "006"
			 order by 2

			return _no_cheque,
				   _fecha_impresion,
				   _no_requis,
				   _monto_tran
				   with resume;
		end foreach
	end if
end foreach

{foreach
 select	no_requis,
		no_cheque,
		fecha_impresion
   into	_no_requis,
		_no_cheque,
		_fecha_impresion
   from	chqchmae
  where anulado         = 0
    and autorizado      = 1
	and cod_banco       = _cod_banco
	and cod_chequera    = _cod_chequera
	and pagado			= 1
	and fecha_impresion between a_fecha1 and a_fecha2
	order by no_cheque

	let _no_cheque2 = 0;
	let _no_cheque2 = _no_cheque + 1;

	select count(*)
	  into _cant
	  from chqchmae
	 where no_cheque = _no_cheque2;

	if _cant > 0 then
	else
		return _no_cheque,
			   _no_cheque2,
			   _no_requis
			   with resume;
	end if

end foreach}

end procedure
