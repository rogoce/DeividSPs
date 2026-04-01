-- Proceso que despliega la informacion de tab en aviso de cancelacion.
-- Realizado : Henry Giron 28/08/2010
Drop procedure sp_cob764;
create procedure sp_cob764(
a_referencia	char(15),
a_tab			smallint,
a_proceso		smallint,
a_usuario		char(15))
returning	char(20),			-- no_documento
			char(20),			-- nombre_cliente
			char(50),			-- nombre_agente
			char(7),			-- periodo
			date,				-- vigencia_inic
			date,				-- vigencia_final
			char(50),			-- nombre_ramo
			dec(16,2),			-- saldo
			dec(16,2),			-- por_vencer
			dec(16,2),			-- exigible
			dec(16,2),			-- dias_30
			dec(16,2),			-- dias_60
			dec(16,2),			-- dias_90
			dec(16,2),			-- dias_120
			char(10),			-- no_poliza
			char(15),			-- no_aviso
			char(1),			-- estatus
			date,				-- fecha_vence
			char(15),			-- user_proceso
			char(50),			-- email_cli
			char(20),			-- apart_cli
			char(50),			-- nombre_acreedor
			char(1),			-- clase
			char(1),			-- marcar_entrega
			char(15),			-- user_marcar
			date,				-- fecha_marcar
			char(1),			-- desmarca
			char(15),			-- user_desmarca
			date,				-- fecha_desmarca
			char(50),			-- motivo_desmarca
			smallint,            -- renglon
			char(1),			-- ult_gestion
			char(15),			-- user_ult_gestion
			date,				-- fecha_ult_gestion
			char(1),            -- estatus_poliza
			smallint,			-- cancela
			smallint;			-- impreso

define _nombre_acreedor		char(50);
define _motivo_desmarca		char(50);
define _nombre_agente		char(50);
define _nombre_ramo			char(50);
define _descripcion			char(50);
define _email_cli			char(50);
define _nombre_cliente		char(20);
define _no_documento		char(20);
define _apart_cli			char(20);
define _user_ult_gestion	char(15);
define _user_desmarca		char(15);
define a_referencia2		char(15);
define _user_proceso		char(15);
define _user_marcar			char(15);
define _usuario2			char(15);
define _no_aviso			char(15);
define _no_poliza			char(10);
define _periodo_c			char(7);
define _periodo				char(7);
define _cod_acreedor		char(5);
define _ano_char			char(4);
define _cobrador			char(3);
define _cod_ramo			char(3);
define _gestion				char(3);
define _marcar_entrega		char(1);
define _estatus_poliza		char(1);
define _ult_gestion			char(1);
define _desmarca			char(1);
define _estatus				char(1);
define _clase				char(1);
define _mes_char			char(2);
define _saldo_incobrable	dec(16,2);
define _saldo_cancelado		dec(16,2);
define _saldo_sin_mora		dec(16,2);
define _por_vencer_c		dec(16,2);
define _corriente_c			dec(16,2);
define _dias_180_c			dec(16,2);
define _dias_150_c			dec(16,2);
define _dias_120_c			dec(16,2);
define _exigible_c			dec(16,2);
define _saldo_pago			dec(16,2);
define _por_vencer			dec(16,2);
define _dias_30_c			dec(16,2);
define _dias_60_c			dec(16,2);
define _dias_90_c			dec(16,2);
define _dias_180			dec(16,2);
define _dias_150			dec(16,2);
define _dias_120			dec(16,2);
define _exigible			dec(16,2);
define _dias_90				dec(16,2);
define _dias_60				dec(16,2);
define _dias_30				dec(16,2);
define _saldo_c				dec(16,2);
define _saldo				dec(16,2);
define _hay_pago			smallint;
define _cancela				smallint;
define _impreso				smallint;
define _renglon				smallint;
define _error				smallint;
define _veces				smallint;
define _dias				smallint;
define _fecha_ult_gestion	date;
define _fecha_desmarca		date;
define _vigencia_final		date;
define _fecha_imprimir		date;
define _vigencia_inic		date;
define _fecha_proceso		date;
define _fecha_marcar		date;
define _fecha_actual		date;
define _fecha_vence			date;

