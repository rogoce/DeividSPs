-- Proceso que determina los periodos en los que se deben pagar las pólizas con periodos de pagos distintos a Mensual/Anual 
-- Creado    : 29/12/2016 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob391;
create procedure 'informix'.sp_cob391(a_no_documento char(18)) 
returning	smallint,
			varchar(100);

define _error_desc			varchar(100);
define _periodo				char(7);
define _cod_perpago			char(3);
define _cero				char(1);
define _cnt_perpago			smallint;
define _cnt_ciclos			smallint;
define _mes_pago			smallint;
define _ano_pago			smallint;
define _ciclo				smallint;
define _meses				smallint;
define _error_code			integer;
define _error_isam			integer;
define _fecha_primer_pago	date;
define _fecha_pago			date;

set isolation to dirty read;

--set debug file to 'sp_cob391.trc';
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc
 	return _error_code, _error_desc;
end exception

drop table if exists tmp_periodos;
create temp table tmp_periodos(
periodo		char(7)) with no log; 

foreach
	select cod_perpago,
		   fecha_primer_pago
	  into _cod_perpago,
		   _fecha_primer_pago
	  from emipomae
	 where no_documento = a_no_documento
	   and actualizado = 1
	 order by vigencia_inic

	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	let _ano_pago = year(_fecha_primer_pago);
	let _mes_pago = month(_fecha_primer_pago);
	let _cero = '';

	if _mes_pago < 10 then
		let _cero = '0';
	end if

	let _periodo = _ano_pago || '-' || trim(_cero) ||_mes_pago;

	insert into tmp_periodos(periodo)
	values(_periodo);

	if day(_fecha_primer_pago) > 28 then
		let _fecha_pago = mdy(_mes_pago,28,_ano_pago);
	else
		let _fecha_pago = _fecha_primer_pago;
	end if

	let _periodo = null;

	if _meses = 0 then
		let _cnt_ciclos = 1;
	else
		let _cnt_ciclos = (12/_meses) - 1;
	end if

	for _ciclo = 1 to _cnt_ciclos
		let _fecha_pago = _fecha_pago + _meses  units month;
		
		let _ano_pago = year(_fecha_pago);
		let _mes_pago = month(_fecha_pago);

		let _cero = '';

		if _mes_pago < 10 then
			let _cero = '0';
		end if

		let _periodo = _ano_pago || '-' ||  trim(_cero) ||_mes_pago;

		insert into tmp_periodos(periodo)
		values(_periodo);

		let _periodo = null;
	end for
end foreach

return 1,'Actualización Exitosa';

end
end procedure;