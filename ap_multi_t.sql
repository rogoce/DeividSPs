-- 
-- Caso de poliza que no se cargó con TEMIS
-- Creado    : 14/05/2024 - Autor: Amado Perez

DROP PROCEDURE ap_multi_t;
CREATE PROCEDURE ap_multi_t() 
RETURNING int, 
          char(25);

	DEFINE _no_poliza 			char(10);
	DEFINE _no_unidad           char(5);
	DEFINE _no_endoso			char(5);
	DEFINE _error               integer;
	DEFINE _suma_asegurada      dec(16,2);
 	DEFINE _vigencia_inic       date;
	DEFINE _vigencia_final      date;
	DEFINE _cnt		            smallint;
	DEFINE _cod_cober_reas      char(3);
	--DEFINE _unidad              
          

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;



FOR _cnt = 3 to 118
	select *
	 from emipouni
	where no_poliza = '0002619890'
	  and no_unidad = '00001'
	into temp prueba; 
	  
	if _cnt < 10 then
		let _no_unidad = '0000' || _cnt;
	elif _cnt >= 10 and _cnt < 100 then
	    let _no_unidad = '000' || _cnt;
	elif _cnt >= 100 and _cnt < 1000 then
	    let _no_unidad = '00' || _cnt;
	elif _cnt >= 1000 and _cnt < 10000 then
	    let _no_unidad = '0' || _cnt;
	else
		let _no_unidad = _cnt;
	end if	
	
	update prueba set no_unidad = _no_unidad;
	   
	insert into emipouni
    select * from prueba;

    drop table prueba;	

	select *
	  from emipocob		
	 where no_poliza = '0002619890'
	   and no_unidad = '00001'
	  into temp prueba;

	update prueba set no_unidad = _no_unidad;

	insert into emipocob
	select * from prueba;

	drop table prueba;
	      
	select *
	  from emifacon		
	 where no_poliza = '0002619890'
	   and no_unidad = '00001'
	  into temp prueba;

	update prueba set no_unidad = _no_unidad;

	insert into emifacon
	select * from prueba;

	drop table prueba;
	
	select *
	  from emireama		
	 where no_poliza = '0002619890'
	   and no_unidad = '00001'
	  into temp prueba;

	update prueba set no_unidad = _no_unidad;

	insert into emireama
	select * from prueba;

	drop table prueba;
	
	select *
	  from emireaco		
	 where no_poliza = '0002619890'
	   and no_unidad = '00001'
	  into temp prueba;

	update prueba set no_unidad = _no_unidad;

	insert into emireaco
	select * from prueba;

	drop table prueba;
	  
END FOR


return 0, "actualizacion exitosa";
END PROCEDURE	  