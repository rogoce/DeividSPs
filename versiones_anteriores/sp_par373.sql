-- Busca la ponderacion del cliente
-- Creado: 31/05/2020 - Autor: Henry Giron
--
drop procedure sp_par373;
create procedure sp_par373(a_cliente char(10))
returning	char(2)  as pep ,
            char(50) as ocupacion,	
            char(50) as profesion,				
            char(50) as nacionalidad,	
            char(50) as producto,	
            char(50) as actividad,	
			char(50) as canal,	
            char(50) as riesgo;
			

define _cod_pep               integer;
define _cod_ocupacion         char(5);
define _cod_profesion         integer;
define _cod_producto          char(5);
define _cod_actividad         char(3);	
define _cod_canal             integer;
define _cod_riesgo            dec(16,2);
define _nombre_pep            char(2);	
define _nombre_ocupacion      char(50);	 
define _nombre_profesion      char(50);
define _nombre_nacionalidad   char(50);
define _nombre_producto       char(50);
define _nombre_actividad      char(50);
define _nombre_canal          char(50);
define _nombre_riesgo         char(50);



set isolation to dirty read;

--set debug file to "sp_par370.trc";
--trace on;

begin


foreach
	Select cod_pep,
		   cod_ocupacion,
		   cod_profesion,
		   nacionalidad ,
		   cod_producto,
		   cod_actividad,
		   cod_canal,
		   nvl(valor_ponderacion,0)
	  into _cod_pep,
		   _cod_ocupacion,
		   _cod_profesion,
		   _nombre_nacionalidad,
		   _cod_producto,
		   _cod_actividad,
		   _cod_canal,
		   _cod_riesgo
	  from ponderacion
	 where cod_cliente = a_cliente 
	 
	
	 select trim(nombre)
	   into _nombre_pep
	   from clipep
	  where cod_pep = _cod_pep;		
		
	 select trim(nombre)
	   into _nombre_ocupacion
	   from cliocupa
	  where cod_ocupacion = _cod_ocupacion;	

	 select trim(nombre)
	   into _nombre_profesion
	   from cliprofesion
	  where cod_profesion = _cod_profesion;	

	 select trim(nombre)
	   into _nombre_producto
	   from cliproducto
	  where cod_producto  = _cod_producto;
	  
	 select trim(nombre)
	   into _nombre_actividad
	   from cliactiv
	  where cod_actividad  = _cod_actividad;	 

	 select trim(nombre)
	   into _nombre_canal
	   from clicanal
	  where cod_canal = _cod_canal;	

      select replace(trim(nombre),'RIESGO','') 
	   into _nombre_riesgo
	   from cliriesgo	  
	  where _cod_riesgo between minimo and maximo;	
	  
	  
	return _nombre_pep,
		   _nombre_ocupacion,
		   _nombre_profesion,
		   _nombre_nacionalidad,
		   _nombre_producto,
		   _nombre_actividad,
		   _nombre_canal,
		   _nombre_riesgo;
end foreach



end
end procedure;