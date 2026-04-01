--Procedimiento para eliminar los registros iguales del numero de licencia y sacar a nuestros corredores
--Armando Moreno M. 20/06/2016

drop procedure sp_che230bk;

create procedure "informix".sp_che230bk(a_usuario char(8))
RETURNING smallint,char(25);

define _no_licencia char(10);
define _cnt         integer;
define _cod_agente  char(10);
define _n_agente    char(50);
define _fecha_hoy   date;
define _tipo_licencia char(1);


--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

SET LOCK MODE TO WAIT;

let _fecha_hoy = current;

CREATE TEMP TABLE tmp_agtmor
         (no_licencia      char(10),
          cantidad         integer,
		  tipo_licencia    char(1))
          WITH NO LOG;
foreach

	select count(*),
	       no_licencia,
		   tipo_licencia
	  into _cnt,
           _no_licencia,
		   _tipo_licencia
      from agt_mor
  group by no_licencia,tipo_licencia
 having count(*) > 1
 
	 insert into tmp_agtmor(no_licencia,cantidad,tipo_licencia)
	 values(_no_licencia,_cnt,_tipo_licencia);
	   
end foreach

foreach
	select no_licencia,cantidad,tipo_licencia
	  into _no_licencia,_cnt,_tipo_licencia
	  from tmp_agtmor
	
	delete from agt_mor
	where no_licencia = _no_licencia
	  and tipo_licencia = _tipo_licencia;
	
	 insert into agt_mor(no_licencia,fecha,tipo_licencia)
	 values(_no_licencia,today,_tipo_licencia);
	  
end foreach

drop table tmp_agtmor;

--Borra los registros de agt_morosos y busca solo a nuestros corredores e inserta los procedentes del nuevo baje en agt_morosos
delete from agt_morosos;

Foreach
	select no_licencia,
	       tipo_licencia
	  into _no_licencia,
	       _tipo_licencia
	  from agt_mor
  order by no_licencia
	  
    let _n_agente = null;
	
	foreach
		select nombre,
			   cod_agente
		  into _n_agente,
			   _cod_agente
		  from agtagent
		 where no_licencia = _no_licencia
		   and tipo_persona = _tipo_licencia
		 exit foreach;
	end foreach 
	if _n_agente is null then
	else
		insert into agt_morosos(no_licencia,cod_agente,nombre)
		values(_no_licencia,_cod_agente,_n_agente);
	end if
	  
End Foreach

return 0,'Proceso Completado';
END
end procedure