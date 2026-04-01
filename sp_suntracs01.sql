-- Procedimiento que arregla el reaseguro de las polizas suntracs
--
-- Creado:     25/01/2016 - Federico Coronado.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_suntracs01;
create procedure "informix".sp_suntracs01()
returning	integer,
			integer,		-- _error
			char(10),      
			char(100);		--char(100);

define _mensaje             varchar(100);
define _error_desc			char(100);
define _error_isam			integer;
define ls_ruta				char(5);
define _cod_cober_reas     	char(3);
define ls_cober_reas		char(3);
define ld_letra				dec(16,2);
define _cnt_max             smallint;
define _cnt                 smallint;
define _cnt_emireama        smallint;
define _vigencia_inic       date;
define _vigencia_final      date;
define _no_unidad           varchar(5);
define ld_prima_neta        dec(16,2);
define ld_suma_asegurada    dec(16,2);
define li_orden             integer;
define _error				integer;
define ls_contrato			char(5);
define ld_porc_partic_prima dec(10,4);
define ld_porc_partic_suma  dec(10,4);
define ld_suma				dec(16,2); 
define ld_prima				dec(16,2); 
define _no_poliza           varchar(10);


begin

on exception set _error,_error_isam,_error_desc 
 	return _error,_error_isam,_error_desc,'';
end exception

set isolation to dirty read;

--set debug file to "sp_suntracs01.trc";
--trace on;
--let _no_poliza = '959759';
foreach
	select no_poliza
	  into _no_poliza
	  from emipomae
	 where cod_grupo = '01016'
       and estatus_poliza = 1
	   and cod_ramo = '016'
  order by no_poliza asc
	--where no_poliza = '782829'
 
		foreach
			select no_unidad,
				   prima,
				   suma_asegurada,
				   vigencia_inic,
				   vigencia_final
			  into _no_unidad,
				   ld_prima_neta,
				   ld_suma_asegurada,
				   _vigencia_inic,
				   _vigencia_final
			  from emipouni
			  where no_poliza = _no_poliza
			  
			 select c.cod_cober_reas
			   into ls_cober_reas
			   from emipocob e, prdcober c 
			  where e.no_poliza 		= _no_poliza
				and e.no_unidad 		= _no_unidad
				and c.cod_cobertura 	= e.cod_cobertura
		   group by c.cod_cober_reas;
		   
		/*   if ls_cober_reas is null or trim(ls_cober_reas) = "" then
				return 0,0, _no_poliza, _no_unidad WITH RESUME;
		   end if*/
			  select count(*)
				into _cnt
			   from emifacon 
			  where no_poliza = _no_poliza
				and no_endoso = '00000'
				and no_unidad = _no_unidad;
			   
			if _cnt = 0 then
				foreach   
					select orden,
						   cod_contrato,
						   cod_ruta,
						   porc_partic_prima,
						   porc_partic_suma
					 into li_orden,
						  ls_contrato,
						  ls_ruta,
						  ld_porc_partic_prima,
						  ld_porc_partic_suma
					 from emigloco
					where no_poliza = _no_poliza
					
					let ld_suma = (ld_suma_asegurada * ld_porc_partic_suma) / 100;
					let ld_prima = (ld_prima_neta * ld_porc_partic_prima) / 100;
					
					insert into emifacon (
								no_poliza,
								no_endoso,
								no_unidad,
								cod_cober_reas,
								orden,
								cod_contrato,
								porc_partic_suma,
								porc_partic_prima,
								suma_asegurada,
								prima,
								cod_ruta)
						values(	_no_poliza,
								"00000",
								_no_unidad,
								ls_cober_reas,
								li_orden,
								ls_contrato,
								ld_porc_partic_suma,
								ld_porc_partic_prima,
								ld_suma,
								ld_prima,
								ls_ruta);
				end foreach 
			end if	
				select count(*)
				  into _cnt_emireama
				  from emireama
			     where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;
				 
					if _cnt_emireama = 0 then			 
						select max(no_cambio)
						  into _cnt_max
						  from emireama
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
						   
						if _cnt_max is null then
							let _cnt_max = 0;
						else
							let _cnt_max = _cnt_max + 1;
						end if
						
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
											_cnt_max,
											ls_cober_reas,
											_vigencia_inic,
											_vigencia_final
											);
											
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
											_no_unidad,
											_cnt_max,
											cod_cober_reas,
											orden,
											cod_contrato,
											porc_partic_suma,
											porc_partic_prima
											FROM emifacon
										   WHERE no_poliza = _no_poliza
											 AND no_endoso = '00000'
											 AND no_unidad	= _no_unidad;
				    end if
		end foreach	
	return 0,0, _no_poliza, '' WITH RESUME;
end foreach
/*return 0,0,"","";*/
end
end procedure;