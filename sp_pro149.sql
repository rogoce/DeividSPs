-- Procedimiento para verificacion de inf. callcenter

-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_pro149;

create procedure sp_pro149(a_usuario CHAR(8))
returning char(20),date,date,char(8);

define _no_documento    char(20);
define _vigencia_inic	date;
define _vigencia_final	date;
define _usuario			char(8);

foreach
	select no_documento,
		   vigencia_inic,
		   vigencia_final,
		   user_added
	  into _no_documento,
	       _vigencia_inic,
		   _vigencia_final,
		   _usuario
	  from emirepol
	 where user_added = a_usuario
	 order by 1

	  RETURN _no_documento,
			 _vigencia_inic,
	  		 _vigencia_final,
			 _usuario
			with resume;

end foreach
end procedure