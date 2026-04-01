-- Reporte para el jefe jesus
-- creado   :09/02/2022 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_web67;

CREATE PROCEDURE "informix".sp_web67(a_nodocumento char(21), a_cod_agente char(5))
		RETURNING 	integer;

define _count_uni          	integer;
define _count_dep    		integer;
define _count_total    		integer; 

SET ISOLATION TO DIRTY READ;
/*
	SELECT count(*)
	  into _count_dep
	  from emipomae
	 inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
	 inner join recprea1 on recprea1.no_documento = emipomae.no_documento
	 inner join cliclien on cliclien.cod_cliente = recprea1.cod_reclamante
	 inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
	 inner join emidepen on emipouni.no_poliza = emidepen.no_poliza
	 where emipoagt.cod_agente = a_cod_agente 
	   and recprea1.no_documento = a_nodocumento
	   and emidepen.cod_cliente = recprea1.cod_reclamante 
	   and emidepen.no_unidad = emipouni.no_unidad;


	SELECT count(*)
	  into _count_uni
	  from emipomae
     inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
     inner join recprea1 on recprea1.no_documento = emipomae.no_documento
     inner join cliclien on cliclien.cod_cliente = recprea1.cod_reclamante
     inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
     where emipoagt.cod_agente = a_cod_agente 
	   and recprea1.no_documento = a_nodocumento
       and emipouni.cod_asegurado = recprea1.cod_reclamante;
	   
	let  _count_total = _count_uni + _count_dep;
	*/
SELECT count(*)
  into _count_total
  FROM
	(
	SELECT recprea1.no_aprobacion, cliclien.nombre as reclamante, cliclien.cedula, recprea1.comentario,
			recprea1.no_documento, recprea1.cod_cpt1, recprea1.cod_icd1, recprea1.autorizado_por, recprea1.cod_reclamante, year(fecha_autorizacion) as fecha_autorizacion,
			emipouni.no_unidad, date(fecha_solicitud) as fecha_solicitud, estado, date(fecha_autorizacion) as fecha_autorizacion_1, recprea1.cod_cliente
	  from emipomae
	 inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
	 inner join recprea1 on recprea1.no_documento = emipomae.no_documento
	 inner join cliclien on cliclien.cod_cliente = recprea1.cod_reclamante
	 inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
	 inner join emidepen on emipouni.no_poliza = emidepen.no_poliza
	 where emipoagt.cod_agente = a_cod_agente 
	   and recprea1.no_documento = a_nodocumento
	   and emidepen.cod_cliente = recprea1.cod_reclamante
	   and emidepen.no_unidad = emipouni.no_unidad
	union
	SELECT recprea1.no_aprobacion, cliclien.nombre as reclamante, cliclien.cedula, recprea1.comentario,
			recprea1.no_documento, recprea1.cod_cpt1, recprea1.cod_icd1, recprea1.autorizado_por, recprea1.cod_reclamante, year(fecha_autorizacion) as fecha_autorizacion,
			emipouni.no_unidad, date(fecha_solicitud) as fecha_solicitud, estado, date(fecha_autorizacion) as fecha_autorizacion_1, recprea1.cod_cliente
	  from emipomae
	 inner join emipoagt on emipoagt.no_poliza = emipomae.no_poliza
	 inner join recprea1 on recprea1.no_documento = emipomae.no_documento
	 inner join cliclien on cliclien.cod_cliente = recprea1.cod_reclamante
	 inner join emipouni on emipouni.no_poliza = emipomae.no_poliza
	 where emipoagt.cod_agente = a_cod_agente 
	   and recprea1.no_documento = a_nodocumento
	   and emipouni.cod_asegurado = recprea1.cod_reclamante
       );	
	return _count_total;

END PROCEDURE;