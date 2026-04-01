drop procedure sp_sac180;

create procedure "informix".sp_sac180(a_db char(18))
returning char(12),
		  char(50),
		  char(1),
		  char(2),
		  char(1),
		  char(1),
		  char(50);

define _cta_cuenta		char(12);
define _cta_nombre		char(50);
define _cta_tipo		char(1);
define _cta_subtipo		char(2);
define _cta_tippartida	char(1);
define _cta_recibe		char(1);
define _cia_nom		    char(50);

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = a_db;

if a_db = "sac" then

	select *
	  from sac:cglcuentas
	  into temp tmp_cglcuentas;

elif a_db = "sac001" then

	select *
	  from sac001:cglcuentas
	  into temp tmp_cglcuentas;

elif a_db = "sac002" then

	select *
	  from sac002:cglcuentas
	  into temp tmp_cglcuentas;

elif a_db = "sac003" then

	select *
	  from sac003:cglcuentas
	  into temp tmp_cglcuentas;

elif a_db = "sac004" then

	select *
	  from sac004:cglcuentas
	  into temp tmp_cglcuentas;

elif a_db = "sac005" then

	select *
	  from sac005:cglcuentas
	  into temp tmp_cglcuentas;

elif a_db = "sac006" then

	select *
	  from sac006:cglcuentas
	  into temp tmp_cglcuentas;

elif a_db = "sac007" then

	select *
	  from sac007:cglcuentas
	  into temp tmp_cglcuentas;

elif a_db = "sac008" then

	select *
	  from sac008:cglcuentas
	  into temp tmp_cglcuentas;

end if



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
   from tmp_cglcuentas
  order by 1 	

	return _cta_cuenta,
		   _cta_nombre,
		   _cta_tipo,
		   _cta_subtipo,
		   _cta_tippartida,
		   _cta_recibe,
		   _cia_nom
		   with resume;

cuenta
nombre

end foreach

drop table tmp_cglcuentas;
end procedure