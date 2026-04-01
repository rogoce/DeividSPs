-- Reporte de Aviso de Cancelacion - Marcados como entregados
-- Creado    : 31/07/2000 - Autor: Henry Giron
-- SIS v.2.0 - d_cobr_sp_cob748_dw4f - DEIVID, S.A.  -- x corredor

drop procedure sp_cob748f;
create procedure "informix".sp_cob748f(
a_compania		char(3),
a_cobrador		char(3)		default '*',
a_tipo_aviso	smallint,
a_agente		char(5)		default '*',
a_acreedor		char(5)		default '*',
a_asegurado		char(10)	default '*',
a_callcenter	smallint 	default 0,
a_referencia	char(15),
a_clase			smallint,
a_tab			smallint,
a_fecha1		date,
a_fecha2		date)
returning	char(15),	-- no_aviso
			char(20),	-- no_documento
			char(10),	-- no_poliza
			char(7),	-- periodo
			date,		-- vigencia_inic
			date,		-- vigencia_final
			char(3),	-- cod_ramo
			char(50),	-- nombre_ramo
			char(50),	-- nombre_subramo
			char(10),	-- cedula
			char(100),	-- nombre_cliente
			dec(16,2),	-- saldo
			dec(16,2),	-- por_vencer
			dec(16,2),	-- exigible
			dec(16,2),	-- corriente
			dec(16,2),	-- dias_30
			dec(16,2),	-- dias_60
			dec(16,2),	-- dias_90
			dec(16,2),	-- dias_120
			dec(16,2),	-- dias_150
			dec(16,2),	-- dias_180
			char(5),	-- cod_acreedor
			char(50),	-- nombre_acreedor
			char(5),	-- cod_agente
			char(50),	-- nombre_agente
			dec(16,2),	-- porcentaje
			char(10),	-- telefono
			char(3),	-- cod_cobrador
			char(3),	-- cod_vendedor
			char(20),	-- apartado
			char(10),	-- fax_cli
			char(10),	-- tel1_cli
			char(10),	-- tel2_cli
			char(20),	-- apart_cli
			char(50),	-- email_cli
			date,		-- fecha_proc
			char(3),	-- cod_forma_pago
			char(50),	-- forma_pago
			char(1),	-- cobra_poliza
			char(50),	-- compania_nombre
			char(50),	-- cobrador
			char(50),	-- clase
			char(1),	-- estatus_poliza
			char(10),	-- no_factura
			date,		-- fecha transaccion  
			char(60);		-- motivo  

define _nombre_cliente 	    char(100);
define _nombre_acreedor 	char(50);
define _nombre_formapag 	char(50);
define _compania_nombre 	char(50);
define _nombre_cobrador 	char(50);
define _nombre_subramo 	    char(50);
define _nombre_agente 		char(50);
define _descripcion		    char(50);
define _nombre_ramo 		char(50);
define _email_cli 			char(50);
define n_clase 				char(50);
define _no_documento 		char(20);
define _apart_cli 			char(20);
define _apartado 			char(20);
define _user_cancela        char(15);
define _user_filtro         char(15);
define _no_aviso 			char(15);
define _no_factura      	char(10);
define _no_poliza 			char(10);
define _tel2_cli 			char(10);
define _tel1_cli 			char(10);
define _telefono 			char(10);
define _fax_cli 			char(10);
define _cedula 				char(10);
define _periodo 			char(7);
define _cod_acreedor 		char(5);
define _cod_agente 			char(5);
define _cod_cobrador 		char(3);
define _cod_vendedor 		char(3);
define _cod_formapag    	char(3);
define _cod_ramo 			char(3);
define _estatus_poliza		char(1);
define _status_filtro       char(1);
define _cobra_poliza	 	char(1);
define _status				char(1);
define _clase				char(1);
define _saldo_cancelado     dec(16,2);
define _por_vencer 			dec(16,2);
define _porcentaje 			dec(16,2);
define _corriente 			dec(16,2);
define _exigible 			dec(16,2);
define _dias_180 			dec(16,2);
define _dias_120 			dec(16,2);
define _dias_150 			dec(16,2);
define _dias_90 			dec(16,2);
define _dias_60 			dec(16,2);
define _dias_30 			dec(16,2);
define _saldo 				dec(16,2);
define _ult_gestion         smallint;
define _desmarca            smallint;
define _error               smallint;
define _vigencia_final 	    date;
define _vigencia_inic 		date;
define _fecha_cancela       date;
define _fecha_proc 			date;
define _fecha				date;
define _cod_no_renov	    char(3);
define _no_renov  	 	    char(50);
define _motivo  	 	    char(60);

set isolation to dirty read;

