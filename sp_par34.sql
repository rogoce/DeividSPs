-- Verificacion del Reaseguro por Unidad

drop procedure sp_par34;

create procedure sp_par34()
returning char(20),
		  char(10),
		  char(5),
		  char(100),
		  dec(16,6);
		  	
define _no_poliza			char(10);
define _no_unidad			char(5);
define _cantidad			integer;
define _no_documento		char(20);
define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_cober_reas		char(3);
define _no_cambio      		smallint;
define _no_endoso			char(5);
define _orden				smallint;
define _porc_partic_suma	dec(16,6);
define _porc_partic_prima	dec(16,6);
define _porc_partic_suma_2	dec(16,6);
define _porc_partic_prima_2	dec(16,6);
define _cod_contrato		char(5);
define _no_endoso_2			char(5);

let _no_cambio = 0;
let _no_endoso = "00000";

foreach
 select no_poliza,
		no_documento,
		vigencia_inic,
		vigencia_final
   into _no_poliza,
		_no_documento,
		_vigencia_inic,
		_vigencia_final
   from emipomae
  where actualizado = 1

	foreach
	 select no_unidad 
	   into _no_unidad
	   from emipouni
	  where no_poliza = _no_poliza

		-- Verifica que Exista el Maestro de Fechas
			
		select count(*)
		  into _cantidad
		  from emireama
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		if _cantidad = 0 then

			{
			FOREACH
			 SELECT	cod_cober_reas
			   INTO	_cod_cober_reas
			   FROM	emifacon
			  WHERE	no_poliza = _no_poliza
			    AND no_endoso = _no_endoso
				and no_unidad = _no_unidad
			  GROUP BY cod_cober_reas

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
				_no_cambio,
				_cod_cober_reas,
				_vigencia_inic,
				_vigencia_final
				);

			END FOREACH
			--}

			return _no_documento,
				   _no_poliza,	
			       _no_unidad,
			       "01 - No Existe Distribucion de Reaseguro Maestros",
				   0.00
			       with resume;		   
		end if
				  		
		-- Verifica que Exista el Maestro de Contratos

		select count(*)
		  into _cantidad
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		if _cantidad = 0 then

			--{
			begin
			on exception in (-691)
			return _no_documento,
				   _no_poliza,	
			       _no_unidad,
			       "03 - No Existe Distribucion de Reaseguro Contratos",
				   0.00
			       with resume;		   
			end exception

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
			no_poliza, 
			no_unidad,
			_no_cambio,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima
			 FROM emifacon
			WHERE no_poliza = _no_poliza
			  AND no_endoso = _no_endoso
			  and no_unidad = _no_unidad;

			return _no_documento,
				   _no_poliza,	
			       _no_unidad,
			       "02 - No Existe Distribucion de Reaseguro Contratos",
				   0.00
			       with resume;		   

			end
			--}
		end if

		{
		-- Verifica que Exista los Contratos Facultativos

	   foreach	
		select no_cambio,
			   cod_cober_reas,
			   orden	
		  into _no_cambio,
			   _cod_cober_reas,
			   _orden	
		  from emireaco e, reacomae c
		 where e.no_poliza     = _no_poliza
		   and e.no_unidad     = _no_unidad
		   and e.cod_contrato  = c.cod_contrato
		   and c.tipo_contrato = 3


			select count(*)
			  into _cantidad
			  from emireafa
			 where no_poliza      = _no_poliza
			   and no_unidad      = _no_unidad
			   and no_cambio      = _no_cambio
			   and cod_cober_reas = _cod_cober_reas
			   and orden          = _orden;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			if _cantidad = 0 then

				begin
				on exception in (-691, -268)
					return _no_documento,
						   _no_poliza,	
					       _no_unidad,
					       "05 - No Existe Distribucion de Facultativos"
					       with resume;		   
				end exception

					INSERT INTO emireafa(
					no_poliza,
					no_unidad,
					no_cambio,
					cod_cober_reas,
					orden,
					cod_contrato,
					cod_coasegur,
					porc_partic_reas,
					porc_comis_fac,
					porc_impuesto
					)
					SELECT 
					no_poliza, 
					no_unidad,
					_no_cambio,
					cod_cober_reas,
					orden,
					cod_contrato,
					cod_coasegur,
					porc_partic_reas,
					porc_comis_fac,
					porc_impuesto
					 FROM emifafac
					WHERE no_poliza = _no_poliza
					  AND no_endoso = _no_endoso
					  and no_unidad = _no_unidad;

					return _no_documento,
						   _no_poliza,	
					       _no_unidad,
					       "04 - No Existe Distribucion de Facultativos"
					       with resume;		   

				end 

			end if

		end foreach
		--}

		-- Verificacion entre Historico de Contratos y Contratos Actuales

		{
		select min(no_endoso)
		  into _no_endoso
		  from emifacon
		 WHERE no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

		foreach
		 select cod_cober_reas,
			    orden,
			    cod_contrato,
			    porc_partic_suma,
			    porc_partic_prima
		   into	_cod_cober_reas,
			    _orden,
			    _cod_contrato,
			    _porc_partic_suma,
			    _porc_partic_prima
		   from emifacon
		  WHERE no_poliza = _no_poliza
		 	AND no_endoso = _no_endoso
			and no_unidad = _no_unidad
		
				select porc_partic_suma,
			    	   porc_partic_prima
				  into _porc_partic_suma_2,
			    	   _porc_partic_prima_2
				  from emireaco
				 WHERE no_poliza      = _no_poliza
				   and no_unidad      = _no_unidad
				   AND no_cambio      = 0
				   and cod_cober_reas = _cod_cober_reas
				   and orden          = _orden;
				   
				if _porc_partic_suma_2 is null then

					let _no_endoso_2 = null;
									
					foreach
					 select no_endoso
					   into _no_endoso_2
					   from endedmae
					  where no_poliza   = _no_poliza
					    and cod_endomov = "017"
					 order by no_endoso desc
						exit foreach;
					end foreach

					if _no_endoso_2 is null then

						return _no_documento,
							   _no_poliza,	
						       _no_unidad,
						       "10 - No Encontro la Distribucion de Reaseguro"
						       with resume;		   
					else
						return _no_documento,
							   _no_poliza,	
						       _no_unidad,
						       "11 - No Encontro la Distribucion de Reaseguro - Cambio Reas."
						       with resume;		   
					end if
				end if

		end foreach
		--}

		foreach
		 select no_cambio,
		        cod_cober_reas,
		        sum(porc_partic_suma),	
		        sum(porc_partic_prima)	
		   into _no_cambio,
		        _cod_cober_reas,
		        _porc_partic_suma,	
		        _porc_partic_prima
		   from emireaco
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
		  group by no_cambio, cod_cober_reas

			if _porc_partic_suma <> 100 then
				return _no_documento,
					   _no_poliza,	
				       _no_unidad,
				       "20 - Porcentaje de Suma <> 100",
					   _porc_partic_suma
				       with resume;		   
			end if

			if _porc_partic_prima <> 100 then
				return _no_documento,
					   _no_poliza,	
				       _no_unidad,
				       "21 - Porcentaje de Prima <> 100",
					   _porc_partic_prima
				       with resume;		   
			end if
			

		end foreach

	
	end foreach

end foreach

end procedure;
















																   