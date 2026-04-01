-- sp_wun06:Proceso que genera la información que se envia a Western Union
-- Creado     :	07/03/2016 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_wun06;		

create procedure "informix".sp_wun06()
returning   varchar(3),		-- 	_comp_tipo
			varchar(2),		-- 	_comp_sucu
			varchar(60),	-- 	_comp_nro
			varchar(10),	-- 	_comp_imp
			varchar(60),	-- 	_cod_barra
			char(21),		-- 	_cliente_nro
			char(160),		-- 	_cliente_nomb
			varchar(1),		-- 	_estado
			varchar(2),		-- 	_prior_gpo
			varchar(2),		-- 	_prior_nro
			varchar(8),		-- 	_vigen_fecha
			varchar(8),		-- 	_venc_fecha
			varchar(8),		-- 	venc2_fecha
			varchar(10),	-- 	_venc2_importe
			varchar(50),	-- 	_texto_fe
			varchar(120),	-- 	texto_ticket
			varchar(8),		-- 	_utility
			varchar(1),		-- 	_cobro_tipo
			varchar(6),		-- 	_cobro_terminal
			varchar(10),	-- 	cobro_cajero
			varchar(8),		-- 	_cobro_fecha
			varchar(6),		-- 	_cobro_hora
			varchar(4),		-- 	_seq_nro
			varchar(10),		-- 	_cobro_imp
			varchar(4),		-- 	_anul_seq_nro
			varchar(8),		-- 	_anul_fecha
			varchar(6),		-- 	_anul_hora
			varchar(6),		-- 	_anul_terminal
			varchar(10);	-- 	_anul_cajero

		
define _error_desc		varchar(100);
define _nom_cliente		varchar(100);
define _nom_ramo		varchar(50);
define _no_documento	varchar(20);
define _no_documento_r	char(17);
define _cod_cliente_r	char(14);
define _cod_cliente		char(10);
define _saldo_entero	char(9);
define _fecha_hoy_char	char(8);
define _vigencia_final	char(8);
define _vigencia_inic	char(8);
define _fecha_ven		char(7);
define _ent_serv		char(5);
define _ano_char		char(4);
define _cod_pais		char(3);
define _dec_part		char(2);
define _mes_char		char(2);
define _cod_estado		char(1);
define _id_serv			char(1);
define _saldo			dec(16,2);
define _no_secuencia	integer;
define _error_isam		integer;
define _error			integer;
define _fecha_hoy		date;

define _comp_tipo		varchar(3);
define _comp_sucu		varchar(2);
define _comp_nro		varchar(60);
define _comp_imp		varchar(10);  -- int
define _cod_barra		varchar(60);
define _cliente_nro		char(21);
define _cliente_nomb	char(160);
define _estado			varchar(1); 
define _prior_gpo		varchar(2);
define _prior_nro		varchar(2);
define _vigen_fecha		varchar(8);
define _venc_fecha		varchar(8);
define venc2_fecha		varchar(8);
define _venc2_importe	varchar(10);  -- int
define _texto_fe		varchar(50); 
define texto_ticket		varchar(120); 
define _utility			varchar(8);
define _cobro_tipo		varchar(1);
define _cobro_terminal	varchar(6);
define cobro_cajero		varchar(10);
define _cobro_fecha		varchar(8);
define _cobro_hora		varchar(6);
define _seq_nro			varchar(4);
define _cobro_imp		varchar(10);  -- int
define _anul_seq_nro	varchar(4);
define _anul_fecha		varchar(8);
define _anul_hora		varchar(6); 
define _anul_terminal	varchar(6); 
define _anul_cajero		varchar(10);
define _cadena			varchar(255);

let _cadena = '3,2,60,10,60,21,160,1,2,2,8,8,8,10,50,120,8,1,6,10,8,6,4,10,4,8,6,6,10';
let	_cobro_terminal = '';
let	_venc2_importe = '';
let	_anul_terminal = '';
let	_cliente_nomb = '';
let	_anul_seq_nro = '';
let	_cliente_nro = '';
let	_vigen_fecha = '';
let	texto_ticket = '';
let	cobro_cajero = '';
let	_cobro_fecha = '';
let	_anul_cajero = '';
let	_venc_fecha = '';
let	venc2_fecha = '';
let	_cobro_hora = '';
let	_cobro_tipo = '';
let	_anul_fecha = '';
let	_cod_barra = '';
let	_comp_tipo = '';
let	_comp_sucu = '';
let	_prior_gpo = '';
let	_prior_nro = '';
let	_cobro_imp = '';
let	_anul_hora = '';
let	_comp_nro = '';
let	_comp_imp = '';
let	_texto_fe = '';
let	_utility = '';
let	_seq_nro = '';
let	_estado = '';

set isolation to dirty read;

--set debug file to "sp_wun06.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	return '',
	"0.00",
	'',
	'',
	_error_desc,
	'',
	'',
	'',
	'',
	'',
	cast(_error as varchar(10)),  
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'';
end exception

--Buscar la fecha del servidor
let _fecha_hoy = sp_sis40();

--Formato de fecha yyyymmdd
let _fecha_hoy_char = to_char(_fecha_hoy,"%Y%m%d");


