-- Procedimiento que determina el codigo de corredor deacuerdo al periodo del concurso

drop procedure sp_sis101a;
create procedure sp_sis101a(a_no_documento char(20))
returning smallint;
          
define _porc_partic_agt     decimal(16,4);
define _cnt                 integer;
define _no_poliza           char(10);
define _no_endoso           char(10);
define _cod_agente          char(10);

BEGIN

--set debug file to "sp_sis29.trc";
--trace on;

set isolation to dirty read;

drop table if exists tmp_corr;

CREATE TEMP TABLE tmp_corr(
		cod_agente           CHAR(10)  NOT NULL,
		porcentaje           DEC(16,4) DEFAULT 0
) WITH NO LOG;

select count(*)
  into _cnt
  from endedmae
 where actualizado = 1
   and cod_endomov in('012','031')
  -- and vigencia_inic <= '30/09/2017'
   --and fecha_emision > '30/09/2017'
   and no_documento = a_no_documento;
   
if _cnt is null then
	let _cnt = 0;
end if

let _no_poliza = null;
if _cnt = 0 then
	select min(no_poliza),min(no_endoso)
	  into _no_poliza,_no_endoso
	  from endedmae
	 where actualizado = 1
	   and cod_endomov in('012','031')
	   and vigencia_inic > '30/09/2017'
	   and fecha_emision <= '30/09/2017'
	   and no_documento = a_no_documento;
	   
    if _no_poliza is null then
		let _no_poliza = sp_sis21(a_no_documento);
		foreach
			select cod_agente,
				   porc_partic_agt
			  into _cod_agente,
				   _porc_partic_agt
			  from emipoagt
			 where no_poliza = _no_poliza
			 
			insert into tmp_corr(cod_agente, porcentaje)
			values(_cod_agente,_porc_partic_agt);
				   
		end foreach
	else
		foreach
			select cod_agente,porc_partic_agt
			  into _cod_agente,_porc_partic_agt
			  from endmoage
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
		   
			insert into tmp_corr(cod_agente, porcentaje)
			values(_cod_agente,_porc_partic_agt);
		end foreach
    end if	
else
	foreach
		select no_poliza,no_endoso,max(fecha_emision)
		  into _no_poliza,_no_endoso,_fecha_emision
		  from endedmae
		 where actualizado = 1
		   and cod_endomov in('012','031')
		   and vigencia_inic <= '30/09/2017'
		   and fecha_emision > '30/09/2017'
		   and no_documento = a_no_documento
		order by 2 desc
		exit foreach;
	end foreach
	
	foreach
		select cod_agente,porc_partic_agt
		  into _cod_agente,_porc_partic_agt
		  from endmoage
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
	   
		insert into tmp_corr(cod_agente, porcentaje)
		values(_cod_agente,_porc_partic_agt);
	end foreach
end if
end

return 0;

end procedure;

