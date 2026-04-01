--Proceso corredores suspendidos proveniente de archivo enviado por la superintendencia
--Procedimiento para eliminar los registros iguales del numero de licencia y sacar a nuestros corredores
--Armando Moreno M. 08/08/2017

drop procedure sp_che230a;
create procedure sp_che230a(a_usuario char(8))
RETURNING smallint,char(25);

define _no_licencia char(10);
define _cnt         integer;
define _cod_agente  char(10);
define _n_agente    char(50);
define _fecha_hoy   date;
define _tipo_licencia char(1);
define _estatus_licencia char(1);
define _generar_cheque  smallint;
define ld_fecha_hora	datetime year to fraction(5);
DEFINE _mensaje         varchar(255);


--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

SET LOCK MODE TO WAIT;

let _fecha_hoy = current;
call sp_sis40() returning ld_fecha_hora;

CREATE TEMP TABLE tmp_agtsus
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
      from agt_sus
  group by no_licencia,tipo_licencia
 having count(*) > 1
 
	 insert into tmp_agtsus(no_licencia,cantidad,tipo_licencia)
	 values(_no_licencia,_cnt,_tipo_licencia);
	   
end foreach

foreach
	select no_licencia,cantidad,tipo_licencia
	  into _no_licencia,_cnt,_tipo_licencia
	  from tmp_agtsus
	
	delete from agt_sus
	where no_licencia = _no_licencia
	  and tipo_licencia = _tipo_licencia;
	
	 insert into agt_sus(no_licencia,fecha,tipo_licencia)
	 values(_no_licencia,today,_tipo_licencia);
	  
end foreach

drop table tmp_agtsus;

--Borra los registros de agt_suspendidos y busca solo a nuestros corredores e inserta los procedentes del nuevo baje en agt_suspendidos
delete from agt_suspendidos;

Foreach
	select no_licencia,
	       tipo_licencia
	  into _no_licencia,
	       _tipo_licencia
	  from agt_sus
	  
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
		insert into agt_suspendidos(no_licencia,cod_agente,nombre)
		values(_no_licencia,_cod_agente,_n_agente);
		insert into agt_suspendidos2(no_licencia,cod_agente,nombre)
		values(_no_licencia,_cod_agente,_n_agente);
	end if
End Foreach

--Desmarcar corredores suspendidos a Activos

Foreach
	select no_licencia,
	       cod_agente,
		   nombre
	  into _no_licencia,
	       _cod_agente,
		   _n_agente
	  from agtagent
	 where estatus_licencia = 'P'
	 
	if _cod_agente = '02825' then --se excluye 02825 caso 3631
		continue foreach;
	end if 
	select count(*)
	  into _cnt
	  from agt_suspendidos
	 where cod_agente = _cod_agente;
	 
	if _cnt is null then
		let _cnt = 0;
	end if
	--Como el agente NO esta en la tabla de los suspendidos, se entiende que ya se libero y debe estar Activo.
	if _cnt = 0 then --Tambien se busca en la tabla de historica para saber si es un corredor marcado por este proceso. Si se encuentra quiere decir que si se puede desmarcar.
		select count(*)
		  into _cnt
	      from agt_suspendidos2
	     where cod_agente = _cod_agente;
	 
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt > 0 then
			update agtagent
			   set estatus_licencia = 'A'
			 where cod_agente       = _cod_agente;

			insert into agt_sus_his(cod_agente,no_licencia,nombre,date_added,user_added,estatus)
			values(_cod_agente,_no_licencia,_n_agente,_fecha_hoy,a_usuario,'A');
			
			---Marcar a los corredores agrupados como activos
			update agtagent
			   set estatus_licencia = 'A'
			 where agente_agrupado  = _cod_agente;
			 
			delete from agt_suspendidos
			where cod_agente = _cod_agente;
			let _mensaje = "SE LIBERA DE SUSPENSION PERMANENTE, SEGUN INFORME DE SUPERINT. INCUMPLIMIENTO DE LEY 2015.";
			insert into agtnotas(cod_agente,fecha_nota,desc_nota,user_added)
			values(_cod_agente,ld_fecha_hora,_mensaje,a_usuario);
			let ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;
		end if	
	end if
End Foreach

--Marcar corredores Activos a Suspendidos

Foreach
	select no_licencia,
	       cod_agente,
		   nombre
	  into _no_licencia,
	       _cod_agente,
		   _n_agente
	  from agt_suspendidos
	  
	--Marcar al corredor como Suspendido segun la tabla de suspendidos del ultimo baje.

	select estatus_licencia
	  into _estatus_licencia
	  from agtagent
	 where cod_agente = _cod_agente;

    {if _estatus_licencia in('X','T') then	--se pone en comentario debido a que la susp. permanente esta por encima de las otras.
		continue foreach;
	end if}
	
	update agtagent
	   set estatus_licencia = 'P'
	 where cod_agente       = _cod_agente;

	insert into agt_sus_his(cod_agente,no_licencia,nombre,date_added,user_added,estatus)
	values(_cod_agente,_no_licencia,_n_agente,_fecha_hoy,a_usuario,'P');
	
	---Marcar a los corredores agrupados
	update agtagent
	   set estatus_licencia = 'P'
	 where agente_agrupado  = _cod_agente;
	 
	let _mensaje = "SE SUSPENDE PERMANENTE, SEGUN INFORME DE SUPERINT. INCUMPLIMIENTO DE LEY 2015 PARA EMISION Y COMISION SEGUN CIRCULAR SSRP DES 028-2017";
	insert into agtnotas(cod_agente,fecha_nota,desc_nota,user_added)
	values(_cod_agente,ld_fecha_hora,_mensaje,a_usuario);
	let ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;
End Foreach

return 0,'Proceso Completado';
END
end procedure