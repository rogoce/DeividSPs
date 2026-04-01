-- Procedimiento que crea los valores del auxiliar de reaseguro por pagar
-- 
-- Creado     : 24/07/2007 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac65;		

create procedure "informix".sp_sac65(a_cod_coasegur char(3))
returning integer,
          char(50),
          char(5);

define _codigo		char(5);
define _nombre		char(50);
define _alias		char(50);
define _tipo_agente	char(1);
define _nombre_aux	char(50);
define _cuenta		char(25);
define _cantidad	smallint;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, "";
end exception

-- Tabla de Terceros

let _codigo = "RE" || a_cod_coasegur;

select count(*)
  into _cantidad
  from cglterceros
 where ter_codigo = _codigo;

if _cantidad = 0 then

	select nombre
	  into _nombre_aux
	  from emicoase
	 where cod_coasegur = a_cod_coasegur;

	insert into cglterceros(
	ter_codigo,
	ter_descripcion,
	ter_contacto,
	ter_cedula,
	ter_telefono,
	ter_fax,
	ter_apartado,
	ter_observacion,
	ter_limites
	)
	values(
	_codigo,
	_nombre_aux,
	_nombre_aux,
	".",
	".",
	".",
	".",
	"COMPANIAS REASEGURADORAS",
	0.00
	);

end if

end 

return 0, "Actualizacion Exitosa", _codigo;
 
end procedure