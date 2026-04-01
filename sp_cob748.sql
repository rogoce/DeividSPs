-- Reporte de Aviso de Cancelacion
-- Creado    : 31/07/2000 - Autor: Henry Giron
-- SIS v.2.0 - d_cobr_sp_cob748c_dw1 - DEIVID, S.A.  -- x corredor
-- SIS v.2.0 - d_cobr_sp_cob748h_dw1 - DEIVID, S.A.	 -- x acreedor

drop procedure sp_cob748;
create procedure "informix".sp_cob748(
a_compania		char(3),
a_cobrador		char(3)		default '*',
a_tipo_aviso	smallint,
a_agente		char(5)		default '*',
a_acreedor		char(5)		default '*',
a_asegurado		char(10)	default '*',
a_callcenter	smallint	default 0,
a_referencia	char(15))
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
			char(5), 	-- cod_acreedor 	
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
			char(1),	-- estatus
			char(10);	-- no_factura

define _nombre_cliente	char(100);
define _compania_nombre	char(50);
define _nombre_cobrador	char(50);
define _nombre_acreedor	char(50); 
define _nombre_formapag	char(50);
define _nombre_subramo	char(50);
define _nombre_agente	char(50); 
define _nombre_ramo		char(50);
define _email_cli		char(50);
define _no_documento	char(20);
define _apart_cli		char(20); 
define _apartado		char(20); 
define _no_aviso		char(15);
define _no_factura		char(10);
define _no_poliza		char(10);
define _telefono		char(10); 
define _fax_cli			char(10); 
define _tel1_cli		char(10); 
define _tel2_cli		char(10); 
define _cedula			char(10);
define _periodo_c		char(7);
define _periodo			char(7); 
define _cod_acreedor	char(10);  --char(5); 11/03/2019 HG
define _cod_agente		char(5); 
define _ano_char		char(4);
define _cod_cobrador	char(3); 
define _cod_vendedor	char(3); 
define _cod_formapag	char(3);
define _cod_ramo		char(3); 
define _mes_char		char(2);
define _estatus_poliza	char(1);
define _cobra_poliza	char(1);
define _por_vencer_c	dec(16,2);
define _corriente_c		dec(16,2);
define _exigible_c		dec(16,2);
define _porcentaje		dec(16,2); 
define _por_vencer		dec(16,2); 
define _dias_180_c		dec(16,2);
define _dias_150_c		dec(16,2);
define _dias_120_c		dec(16,2);
define _dias_90_c		dec(16,2);
define _dias_60_c		dec(16,2);
define _dias_30_c		dec(16,2);
define _corriente		dec(16,2); 
define _exigible		dec(16,2); 
define _dias_180		dec(16,2); 
define _dias_150		dec(16,2); 
define _dias_120		dec(16,2); 
define _dias_90			dec(16,2); 
define _dias_60			dec(16,2); 
define _dias_30			dec(16,2); 
define _saldo_c			dec(16,2);
define _saldo			dec(16,2); 
define _vigencia_final	date; 
define _vigencia_inic	date; 
define _fecha_actual	date;
define _fecha_proc		date;

set isolation to dirty read;

if a_agente = '%'	then
	let a_agente = '*';
end if
if a_acreedor = '%'	then
	let a_acreedor = '*';
end if
if a_asegurado = '%'	then
	let a_asegurado = '*';
end if
if a_cobrador = '%'	then
	let a_cobrador = '*';
end if

-- nombre de la compania
let  _compania_nombre = sp_sis01(a_compania); 

if a_callcenter = 0 then
	let _cobra_poliza = "C";
else
	let _cobra_poliza = "E";
end if
--
let _fecha_actual = today;
let _periodo_c	    = ' ';

if month(_fecha_actual) < 10 then
	let _mes_char = '0'|| month(_fecha_actual);
else
	let _mes_char = month(_fecha_actual);
end if

let _ano_char = year(_fecha_actual);
let _periodo_c  = _ano_char || "-" || _mes_char;


-- reporte de las cartas a imprimir
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
		   no_factura          
	  into _no_aviso,   
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
		   _no_factura          
	  from avisocanc  
	 where no_aviso     = a_referencia
	   and cod_agente   matches a_agente
	   and cod_acreedor matches a_acreedor
	   and cedula		matches a_asegurado
	   and cod_cobrador matches a_cobrador
	   and estatus <> 'y'
--	 and desmarca = 1 
	 order by periodo, nombre_agente, nombre_cliente, no_documento	          

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
		   _estatus_poliza,     -- estatus poliza
		   _no_factura
		   with resume;	 		
end foreach
end procedure;