let _ent_serv = '20034';
let _cod_pais = '745';

--Extraer los 2 últimos valores del año
let _ano_char = substr(year(_fecha_hoy),-2);

--Formato del mes con 2 caracteres
let _mes_char = lpad(month(_fecha_hoy),2,'0');

let _fecha_ven = trim(_ano_char) || '365';
let _id_serv  = '1';
let _utility = '74520034';

foreach
	select no_documento,
		   cod_cliente,
		   nom_cliente,
		   saldo,
		   ramo,
		   cod_estado,
		   no_secuencia
	  into _no_documento,
		   _cod_cliente,
		   _nom_cliente,
		   _saldo,
		   _nom_ramo,
		   _cod_estado,
		   _no_secuencia
	  from deivid_cob:wun_saldos

	--Formato solo con la parte entera del saldo  y rellenando con 0 a la izq. hasta completar 9 caracteres.
	let _saldo_entero = lpad(cast(trunc(_saldo,0) as varchar(9)),9,'0');

	--Eliminar el punto decimal del saldo.
	let _saldo = _saldo * 100;

	--Extraer la parte decimal del saldo.
	let _dec_part = substr(_saldo,-2);

	--Formato de cod_cliente rellenando con 0 a la izq. hasta comple
	let _cod_cliente_r = lpad(trim(_cod_cliente),14,'0');

	--Formato de no_documento rellenando con 0 a la izq. hasta completar 17 caracteres
	let _no_documento_r = lpad(trim(_no_documento),17,'0');
	
	let _cod_barra = _cod_pais || _ent_serv || _id_serv || _cod_cliente_r || trim(_ano_char) || _mes_char || _saldo_entero || _dec_part || trim(_fecha_ven) || _no_documento_r;	

	-- colocar en estructura
	let	_comp_tipo	    = rpad(trim(_comp_tipo),3,' ');
	let	_comp_sucu	    = rpad(trim(_comp_sucu),2,' ');
	let	_comp_nro	    = rpad(trim(_no_documento),60,' ');
	let	_comp_imp	    = lpad(cast(trunc(_saldo,0) as varchar(10)),10,'0');
	let	_cod_barra	    = rpad(trim(_cod_barra),60,' ');
	let	_cliente_nro	= rpad(trim(_cod_cliente),22,' ');
	let	_cliente_nomb	= rpad(trim(_nom_cliente),160,' ');
	let	_estado	        = rpad(trim(_cod_estado),1,'0');
	let	_prior_gpo	    = rpad(trim(_prior_gpo),2,' ');
	let	_prior_nro	    = rpad(trim(_prior_nro),2,' ');
	let	_vigen_fecha	= rpad(trim(_fecha_hoy_char),8,'0');
	let	_venc_fecha	    = rpad(trim(_fecha_hoy_char),8,'0');
	let	venc2_fecha	    = rpad(trim(venc2_fecha),8,' ');
	let	_venc2_importe	= lpad(cast(trunc(_venc2_importe,0) as varchar(10)),10,'0');	
	let	_texto_fe	    = rpad(trim(_nom_ramo),50,' ');
	let	texto_ticket	= rpad(trim(texto_ticket),120,' ');
	let	_utility	    = rpad(trim(_utility),8,' ');   
	let	_cobro_tipo	    = rpad(trim(_cobro_tipo),1,' ');
	let	_cobro_terminal	= rpad(trim(_cobro_terminal),6,' ');
	let	cobro_cajero	= rpad(trim(cobro_cajero),10,' ');
	let	_cobro_fecha	= rpad(trim(_cobro_fecha),8,' ');
	let	_cobro_hora	    = rpad(trim(_cobro_hora),6,' ');
	let	_seq_nro	    = lpad(trim(cast(_no_secuencia as varchar(4))),4,'0');  
	let	_cobro_imp	    = lpad(cast(trunc(_cobro_imp,0) as varchar(10)),10,'0');	
	let	_anul_seq_nro	= rpad(trim(_anul_seq_nro),4,' ');
	let	_anul_fecha	    = rpad(trim(_anul_fecha),8,' ');
	let	_anul_hora	    = rpad(trim(_anul_hora),6,' ');
	let	_anul_terminal	= rpad(trim(_anul_terminal),6,' ');
	let	_anul_cajero	= rpad(trim(_anul_cajero),10,' ');

	return	_comp_tipo,
			_comp_sucu,
			_comp_nro,
			_comp_imp,
			_cod_barra,
			_cliente_nro,
			_cliente_nomb,
			_estado,
			_prior_gpo,
			_prior_nro,
			_vigen_fecha,
			_venc_fecha,
			venc2_fecha,
			_venc2_importe,
			_texto_fe,
			texto_ticket,
			_utility,
			_cobro_tipo,
			_cobro_terminal,
			cobro_cajero,
			_cobro_fecha,
			_cobro_hora,
			_seq_nro,
			_cobro_imp,
			_anul_seq_nro,
			_anul_fecha,
			_anul_hora,
			_anul_terminal,
			_anul_cajero with resume;		
end foreach
end
end procedure;