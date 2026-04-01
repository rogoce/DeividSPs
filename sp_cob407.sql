-- Procedimiento para polizas con 15 dias en suspension - Emipoliza (Correo al Cliente)
-- Creado: 21/11/2017 - Autor: Henry Giron
-- execute procedure sp_cob406(today)
drop procedure sp_cob406;
create procedure sp_cob406(a_fecha date default today)
returning	integer			as cod_error,
			varchar(100)	as mensaje;

define _mensaje				varchar(100);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_tipo			char(5);
define _cod_ramo			char(3);
define _excepcion			smallint;
define _ramo_sis			smallint;
define _pagada				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_proceso		date;

set isolation to dirty read;

--set debug file to "sp_cob406.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje;
end exception

let _fecha_inicio = '01/01/2014';

select date(valor_parametro)
  into _dia_notif_nulidad
  from inspaag
 where codigo_parametro = '_dia_noti_null_n';

foreach
	select distinct l.no_documento,
		   a_fecha_desde - e.fecha_primer_pago
	  into _no_documento,
		   _dias_sin_pago
	  from emiletra l, emipomae e
	 where e.no_poliza = l.no_poliza
	   and e.vigencia_inic >= _fecha_inicio
	   and a_fecha_desde - e.fecha_primer_pago = _dia_notif_nulidad
	   and l.pagada = 0
	   and l.no_letra = 1
	   and l.monto_letra <> 0
	   and l.monto_pag = 0

	-- Procedure que retorna todos los correos de un cliente
	call sp_sis163(_cod_cliente) returning _email_aseg;


	call sp_sis455a(_cod_tipo,_email_aseg,'','',_no_poliza,0,_no_documento,_cod_cliente,_exigible,0.00,0.00,_fecha_proceso) returning _error,_mensaje;

	if _error <> 0 then
		let _mensaje = _mensaje || ' Poliza: ' || trim(_no_documento);
		return _error,_mensaje;
	end if
