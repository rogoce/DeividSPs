--Procedimiento texto de comision de agente
--Henry Giron  11/12/2018
-- AMORENO:24/04/2019 Debemos deshabilitar las comisiones en las pólizas para los ramos de personas también
-- se vuelve a colocar segun correo JBRITO
drop procedure sp_sis459;
create procedure sp_sis459(a_no_poliza char(10))
returning char(75) as agt_txt,
          int as visto;

define _agt_txt			char(75);
define _cnt     		integer;
define _visto   		integer;
define _cnt_pp_lic_vida     integer;
define _cnt_persona     integer;
define _agt_ramo		char(3);
define _agt_licencia	char(10);
define _no_documento	char(20);

let _no_documento    = '';
let _agt_txt    = '';
let _visto      = 0;
let _cnt_persona = 0;
let _agt_ramo    = '';
let _agt_licencia    = '';

SELECT count(*)
  INTO _cnt
  FROM emipoagt,
       agtagent
 WHERE agtagent.cod_agente = emipoagt.cod_agente  
   AND emipoagt.no_poliza = a_no_poliza ;
		 
	if _cnt is null then
	   let _cnt = 0;
	end if	 		 

if _cnt >= 1 then	

		select cod_ramo, no_documento
		  into _agt_ramo, _no_documento
		  from emipomae 
		 where no_poliza = a_no_poliza ; --HG:27/6/2023 SD#6947 NJURADO 
			if _agt_ramo is null then
			   let _agt_ramo = '';
			end if			
			

		foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(pp_lic_vida,'') = '' then "PN "||no_licencia	else "PP "||pp_lic_vida end)
								when _agt_ramo = '008' then (case when nvl(pp_lic_fianza,'') = '' then "PN "||no_licencia	else "PP "||pp_lic_fianza end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(pp_lic_general,'') = '' then "PN "||no_licencia	else "PP "||pp_lic_general end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else "PN "||no_licencia end) end) --licencia						  
						  
						  
					else
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(pp_lic_vida,'') = '' then "PJ "||no_licencia	else "PP "||pp_lic_vida end)
								when _agt_ramo = '008' then (case when nvl(pp_lic_fianza,'') = '' then "PJ "||no_licencia	else "PP "||pp_lic_fianza end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(pp_lic_general,'') = '' then "PJ "||no_licencia	else "PP "||pp_lic_general end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else "PJ "||no_licencia end) end) --licencia						  						  
					end)
			  ELSE  " "
					end))
			  INTO _agt_txt		 
			  FROM emipoagt,
				   agtagent
			 WHERE agtagent.cod_agente = emipoagt.cod_agente  
			   AND emipoagt.no_poliza = a_no_poliza
			 order by 1
			 
			  if _cnt > 1 then
				return _agt_txt,_visto with resume;
			end if
			
		end foreach		
		
		 if _cnt = 1 then
			return _agt_txt,_visto;
		end if
else
	return _agt_txt,_visto;
end if		
	

end procedure