-- Depuracion de los codigos de tipos de autos de los modelos

create procedure sp_par346()
returning integer,
          char(50);
          
define _cod_modelo		char(5);
define _cod_tipoauto	char(3);

foreach
 select cod_modelo,
        cod_tipoauto
   into _cod_modelo,
        _cod_tipoauto
   from deivid_tmp:tmp_marcamodelos

	update emimodel
	   set cod_tipoauto = _cod_tipoauto
     where cod_modelo	= _cod_modelo;
	 
end foreach

return 0, "Actualizacion Exitosa";

end procedure