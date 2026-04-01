-- *********************************
-- sp_sac181 Procedimiento que retorna el nombre de la  cuenta de sac
-- Creado : Henry Giron Fecha : 21/04/2010
-- *********************************
DROP PROCEDURE sp_sac181;

CREATE PROCEDURE sp_sac181(a_db CHAR(18) ) 
RETURNING integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);	
DEFINE v_nombre_cuenta   CHAR(50);

SET ISOLATION TO DIRTY READ;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

if a_db = "sac" then

	select *
	  from sac:cglcuentas 
	  into temp tmp_cglcuentas;	

	select *
	  from sac:cglterceros 
	  into temp tmp_cglterceros;	

elif a_db = "sac001" then

	select *
	  from sac001:cglcuentas 
	  into temp tmp_cglcuentas;	

	select *
	  from sac001:cglterceros 
	  into temp tmp_cglterceros;	


elif a_db = "sac002" then

	select *
	  from sac002:cglcuentas 
	  into temp tmp_cglcuentas;	

	select *
	  from sac002:cglterceros 
	  into temp tmp_cglterceros;	

elif a_db = "sac003" then

	select *
	  from sac003:cglcuentas 
	  into temp tmp_cglcuentas;	

	select *
	  from sac003:cglterceros 
	  into temp tmp_cglterceros;	

elif a_db = "sac004" then

	select *
	  from sac004:cglcuentas 
	  into temp tmp_cglcuentas;	

	select *
	  from sac004:cglterceros 
	  into temp tmp_cglterceros;	

elif a_db = "sac005" then

	select *
	  from sac005:cglcuentas 
	  into temp tmp_cglcuentas;	

	select *
	  from sac005:cglterceros 
	  into temp tmp_cglterceros;	

elif a_db = "sac006" then

	select *
	  from sac006:cglcuentas 
	  into temp tmp_cglcuentas;	

	select *
	  from sac006:cglterceros 
	  into temp tmp_cglterceros;	

elif a_db = "sac007" then

	select *
	  from sac007:cglcuentas 
	  into temp tmp_cglcuentas;	

	select *
	  from sac007:cglterceros 
	  into temp tmp_cglterceros;	

elif a_db = "sac008" then

	select *
	  from sac008:cglcuentas 
	  into temp tmp_cglcuentas;	

	select *
	  from sac008:cglterceros 
	  into temp tmp_cglterceros;	

end if

end 

return 0, "Actualizacion Exitosa";

end procedure 