let _saldo_cancelado = 0;
let _desmarca = 0;
let n_clase = '';
let _status = '';
let _clase = '';

if a_agente = '%' then
	let a_agente = '*';
end if

if a_acreedor = '%' then
	let a_acreedor = '*';
end if

if a_asegurado = '%'	then
	let a_asegurado = '*';
end if

if a_cobrador = '%' then
	let a_cobrador = '*';
end if

-- nombre de la compania
let  _compania_nombre = sp_sis01(a_compania);

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
elif a_tab = 6 then -- tab status A cancelar 
	let _status_filtro = 'X';
	let _clase = '*';
	let n_clase = "Polizas Canceladas";
elif a_tab = 7 then -- tab status Resultado
	let _clase = '*';

	if a_clase = 1 then
		let _status_filtro = 'Z';
		-- let n_clase = "Polizas Canceladas";
		let n_clase = "Polizas Canceladas y Cese de Vigencia";
	elif a_clase = 2 then
		let _status_filtro = 'Y';
		let n_clase = "Polizas Desmarcadas";
	elif a_clase = 3 then
		let _status_filtro = 'Y';
		let n_clase = "Polizas en Ultima Gestion";
	elif a_clase = 4 then
		let _status_filtro = 'Z';
		let n_clase = "Polizas Canceladas con Prima Devengada";
	elif a_clase = 5 then
		let _status_filtro = 'M';
		let n_clase = "Polizas Entregadas";  
	end if

	foreach
		select distinct usuario2
		   into _user_filtro
		  from avisocanc
		 where no_aviso   = a_referencia
		exit foreach;
	end foreach
end if

foreach
	select no_aviso,
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
		   desmarca,
		   fecha_cancela
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
		   _desmarca,
		   _fecha_cancela
	  from avisocanc
	 where cod_agente matches a_agente
	   and cod_acreedor matches a_acreedor
	   and cedula matches a_asegurado
	   and cod_cobrador matches a_cobrador
	   and clase matches _clase
	 order by no_aviso,fecha_cancela,periodo, nombre_agente, nombre_cliente, no_documento
	 
--	 and estatus = _status   -- marcado de entregado
--	 AND no_aviso   = a_referencia
--	 AND user_cancela   = _user_cancela

	let _fecha = _fecha_proc;

	if a_tab in (4,6) then -- tab status marcado
		if _status not in (_status_filtro) then
			continue foreach;
		end if
	elif a_tab = 7 then -- tab status Resultado
		if _status not in (_status_filtro) then  --armando 02/02/2015
			continue foreach;
		end if
		if a_clase = 1 then
			{if _user_filtro <> _user_cancela then   armando  02/02/2015
				continue foreach;
			end if}
			if _no_aviso not in (a_referencia) then
--				continue foreach;
			end if
			if _fecha_cancela >= a_fecha1 and _fecha_cancela <= a_fecha2 then
			   let _fecha = _fecha_cancela;
			else
			   continue foreach;
			end if
		elif a_clase = 2 then
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
				-- continue foreach;   -- investigar porque no se esta realizando
			end if			
			if _fecha_proc >= a_fecha1 and _fecha_proc <= a_fecha2 then
			   let _fecha = _fecha_proc;
			else
			   continue foreach;
			end if			
		elif a_clase = 3 then
			if _user_filtro <> _user_cancela then
--				continue foreach;
			end if
			if _ult_gestion <> 1 then
				continue foreach;
			end if
		elif a_clase = 4 then
			if _user_filtro <> _user_cancela then
				continue foreach;
			end if
			if _saldo_cancelado <= 0 then
				continue foreach;
			end if
		elif a_clase = 5 then
			if _user_filtro <> _user_cancela then
				continue foreach;
			end if
			if _saldo_cancelado <= 0 then
				continue foreach;
			end if
		end if
	end if
	
	-- LET _no_poliza = sp_sis21(_no_documento); --trae ult. vigencia de la poliza.

	 select cod_no_renov
	   into	_cod_no_renov
	   from	emipomae
	  where	no_poliza = _no_poliza;	
	  
	let _motivo = '';
	let _no_renov = '';
	
	if _cod_no_renov = '039' then	
		select trim(nombre)
		  into _no_renov
		  from eminoren
		 where cod_no_renov = _cod_no_renov;	
		 
		 let _motivo = trim(_no_renov)||'-'||trim(_cod_no_renov);
   end if
	-- Cobrador
	select nombre
      into _nombre_cobrador
      from cobcobra
	 where cod_cobrador = _cod_cobrador;

	return _no_aviso,   		-- no_aviso
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
		   _no_factura,			-- factura
		   _fecha,				-- fecha transaccion
		   _motivo              -- motivo
		   with resume;
end foreach
end procedure;