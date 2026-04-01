-- Proceso que despliega la informacion de tab en aviso de cancelacion. 
-- Realizado : Henry Giron 28/08/2010 
--Drop procedure sp_cob764; 
create procedure sp_cob764(a_referencia char(15), a_tab smallint, a_proceso smallint, a_usuario char(15) )
returning  CHAR(20)		   ,			-- no_documento  	
		   CHAR(20)		   ,			-- nombre_cliente	
		   CHAR(50)		   ,			-- nombre_agente	
		   CHAR(7)		   ,			-- periodo			
		   DATE 		   ,			-- vigencia_inic 	
		   DATE			   ,			-- vigencia_final	
		   CHAR(50) 	   ,			-- nombre_ramo		
		   DECIMAL(16,2)   ,			-- saldo   			
		   DECIMAL(16,2)   ,			-- por_vencer		
		   DECIMAL(16,2)   ,			-- exigible			
		   DECIMAL(16,2)   ,			-- dias_30			
		   DECIMAL(16,2)   ,			-- dias_60			
		   DECIMAL(16,2)   ,			-- dias_90			
		   DECIMAL(16,2)   ,			-- dias_120			
		   CHAR(10)   	   ,			-- no_poliza		
		   CHAR(15)   	   ,			-- no_aviso			
		   CHAR(1)   	   ,			-- estatus			
		   DATE   		   ,			-- fecha_vence	
		   CHAR(15)  	   ,			-- user_proceso	
		   CHAR(50)   	   ,			-- email_cli 	
		   CHAR(20)  	   ,			-- apart_cli 	
		   CHAR(50)   	   ,			-- nombre_acreedor	
		   CHAR(1)  	   ,			-- clase 
		   CHAR(1)  	   ,			-- marcar_entrega 
		   CHAR(15) 	   ,			-- user_marcar 
		   DATE   		   ,			-- fecha_marcar 
		   CHAR(1)  	   ,			-- desmarca 
		   CHAR(15) 	   ,			-- user_desmarca 
		   DATE   		   ,			-- fecha_desmarca 
		   CHAR(50)		   ,			-- motivo_desmarca  
		   SMALLINT        ,            -- renglon 
	       CHAR(1)  	   ,			-- ult_gestion 
		   CHAR(15) 	   ,			-- user_ult_gestion 
		   DATE   		   ,			-- fecha_ult_gestion 
		   CHAR(1)         ,            -- estatus_poliza
		   SMALLINT        ,            -- cancela 
		   SMALLINT        ;            -- impreso 

DEFINE a_referencia2       CHAR(15)		; 										
DEFINE _no_documento       CHAR(20)		;
DEFINE _nombre_cliente     CHAR(20)		;
DEFINE _nombre_agente	   CHAR(50)		;
DEFINE _periodo			   CHAR(7)		;
DEFINE _vigencia_inic      DATE 		;
DEFINE _vigencia_final	   DATE			;
DEFINE _nombre_ramo		   CHAR(50) 	;
DEFINE _saldo   		   DECIMAL(16,2);
DEFINE _por_vencer		   DECIMAL(16,2);
DEFINE _exigible		   DECIMAL(16,2);
DEFINE _dias_30			   DECIMAL(16,2);
DEFINE _dias_60			   DECIMAL(16,2);
DEFINE _dias_90			   DECIMAL(16,2);
DEFINE _dias_120		   DECIMAL(16,2);
DEFINE _dias_150 		   DECIMAL(16,2);
DEFINE _dias_180		   DECIMAL(16,2);
DEFINE _no_poliza		   CHAR(10)   	;
DEFINE _no_aviso		   CHAR(15)   	;
DEFINE _estatus			   CHAR(1)   	;
DEFINE _fecha_vence		   DATE   		;
DEFINE _user_proceso	   CHAR(15)  	;
DEFINE _email_cli		   CHAR(50)   	;
DEFINE _apart_cli		   CHAR(20)  	;
DEFINE _nombre_acreedor	   CHAR(50)   	;
DEFINE _cod_acreedor	   CHAR(5)  	;
DEFINE _clase              CHAR(1)   	;
DEFINE _marcar_entrega     CHAR(1)   	;
DEFINE _user_marcar        CHAR(15)   	;
DEFINE _fecha_marcar       DATE   		;
DEFINE _desmarca           CHAR(1)   	;
DEFINE _user_desmarca      CHAR(15)   	;
DEFINE _motivo_desmarca    CHAR(50)   	;
DEFINE _fecha_desmarca     DATE   		;
DEFINE _cobrador           CHAR(3)   	;
DEFINE _gestion            CHAR(3)   	;
DEFINE _renglon			   SMALLINT     ;
DEFINE _ult_gestion        CHAR(1)   	;
DEFINE _user_ult_gestion   CHAR(15)   	;
DEFINE _fecha_ult_gestion  DATE   		;
DEFINE _veces        	   SMALLINT     ;
DEFINE _saldo_cancelado    DECIMAL(16,2);
DEFINE _estatus_poliza	   CHAR(1)   	;
DEFINE _cancela			   SMALLINT     ;
DEFINE _impreso			   SMALLINT     ;
DEFINE _saldo_incobrable   DECIMAL(16,2);
DEFINE _error              SMALLINT     ;
DEFINE _descripcion		   CHAR(50)   	;
DEFINE _usuario2           CHAR(15)     ;
DEFINE _table_temp 		   LVARCHAR     ;
DEFINE _sql_describe       LVARCHAR     ;
DEFINE _sql_where	       LVARCHAR     ;
DEFINE returnValue         LVARCHAR     ;

