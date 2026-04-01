-- Procedimiento adicion de corredor con porcentaje de comision
-- Creado    : 04/09/2018 - Autor: Henry Girón

drop procedure sp_pro224;
create procedure sp_pro224(a_no_poliza char(10))
returning	char(50) as nombre_agente,            
			char(15) as tipo_agente,
			char(10) as no_licencia,
			char(16) as porc_comis_agt;

define _error_desc		char(50);
define _error_isam		integer;
define _error			integer;
define _porc_comis_agt	char(16);
define _porc_comis		char(16);
define _no_licencia		char(10);
define _nombre_agente	char(50);
define _tipo_agente	    char(1);
define _desc_tipo       char(15);
define _cod_ramo        char(3);
define _nueva_renov     char(1);

--set debug file to "sp_pro224.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return '',_error, _error_desc,0;
end exception

let _desc_tipo = '';

FOREACH
  SELECT agtagent.nombre,   
		 agtagent.tipo_agente,   
		 agtagent.no_licencia,   		 
		 emipoagt.porc_comis_agt  --||' %'				 
	INTO _nombre_agente,
		 _tipo_agente,   
		 _no_licencia,   
		 _porc_comis
	FROM emipoagt,   
		 agtagent  
   WHERE agtagent.cod_agente = emipoagt.cod_agente 
     AND emipoagt.no_poliza = a_no_poliza 
	 
	-- let _porc_comis_agt = _porc_comis; --||' %' ;		 
		 
		 select cod_ramo, nueva_renov
		 into _cod_ramo,_nueva_renov
		 from emipomae 
		 where no_poliza = a_no_poliza;
		 
		 let _porc_comis_agt = '';
		 
		 if _cod_ramo in ('018','016') then		 		   
			  if _nueva_renov = 'N' or _nueva_renov = 'R' then
			     let _porc_comis_agt = _porc_comis;
			  end if
		 end if
		 
         let _desc_tipo = '';
		 if _tipo_agente = 'A' then
		     let _desc_tipo = 'PJ '||trim(_no_licencia);
                end if
		 if _tipo_agente = 'N' then
		     let _desc_tipo = 'PN '||trim(_no_licencia);
		end if

	return _nombre_agente,
		   _desc_tipo,   
		   _no_licencia,   
		   _porc_comis_agt									
	   with resume;		   

END FOREACH

END

end procedure 