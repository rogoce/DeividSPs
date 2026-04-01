-- Procedure que retorna las reservas y los deducibles

drop procedure sp_rec225a;

create procedure sp_rec225a()
returning char(50),
          char(20),
          char(20),
		  char(5),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  date;


define _filtros				char(255);
define _nom_cobertura		char(50);
define _nom_ramo			char(50);
define _no_documento		char(20);
define _numrecla			char(20);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _cod_ramo			char(3);
define _cod_cobertura   	char(5);
define _reserva_inicial		dec(16,2);
define _reserva_actual		dec(16,2);
define _deducible			dec(16,2);
define _estatus_audiencia	smallint;
define _fecha_reclamo		date;

call sp_rec02("001", "001", "2014-01") returning _filtros;

foreach
	select numrecla,
		   no_reclamo,
		   no_poliza,
		   cod_ramo
	  into _numrecla,
		   _no_reclamo,
		   _no_poliza,
		   _cod_ramo
	  from tmp_sinis
	 where cod_ramo in ("002", "020")

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select estatus_audiencia,
		   fecha_reclamo
	  into _estatus_audiencia,
		   _fecha_reclamo
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	
	{if _estatus_reclamo = 1 then
		let _estatus_recl = 'Ganado';
	elif
	end if}
	
	foreach
		select cod_cobertura,
			   reserva_actual,
			   reserva_inicial,
			   deducible
		  into _cod_cobertura,
			   _reserva_actual,
			   _reserva_inicial,
			   _deducible
		  from recrccob
		 where no_reclamo = _no_reclamo
		
		select nombre
		  into _nom_cobertura
		  from prdcober
		 where cod_cobertura = _cod_cobertura;

		return _nom_ramo,
			   _numrecla,
			   _no_documento,
			   _cod_cobertura,
			   _nom_cobertura,
			   _deducible,
			   _reserva_inicial,
			   _reserva_actual,
			   _fecha_reclamo
			   with resume;
	end foreach
end foreach

drop table tmp_sinis;

end procedure