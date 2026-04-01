-- Proceso que despliega la informacion de tab en aviso de cancelacion. 
-- Realizado : Henry Giron 28/08/2010 
Drop procedure sp_cob752_p; 
create procedure sp_cob752_p(a_referencia char(15), a_tab smallint, a_proceso smallint, a_usuario char(15) )
returning  CHAR(1), CHAR(255);
										
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
DEFINE _error			   integer      ;
define _error_isam		   integer      ;
DEFINE _error_desc		   char(50)     ;
DEFINE _se_desmarco        SMALLINT     ;
DEFINE _user_clase         CHAR(15)   	;
DEFINE _fecha_clase        DATE   		;


--  Set debug file to "sp_cob752_p.trc" ;
--  Trace on  ;
SET ISOLATION TO DIRTY READ;
--return 0,"Realizado Exitosamente. En Base de prueba de Sistema.";
SET LOCK MODE TO WAIT;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Estatus
-- G - Proceso
-- R - Clasificar (Email,Apartado,Otros)
-- I - Imprimir	y Enviar
--X M - Marcar Aviso
--X E - Marcar Conservacion
-- X - Procesar a Quince dias
-- Y - Desmarcar Poliza x Pagos
-- Z - Cancelar	Poliza

-- Estatus
-- G - Genera
-- D - Desmarca o C - Clasificar (Email,Apartado,Otros)
-- P - Procesa 
-- I - Imprimir	y Enviar
--X M - Marcar Aviso
--X E - Marcar Conservacion
-- X - Procesar a Quince dias
-- Y - Desmarcar Poliza x Pagos
-- Z - Cancelar	Poliza

let _renglon     = 0;
let _veces       = 0;
let _se_desmarco = 0;

foreach
	select cod_cobrador 
	  into _cobrador
	  from cobcobra 
	 where activo = '1' 
	   and usuario = a_usuario 
     order by 1 asc
	  exit foreach;
end foreach

let _motivo_desmarca = "";
let _saldo_cancelado = 0.00;

FOREACH
	SELECT no_poliza,
	       renglon,
		   estatus,
	       email_cli
	  INTO _no_poliza,
		   _no_aviso,
		   _estatus,
		   _email_cli
	  FROM avisocanc
	 WHERE no_aviso = a_referencia
--	   AND estatus  = "G"

	{SELECT a.no_documento	,   
	     a.nombre_cliente	,   
	     a.nombre_agente	,   
	     a.periodo			,   
	     a.vigencia_inic	,   
	     a.vigencia_final	,   
	     a.nombre_ramo		,   
	     a.saldo			,   
	     a.por_vencer		,   
	     a.exigible			,   
	     a.dias_30			,   
	     a.dias_60			,   
	     a.dias_90			,   
	     a.dias_120			,   
	     a.no_poliza		,   
	     a.no_aviso			,   
	     a.estatus			,   
	     a.fecha_vence		,   
	     a.user_proceso		,   
	     a.email_cli		,   
	     a.apart_cli  		,
		 a.nombre_acreedor 	,
		 a.cod_acreedor		,
		 a.clase            ,
		 a.marcar_entrega   ,
		 a.user_marcar      ,
		 a.fecha_marcar		,
		 a.desmarca       	,
		 a.user_desmarca  	,
		 a.fecha_desmarca 	,
		 trim(a.motivo_desmarca),
		 a.renglon      	,
		 a.ult_gestion      ,
		 a.user_ult_gestion ,
		 a.fecha_ult_gestion,
		 a.saldo_cancelado 	,
		 a.estatus_poliza
	INTO _no_documento   	,
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
		 _estatus_poliza
	FROM avisocanc a 
   WHERE a.no_aviso = a_referencia 
     and a.estatus  = "G" }

	  IF a_tab = 1 THEN     -- x Corredores	
		  IF _estatus not in ("G") THEN		-- Realiza el proceso de clasificacion e impresion
			 CONTINUE FOREACH;
	     END IF

		  IF trim(_email_cli) = "" or _email_cli is null then
		     LET _clase= "2" ;
		 ELSE
		     LET _clase= "1" ;
	     END IF

		 LET _fecha_desmarca = current;
		 LET _user_desmarca  = TRIM(a_usuario);

		 LET _fecha_clase    = current;
		 LET _user_clase     = TRIM(a_usuario);

		Update avisocanc
		Set    estatus      = "I",             
		       clase        = _clase,
		       fecha_clase  = ld_fecha,
		       user_clase  = :g_globales.istr_usuario.usuario,
		       marcar_entrega = "1"
		 Where no_aviso  = a_referencia 
		   and no_poliza = _no_poliza 
		   and renglon   = _renglon	

     END IF

	  IF a_tab = 2 THEN     -- x Acreedores
	     let _marcar_entrega = 1;

		  IF trim(_cod_acreedor) = "" THEN 
		     CONTINUE FOREACH; 
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

     END IF
	  IF a_tab = 3 then		-- x Procesos
		  IF _estatus not in ('I','R','M') THEN
--		  IF _estatus not in ('R') THEN
			 CONTINUE FOREACH;
	     END IF

		 { IF a_proceso <> _clase THEN
			 CONTINUE FOREACH;
	     END IF}
		 let _marcar_entrega = 1;
     END IF 
	  IF a_tab = 4 THEN     -- x Entregado
		  IF _estatus not in ('I') THEN		-- ('M')
			 CONTINUE FOREACH;
	     END IF

		  {IF a_proceso <> _clase THEN
			 CONTINUE FOREACH;
	     END IF}
		 let _marcar_entrega = 0;
		 let _fecha_marcar = null;

     END IF
	  IF a_tab = 5 THEN      -- x Conservacion de cartera
		  IF _estatus not in ('E') THEN
			 CONTINUE FOREACH;
	     END IF
		 let _marcar_entrega = 0;
     END IF
	  IF a_tab = 6 THEN     -- x Seleccionar cancelado	  sp_cob753 X-Acancelar
--	     let _marcar_entrega = 1;
		  IF _estatus  not in ('X') THEN
			 CONTINUE FOREACH;
	     END IF
		 if _ult_gestion = 1 then
		    let _marcar_entrega = 0;
		 end if
     END IF
	  IF a_tab = 7 THEN     -- x Seleccionar cancelado	  sp_cob753 Z-canceladas Y-desmarcardas
		  IF _estatus  not in ('Z','Y') THEN
			 CONTINUE FOREACH;
	     END IF
		 let _marcar_entrega = 0;
		 let _desmarca = 0;
		  IF a_proceso = 1 THEN			 -- Polizas Canceladas
			  IF _estatus  not in ('Z') THEN
				 CONTINUE FOREACH;
		     END IF
	     END IF
		  IF a_proceso = 2 THEN			 -- Polizas Desmarcadas
		     IF _estatus  not in ('Y') THEN
				 CONTINUE FOREACH;
		     END IF
	     END IF
		  IF a_proceso = 3 THEN			 -- Polizas Ultima Gestion
			 if _ult_gestion <> 1 then
			     CONTINUE FOREACH;
			 end if
	     END IF
		  IF a_proceso = 4 THEN			 --Saldo de cancelacion por Prorrata
			  IF _estatus <> ('Z') THEN
				 	CONTINUE FOREACH;
		     END IF
	      	  if _saldo_cancelado = 0 then
    			 	CONTINUE FOREACH;
		     end if
	     END IF
     END IF
END FOREACH
--trace off;
if _error <> 0 then
	return 1,"Error de Proceso." ;
else							
	return 0,"Realizado Exitosamente.";
end if

end
end procedure
	  