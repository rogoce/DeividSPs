drop procedure sp_sac166;

create procedure sp_sac166()
returning char(3),
          char(7),
		  date,
		  char(25),
		  dec(16,2),
		  dec(16,2);

define _notrx		integer;
define _contador	integer;

define _no_remesa	char(10);
define _renglon     smallint;
define _cuenta		char(25);
define _debito		dec(16,2);
define _debito2		dec(16,2);
define _credito		dec(16,2);
define _credito2	dec(16,2);
define _periodo		char(7);
define _costo		char(3);
define _fecha		date;

define _comprobante		char(15);
define _concepto		char(3);
define _origen      	char(3);
define _tipo_comp		smallint;
define _descrip			char(50);
define _tipo_compd		char(50);

define _linea			integer;
define _linea_aux		integer;
define _cod_auxiliar	char(5);

--drop table tmp_asie;
--drop table tmp_asie2;

create temp table tmp_asie(
no_remesa	char(10),
renglon     smallint,
cuenta		char(25),
debito		dec(16,2),
credito		dec(16,2),
periodo		char(7),
costo		char(3),
fecha		date
) with no log;

{ 
create temp table tmp_asie2(
no_remesa	char(10),
renglon     smallint,
cuenta		char(25),
debito		dec(16,2),
credito		dec(16,2),
periodo		char(7),
costo		char(3),
fecha		date,
cod_aux		char(5)
) with no log;
}

foreach
 select no_remesa,
        renglon,
		periodo
   into _no_remesa,
        _renglon,
		_periodo
   from cobredet
  where periodo = "2009-12"
    and actualizado = 1
	and sac_asientos <> 2

	update cobredet
	   set sac_asientos = 2
     where no_remesa = _no_remesa
       and renglon   = _renglon;

	foreach
	 select cuenta,
	        debito,
			credito,
			centro_costo,
			fecha
	   into	_cuenta,
	        _debito,
			_credito,
			_costo,
			_fecha
	   from cobasien
	  where no_remesa = _no_remesa
	    and renglon   = _renglon
	
		update cobasien
		   set sac_notrx = 65233,
		       periodo   = "2009-12"
		 where no_remesa = _no_remesa
		   and renglon   = _renglon
		   and cuenta    = _cuenta;

		insert into tmp_asie
		values (_no_remesa, _renglon, _cuenta, _debito, _credito, _periodo, _costo, _fecha);

		{
		foreach
		 select debito,
				credito,
				cod_auxiliar
		   into	_debito2,
				_credito2,
				_cod_auxiliar
		   from cobasiau
		  where no_remesa = _no_remesa
		    and renglon   = _renglon
			and cuenta    = _cuenta

			insert into tmp_asie2
			values (_no_remesa, _renglon, _cuenta, _debito2, _credito2, _periodo, _costo, _fecha, _cod_auxiliar);

		end foreach
		}

	end foreach

end foreach

let _concepto	   = "015"; -- Cajas
let _origen		   = "COB"; -- Cobros
let _tipo_comp     = 2;

let _contador = 0;
let _linea    = 0;

foreach
 select costo,
        periodo,
		fecha,
		cuenta,
		sum(debito),
		sum(credito)
   into _costo,
		_periodo,
		_fecha,
		_cuenta,
		_debito,
		_credito
   from tmp_asie
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	{
	let _contador = _contador + 1;

	if _contador = 1 then

		let _notrx = sp_sac10();

		let _tipo_compd  = sp_sac11(3, _tipo_comp);
		let _comprobante = _origen || _periodo[6,7] || _periodo[3,4] || _tipo_comp;
		let _descrip     = _origen || " " || _periodo || " " || trim(_tipo_compd);

		-- Insercion de Comprobantes

		insert into cgltrx1(
		trx1_notrx,
		trx1_tipo,
		trx1_comprobante,
		trx1_fecha,
		trx1_concepto,
		trx1_ccosto,
		trx1_descrip,
		trx1_monto,
		trx1_moneda,
		trx1_debito,
		trx1_credito,
		trx1_status,
		trx1_origen,
		trx1_usuario,
		trx1_fechacap
		)
		values(
		_notrx,
		"01",
		_comprobante,
		_fecha,
		_concepto,
		_costo,
		_descrip,
		0.00,
		"00",
		0.00,
		0.00,
		"I",
		_origen,
		"informix",
		_fecha
		);

	end if

	let _linea   = _linea + 1;

	insert into cgltrx2(
	trx2_notrx,
	trx2_tipo,
	trx2_linea,
	trx2_cuenta,
	trx2_ccosto,
	trx2_debito,
	trx2_credito,
	trx2_actlzdo
	)
	values(
	_notrx,
	"01",
	_linea,
	_cuenta,
	_costo,
	_debito,
	_credito,
	0
	);

	update cgltrx1
	   set trx1_debito  = trx1_debito  + _debito,
	       trx1_credito = trx1_credito + _credito,
		   trx1_monto   = trx1_monto   + _debito
	 where trx1_notrx   = _notrx;

	let _linea_aux = 0;

	foreach
	 select cod_aux,
	        sum(debito),
			sum(credito)
	   into _cod_auxiliar,
	        _debito2,
			_credito2
	   from tmp_asie2
	  where cuenta = _cuenta
	  group by 1
	  order by 1

		let _linea_aux = _linea_aux + 1;

		insert into cgltrx3(
		trx3_notrx,
		trx3_tipo,
		trx3_lineatrx2,
		trx3_linea,
		trx3_cuenta,
		trx3_auxiliar,
		trx3_debito,
		trx3_credito,
		trx3_actlzdo
		)
		values(
		_notrx,
		"01",
		_linea,
		_linea_aux,
		_cuenta,
		_cod_auxiliar,
		_debito2,
		_credito2,
		0
		);

	end foreach
	}

	return _costo,
		   _periodo,
		   _fecha,
		   _cuenta,
		   _debito,
		   _credito
		   with resume;

end foreach

drop table tmp_asie;
--drop table tmp_asie2;

end procedure