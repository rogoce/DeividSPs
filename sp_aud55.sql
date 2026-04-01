-- Procedure para auditar pase de cartas vs reporte de BO 
-- Creado    : 05/10/2017 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A. 
-- execute procedure sp_aud55('2017-10'); 
drop procedure sp_aud55; 

create procedure "informix".sp_aud55(a_periodo char(7)) 
Returning CHAR(20) as poliza,
		  CHAR(20) as reporte,		
		  CHAR(7)  as periodo,
		  CHAR(50) as asegurado,
		  CHAR(50) as plan,
		  DATE     as fecha_aniv,
		  CHAR(50) as corredor;											
		  
define _poliza	        char(20);
define _reporte	        char(20);
define _periodo	        char(7);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _asegurado       CHAR(50);
define _plan            CHAR(50);
define _fecha_aniv		date;
define _nombre_agente	varchar(50);
define _no_poliza		char(10);
define _cod_agente		char(5);
define _cod_asegurado       char(10);	 
define _fecha_periodo   	date;
define _anio_aniv			char(4);
define _mes_aniv			char(2);
define _dia_aniv			char(2);
define _vigencia_inic       date;

--número de póliza, nombre del asegurado, número de producto, nombre del producto, fecha de aniversario, corredor.

  drop table if exists tmp_diferentes; 
CREATE TEMP TABLE tmp_diferentes 
         (poliza        CHAR(20), 
		  reporte	    CHAR(20), 
          periodo       CHAR(7), 
		  asegurado     CHAR(50), 
		  plan          CHAR(50)      --,primary key (poliza,periodo,reporte)	  
		  ) with no log;

set isolation to dirty read;

begin 
on exception set _error,_error_isam,_error_desc	
	return _error,_error_desc,'','','',null,''; 
end exception 
let _fecha_periodo = mdy(a_periodo[6,7], 1, a_periodo[1,4]);
-- TMP_BO1  
	INSERT INTO tmp_diferentes	
select distinct b.no_documento,'BusinessObject' ,b.periodo,b.nombre_cliente,b.nombre_plan  
  from tmp_bo1 a right  join emicartasal2 b on trim(a.no_documento) = trim(b.no_documento)  
 where b.periodo[6,7] = a_periodo[6,7] 
   and a.no_documento is null; 
-- EMICAARTASAL2  
	INSERT INTO tmp_diferentes	  
select distinct b.no_documento,'DEIVID-Emicartasal2',b.periodo,b.asegurado,b.plan
  from emicartasal2 a right join tmp_bo1 b on trim(a.no_documento) = trim(b.no_documento) 
 where a.no_documento is null
--   and b.periodo[6,7] = '10';
   and b.periodo[6,7] = a_periodo[6,7];

foreach 
	select 	poliza,
			reporte,
			periodo,
			asegurado,
			plan
	  into _poliza,
	       _reporte,
		   _periodo,
		   _asegurado,
		   _plan
	  from tmp_diferentes	
	 where periodo[6,7] = a_periodo[6,7]	   					 		
	 order by 3,2,1
	 
	 call sp_sis21(_poliza) returning _no_poliza;
	 
	foreach
	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = _no_poliza
	 order by porc_partic_agt desc

	  exit foreach;
	   end foreach

	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	 -- Lectura de emipomae
	select cod_contratante  ,vigencia_inic
	  into _cod_asegurado, _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;	
		
	{-- Lectura de cliclien
	select fecha_aniversario
	  into _fecha_aniv
	  from cliclien
	 where cod_cliente = _cod_asegurado;} 	 
	 
if month(_vigencia_inic) < month(_fecha_periodo) then
		let _anio_aniv =   a_periodo[1,4];
		let _mes_aniv  =   month(_vigencia_inic);
		let _dia_aniv  =   day(_vigencia_inic);
		let _fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);
		let _fecha_aniv = _fecha_aniv + 1 units year;
	else
		let _anio_aniv =   a_periodo[1,4];
		let _mes_aniv  =   month(_vigencia_inic);
		let _dia_aniv  =   day(_vigencia_inic);
		let _fecha_aniv = mdy(_mes_aniv,_dia_aniv,_anio_aniv);
	end if	 

	return _poliza,
	       _reporte,
		   _periodo,
		   _asegurado,
		   _plan,
		   _fecha_aniv,
		   _nombre_agente
	   with resume;			

	end foreach
	
end 

end procedure
                                                                                                                                                                                     
