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
define _cnt_persona     integer;

let _agt_txt    = '';
let _visto      = 0;
let _cnt_persona = 0;

SELECT count(*)
  INTO _cnt
  FROM emipoagt,
       agtagent
 WHERE agtagent.cod_agente = emipoagt.cod_agente  
   AND emipoagt.no_poliza = a_no_poliza;
		 
	if _cnt is null then
	   let _cnt = 0;
	end if	 		 

if _cnt >= 1 then	
		foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  " PN "||trim(agtagent.no_licencia)
					else
						  " PJ "||trim(agtagent.no_licencia)
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
	
------------------------------------Anterior--------------------------------------------------29/01/2020
--if  ( (trim(ramo) = 'SALUD' or trim(ramo) = 'COLECTIVO DE VIDA') and (tipo_factura = 'NUEVA' or tipo_factura = 'RENOVAR')  ,1,0)  
{  -- HGIRON: solicitud de quitar %Comision Correo Jbrito 29/01/2020
if _cnt > 1 then

	select count(*) 
	  into _cnt_persona
	  from emipomae 
	 where no_poliza = a_no_poliza and cod_ramo in ( '004','016','018','019');  -- Ramos de Persona: ASTANCIO al 2/1/2019 por SKY
		if _cnt_persona is null then
		   let _cnt_persona = 0;
		end if
		
	if _cnt_persona = 0 then
		foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  " PN "||trim(agtagent.no_licencia)
					else
						  " PJ "||trim(agtagent.no_licencia)
					end)
			  ELSE  " "
					end))
			  INTO _agt_txt		 
			  FROM emipoagt,
				   agtagent
			 WHERE agtagent.cod_agente = emipoagt.cod_agente  
			   AND emipoagt.no_poliza = a_no_poliza
			 order by 1
			  --EXIT foreach;
			  return _agt_txt,_visto with resume;
		end foreach	
	else
	    let _visto      = 1;
		foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  " PN "||trim(agtagent.no_licencia)
					else
						  " PJ "||trim(agtagent.no_licencia)
					end)
			  ELSE  " "
					end)||" | CR: "||trim(cast(cast(emipoagt.porc_comis_agt as int) as char(3))) ||' % ' )
			  INTO _agt_txt		 
			  FROM emipoagt,
				   agtagent
			 WHERE agtagent.cod_agente = emipoagt.cod_agente  
			   AND emipoagt.no_poliza = a_no_poliza
			 order by 1
			  --EXIT foreach;
			  return _agt_txt,_visto with resume;
		end foreach		
	end if
	
else
	if _cnt = 1 then
	
		select count(*) 
		  into _cnt_persona
		  from emipomae 
		 where no_poliza = a_no_poliza and cod_ramo in ( '004','016','018','019');  -- Ramos de Persona: ASTANCIO al 2/1/2019 por SKY
			if _cnt_persona is null then
			   let _cnt_persona = 0;
			end if
			
		if _cnt_persona = 0 then
	
				foreach
				 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
						(case  when agtagent.tipo_persona = 'N' then
							  " PN "||trim(agtagent.no_licencia)
						else
							  " PJ "||trim(agtagent.no_licencia)
						end)
				  ELSE  " "
						end) )
				  INTO _agt_txt		 
				  FROM emipoagt,
					   agtagent
				 WHERE agtagent.cod_agente = emipoagt.cod_agente  
				   AND emipoagt.no_poliza = a_no_poliza
				 order by 1		
				end foreach	
		else
		    let _visto      = 1;
			foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  " PN "||trim(agtagent.no_licencia)
					else
						  " PJ "||trim(agtagent.no_licencia)
					end)
			  ELSE  " "
					end)||" | CR: "||trim(cast(cast(emipoagt.porc_comis_agt as int) as char(3))) ||' % ' )
			  INTO _agt_txt		 
			  FROM emipoagt,
				   agtagent
			 WHERE agtagent.cod_agente = emipoagt.cod_agente  
			   AND emipoagt.no_poliza = a_no_poliza
			 order by 1		
			end foreach			
		
		end if
	else	
		let _agt_txt = "";
	end if
	
	return _agt_txt,_visto;
end if
}

end procedure