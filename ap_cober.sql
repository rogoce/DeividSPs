-- Eco Integracion
-- Genera Información para la tabla Tbl_PolizasCoberturas 
-- Creado    : 28/04/2021 - Autor: Amado Perez

DROP PROCEDURE ap_cober;
CREATE PROCEDURE ap_cober() 
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

{FOREACH
	select distinct no_poliza, 
	       no_endoso,
	       no_unidad  
	 into _no_poliza,
	      _no_endoso,
		  _no_unidad
	 from endeduni
	where no_poliza = '1587650'
	  and no_endoso = '00000'
	  and no_unidad not in (select distinct no_unidad
	 from endedcob where no_poliza = '1587650'
	  and no_endoso = '00000')
	order by no_unidad	
	      
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
    select '1587650',
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
		   '29/04/2021',	
		   '29/04/2021',	
           desc_limite1,
		   desc_limite2,
		   factor_vigencia
      from emipocob
     where no_poliza = '1456858'
	   and no_unidad = _no_unidad;	  
	   
	  
END FOREACH
}
{FOREACH
	select distinct no_poliza, 
	       no_endoso,
	       no_unidad  
	 into _no_poliza,
	      _no_endoso,
		  _no_unidad
	 from endeduni
	where no_poliza = '1587650'
	 and no_endoso = '00000'
	 and no_unidad not in (select distinct no_unidad
	 from emipocob where no_poliza = '1587650')
	 order by no_unidad	
	      
	insert into emipocob (
		no_poliza,
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
		desc_limite1,
		desc_limite2,
		prima_vida,
		prima_vida_orig     
		)
    select '1587650',
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
		   '29/04/2021',	
		   '29/04/2021',	
 		   factor_vigencia,
           desc_limite1,
		   desc_limite2,
		   prima_vida,
		   prima_vida_orig     
      from emipocob
     where no_poliza = '1456858'
	   and no_unidad = _no_unidad;	  
END FOREACH
}

FOREACH
	select distinct no_poliza, 
	       no_unidad,
           suma_asegurada,
		   vigencia_inic,
		   vigencia_final
	 into _no_poliza,
		  _no_unidad,
		  _suma_asegurada,
		  _vigencia_inic,
		  _vigencia_final		  
	 from endeduni
	where no_poliza = '1587650'
	 and no_endoso = '00000'
	  and no_unidad not in (select distinct no_unidad
	 from emifacon where no_poliza = '1587650'
	  and no_endoso = '00000')
	 order by no_unidad	
	 
	let _error = sp_proe04(_no_poliza,_no_unidad,_suma_asegurada,'001');
	
	let _cnt = 0;
	
	if _error = 0 then
		
			FOREACH
			 SELECT	cod_cober_reas
			   INTO	_cod_cober_reas
			   FROM	emifacon
			  WHERE	no_poliza = '1587650'
				AND no_endoso = '00000'
				AND no_unidad = _no_unidad
			  GROUP BY no_unidad, cod_cober_reas
			  
				select count(*) 
				  into _cnt
				  from emireama
				 WHERE no_poliza = '1587650'
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
					'1587650', 
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
		 WHERE	no_poliza = '1587650'
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
			'1587650', 
			no_unidad,
			0,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima
			FROM emifacon
			WHERE no_poliza = '1587650'
			  AND no_endoso = '00000'
			  and no_unidad = _no_unidad;
		end if 
	end if
	      
END FOREACH

return 0, "actualizacion exitosa";
END PROCEDURE	  