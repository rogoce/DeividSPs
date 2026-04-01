-- Procedimiento que Prepara la Información de los Reclamos de la Carga de Pma Asistencias
-- creado 24/01/2014 Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rwf133;		
create procedure "informix".sp_rwf133(a_cod_evento char(3), a_reclamo CHAR(10))
returning	char(5),				        --1  cod_cobertura
			varchar(50),
			dec(16,2);						--2  reserva
			
define _cod_cobertura 	char(5);
define _cod_evento      char(3);
define _tipo_siniestro  smallint;
define _no_poliza	    char(10);
define _no_unidad	    char(5);
define _cod_ramo        char(3);
define _cod_producto    char(5);
define _suma_asegurada  dec(16,2);
define _tipo, _cnt_cob  smallint;
define _reserva_inicial dec(16,2);
define _cod_cobertura_ori 	char(5);
define _cobertura           varchar(50);
define _periodo_rec     char(7);
define _cnt_evento      smallint;
define _nombre, _nombre2          varchar(50);
define _cant_cob        smallint;
define _tipo_dano       smallint;

if a_reclamo = '650225' then
  SET DEBUG FILE TO "sp_pro312.trc";
  TRACE ON;
end if

let a_reclamo = a_reclamo;
let _reserva_inicial = 0.00;
let _tipo_siniestro = 0;
let _cod_cobertura_ori = null;

let _nombre2 = null;

if a_cod_evento = '005' then   --ATROPELLO DE PEATON
	let _tipo_siniestro = 5;
	let _nombre = '%COLISION%';
elif a_cod_evento = '008' then --ROBO TOTAL DEL AUTO                               
	let _tipo_siniestro = 6;
	let _nombre = '%ROBO%';
elif a_cod_evento = '009' then --ROBO PARCIAL DE PARTES Y ACCESORIOS DE  AUTO      
	let _tipo_siniestro = 3;
	let _nombre = '%COMPRENSIVO%';
elif a_cod_evento = '014' then --ROTURA DE PARABRISAS                              
	let _tipo_siniestro = 7;
	let _nombre = '%COMPRENSIVO%';
elif a_cod_evento = '016' then --COLISION
	let _tipo_siniestro = 1;
	let _nombre = '%COLISION%';
	let _nombre2 = '%AJENA%';
elif a_cod_evento = '039' then --DANOS POR MALDAD                                  
elif a_cod_evento = '044' then --INCENDIO                                          
	let _tipo_siniestro = 2;
	let _nombre = '%INCENDIO%';
elif a_cod_evento = '064' then --CAIDA DE OBJETOS AL  VEHICULO                     
	let _tipo_siniestro = 8;
	let _nombre = '%COMPRENSIVO%';
elif a_cod_evento = '142' then --INUNDACION
	let _tipo_siniestro = 4;
	let _nombre = '%COMPRENSIVO%';
end if

select no_poliza,
       no_unidad,
	   suma_asegurada,
	   cod_evento,
	   periodo,
	   tipo_dano
  into _no_poliza,
	   _no_unidad,
	   _suma_asegurada,
	   _cod_evento,
	   _periodo_rec,
	   _tipo_dano
  from recrcmae
 where no_reclamo = a_reclamo;

 select count(*) 
   into _cant_cob
   from recrccob
  where no_reclamo = a_reclamo;
  
 if _cant_cob > 1 then
	foreach
		select cod_cobertura, reserva_inicial
		  into _cod_cobertura_ori, _reserva_inicial
		  from recrccob
		 where no_reclamo = a_reclamo
		   and reserva_inicial <> 0

		exit foreach;
	end foreach
		if _cod_cobertura_ori is null then
			foreach
				select cod_cobertura, reserva_inicial
				  into _cod_cobertura_ori, _reserva_inicial
				  from recrccob
				 where no_reclamo = a_reclamo
				exit foreach;
			end foreach
		end if
 else
	select cod_cobertura, reserva_inicial
	  into _cod_cobertura_ori, _reserva_inicial
	  from recrccob
	 where no_reclamo = a_reclamo;
	 
	if _tipo_siniestro = 1 then
		select nombre
		  into _nombre
		  from prdcober
		 where cod_cobertura = _cod_cobertura_ori;	
	end if
 end if
 
let _cod_cobertura = null;

let _cod_producto = null;

select cod_producto
  into _cod_producto
  from emipouni
 where no_poliza = _no_poliza
   and no_unidad = _no_unidad;

if _cod_producto is null then
	foreach 
		select cod_producto
		  into _cod_producto
		  from endeduni
		 where no_poliza = _no_poliza
   		   and no_unidad = _no_unidad
		 order by no_endoso desc

         exit foreach;
	end foreach
end if

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

--if _cod_ramo = '023' then
  --	let _cod_ramo = '002';
