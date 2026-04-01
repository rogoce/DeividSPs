-- Lista de Cambios de Usuarios
-- Creado    : 01/02/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.  

DROP PROCEDURE sp_seg002a;
create procedure "informix".sp_seg002a()
returning CHAR(8),   --_usuario,
		  CHAR(30),  --_descripcion
		  char(100), --_depto_name,												   
		  char(30);	 --_n_agencia	

DEFINE _usuario         char(8);  -- 1
DEFINE _descripcion     char(30); -- 2
DEFINE _n_agencia       char(30);
DEFINE _depto_name      char(100);
DEFINE _cia_depto       char(5);
DEFINE _codigo_agencia  char(3);

let    _n_agencia     = "";

SET ISOLATION TO DIRTY READ;

-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach
	 select descripcion,
	 		usuario,	        
			cia_depto,
			codigo_agencia
	   into _descripcion,
		   	_usuario,	        
			_cia_depto,
			_codigo_agencia
	   from insuser
	  where status = "I"     

	select  nombre
	  into  _depto_name
	  from  insdepto 
	  where cod_depto = _cia_depto;

	select  descripcion
	  into  _n_agencia
	  from  insagen
	  where codigo_agencia = _codigo_agencia;

	 return _usuario,
			_descripcion,
			_depto_name,
			_n_agencia	
	   with resume;
end foreach
		   
end procedure;
				 