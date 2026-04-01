-- Proceso que despliega la informacion de tab en aviso de cancelacion.
-- Realizado : Henry Giron 28/08/2010
Drop procedure sp_cob764;
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
DEFINE _fecha_actual	   DATE			;
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
DEFINE _fecha_imprimir	   DATE   		;
DEFINE _fecha_proceso	   DATE   		;
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
DEFINE _dias			   SMALLINT     ;
DEFINE _saldo_incobrable   DECIMAL(16,2);
DEFINE _error              SMALLINT     ;
DEFINE _descripcion		   CHAR(50)   	;
DEFINE _usuario2           CHAR(15)     ;
define _mes_char		   CHAR(2)		;
define _ano_char		   CHAR(4)		;
DEFINE _saldo_pago 		   DECIMAL(16,2);
DEFINE _periodo_c		   CHAR(7)		;
DEFINE _saldo_c   		   DECIMAL(16,2);
define _corriente_c 	   DECIMAL(16,2);
DEFINE _por_vencer_c	   DECIMAL(16,2);
DEFINE _exigible_c		   DECIMAL(16,2);
DEFINE _dias_30_c		   DECIMAL(16,2);
DEFINE _dias_60_c		   DECIMAL(16,2);
DEFINE _dias_90_c		   DECIMAL(16,2);
DEFINE _dias_120_c		   DECIMAL(16,2);
DEFINE _dias_150_c 		   DECIMAL(16,2);
DEFINE _dias_180_c		   DECIMAL(16,2);
DEFINE _hay_pago		   SMALLINT     ;
DEFINE _saldo_sin_mora	   DECIMAL(16,2);
DEFINE _cod_ramo		   CHAR(3)		;


-- RETURN 1,'SOLICITAR AUTORIZACION A COMPUTO';	  -- Quitar cuando se desee eliminar la carga
begin


LET _no_documento     = ' '  ; --'SOLICITAR'  ;
LET _nombre_cliente   = ' '  ; --'AUTORIZACION '  ;
LET _nombre_agente    = ' '  ; --'A HENRY'  ;
LET _periodo	      = ' '  ;
LET _vigencia_inic    = ' '  ;
LET _vigencia_final	  = ' '  ;
LET _nombre_ramo	  = ' '  ;
LET _saldo   		  = ' '  ;
LET _por_vencer		  = ' '  ;
LET _exigible		  = ' '  ;
LET _dias_30		  = ' '  ;
LET _dias_60		  = ' '  ;
LET _dias_90		  = ' '  ;
LET _dias_120		  = ' '  ;
LET _no_poliza		  = ' '  ;
LET _no_aviso		  = ' '  ;
LET _estatus		  = ' '  ;
LET _fecha_vence	  = ' '  ;
LET _user_proceso	  = ' '  ;
LET _email_cli		  = ' '  ;
LET _apart_cli		  = ' '  ;
LET _nombre_acreedor  = ' '  ;
LET _clase            = ' '  ;
LET _marcar_entrega   = ' '  ;
LET _user_marcar      = ' '  ;
LET _fecha_marcar     = ' '  ;
LET _desmarca         = ' '  ;
LET _user_desmarca    = ' '  ;
LET _fecha_desmarca   = ' '  ;
LET _motivo_desmarca  = ' '  ;
LET _renglon		  = ' '  ;
LET _ult_gestion      = ' '  ;
LET _user_ult_gestion = ' '  ;
LET _fecha_ult_gestion= ' '  ;
LET _estatus_poliza	  = ' '  ;
LET _cancela          = ' '  ;
let _renglon = 0;
let _veces   = 0;
let _cancela = 0;
let _impreso = 0;
let _hay_pago = 0;
let _saldo_incobrable = 0;
let _fecha_actual = today;
LET _periodo_c	      = ' '  ;
LET _saldo_sin_mora = 0;

{RETURN _no_documento   	,
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
	   	 _impreso; }

-- ver la informacion por gestor - supervisor - jefe de cobros
-- Temporal por gestor

SELECT * FROM AVISOCANC INTO temp tmp_a1;

IF MONTH(_fecha_actual) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_actual);
ELSE
	LET _mes_char = MONTH(_fecha_actual);
END IF

LET _ano_char = YEAR(_fecha_actual);
LET _periodo_c  = _ano_char || "-" || _mes_char;

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

--SET DEBUG FILE TO "sp_cob752.trc";
--TRACE ON;


let _fecha_actual = current;
let _fecha_actual = today;

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
	let a_tab = a_tab;
	if a_tab = 4 and a_proceso = 2 then
       let a_referencia2 = "%";
	end if
	if a_tab >= 5 then
	   let a_referencia2 = "%";
	else
	   let a_referencia2 = a_referencia;
	end if

	FOREACH
		SELECT a.no_documento	,
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
		     a.dias_150			,
		     a.dias_180			,
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
			 a.estatus_poliza	,
			 a.cancela			,
			 a.impreso			,
			 a.fecha_imprimir	,
			 a.fecha_proceso	,
			 a.cod_ramo
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
			 _impreso           ,
			 _fecha_imprimir	,
			 _fecha_proceso		,
			 _cod_ramo
		FROM tmp_a1 a
	   WHERE a.no_aviso like (a_referencia2)
	     AND a.user_proceso = _usuario2
