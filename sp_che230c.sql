--Procedimiento para eliminar los registros iguales del numero de licencia y sacar a nuestros corredores
--Armando Moreno M. 20/06/2016

drop procedure sp_che230c;
create procedure sp_che230c(a_usuario char(8))
RETURNING smallint, char(25);

define _no_licencia char(10);
define _cnt         integer;
define _cod_agente  char(5);
define _n_agente    char(50);
define _fecha_hoy   date;
define _tipo_licencia char(1);
define _estatus_licencia char(1);
define _estatus_licencia2 char(1);
define _estatus_licencia3 char(1);
define _vida, _danos, _fianza char(1);
define _vida_s, _danos_s, _fianza_s smallint;
define _cod_agente2 char(5);
define ld_fecha_hora	datetime year to fraction(5);
define _mensaje         varchar(255);

define _error			integer;
define _error_isam		integer;
define _error_desc		varchar(100);



BEGIN
on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error, _error_desc;
end exception


SET LOCK MODE TO WAIT;

--drop table if exists tmp_agtsta;
let _fecha_hoy = current;
call sp_sis40() returning ld_fecha_hora;

CREATE TEMP TABLE tmp_agtsta
         (no_licencia      char(10),
		  tipo_licencia    char(1),
		  cod_agente       char(5),
		  nombre           char(50),
		  estatus          char(1),
		  vida             smallint,
		  danos            smallint,
		  fianza           smallint)
          WITH NO LOG;
		  		  
foreach

	select codigo[3,3],
	       codigo[4,13],
		   codigo[17,66],
		   codigo[87,87],
		   codigo[89,89],
		   codigo[90,90],
		   codigo[91,91]
	  into _tipo_licencia,
	       _no_licencia,	
           _n_agente,		   
		   _estatus_licencia,
		   _vida,
		   _danos,
		   _fianza
      from agt_status

	 let _vida_s = 0;		  
	 let _danos_s = 0;		  
	 let _fianza_s = 0;
	  
	 if _vida = '1' then
		let _vida_s = 1;
	 end if
	 if _danos = '1' then
		let _danos_s = 1;
	 end if
	 if _fianza = '1' then
		let _fianza_s = 1;
	 end if
 
	 insert into tmp_agtsta(no_licencia,tipo_licencia,nombre,estatus,vida,danos,fianza)
	 values(_no_licencia,_tipo_licencia,_n_agente,_estatus_licencia,_vida_s,_danos_s,_fianza_s);
	   
end foreach

delete from tmp_agtsta where no_licencia not in (select no_licencia from agtagent);

delete from tmp_agtsta where estatus is null or trim(estatus) = "";

delete from agt_status_aa;

--SET DEBUG FILE TO "sp_che230c.trc"; 
--trace on;
begin
foreach
	select no_licencia, 
	       tipo_licencia, 
		   nombre,
		   estatus,
		   vida,
		   danos,
		   fianza
	  into _no_licencia, 
	       _tipo_licencia, 
		   _n_agente,
		   _estatus_licencia,
		   _vida_s,
		   _danos_s,
		   _fianza_s
	  from tmp_agtsta

	on exception set _error, _error_isam, _error_desc
		--rollback work;
		return _error, _error_desc;
	end exception
	  
	{on exception
	    foreach
			select cod_agente, nombre
			  into _cod_agente, _n_agente
			  from agtagent 
			 where no_licencia = _no_licencia
			   and tipo_agente = 'A'
			   and cod_agente = agente_agrupado
			 return 1, _cod_agente, _no_licencia,_n_agente WITH RESUME;
		--return 1, _tipo_licencia || " " || _no_licencia || " " || _n_agente WITH RESUME;
		end foreach
	end exception}
	  
	let _no_licencia = _no_licencia;
	
   FOREACH	
	select cod_agente
	  into _cod_agente
	  from agtagent
	 where no_licencia = _no_licencia
	   and tipo_persona = _tipo_licencia
	   and tipo_agente = 'A'
	 --  and cod_agente = agente_agrupado --Se hace cambio segun caso 36137 y correo enviado el 04-12-2020 por Zuleyka
	   
	 INSERT INTO agt_status_aa (
		cod_agente,
		no_licencia,
		estatus,
        vida,
        danos,
        fianza,
        user_added) 
     VALUES (
	    _cod_agente,
		_no_licencia,
		_estatus_licencia,
		_vida_s,
		_danos_s,
		_fianza_s,
		a_usuario
		);		
	END FOREACH
end foreach
  
end	  

--Marcar corredores

Foreach
	select no_licencia,
	       cod_agente,
		   estatus
	  into _no_licencia,
	       _cod_agente,
		   _estatus_licencia
	  from agt_status_aa
	  
	foreach
		select cod_agente, estatus_licencia
		  into _cod_agente2, _estatus_licencia2
		  from agtagent
		 where cod_agente = _cod_agente
--		 where agente_agrupado = _cod_agente --Se hace cambio segun caso 36137 y correo enviado el 04-12-2020 por Zuleyka
		 
		if _estatus_licencia = 'V' and _estatus_licencia2 in ('A', 'X') then -- Si está activo o moroso
			continue foreach;
		end if

		if _estatus_licencia in('C','S') and _estatus_licencia2 in('P','T') then
			continue foreach;
		end if
		
		if _estatus_licencia = 'V' then
			let _estatus_licencia3 = 'A';
			let _mensaje = "SE ACTIVA PERMANENTE, SEGUN INFORME DE SUPERINT. ESTATUS DEL CORREDOR";
		else
			let _estatus_licencia3 = 'P';
			let _mensaje = "SE SUSPENDE PERMANENTE, SEGUN INFORME DE SUPERINT. ESTATUS DEL CORREDOR";
		end if
		
		if _cod_agente2 = '02825' then --se excluye 02825 caso 3631
			continue foreach;
		end if
		update agtagent
		   set estatus_licencia = _estatus_licencia3
		 where cod_agente       = _cod_agente2;

		insert into agt_status_aa_his(cod_agente,no_licencia,date_added,user_added,estatus)
		values(_cod_agente2,_no_licencia,current,a_usuario,_estatus_licencia3);
		
		insert into agtnotas(cod_agente,fecha_nota,desc_nota,user_added)
		values(_cod_agente2,ld_fecha_hora,_mensaje,a_usuario);
		let ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;
		
	End foreach
End Foreach
drop table tmp_agtsta;

--drop table if exists tmp_agtsta;
return 0,'Proceso Completado';
END
end procedure