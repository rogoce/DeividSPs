drop procedure sp_pro104a;

create procedure "informix".sp_pro104a()
returning char(20),date,varchar(255),date,date,char(8);


define _cantidad		smallint;
define _no_documento    char(20);
define _descripcion     varchar(255);
define _no_poliza		char(10);
define _vigencia_inic   date;
define _vigencia_final  date;
define _fecha_aviso     date;
define _user_added      char(8);

set isolation to dirty read;

foreach

 select no_documento,
		fecha_aviso,
		descripcion,
		no_poliza,
		user_added
   into _no_documento,
		_fecha_aviso,
		_descripcion,
		_no_poliza,
		_user_added
   from eminotas
  where procesado   = 0
    and fecha_aviso <= today
    and fecha_aviso is not null

 select vigencia_inic,
		vigencia_final
   into _vigencia_inic,
        _vigencia_final
   from emipomae
  where no_poliza = _no_poliza;

 RETURN	_no_documento,
		_fecha_aviso,
		_descripcion,
		_vigencia_inic,
		_vigencia_final,
		_user_added
   WITH RESUME;

end foreach

end procedure