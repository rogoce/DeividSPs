-- Procedimiento para verificar los saldos entre
-- Coaseguro Minoritario con Impuesto Vs sin Impuestos

drop procedure sp_par101;

create procedure "informix".sp_par101(a_fecha date)
returning char(20),
          dec(16,2),
          dec(16,2),
		  dec(16,2);

define _no_documento	char(20);
define _saldo1			dec(16,2);
define _saldo2			dec(16,2);

define _no_documento2	char(20);
define _no_recibo		char(10);
define _prima_bruta		dec(16,2);
define _prima_neta		dec(16,2);
define _prima_calc		dec(16,2);
define _porc_impuesto	dec(16,2);

create temp table tmp_versus(
	no_documento	char(20),
	saldo1			dec(16,2),
	saldo2 			dec(16,2)
	) with no log;


--call sp_par102("001", "001", a_fecha); -- Morosidad Coaseguro Minoritario con Impuestos
call sp_cob05("001", "001", a_fecha); -- Morosidad Produccion Directa con Impuestos

foreach
 select doc_poliza,
        sum(saldo)
   into _no_documento,
        _saldo1
   from tmp_moros
--  where incobrable = 0
  where cod_ramo = "017"
  group by doc_poliza

	insert into tmp_versus
	values(
	_no_documento,
	_saldo1,
	0.00
	);

end foreach

drop table tmp_moros;

--call sp_par103("001", "001", a_fecha); -- Morosidad Coaseguro Minoritario sin Impuestos
call sp_cob143("001", "001", a_fecha); -- Morosidad Produccion Directa sin Impuestos

foreach
 select doc_poliza,
        sum(saldo)
   into _no_documento,
        _saldo2
   from tmp_moros
--  where incobrable = 0
  where cod_ramo = "017"
  group by doc_poliza

	insert into tmp_versus
	values(
	_no_documento,
	0.00,
	_saldo2
	);

end foreach

drop table tmp_moros;

foreach
 select no_documento,
        sum(saldo1),
		sum(saldo2)
   into _no_documento,
        _saldo1,
		_saldo2
   from tmp_versus
--  where no_documento = "0196-1263-01"
  group by no_documento
	
	let _porc_impuesto = sp_par106(_no_documento);

	let _prima_neta = _saldo1 / _porc_impuesto;
	
--	let _prima_neta = 0.00;

	if _saldo2 <> _prima_neta then

--	if _saldo2 <> _saldo1 then

		call sp_par105(_no_documento);

		return _no_documento,
		       _saldo1,
			   _saldo2,
			   _prima_neta
			   with resume;

	end if

end foreach

drop table tmp_versus;

end procedure