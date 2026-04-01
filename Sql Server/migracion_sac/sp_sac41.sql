-- Procedure que Retorna en que periodo de cierre esta la compania de contabilidad seleccionada
-- 
-- Creado    : 05/10/2005 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/10/2005 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sac_sp_sac01_crit - DEIVID, S.A.

drop procedure sp_sac41;

create procedure "informix".sp_sac41(a_database char(18))
returning char(4),
          char(10);

define _par_mesfiscal	char(2);
define _par_anofiscal 	char(4);

define _mes				smallint;
define _nombre_mes		char(10);

--set debug file to "sp_sac41.trc";
--trace on;

set isolation to dirty read;

let _par_mesfiscal = null;
let _par_anofiscal = null;
 

if a_database = "sac" then

	select par_mesfiscal,
		   par_anofiscal
	  into _par_mesfiscal,
		   _par_anofiscal
	  from sac:cglparam;

elif a_database = "sac001" then

	select par_mesfiscal,
		   par_anofiscal
	  into _par_mesfiscal,
		   _par_anofiscal
	  from sac001:cglparam;

elif a_database = "sac002" then

	select par_mesfiscal,
		   par_anofiscal
	  into _par_mesfiscal,
		   _par_anofiscal
	  from sac002:cglparam;

elif a_database = "sac003" then

	select par_mesfiscal,
		   par_anofiscal
	  into _par_mesfiscal,
		   _par_anofiscal
	  from sac003:cglparam;

elif a_database = "sac004" then

	select par_mesfiscal,
		   par_anofiscal
	  into _par_mesfiscal,
		   _par_anofiscal
	  from sac004:cglparam;

elif a_database = "sac005" then

	select par_mesfiscal,
		   par_anofiscal
	  into _par_mesfiscal,
		   _par_anofiscal
	  from sac005:cglparam;

elif a_database = "sac006" then

	select par_mesfiscal,
		   par_anofiscal
	  into _par_mesfiscal,
		   _par_anofiscal
	  from sac006:cglparam;

elif a_database = "sac007" then

	select par_mesfiscal,
		   par_anofiscal
	  into _par_mesfiscal,
		   _par_anofiscal
	  from sac007:cglparam;

elif a_database = "sac008" then

	select par_mesfiscal,
		   par_anofiscal
	  into _par_mesfiscal,
		   _par_anofiscal
	  from sac008:cglparam;

end if

let _mes = _par_mesfiscal;
let _nombre_mes = sp_sac18(_mes);

return _par_anofiscal,
       _nombre_mes;

end procedure
