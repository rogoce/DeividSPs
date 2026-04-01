-- Retorna los Reclamos de Una Poliza
-- 
-- Creado    : 16/05/2012 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_atc16;

create procedure sp_atc16(a_no_documento char(20))
returning char(5),
          char(20),
		  date,
		  date,
		  char(50),
		  char(50);

define _nom_asegurado	char(50);
define _reclamante		char(50);
define _numrecla		char(20);
define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_reclamante	char(5);
define _cod_asegurado	char(5);
define _no_unidad		char(5);
define _fecha_siniestro	date;
define _fecha_reclamo	date;
define _cnt_rec			integer;


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_atc16.trc";
--trace on;


foreach
	select distinct no_unidad,
		   cod_reclamante	
	  into _no_unidad,
		   _cod_reclamante	
	  from recrcmae
	 where no_documento		matches a_no_documento
	   and actualizado		= 1
	   --and estatus_reclamo	= 'A'

	call sp_sis21(a_no_documento) returning _no_poliza;

	select cod_asegurado
	  into _cod_asegurado
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	select nombre
	  into _nom_asegurado
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	
	select nombre
	  into _reclamante
	  from cliclien
	 where cod_cliente = _cod_reclamante;
	
	select count(*)
	  into _cnt_rec
	  from recrcmae
	 where actualizado  = 1
	   and no_documento matches a_no_documento
	   and no_unidad    = _no_unidad;

	if _cnt_rec > 1 then
		let _numrecla			= 'Varios';
		let _fecha_reclamo		= '01/01/1900';
		let _fecha_siniestro	= '01/01/1900';
	else
		select numrecla,
			   fecha_reclamo,
			   fecha_siniestro	
		  into _numrecla,
			   _fecha_reclamo,
			   _fecha_siniestro	
		  from recrcmae 
	 	 where actualizado  = 1
	 	   and no_documento matches a_no_documento
	 	   and no_unidad    = _no_unidad;
	end if

	return _no_unidad,
		   _numrecla,
		   _fecha_reclamo,
		   _fecha_siniestro,
		   _nom_asegurado,
		   _reclamante with resume;

end foreach
end procedure                                                                                                                                                                                                                              
