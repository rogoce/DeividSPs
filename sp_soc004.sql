-- BUSCA REGISTROS EN CLICLIEN CUANDO SE CREA UN PROVEEDOR EN ORDEN DE PAGO

-- Creado    : 05/01/2010 - Autor: Amado Perez

drop procedure sp_soc004;

create procedure "informix".sp_soc004(as_ruc varchar(30)) 
 RETURNING char(10),
		   char(50),
		   char(1),
		   char(1),
		   char(50),
		   char(100),
		   char(10),
		   char(1),
		   char(17),
		   char(3),
		   smallint,
		   char(2),
		   smallint;

define 	_error			smallint;

define	_cod_cliente	char(10);
define  _nombre         char(50);
define	_tipo_persona	char(1);
define  _sexo   		char(1);
define  _correo			char(50);
define	_direccion		char(100);
define	_telefono		char(10);
define	_tipo_cuenta	char(1);
define  _cod_cuenta		char(17);
define	_cod_banco		char(3);
define	_tipo_pago		smallint;
define	_cod_ruta		char(2);
define  _pasaporte  	smallint;
define  _cnt            smallint;

--SET DEBUG FILE TO "sp_soc004.trc";
--TRACE ON ;


BEGIN

ON EXCEPTION SET _error
  RETURN _error,"","","","","","","","","",0,"",0;
END EXCEPTION


  SELECT   cod_cliente,
           nombre,
           tipo_persona,
           sexo,   
		   e_mail,
		   direccion_1,
		   telefono1,
		   tipo_cuenta,
		   cod_cuenta,
		   cod_banco,
		   tipo_pago,
		   cod_ruta,
		   pasaporte
    INTO   _cod_cliente,   
           _nombre,   
           _tipo_persona,   
           _sexo,   
		   _correo,
		   _direccion,
		   _telefono,
		   _tipo_cuenta,
		   _cod_cuenta,
		   _cod_banco,
		   _tipo_pago,
		   _cod_ruta,
		   _pasaporte
	 FROM  cliclien 
	WHERE  cedula = trim(as_ruc)  ;

END
RETURN trim(_cod_cliente),
	   _nombre,   
	   _tipo_persona, 
	   _sexo,   
	   _correo,
	   _direccion,
	   _telefono,
	   _tipo_cuenta,
	   _cod_cuenta,
	   _cod_banco,
	   _tipo_pago,
	   _cod_ruta,
	   _pasaporte;


end procedure;