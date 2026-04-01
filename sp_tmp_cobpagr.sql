-- Generacion de la información de la remesa actualizada de General Representative para generar el archivo de Excel que se les envía
-- creado por :    Roman Gordon	10/04/2013
-- sis v.2.0 - deivid, s.a.

drop procedure sp_tmp_cobpagr;

create procedure "informix".sp_tmp_cobpagr()
returning	integer,
            char(50);				

define _cliente				char(100);
define _error_desc			char(50);
define _no_documento		char(21);
define _no_recibo_agt		char(20);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _numero				char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _ano_char			char(4);
define _mes_char			char(2);
define _monto_cobrado		dec(16,2);
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _monto_30			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _saldo				dec(16,2);
define _cnt_cobpaex			smallint;
define _weekday				smallint;
define _error_isam			integer;
define _secuencia			integer;
define _error				integer;
define _fecha_apertura		date;
define _fecha_corte			date;
define _fecha_pago			date;
define _fecha				date;
define _fec_apertura		date;

set isolation to dirty read;
--set debug file to "sp_cob326.trc";
--trace on;

--return 0,'';

foreach
	select numero,
		   no_documento,
		   referencia
	  into _cnt_cobpaex,
		   _no_documento,
		   _cliente
	  from tmp_cobpagr

	update cobpagr
	   set no_recibo_agt = _cliente
	 where secuencia = _cnt_cobpaex
	   and no_documento = _no_documento;
end foreach
return 0,'';
end procedure