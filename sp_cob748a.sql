-- Reporte de Aviso de Cancelacion - Marcados como entregados
-- Creado    : 31/07/2000 - Autor: Henry Giron
-- SIS v.2.0 - d_cobr_sp_cob748_dw4 - DEIVID, S.A.  -- x corredor

DROP PROCEDURE sp_cob748a;
CREATE PROCEDURE "informix".sp_cob748a(a_compania CHAR(3),a_cobrador CHAR(3) DEFAULT '*',a_tipo_aviso SMALLINT,a_agente CHAR(5) DEFAULT '*',a_acreedor CHAR(5) DEFAULT '*', a_asegurado CHAR(10) DEFAULT '*',a_callcenter SMALLINT DEFAULT 0, a_referencia CHAR(15), a_clase smallint, a_tab smallint)
RETURNING  CHAR(15), 		   -- no_aviso
		    CHAR(20), 		   -- no_documento
		    CHAR(10), 		   -- no_poliza
		    CHAR(7), 		   -- periodo
		    DATE, 			   -- vigencia_inic
		    DATE, 			   -- vigencia_final
		    CHAR(3), 		   -- cod_ramo
		    CHAR(50), 		   -- nombre_ramo
		    CHAR(50), 		   -- nombre_subramo
		    CHAR(10), 		   -- cedula
		    CHAR(100), 		   -- nombre_cliente
		    DECIMAL(16,2),	   -- saldo
		    DECIMAL(16,2),	   -- por_vencer
		    DECIMAL(16,2),	   -- exigible
		    DECIMAL(16,2),	   -- corriente
		    DECIMAL(16,2),	   -- dias_30
			DECIMAL(16,2),	   -- dias_60
			DECIMAL(16,2),	   -- dias_90
			DECIMAL(16,2),	   -- dias_120
			DECIMAL(16,2),	   -- dias_150
			DECIMAL(16,2),	   -- dias_180
			CHAR(5), 		   -- cod_acreedor
			CHAR(50), 		   -- nombre_acreedor
			CHAR(5), 		   -- cod_agente
			CHAR(50), 		   -- nombre_agente
			DECIMAL(16,2),	   -- porcentaje
			CHAR(10), 		   -- telefono
			CHAR(3), 		   -- cod_cobrador
			CHAR(3), 		   -- cod_vendedor
 			CHAR(20), 		   -- apartado
 			CHAR(10), 		   -- fax_cli
 			CHAR(10), 		   -- tel1_cli
 			CHAR(10), 		   -- tel2_cli
 			CHAR(20), 		   -- apart_cli
 			CHAR(50), 		   -- email_cli
 			DATE,  			   -- fecha_proc
 			CHAR(3),  		   -- cod_forma_pago
			CHAR(50),		   -- forma_pago
			CHAR(1),		   -- cobra_poliza
			CHAR(50),		   -- compania_nombre
			CHAR(50),		   -- cobrador
			CHAR(50),		   -- clase
			CHAR(1),		   -- estatus_poliza
			CHAR(10);		   -- no_factura


DEFINE _compania_nombre 	CHAR(50);
DEFINE _nombre_cobrador 	CHAR(50);
DEFINE _no_aviso 			CHAR(15);
DEFINE _no_documento 		CHAR(20);
DEFINE _no_poliza 			CHAR(10);
DEFINE _periodo 			CHAR(7);
DEFINE _vigencia_inic 		DATE;
DEFINE _vigencia_final 	    DATE;
DEFINE _cod_ramo 			CHAR(3);
DEFINE _nombre_ramo 		CHAR(50);
DEFINE _nombre_subramo 	    CHAR(50);
DEFINE _cedula 				CHAR(10);
DEFINE _nombre_cliente 	    CHAR(100);
DEFINE _saldo 				DECIMAL(16,2);
DEFINE _por_vencer 			DECIMAL(16,2);
DEFINE _exigible 			DECIMAL(16,2);
DEFINE _corriente 			DECIMAL(16,2);
DEFINE _dias_30 			DECIMAL(16,2);
DEFINE _dias_60 			DECIMAL(16,2);
DEFINE _dias_90 			DECIMAL(16,2);
DEFINE _dias_120 			DECIMAL(16,2);
DEFINE _dias_150 			DECIMAL(16,2);
DEFINE _dias_180 			DECIMAL(16,2);
DEFINE _cod_acreedor 		CHAR(10);  --CHAR(5);
DEFINE _nombre_acreedor 	CHAR(50);
DEFINE _cod_agente 			CHAR(5);
DEFINE _nombre_agente 		CHAR(50);
DEFINE _porcentaje 			DECIMAL(16,2);
DEFINE _telefono 			CHAR(10);
DEFINE _cod_cobrador 		CHAR(3);
DEFINE _cod_vendedor 		CHAR(3);
DEFINE _apartado 			CHAR(20);
DEFINE _fax_cli 			CHAR(10);
DEFINE _tel1_cli 			CHAR(10);
DEFINE _tel2_cli 			CHAR(10);
DEFINE _apart_cli 			CHAR(20);
DEFINE _email_cli 			CHAR(50);
DEFINE _fecha_proc 			DATE;
DEFINE _cobra_poliza	 	CHAR(1);
DEFINE _cod_formapag    	CHAR(3);
DEFINE _nombre_formapag 	CHAR(50);
DEFINE n_clase 				CHAR(50);
DEFINE _status				CHAR(1);
DEFINE _status_filtro       CHAR(1);
DEFINE _clase				CHAR(1);
DEFINE _estatus_poliza		CHAR(1);
DEFINE _user_cancela        CHAR(15);
DEFINE _user_filtro         CHAR(15);
DEFINE _no_factura      	CHAR(10);
DEFINE _error               SMALLINT;
DEFINE _descripcion		    CHAR(50);
DEFINE _saldo_cancelado     DECIMAL(16,2);
DEFINE _ult_gestion         SMALLINT;
DEFINE _desmarca            SMALLINT;

