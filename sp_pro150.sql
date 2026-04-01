-- Procedimiento que Retorna la Informacion de Cobros de los Clientes

-- Creado    : 30/04/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro150;

create procedure sp_pro150(a_cod_pagador CHAR(10))
returning char(10),		--_cod_pagador
		  char(100),	--_nombre,
	      char(100),	--_direccion,
	      char(10),		--_telefono1,
	      char(10),		--_telefono2,
	      char(10),		--_celular,
	      char(10),		--_fax,
	      char(50),		--_e_mail,
	      char(10),		--_telefono3,
	      char(20),		--_apartado,
	      char(30),		--_cedula
		  date;			-- fechaaniversario

define _nombre	          char(100);
define _direccion_cob	  char(100);
define _direccion	      char(100);
define _telefono1		  char(10);
define _telefono2		  char(10);
define _celular			  char(10);
define _telefono3		  char(10);
define _fax				  char(10);
define _e_mail			  char(50);
define _apartado		  char(20);
define _cedula			  char(30);
define _fecha_aniversario date;

set isolation to dirty read;

-- Falta incluir el campo de direccion de cobros
-- es un solo campo varchar de 100

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
	   fecha_aniversario
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
	   _fecha_aniversario
  from cliclien
 where cod_cliente = a_cod_pagador;

IF _direccion_cob IS NULL THEN
	LET _direccion_cob = '';
END IF

IF _cedula IS NULL THEN
	LET _cedula = '';
END IF

return a_cod_pagador,
	   _nombre,
	   _direccion_cob,
	   _telefono1,
	   _telefono2,
	   _celular,
	   _fax,
	   _e_mail,
	   _telefono3,
	   _apartado,
	   _cedula,
	   _fecha_aniversario;

end procedure