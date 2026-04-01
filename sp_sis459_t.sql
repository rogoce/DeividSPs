--Procedimiento texto de comision de agente
--Henry Giron  11/12/2018

drop procedure sp_sis459_t;
create procedure sp_sis459_t(a_no_poliza char(10))
returning char(75) as agt_txt,
          int as visto;

define _agt_txt	char(75);
define _cnt     integer;
define _visto   integer;
define _cnt_persona     integer;
DEFINE _porc_comis          DEC(5,2);
define _cod_ramo		    char(3);
DEFINE _cod_agente          CHAR(5);  
DEFINE _agente_agrupado     CHAR(5);  
DEFINE _cod_grupo  		    CHAR(5); 
define _agt_ramo		char(3);
define _agt_licencia	char(10);
define _no_documento	char(20);


let _agt_txt    = '';
let _visto      = 0;
let _cnt_persona = 0;
let _porc_comis = 0;
let _agente_agrupado = '';
let _agt_ramo    = '';
let _agt_licencia    = '';
let _no_documento    = '';


--if  ( (trim(ramo) = 'SALUD' or trim(ramo) = 'COLECTIVO DE VIDA') and (tipo_factura = 'NUEVA' or tipo_factura = 'RENOVAR')  ,1,0)  

SELECT count(*)
  INTO _cnt
  FROM emipoagt,
       agtagent
 WHERE agtagent.cod_agente = emipoagt.cod_agente  
   AND emipoagt.no_poliza = a_no_poliza;     
		 
	if _cnt is null then
	   let _cnt = 0;
	end if	 		 

if _cnt > 1 then

	select count(*) 
	  into _cnt_persona
	  from emipomae 
	 where no_poliza = a_no_poliza ; --and cod_ramo in ( '004','016','018','019');  -- Ramos de Persona: ASTANCIO al 2/1/2019 por SKY
		if _cnt_persona is null then
		   let _cnt_persona = 0;
		end if
		
	select cod_ramo, no_documento
	  into _agt_ramo, _no_documento
	  from emipomae 
	 where no_poliza = a_no_poliza ; --HG:27/6/2023 SD#6947 NJURADO 
		if _agt_ramo is null then
		   let _agt_ramo = '';
		end if				
		
	if _cnt_persona = 0 then
		foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  " PN "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
					else
						  " PJ "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
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
-- AMORENO:24/04/2019 Debemos deshabilitar las comisiones en las pólizas para los ramos de personas también
{	
	    let _visto      = 1;
		foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  " PN "||trim(agtagent.no_licencia)						  
					else
						  " PJ "||trim(agtagent.no_licencia)
					end)
			  ELSE  " "
					end)||" |CR: "||trim(cast(cast(emipoagt.porc_comis_agt as int) as char(3))) ||'% ' )
			  INTO _agt_txt	
}
		foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  " PN "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
					else
						  " PJ "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
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
	end if
	
else
	if _cnt = 1 then
	
		select count(*) 
		  into _cnt_persona
		  from emipomae 
		 where no_poliza = a_no_poliza; -- and cod_ramo in ( '004','016','018','019');  -- Ramos de Persona: ASTANCIO al 2/1/2019 por SKY
			if _cnt_persona is null then
			   let _cnt_persona = 0;
			end if
		select cod_ramo, no_documento
		  into _agt_ramo, _no_documento
		  from emipomae 
		 where no_poliza = a_no_poliza ; --HG:27/6/2023 SD#6947 NJURADO 
			if _agt_ramo is null then
			   let _agt_ramo = '';
			end if				
			
		if _cnt_persona = 0 then
	
				foreach
				 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
						(case  when agtagent.tipo_persona = 'N' then
							  " PN "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
						else
							  " PJ "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
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
-- AMORENO:24/04/2019 Debemos deshabilitar las comisiones en las pólizas para los ramos de personas también
{		
		    let _visto      = 1;
			foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  " PN "||trim(agtagent.no_licencia)
					else
						  " PJ "||trim(agtagent.no_licencia)
					end)
			  ELSE  " "
					end)||" |CR: "||trim(cast(cast(emipoagt.porc_comis_agt as int) as char(3))) ||'% ' )
			  INTO _agt_txt		 
}			  
		foreach
			 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
					(case  when agtagent.tipo_persona = 'N' then
						  " PN "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
					else
						  " PJ "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
					end)
			  ELSE  " "
					end))
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
	
	select cod_ramo, cod_grupo, cod_agente
	  into _cod_ramo, _cod_grupo, _cod_agente
	  from emipoliza 
	 where no_poliza = a_no_poliza;  
		 
