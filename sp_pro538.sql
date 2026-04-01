-- Procedure que verifica la informacion de los bajes de ducruet vs los preliminares enviados
-- para determinar si hubo siniestros entre el envio del preliminar y el baje

drop procedure sp_pro538;

create procedure "informix".sp_pro538()
returning char(10),
          char(20),
		  date,
		  date,
		  char(20),
		  date,
		  char(20);

define _num_carga		char(10);
define _no_documento	char(20);
define _fecha_aviso		date;
define _date_added		date;
define _uso_auto		char(20);

define _numrecla		char(20);
define _fecha_siniestro	date;

define _cant_rec		integer;

foreach
 select num_carga,
        date_added
   into _num_carga,
        _date_added
   from prdemielect
  where cod_agente = "00035"
    and proceso    = "R"
	and date_added >= "01/01/2014"

	foreach
	 select	no_documento
	   into	_no_documento
	   from prdemielctdet
      where num_carga   = _num_carga
	    and actualizado = 1

	   foreach	
		select fecha_envio,
		       uso_auto
		  into _fecha_aviso,
		       _uso_auto
          from emirenduc
         where no_documento = _no_documento
           and periodo      >= "2014-01"

		   foreach	
			select numrecla,
			       fecha_siniestro
			  into _numrecla,
			       _fecha_siniestro
			  from recrcmae
			 where no_documento      = _no_documento
			   and actualizado       = 1
			   and fecha_siniestro   >= _fecha_aviso
			   and fecha_siniestro   <= _date_added
			   and estatus_audiencia not in (1, 7)

				return  _num_carga,
			            _no_documento,
			            _fecha_aviso,
					    _date_added,
						_numrecla,
					    _fecha_siniestro,
						_uso_auto
						with resume;

			end foreach

		end foreach

	end foreach

end foreach

return "0", "", null, null, "", null, "";

end procedure