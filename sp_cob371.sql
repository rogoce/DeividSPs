-- Procedimiento que determina si el no_poliza de acuerdo a las letras pendientes
-- Creado    : 24/02/2015 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob371;
create procedure sp_cob371(a_no_remesa char(10))
returning	integer			as Cod_Error,
			varchar(100)	as Mensaje_Error;

define _error_desc		varchar(100);
define _no_poliza_ant	char(10);
define _no_poliza		char(10);
define _cargo_especial	dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _exigible		dec(16,2);
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);
define _monto_90		dec(16,2);
define _saldo			dec(16,2);
define _pronto_pago		smallint;
define _dia_hoy			smallint;
define _renglon			smallint;
define _dia				smallint;
define _error_isam		integer;
define _error			integer;
define _fecha_hoy		date;
define _fecha_sig		date;

set isolation to dirty read;

--set debug file to "sp_cob371.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

select tipo_remesa,
	   fecha
  into _tipo_remesa
	   _fecha_remesa
  from cobremae
 where no_remesa = a_no_remesa;

if tipo_remesa not in ('A','M','C','J','H','T','B','F') then
	return 0,'Verificación no Necesaria';
end if

foreach
	select doc_remesa,
		   no_poliza,
		   renglon
	  into _no_documento,
		   _no_poliza,
		   _renglon
	  from cobredet
	 where no_remesa = a_no_remesa
	   and d.tipo_mov in ('P','N','X')

	foreach
		select no_poliza
		  into _no_poliza_ant
		  from emiletra
		 where no_documento = _no_documento
		   and monto_pen > 0
		   and pagada = 0
		 order by fecha_vencimiento asc

		exit foreach;
	end foreach

	if _no_poliza_ant <> _no_poliza then
		update cobredet
		   set no_poliza = _no_poliza_ant
		 where no_remesa = a_no_remesa
		   and renglon = _renglon;
	end if
end foreach
end
end procedure;