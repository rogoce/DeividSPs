-- Actualizar las compañias para los contratos bouquet

-- Creado    : 19/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac150;

create procedure sp_sac150() 
returning integer,
          char(50);

define _cod_contrato	char(5);
define _cod_cober_reas	char(3);
define _cod_coasegur	char(3);
define _aux_bouquet		char(5);
define _nombre_aux		char(50);

foreach
 select cod_contrato,
        cod_cober_reas
   into _cod_contrato,
        _cod_cober_reas
   from reacocob
  where bouquet = 1
  
	foreach
	 select cod_coasegur
	   into _cod_coasegur
	   from reacoase
      where cod_contrato   = _cod_contrato
        and cod_cober_reas = _cod_cober_reas

		select aux_bouquet,
		       nombre
		  into _aux_bouquet,
		       _nombre_aux
		  from emicoase
		 where cod_coasegur = _cod_coasegur;

		if _aux_bouquet is null then
			
			let _aux_bouquet = "BQ" || _cod_coasegur;

			update emicoase
			   set aux_bouquet  = _aux_bouquet
			 where cod_coasegur = _cod_coasegur;
			
			insert into cglterceros(
			ter_codigo,
			ter_descripcion,
			ter_contacto,
			ter_cedula,
			ter_telefono,
			ter_fax,
			ter_apartado,
			ter_observacion,
			ter_limites
			)
			values(
			_aux_bouquet,
			_nombre_aux,
			_nombre_aux,
			".",
			".",
			".",
			".",
			"BOUQUET COMPANIAS REASEGURADORAS",
			0.00
			);


		end if

	end foreach

end foreach 	

return 0, "Actualizacion Exitosa";

end procedure
