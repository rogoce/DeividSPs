-- Procedure que Crea el Historico de Asientos de Planilla

-- Creado    : 15/01/2005 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
--drop procedure sp_sac31;

create procedure sp_sac31() 
returning char(10),
	   	  char(50),
	      date,
	   	  char(2),   
	      char(25),		 
	      dec(16,2),		 
		  dec(16,2);

define _campo			char(255);
define _cod_empleado	char(10);
define _nombre			char(50);
define _fecha_char		char(8);
define _tipo_comp		char(2);
define _cuenta			char(25);
define _debito_char		char(10);
define _credito_char    char(10);
define _periodo			char(7);
define _cantidad		integer;

define _debito			dec(16,2);
define _credito 		dec(16,2);
define _fecha_date		date;


foreach 
 select campo
   into _campo
   from placampo

	let _cod_empleado = _campo[1,10];
	let _nombre       = _campo[11,60];
	let _fecha_char	  = _campo[61,68];
	let _tipo_comp    = _campo[69,70];
	let _cuenta		  = _campo[71,95];
	let _debito_char  = _campo[96,105];	
	let _credito_char = _campo[106,115];

	let _fecha_date   = mdy(_fecha_char[3,4], _fecha_char[1,2], _fecha_char[5,8]);
	let _debito       = _debito_char;
	let _credito      = _credito_char;

	return _cod_empleado,
		   _nombre,      
		   _fecha_date,		 
		   _tipo_comp,   
		   _cuenta,		 
		   _debito,		 
		   _credito
		   with resume;	 

end foreach

end procedure