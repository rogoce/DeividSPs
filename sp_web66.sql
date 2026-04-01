-- Reporte para el jefe jesus
-- creado   :09/02/2022 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_web66;

CREATE PROCEDURE "informix".sp_web66(a_nodocumento char(21), a_cod_agente char(5),a_indice int, a_total int, a_busqueda char(10) default null, a_busqueda_recla char(10) default null)
		RETURNING 	char(10)	as  no_aprobacion,
					char(100)	as	reclamante,
					char(30)	as	cedula,
					char(255)	as	comentario,
					char(21)	as	no_documento, 
					char(10)	as	cod_cpt1,
					char(10)	as	cod_icd1,
					char(10)	as	autorizado_por,
					char(10)	as	cod_reclamante,
					date		as	fecha_autorizacion,
					char(5)		as	no_unidad,
					date		as	fecha_solicitud, 
					int			as	estado,
					date		as	fecha_autorizacion_1,
					char(10)	as	cod_cliente;

define TempString           	char(612);
define _no_aprobacion    		char(10); 
define _reclamante		  		char(100); 
define _cedula					char(30); 
define _comentario				char(255); 
define _no_documento			char(21); 
define _cod_cpt1				char(10); 
define _cod_icd1				char(10); 
define _autorizado_por			char(10); 
define _cod_reclamante			char(10);
define _fecha_autorizacion		date; 
define _no_unidad				char(5); 
define _fecha_solicitud			date; 
define _estado					int;
define _fecha_autorizacion_1	date;
define _cod_cliente 			char(10);



