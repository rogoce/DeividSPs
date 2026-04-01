-- Verificacion de los Asientos para una Poliza

-- Creado    : 15/08/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par230;		

create procedure "informix".sp_par230(a_no_documento char(20))
returning date,
		  char(10),
		  char(20),
		  dec(16,2),
		  char(25),
		  char(50),
		  dec(16,2),
		  dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_remesa		char(10);
define _renglon			smallint;

define _documento		char(10);
define _fecha			date;
define _tipo			char(10);
define _monto			dec(16,2);

define _cod_cuenta		char(25);
define _nombre			char(50);
define _debito			dec(16,2);
define _credito			dec(16,2);

create temp table tmp_asientos(
fecha		date,
tipo		char(10),
documento	char(10),
monto		dec(16,2),
cod_cuenta	char(25),
debito		dec(16,2),
credito		dec(16,2)
) with no log;

let _tipo = "FACTURA";
 
foreach
 select no_poliza,
        no_endoso,
		prima_bruta,
		fecha_emision,
		no_factura
   into _no_poliza,
        _no_endoso,
		_monto,
		_fecha,
		_documento
   from endedmae
  where no_documento = a_no_documento
    and actualizado  = 1

	foreach
	 select cuenta,
	        debito,
			credito
	   into _cod_cuenta,
	        _debito,
			_credito
	   from endasien
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso
		and tipo_comp = 1

		insert into tmp_asientos
		values(
		_fecha,
		_tipo,
		_documento,
		_monto,
		_cod_cuenta,
		_debito,
		_credito
		);

	end foreach

end foreach

let _tipo = "RECIBO";
 
foreach
 select no_remesa,
        renglon,
		monto,
		fecha,
		no_recibo
   into _no_remesa,
        _renglon,
		_monto,
		_fecha,
		_documento
   from cobredet
  where doc_remesa  = a_no_documento
    and actualizado = 1
	and tipo_mov    in ("P", "N")

	foreach
	 select cuenta,
	        debito,
			credito
	   into _cod_cuenta,
	        _debito,
			_credito
	   from cobasien
	  where no_remesa = _no_remesa
	    and renglon   = _renglon

		insert into tmp_asientos
		values(
		_fecha,
		_tipo,
		_documento,
		_monto,
		_cod_cuenta,
		_debito,
		_credito
		);

	end foreach

end foreach

foreach
 select fecha, 
		tipo,
		documento,
		monto,
		cod_cuenta,
		debito,
		credito
   into _fecha,
		_tipo,
		_documento,
		_monto,
		_cod_cuenta,
		_debito,
		_credito
   from	tmp_asientos
  where cod_cuenta[1,3] not in ("265", "411", "264", "240")

	select cta_nombre
	  into _nombre
	  from cglcuentas
	 where cta_cuenta = _cod_cuenta;

	return _fecha,
		   _tipo,
		   _documento,
		   _monto,
		   _cod_cuenta,
		   _nombre,
		   _debito,
		   _credito
		   with resume;

end foreach

drop table tmp_asientos;


end procedure 
