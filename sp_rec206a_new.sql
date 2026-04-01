-- Procedimiento que Prepara la Información de los Reclamos de la Carga de Pma Asistencias
-- creado 24/01/2014 Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec206a_new;		
create procedure "informix".sp_rec206a_new(a_tipo_siniestro integer, a_cod_ramo char(3), a_cod_producto varchar(10), a_no_poliza varchar(10), a_no_unidad varchar(5), a_tipo_dano char(20))
returning	char(3),						--1 cod_evento		
			varchar(10),				    --2 cod_cobertura
			varchar(20);                    --3 ramo
			
define _nom_ramo 		varchar(30);
define _cod_cobertura 	varchar(200);
define _cod_evento      char(3);
let _cod_cobertura = NULL;
if a_tipo_siniestro = 0 then
	let a_tipo_siniestro = 1;
end if
	if a_cod_ramo = '002' or a_cod_ramo = '023' then
		let _nom_ramo = "AUTOMOVIL ";
				if a_tipo_siniestro in(1,2,3,4,5,6,7,8) then
					if a_cod_producto = '00318' then	
					    if a_tipo_siniestro = 1 then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%PROPIEDAD AJENA%';
						elif a_tipo_siniestro = 5 then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%LESIONE%';
						elif a_tipo_siniestro = 2 then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%INCENDIO%';
						elif a_tipo_siniestro = 6 then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%ROBO%';
						elif a_tipo_siniestro = 7 then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%ROTURA%';
						elif a_tipo_siniestro = 8 then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%CAIDA%';							   
						 end if
					elif a_cod_producto = '00313' then  --AutoRC 
						if a_tipo_siniestro = 1 then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%PROPIEDAD AJENA%';
						elif a_tipo_siniestro = 5 then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%LESIONE%';
						end if
					else --Auto completa y otros
						if a_tipo_siniestro in(1) then
							if a_tipo_dano = 'fuerte' then
								select e.cod_cobertura 
								  into _cod_cobertura
								  from emipocob e, prdcober p
								 where e.cod_cobertura = p.cod_cobertura
								   and e.no_poliza = a_no_poliza
								   and no_unidad = a_no_unidad
								   and p.cod_ramo = a_cod_ramo
								   and p.nombre like '%COLISION%';
							else
								select e.cod_cobertura 
								  into _cod_cobertura
								  from emipocob e, prdcober p
								 where e.cod_cobertura = p.cod_cobertura
								   and e.no_poliza = a_no_poliza
								   and no_unidad = a_no_unidad
								   and p.cod_ramo = a_cod_ramo
								   and p.nombre like '%PROPIEDAD AJENA%';
							end if
						elif a_tipo_siniestro in(2) then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%INCENDIO%';
						elif a_tipo_siniestro in(3,4,7,8) then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%COMPRENSIVO%';
						elif a_tipo_siniestro in(5) then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%LESIONE%';	   
						elif a_tipo_siniestro in(6) then
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = a_no_poliza
							   and no_unidad = a_no_unidad
							   and p.cod_ramo = a_cod_ramo
							   and p.nombre like '%ROBO%';
						end if
					end if					
				end if
	elif a_cod_ramo = '020' then
		let _nom_ramo = "SODA";
		if a_tipo_siniestro = 1 then
			select e.cod_cobertura 
			  into _cod_cobertura
			  from emipocob e, prdcober p
			 where e.cod_cobertura = p.cod_cobertura
			   and e.no_poliza = a_no_poliza
			   and no_unidad = a_no_unidad
			   and p.cod_ramo = a_cod_ramo
			   and p.nombre like '%PROPIEDAD AJENA%';
		elif a_tipo_siniestro = 5 then
			select e.cod_cobertura 
			  into _cod_cobertura
			  from emipocob e, prdcober p
			 where e.cod_cobertura = p.cod_cobertura
			   and e.no_poliza = a_no_poliza
			   and no_unidad = a_no_unidad
			   and p.cod_ramo = a_cod_ramo
			   and p.nombre like '%LESIONE%';
		end if
	end if
	if _cod_cobertura is null or trim(_cod_cobertura) = '' then
		select e.cod_cobertura 
		  into _cod_cobertura
		  from emipocob e, prdcober p
		 where e.cod_cobertura = p.cod_cobertura
		   and e.no_poliza = a_no_poliza
		   and no_unidad = a_no_unidad
		   and p.cod_ramo = a_cod_ramo
		   and p.nombre like '%PROPIEDAD AJENA%';
	end if
	if a_tipo_siniestro = 1 then
		select cod_evento
		  into _cod_evento
		  from recevent 
		 where cod_ramo = '002' 
		   and activo = 1 
		   and nombre like '%COLISION';
	elif a_tipo_siniestro = 2 then
		select cod_evento
		  into _cod_evento
		  from recevent 
		 where cod_ramo = '002' 
		   and activo = 1 
		   and nombre like '%INCENDIO%';
	elif a_tipo_siniestro = 3 then
		select cod_evento
		  into _cod_evento
		  from recevent 
		 where cod_ramo = '002' 
		   and activo = 1 
		   and nombre like '%ROBO PARCIAL%';
	elif a_tipo_siniestro = 4 then
		select cod_evento
		  into _cod_evento
		  from recevent 
		 where cod_ramo = '002' 
		   and activo = 1 
		   and nombre like '%INUNDACION%';
	elif a_tipo_siniestro = 5 then
		select cod_evento
		  into _cod_evento
		  from recevent 
		 where cod_ramo = '002' 
		   and activo = 1 
		   and nombre like '%ATROPELLO%';
	elif a_tipo_siniestro = 6 then
		select cod_evento
		  into _cod_evento
		  from recevent 
		 where cod_ramo = '002' 
		   and activo = 1 
		   and nombre like '%ROBO TOTAL%';
	elif a_tipo_siniestro = 8 then
		select cod_evento
		  into _cod_evento
		  from recevent 
		 where cod_ramo = '002' 
		   and activo = 1 
		   and nombre like '%CAIDA DE OBJETO%';
	elif a_tipo_siniestro = 7 then
		select cod_evento
		  into _cod_evento
		  from recevent 
		 where cod_ramo = '002' 
		   and activo = 1 
		   and nombre like '%ROTURA%';
	elif a_tipo_siniestro = 9 then
		select cod_evento
		  into _cod_evento
		  from recevent 
		 where cod_ramo = '002' 
		   and activo = 1 
		   and nombre like '%PROPIEDAD AJENA%';
	end if
	return	_cod_evento,_cod_cobertura,_nom_ramo;

end procedure