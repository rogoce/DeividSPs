drop procedure sp_che77;

create procedure sp_che77()
returning smallint,
          smallint,
		  char(50),
		  dec(16,2);

define _ramo		char(50);
define _ano			smallint;
define _mes			smallint;
define _no_reclamo	char(10);
define _monto		dec(16,2);
define _monto2		dec(16,2);
define _periodo		char(7);

define _nombre		char(50);
define _no_poliza	char(10);
define _cod_ramo	char(3);

define _porc_coas_otras		dec(16,2);

set isolation to dirty read;

create temp table tmp_cheque(
ano		smallint,
mes		smallint,
ramo	char(50),
monto	dec(16,2)
) with no log;

foreach
 select no_reclamo,
        monto,
		periodo
   into	_no_reclamo,
        _monto,
		_periodo
   from rectrmae
  where actualizado  = 1
    and periodo     >= "2006-07"
	and periodo     <= "2007-08"
	and cod_tipotran = "004"

	let _ano = _periodo[1,4];
	let _mes = _periodo[6,7];

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

   foreach
	select porc_partic_coas
	  into _porc_coas_otras
	  from reccoas
	 where no_reclamo   =  _no_reclamo
	   and cod_coasegur <> "036"

		let _monto2  = _monto / 100 * _porc_coas_otras;

		insert into tmp_cheque
		values (_ano, _mes, _nombre, _monto2);

	end foreach

end foreach

foreach
 select ano,
        mes,
		ramo,
		sum(monto)
   into _ano,
        _mes,
		_ramo,
		_monto
   from tmp_cheque
  group by 1, 2, 3
  order by 1, 2, 3

	return _ano,
	       _mes,
		   _ramo,
		   _monto
		   with resume;

end foreach

drop table tmp_cheque;

end procedure