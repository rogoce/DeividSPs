-- Listado de pólizas de los corredores modulo de consultas web
-- Creado    : 07/08/2019 - Autor: Federico Coronado

DROP PROCEDURE sp_webcon01;

CREATE PROCEDURE sp_webcon01(a_sql_describe lvarchar)
  RETURNING VARCHAR(50) as ramo,			-- Ramo
			VARCHAR(50) as grupo,			-- Grupo
			VARCHAR(20) as usuario,    		-- Usuario
			VARCHAR(20) as no_documento,	-- Póliza
			VARCHAR(10) as estado,			-- Estado
			VARCHAR(100) as contratante,	-- Contratante
			VARCHAR(100) as pagador,		-- Pagador
			DATE as vigencia_inicial,		-- Vigencia_inic
			DATE as vigencia_final,			-- Vigencia_final
			DEC(16,2) as saldo,				-- Saldo
			DEC(16,2) as saldo_x_vencer,	-- Saldo x vencer
			DATE as fecha_suspension,		-- F. Suspensión
			DATE as fecha_aviso_canc,		-- F. Aviso Canc
			DEC(16,2) as exigible,			-- Exigible
			DEC(16,2) as corriente,			-- Corriente
			DEC(16,2) as _30dias,			-- 30 días
			DEC(16,2) as _60dias,			-- 60 días
			DEC(16,2) as _90dias,    		-- 90 días
			smallint  as pintar,			-- pintar
			varchar(10) as cod_cliente,		-- cod_cliente
			varchar(10) as no_poliza,		-- no_poliza
			smallint as leasing,			-- leasing
			VARCHAR(100) as asegurado;		-- Asegurado
			
			
DEFINE _vig_inicial			date; 
DEFINE _vig_final 			date;
DEFINE _fecha_aviso_canc 	date;
DEFINE _num_poliza 			varchar(20);
DEFINE _ramo 				varchar(50);
DEFINE _status_poliza		varchar(10); 
DEFINE _saldo				decimal(16,2);
DEFINE _saldo_venc			decimal(16,2);
DEFINE _cod_cliente			varchar(10);
DEFINE _cod_pagador			varchar(10);
define _cod_asegurado_uni	varchar(10);
DEFINE _saldo_pend			decimal(16,2);
DEFINE _saldo_corr			decimal(16,2);
DEFINE _saldo_30dias		decimal(16,2);
DEFINE _saldo_60dias		decimal(16,2);
DEFINE _saldo_90dias		decimal(16,2);
DEFINE _nombre_asegurado    varchar(100);
DEFINE _nombre_contratante  varchar(100);
DEFINE _nombre_pagador      varchar(100);
DEFINE _no_poliza           varchar(10);
DEFINE _cod_ramo			varchar(3); 
DEFINE _cod_grupo			varchar(5); 
DEFINE _user_added			varchar(8); 
DEFINE _cod_sucursal		varchar(3);
DEFINE _nueva_renov			varchar(1);
define _fecha_suspension    date;
define _nombre_cliente      varchar(100);
define _nombre_grupo        varchar(50);
define _periodo_hoy         varchar(7);
define _fecha               date;
define _pintar              smallint;
define _leasing             smallint;
define _cnt_uni             smallint;
define _estatus_poliza      smallint;

--SET DEBUG FILE TO "sp_webcon01.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

let _nombre_asegurado = '';
let _nombre_pagador	  = '';	
let _fecha = today; 
 call deivid:sp_sis39(_fecha) RETURNING _periodo_hoy;
prepare equisql from a_sql_describe;	
declare equicur cursor for equisql;
open equicur;
	while (1 = 1)
		fetch equicur into	_vig_inicial,		
							_vig_final, 		
							_fecha_aviso_canc,
							_num_poliza, 		
							_ramo,			
							_status_poliza,	
							_saldo,			
							_saldo_venc,
							_nombre_cliente,
							_cod_cliente,		
							_saldo_pend,		
							_saldo_corr,		
							_saldo_30dias,	
							_saldo_60dias,	
							_saldo_90dias;	
		IF (SQLCODE = 100) THEN
			EXIT;
		END IF
		/*
		if (sqlcode != 100) then
		
		end if		
		*/										
							
