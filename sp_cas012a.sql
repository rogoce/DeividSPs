-- Procedimiento que Retorna la Informacion de Cobros de los Clientes

-- Creado    : 30/04/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cas012a;

create procedure sp_cas012a(a_cod_pagador CHAR(10))
returning char(50),		--_direccion1,
		  char(50),		--_direccion2,
		  char(200),	--_direccion cobros,
	      char(10),		--_telefono1,
	      char(10),		--_telefono2,
	      char(10),		--_celular,
	      char(10),		--_fax,
	      char(50),		--_e_mail,
	      char(10),		--_telefono3,
	      char(20),		--_apartado,
	      char(30);		--_cedula

define _direccion_cob	char(200);
define _direccion1	    char(50);
define _direccion2	    char(50);
define _telefono1		char(10);
define _telefono2		char(10);
define _celular			char(10);
define _telefono3		char(10);
define _fax				char(10);
define _e_mail			char(50);
define _apartado		char(20);
define _cedula			char(30);

set isolation to dirty read;

select cedula,
       direccion_cob,
	   direccion_1,
	   direccion_2,
       telefono1,
       telefono2,
       telefono3,
       celular,
       fax,
       apartado,
       e_mail
  into _cedula,
       _direccion_cob,
	   _direccion1,
	   _direccion2,
       _telefono1,
       _telefono2,
       _telefono3,
       _celular,
       _fax,
       _apartado,
       _e_mail
  from cliclien
 where cod_cliente = a_cod_pagador;

IF _direccion_cob IS NULL THEN
	LET _direccion_cob = '';
END IF

IF _cedula IS NULL THEN
	LET _cedula = '';
END IF

return _direccion1,
	   _direccion2,
	   _direccion_cob,
	   _telefono1,
	   _telefono2,
	   _celular,
	   _fax,
	   _e_mail,
	   _telefono3,
	   _apartado,
	   _cedula;

end procedure