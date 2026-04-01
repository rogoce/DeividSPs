-- Procedimiento para verificar las polizas de auto particulares
-- donde el tipo de auto no es 005


--drop procedure sp_par87;

create procedure "informix".sp_par87()

define _no_poliza		char(10);
define _no_unidad		char(5);
define _no_motor		char(30);
define _no_documento	char(10);
define _cod_marca		char(3);
define _cod_modelo		char(5);

define _nombre_marca	char(50);
define _nombre_modelo	char(50);

foreach
 select no_poliza,
        no_documento
   into	_no_poliza,
        _no_documento
   from emipomae
  where actualizado = 1
    and cod_ramo    = "002"
	and cod_subramo = "001"

	foreach
	 select no_unidad,
	        no_motor
	   into _no_unidad,
	        _no_motor
	   from emiauto
	  where no_poliza   = _no_poliza
	    and cod_tipoveh <> "005"

		select cod_marca,
		       cod_modelo,
			   no_chasis
		  into _cod_marca,
		       _cod_modelo,
			   _no_chasis
		  from emivehic
		 where no_motor = _no_motor;
			
		select nombre
		  into _nombre_marca
		  from emimarca
		 where cod_marca = _cod_marca;

		select nombre
		  into _nombre_modelo
		  from emimodel
		 where cod_modelo = _cod_modelo;

		let _nombre_marca = trim(_nombre_marca) || " " trim(_nombre_modelo);

		return _no_documento,
		       _no_unidad,
			   _nombre_marca,
			   _no_motor,
			   _no_chasis
			   with resume;

	end foreach

	
end foreach

end procedure
