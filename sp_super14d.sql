-- Informe de Reclamos por Ramo
-- 
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec03a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_super14d;
CREATE PROCEDURE sp_super14d() 
RETURNING char(5),char(3),CHAR(20),date,decimal(16,2); 

DEFINE _no_poliza        		CHAR(10);
define _no_endoso               char(10);
define _cod_agente               char(5);
define _cod_endomov               char(3);
define _no_documento            char(20);
define _prima_suscrita          decimal(16,2);
define _cnt                     integer;
define _fecha_emision date;

SET ISOLATION TO DIRTY READ;


foreach
	select distinct e.no_poliza,e.no_documento,t.cod_agente
      into _no_poliza,_no_documento,_cod_agente
	  from endedmae e, endmoage t
	 where e.no_poliza = t.no_poliza
       and e.no_endoso = t.no_endoso
       and e.actualizado  = 1
	   and e.no_endoso = '00000'
	   and e.periodo between '2016-10' and '2017-09'
       and t.cod_agente in ('00473','02243')
	   
	{select count(*)
	  into _cnt
	  from endmoage
	 where no_poliza = _no_poliza
       and cod_agente <> '00473';
    if _cnt is null then
		let _cnt = 0;
    end if
	if _cnt > 0 then
		insert into fis_concurso(no_documento, pri_sus_pag)
		values (_no_documento, 0);
	end if}
	
	select max(fecha_emision)
	  into _fecha_emision
	  from endedmae
	 where no_poliza = _no_poliza
       and actualizado = 1
       and cod_endomov in('012','031')
       and periodo >= '2017-09';
	   
    
    if _fecha_emision is null then
		select sum(prima_suscrita),max(fecha_emision)
		  into _prima_suscrita,_fecha_emision
		  from endedmae
		 where no_poliza = _no_poliza
		   and actualizado = 1
		   and cod_endomov in('002')
		   and periodo <= '2017-09'
		   and fecha_emision >= '28/09/2017';

		if _fecha_emision is not null then
			return _cod_agente,'002',_no_documento,_fecha_emision,_prima_suscrita with resume;
		end if
	else
		select sum(prima_suscrita)
		  into _prima_suscrita
		  from endedmae
		 where no_poliza = _no_poliza
          and actualizado = 1;		 
	
		return _cod_agente,'031',_no_documento,_fecha_emision,_prima_suscrita with resume;
	end if

end foreach
--return "Listo",0;
END PROCEDURE;




