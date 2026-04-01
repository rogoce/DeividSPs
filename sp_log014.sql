-- Procedure que actualiza estado de impresion de aviso de cancelación. 
-- Creado    : 26/2/2016 - Autor: Henry Girón. 
-- SIS v.2.0 - DEIVID, S.A. 
-- Set debug file to 'sp_log010.trc'; 
-- trace on ; 

Drop procedure sp_log014;  
CREATE procedure "informix".sp_log014(a_fecha1 date, a_fecha2 date, a_codagente CHAR(255) DEFAULT "*", a_codacreedor CHAR(255) DEFAULT "*" )   
   RETURNING CHAR(20),  -- poliza  
             char(100), -- cliente  
			 char(50),  -- corredor  
			 char(50),  -- acreedor  
			 date,      -- fecha_aviso   
			 date,      -- date_imp_aviso_log   
             char(15),	-- user_imp_aviso_log   
			 char(10),  -- no_aviso   
			 varchar(255);  -- filtro   
			 
BEGIN 

    define _no_documento       char(20); 
    define _name_corredor  	   char(50); 
    define _name_cliente       char(100);   
	define _name_acreedor	   char(50);  
	define _fecha_aviso        date; 
    define _user_imp_aviso_log char(15); 
    define _date_imp_aviso_log date; 
	define _no_aviso            char(10); 
    define v_filtros            varchar(255); 
	define _tipo	            char(1); 
    define _cod_agente  	   char(5); 
    define _cod_acreedor  	   char(5); 
	define _imp_aviso_log      smallint;

	SET ISOLATION TO DIRTY READ; 
	
	create temp table temp_det
	(poliza	            CHAR(20),
	cliente	            CHAR(100),
	corredor	        CHAR(50),
	acreedor	        CHAR(50),
	fecha_aviso	        date,
	date_imp_aviso_log	date,
	user_imp_aviso_log	CHAR(15),
	no_aviso	        CHAR(10),
	imp_aviso_log       smallint,
	codagente	        CHAR(5),
	codacreedor         CHAR(5),
	seleccionado	    smallint default 1) 
	with no log;

	create index id1_temp_det on temp_det(codagente);
	create index id2_temp_det on temp_det(codacreedor);
	create index id3_temp_det on temp_det(seleccionado);

	
	LET v_filtros     = "";				
--	LET v_filtros = TRIM(v_filtros) ||" No.Avisos: "||TRIM(a_no_aviso);	
--	LET _tipo = sp_sis04(a_no_aviso); -- Separa los valores del String	

FOREACH 
	select no_documento, 
	       nombre_cliente, 
           nombre_agente, 
           nombre_acreedor, 
           fecha_proceso, 
           date_imp_aviso_log, 
		   user_imp_aviso_log ,
		   no_aviso,
		   imp_aviso_log,
		   cod_agente,
		   cod_acreedor
	  into _no_documento, 
           _name_cliente, 
           _name_corredor, 
		   _name_acreedor, 
		   _fecha_aviso, 
		   _date_imp_aviso_log, 
           _user_imp_aviso_log,
           _no_aviso,
		   _imp_aviso_log,
		   _cod_agente,
		   _cod_acreedor
	  from avisocanc 
	 where ( estatus in ('I')  
	    and cancela = "0" )
       and ( trim(cod_acreedor) <> "" )
       and date_imp_aviso_log >= a_fecha1
	   and date_imp_aviso_log <= a_fecha2 		 
	   order by nombre_acreedor,nombre_cliente 	   
	   
	   		insert into temp_det
		   values(	_no_documento, 
				 _name_cliente, 
				 _name_corredor, 
				 _name_acreedor, 
				 _fecha_aviso, 
				 _date_imp_aviso_log, 
				 _user_imp_aviso_log, 
				 _no_aviso, 
				 _imp_aviso_log,
				 _cod_agente,
				 _cod_acreedor,
				 1
				 );			  

end foreach


-- procesos v_filtros
let v_filtros ="";

--filtro por agente
if a_codagente <> "*" then
	let v_filtros = trim(v_filtros) ||"Agente: "||TRIM(a_codagente);
	let _tipo = sp_sis04(a_codagente); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and codagente not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and codagente in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

--filtro por acreedor
if a_codacreedor <> "*" then
	let v_filtros = trim(v_filtros) ||"Agente: "||TRIM(a_codacreedor);
	let _tipo = sp_sis04(a_codacreedor); -- separa los valores del string

	if _tipo <> "E" THEN -- Incluir los Registros
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and codacreedor not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and codacreedor in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if


FOREACH 
    select poliza,
			cliente,
			corredor,
			acreedor,
			fecha_aviso,
			date_imp_aviso_log,
			user_imp_aviso_log,
			no_aviso
	into _no_documento, 
		 _name_cliente, 
		 _name_corredor, 
		 _name_acreedor, 
		 _fecha_aviso, 
		 _date_imp_aviso_log, 
		 _user_imp_aviso_log, 
		 _no_aviso			
	 from temp_det 
		 where seleccionado = 1
		   order by cliente,acreedor	   

  RETURN _no_documento, 
		 _name_cliente, 
		 _name_corredor, 
		 _name_acreedor, 
		 _fecha_aviso, 
		 _date_imp_aviso_log, 
		 _user_imp_aviso_log, 
		 _no_aviso, 
		 v_filtros 
		 WITH RESUME; 				 

end foreach
				 

DROP TABLE temp_det;
END

END PROCEDURE;
