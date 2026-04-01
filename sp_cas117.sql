-- Reporte de Polizas de Anuladas
-- Creado : 17/07/2017 - Autor: Henry Giron
-- Modificado: 17/07/2017 - Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_cas117_dw1 - DEIVID, S.A.  execute procedure sp_cas117('001','001','11/07/2017','15/07/2017')

drop procedure sp_cas117;
create procedure sp_cas117(
a_compania 		char(3),
a_agencia  		char(3),
a_fecha1 date,
a_fecha2 date)
returning   char(20)		as Poliza,
			varchar(50)		as Contratante,
			varchar(100)	as Tipo_Cliente,
			date			as Vigencia_Inicial,
			date			as Vigencia_Final,		   
			varchar(50)		as Forma_de_Pago,		   
			varchar(50)		as Grupo,
			varchar(20)		as Tipo_Poliza,	
			varchar(50)		as Ramo,
			char(10)		as Factura,
			dec(16,2)		as Prima_Bruta,
			smallint		as Dias_vencido,	
			dec(16,2)		as Saldo,
			varchar(50)		as cia,
			date			as fecha_actual,
			date			as fecha_hasta,
			char(8)			as usuario_anulo,
			varchar(50)		as corredor,
			varchar(6) 		as Cod_Producto,
			varchar(50)		as Producto,
			char(3)			as Cod_Gestion,
			varchar(50)		as Gestion,
			date			as Fecha_Gestion,
			date			as Fecha_Anula;

define _mensaje				varchar(250);
define _cliente_vip			varchar(50); 
define _nom_agente			varchar(50);
define _nombre_cli			varchar(50);
define _nom_grupo			varchar(50);
define _cia_nombre          varchar(50); 
define _nombre_formapag	    varchar(50);
define _nombre_ramo         varchar(50); 
define _no_documento		char(20);
define _desc_n_r            char(20);
define _cod_cliente			char(10);
define _no_factura          char(10);
define _no_poliza			char(10);
define _user_anulo			char(8);
define _periodo         	char(7);
define _cod_grupo			char(5);
define _cod_formapag        char(5);
define _cod_ramo            char(3); 
define _prima_bruta			dec(16,2);
define _por_vencer     		dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _exigible       		dec(16,2);
define _saldo				dec(16,2);
define _estatus_poliza		smallint;
define _holgura_nueva		smallint;
define _holgura_renov		smallint;
define _dias_nulidad		smallint;
define _dias_resta      	smallint;
define _vip					smallint;
define _cnt_holgura         integer;
define _error_isam			integer;
define _error				integer;
define _fecha_suscripcion	date;
define _fecha_primer_pago	date;
define _fecha_anulacion     date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_ult_dia		date;
define _fecha_actual		date;
define _fecha_rehab			date;
define _cnt_unidad          integer;
define _cod_producto        char(5);
define _producto            varchar(50);
define _cod_gestion   		char(3);  
define _gestion				varchar(50);
define _fecha_gestion		date;

set isolation to dirty read;
 --set debug file to "sp_cas117.trc";
 --trace on;

begin
on exception set _error,_error_isam,_mensaje	
 	return '','','',null,null,'','','','','',0.00,_error,0.00,_mensaje,null,null,'','',null,null,null,null,null,null;
end exception

let  _cia_nombre = sp_sis01('001'); 
let _fecha_actual = date(current);
let _desc_n_r = '';
let _error = 0;
 
call sp_sis39(_fecha_actual) returning _periodo;
call sp_sis36(_periodo) returning _fecha_ult_dia;