--       AND a.no_documento in ('0103-00203-01','0208-00450-01','0411-00013-01')
	  -- AND a.no_documento in ('0209-00319-02','0210-00214-04')
	  -- AND a.cod_cobrador = _cobrador

			let _dias_90  	= _dias_90+_dias_120+_dias_150+_dias_180;
			let _dias_120 	= 0.00;
			let _dias_150 	= 0.00;
			let _dias_180 	= 0.00;
			let _saldo_pago = 0.00;
			 if _cod_ramo in ("004","016","018","019") then
				let _saldo_sin_mora = _saldo - (_dias_60+_dias_90);
		   else
				let _saldo_sin_mora = _saldo - _dias_90;
			end if

			if _estatus not in ('G') then
				if _fecha_imprimir is null then
				   let _fecha_imprimir = _fecha_proceso;
			   end if
			   let _hay_pago = 0;
				select count(*) --saldo
				  into _hay_pago
				  from emipomae
				 where no_poliza = _no_poliza
				   and no_documento	= _no_documento
				   and fecha_ult_pago >= _fecha_imprimir;
--				   and saldo < _exigible;
					if _hay_pago >= 1 then
						   let _saldo_pago = 0.00;
						select saldo
						  into _saldo_pago
						  from emipomae
						 where no_poliza = _no_poliza
						   and no_documento	= _no_documento
						   and fecha_ult_pago >= _fecha_imprimir;

						if _saldo_pago is null then
						   let _saldo_pago = 0.00;
					   end if
--					   if _saldo_pago <= _exigible then
					   if _saldo_pago <= _saldo_sin_mora or abs(_saldo_pago - _saldo_sin_mora) <= 5.00 then
							continue foreach;
					   else
							 -- si el pago es en el dia
							 -- TRACE Off;
				 		   	 CALL sp_cob245("001","001",_no_documento,_periodo_c,_fecha_actual)
				 		   	 RETURNING _por_vencer_c,
									   _exigible_c,
									   _corriente_c,
									   _dias_30_c,
									   _dias_60_c,
									   _dias_90_c,
									   _dias_120_c,
									   _dias_150_c,
									   _dias_180_c,
									   _saldo_c;
							  -- TRACE ON;
							  IF _saldo_c = 0 then
								 continue foreach;
							  end if

							  IF _saldo <> _saldo_c then
									let _saldo = _saldo_c;
									let _por_vencer = _por_vencer_c; 
									let _exigible 	= _exigible_c; 
--									let _corriente 	= _corriente_c;	
									let _dias_30  	= _dias_30_c;
									let _dias_60  	= _dias_60_c;
									let _dias_90  	= _dias_90_c+_dias_120_c+_dias_150_c+_dias_180_c;
									let _dias_120 	= 0.00;
									let _dias_150 	= 0.00;
									let _dias_180 	= 0.00;
							  end if
					  end if
			   end if
			end if

		  IF a_tab = 1 THEN      -- x Corredores
			 IF _estatus in ('Q') THEN
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
				let _dias_60 = _dias_60+_dias_120;
				let _dias_120 = 0.00;
	     END IF
		  IF a_tab = 3 then		-- x Procesos
			  IF _estatus not in ('I','R','M') THEN
	--		  IF _estatus not in ('R') THEN
				 CONTINUE FOREACH;
		     END IF
			 { IF a_proceso <> _clase THEN
				 CONTINUE FOREACH;
		     END IF }
			 let _marcar_entrega = 1;
	     END IF
		  IF a_tab = 4 THEN     -- x Entregado
			  IF a_proceso = 1 THEN			 -- Polizas Canceladas
				  IF _estatus not in ('I','M') THEN		-- ('M')
					 CONTINUE FOREACH;
			     END IF
		     END IF
			  IF a_proceso = 2 THEN			 -- Polizas diarias
				  IF _estatus not in ('X') THEN		-- ('M')
					 CONTINUE FOREACH;
			     END IF
				 call sp_sis388(_fecha_marcar,_fecha_actual) returning _dias;
				 let _cancela = _dias;
--				 if _cancela > 11 then
--				 	continue foreach;
--				end if
		     END IF
	     END IF
		  IF a_tab = 5 THEN     -- x Conservacion de cartera
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
			 let _marcar_entrega = 0;
	     END IF
		  IF a_tab = 7 THEN     -- x Seleccionar cancelado	  sp_cob753 Z-canceladas Y-desmarcardas
				  IF _estatus  not in ('Z','Y','X') THEN
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
			  IF a_proceso = 3 THEN	 --  Ultima gestion
				  IF _estatus not in ("X") THEN
					 CONTINUE FOREACH;
			     END IF
				 IF _user_ult_gestion is null THEN
				     CONTINUE FOREACH;
			     END IF
		     END IF
			  IF a_proceso = 4 THEN			 --Saldo de cancelacion por Prorrata
				  IF _estatus  not in ('Z') THEN
					 CONTINUE FOREACH;
			     END IF
				 let _saldo_incobrable = _saldo - _saldo_cancelado;
				  IF _saldo_incobrable = 0 THEN
					 CONTINUE FOREACH;
			     END IF
				 let _saldo = _saldo_incobrable;
		     END IF

	     END IF

		  IF a_tab = 8 THEN     -- x Seleccionar cancelado	  sp_cob753 X-Acancelar
--	     let _marcar_entrega = 1;
--			  IF _estatus  not in ('Y') and _estatus_poliza <> 1 and _saldo <= 0 THEN
			  IF _estatus  not in ('Y')  THEN
				 CONTINUE FOREACH;
		     END IF
			  IF _estatus_poliza  not in (3)  THEN
				 CONTINUE FOREACH;
		     END IF

	     END IF


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
	END FOREACH
END FOREACH
end
DROP TABLE tmp_usuario159;
DROP TABLE tmp_a1;

end procedure
	   
