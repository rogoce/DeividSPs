--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

--drop procedure sp_pro315;

create procedure "informix".sp_pro315(v_periodo char(7))
returning integer;

begin

define v_poliza     	char(10);
define v_documento  	char(20);
define v_factura    	char(10);
define v_renovar    	smallint;
define v_cod_renovar 	smallint;
define v_cod_no_renovar char(3);
define _cod_ramo        char(3);
define _no_poliza       char(10);
define v_vigencia_inic  date;
define _vig_inic_ult    date;
define v_vigencia_fin   date;
define v_tipo       	char(3);
define v_saldo      	decimal(16,2);
define v_cant       	smallint;
define v_cantidad   	smallint;
define v_incurrido  	decimal(16,2);
define v_pagos      	decimal(16,2);
define v_tot_pagos  	decimal(16,2);
define _suma_asegurada	decimal(16,2);
define _perd_total  	smallint;
define _todas_perdida  	smallint;
define _cod_compania   	char(3);
define _codigo_agencia	char(3);
define _cod_sucursal   	char(3);
define _centro_costo   	char(3);
define _usuario      	char(8);
define _cnt			  	smallint;
define _cantidad	  	smallint;
define _cod_agente      char(5);
define _porc_partic  	decimal(5,2);
define _vig_final		date;
define _cod_tipoprod    char(3);
define _cod_grupo       char(5);
define _salir           smallint;
define _cod_subramo     char(3);
define _fecha           date;
define _cod_manzana     char(15);
define _cod_asegurado   char(10);
define _fecha_aniversario date;
define _edad            integer;
define _no_unidad       char(5);
define _activo          smallint;
define _cod_acreedor    char(5);
define _ano_auto        smallint;
define _cod_cobertura   char(5);
define _estatus         smallint;
define _prima_bruta     decimal(16,2);
define _diezporc	    decimal(16,2);
define _saldo           decimal(16,2);

--SET DEBUG FILE TO "sp_pro315.trc"; 
--TRACE ON;                                                                

create temp table tmp_reaut(
usuario		char(8),
no_poliza	char(10)
) with no log;

set isolation to dirty read;

let _fecha           = current;
let v_pagos          = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_saldo          = 0;
let v_renovar        = 0;
let v_cod_renovar    = 0;
let _salir 			 = 0;
let v_poliza         = NULL;
let v_factura        = NULL;
let v_cod_no_renovar = NULL;
let _prima_bruta     = 0;