-- RETURN 1,'SOLICITAR AUTORIZACION A COMPUTO';	  -- Quitar cuando se desee eliminar la carga
set isolation to dirty read;

begin

let _fecha_ult_gestion	= ' ';
let _user_ult_gestion	= ' ';
let _nombre_acreedor	= ' ';
let _motivo_desmarca	= ' ';
let _fecha_desmarca		= ' ';
let _marcar_entrega		= ' ';
let _estatus_poliza		= ' ';
let _vigencia_final		= ' ';
let _nombre_cliente		= 'AUTORIZACION ';
let _nombre_agente		= 'A HENRY';
let _user_desmarca		= ' ';
let _vigencia_inic		= ' ';
let _no_documento		= 'SOLICITAR';
let _fecha_marcar		= ' ';
let _user_proceso		= ' ';
let _user_marcar		= ' ';
let _ult_gestion		= ' ';
let _nombre_ramo		= ' ';
let _fecha_vence		= ' ';
let _por_vencer			= ' ';
let _periodo_c			= ' ';
let _email_cli			= ' ';
let _apart_cli			= ' ';
let _no_poliza			= ' ';
let _desmarca			= ' ';
let _no_aviso			= ' ';
let _exigible			= ' ';
let _dias_120			= ' ';
let _dias_90			= ' ';
let _dias_60			= ' ';
let _dias_30			= ' ';
let _estatus			= ' ';
let _periodo			= ' ';
let _renglon			= ' ';
let _cancela			= ' ';
let _saldo				= ' ';
let _clase				= ' ';
let _saldo_incobrable	= 0;
let _saldo_sin_mora		= 0;
let _hay_pago			= 0;
let _renglon			= 0;
let _cancela			= 0;
let _impreso			= 0;
let _veces				= 0;
let _fecha_actual		= today;

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
	   	 _impreso;}

-- ver la informacion por gestor - supervisor - jefe de cobros
-- Temporal por gestor

select *
  from avisocanc
 where no_aviso like (a_referencia) 
  into temp tmp_a1;

if month(_fecha_actual) < 10 then
	let _mes_char = '0'|| month(_fecha_actual);
else
	let _mes_char = month(_fecha_actual);
end if

let _ano_char = year(_fecha_actual);
let _periodo_c  = _ano_char || "-" || _mes_char;

call sp_sis159(a_usuario) returning _error, _descripcion;

if _error <> 0 then
	return _no_documento,
	   	 _nombre_cliente,
	   	 _nombre_agente,
	   	 _periodo,
	   	 _vigencia_inic,
	   	 _vigencia_final,
	   	 _nombre_ramo,
	   	 _saldo,
	   	 _por_vencer,
	   	 _exigible,
	   	 _dias_30,
	   	 _dias_60,
	   	 _dias_90,
	   	 _dias_120,
	   	 _no_poliza,
	   	 _no_aviso,
	   	 _estatus,
	   	 _fecha_vence,
	   	 _user_proceso,
	   	 _email_cli,
	   	 _apart_cli,
		 _nombre_acreedor,
		 _clase,
		 _marcar_entrega,
		 _user_marcar,
		 _fecha_marcar,
		 _desmarca,
		 _user_desmarca,
		 _fecha_desmarca,
		 _motivo_desmarca,
		 _renglon,
		 _ult_gestion,
		 _user_ult_gestion,
		 _fecha_ult_gestion,
		 _estatus_poliza,
		 _cancela,
	   	 _impreso 	 with resume;

	drop table tmp_usuario159;
end if

