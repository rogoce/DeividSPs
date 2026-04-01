-- Procedimiento que crea los valores del auxiliar de comisiones por pagar
-- 
-- Creado     : 02/03/2006 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sac45;		

create procedure sp_sac45(a_cod_agente char(5))
returning integer,
          char(50);

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
	return _error, _error_desc;
end exception

-- Tabla de Terceros

let _codigo = "A" || a_cod_agente[2,5];

select count(*)
  into _cantidad
  from cglterceros
 where ter_codigo = _codigo;

if _cantidad = 0 then

	select nombre,
	       alias,
		   tipo_agente
	  into _nombre,
	       _alias,
		   _tipo_agente
	  from agtagent
	 where cod_agente = a_cod_agente;

	if _tipo_agente = "E" then
		let _nombre_aux = _alias;
	else
		let _nombre_aux = _nombre;
	end if

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
	"COMISIONES POR PAGAR",
	0.00
	);

end if

-- Auxiliar de Comisiones por Pagar

SELECT cuenta
  INTO _cuenta
  FROM parintcu
 WHERE cod_intercta = "CPCXPAUX";

select count(*)
  into _cantidad
  from cglauxiliar
 where aux_cuenta  = _cuenta
   and aux_tercero = _codigo;

if _cantidad = 0 then

	insert into cglauxiliar(
	aux_cuenta,
	aux_tercero,
	aux_pctreten,
	aux_saldoret,
	aux_corriente,
	aux_30dias,
	aux_60dias,
	aux_90dias,
	aux_120dias,
	aux_150dias,
	aux_ultimatrx,
	aux_ultimodcmto,
	aux_observacion
	)
	values(
	_cuenta,
	_codigo,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	"",
	"",
	""
	);

end if
end 
return 0, "Actualizacion Exitosa";
end procedure