SET ISOLATION TO DIRTY READ;

let n_clase = '';
let _clase  = '';
let _status = '';
let _saldo_cancelado = 0;
let _desmarca = 0;

IF a_agente = '%'	THEN
	LET a_agente = '*';
END IF

IF a_acreedor = '%'	THEN
	LET a_acreedor = '*';
END IF

IF a_asegurado = '%'	THEN
	LET a_asegurado = '*';
END IF

IF a_cobrador = '%'	THEN
	LET a_cobrador = '*';
END IF

-- Nombre de la Compania
LET  _compania_nombre = sp_sis01(a_compania);

if a_callcenter = 0 then
	let _cobra_poliza = "C";
else
	let _cobra_poliza = "E";
end if

if a_tab = 4 then -- tab status marcado
	let _status_filtro = 'M';
	let _clase = a_clase;
	if a_clase = 1 then
		let n_clase = "Entregado por Correo";
	else
		if a_clase = 2 then
			let n_clase = "Entregado por Apartado";
		else
			let n_clase = "Entregado sin Correo ni Apartado";
		end if
	end if
end if

if a_tab = 5 then -- tab status conservacion
	let _status_filtro = 'E';
	let _clase = '*';
	let n_clase = "Polizas en Conservacion de Cartera";
end if

if a_tab = 6 then -- tab status A cancelar
	let _status_filtro = 'X';
	let _clase = '*';
	let n_clase = "Polizas Canceladas";
end if

if a_tab = 7 then -- tab status Resultado
	let _clase = '*';
	if a_clase = 1 then
		let _status_filtro = 'Z';
		let n_clase = "Polizas Canceladas";

	 foreach
	 select distinct usuario2
	   into _user_filtro
	   FROM avisocanc
	  WHERE no_aviso   = a_referencia
	  exit foreach;
	  end foreach
	end if
	if a_clase = 2 then
		let _status_filtro = 'Y';
		let n_clase = "Polizas Desmarcadas";
	 foreach
	 select distinct usuario2
	   into _user_filtro
	   FROM avisocanc
	  WHERE no_aviso   = a_referencia
	  exit foreach;
	  end foreach
	end if
	if a_clase = 3 then
		let _status_filtro = 'Y';
		let n_clase = "Polizas en Ultima Gestion";
	 foreach
	 select distinct usuario2
	   into _user_filtro
	   FROM avisocanc
	  WHERE no_aviso   = a_referencia
	  exit foreach;
	  end foreach
	end if
	if a_clase = 4 then
		let _status_filtro = 'Z';
		let n_clase = "Polizas Canceladas con Prima Devengada";
	 foreach
	 select distinct usuario2
	   into _user_filtro
	   FROM avisocanc
	  WHERE no_aviso   = a_referencia
	  exit foreach;
	  end foreach
	end if
	if a_clase = 5 then
		let _status_filtro = 'M';
		let n_clase = "Polizas Entregadas";
	 foreach
	 select distinct usuario2
	   into _user_filtro
	   FROM avisocanc
	  WHERE no_aviso   = a_referencia
	  exit foreach;
	  end foreach
	end if
end if


