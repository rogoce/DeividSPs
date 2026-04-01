-- Procedimiento que trae los clientes para programa CAS.

-- Creado    : 10/04/2003 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob106;

create procedure sp_cob106(a_cod_cliente CHAR(10))
returning char(10),
       	  char(100),
	      char(50),
	      char(50),
	      char(10),
	      char(10),
	      char(10),
	      char(10),
	      char(50),
	      char(10),
	      char(20),
		  char(3),
		  char(2),
		  char(2),
		  char(2),
		  char(5),
		  int,
		  int;

define _nombre	        char(100);
define _direccion_1		char(50);
define _direccion_2	    char(50);
define _direccion	    char(100);
define _telefono1		char(10);
define _telefono2		char(10);
define _celular			char(10);
define _telefono3		char(10);
define _fax				char(10);
define _e_mail			char(50);
define _apartado		char(20);
define _cedula			char(30);
define _code_pais		char(3);
define _code_provincia	char(2);
define _code_ciudad		char(2);
define _code_distrito	char(2);
define _code_correg		char(5);
define _dia_cobros1		Int;
define _dia_cobros2		Int;
set isolation to dirty read;

foreach
 select	direccion_1,
		direccion_2,
		telefono1,
		telefono2,
		telefono3,
		celular,
		fax,
		apartado,
		e_mail,
		code_pais,
		code_provincia,
		code_ciudad,
		code_distrito,
		code_correg,
		dia_cobros1,
		dia_cobros2
   into	_direccion_1,
		_direccion_2,
		_telefono1,
		_telefono2,
		_telefono3,
		_celular,
		_fax,
		_apartado,
		_e_mail,
		_code_pais,
		_code_provincia,
		_code_ciudad,
		_code_distrito,
		_code_correg,
		_dia_cobros1,
		_dia_cobros2
   from	cascliente
  where cod_cliente = a_cod_cliente

 select	nombre
   into	_nombre
   from	cliclien
  where	cod_cliente = a_cod_cliente;

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = '';
	END IF

	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = '';
	END IF

	Let _direccion = TRIM(_direccion_1) || ' ' || TRIM(_direccion_2);

	return a_cod_cliente,
	       _nombre,
		   _direccion_1,
		   _direccion_2,
		   _telefono1,
		   _telefono2,
		   _celular,
		   _fax,
		   _e_mail,
		   _telefono3,
		   _apartado,
		   _code_pais,
		   _code_provincia,
		   _code_ciudad,
		   _code_distrito,
		   _code_correg,
		   _dia_cobros1,
		   _dia_cobros2
		   with resume;
end foreach
end procedure
