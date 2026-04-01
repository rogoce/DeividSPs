-- Procedimiento que Retorna la Informacion de Cobros de los Clientes

-- Creado    : 30/04/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas012;

create procedure sp_cas012(a_cod_pagador CHAR(10))
returning char(100),	--_nombre,
	      char(200),	--_direccion,
	      char(10),		--_telefono1,
	      char(10),		--_telefono2,
	      char(10),		--_celular,
	      char(10),		--_fax,
	      char(50),		--_e_mail,
	      char(10),		--_telefono3,
	      char(20),		--_apartado,
	      char(30),		--_cedula
		  char(2),		-- ciudad
		  char(2),		-- distrito
		  char(5),		-- area
		  char(3),		-- pais
		  char(2),		-- prov
		  char(50),		-- contacto
		  date;			-- fecha_aniversario

define _direccion_cob	  char(200);
define _direccion	      char(100);
define _nombre	          char(100);
define _contacto	      char(50);
define _e_mail			  char(50);
define _cedula			  char(30);
define _apartado		  char(20);
define _telefono1		  char(10);
define _telefono2		  char(10);
define _celular			  char(10);
define _telefono3		  char(10);
define _fax				  char(10);
define _code_correg		  char(5);
define _cod_estafeta	  char(4);
define _code_pais         char(3);
define _code_provincia	  char(2);
define _code_ciudad		  char(2);
define _code_distrito	  char(2);
define _fecha_aniversario date;

set isolation to dirty read;


select nombre,
       cedula,
       direccion_cob,
       telefono1,
       telefono2,
       telefono3,
       celular,
       fax,
       apartado,
       e_mail,
       code_ciudad,
       code_distrito,
       code_correg,
       code_pais,
       code_provincia,
       contacto,
	   fecha_aniversario,
	   cod_estafeta
  into _nombre,
       _cedula,
       _direccion_cob,
       _telefono1,
       _telefono2,
       _telefono3,
       _celular,
       _fax,
       _apartado,
       _e_mail,
       _code_ciudad,
       _code_distrito,
       _code_correg,
       _code_pais,
       _code_provincia,
       _contacto,
	   _fecha_aniversario,
	   _cod_estafeta
  from cliclien
 where cod_cliente = a_cod_pagador;

if _direccion_cob is null then
	let _direccion_cob = '';	
end if

if _cedula is null then
	let _cedula = '';
end if

if _cod_estafeta is null then
	let _cod_estafeta = '';
end if

return _nombre,
	   _direccion_cob,
	   _telefono1,
	   _telefono2,
	   _celular,
	   _fax,
	   _e_mail,
	   _telefono3,
	   _apartado,
	   _cedula,
	   _code_ciudad,
	   _code_distrito,
	   _code_correg,
	   _code_pais,
	   _code_provincia,
	   _contacto,
	   _fecha_aniversario;
end procedure;