--set debug file to "sp_cob764.trc";
--trace on;

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
		   and usuario = _usuario2   -- a_usuario
	     order by 1 asc
		  exit foreach;
	end foreach

	let _motivo_desmarca = "";
	let _saldo_cancelado = 0.00;
	let a_tab = a_tab;

	if a_tab = 4 and a_proceso = 2 then
       let a_referencia2 = "%";
	end if

	{if a_tab >= 5 then
		--let a_referencia2 = "%";
	   let a_referencia2 = a_referencia;
	else
	   let a_referencia2 = a_referencia;
	end if}

	foreach
		select no_documento,
			   nombre_cliente,
			   nombre_agente,
			   periodo,
			   vigencia_inic,
			   vigencia_final,
			   nombre_ramo,
			   saldo,
			   por_vencer,
			   exigible,
			   dias_30,
			   dias_60,
			   dias_90,
			   dias_120,
			   dias_150,
			   dias_180,
			   no_poliza,
			   no_aviso,
			   estatus,
			   fecha_vence,
			   user_proceso,
			   email_cli,
			   apart_cli,
			   nombre_acreedor,
			   cod_acreedor,
			   clase,
			   marcar_entrega,
			   user_marcar,
			   fecha_marcar,
			   desmarca,
			   user_desmarca,
			   fecha_desmarca,
			   trim(motivo_desmarca),
			   renglon,
			   ult_gestion,
			   user_ult_gestion,
			   fecha_ult_gestion,
			   saldo_cancelado,
			   estatus_poliza,
			   cancela,
			   impreso,
			   fecha_imprimir,
			   fecha_proceso,
			   cod_ramo
		  into _no_documento,
			   _nombre_cliente,
			   _nombre_agente,
			   _periodo,
			   _vigencia_inic,
			   _vigencia_final,
			   _nombre_ramo,
			   _saldo,
			   _por_vencer,
			   _exigible,
			   _dias_30,
			   _dias_60,
			   _dias_90,
			   _dias_120,
			   _dias_150,
			   _dias_180,
			   _no_poliza,
			   _no_aviso,
			   _estatus,
			   _fecha_vence,
			   _user_proceso,
			   _email_cli,
			   _apart_cli,
			   _nombre_acreedor,
			   _cod_acreedor,
			   _clase,
			   _marcar_entrega,
			   _user_marcar,
			   _fecha_marcar,
			   _desmarca,
			   _user_desmarca,
			   _fecha_desmarca,
			   _gestion,
			   _renglon,
			   _ult_gestion,
			   _user_ult_gestion,
			   _fecha_ult_gestion,
			   _saldo_cancelado,
			   _estatus_poliza,
			   _cancela,
			   _impreso,
			   _fecha_imprimir,
			   _fecha_proceso,
			   _cod_ramo
		  from tmp_a1
		 where no_aviso like (a_referencia2)
		   and user_proceso = _usuario2
		-- AND a.no_documento in ('0103-00203-01','0208-00450-01','0411-00013-01')
		-- AND a.no_documento in ('0209-00319-02','0210-00214-04')
		--and no_documento = '0212-01430-01'
		-- AND a.cod_cobrador = _cobrador

		call sp_cob245("001","001",_no_documento,_periodo_c,_fecha_actual)
		returning	_por_vencer_c,
					_exigible_c,
					_corriente_c,
					_dias_30_c,
					_dias_60_c,
					_dias_90_c,
					_dias_120_c,
					_dias_150_c,
					_dias_180_c,
					_saldo_c;

		if _saldo_c = 0 then
			continue foreach;
		end if

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

			select count(*) -- saldo
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
				if _saldo_pago <= _saldo_sin_mora and abs(_saldo_pago - _saldo_sin_mora) <= 5.00 then
					continue foreach;
				else
					 -- si el pago es en el dia
					 --trace off;
					call sp_cob245("001","001",_no_documento,_periodo_c,_fecha_actual)
					returning	_por_vencer_c,
								_exigible_c,
								_corriente_c,
								_dias_30_c,
								_dias_60_c,
								_dias_90_c,
								_dias_120_c,
								_dias_150_c,
								_dias_180_c,
								_saldo_c;
					  --trace on;
					if _saldo_c = 0 then
						continue foreach;
					end if

					if _saldo <> _saldo_c then
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

		if a_tab = 1 then      -- x corredores
			if _estatus in ('Q','Y') THEN
				continue foreach;
			end if
			
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
		elif a_tab = 2 then     -- x acreedores
			let _marcar_entrega = 1;

			if trim(_cod_acreedor) = "" then
				continue foreach;
			end if
			
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
			
		elif a_tab = 3 then		-- x procesos
			if _estatus not in ('I','R','M') then
				continue foreach;
			end if
			 { if a_proceso <> _clase then
				 continue foreach;
		     end if }
			 let _marcar_entrega = 1;
			 
		elif a_tab = 4 then     -- x entregado
			if a_proceso = 1 then			 -- polizas canceladas
				if _estatus not in ('I','M') then		-- ('m')
					continue foreach;
				end if
			end if

			if a_proceso = 2 then			 -- polizas diarias
				 -- if _estatus not in ('x') then		-- ('m')
				   --	 continue foreach;
			    -- end if
				call sp_sis388(_fecha_marcar,_fecha_actual) returning _dias;
				let _cancela = _dias;
				
				if _cancela > 10 then
					continue foreach;
				end if
			end if
			
		elif a_tab = 5 then     -- x conservacion de cartera
			if _estatus not in ('E') then
				continue foreach;
			end if
			let _marcar_entrega = 0;
			
		elif a_tab = 6 then     -- x seleccionar cancelado	  sp_cob753 x-acancelar
			--let _marcar_entrega = 1;
			if _estatus  not in ('X') then
				continue foreach;
			end if

			if _ult_gestion = 1 then
				let _marcar_entrega = 0;
			end if

			let _marcar_entrega = 0;
			
		elif a_tab = 7 then     -- x seleccionar cancelado	  sp_cob753 z-canceladas y-desmarcardas
			if _estatus  not in ('Z','Y','X') then
				continue foreach;
			end if

			let _marcar_entrega = 0;
			let _desmarca = 0;

			if a_proceso = 1 then			 -- polizas canceladas
				if _estatus  not in ('Z') then
					continue foreach;
				end if
			end if
			if a_proceso = 2 then			 -- polizas desmarcadas
				if _estatus  not in ('Y') then
					continue foreach;
				end if
			end if
			
			if a_proceso = 3 then	 --  ultima gestion
				if _estatus not in ("X") Then
					continue foreach;
				end if
				
				if _user_ult_gestion is null then
					continue foreach;
				end if
			end if
			
			if a_proceso = 4 then			 --saldo de cancelacion por prorrata
				if _estatus  not in ('Z') then
					continue foreach;
			end if
				let _saldo_incobrable = _saldo - _saldo_cancelado;

				if _saldo_incobrable = 0 then
					continue foreach;
				end if
				
				let _saldo = _saldo_incobrable;
			end if
			
		elif a_tab = 8 then     -- x seleccionar cancelado	  sp_cob753 x-acancelar
			--let _marcar_entrega = 1;
			--if _estatus  not in ('y') and _estatus_poliza <> 1 and _saldo <= 0 then
			if _estatus  not in ('Y')  then
				continue foreach;
			end if
			  
			if _cod_ramo in ("004","016","018","019") then
				continue foreach;
			end if
			
			select cod_status
			  into _estatus_poliza
			  from emipoliza 
			 where trim(no_documento) = trim(_no_documento);

			if _estatus_poliza  in ('1','2')  then
				continue foreach;
			end if
		end if
		
		return	_no_documento,
				_nombre_cliente,
				_nombre_agente,
				_periodo,
				_vigencia_inic,
				_vigencia_final,
				_nombre_ramo,
				_saldo,
				_por_vencer,
				_exigible,
				_dias_30,
				_dias_60,
				_dias_90,
				_dias_120,
				_no_poliza,
				_no_aviso,
				_estatus,
				_fecha_vence,
				_user_proceso,
				_email_cli,
				_apart_cli,
				_nombre_acreedor,
				_clase,
				_marcar_entrega,
				_user_marcar,
				_fecha_marcar,
				_desmarca,
				_user_desmarca,
				_fecha_desmarca,
				_motivo_desmarca,
				_renglon,
				_ult_gestion,
				_user_ult_gestion,
				_fecha_ult_gestion,
				_estatus_poliza,
				_cancela,
				_impreso	with resume;
	end foreach
end foreach
end

drop table tmp_usuario159;
drop table tmp_a1;

end procedure 