-- Muestra la Direccion de los Clientes
-- 
-- Creado    : 07/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cas002;

create procedure sp_cas002()
returning char(100),
          smallint,
		  smallint,
		  char(50),
		  char(50),
		  char(10),
		  char(10),
		  char(10),
		  char(10),
		  char(10),
		  char(20),
		  char(50),
		  char(2),
		  char(50),
		  char(2),
		  char(50),
		  char(2),
		  char(50),
		  char(5),
		  char(50);

define _cod_cliente          char(10);
define _dia_cobros1          smallint;
define _dia_cobros2          smallint;
define _code_pais            char(3);
define _code_provincia       char(2);
define _code_ciudad          char(2);
define _code_distrito        char(2);
define _code_correg          char(5);
define _direccion_1          char(50);
define _direccion_2          char(50);
define _telefono1            char(10);
define _telefono2            char(10);
define _telefono3            char(10);
define _celular              char(10);
define _fax                  char(10);
define _apartado             char(20);
define _e_mail               char(50);
define _nombre_cliente       char(100);
define _nombre_provincia     char(50);
define _nombre_ciudad        char(50);
define _nombre_distrito      char(50);
define _nombre_correg        char(50);

--define _cod_cobrador         char(3)
--define _procesado            smallint
--define _fecha_ult_pro        date
--define _cod_grupo            char(5)

foreach
 select cod_cliente,
		dia_cobros1,   
		dia_cobros2,   
		code_pais,     
		code_provincia,
		code_ciudad,   
		code_distrito, 
		code_correg,   
		direccion_1,   
		direccion_2,   
		telefono1,     
		telefono2,    
		telefono3,     
		celular,       
		fax,           
		apartado,      
		e_mail        
   into _cod_cliente,   
		_dia_cobros1,   
		_dia_cobros2,   
		_code_pais,     
		_code_provincia,
		_code_ciudad,   
		_code_distrito, 
		_code_correg,   
		_direccion_1,   
		_direccion_2,   
		_telefono1,    
		_telefono2,     
		_telefono3,     
		_celular,       
		_fax,           
		_apartado,      
		_e_mail        
   from	cascliente

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select nombre
	  into _nombre_provincia
	  from genprov
	 where code_pais      = _code_pais
	   and code_provincia = _code_provincia;

	select nombre
	  into _nombre_ciudad
	  from genciud
	 where code_pais      = _code_pais
	   and code_provincia = _code_provincia
	   and code_ciudad    = _code_ciudad;

	select nombre
	  into _nombre_distrito
	  from gendtto
	 where code_pais      = _code_pais
	   and code_provincia = _code_provincia
	   and code_ciudad    = _code_ciudad
	   and code_distrito  = _code_distrito;

	select nombre
	  into _nombre_correg
	  from gencorr
	 where code_pais      = _code_pais
	   and code_provincia = _code_provincia
	   and code_ciudad    = _code_ciudad
	   and code_distrito  = _code_distrito
	   and code_correg    = _code_correg;

   return _nombre_cliente,   
		  _dia_cobros1,   
		  _dia_cobros2,   
		  _direccion_1,   
		  _direccion_2,   
		  _telefono1,     
		  _telefono2,     
		  _telefono3,     
		  _celular,       
		  _fax,           
		  _apartado,      
		  _e_mail,
		  _code_provincia,
		  _nombre_provincia,
		  _code_ciudad,
		  _nombre_ciudad,   
		  _code_distrito,
		  _nombre_distrito, 
		  _code_correg,
		  _nombre_correg   
		  with resume;

end foreach

end procedure