--	if _cod_agente = '02618' or _cod_agente = '02531' or _cod_agente = '02532' then    
--  if _cod_grupo = '1122' or _cod_grupo = '124' or _cod_grupo = '125' then   
if _cod_agente = '02618' or _cod_agente = '02531' or _cod_agente = '02532'  then

     if  _cod_grupo = '1122' or _cod_grupo = '124' or _cod_grupo = '125' or _cod_grupo = '77960' then  -- SD#3010 77960  11/04/2022 10:00
		   
		select porc_comision
		  into _porc_comis
		  from prdramo
		 where cod_ramo = _cod_ramo;
		 
		{
		cod_agente	agente_agrupado	principal	
		02618	02618	CORREDOR DIRECTO (DUCRUET-BANISI)	
		02531	02319	LIZSENELL GIONELLA BERNAL RAMIREZ	
		02532	01001	FELIX ALBERTO ABADIA PRETELT	
		}		 
		 
		foreach
		 SELECT agtagent.agente_agrupado		  
		  INTO _agente_agrupado	 
		  FROM emipoagt,
			   agtagent
		 WHERE agtagent.cod_agente = emipoagt.cod_agente  
		   AND emipoagt.no_poliza = a_no_poliza		  
         order by 1				   
		 
		 if _agente_agrupado in ('02618','02904') then 
		     let _agente_agrupado = '00035';
		 end if
		 
		select cod_ramo, no_documento
		  into _agt_ramo, _no_documento
		  from emipomae 
		 where no_poliza = a_no_poliza ; --HG:27/6/2023 SD#6947 NJURADO 
			if _agt_ramo is null then
			   let _agt_ramo = '';
			end if	
			
		   
		 SELECT (trim(agtagent.nombre)||" "||(case  when agtagent.tipo_agente = 'A' then
				(case  when agtagent.tipo_persona = 'N' then
					  " PN "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
				else
					  " PJ "|| --trim(agtagent.no_licencia)
						  (case when _agt_ramo  in ('004','016','018','019','025')  then (case when nvl(trim(pp_lic_vida),'') = '' then no_licencia	else trim(pp_lic_vida) end)
								when _agt_ramo = '008' then (case when nvl(trim(pp_lic_fianza),'') = '' then no_licencia	else trim(pp_lic_fianza) end)
								when _agt_ramo not in ('004','016','018','019','025','008')  then (case when nvl(trim(pp_lic_general),'') = '' then no_licencia	else trim(pp_lic_general) end)
								else  (case when nvl(_agt_ramo,'') = '' then ''	else no_licencia end) end) 		
				end)
		  ELSE  " "
				end) )
		  INTO _agt_txt		 
		  FROM agtagent
		 WHERE agtagent.cod_agente = _agente_agrupado;	   
		 
		 exit foreach;
		end foreach	
-- AMORENO:24/04/2019 Debemos deshabilitar las comisiones en las pólizas para los ramos de personas también
{		
		let _visto      = 1;
		let _agt_txt = trim(_agt_txt)||" |CR: "||trim(cast(cast( _porc_comis as int) as char(3))) ||'% ' ;
}		
		let _agt_txt = trim(_agt_txt);
	else	
-- AMORENO:24/04/2019 Debemos deshabilitar las comisiones en las pólizas para los ramos de personas también 
--      let _visto      = 1; 
	 	let _agt_txt    = _agt_txt;							
	 end if	

end if		 
	
	
	return _agt_txt,_visto;
end if


end procedure
