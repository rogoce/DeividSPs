-- Procedimiento que trae los corredores de la poliza seleccionada.

-- Creado    : 9/04/2003 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob105;

create procedure sp_cob105(a_no_poliza  CHAR(10))
returning char(5),   --_codagente
       	  char(50),	 --nombre corredor
       	  char(50), --direccion1
       	  char(50), --direccion2
	      char(10),	 --tel1
	      char(10),	 --tel2
	      char(10),	 --celular
	      char(20),  --apartado
		  char(30),	 --ced/ruc
	      char(3),   --ejecutivo de cobros
	      char(50);  --email

define _cod_agente		char(5);
define _nombre_corredor	char(50);
define _direccion		char(100);
define _direccion_1		char(50);
define _direccion_2	    char(50);
define _telefono1		char(10);
define _telefono2		char(10);
define _celular			char(10);
define _apartado		char(20);
define _cedula			char(30);
define _ejecutiva		char(3);
define _email                   char(50);

set isolation to dirty read;

foreach
 select	cod_agente
   into	_cod_agente
   from	emipoagt
  where	no_poliza = a_no_poliza

 select nombre,
		direccion_1,
		direccion_2,
		telefono1,
		telefono2,
		celular,
		apartado,
		cedula,
		cod_cobrador,
		email_cobros
   into	_nombre_corredor,
		_direccion_1,
		_direccion_2,
		_telefono1,
		_telefono2,
		_celular,
		_apartado,
		_cedula,
		_ejecutiva,
		_email
   from	agtagent
  where	cod_agente = _cod_agente;

	IF _direccion_1 IS NULL THEN
		LET _direccion_1 = '';
	END IF

	IF _direccion_2 IS NULL THEN
		LET _direccion_2 = '';
	END IF

	IF _cedula IS NULL THEN
		LET _cedula = '';
	END IF

	return _cod_agente,
		   _nombre_corredor,
		   _direccion_1,
		   _direccion_2,
		   _telefono1,
		   _telefono2,
		   _celular,
		   _apartado,
		   _cedula,
		   _ejecutiva,
		   _email
		   with resume;
end foreach
end procedure
