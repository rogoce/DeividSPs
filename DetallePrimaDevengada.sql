-- Procedimiento que Carga las tablas para el Analisis de Cuentas 
-- Creado: 20/10/2022 - Autor: Román Gordón
-- execute procedure DetallePrimaDevengada('2024-01','2024-03')

drop procedure DetallePrimaDevengada;
create procedure "informix".DetallePrimaDevengada(a_periodo_desde char(7),a_periodo_hasta char(7))
returning	integer 		as error,
			integer 		as error_d,
			varchar(100)	as mensaje;

  
define _error_desc 			varchar(100);      
define _canal		 			varchar(50);       
define _nom_subramo			varchar(50);        
define _nombre_grupo			varchar(50);        
define _res_descripcion		varchar(50);        
define _zona_ventas			varchar(50);        
define _desc_desc				varchar(50);        
define _cta_nombre			varchar(50);        
define _nom_corredor			varchar(50);
define _categoria_contable	varchar(50);
define _segm_triangulo		varchar(50);
define _desc_clasif			varchar(50);        
define _res_cuenta			varchar(30);        
define _nom_ramo				varchar(50);        
define _ramo					varchar(50);        
define _tipo_auto				varchar(30);        
define _no_motor				varchar(30);  
define _prima_suscrita   		dec(16,2);
define _res_credito      		dec(16,2);
define _prima_bruta      		dec(16,2);
define _prima_neta      		dec(16,2);
define _res_debito      		dec(16,2);
define _impuesto      		dec(16,2);
define _saldo_mov      		dec(16,2);
define _db_mov		      		dec(16,2);
define _cr_mov		      		dec(16,2);
define _no_documento			char(20);           
define _cod_contratante		char(10);           
define _no_poliza_n 			char(10);           
define _no_factura 			char(10);           
define _no_poliza 			char(10);           
define _res_comprobante		char(10);           
define _user_added 			char(8);            
define _cod_producto			char(5);            
define _cod_grupo				char(5);            
define _no_endoso				varchar(10);            
define _cod_modelo			char(5);            
define _cod_agente 			char(5);            
define _grupo_mdl 			char(5);            
define _no_unidad 			char(5);            
define _cod_sucursal 			char(3);            
define _cod_vendedor 			char(3);            
define _cod_subramo	 		char(3);            
define _res_origen 			char(3);            
define _res_mayor 			char(3);            
define _res_ccosto	 		char(3);            
define _cod_ramo		 		char(3);            
define _tipo_persona	 		char(1);
define _tipo_agente	 		char(1);
define _nueva_renov	 		char(1);
define _indiv_col		 		varchar(15);
define _sexo				 	char(1);
define _vigencia_inic_endoso	date;           
define _vigencia_final		date;           
define _vigencia_inic			date;           
define _res_fechatrx			date;           
define _fecha_desde			date;           
define _fecha_hasta			date;           
define _primer_anio			date;           
define _fecha_hoy				date;           
define _res_notrx				integer;           
define _error_isam			smallint;           
define _error					smallint;


--set debug file to "DetalleContable.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc

	if _no_poliza is null then
		let _no_poliza = '';
	end if
	
	if _no_documento is null then
		let _no_documento = '';
	end if	
	
	if _res_notrx is null then
		let _res_notrx = 0;
	end if
	
	return	_error,
			_error_isam,
			_error_desc || ' ' ||_no_documento||' ' ||_no_poliza || ' - ' || _res_notrx;
end exception

drop table if exists tmp_mov_cuentas;
create temp table tmp_mov_cuentas(
	res_origen					char(3),
	res_comprobante			varchar(50),
	res_notrx					integer,
	res_fechatrx				date,
	res_descripcion			varchar(50),
	res_ccosto					char(3),
	res_mayor					char(3),
	res_cuenta					varchar(20),
	cta_nombre					varchar(50),
	res_debito					dec(16,2),	
	res_credito				dec(16,2),
	CodRamo					char(3),
	Ramo						varchar(50),
	CodSubramo					char(3),
	Subramo					varchar(50),
	no_poliza					char(10),
	Poliza						varchar(20),
	cod_sucursal				char(3),
	indiv_colectivo			varchar(15),
	Canal						varchar(50),
	CodZona					char(5),
	ZonaVentas					varchar(50),
	CodGrupo					char(5),
	Grupo						varchar(50),
	CodCorredor				char(5),
	Corredor					varchar(50),
	tipo_persona				char(1),
	sexo						char(1),
	VigenciaInic				date,
	VigenciaFinal				date,
	VigenciaInicialEndoso		date,
	NuevaRenov					char(1),
	NroEndoso					varchar(10),
	Factura					char(15),
	categoria_contable		varchar(50),
	segm_triangulo			varchar(50),
	tipo_clasificacion		varchar(50),
	db							dec(16,2),	
	cr							dec(16,2),	
	saldo						dec(16,2)
	--,primary key(res_notrx,res_cuenta,res_ccosto,CodCorredor,no_poliza,NroEndoso)
	) with no log;