SET ISOLATION TO DIRTY READ;
--SKIP 634593 FIRST 211536 
	if trim(a_busqueda) <> '' then
		foreach
			SELECT SKIP a_indice FIRST a_total no_aprobacion, 
									reclamante, 
									cedula, 
									comentario, 
									no_documento, 
									cod_cpt1, 
									cod_icd1, 
									autorizado_por, 
									cod_reclamante, 
									fecha_autorizacion, 
									no_unidad, 
									fecha_solicitud, 
									estado, 
									fecha_autorizacion_1, 
									cod_cliente 
							  into  _no_aprobacion, 
									_reclamante, 
									_cedula, 
									_comentario, 
									_no_documento, 
									_cod_cpt1, 
									_cod_icd1, 
									_autorizado_por, 
									_cod_reclamante, 
									_fecha_autorizacion, 
									_no_unidad, 
									_fecha_solicitud, 
									_estado, 
									_fecha_autorizacion_1, 
									_cod_cliente 			  
			FROM
			(
			SELECT recprea1.no_aprobacion, cliclien.nombre as reclamante, cliclien.cedula, recprea1.comentario,
			recprea1.no_documento, recprea1.cod_cpt1, recprea1.cod_icd1, recprea1.autorizado_por, recprea1.cod_reclamante, year(fecha_autorizacion) as fecha_autorizacion,
			emipouni.no_unidad, date(fecha_solicitud) as fecha_solicitud, estado, date(fecha_autorizacion) as fecha_autorizacion_1, recprea1.cod_cliente
			from emipomae
			inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
			inner join recprea1 on recprea1.no_documento =  emipomae.no_documento
			inner join cliclien on cliclien.cod_cliente =  recprea1.cod_reclamante
			inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
			inner join emidepen on emipouni.no_poliza = emidepen.no_poliza
			where emipoagt.cod_agente = a_cod_agente and recprea1.no_documento = a_nodocumento
			and emidepen.cod_cliente = recprea1.cod_reclamante and emidepen.no_unidad = emipouni.no_unidad
			UNION
			SELECT recprea1.no_aprobacion, cliclien.nombre as reclamante, cliclien.cedula, recprea1.comentario, recprea1.no_documento,
			recprea1.cod_cpt1, recprea1.cod_icd1, recprea1.autorizado_por, recprea1.cod_reclamante, year(fecha_autorizacion), no_unidad,
			date(fecha_solicitud), estado, date(fecha_autorizacion), recprea1.cod_cliente
			from emipomae
			inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
			inner join recprea1 on recprea1.no_documento =  emipomae.no_documento
			inner join cliclien on cliclien.cod_cliente =  recprea1.cod_reclamante
			inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
			where emipoagt.cod_agente = a_cod_agente and recprea1.no_documento = a_nodocumento
			and emipouni.cod_asegurado = recprea1.cod_reclamante
			) 
			where no_aprobacion like "%" || TRIM(a_busqueda) || "%"
			order by 12 desc
				let TempString = _comentario;
				LET TempString =  REPLACE(TempString, "“", '');
				LET TempString =  REPLACE(TempString, '”', '');

				let _comentario = TempString;

				RETURN	_no_aprobacion,    	
						_reclamante,		  	
						_cedula,				
						_comentario,			
						_no_documento,		
						_cod_cpt1,			
						_cod_icd1,			
						_autorizado_por,		
						_cod_reclamante,		
						_fecha_autorizacion,	
						_no_unidad,			
						_fecha_solicitud,		
						_estado,				
						_fecha_autorizacion_1,
						_cod_cliente
						WITH RESUME;
		end foreach	
		
	elif trim(a_busqueda_recla) <> '' then
			foreach
			SELECT SKIP a_indice FIRST a_total no_aprobacion, 
									reclamante, 
									cedula, 
									comentario, 
									no_documento, 
									cod_cpt1, 
									cod_icd1, 
									autorizado_por, 
									cod_reclamante, 
									fecha_autorizacion, 
									no_unidad, 
									fecha_solicitud, 
									estado, 
									fecha_autorizacion_1, 
									cod_cliente 
							  into  _no_aprobacion, 
									_reclamante, 
									_cedula, 
									_comentario, 
									_no_documento, 
									_cod_cpt1, 
									_cod_icd1, 
									_autorizado_por, 
									_cod_reclamante, 
									_fecha_autorizacion, 
									_no_unidad, 
									_fecha_solicitud, 
									_estado, 
									_fecha_autorizacion_1, 
									_cod_cliente 			  
			FROM
			(
			SELECT recprea1.no_aprobacion, cliclien.nombre as reclamante, cliclien.cedula, recprea1.comentario,
			recprea1.no_documento, recprea1.cod_cpt1, recprea1.cod_icd1, recprea1.autorizado_por, recprea1.cod_reclamante, year(fecha_autorizacion) as fecha_autorizacion,
			emipouni.no_unidad, date(fecha_solicitud) as fecha_solicitud, estado, date(fecha_autorizacion) as fecha_autorizacion_1, recprea1.cod_cliente
			from emipomae
			inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
			inner join recprea1 on recprea1.no_documento =  emipomae.no_documento
			inner join cliclien on cliclien.cod_cliente =  recprea1.cod_reclamante
			inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
			inner join emidepen on emipouni.no_poliza = emidepen.no_poliza
			where emipoagt.cod_agente = a_cod_agente and recprea1.no_documento = a_nodocumento
			and emidepen.cod_cliente = recprea1.cod_reclamante and emidepen.no_unidad = emipouni.no_unidad
			UNION
			SELECT recprea1.no_aprobacion, cliclien.nombre as reclamante, cliclien.cedula, recprea1.comentario, recprea1.no_documento,
			recprea1.cod_cpt1, recprea1.cod_icd1, recprea1.autorizado_por, recprea1.cod_reclamante, year(fecha_autorizacion), no_unidad,
			date(fecha_solicitud), estado, date(fecha_autorizacion), recprea1.cod_cliente
			from emipomae
			inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
			inner join recprea1 on recprea1.no_documento =  emipomae.no_documento
			inner join cliclien on cliclien.cod_cliente =  recprea1.cod_reclamante
			inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
			where emipoagt.cod_agente = a_cod_agente and recprea1.no_documento = a_nodocumento
			and emipouni.cod_asegurado = recprea1.cod_reclamante
			) 
			where cod_reclamante like "%" || TRIM(a_busqueda_recla) || "%"
			order by 12 desc
				let TempString = _comentario;
				LET TempString =  REPLACE(TempString, "“", '');
				LET TempString =  REPLACE(TempString, '”', '');

				let _comentario = TempString;

				RETURN	_no_aprobacion,    	
						_reclamante,		  	
						_cedula,				
						_comentario,			
						_no_documento,		
						_cod_cpt1,			
						_cod_icd1,			
						_autorizado_por,		
						_cod_reclamante,		
						_fecha_autorizacion,	
						_no_unidad,			
						_fecha_solicitud,		
						_estado,				
						_fecha_autorizacion_1,
						_cod_cliente
						WITH RESUME;
		end foreach
	else
		foreach
			SELECT SKIP a_indice FIRST a_total no_aprobacion, 
									reclamante, 
									cedula, 
									comentario, 
									no_documento, 
									cod_cpt1, 
									cod_icd1, 
									autorizado_por, 
									cod_reclamante, 
									fecha_autorizacion, 
									no_unidad, 
									fecha_solicitud, 
									estado, 
									fecha_autorizacion_1, 
									cod_cliente 
							  into  _no_aprobacion, 
									_reclamante, 
									_cedula, 
									_comentario, 
									_no_documento, 
									_cod_cpt1, 
									_cod_icd1, 
									_autorizado_por, 
									_cod_reclamante, 
									_fecha_autorizacion, 
									_no_unidad, 
									_fecha_solicitud, 
									_estado, 
									_fecha_autorizacion_1, 
									_cod_cliente 			  
			FROM
			(
			SELECT recprea1.no_aprobacion, cliclien.nombre as reclamante, cliclien.cedula, recprea1.comentario,
			recprea1.no_documento, recprea1.cod_cpt1, recprea1.cod_icd1, recprea1.autorizado_por, recprea1.cod_reclamante, year(fecha_autorizacion) as fecha_autorizacion,
			emipouni.no_unidad, date(fecha_solicitud) as fecha_solicitud, estado, date(fecha_autorizacion) as fecha_autorizacion_1, recprea1.cod_cliente
			from emipomae
			inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
			inner join recprea1 on recprea1.no_documento =  emipomae.no_documento
			inner join cliclien on cliclien.cod_cliente =  recprea1.cod_reclamante
			inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
			inner join emidepen on emipouni.no_poliza = emidepen.no_poliza
			where emipoagt.cod_agente = a_cod_agente and recprea1.no_documento = a_nodocumento
			and emidepen.cod_cliente = recprea1.cod_reclamante and emidepen.no_unidad = emipouni.no_unidad
			UNION
			SELECT recprea1.no_aprobacion, cliclien.nombre as reclamante, cliclien.cedula, recprea1.comentario, recprea1.no_documento,
			recprea1.cod_cpt1, recprea1.cod_icd1, recprea1.autorizado_por, recprea1.cod_reclamante, year(fecha_autorizacion), no_unidad,
			date(fecha_solicitud), estado, date(fecha_autorizacion), recprea1.cod_cliente
			from emipomae
			inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
			inner join recprea1 on recprea1.no_documento =  emipomae.no_documento
			inner join cliclien on cliclien.cod_cliente =  recprea1.cod_reclamante
			inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
			where emipoagt.cod_agente = a_cod_agente and recprea1.no_documento = a_nodocumento
			and emipouni.cod_asegurado = recprea1.cod_reclamante
			) 
			order by 12 desc
				let TempString = _comentario;
				LET TempString =  REPLACE(TempString, "“", '');
				LET TempString =  REPLACE(TempString, '”', '');

				let _comentario = TempString;

				RETURN	_no_aprobacion,    	
						_reclamante,		  	
						_cedula,				
						_comentario,			
						_no_documento,		
						_cod_cpt1,			
						_cod_icd1,			
						_autorizado_por,		
						_cod_reclamante,		
						_fecha_autorizacion,	
						_no_unidad,			
						_fecha_solicitud,		
						_estado,				
						_fecha_autorizacion_1,
						_cod_cliente
						WITH RESUME;
		end foreach
	end if
END PROCEDURE;