foreach

	 select no_poliza, 
			no_documento, 
			no_factura,
	        renovada, 
	        no_renovar, 
	        cod_no_renov,
	        vigencia_inic, 
	        vigencia_final, 
	        saldo,
			cod_compania,
			cod_sucursal,
			cod_ramo,
			cod_tipoprod,
			cod_grupo,
			cod_subramo,
			suma_asegurada,
			prima_bruta
	   into v_poliza, 
	 	    v_documento, 
	 	    v_factura, 
	 	    v_renovar, 
	 	    v_cod_renovar,
	        v_cod_no_renovar, 
	        v_vigencia_inic, 
	        v_vigencia_fin, 
	        v_saldo,
			_cod_compania,
			_cod_sucursal,
			_cod_ramo,
			_cod_tipoprod,
			_cod_grupo,
			_cod_subramo,
			_suma_asegurada,
			_prima_bruta
	   from emipomae
	  where year(vigencia_final)  = v_periodo[1,4]
	    and month(vigencia_final) = v_periodo[6,7]
	    and renovada       		      = 0
	    and no_renovar     		      = 0
	    and incobrable     		      = 0
	    and abierta        		      = 0
	    and actualizado               = 1
	    and estatus_poliza 		      IN (1,3)

	 select centro_costo
	   into _centro_costo
	   from insagen
	  where codigo_agencia  = _cod_sucursal
		and codigo_compania = _cod_compania;

	 --***********************
	 --Excepciones de Tecnico*
	 --***********************

	 if _cod_ramo in('001','003','005','006','015','011','013','010','009','014') then

	  	  --polizas con facultativos
		
		  select count(*)
		    into _cnt
		    from emifafac
		   where no_poliza = v_poliza;

		  if _cnt > 0 then

			select usuario
			  into _usuario
			  from emiredis
			 where cod_sucursal = _centro_costo
			   and tipo_ramo    = '2'
			   and renglon      = 2;  --polizas con facultativos

			INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

		  end if

	  	  --polizas con ubicacion zona libre y france field
		  foreach

			  select cod_manzana
			    into _cod_manzana
				from emipouni
			   where no_poliza = v_poliza

			  if _cod_manzana[1,12] = '030010020103' or _cod_manzana[1,12] = '030010064400' then

				  select count(*)
				    into _cnt
				    from tmp_reaut
				   where no_poliza = v_poliza;

				  if _cnt > 0 then
				  else

					select usuario
					  into _usuario
					  from emiredis
					 where cod_sucursal = _centro_costo
					   and tipo_ramo    = '2'
					   and renglon      = 1;	--polizas con ubicacion zona libre - francefield

					INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
					exit foreach;
				  end if	
			  end if
		  end foreach

	  	  --Polizas con Coaseguro

		  if _cod_tipoprod in('001','002') then

			  select count(*)
			    into _cnt
			    from tmp_reaut
			   where no_poliza = v_poliza;

			  if _cnt > 0 then
			  else

				select usuario
				  into _usuario
				  from emiredis
				 where cod_sucursal = _centro_costo
				   and tipo_ramo    = '2'
				   and renglon      = 3;	--polizas con coaseguro

				INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

			  end if
		  end if

		  --Polizas con Reclamos

		  let v_cantidad = 0;

		  select count(*) 
		    into v_cantidad 
		    from recrcmae
		   where no_poliza   = v_poliza
		     and actualizado = 1;

		  if v_cantidad > 0 then
			  select count(*)
			    into _cnt
			    from tmp_reaut
			   where no_poliza = v_poliza;

			  if _cnt > 0 then
			  else

				select usuario
				  into _usuario
				  from emiredis
				 where cod_sucursal = _centro_costo
				   and tipo_ramo    = '2'
				   and renglon      = 4;	--polizas con reclamos

				INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

			  end if
		  end if
	 elif _cod_ramo = '004' then

		  --Polizas del Ramo Accidentes personales cuando el asegurado es > a 70 anos.

		  let v_cantidad = 0;
		  foreach

			select cod_asegurado
			  into _cod_asegurado
			  from emipouni
			 where no_poliza = v_poliza

			select fecha_aniversario
			  into _fecha_aniversario
			  from cliclien
			 where cod_cliente = _cod_asegurado;

			if _fecha_aniversario is null then
				continue foreach;
			end if

			let _edad = sp_sis78(_fecha_aniversario,_fecha);--Retorna la edad a la fecha

			if _edad > 70 then
				
			    select count(*)
				  into v_cantidad
				  from tmp_reaut
				 where no_poliza = v_poliza;

				if v_cantidad > 0 then
					exit foreach;
				else
					select usuario
					  into _usuario
					  from emiredis
					 where cod_sucursal = _centro_costo
					   and tipo_ramo    = '3'
					   and renglon      = 5;	--polizas con reclamos

					INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
					exit foreach;
				end if

			end if

		  end foreach
	 elif _cod_ramo = '019' then

	      select count(*)
		    into v_cantidad
		    from tmp_reaut
		   where no_poliza = v_poliza;

		  if v_cantidad > 0 then
			continue foreach;
		  end if

		  select count(*)
		    into _cnt
		    from emipouni
		   where no_poliza = v_poliza;

		  if _cnt > 1 then

			select usuario
			  into _usuario
			  from emiredis
			 where cod_sucursal = _centro_costo
			   and tipo_ramo    = '3'
			   and renglon      = 5;	--polizas colectivas

			INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

		  else

			select usuario
			  into _usuario
			  from emiredis
			 where cod_sucursal = _centro_costo
			   and tipo_ramo    = '3'
			   and renglon      = 6;	--polizas individuales

			INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

		  end if
		
	 elif _cod_ramo = '018' then
		
		  let v_cantidad = 0;
		  let _salir     = 0;

		  if _cod_subramo = '012' then --subramo colectivo

		      select count(*)
			    into v_cantidad
			    from tmp_reaut
			   where no_poliza = v_poliza;

			  if v_cantidad > 0 then
				continue foreach;
			  else
					select usuario
					  into _usuario
					  from emiredis
					 where cod_sucursal = _centro_costo
					   and tipo_ramo    = '3'
					   and renglon      = 5;	--polizas colectivas

					INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
					continue foreach;
			  end if

		  end if

		  --Polizas del Ramo salud cuando por lo menos algun dependiente es > a 25 anos.
		  select count(*)
		    into _cnt
		    from emipouni
		   where no_poliza = v_poliza;

		  foreach

			select cod_asegurado,
			       no_unidad
			  into _cod_asegurado,
			       _no_unidad
			  from emipouni
			 where no_poliza = v_poliza

			foreach

				select cod_cliente,
				       activo
				  into _cod_asegurado,
					   _activo
				  from emidepen
				 where no_poliza = v_poliza
				   and no_unidad = _no_unidad

				if _activo = 1 then

					select fecha_aniversario
					  into _fecha_aniversario
					  from cliclien
					 where cod_cliente = _cod_asegurado;

					if _fecha_aniversario is null then
						continue foreach;
					end if

					let _edad = sp_sis78(_fecha_aniversario,_fecha);--Retorna la edad a la fecha

					if _edad > 25 then
						
					    select count(*)
						  into v_cantidad
						  from tmp_reaut
						 where no_poliza = v_poliza;

						if v_cantidad > 0 then
							let _salir = 1;
							exit foreach;
						else
							if _cnt > 1 then

								select usuario
								  into _usuario
								  from emiredis
								 where cod_sucursal = _centro_costo
								   and tipo_ramo    = '3'
								   and renglon      = 5;	--polizas colectivas

								INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
								let _salir = 1;
								exit foreach;
							else

								select usuario
								  into _usuario
								  from emiredis
								 where cod_sucursal = _centro_costo
								   and tipo_ramo    = '3'
								   and renglon      = 6;	--polizas individuales

								INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
								let _salir = 1;
								exit foreach;

							end if
						end if
				    end if
				end if
			end foreach
			if _salir = 1 then
				exit foreach;
			end if
		  end foreach

		  --Polizas del Ramo salud cuando el grupo es <> a sin grupo 00001.

		  if _cod_grupo <> '00001' then

			  select count(*)
			   into v_cantidad
			   from tmp_reaut
			  where no_poliza = v_poliza;

			  if v_cantidad > 0 then
			  else
				  if _cnt > 1 then

				  		select usuario
						  into _usuario
						  from emiredis
						 where cod_sucursal = _centro_costo
						   and tipo_ramo    = '3'
						   and renglon      = 5;	--polizas colectivas

						INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
				  else

						select usuario
						  into _usuario
						  from emiredis
						 where cod_sucursal = _centro_costo
						   and tipo_ramo    = '3'
						   and renglon      = 6;	--polizas individuales

						INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
				  end if
			  end if
		  end if

	 elif _cod_ramo = '016' then	--Ramo Colectivo de Vida

		  select count(*)
		   into v_cantidad
		   from tmp_reaut
		  where no_poliza = v_poliza;

		  if v_cantidad > 0 then
			continue foreach;
		  else
		  		select usuario
				  into _usuario
				  from emiredis
				 where cod_sucursal = _centro_costo
				   and tipo_ramo    = '3'
				   and renglon      = 5;	--polizas colectivas

				INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
		  end if

	 elif _cod_ramo = '020' then	--Ramo SODA

		  select count(*)
		   into v_cantidad
		   from tmp_reaut
		  where no_poliza = v_poliza;

		  if v_cantidad > 0 then
			continue foreach;
		  else
		  		select usuario
				  into _usuario
				  from emiredis
				 where cod_sucursal = _centro_costo
				   and tipo_ramo    = '1'
				   and renglon      = 0;	--polizas del ramo SODA

				INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

		  end if

	 elif _cod_ramo = '002' then	--Ramo AUTOMOVIL

		  let _salir = 0;
		  select count(*)
		   into v_cantidad
		   from tmp_reaut
		  where no_poliza = v_poliza;

		  if v_cantidad > 0 then
			continue foreach;
		  else

			  select count(*)
			   into v_cantidad
			   from emipouni
			  where no_poliza = v_poliza;

			  if v_cantidad > 1 then	-- Es Flota

		  		select usuario
				  into _usuario
				  from emiredis
				 where cod_sucursal = _centro_costo
				   and tipo_ramo    = '1'
				   and renglon      = 7;	--Flota del ramo AUTOMOVIL

				INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

			  else
					foreach
						select cod_agente
						  into _cod_agente
						  from emipoagt
						 where no_poliza = v_poliza

						if _cod_agente in('00180','00161') then --TECNICA DE SEGUROS  /  GENERAL REPRESENTATIVES

					  		select usuario
							  into _usuario
							  from emiredis
							 where cod_sucursal = _centro_costo
							   and tipo_ramo    = '1'
							   and renglon      = 8;	--Polizas del ramo AUTOMOVIL con corredor

							INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
							let _salir = 1;
							exit foreach;
						end if

					end foreach

					if _salir = 1 then
						continue foreach;
					end if

					--Polizas con Acreedor Instacash
					foreach
						select cod_acreedor
						  into _cod_acreedor
						  from emipoacr
						 where no_poliza = v_poliza

						if _cod_acreedor = '01913' then --INSTACASH

					  		select usuario
							  into _usuario
							  from emiredis
							 where cod_sucursal = _centro_costo
							   and tipo_ramo    = '1'
							   and renglon      = 9;	--Polizas del ramo AUTOMOVIL con acreedor

							INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
							exit foreach;
						end if

					end foreach

					--Subramo Particular y el auto tiene 10 anos.
					--o suma asegurada menor a 4000
					if _cod_subramo = '001' then
					  foreach

						select ano_tarifa
						  into _ano_auto
						  from emiauto
						 where no_poliza = v_poliza
						exit foreach;
					  end foreach

				  	  select usuario
					    into _usuario
					    from emiredis
					   where cod_sucursal = _centro_costo
					     and tipo_ramo    = '1'
					     and renglon      = 10;	--Polizas del ramo AUTOMOVIL subramo x

					  if _ano_auto >= 10 then

							INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

					  elif _suma_asegurada < 4000 then

							INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

					  end if
					end if

					foreach
						select no_unidad
						  into _no_unidad
						  from emipouni
						 where no_poliza = v_poliza

						exit foreach;
					end foreach

					foreach
						select cod_cobertura
						  into _cod_cobertura
						  from emipocob
						 where no_poliza = v_poliza
						   and no_unidad = _no_unidad

						if _cod_cobertura in('00117','00102','00113') then
							foreach
								select ano_tarifa
								  into _ano_auto
								  from emiauto
								 where no_poliza = v_poliza
								exit foreach;
						    end foreach

							if _ano_auto > 15 then

						  	  select usuario
							    into _usuario
							    from emiredis
							   where cod_sucursal = _centro_costo
							     and tipo_ramo    = '1'
							     and renglon      = 10;	--Polizas del ramo AUTOMOVIL subramo x

								INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
								exit foreach;
							end if
						end if
						if _cod_cobertura in('00119','00121','00606','00118','00120','00902','00103','00901') then
							foreach
								select ano_tarifa
								  into _ano_auto
								  from emiauto
								 where no_poliza = v_poliza
								exit foreach;
						    end foreach

							if _ano_auto > 10 then

						  	  select usuario
							    into _usuario
							    from emiredis
							   where cod_sucursal = _centro_costo
							     and tipo_ramo    = '1'
							     and renglon      = 10;	--Polizas del ramo AUTOMOVIL subramo x

								INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);
								exit foreach;

							end if
						end if

					end foreach

				  --Polizas con Reclamos

				  let v_cantidad = 0;
				  select count(*) 
				    into v_cantidad 
				    from recrcmae
				   where no_poliza   = v_poliza
				     and actualizado = 1;

				  if v_cantidad > 0 then
					  select count(*)
					    into _cnt
					    from tmp_reaut
					   where no_poliza = v_poliza;

					  if _cnt > 0 then
					  else

						select usuario
						  into _usuario
						  from emiredis
						 where cod_sucursal = _centro_costo
						   and tipo_ramo    = '1'
						   and renglon      = 7;	--polizas con reclamos

						INSERT INTO tmp_reaut(usuario,no_poliza) VALUES (_usuario,v_poliza);

					  end if
				  end if
			  end if
		  end if
	 end if
	 --***********************
	 --Excepciones de Cobros
	 --***********************
	  select count(*)
	   into v_cantidad
	   from tmp_reaut
	  where no_poliza = v_poliza;

	  if v_cantidad > 0 then
		continue foreach;
	  else
		let _diezporc = 0;
		let _saldo = sp_cob115b('001','001',v_documento,'');
		let _diezporc = _prima_bruta * 0.10;
		if _saldo > _diezporc then
			INSERT INTO tmp_reaut(usuario,no_poliza) VALUES ('COBROS',v_poliza);			
		end if

	  end if
	 --***********************
	 --Excepciones de Sistema*
	 --***********************
	  select count(*)
	   into v_cantidad
	   from tmp_reaut
	  where no_poliza = v_poliza;

	  if v_cantidad > 0 then
		continue foreach;
	  else
		  --Poliza con Notas
		  select count(*)
		    into v_cantidad
		    from eminotas
		   where no_poliza = v_poliza
		     and procesado = 0;

		  if v_cantidad > 0 then

		  	 INSERT INTO tmp_reaut(usuario,no_poliza) VALUES ('MANUAL',v_poliza);

		  end if

		  select count(*)
		    into v_cantidad
		    from tmp_reaut
	  	   where no_poliza = v_poliza;

		  if v_cantidad > 0 then
			continue foreach;
		  else
			 --Polizas con Endoso descriptivo 015
			 select count(*)
			   into v_cantidad
			   from endedmae
			  where no_poliza   = v_poliza
			    and cod_endomov = '015';

			 if v_cantidad > 0 then

				INSERT INTO tmp_reaut(usuario,no_poliza) VALUES ('MANUAL',v_poliza);

 			 end if

		  end if

	  end if
	 --***********************
	 --Renovacion Automatica *
	 --***********************
	  select count(*)
	   into v_cantidad
	   from tmp_reaut
	  where no_poliza = v_poliza;

	  if v_cantidad > 0 then
		continue foreach;
	  else
		INSERT INTO tmp_reaut(usuario,no_poliza) VALUES ('AUTOMATI',v_poliza);
	  end if

