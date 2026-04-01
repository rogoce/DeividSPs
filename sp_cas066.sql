-- Actualizacion de Registros Segun el Tipo de Gestion

-- Creado    : 08/05/2016 - Autor: Roman Gordon

-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.
-- execute procedure sp_cas066('052','','')
drop procedure sp_cas066;

create procedure sp_cas066(
a_cod_gestion		char(3),
a_cod_cliente		char(10),
a_no_poliza			char(10))
returning integer,varchar(100);

define _error_desc			varchar(100);
define _no_documento		char(20);
define _sus_gest_automatic	char(3);
define _monto_pagado		dec(16,2);
define _cnt_gestion			smallint;
define _pagada				smallint;
define _error				integer;

--set debug file to "sp_cas014bk.trc";
--trace on;

begin
set isolation to dirty read;

--return 0, 'Proceso Inactivo';

select count(*)
  into _cnt_gestion
  from cobcages
 where cod_gestion = a_cod_gestion
   and tipo_accion in (12,13);

if _cnt_gestion is null then
	let _cnt_gestion = 0;
end if

if _cnt_gestion = 0 then
	return 0,'La gestión no es del proceso de anulación';
end if

select valor_parametro
  into _sus_gest_automatic
  from inspaag
 where codigo_parametro = 'sus_gest_automatic';

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;

if a_cod_gestion = _sus_gest_automatic then --Suspensión de Anulación de Póliza
	delete from cobanula
	 where no_documento = _no_documento;
else
	if a_no_poliza not in ('1065676') then
		call sp_pro545(_no_documento) returning _error, _error_desc;
		call sp_pro544(_no_documento) returning _error,_error_desc;
		call sp_cob346a(_no_documento) returning _error,_error_desc;

		select sum(monto_pag)
		  into _monto_pagado
		  from emiletra
		 where no_poliza = a_no_poliza;

		if _monto_pagado is null then	
			let _monto_pagado = 0.00;
		end if

		if _monto_pagado > 0.00 then
			return 0,'La gestión no es del proceso de anulación';
		end if
	end if

	call sp_cob356c(_no_documento,a_cod_cliente,a_cod_gestion) returning _error, _error_desc;
end if

return _error, _error_desc;

end
end procedure;