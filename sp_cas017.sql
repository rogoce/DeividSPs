-- Call Center - Historico de Direcciones
-- 
-- Creado    : 13/05/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 13/05/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas017;

create procedure sp_cas017(a_cod_pagador char(10))
returning date,
       	  char(2),
	   	  char(2),
	      char(2),
	      char(50),
	      char(200),
	      char(10),
	      char(10),
	      char(10),
	      char(10),
	      char(10),
	      char(20),
	      char(50),
	      char(50),
		  char(8);

define _fecha			date;
define _code_pais		char(3);
define _code_provincia	char(2);
define _code_ciudad		char(2);
define _code_distrito	char(2);
define _code_correg		char(5);
define _direccion_cob	char(200);
define _telefono1		char(10);
define _telefono2		char(10);	
define _telefono3		char(10);
define _celular			char(10);
define _fax				char(10);
define _apartado		char(20);
define _e_mail			char(50);
define _contacto		char(50);
define _nombre_corr		char(50);
define _user_added		char(8);

set isolation to dirty read;

foreach
 select fecha,
        code_pais,
		code_provincia,
		code_ciudad,
		code_distrito,
		code_correg,
		direccion_cob,
		telefono1,
		telefono2,
		telefono3,
		celular,
		fax,
		apartado,
		e_mail,
		contacto,
		user_added
   into _fecha,
        _code_pais,
		_code_provincia,
		_code_ciudad,
		_code_distrito,
		_code_correg,
		_direccion_cob,
		_telefono1,
		_telefono2,
		_telefono3,
		_celular,
		_fax,
		_apartado,
		_e_mail,
		_contacto,
		_user_added
   from cobcacam
  where cod_cliente = a_cod_pagador
  order by fecha desc

	select nombre
	  into _nombre_corr
	  from gencorr
	 where code_pais      = _code_pais
	   and code_provincia = _code_provincia
	   and code_ciudad    = _code_ciudad
	   and code_distrito  = _code_distrito
	   and code_correg    = _code_correg;

	return _fecha,
		   _code_provincia,
		   _code_ciudad,
		   _code_distrito,
		   _nombre_corr,
		   _direccion_cob,
		   _telefono1,
		   _telefono2,
		   _telefono3,
		   _celular,
		   _fax,
		   _apartado,
		   _e_mail,
		   _contacto,
		   _user_added
		   with resume;

end foreach

end procedure
