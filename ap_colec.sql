-- 
-- Genera Información para la poliza 1618-00018-01 12-07-2023
-- Creado    : 07/04/2022 - Autor: Amado Perez

DROP PROCEDURE ap_colect;
CREATE PROCEDURE ap_colect() 
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
          

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;



FOREACH
	select no_poliza, 
	       no_unidad,
           suma_asegurada,
           vigencia_inic,
           vigencia_final		   
	 into _no_poliza,
		  _no_unidad,
		  _suma_asegurada,
		  _vigencia_inic,
		  _vigencia_final
	 from emipouni
	where no_poliza = '1986770'
	  and no_unidad not in (select no_unidad
	 from emipocob where no_poliza = '1986770')	  
	   and no_unidad = '00095'
	order by no_unidad	


	select *
	  from emipocob		--coberturas(opcion Final)
	 where no_poliza = '1775263'
	   and no_unidad = _no_unidad
	  into temp prueba;

	update prueba
	   set no_poliza = '1986770',
	       date_added = '05/06/2023',
	       date_changed = '05/06/2023',
		   subir_bo = 0
	 where no_poliza   = '1775263';

	insert into emipocob
	select * from prueba
	 where no_poliza = '1986770';

	drop table prueba;
	      
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
        desc_limite1,
		desc_limite2,
		factor_vigencia
		)
    select no_poliza,
           '00000',
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
           desc_limite1,
		   desc_limite2,
		   factor_vigencia
      from emipocob
     where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;	  
	   
	let _error = sp_proe04(_no_poliza,_no_unidad,_suma_asegurada,'001'); -- Creación de reaseguro
	
	if _error = 0 then
		
			FOREACH
			 SELECT	cod_cober_reas
			   INTO	_cod_cober_reas
			   FROM	emifacon
			  WHERE	no_poliza = _no_poliza
				AND no_endoso = '00000'
				AND no_unidad = _no_unidad
			  GROUP BY no_unidad, cod_cober_reas
			  
				select count(*) 
				  into _cnt
				  from emireama
				 WHERE no_poliza = _no_poliza
				   AND no_unidad = _no_unidad
				   AND no_cambio = 0
				   AND cod_cober_reas = _cod_cober_reas;
				
				if _cnt is null then
					let _cnt = 0;
				end if
				
				if _cnt = 0 then
					INSERT INTO emireama(
					no_poliza,
					no_unidad,
					no_cambio,
					cod_cober_reas,
					vigencia_inic,
					vigencia_final
					)
					VALUES(
					_no_poliza, 
					_no_unidad,
					0,
					_cod_cober_reas,
					_vigencia_inic,
					_vigencia_final
					);
				end if
			END FOREACH
		
		let _cnt = 0;
	
		select count(*) 
		  into _cnt
		  from emireaco
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad
		   AND no_cambio = 0;

		if _cnt is null then
			let _cnt = 0;
		end if
		
		if _cnt = 0 then
			INSERT INTO emireaco(
			no_poliza,
			no_unidad,
			no_cambio,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima
			)
			SELECT 
			_no_poliza, 
			no_unidad,
			0,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima
			FROM emifacon
			WHERE no_poliza = _no_poliza
			  AND no_endoso = '00000'
			  and no_unidad = _no_unidad;
		end if 
	end if
	
	  
END FOREACH


return 0, "actualizacion exitosa";
END PROCEDURE	  