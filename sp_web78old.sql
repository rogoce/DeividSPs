CREATE PROCEDURE "informix".sp_web78()
 RETURNING integer 		as idmodelo,
           integer 		as idmarca,
		   integer 		as idmarcanew,
		   varchar(50)  as nombremarca, 
		   varchar(50) 	as nombre; 
		   			  		    
DEFINE _cod_marca 		 integer;
DEFINE _cod_marca_new    integer;
DEFINE _cod_modelo 		 integer;
DEFINE _nombre_modelo	 varchar(50);
DEFINE _nombre_marca	 varchar(50);
DEFINE _nombre_marca_ant varchar(50);

foreach
	select cod_marca,  
		  cod_modelo, 
		  trim(upper(nombre_modelo)),
		  trim(upper(nombre_marca))
	 into _cod_marca,
	      _cod_modelo,
		  _nombre_modelo,
		  _nombre_marca
	 from modelos_ducruet
	 where cod_modelo_ancon <> ''
	 order by nombre_marca, nombre_modelo asc
	
	if _cod_marca = '399' then
		let _cod_marca_new = 1 ;
	else
		if _nombre_marca <> _nombre_marca_ant then
			let _cod_marca_new = _cod_marca_new + 1;
		end if
	end if
		let _nombre_marca_ant = _nombre_marca;
	RETURN  _cod_modelo,
			_cod_marca,
			_cod_marca_new,
			_nombre_marca,
			_nombre_modelo
			WITH RESUME;
end foreach

END PROCEDURE 
                                                                                                                                                                                      