end foreach

foreach

	select no_poliza,
	       usuario
	  into v_poliza,
	       _usuario
	  from tmp_reaut

	if _usuario = 'AUTOMATI' then
		let _estatus = 1;
	elif _usuario = 'MANUAL' then
		let _estatus = 4;
	else
		let _estatus = 2;
	end if
	
	select no_documento, 
		   no_factura,
	       renovada, 
	       no_renovar, 
	       cod_no_renov,
	       vigencia_inic, 
	       vigencia_final, 
	       saldo,
		   cod_compania,
		   cod_sucursal,
		   cod_ramo,
		   cod_tipoprod,
		   cod_grupo,
		   cod_subramo,
		   suma_asegurada
	  into v_documento, 
		   v_factura, 
		   v_renovar, 
		   v_cod_renovar,
	       v_cod_no_renovar, 
	       v_vigencia_inic, 
	       v_vigencia_fin, 
	       v_saldo,
		   _cod_compania,
		   _cod_sucursal,
		   _cod_ramo,
		   _cod_tipoprod,
		   _cod_grupo,
		   _cod_subramo,
		   _suma_asegurada
	  from emipomae
	 where no_poliza = v_poliza;

 	let _porc_partic = 0.00;

	foreach

		select porc_partic_agt,
			   cod_agente
		  into _porc_partic,
		       _cod_agente
		  from emipoagt
		 where no_poliza = v_poliza
		 order by porc_partic_agt desc

		exit foreach;

	end foreach

	-- Excluir la poliza si todas las unidades son perdida

    let _todas_perdida = 1;
	foreach
	 select perd_total 
	   into _perd_total
	   from emipouni
	  where no_poliza = v_poliza
		if _perd_total = 0 then
			let _todas_perdida = 0;
			exit foreach;
		end if
	end foreach

	if _todas_perdida = 1 then
		continue foreach;
	end if

    delete from emirepo
     where no_poliza   = v_poliza;

    select count(*) 
      into v_cantidad 
      from recrcmae
     where no_poliza   = v_poliza
       and actualizado = 1;

	if v_cantidad is null then
		let v_cantidad = 0;
	end if

	-- Pagos, Salvamentos, Recuperos y Deducibles

   let v_tot_pagos = 0;
   foreach
	select cod_tipotran 
      into v_tipo
      from rectitra
     where tipo_transaccion  IN (4,5,6,7)

		select sum(x.monto) 
          into v_pagos
          from rectrmae x, recrcmae y
         where y.no_poliza     = v_poliza
           and y.actualizado   = 1
           and x.no_reclamo    = y.no_reclamo
           and x.actualizado   = 1
           and x.cod_tipotran  = v_tipo;

		if v_pagos is null then
	        let v_pagos = 0;
	    end if

		let v_tot_pagos = v_tot_pagos + v_pagos;

   end foreach

	-- Variacion de Reserva

	select sum(x.variacion) 
	  into v_incurrido
      from rectrmae x, recrcmae y
     where y.no_poliza   = v_poliza
       and y.actualizado = 1
       and x.no_reclamo  = y.no_reclamo
       and x.actualizado = 1;

	if v_incurrido is null then
		let v_incurrido = 0;
	end if

	-- Incurrido

	let v_incurrido = v_incurrido + v_tot_pagos;

	-- Solo Pagos

	let v_tot_pagos = 0;

	select cod_tipotran 
      into v_tipo
      from rectitra
     where tipo_transaccion  = 4;

	select sum(x.monto) 
      into v_tot_pagos
      from rectrmae x, recrcmae y
     where y.no_poliza     = v_poliza
       and y.actualizado   = 1
       and x.no_reclamo    = y.no_reclamo
       and x.actualizado   = 1
       and x.cod_tipotran  = v_tipo;

	if v_pagos is null then
	    let v_tot_pagos = 0;
    end if

	if v_tot_pagos is null then
	    let v_tot_pagos = 0;
    end if

	INSERT INTO emirepo(
	no_poliza,
	user_added,
	cod_no_renov,
	no_documento,
	renovar,
	no_renovar,
	fecha_selec,
	vigencia_inic,
	vigencia_final,
	saldo,
	cant_reclamos,
	no_factura,
	incurrido,
	pagos,
	porc_depreciacion,
	cod_agente,
	estatus
	)
	VALUES(
	v_poliza,
	_usuario,
	v_cod_no_renovar,
    v_documento,
    v_cod_renovar,
    v_renovar,
	today,
    v_vigencia_inic, 
    v_vigencia_fin,
    v_saldo,
	v_cantidad,
    v_factura, 
    v_incurrido,
    v_tot_pagos,
	0.00,
	_cod_agente,
	_estatus
    );

end foreach
drop table tmp_reaut;
end
return 0;
end procedure;