--end if

	if _cod_ramo = '002' or _cod_ramo = '023' then
				if _tipo_siniestro in(1,2,3,4,5,6,7,8) then
					if _cod_producto = '00318' then	
					    if _tipo_siniestro = 1 then
							let _nombre = '%AJENA%';
						elif _tipo_siniestro = 5 then
							let _nombre = '%LESIONE%';
						elif _tipo_siniestro = 7 then
							let _nombre = '%ROTURA%';
						elif _tipo_siniestro = 8 then
							let _nombre = '%CAIDA%';
						end if

						select e.cod_cobertura 
						  into _cod_cobertura
						  from emipocob e, prdcober p
						 where e.cod_cobertura = p.cod_cobertura
						   and e.no_poliza = _no_poliza
						   and no_unidad = _no_unidad
						   and p.cod_ramo = _cod_ramo
						   and p.nombre like _nombre;
						
						if _cod_cobertura is null then
							foreach
								select e.cod_cobertura 
								  into _cod_cobertura
								  from endedcob e, prdcober p
								 where e.cod_cobertura = p.cod_cobertura
								   and e.no_poliza = _no_poliza
								   and no_unidad = _no_unidad
								   and p.cod_ramo = _cod_ramo
								   and p.nombre like _nombre
								exit foreach;
							end foreach
						end if 

					elif _cod_producto = '00313' then  --AutoRC 
						if _tipo_siniestro = 1 then
							let _nombre = '%AJENA%';
						elif _tipo_siniestro = 5 then
							let _nombre = '%LESIONE%';
						end if

						select e.cod_cobertura 
						  into _cod_cobertura
						  from emipocob e, prdcober p
						 where e.cod_cobertura = p.cod_cobertura
						   and e.no_poliza = _no_poliza
						   and no_unidad = _no_unidad
						   and p.cod_ramo = _cod_ramo
						   and p.nombre like _nombre;

						if _cod_cobertura is null then
							foreach
								select e.cod_cobertura 
								  into _cod_cobertura
								  from endedcob e, prdcober p
								 where e.cod_cobertura = p.cod_cobertura
								   and e.no_poliza = _no_poliza
								   and no_unidad = _no_unidad
								   and p.cod_ramo = _cod_ramo
								   and p.nombre like _nombre
								exit foreach;
							end foreach
						end if 

					else --Auto completa y otros
							select e.cod_cobertura 
							  into _cod_cobertura
							  from emipocob e, prdcober p
							 where e.cod_cobertura = p.cod_cobertura
							   and e.no_poliza = _no_poliza
							   and no_unidad = _no_unidad
							   and p.cod_ramo = _cod_ramo
							   and p.nombre like _nombre; 
						if _cod_cobertura is null then
							foreach
								select e.cod_cobertura 
								  into _cod_cobertura
								  from endedcob e, prdcober p
								 where e.cod_cobertura = p.cod_cobertura
								   and e.no_poliza = _no_poliza
								   and no_unidad = _no_unidad
								   and p.cod_ramo = _cod_ramo
								   and p.nombre like _nombre
								exit foreach;
							end foreach
						end if 
					end if					
				end if
	elif _cod_ramo = '020' then
		if _tipo_siniestro = 1 then
			select e.cod_cobertura 
			  into _cod_cobertura
			  from emipocob e, prdcober p
			 where e.cod_cobertura = p.cod_cobertura
			   and e.no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and p.cod_ramo = _cod_ramo
			   and p.nombre like '%PROPIEDAD AJENA%';

				if _cod_cobertura is null then
					foreach
						select e.cod_cobertura 
						  into _cod_cobertura
						  from endedcob e, prdcober p
						 where e.cod_cobertura = p.cod_cobertura
						   and e.no_poliza = _no_poliza
						   and no_unidad = _no_unidad
						   and p.cod_ramo = _cod_ramo
						   and p.nombre like '%PROPIEDAD AJENA%'
						exit foreach;
					end foreach
				end if 
		elif _tipo_siniestro = 5 then
			select e.cod_cobertura 
			  into _cod_cobertura
			  from emipocob e, prdcober p
			 where e.cod_cobertura = p.cod_cobertura
			   and e.no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and p.cod_ramo = _cod_ramo
			   and p.nombre like '%LESIONE%';

				if _cod_cobertura is null then
					foreach
						select e.cod_cobertura 
						  into _cod_cobertura
						  from endedcob e, prdcober p
						 where e.cod_cobertura = p.cod_cobertura
						   and e.no_poliza = _no_poliza
						   and no_unidad = _no_unidad
						   and p.cod_ramo = _cod_ramo
						   and p.nombre like '%LESIONE%'
						exit foreach;
					end foreach
				end if 
		end if
	end if

	--if a_cod_evento <> _cod_evento then
		let _cnt_evento = 0;
        
		select count(*) 
		  into _cnt_evento
		  from recreeve
		 where cod_ramo = '002'
		   and cod_evento = a_cod_evento
		   and tipo_dano = _tipo_dano;

		if _cnt_evento > 0 then
			foreach		
				select reserva_inicial, tipo
				  into _reserva_inicial, _tipo
				  from recreeve
				 where cod_ramo = '002'
				   and cod_evento = a_cod_evento
				   and tipo_dano = _tipo_dano
			    order by periodo desc
				exit foreach;
			end foreach
				   
			if _tipo = 2 then
				let _reserva_inicial = _suma_asegurada;
			end if
		end if 
	--end if 

    if _cod_cobertura is null then
	    let _cod_cobertura = _cod_cobertura_ori;
	end if

    let _cobertura = null;

    select nombre
	  into _cobertura
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	if a_cod_evento = '016' then --Para polizas que no tengan cobertura de colision
	    let _cnt_cob = 0;
		 
		select count(*)
		  into _cnt_cob
		  from recrccob a, prdcober b
		 where a.cod_cobertura = b.cod_cobertura
		   and no_reclamo = a_reclamo
		   and b.nombre like '%COLISION%';
		
		if _cnt_cob = 0 then 
			let _cod_cobertura = _cod_cobertura_ori;

		    select nombre
			  into _cobertura
			  from prdcober
			 where cod_cobertura = _cod_cobertura;
			      
			foreach
				select reserva
				  into _reserva_inicial
				  from recrepro
				 where cod_ramo = '020'
				   and periodo  <= _periodo_rec
				   and tipo_dano = _tipo_dano
			    order by periodo desc
				exit foreach;
			end foreach
		end if
	end if

    
	return	_cod_cobertura, _cobertura, _reserva_inicial;

end procedure