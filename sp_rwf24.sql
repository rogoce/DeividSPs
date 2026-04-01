-- Actualizacion de la tabla de Transaccion desde Ultimus Workflow
-- 
-- Creado    : 03/08/2004 - Autor: Amado Perez M. 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_rwf24;
CREATE PROCEDURE "informix".sp_rwf24(a_no_tranrec char(10), a_user_windows char(20), a_opcion char(1))
returning integer,
          char(26);

define _error   integer;
define _usuario CHAR(8);
define a_fecha_hora datetime hour to fraction(5);
define _actualizado smallint;

if a_no_tranrec = '2280128' then
  set debug file to "sp_rwf24.trc";
  trace on;
end if
let a_fecha_hora = Current;

set isolation to dirty read;

begin
on exception set _error
	return _error, "Error al Actualizar Transaccion";	
end exception

select actualizado
  into _actualizado
  from rectrmae
 where no_tranrec =  a_no_tranrec;

if _actualizado = 1 then
--	return 0, "Ya estaba actualizado";
end if


if a_opcion <> "6" then
	select usuario
	  into _usuario
	  from insuser
	 where windows_user = UPPER(a_user_windows);
end if

set lock mode to wait 60;

If a_opcion = "1" Then

	update rectrmae
	   set wf_apr_js    = _usuario,
	       wf_apr_js_fh = a_fecha_hora
	 where no_tranrec   = a_no_tranrec;

Elif a_opcion = "2" Then --Dulce

	update rectrmae
	   set wf_apr_j    = _usuario,
	       wf_apr_j_fh = a_fecha_hora
	 where no_tranrec  = a_no_tranrec;

Elif a_opcion = "3" Then -- Tecnico

	update rectrmae
	   set wf_apr_jt    = _usuario,
	       wf_apr_jt_fh = a_fecha_hora
	 where no_tranrec   = a_no_tranrec;

Elif a_opcion = "4" Then -- Gerente

	update rectrmae
	   set wf_apr_g    = _usuario,
	       wf_apr_g_fh = a_fecha_hora
	 where no_tranrec  = a_no_tranrec;

Elif a_opcion = "5" Then -- Tecnico2

	update rectrmae
	   set wf_apr_jt    = _usuario,
	       wf_apr_jt_fh = a_fecha_hora
	 where no_tranrec     = a_no_tranrec;

Elif a_opcion = "6" Then -- Ajustador

	update rectrmae
	   set wf_apr_js    = a_user_windows,
	       wf_apr_js_fh = a_fecha_hora
	 where no_tranrec   = a_no_tranrec;

End if

end

return 0, "Actualizacion Exitosa ... ";	

end procedure