-- Concurso roma 2017   
-- 
-- Creado    : 03/02/2017 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.


DROP procedure sp_web40;
CREATE procedure "informix".sp_web40()
RETURNING varchar(1);

BEGIN
	define v_cod_marca varchar(5);
	define v_cod_modelo varchar(5);
	define v_nombre_marca_d varchar(20);
	define v_nombre_marca_ancon varchar(20);
	define v_nombre_modelo_ancon varchar(20);
	define v_nombre_modelo_d varchar(20);
	define v_cod_modelo_ancon varchar(5);
	
	--SET DEBUG FILE TO "sp_web40.trc";
	--trace on;
	SET ISOLATION TO DIRTY READ;
	
	foreach
		select distinct(nombre_marca) 
		  into v_nombre_marca_d
		 from modelos_ducruet 
		order by nombre_marca
		
		foreach
			select cod_marca,
				   nombre
			  into v_cod_marca,
				   v_nombre_marca_ancon
			  from emimarca
			 where nombre = upper(v_nombre_marca_d)
			exit foreach;
		
		end foreach
		
		 update modelos_ducruet
			set cod_marca_ancon 	= v_cod_marca,
				nombre_marca_ancon 	= v_nombre_marca_ancon
		  where nombre_marca = v_nombre_marca_d;
	end foreach
	
	foreach
		select nombre_modelo, 
			   cod_marca_ancon
		  into v_nombre_modelo_d,
			   v_cod_marca
		from modelos_ducruet
	--   where cod_modelo_ancon is null
		order by nombre_modelo
		
		let v_cod_modelo_ancon = null;
		let v_nombre_modelo_ancon = null;
	
		foreach
			select cod_modelo,
				   nombre
			  into v_cod_modelo_ancon,
				   v_nombre_modelo_ancon
			  from emimodel
			 where nombre = upper(trim(v_nombre_modelo_d))
			   and cod_marca = v_cod_marca
			exit foreach;
		end foreach
		
		 update modelos_ducruet
			set cod_modelo_ancon 	= v_cod_modelo_ancon,
				nombre_modelo_ancon = v_nombre_modelo_ancon
		  where nombre_modelo = v_nombre_modelo_d
		    and cod_marca_ancon = v_cod_marca;
		  
	end foreach
	return '0'
	       with resume;
END
END PROCEDURE;