drop procedure sp_sac20;

create procedure "informix".sp_sac20()
returning char(12),
		  char(50),
		  char(1),
		  char(2),
		  char(1),
		  char(1);

define _cta_cuenta		char(12);
define _cta_nombre		char(50);
define _cta_tipo		char(1);
define _cta_subtipo		char(2);
define _cta_tippartida	char(1);
define _cta_recibe		char(1);

foreach
 select cta_cuenta,
		cta_nombre,
		cta_tipo,
		cta_subtipo,
		cta_tippartida,
		cta_recibe
   into _cta_cuenta,
		_cta_nombre,
		_cta_tipo,
		_cta_subtipo,
		_cta_tippartida,
		_cta_recibe
   from cglcuentas
  order by 1 	

	return _cta_cuenta,
		   _cta_nombre,
		   _cta_tipo,
		   _cta_subtipo,
		   _cta_tippartida,
		   _cta_recibe
		   with resume;

end foreach

end procedure