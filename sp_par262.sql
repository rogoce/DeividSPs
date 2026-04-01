-- Informaci¢n: Depuraci¢n de cliente  Agrupador para Presentar los datos en el Grid
-- Creado     : 23/10/2007 - Autor: Rub‚n Dar¡o Arn ez S nchez


DROP PROCEDURE sp_par262;

create procedure "informix".sp_par262()

returning CHAR(50),  -- 1. Nombre del usuario 
		  CHAR(3);   -- 2. Codigo de Agrupador 
		  
DEFINE _nombre         char(50);	-- 
DEFINE _cod_agrup      char(3);  	--  

-- let    _nom_  = "";

SET ISOLATION TO DIRTY READ;


-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
	foreach 
		 select nombre, 
				cod_agrupa         
		   into _nombre,
		        _cod_agrup
		   from clideagr
	  		 order by nombre
	  	  				 
				   	return  _nombre,	   		-- 1. Nombre completo del usuario
				   			_cod_agrup			-- 2. Codigo de Grupo
					  with resume;
			   
	end foreach;

 end procedure;