/*							
FOREACH
	select  SKIP a_indice FIRST a_cnt_registros p.vig_inicial, 
		   p.vig_final, 
		   p.fecha_aviso_canc, 
		   p.num_poliza, 
		   p.ramo, 
		   p.status_poliza, 
		   p.saldo, 
		   p.saldo_venc, 
		   p.cod_cliente, 
		   saldo_pend,
		   saldo_corr, 
		   saldo_30dias, 
		   saldo_60dias, 
		   saldo_90dias
	  into _vig_inicial,		
	       _vig_final, 		
	       _fecha_aviso_canc,
	       _num_poliza, 		
	       _ramo,			
	       _status_poliza,	
	       _saldo,			
	       _saldo_venc,		
	       _cod_cliente,		
	       _saldo_pend,		
	       _saldo_corr,		
	       _saldo_30dias,	
	       _saldo_60dias,	
	       _saldo_90dias	
	  from web_poliza p
	 where p.cod_agente = a_cod_agente
  ORDER BY p.num_poliza ASC
*/
		let _no_poliza = deivid:sp_sis21(_num_poliza);
		
		if _no_poliza is null or _no_poliza = '' Then
		   continue;
		end if
		
		select cod_pagador,
			   cod_ramo, 
			   cod_grupo, 
			   user_added, 
			   cod_sucursal,
			   nueva_renov,
			   leasing,
			   estatus_poliza
		  into _cod_pagador,
			   _cod_ramo, 
			   _cod_grupo, 
			   _user_added, 
			   _cod_sucursal,
			   _nueva_renov,
			   _leasing,
			   _estatus_poliza
		 from deivid:emipomae
		where no_poliza = _no_poliza;
		
		select nombre 
		  into _nombre_grupo
		  from deivid:cligrupo 
		 where cod_grupo = _cod_grupo;
		
		if _cod_grupo = '00001' then
			let _nombre_grupo = " --- ";
		end if

		if _cod_grupo = '01077' then
			let _user_added   = " --- ";
		end if
		
		if _cod_sucursal <> '009' then
			let _user_added   = " --- ";
		end if
		
--		if _cod_sucursal = '009' and _nueva_renov = 'R' then
--			let _user_added   = " --- ";
--		end if			
		
		SELECT fecha_suspension
		  into _fecha_suspension
		  FROM deivid:emipoliza 
		 WHERE no_documento = _num_poliza;
		 
		let _pintar = 0;
		
		if _fecha_suspension is null or _fecha_suspension = '' Then
		   let _fecha_suspension = null;
		else
			if date(_fecha) > date(_fecha_suspension) then
				if _estatus_poliza = 1 then --solo pólizas vigentes las pinta de naranja.
					let _pintar = 1;
				end if
			else
				let _fecha_suspension = null;
			end if
		end if	

		select nombre
		  into _nombre_pagador
		  from deivid:cliclien
		 where cod_cliente = _cod_pagador;
		  
		select nombre
		  into _nombre_contratante
		  from deivid:cliclien
		 where cod_cliente = _cod_cliente;
		 
		select count(*)
		  into _cnt_uni
		  from deivid:emipouni
		 where no_poliza = _no_poliza;
		
		if _cnt_uni > 1 then
			let _nombre_asegurado = "";
		else 
			select cod_asegurado
			 into _cod_asegurado_uni
			 from deivid:emipouni
			where no_poliza = _no_poliza;
			
			select nombre
			  into _nombre_asegurado
			  from deivid:cliclien
			 where cod_cliente = _cod_asegurado_uni;
		end if
		 
		 
		 
	  
	  	-- Morosidad de la Poliza
		call deivid:sp_cob33(
			'001',
			_cod_sucursal,
			_num_poliza,
			_periodo_hoy,
			_fecha
		   	) RETURNING _saldo_venc,
						_saldo_pend,
						_saldo_corr,
						_saldo_30dias,
						_saldo_60dias,
						_saldo_90dias,
						_saldo;
		if _cod_ramo in('002','020','023','018') then
			let _nombre_contratante = _nombre_pagador;
		end if
	  
		RETURN  _ramo,
				_nombre_grupo,
				_user_added,
				_num_poliza,
				_status_poliza,
				_nombre_contratante,
				_nombre_pagador,
				_vig_inicial,
				_vig_final,
				_saldo,
				_saldo_venc,
				_fecha_suspension,
				_fecha_aviso_canc,
				_saldo_pend,
				_saldo_corr,
				_saldo_30dias,
				_saldo_60dias,
				_saldo_90dias,
				_pintar,
				_cod_cliente,
				_no_poliza,
				_leasing,
				_nombre_asegurado
				WITH RESUME;
	end while
close equicur;	
free equicur;
free equisql;						
	
--END FOREACH

END PROCEDURE;