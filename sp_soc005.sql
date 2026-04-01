-- BUSCA REGISTROS EN CLICLIEN CUANDO SE CREA UN PROVEEDOR EN ORDEN DE PAGO

-- Creado    : 05/01/2010 - Autor: Amado Perez

drop procedure sp_soc005;

create procedure "informix".sp_soc005(a_cliente char(10)) 
 RETURNING int;

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
define  _cedula         char(30);
define  _ced_provincia  char(2);
define  _ced_inicial    char(2);
define  _ced_tomo       char(7);
define  _ced_folio      char(7);
define  _ced_asiento    char(7);


--SET DEBUG FILE TO "sp_soc005.trc";
--TRACE ON ;


BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION


  SELECT   cedula,
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
		   pasaporte,
		   ced_provincia,
		   ced_inicial,  
		   ced_tomo,     
		   ced_folio,    
		   ced_asiento  
    INTO   _cedula,   
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
		   _pasaporte,
		   _ced_provincia,
		   _ced_inicial,  
		   _ced_tomo,     
		   _ced_folio,    
		   _ced_asiento  
	 FROM  cliclien 
	WHERE  cod_cliente = trim(a_cliente)  ;

   UPDATE  cheprove
      SET  cedula	     = _cedula,
           ced_provincia = _ced_provincia,
           ced_inicial 	 = _ced_inicial,  
           ced_tomo   	 = _ced_tomo,   
           ced_folio     = _ced_folio,    
           ced_asiento   = _ced_asiento,  
           correo		 = _correo,
		   direccion	 = _direccion,
		   telefono		 = _telefono,
		   tipo_cuenta	 = _tipo_cuenta,
		   cod_cuenta	 = _cod_cuenta,
		   cod_banco	 = _cod_banco,
		   tipo_pago	 = _tipo_pago,
		   cod_ruta		 = _cod_ruta,
		   pasaporte     = _pasaporte
	WHERE  cod_cliente = a_cliente;


END
RETURN 0;


end procedure;