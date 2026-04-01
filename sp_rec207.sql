-- Procedure que Actualiza los valores de los modelos (Grande, Mediano, Pequeño)

-- Creado    : 03/07/2013 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_rec207;

create procedure "informix".sp_rec207() 
returning char(10),
		  char(50),
		  char(10),
		  char(50),
		  char(3);

define _no_reclamo	char(10);
define _cantidad	smallint;
define _tipo_recla	char(20);
define _marca		char(50);
define _modelo		char(50);
define _tamano		char(3);

define _cod_marca	char(10);
define _cod_modelo	char(10);
define _no_motor	char(50);

-- 12468 Registros

create temp table tmp_modelos(
cod_marca	char(10),
cod_modelo	char(10),
tamano		char(3)
) with no log;


foreach
 select ra_nu_reclamo,
        ra_tipo_reclamante,
		ra_marca,
		ra_modelo,
		ra_tamano
   into _no_reclamo,
        _tipo_recla,
		_marca,
		_modelo,
		_tamano
   from deivid_tmp:tmp_ra_db_reclamosauto
  where (ra_tamano[1,3] = "Gra" or 
         ra_tamano[1,3] = "Med" or 
         ra_tamano[1,3] = "Peq")
--	and ra_tipo_reclamante = "Tercero"

	if 	_tipo_recla = "Tercero" then
	
		select count(*)
		  into _cantidad
		  from recterce
		 where no_reclamo = _no_reclamo;

		if _cantidad = 1 then

			select cod_marca,
			       cod_modelo
			  into _cod_marca,
			       _cod_modelo
			  from recterce
			 where no_reclamo = _no_reclamo;


			insert into tmp_modelos
			values (_cod_marca, _cod_modelo, _tamano);

			{
			return _no_reclamo,
			       _tipo_recla,
				   _marca,
				   _modelo,
				   _tamano
			       with resume;
			}

		end if

	elif _tipo_recla = "Asegurado" then

			select no_motor
			  into _no_motor
			  from recrcmae
			 where no_reclamo = _no_reclamo;

			select cod_marca,
			       cod_modelo
			  into _cod_marca,
			       _cod_modelo
			  from emivehic
			 where no_motor = _no_motor;

			insert into tmp_modelos
			values (_cod_marca, _cod_modelo, _tamano);

			{
			return _no_reclamo,
			       _tipo_recla,
				   _marca,
				   _modelo,
				   _tamano
			       with resume;
			}

	end if

end foreach

foreach 
 select cod_marca,
        cod_modelo,
		tamano
   into _cod_marca,
        _cod_modelo,
		_tamano
   from tmp_modelos
  group by 1, 2, 3
  order by 1, 2  

	select nombre
	  into _marca
	  from emimarca
	 where cod_marca = _cod_marca;

	select nombre
	  into _modelo
	  from emimodel
	 where cod_modelo = _cod_modelo;

	return _cod_marca,
	       _marca,
		   _cod_modelo,
		   _modelo,
		   _tamano
		   with resume;

end foreach

drop table tmp_modelos;

return "0", "", "", "", "";

end procedure
