-- Actualización de Gestiones de anulación cuando la póliza es rehabilitada luego de ser anulada
-- Creado    : 21/01/2016 - Autor: Román Gordón
-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.

drop procedure sp_cas068;

create procedure sp_cas068(a_no_poliza char(10))
returning integer,varchar(100);

define _error_desc		varchar(100);
define _no_documento	char(20);
define _cod_campana		char(10);
define _cod_cliente		char(10);
define _cod_gestion		char(3);
define _anula			char(3);
define _estatus_poliza	smallint;
define _cnt_existe		smallint;
define _error_isam		integer;
define _error			integer;

--set debug file to "sp_cas068.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
 	return _error, 'Poliza: ' || trim(_no_documento) || ' Error: ' || _error_desc;
end exception

set isolation to dirty read;

--return 0, 'Proceso Inactivo';

select no_documento,
	   estatus_poliza
  into _no_documento,
	   _estatus_poliza
  from emipomae
 where no_poliza = a_no_poliza;

if _estatus_poliza <> 4 then
	return 0,'Actualización no necesaria';
end if

select count(*)
  into _cnt_existe
  from caspoliza p, cascampana c
 where c.cod_campana = p.cod_campana
   and p.no_documento = _no_documento
   and c.tipo_campana = 3;

if _cnt_existe is null then
	let _cnt_existe = 0;
end if

if _cnt_existe = 0 then
	return 0,'Actualización no necesaria';
end if

foreach
	select p.cod_campana,
		   p.cod_cliente
	  into _cod_campana,
		   _cod_cliente
	  from caspoliza p, cascampana c
	 where c.cod_campana = p.cod_campana
	   and p.no_documento = _no_documento
	   and c.tipo_campana = 3

	select cod_gestion
	  into _cod_gestion
	  from cascliente
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente;

	if _cod_gestion is null or _cod_gestion = '' then
		continue foreach;
	end if

	select anula
	  into _anula
	  from cobcages
	 where cod_gestion = _cod_gestion;

	if _anula is null or _anula = '' then
		continue foreach;
	end if
	
	delete from caspoliza
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente
	   and no_documento = _no_documento;

	delete from cascliente
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente;
end foreach

return 0,'Actualización Exitosa';

end
end procedure;