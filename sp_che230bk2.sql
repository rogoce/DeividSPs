--Procedimiento para eliminar los registros iguales del numero de licencia y sacar a nuestros corredores
--Armando Moreno M. 20/06/2016
--se coloca para que inserte las notas 27/04/2018

drop procedure sp_che230;
create procedure "informix".sp_che230(a_usuario char(8))
RETURNING smallint,char(25);

define _no_licencia char(10);
define _cnt         integer;
define _cod_agente  char(10);
define _n_agente    char(50);
define _fecha_hoy   date;
define _tipo_licencia char(1);
define _estatus_licencia char(1);
define ld_fecha_hora	datetime year to fraction(5);
DEFINE _mensaje         varchar(255);

--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

SET LOCK MODE TO WAIT;

let _fecha_hoy = current;
call sp_sis40() returning ld_fecha_hora;

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
	  
    let _n_agente = null;
	
	foreach
		select nombre,
			   cod_agente
		  into _n_agente,
			   _cod_agente
		  from agtagent
		 where no_licencia  = _no_licencia
		   and tipo_persona = _tipo_licencia
		 exit foreach;
	end foreach 
	if _n_agente is null then
	else
		insert into agt_morosos(no_licencia,cod_agente,nombre)
		values(_no_licencia,_cod_agente,_n_agente);
	end if
	  
End Foreach

--Desmarcar corredores Morosos a Activos

Foreach
	select no_licencia,
	       cod_agente,
		   nombre
	  into _no_licencia,
	       _cod_agente,
		   _n_agente
	  from agtagent
	 where estatus_licencia = 'X'
	 
	select count(*)
	  into _cnt
	  from agt_morosos
	 where cod_agente = _cod_agente;
	 
	if _cnt is null then
		let _cnt = 0;
	end if
	--Como el agente NO esta en la tabla de los morosos, se entiende que ya pago y debe estar Activo.
	if _cnt = 0 then
		update agtagent
		   set estatus_licencia = 'A'
		 where cod_agente       = _cod_agente;

		insert into agt_mor_his(cod_agente,no_licencia,nombre,date_added,user_added,estatus)
		values(_cod_agente,_no_licencia,_n_agente,_fecha_hoy,a_usuario,'A');
		
		---Marcar a los corredores agrupados como activos
		update agtagent
		   set estatus_licencia = 'A'
		 where agente_agrupado  = _cod_agente;
		 
		delete from agt_morosos
		where cod_agente = _cod_agente;
		let _mensaje = "SE LIBERA DE MOROSIDAD, SEGUN INFORME DE SUPERINTENDENCIA.";
		insert into agtnotas(cod_agente,fecha_nota,desc_nota,user_added)
		values(_cod_agente,ld_fecha_hora,_mensaje,a_usuario);
		let ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;
	end if
End Foreach

--Marcar corredores Activos a Morosos

Foreach
	select no_licencia,
	       cod_agente,
		   nombre
	  into _no_licencia,
	       _cod_agente,
		   _n_agente
	  from agt_morosos
	  
	--Marcar al corredor como Moroso segun la tabla de morosos del ultimo baje.

	select estatus_licencia
	  into _estatus_licencia
	  from agtagent
	 where cod_agente = _cod_agente;

    if _estatus_licencia in('P','T') then
		continue foreach;
	end if
	
	update agtagent
	   set estatus_licencia = 'X'
	 where cod_agente       = _cod_agente;

	insert into agt_mor_his(cod_agente,no_licencia,nombre,date_added,user_added,estatus)
	values(_cod_agente,_no_licencia,_n_agente,_fecha_hoy,a_usuario,'X');
	
	---Marcar a los corredores agrupados
	update agtagent
	   set estatus_licencia = 'X'
	 where agente_agrupado  = _cod_agente;
	let _mensaje = "SUSPENDIDO POR MOROSIDAD, SEGUN INFORME DE SUPERINTENDEDNCIA.";
	insert into agtnotas(cod_agente,fecha_nota,desc_nota,user_added)
	values(_cod_agente,ld_fecha_hora,_mensaje,a_usuario);
	let ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;
	
End Foreach

return 0,'Proceso Completado';
END
end procedure