-- Procedure que inserta la tabla endmoaut para tener toda la informacion para BO

-- Creado    : 17/05/2004 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis57;

create procedure sp_sis57(
a_no_poliza	char(10),
a_no_endoso char(5)
)

define _no_unidad	char(5);
define _cantidad	integer;
define _null		char(1);
define _no_endoso	char(5);
define _cod_ramo    char(3);

let _null = null;

select cod_ramo 
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_ramo = "002" then

	foreach 
	 select	no_unidad
	   into	_no_unidad
	   from	endeduni
	  where no_poliza = a_no_poliza
	    and no_endoso = a_no_endoso

		select count(*)
		  into _cantidad
		  from endmoaut
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   and no_unidad = _no_unidad;

		if _cantidad = 0 then

			-- Selecionar la Informacion de Emiauto

			insert into endmoaut(
			no_poliza,
			no_endoso,
			no_unidad,
			no_motor,
			cod_tipoveh,
			uso_auto,
			no_chasis,
			ano_tarifa
			)
			select
			no_poliza,
			a_no_endoso,
			no_unidad,
			no_motor,
			cod_tipoveh,
			uso_auto,
			_null,
			ano_tarifa
			 from emiauto
			where no_poliza = a_no_poliza
			  and no_unidad = _no_unidad;

			select count(*)
			  into _cantidad
			  from endmoaut
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso
			   and no_unidad = _no_unidad;

			if _cantidad = 0 then

				 select min(no_endoso)
				   into _no_endoso
				   from endmoaut
				  where no_poliza = a_no_poliza
				    and no_unidad = _no_unidad;

				-- Si no hay informacion en Emiauto, buscarla del primer Endmoaut
				
				if _no_endoso is not null then

					insert into endmoaut(
					no_poliza,
					no_endoso,
					no_unidad,
					no_motor,
					cod_tipoveh,
					uso_auto,
					no_chasis,
					ano_tarifa
					)
					select
					no_poliza,
					a_no_endoso,
					no_unidad,
					no_motor,
					cod_tipoveh,
					uso_auto,
					_null,
					ano_tarifa
					 from endmoaut
					where no_poliza = a_no_poliza
					  and no_endoso = _no_endoso
					  and no_unidad = _no_unidad;

				else

					-- Si no existe crear el registro con informacion generica

					insert into endmoaut(
					no_poliza,
					no_endoso,
					no_unidad,
					no_motor,
					cod_tipoveh,
					uso_auto,
					no_chasis,
					ano_tarifa
					)
					values(
					a_no_poliza,
					a_no_endoso,
					_no_unidad,
					"00000",
					"013",
					"P",
					_null,
					1900
					);
				end if
			end if
		end if
	end foreach
end if
end procedure