-- RETURN 1,'SOLICITAR AUTORIZACION A COMPUTO';	  -- Quitar cuando se desee eliminar la carga  
-- SET DEBUG FILE TO "sp_cob764.trc";

begin
let _renglon = 0;
let _veces   = 0;
let _cancela = 0;
let _impreso = 0;
let _saldo_incobrable = 0;

-- Para evitar bloqueo
LET	_table_temp   = trim("AVISOCANC")||"_"||trim(upper(a_usuario));
LET _sql_where    = " 1 = 1 ";
LET _sql_describe = "SELECT * FROM "||trim("AVISOCANC")||" where "||trim(_sql_where)||" INTO temp "||trim(_table_temp)||" " ;
--LET _sql_describe = "SELECT * FROM AVISOCANC INTO temp tmp_a1 " ;
--EXECUTE IMMEDIATE _sql_describe;
--EXEC SQL execute  immediate	_sql_describe;
--call EXEC (_sql_describe) returning returnValue;
-- ver la informacion por gestor - supervisor - jefe de cobros
call sp_sis159(a_usuario) returning _error, _descripcion;

if _error <> 0 then
  RETURN _no_documento   	,	
	   	 _nombre_cliente 	,
	   	 _nombre_agente	    ,
	   	 _periodo			,
	   	 _vigencia_inic  	,
	   	 _vigencia_final	,
	   	 _nombre_ramo		,
	   	 _saldo   		    ,
	   	 _por_vencer		,
	   	 _exigible		    ,
	   	 _dias_30			,
	   	 _dias_60			,
	   	 _dias_90			,
	   	 _dias_120		    ,
	   	 _no_poliza		    ,
	   	 _no_aviso		    ,
	   	 _estatus			,
	   	 _fecha_vence		,
	   	 _user_proceso	    ,
	   	 _email_cli		    ,
	   	 _apart_cli			,
		 _nombre_acreedor	,
		 _clase             ,
		 _marcar_entrega    ,
		 _user_marcar       ,
		 _fecha_marcar      ,
		 _desmarca       	,
		 _user_desmarca  	,
		 _fecha_desmarca 	,
		 _motivo_desmarca  	,
		 _renglon			,
		 _ult_gestion       ,
		 _user_ult_gestion  ,
		 _fecha_ult_gestion ,
		 _estatus_poliza	,
		 _cancela           ,
	   	 _impreso        
	   	 WITH RESUME;

drop table tmp_usuario159;
end if       

