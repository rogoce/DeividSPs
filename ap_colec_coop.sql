-- 
-- Genera Información para la poliza 1618-00018-01 12-07-2023
-- Creado    : 07/04/2022 - Autor: Amado Perez

DROP PROCEDURE ap_colect_coop;
CREATE PROCEDURE ap_colect_coop() 
RETURNING int, 
          char(100);

	DEFINE _no_poliza 			char(10);
	DEFINE _no_unidad           char(5);
	DEFINE _no_endoso			char(5);
	DEFINE _error               integer;
	DEFINE _suma_asegurada      dec(16,2);
 	DEFINE _vigencia_inic       date;
	DEFINE _vigencia_final      date;
	DEFINE _cnt		            smallint;
	DEFINE _cod_cober_reas      char(3);
	DEFINE _cod_producto        char(3);
	DEFINE _borra_cob           smallint;
    define _error_cod	        integer;
    define _error_isam	        integer;
    define _error_desc	        char(100);
         

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;
 
BEGIN WORK;

begin 
on exception set _error_cod, _error_isam, _error_desc
    rollback work;
	return _error_cod, _error_desc;
end exception

FOREACH
	select no_poliza, 
	       no_unidad,
           suma_asegurada,
           vigencia_inic,
           vigencia_final,
           cod_producto		   
	 into _no_poliza,
		  _no_unidad,
		  _suma_asegurada,
		  _vigencia_inic,
		  _vigencia_final,
		  _cod_producto
	 from emipouni
	where no_poliza = '2320231'
	  and no_unidad in (select no_unidad
	 from emipocob where no_poliza = '2320231')	  
--	  and no_unidad = '00803'
	order by no_unidad	
	
	let _borra_cob = 0;
	
	select borra_cob
	  into _borra_cob
	  from deivid_tmp:coop_borracob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and procesado = 0;
	   
	if _borra_cob is null then
		let _borra_cob = 0;
    end if	
	
	if _borra_cob = 1 then
		delete from emipocob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura in (
		   select cod_cobertura from prdcober where nombre like '%INCAPACI%');
		   
		update deivid_tmp:coop_borracob
           set procesado = 1
         where no_poliza = _no_poliza
	       and no_unidad = _no_unidad;				   
    elif _borra_cob = 2 then
		delete from emipocob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura in (
           select cod_cobertura from prdcober
			where nombre like '%MUERTE%ACC%'
			or nombre like '%INCAPACI%'
			or nombre like '%COBERT%CANCER%');

		update deivid_tmp:coop_borracob
           set procesado = 1
         where no_poliza = _no_poliza
	       and no_unidad = _no_unidad;
	end if
	
	if _borra_cob <> 0 then
	
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
    end if	
END FOREACH	
	
FOREACH
	select no_poliza, 
	       no_unidad,
           suma_asegurada,
           vigencia_inic,
           vigencia_final,
           cod_producto		   
	 into _no_poliza,
		  _no_unidad,
		  _suma_asegurada,
		  _vigencia_inic,
		  _vigencia_final,
		  _cod_producto
	 from emipouni
	where no_poliza = '2320231'
	  and no_unidad not in (select no_unidad
	 from emipocob where no_poliza = '2320231')	  
	 -- and no_unidad = '00216'
	order by no_unidad	
	
	let _borra_cob = 0;
	
	select borra_cob
	  into _borra_cob
	  from deivid_tmp:coop_borracob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and procesado = 0;
	   
	if _borra_cob is null then
		let _borra_cob = 0;
    end if		

	select *
	  from emipocob		--coberturas(opcion Final)
	 where no_poliza = '1917194'
	   and no_unidad = _no_unidad
	  into temp prueba;

	update prueba
	   set no_poliza = '2320231',
	       date_added = today,
	       date_changed = today,
		   subir_bo = 0
	 where no_poliza   = '1917194';
	 
	if _borra_cob = 1 then
		delete from prueba
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura in (
		   select cod_cobertura from prdcober where nombre like '%INCAPACI%');
		   
		update deivid_tmp:coop_borracob
           set procesado = 1
         where no_poliza = _no_poliza
	       and no_unidad = _no_unidad;		   
    elif _borra_cob = 2 then
		delete from prueba
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura in (
           select cod_cobertura from prdcober
			where nombre like '%MUERTE%ACC%'
			or nombre like '%INCAPACI%'
			or nombre like '%COBERT%CANCER%');

		update deivid_tmp:coop_borracob
           set procesado = 1
         where no_poliza = _no_poliza
	       and no_unidad = _no_unidad;
	end if
		
	 
	insert into emipocob
	select * from prueba
	 where no_poliza = '2320231';

	drop table prueba;
	      
{	insert into endedcob (
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
}	   
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

END
commit work;
return 0, "actualizacion exitosa";
END PROCEDURE	  