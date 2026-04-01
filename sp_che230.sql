--Procedimiento para eliminar los registros iguales del numero de licencia y sacar a nuestros corredores
--Armando Moreno M. 20/06/2016
--se coloca para que inserte las notas 27/04/2018

drop procedure sp_che230;
create procedure sp_che230(a_usuario char(8))
RETURNING smallint,char(25);

define _no_licencia char(10);
define _cnt         integer;
define _cod_agente  char(10);
define _n_agente    char(50);
define _fecha_hoy   date;
define _tipo_licencia char(1);
define _valor         char(8);
define _estatus_licencia,_clase_archivo char(1);
define ld_fecha_hora	datetime year to fraction(5);
DEFINE _mensaje         varchar(255);
define _email_agt		char(384);
define _error           smallint;
define _descripcion		varchar(30);

--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

SET LOCK MODE TO WAIT;

let _fecha_hoy   = current;
let _descripcion = '';
call sp_sis40() returning ld_fecha_hora;

CREATE TEMP TABLE tmp_agtmor
         (no_licencia      char(10),
          cantidad         integer,
		  tipo_licencia    char(1),
		  clase_archivo    char(1))
          WITH NO LOG;
foreach
	select count(*),
	       no_licencia,
		   tipo_licencia,
		   clase_archivo
	  into _cnt,
           _no_licencia,
		   _tipo_licencia,
		   _clase_archivo
      from agt_mor
  group by no_licencia,tipo_licencia,clase_archivo
 having count(*) > 1
 
 insert into tmp_agtmor(no_licencia,cantidad,tipo_licencia,clase_archivo)
 values(_no_licencia,_cnt,_tipo_licencia,_clase_archivo);
	   
end foreach

foreach
	select no_licencia,cantidad,tipo_licencia,clase_archivo
	  into _no_licencia,_cnt,_tipo_licencia,_clase_archivo
	  from tmp_agtmor
	
	delete from agt_mor
	where no_licencia   = _no_licencia
	  and tipo_licencia = _tipo_licencia;
	
	 insert into agt_mor(no_licencia,fecha,tipo_licencia,clase_archivo)
	 values(_no_licencia,today,_tipo_licencia,_clase_archivo);
	  
end foreach

drop table tmp_agtmor;

--Borra los registros de agt_morosos y busca solo a nuestros corredores e inserta los procedentes del nuevo baje en agt_morosos
delete from agt_morosos;

Foreach
	select no_licencia,
	       tipo_licencia,
		   clase_archivo
	  into _no_licencia,
	       _tipo_licencia,
		   _clase_archivo
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
		insert into agt_morosos(no_licencia,cod_agente,nombre,clase_archivo)
		values(_no_licencia,_cod_agente,_n_agente,_clase_archivo);
	end if
	  
End Foreach
--****************************************************************************************************
--Recorrer corredores Morosos de agtagent y sino estan en la tabla de morosos, marcarlos como Activos.
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
	if _cod_agente = '02825' then --se excluye 02825 caso 3631
		continue foreach;
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
		 
		let _mensaje = "SE LIBERA DE MOROSIDAD, SEGUN INFORME DE SUPERINTENDENCIA.";
		
		insert into agtnotas(cod_agente,fecha_nota,desc_nota,user_added)
		values(_cod_agente,ld_fecha_hora,_mensaje,a_usuario);
		
		let ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;
	end if
End Foreach
--******************************************************************************
--Recorrer corredores que quendan Morosos y Marcarlos como Morosos en agtagent
Foreach
	select no_licencia,
	       cod_agente,
		   nombre,
		   clase_archivo
	  into _no_licencia,
	       _cod_agente,
		   _n_agente,
		   _clase_archivo
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
	 
	if _clase_archivo = 'T' then
	  let _valor = '-TASA';
	elif _clase_archivo = 'F' then
	  let _valor = '-FIANZA';
	else
	  let _valor = '';
	end if
	
	let _mensaje = "SUSPENDIDO POR MOROSIDAD, SEGUN INFORME DE SUPERINTENDEDNCIA."||_valor;
	
	insert into agtnotas(cod_agente,fecha_nota,desc_nota,user_added)
	values(_cod_agente,ld_fecha_hora,_mensaje,a_usuario);
	
	let ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;
	
	--Creacion de resgistro en parmailsend/parmailcom para envio de notificacion al corredor --29/05/2018
	let _email_agt = sp_sis163a(_cod_agente,'COM');
	if _email_agt is null then
		let _email_agt = '';
	end if
	if _email_agt <> '' then
		select estatus_licencia
		  into _estatus_licencia
		  from agtagent
		 where cod_agente = _cod_agente;
		if _estatus_licencia = 'X' then
			call sp_sis455a('00040',_email_agt,'','',_clase_archivo,0,'','',0.00,0.00,0.00,null) returning _error,_descripcion;
		end if	
	end if
End Foreach
return 0,'Proceso Completado';
END
end procedure