-- Reporte de las Cartas a Imprimir
FOREACH
  SELECT no_aviso,
         no_documento,
         no_poliza,
         periodo,
         vigencia_inic,
         vigencia_final,
         cod_ramo,
         nombre_ramo,
         nombre_subramo,
         cedula,
         nombre_cliente,
         saldo,
         por_vencer,
         exigible,
         corriente,
         dias_30,
         dias_60,
         dias_90,
         dias_120,
         dias_150,
         dias_180,
         cod_acreedor,
         nombre_acreedor,
         cod_agente,
         nombre_agente,
         porcentaje,
         telefono,
         cod_cobrador,
         cod_vendedor,
         apartado,
         fax_cli,
         tel1_cli,
         tel2_cli,
         apart_cli,
         email_cli,
         fecha_proceso,
		 cod_formapag,
		 nombre_formapag,
		 cobra_poliza,
		 estatus_poliza,
		 user_cancela,
		 estatus,
		 no_factura,
		 saldo_cancelado,
		 ult_gestion,
		 desmarca
  into  _no_aviso,
         _no_documento,
         _no_poliza,
         _periodo,
         _vigencia_inic,
         _vigencia_final,
         _cod_ramo,
         _nombre_ramo,
         _nombre_subramo,
         _cedula,
         _nombre_cliente,
         _saldo,
         _por_vencer,
         _exigible,
         _corriente,
         _dias_30,
         _dias_60,
         _dias_90,
         _dias_120,
         _dias_150,
         _dias_180,
         _cod_acreedor,
         _nombre_acreedor,
         _cod_agente,
         _nombre_agente,
         _porcentaje,
         _telefono,
         _cod_cobrador,
         _cod_vendedor,
         _apartado,
         _fax_cli,
         _tel1_cli,
         _tel2_cli,
         _apart_cli,
         _email_cli,
         _fecha_proc,
		 _cod_formapag,
		 _nombre_formapag,
		 _cobra_poliza,
		 _estatus_poliza,
		 _user_cancela,
		 _status,
		 _no_factura,
		 _saldo_cancelado,
		 _ult_gestion,
		 _desmarca
    FROM avisocanc
   WHERE cod_agente MATCHES a_agente
	 AND cod_acreedor MATCHES a_acreedor
	 AND cedula MATCHES a_asegurado
	 AND cod_cobrador MATCHES a_cobrador
--	 AND estatus = _status   -- marcado de entregado
--	 AND no_aviso   = a_referencia
	 AND clase MATCHES _clase
--	 AND user_cancela   = _user_cancela
   ORDER BY periodo, nombre_agente, nombre_cliente, no_documento

	if a_tab in (4,6) then -- tab status marcado
		if _status not in (_status_filtro) then
			continue foreach;
		end if
	end if

	if a_tab = 7 then -- tab status Resultado
		if _status not in (_status_filtro) then
			continue foreach;
		end if
		if a_clase = 1 then
			if _user_filtro <> _user_cancela then
				continue foreach;
			end if
			if _no_aviso not in (a_referencia) then
--				continue foreach;
			end if
		end if
		if a_clase = 2 then
			if _user_filtro <> _user_cancela then
--				continue foreach;
			end if
			if _status not in (_status_filtro) then
				continue foreach;
			end if
			if _no_aviso not in (a_referencia) then
--				continue foreach;
			end if
			if _desmarca not in (0) then
				continue foreach;
			end if			
		end if
		if a_clase = 3 then
			if _user_filtro <> _user_cancela then
--				continue foreach;
			end if
			if _ult_gestion <> 1 then
				continue foreach;
			end if
		end if
		if a_clase = 4 then
			if _user_filtro <> _user_cancela then
				continue foreach;
			end if
			if _saldo_cancelado <= 0 then
				continue foreach;
			end if
		end if
		if a_clase = 5 then
			if _user_filtro <> _user_cancela then
				continue foreach;
			end if
			if _saldo_cancelado <= 0 then
				continue foreach;
			end if
		end if

	end if

-- Cobrador

  SELECT nombre
    INTO _nombre_cobrador
    FROM cobcobra
   WHERE cod_cobrador = _cod_cobrador;

	RETURN _no_aviso,   		-- no_aviso
		   _no_documento,   	-- no_documento
		   _no_poliza,   		-- no_poliza
		   _periodo,   			-- periodo
		   _vigencia_inic,  	-- vig_inic
		   _vigencia_final, 	-- vig_final
		   _cod_ramo,   		-- cod_ramo
		   _nombre_ramo,   		-- n_ramo
		   _nombre_subramo, 	-- n_subramo
		   _cedula,   			-- cedula
		   _nombre_cliente, 	-- n_cliente
		   _saldo,   			-- saldo1
		   _por_vencer,   		-- porvencer
		   _exigible,   		-- exigible1
		   _corriente,   		-- corriente1
		   _dias_30,   			-- dias30
		   _dias_60,   			-- dias60
		   _dias_90,   			-- dias90
		   _dias_120,   		-- dias120
		   _dias_150,   		-- dias150
		   _dias_180,   		-- dias180
		   _cod_acreedor,   	-- acreedor
		   _nombre_acreedor,	-- n_acreedor
		   _cod_agente,   		-- cod_agente
		   _nombre_agente,  	-- n_agente
		   _porcentaje,   		-- porcentaje
		   _telefono,   		-- telefono
		   _cod_cobrador,   	-- cod_cobrador
		   _cod_vendedor,   	-- cod_vendedor
		   _apartado,   		-- apartado
		   _fax_cli,   			-- fax_cli
		   _tel1_cli,   		-- tel1_cli
		   _tel2_cli,   		-- tel2_cli
		   _apart_cli,   		-- apart_cli
		   _email_cli,   		-- email_cli
		   _fecha_proc,		   	-- fecha_proc
		   _cod_formapag,       -- cod_f_pago
		   _nombre_formapag, 	-- f_pago
		   _cobra_poliza,		-- cobra_poliza
		   _compania_nombre,    -- compania
		   _nombre_cobrador,    -- n_cobrador
		   n_clase,				-- titulo
		   _estatus_poliza,		-- estatus_poliza
		   _no_factura			-- factura
		   WITH RESUME;

END FOREACH

END PROCEDURE 
                                       