let _no_documento = '';
let _no_poliza = '';
let _res_notrx = 0;
let _fecha_hoy = sp_sis26();
let _fecha_desde = mdy(a_periodo_desde[6,7],1,a_periodo_desde[1,4]);
let _fecha_hasta = sp_sis36(a_periodo_hasta);

foreach
	select res_origen,
			res_comprobante,
			res_notrx,
			res_fechatrx,
			res_descripcion,
			res.res_ccosto,
			res_cuenta,
			cta_nombre,
			sum(res_debito),
			sum(res_credito)
	  into _res_origen,
			_res_comprobante,
			_res_notrx,
			_res_fechatrx,
			_res_descripcion,
			_res_ccosto,
			_res_cuenta,
			_cta_nombre,
			_res_debito,
			_res_credito
	  from cglresumen res
     inner join cglcuentas on cta_cuenta = res_cuenta
	 where date(res_fechatrx) between _fecha_desde and _fecha_hasta
	   and (cta_cuenta like '55102%' or cta_cuenta like '55101%' or cta_cuenta like '55105%' or cta_cuenta like '55201%' or cta_cuenta like '411%' or cta_cuenta like '511%' or cta_cuenta like  '55103%')
	   and res_tipcomp <> '021'
	 group by 1,2,3,4,5,6,7,8
	 order by res_origen,res_fechatrx
	--and res_origen = 'PRO'

	let _res_mayor = _res_cuenta[1,3];

	if _res_origen = 'PRO' then
		foreach
			select emi.cod_ramo,
				    ram.nombre,
					emi.cod_subramo,
					sub.nombre,
					mae.no_poliza,
					mae.no_documento,
					mae.no_endoso,
					mae.no_factura,
					asi.debito,
					asi.credito		
			  into _cod_ramo,
				   _nom_ramo,
				   _cod_subramo,
				   _nom_subramo,
				   _no_poliza,
				   _no_documento,
				   _no_endoso,
				   _no_factura,
				   _db_mov,
				   _cr_mov			  
			  from endasien asi
			 inner join endedmae mae on mae.no_poliza = asi.no_poliza and mae.no_endoso = asi.no_endoso
			 inner join emipomae emi on emi.no_poliza = mae.no_poliza
			 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
			 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
			 where asi.sac_notrx = _res_notrx 
			   and asi.cuenta = _res_cuenta
			   and asi.centro_costo = _res_ccosto
			   and (asi. debito - asi.credito) <> 0
		
			let _saldo_mov = _db_mov - abs(_cr_mov);
			
			call sp_niif13(_no_poliza,'','',1)
			returning _error,_error_isam,_error_desc,_desc_clasif,_categoria_contable,_segm_triangulo;
			
			let _res_mayor = _res_cuenta[1,3];

			insert into tmp_mov_cuentas
			(
				res_origen,				
				res_comprobante,		    
				res_notrx,				    
				res_fechatrx,			    
				res_descripcion,		    
				res_mayor,                 
				res_ccosto,                
				res_cuenta,                
				cta_nombre,				
				res_debito,			    
				res_credito,			    
				CodRamo,				    
				Ramo,					    
				CodSubramo,				
				Subramo,				    
				no_poliza,                 
				Poliza,
				NroEndoso,				    
				Factura,
				categoria_contable,
				segm_triangulo,
				tipo_clasificacion,			
				db,						    
				cr,						    
				saldo)
			values(
				_res_origen,
				_res_comprobante,
				_res_notrx,
				_res_fechatrx,
				_res_descripcion,
				_res_mayor,
				_res_ccosto,
				_res_cuenta,
				_cta_nombre,
				_res_debito,
				_res_credito,	
				_cod_ramo,
				_nom_ramo,
				_cod_subramo,
				_nom_subramo,
				_no_poliza,
				_no_documento,
				_no_endoso,
				_no_factura,
				_categoria_contable,
				_segm_triangulo,
				_desc_clasif,
				_db_mov,
				_cr_mov,
				_saldo_mov);
		end foreach
	elif _res_origen = 'REA' then
	
		foreach
			select emi.cod_ramo,
				   ram.nombre,
				   emi.cod_subramo,
				   sub.nombre,
				   mae.no_poliza,
				   mae.no_documento,
				   mae.no_endoso,
				   mae.no_factura,
				   res.debito,
				   res.credito		
			  into _cod_ramo,
				   _nom_ramo,
				   _cod_subramo,
				   _nom_subramo,
				   _no_poliza,
				   _no_documento,
				   _no_endoso,
				   _no_factura,
				   _db_mov,
				   _cr_mov	
			  from cglcuentas cta
			 inner join sac999:reacompasie res on res.cuenta = cta_cuenta
			 inner join sac999:reacomp det on det.no_registro = res.no_registro
			 inner join endedmae mae on mae.no_poliza = det.no_poliza and mae.no_endoso = det.no_endoso
			 inner join emipomae emi on emi.no_poliza = mae.no_poliza				 
			 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
			 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
			 where res.sac_notrx = _res_notrx 
			   and res.cuenta = _res_cuenta
			   and res.centro_costo = _res_ccosto
			   and (res.debito - res.credito) <> 0			   
			-- group by cta_cuenta,cta_nombre,ram.nombre,sub.nombre 
			   
			call sp_niif13(_no_poliza,'','',1)
			returning _error,_error_isam,_error_desc,_desc_clasif,_categoria_contable,_segm_triangulo;
			
			/*if _tipo_registro = 1 then -- Factura
				select emi.cod_ramo,
						ram.nombre,
						emi.cod_subramo,
						sub.nombre,
						mae.no_documento,
						mae.no_endoso,
						mae.no_factura,
						asi.debito * (agt.porc_partic_agt/100),
						asi.credito * (agt.porc_partic_agt/100)		
				  into _cod_ramo,
						_nom_ramo,
						_cod_subramo,
						_nom_subramo,
						_cod_vendedor,
						_zona_ventas,
						_cod_agente,
						_nom_corredor,
						_sexo,
						_tipo_persona,
						_tipo_agente,
						_cod_grupo,
						_nombre_grupo,
						_no_documento,
						_cod_sucursal,
						_vigencia_inic,
						_vigencia_final,
						_vigencia_inic_endoso,
						_nueva_renov,
						_no_endoso,
						_no_factura,
						_db_mov,
						_cr_mov			  
				  from sac999:reacomp asi
				 inner join endedmae mae on mae.no_poliza = asi.no_poliza and mae.no_endoso = asi.no_endoso
				 inner join emipomae emi on emi.no_poliza = mae.no_poliza
				 inner join cligrupo grp on grp.cod_grupo = emi.cod_grupo
				 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
				 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
				 inner join endmoage agt on agt.no_poliza = mae.no_poliza and agt.no_endoso = mae.no_endoso
				 inner join agtagent cor on cor.cod_agente = agt.cod_agente
				 inner join agtvende zon on zon.cod_vendedor = cor.cod_vendedor			 
				 where asi.sac_notrx = _res_notrx 
				   and asi.cuenta = _res_cuenta
				   and asi.centro_costo = _res_ccosto
			elif _tipo_registro = 2 then -- Cobros
			elif _tipo_registro = 3 then --Reclamos
			elif _tipo_registro in (4,5) then --Cheques
			end if			
			*/
			let _saldo_mov = _db_mov - abs(_cr_mov);
			
			let _res_mayor = _res_cuenta[1,3];

			insert into tmp_mov_cuentas
			(
				res_origen,				
				res_comprobante,		    
				res_notrx,				    
				res_fechatrx,			    
				res_descripcion,		    
				res_mayor,                 
				res_ccosto,                
				res_cuenta,                
				cta_nombre,				
				res_debito,			    
				res_credito,			    
				CodRamo,				    
				Ramo,					    
				CodSubramo,				
				Subramo,				    
				no_poliza,                 
				Poliza,
				NroEndoso,				    
				Factura,
				categoria_contable,
				segm_triangulo,
				tipo_clasificacion,				
				db,						    
				cr,						    
				saldo)
			values(
				_res_origen,
				_res_comprobante,
				_res_notrx,
				_res_fechatrx,
				_res_descripcion,
				_res_mayor,
				_res_ccosto,
				_res_cuenta,
				_cta_nombre,
				_res_debito,
				_res_credito,	
				_cod_ramo,
				_nom_ramo,
				_cod_subramo,
				_nom_subramo,
				_no_poliza,
				_no_documento,
				_no_endoso,
				_no_factura,
				_categoria_contable,
				_segm_triangulo,
				_desc_clasif,
				_db_mov,
				_cr_mov,
				_saldo_mov);
		end foreach
		
	else --CGL
		insert into tmp_mov_cuentas
			(
				res_origen,				
				res_comprobante,		    
				res_notrx,				    
				res_fechatrx,			    
				res_descripcion,		    
				res_mayor,                 
				res_ccosto,                
				res_cuenta,                
				cta_nombre,				
				res_debito,			    
				res_credito,			    
				CodRamo,				    
				Ramo,					    
				CodSubramo,				
				Subramo,				    
				no_poliza,                 
				Poliza,					
				cod_sucursal,              
				indiv_colectivo,
				Canal,
				CodZona,				    
				ZonaVentas,			    
				CodGrupo,                  
				Grupo,					    
				CodCorredor,			    
				Corredor,				    
				sexo,                       
				tipo_persona,              
				VigenciaInic,			    
				VigenciaFinal,			    
				VigenciaInicialEndoso,	
				NuevaRenov,			    
				NroEndoso,				    
				Factura,		    
				db,						    
				cr,						    
				.)
			values(
				_res_origen,
				_res_comprobante,
				_res_notrx,
				_res_fechatrx,
				_res_descripcion,
				_res_mayor,
				_res_ccosto,
				_res_cuenta,
				_cta_nombre,
				_res_debito,
				_res_credito,	
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
				'01/01/1900',
				'01/01/1900',
				'01/01/1900',
				'',
				'',
				'',
				_res_debito,
				_res_credito,
				_res_debito - abs(_res_credito));
	end if
end foreach
end
return 0, 0 , "Completado;
end procedure;