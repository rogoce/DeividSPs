-- 
-- Genera Información para la poliza 1619-00013-01 
-- Creado    : 07/04/2022 - Autor: Amado Perez

DROP PROCEDURE ap_crea_emifacon;
CREATE PROCEDURE ap_crea_emifacon(a_no_poliza char(10), a_no_endoso char(5)) 
RETURNING int, 
          char(25);

	DEFINE _no_poliza 			char(10);
	DEFINE _no_unidad           char(5);
	DEFINE _no_endoso			char(5);
	DEFINE _error               integer;
	DEFINE _suma_asegurada      dec(16,2);
 	DEFINE _vigencia_inic       date;
	DEFINE _vigencia_final      date;
	DEFINE _cnt		            smallint;
	DEFINE _cod_cober_reas      char(3);
	DEFINE _cod_ruta            char(5);
	DEFINE _cod_producto        char(5);
	DEFINE _cod_asegurado       char(10);
	DEFINE _desc_unidad         varchar(50);
	DEFINE _actualizado         smallint;


SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;
 
let _actualizado = 0; 
 
select actualizado 
  into _actualizado
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;   

if _actualizado = 1 then
	return 1, 'Error ya está actualizado';
end if   

FOREACH
	select no_poliza, 
	       no_unidad,
		   suma_asegurada	   
	 into _no_poliza,
		  _no_unidad,
		  _suma_asegurada
	 from endeduni
	where no_poliza = a_no_poliza
	  and no_endoso = a_no_endoso
	order by no_unidad	
	
    let _cnt = 0;
	
    select count(*)
	  into _cnt
	  from endedcob
	 where no_poliza = _no_poliza
	   and no_endoso = a_no_endoso
	   and no_unidad = _no_unidad;
	   
	if _cnt is null then   
		let _cnt = 0;
	end if	
	
	if _cnt = 0 then
		insert into endedcob (
			no_poliza,
			no_endoso,
			no_unidad,
			cod_cobertura,
			orden,
			tarifa,
			deducible,
			limite_1,
			limite_2,
			prima_anual,
			prima,
			descuento,
			recargo,
			prima_neta,
			date_added,
			date_changed,
			factor_vigencia,
			opcion,
			subir_bo
			)
		select  no_poliza,
			    no_endoso,
			    _no_unidad,
				cod_cobertura,
				orden,
				tarifa,
				deducible,
				limite_1,
				limite_2,
				prima_anual,
				prima,
				descuento,
				recargo,
				prima_neta,
				date_added,
				date_changed,
				factor_vigencia,
				opcion,
				subir_bo
		   from endedcob
		  where no_poliza = _no_poliza
			and no_endoso = a_no_endoso
			and no_unidad = '00002';
			
		let _error = sp_proe04b(_no_poliza, _no_unidad, _suma_asegurada, a_no_endoso); -- Creación de reaseguro
   end if


	
	
	--if _error = 0 then
		
	--end if
	
return _no_unidad, "actualizacion exitosa" with resume;	  
END FOREACH



END PROCEDURE	  