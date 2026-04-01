-- Presentar los datos de historico de vacaciones.

-- Creado     : 07/10/2010 - Autor: Armando Moreno M.
-- Modificado : 07/10/2010 - Por  : Armando Moreno M.

DROP PROCEDURE sp_pla004;

create procedure "informix".sp_pla004(a_usuario char(8))
returning char(50), datetime year to fraction(5), char(8), date, date, varchar(25);

define _n_usuario    char(50);
define _date_added   datetime year to fraction(5);
define _user_added   char(8);
define _fec_vac_ini  date;
define _fec_vac_fin  date;
define _cod_motivo   char(3);
define _n_desc       varchar(25);

SET ISOLATION TO DIRTY READ;

foreach 
	 select date_added, 
	        user_added, 
	        fec_vac_ini,
		    fec_vac_fin,
			cod_motivo
	   into _date_added, 
		    _user_added, 
		    _fec_vac_ini,
		    _fec_vac_fin,
			_cod_motivo
	   from rrhvachi
	  where usuario = a_usuario

	select descripcion
	  into _n_usuario
	  from insuser
	 where usuario = a_usuario;

	select descripcion
	  into _n_desc
	  from rrhmotiv
	 where cod_motivo = _cod_motivo;

	 return _n_usuario,
			_date_added,
			_user_added,
			_fec_vac_ini,
			_fec_vac_fin,
			_n_desc
	   with resume;
		   
end foreach;
end procedure;
