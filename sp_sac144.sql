-- *********************************
-- Procedimiento que genera el reporte de Comprobantes actualizados
-- Creado : Henry Giron Fecha : 11/01/2010
-- d_sac_sp_sac145_dw1
-- *********************************
DROP PROCEDURE sp_sac144;

CREATE PROCEDURE sp_sac144(a_db CHAR(18), a_notrx integer, a_comp char(8) ) 
RETURNING integer,
            char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

if a_db = "sac" then

	select *
	  from sac:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	  into temp tmp_cglresumen;

	select *
	  from sac:cglresumen1 
	 WHERE res1_noregistro  in
	 (	select res_noregistro
	  from sac:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	 )
--	   and res1_comprobante like a_comp
	  into temp tmp_cglresumen1;

	select *
	  from sac:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac001" then

	select *
	  from sac001:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	  into temp tmp_cglresumen;

	select *
	  from sac001:cglresumen1 
	 WHERE res1_noregistro  in
	 (	select res_noregistro
	  from sac001:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	 )
--	   and res1_comprobante like a_comp
	  into temp tmp_cglresumen1;
	select *
	  from sac001:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac001:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac001:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac002" then

	select *
	  from sac002:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	  into temp tmp_cglresumen;

	select *
	  from sac002:cglresumen1 
	 WHERE res1_noregistro  in
	 (	select res_noregistro
	  from sac002:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	 )
--	   and res1_comprobante like a_comp
	  into temp tmp_cglresumen1;

	select *
	  from sac002:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac002:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac002:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac003" then

	select *
	  from sac003:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	  into temp tmp_cglresumen;

	select *
	  from sac003:cglresumen1 
	 WHERE res1_noregistro  in
	 (	select res_noregistro
	  from sac003:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	 )
--	   and res1_comprobante like a_comp
	  into temp tmp_cglresumen1;

	select *
	  from sac003:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac003:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac003:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac004" then

	select *
	  from sac004:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	  into temp tmp_cglresumen;

	select *
	  from sac004:cglresumen1 
	 WHERE res1_noregistro  in
	 (	select res_noregistro
	  from sac004:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	 )
--	   and res1_comprobante like a_comp
	  into temp tmp_cglresumen1;

	select *
	  from sac004:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac004:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac004:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac005" then

	select *
	  from sac005:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	  into temp tmp_cglresumen;

	select *
	  from sac005:cglresumen1 
	 WHERE res1_noregistro  in
	 (	select res_noregistro
	  from sac005:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	 )
--	   and res1_comprobante like a_comp
	  into temp tmp_cglresumen1;

	select *
	  from sac005:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac005:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac005:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac006" then

	select *
	  from sac006:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	  into temp tmp_cglresumen;

	select *
	  from sac006:cglresumen1 
	 WHERE res1_noregistro  in
	 (	select res_noregistro
	  from sac006:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	 )
--	   and res1_comprobante like a_comp
	  into temp tmp_cglresumen1;

	select *
	  from sac006:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac006:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac006:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac007" then

	select *
	  from sac007:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	  into temp tmp_cglresumen;

	select *
	  from sac007:cglresumen1 
	 WHERE res1_noregistro  in
	 (	select res_noregistro
	  from sac007:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	 )
--	   and res1_comprobante like a_comp
	  into temp tmp_cglresumen1;

	select *
	  from sac007:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac007:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac007:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac008" then

	select *
	  from sac008:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	  into temp tmp_cglresumen;

	select *
	  from sac008:cglresumen1 
	 WHERE res1_noregistro  in
	 (	select res_noregistro
	  from sac008:cglresumen 
	 WHERE res_notrx  = a_notrx
	   and res_comprobante like a_comp
	 )
--	   and res1_comprobante like a_comp
	  into temp tmp_cglresumen1;

	select *
	  from sac008:cglconcepto
	  into temp tmp_cglconcepto;

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