foreach
	select no_poliza,
		   no_documento,
		   no_factura,
		   fecha_emision,
		   user_added
	  into _no_poliza,
		   _no_documento,
		   _no_factura,
		   _fecha_anulacion,
		   _user_anulo
	  from endedmae
	 where cod_endomov = '002'  -- cancelacion 
	   and cod_tipocan = '037'  -- anulacion		
       and fecha_emision >= a_fecha1
	   and fecha_emision <= a_fecha2

	let _vip = 0;		
	let _cliente_vip = '';
	
	select trim(no_documento),
	       cod_ramo,
	       vigencia_inic,
		   vigencia_final,
		   estatus_poliza,
		   (case when nueva_renov = 'N' then "NUEVA" else "RENOVADA" end) desc_n_r,		   
		   fecha_primer_pago,
		   fecha_suscripcion,
		   cod_grupo,
		   prima_bruta,
		   cod_formapag,		   
		   cod_contratante
	  into _no_documento,
	       _cod_ramo,
	       _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _desc_n_r,		   		   
		   _fecha_primer_pago,
		   _fecha_suscripcion,
		   _cod_grupo,
		   _prima_bruta,
		   _cod_formapag,		   
		   _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza <> 4 then
		select max(fecha_emision)
		  into _fecha_rehab
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov = '003'
		   and actualizado = 1;

		if _fecha_rehab >= _fecha_anulacion then
			continue foreach;
		end if
	end if

	if _fecha_suscripcion > _fecha_primer_pago then
		let _dias_resta = _fecha_anulacion -_fecha_suscripcion;
	else
		let _dias_resta = _fecha_anulacion - _fecha_primer_pago;
	end if

	CALL sp_cob33(
				a_compania,
				a_agencia,
				_no_documento,
				_periodo,
				_fecha_ult_dia)
	RETURNING	_por_vencer,
				_exigible,  
				_corriente,
				_monto_30,  
				_monto_60,  
				_monto_90,
				_saldo;
				
	if _saldo is null then
		let _saldo = 0;
	end if					

	foreach
		select a.nombre
		  into _nom_agente
		  from emipoagt e, agtagent a
		 where e.cod_agente = a.cod_agente
		   and e.no_poliza = _no_poliza
		 order by porc_partic_agt
		exit foreach;
	end foreach

	select trim(nombre)
	  into _nom_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	select trim(nombre)
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;	 

	select trim(nombre)
	  into _nombre_cli
	  from cliclien
	 where cod_cliente = _cod_cliente;		  
	 
    select trim(nombre)
      into _nombre_formapag
      from cobforpa 
     where cod_formapag = _cod_formapag;
	 
	CALL sp_sis233 (_cod_cliente) returning _vip,_cliente_vip; 	
	
	select count(*)
	  into _cnt_unidad
	  from emipouni 
	 where no_poliza = _no_poliza;
	 
	if _cnt_unidad = 1 then
		select cod_producto
		  into _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza;
		 
		select nombre
		  into _producto
		  from prdprod
		 where cod_producto = _cod_producto;
	else
		let _cod_producto = null;
		let _producto     = 'Ver Detalles por Unidad';
	end if
	
	let _fecha_gestion = null;
	let _gestion = null;
	let _cod_gestion = null;
	
	foreach
		select b.cod_gestion,
			   b.nombre,
			   a.fecha_gestion
		  into _cod_gestion,
			   _gestion,
			   _fecha_gestion
		  from cobgesti a, cobcages b
		 where a.cod_gestion = b.cod_gestion
		   and b.anula = '037'
		   and a.no_poliza = _no_poliza
		--   and a.fecha_gestion <= a_fecha2
		 order by 3 desc
		
		exit foreach;
	end foreach
			
	return _no_documento,	       
		_nombre_cli,
		_cliente_vip,		   	       
		_vigencia_inic,
		_vigencia_final,		   
		_nombre_formapag,		   
		_nom_grupo,
		_desc_n_r,			   		   
		_nombre_ramo,
		_no_factura,
		_prima_bruta,
		_dias_resta,
		_saldo,
		_cia_nombre,
		a_fecha1,
		a_fecha2,
		_user_anulo,
		_nom_agente,
		trim((case when _cod_producto is null then "Varios" else _cod_producto end)),
		_producto,
		_cod_gestion,
		_gestion,
		_fecha_gestion,
		_fecha_anulacion
	with resume;	 	 
	
end foreach
--trace off;
end
end procedure;