foreach
	select usuario 
	  into _usuario2
	  from tmp_usuario159 
     order by 1 asc

	foreach
		select cod_cobrador 
		  into _cobrador
		  from cobcobra 
		 where activo = '1' 
		   and usuario = _usuario2 -- a_usuario 
	     order by 1 asc
		  exit foreach;
	end foreach

	let _motivo_desmarca = "";
	let _saldo_cancelado = 0.00;
	let _dias_90   = 0.00;
	let _dias_120  = 0.00;
	let _dias_150  = 0.00;
	let _dias_180  = 0.00;
	let _estatus   = 0;

	if a_tab >= 5 then
	   let a_referencia2 = "%";
	else
	   let a_referencia2 = a_referencia;
	end if

	LET _sql_where	= " no_aviso like ( '"||trim(a_referencia2)||"' ) "||
	                  " and user_proceso = '"||trim(_usuario2)||"' ";
	LET _sql_describe = 
	         "SELECT no_documento, 	" ||
		     "nombre_cliente	,  	" ||
		     "nombre_agente	,      	" ||
		     "periodo			,  	" ||
		     "vigencia_inic	,      	" ||
		     "vigencia_final	,  	" ||
		     "nombre_ramo		,  	" ||
		     "saldo			,      	" ||
		     "por_vencer		,  	" ||
		     "exigible			,   " ||
		     "dias_30			,  	" ||
		     "dias_60			,  	" ||
		     "dias_90			,  	" ||
		     "dias_120			,   " ||
		     "dias_150			,   " ||
		     "dias_180			,   " ||
		     "no_poliza		,      	" ||
		     "no_aviso			,   " ||
		     "estatus			,  	" ||
		     "fecha_vence		,  	" ||
		     "user_proceso		,   " ||
		     "email_cli		,      	" ||
		     "apart_cli  		,  	" ||
			 "nombre_acreedor 	,  	" ||
			 "cod_acreedor		,  	" ||
			 "clase            ,   	" ||
			 "marcar_entrega   ,   	" ||
			 "user_marcar      ,   	" ||
			 "fecha_marcar		,  	" ||
			 "desmarca       	,  	" ||
			 "user_desmarca  	,  	" ||
			 "fecha_desmarca 	,  	" ||
			 "trim(motivo_desmarca)," || 
			 "renglon      	,	    " || 
			 "ult_gestion      ,	" || 
			 "user_ult_gestion ,	" || 
			 "fecha_ult_gestion,	" || 
			 "saldo_cancelado 	,   " || 
			 "estatus_poliza	,	" || 
			 "cancela			,	" || 
			 "impreso 			    " || 
			 "from " || _table_temp ||" "||
			 "where " || _sql_where ||" ";

	PREPARE xsql FROM _sql_describe;	
	DECLARE xcur CURSOR FOR xsql;	 
	   OPEN xcur;
   WHILE (1 = 1)

 FETCH xcur INTO _no_documento 	,
			 _nombre_cliente 	,
			 _nombre_agente		,
			 _periodo			,
			 _vigencia_inic  	,
			 _vigencia_final	,
			 _nombre_ramo		,
			 _saldo   			,
			 _por_vencer		,
			 _exigible			,
			 _dias_30			,
			 _dias_60			,
			 _dias_90			,
			 _dias_120			,
		     _dias_150			,   
		     _dias_180			,   
			 _no_poliza			,
			 _no_aviso			,
			 _estatus			,
			 _fecha_vence		,
			 _user_proceso		,
			 _email_cli			,
			 _apart_cli			,
			 _nombre_acreedor	,
			 _cod_acreedor		,
			 _clase             , 
			 _marcar_entrega    , 
			 _user_marcar       , 
			 _fecha_marcar      ,
			 _desmarca       	,
			 _user_desmarca  	,
			 _fecha_desmarca 	,
			 _gestion  			,
			 _renglon			,
			 _ult_gestion       ,
			 _user_ult_gestion  ,
			 _fecha_ult_gestion ,
			 _saldo_cancelado	,
			 _estatus_poliza	,
			 _cancela			,
			 _impreso 	        ;

			 IF (SQLCODE = 100) THEN
				EXIT;
		    END IF

			let _dias_90 = _dias_90+_dias_120+_dias_150+_dias_180;
			let _dias_120 = 0.00;
			let _dias_150 = 0.00;
			let _dias_180 = 0.00;

		  IF a_tab = 1 THEN      -- x Corredores
			 IF _estatus in ('Q') THEN
				 --CONTINUE FOREACH;
		     END IF
		     let _marcar_entrega = 1;
			 let _motivo_desmarca = "";
			 select nombre 
			   into _motivo_desmarca
			   from avicanmot 		 
			  where	cod_motivo = _gestion;
			select count(*)
			  into _veces
			  from avicanbit
			 where no_aviso = a_referencia
			   and renglon  = _renglon
			   and estatus  = "0"
			   and proceso  = a_tab;
				if _veces is null then
				   let _marcar_entrega = "";
				else
				   let _marcar_entrega = _veces;
				end if   
	     END IF

		  IF a_tab = 2 THEN     -- x Acreedores
		     let _marcar_entrega = 1;
			  IF trim(_cod_acreedor) = "" THEN 
				 --CONTINUE FOREACH;
			 END IF 
			 let _marcar_entrega = 1;
			 let _motivo_desmarca = "";
			 select nombre 
			   into _motivo_desmarca 
			   from avicanmot 
			  where	cod_motivo = _gestion;

			select count(*)
			  into _veces
			  from avicanbit
			 where no_aviso = a_referencia
			   and renglon  = _renglon
			   and estatus  = "0"
			   and proceso  = 1;

				if _veces is null then
					let _marcar_entrega = '';
				else
					let _marcar_entrega = _veces;
				end if  
				let _dias_60 = _dias_60+_dias_120;
				let _dias_120 = 0.00;
	     END IF
		  IF a_tab = 3 then		-- x Procesos
			  IF _estatus not in ('I','R','M') THEN
				 --CONTINUE FOREACH; 
		     END IF
			 let _marcar_entrega = 1;
	     END IF 
		  IF a_tab = 4 THEN     -- x Entregado
			  IF a_proceso = 1 THEN			 -- Polizas Canceladas
				  IF _estatus not in ('I','M') THEN		-- ('M')
					 --CONTINUE FOREACH; 
			     END IF
		     END IF
			  IF a_proceso = 2 THEN			 -- Polizas Canceladas
				  IF _estatus not in ('X') THEN		-- ('M')
					 --CONTINUE FOREACH; 
			     END IF
		     END IF
	     END IF
		  IF a_tab = 5 THEN     -- x Conservacion de cartera
			  IF _estatus not in ('E') THEN
				 --CONTINUE FOREACH; 
		     END IF
			 let _marcar_entrega = 0;
	     END IF
		  IF a_tab = 6 THEN     -- x Seleccionar cancelado	  sp_cob753 X-Acancelar
	--	     let _marcar_entrega = 1;
			  IF _estatus  not in ('X') THEN
				 --CONTINUE FOREACH; 
		     END IF
			 if _ult_gestion = 1 then
			    let _marcar_entrega = 0;
			 end if
			 let _marcar_entrega = 0;
	     END IF
		  IF a_tab = 7 THEN     -- x Seleccionar cancelado	  sp_cob753 Z-canceladas Y-desmarcardas
				  IF _estatus  not in ('Z','Y','X') THEN
					 ---CONTINUE FOREACH; 
			     END IF
			 let _marcar_entrega = 0;
			 let _desmarca = 0;

			  IF a_proceso = 1 THEN			 -- Polizas Canceladas
				  IF _estatus  not in ('Z') THEN
					 --CONTINUE FOREACH; 
			     END IF
		     END IF
			  IF a_proceso = 2 THEN			 -- Polizas Desmarcadas
			     IF _estatus  not in ('Y') THEN
					 --CONTINUE FOREACH; 
			     END IF
		     END IF
			  IF a_proceso = 3 THEN	 --  Ultima gestion
				  IF _estatus not in ("X") THEN
					-- CONTINUE FOREACH; 
			     END IF
				 IF _user_ult_gestion is null THEN
				   --	 CONTINUE FOREACH; 
			     END IF
		     END IF
			  IF a_proceso = 4 THEN			 -- Saldo de Cancelacion por Prorrata
				  IF _estatus  not in ('Z') THEN
				   --	 CONTINUE FOREACH; 
			     END IF
				 let _saldo_incobrable = _saldo - _saldo_cancelado;
				  IF _saldo_incobrable = 0 THEN
					-- CONTINUE FOREACH; 
			     END IF
				 let _saldo = _saldo_incobrable;
		     END IF

	     END IF

		  IF a_tab = 8 THEN     -- x Seleccionar cancelado	  sp_cob753 X-Acancelar
			  IF _estatus  not in ('Y')  THEN
				   --	CONTINUE FOREACH; 
		     END IF
			  IF _estatus_poliza  not in (3)  THEN
				   --	CONTINUE FOREACH; 
		     END IF

	     END IF
		IF (SQLCODE != 100) THEN
			  RETURN _no_documento   	,	
				   	 _nombre_cliente 	,
				   	 _nombre_agente	    ,
				   	 _periodo			,
				   	 _vigencia_inic  	,
				   	 _vigencia_final	,
				   	 _nombre_ramo		,
				   	 _saldo   		    ,
				   	 _por_vencer		,
				   	 _exigible		    ,
				   	 _dias_30			,
				   	 _dias_60			,
				   	 _dias_90			,
				   	 _dias_120		    ,
				   	 _no_poliza		    ,
				   	 _no_aviso		    ,
				   	 _estatus			,
				   	 _fecha_vence		,
				   	 _user_proceso	    ,
				   	 _email_cli		    ,
				   	 _apart_cli			,
					 _nombre_acreedor	,
					 _clase             ,
					 _marcar_entrega    ,
					 _user_marcar       ,
					 _fecha_marcar      ,
					 _desmarca       	,
					 _user_desmarca  	,
					 _fecha_desmarca 	,
					 _motivo_desmarca  	,
					 _renglon			,
					 _ult_gestion       ,
					 _user_ult_gestion  ,
					 _fecha_ult_gestion ,
					 _estatus_poliza	,
					 _cancela           ,
				   	 _impreso        
				   	 WITH RESUME;
		ELSE
			EXIT;
		END IF
	    END WHILE
	  CLOSE xcur;	
	   FREE xcur;
	   FREE xsql;  
END FOREACH
end
DROP TABLE tmp_usuario159;
LET _sql_describe = "DROP TABLE "||trim(_table_temp)||" ";
EXECUTE IMMEDIATE _sql_describe;
end procedure	 