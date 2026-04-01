-- Procedimiento que crea el tercero desde la tabla de clientes para la cuenta de gastos

-- Creado    : 18/01/2012 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sac224;

create procedure "informix".sp_sac224(_cod_cliente char(10), _ter_codigo char(5))
returning char(5);

define _nombre_cliente	char(100);
define _cedula			char(50);
define _apartado		char(20);
define _telefono1		char(15);
define _fax				char(15);
define _no_registro		char(5);

select nombre,
       cedula,
	   telefono1,
	   fax,
	   apartado
  into _nombre_cliente,
       _cedula,
	   _telefono1,
	   _fax,
	   _apartado
  from cliclien
 where cod_cliente = _cod_cliente;


	insert into cglterceros(
	ter_codigo,
	ter_descripcion,
	ter_contacto,
	ter_cedula,
	ter_telefono,
	ter_fax,
	ter_apartado,
	ter_observacion,
	ter_limites,
	ter_codcliente
	)
	values(
	_ter_codigo,
	_nombre_cliente,
	".",
	_cedula,
	_telefono1,
	_fax,
	_apartado,
	"AUXILIAR PARA LA CUENTA DE GASTOS",
	0.00,
	_cod_cliente
	);


return _ter_codigo;

end procedure