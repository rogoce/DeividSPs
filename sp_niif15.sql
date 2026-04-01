-- Procedure de Generación del detalle de Comprobantes Contables para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif15('2021-01','2021-12')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif15;
create procedure sp_niif15(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	char(3)				as res_origen,						
            date				as res_fechatrx,     
            varchar(30)			as cuenta,
			varchar(30)			as nom_cuenta,
			dec(16,2)			as debito,           
			dec(16,2)			as credito,
			char(3)				as cod_ramo,
			varchar(30)			as nom_ramo,
			char(3)				as cod_subramo,
			varchar(30)			as nom_subramo,    
            char(5)				as cod_grupo,
			varchar(30)			as nom_grupo,          
            char(20)			as no_documento,
			date				as vigencia_inic,    
			date				as vigencia_final,
			char(20)			as nueva_renov,      
			varchar(30)			as numrecla,          
			char(10)			as transaccion,      
			date				as fecha_trx,
			date				as fecha_reclamo,
			date				as fecha_siniestro,
			date				as fecha_pagado,
			dec(16,2)			as mto_mov,
			dec(16,2)			as pagado_neto,
			dec(16,2)			as pagado_cedido,
			dec(16,2)			as reserva,
			dec(16,2)			as reserva_ret,
			dec(16,2)			as reserva_cedida,
			char(10)			as no_reclamo,      
			char(10)			as no_poliza,      
			char(10)			as no_tranrec,      
			char(10)			as anular_nt,      
			char(3)				as cod_tipotran,
			varchar(30)			as tipotran,          
			varchar(50)			as desc_clasif,          
			varchar(50)			as categoria_contable,          
			varchar(40)			as segm_triangulo;

define _error_desc			char(50);
define _estatus_recl		varchar(20);
define _desc_clasif			varchar(50);
define _categoria_contable	varchar(50);
define _segm_triangulo		varchar(50);
define _nom_subramo			varchar(50);
define _nom_cuenta			varchar(50);
define _nom_grupo			varchar(50);
define _nom_ramo			varchar(50);
define _tipotran			varchar(50);
define _filtros				varchar(50);
define _cuenta				varchar(30);
define _no_documento		char(20);
define _numrecla			char(18);
define _no_requis			char(10);
define _transaccion			char(10);
define _anular_nt			char(10);
define _no_reclamo2			char(10);
define _nueva_renov			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _no_unidad			char(5);
define _cod_grupo			char(5);
define _cod_coasegur		char(3);
define _cod_subramo			char(3);
define _cod_tipotran		char(3);
define _res_origen			char(3);
define _cod_ramo			char(3);
define _periodo_requis		char(7);
define _periodo_pago		char(7);
define _periodo				char(7);
define _estatus_reclamo		char(1);
define _tipo				char(1);
define _estatus_poliza		smallint;
define _flag_anio_pago		smallint;
define _clasificacion		smallint;
define _tipo_contrato		smallint;
define _no_cambio			smallint;
define _fronting			smallint;
define _cnt_cob				smallint;
define _pagado				smallint;
define _fecha_decl			date;
define _fecha_ocurr			date;
define _fecha_transaccion	date;
define _fecha_declaracion	date;
define _fecha_ocurrencia	date;
define _fecha_siniestro		date;
define _fecha_reclamo		date;
define _fecha_pagado		date;
define _res_fechatrx		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_trx			date;
define _fecha_cierre		date;
define _error_isam			integer;
define my_sessionid			integer;
define _error				integer;
define _debito				dec(16,2);
define _credito				dec(16,2);
define _mto_mov				dec(16,2);
define _reserva_cedida		dec(16,2);
define _pagado_cedido		dec(16,2);
define _monto_reserva		dec(16,2);
define _monto_pag_ret		dec(16,2);
define _monto_pagado		dec(16,2);
define _pagado_bruto		dec(16,2);
define _reserva_ret			dec(16,2);
define _monto_total			dec(16,2);
define _monto_bruto			dec(16,2);
define _pagado_neto			dec(16,2);
define _variacion			dec(16,2);
define _reserva				dec(16,2);
define _monto_pag			dec(16,2);
define _porc_reas			dec(9,6);
define _porc_partic_prima	dec(9,6);
define _porc_facultativo	dec(9,6);
define _porc_retencion		dec(9,6);
define _porc_fronting		dec(9,6);
define _porc_cedido			dec(9,6);
define _porc_coas			dec(7,4);


set isolation to dirty read;

let _no_documento = '';
let _error_desc = '';
let _no_poliza = '';

begin 
on exception set _error, _error_isam, _error_desc
	if _no_poliza is null then
		let _no_poliza = '';
	end if
	
	if _no_documento is null then
		let _no_documento = '';
	end if
	
	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_no_documento) || trim(_error_desc);
	return '',				
		   null,            
		   '',              
		   '',
		   _error,          
		   _error_isam,     
		   '',              
		   _error_desc,     
		   '',              
		   '',              
		   '',              
		   '',              
		   '',              
		   null,            
		   null,            
		   '',              
		   '',              
		   '',              
		   null,            
		   null,            
		   null,            
		   null,            
		   0.00,           
		   0.00,           
		   0.00,           
		   0.00,           
		   0.00,           
		   0.00,           
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

--set debug file to "sp_pro545.trc";
--trace on;

let _fecha_desde = mdy(a_periodo_desde[6,7],1,a_periodo_desde[1,4]);
let _fecha_hasta = sp_sis36(a_periodo_hasta);

drop table if exists tmp_mov_trxs;
create temp table tmp_mov_trxs(
res_origen			char(3),							
res_fechatrx		date,			
cuenta				varchar(30),	
nom_cuenta			varchar(30),	
debito				dec(16,2),		
credito				dec(16,2),		
cod_ramo			char(3),			
nom_ramo			varchar(30),		
cod_subramo			char(3),			
nom_subramo			varchar(30),	
cod_grupo			char(5),
nom_grupo			varchar(30),		
no_documento		char(20),		
vigencia_inic		date,			
vigencia_final		date,			
nueva_renov			char(20),		
numrecla			varchar(30),		
transaccion			char(10),		
fecha_trx			date,			
fecha_reclamo		date,			
fecha_siniestro		date,			
fecha_pagado		date,			
mto_mov				dec(16,2),		
pagado_neto			dec(16,2),		
pagado_cedido		dec(16,2),		
reserva				dec(16,2),		
reserva_ret			dec(16,2),		
reserva_cedida		dec(16,2),		
no_reclamo			char(10),		
no_poliza			char(10),		
no_tranrec			char(10),		
anular_nt			char(10),		
cod_tipotran		char(3),			
tipotran			varchar(30),		
desc_clasif			varchar(50),		
categoria_contable	varchar(50),	  
segm_triangulo		varchar(40)) with no log;

FOREACH
	select res_origen,				
		   res_fechatrx,            
		   res_cuenta,              
		   cta_nombre,              
		   debito,                  
		   credito,                 
		   cod_ramo,                
		   ramo,                    
		   cod_subramo,             
		   subramo,                 
		   cod_grupo,               
		   grupo,                   
		   no_documento,            
		   vigencia_inic,           
		   vigencia_final,          
		   nueva_renov,             
		   numrecla,                
		   transaccion,             
		   fecha_trx,               
		   fecha_reclamo,           
		   fecha_siniestro,
		   fecha_pagado,		   
		   mto_mov,                 
		   reserva,
		   no_reclamo,
		   no_poliza,
		   no_tranrec,
		   anular_nt,
		   cod_tipotran,
		   tipo_tran
	  into _res_origen,			
		   _res_fechatrx,       
		   _cuenta,             
		   _nom_cuenta,         
		   _debito,             
		   _credito,            
		   _cod_ramo,           
		   _nom_ramo,           
		   _cod_subramo,        
		   _nom_subramo,        
		   _cod_grupo,			
		   _nom_grupo,          
		   _no_documento,       
		   _vigencia_inic,      
		   _vigencia_final,     
		   _nueva_renov,        
		   _numrecla,           
		   _transaccion,        
		   _fecha_trx,          
		   _fecha_reclamo,      
		   _fecha_siniestro,
		   _fecha_pagado,
		   _mto_mov,
		   _reserva,
		   _no_reclamo,
		   _no_poliza,
		   _no_tranrec,
		   _anular_nt,
		   _cod_tipotran,
		   _tipotran
	  from (                    
	select res_origen,          
		   res_fechatrx,        
		   res_cuenta,          
		   cta_nombre,
		   asi.debito,
		   asi.credito,
		   ram.cod_ramo,
		   ram.nombre as ramo,
		   sub.cod_subramo,
		   sub.nombre as subramo,
		   grp.cod_grupo,
		   grp.nombre as grupo,
		   emi.no_documento,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   emi.nueva_renov,
		   mae.numrecla,
		   mae.transaccion,
		   mae.fecha as fecha_trx,
		   rec.fecha_reclamo,
		   rec.fecha_siniestro,
		   mae.fecha_pagado,
		   mae.monto * (coa.porc_partic_coas/100) as mto_mov,
		   mae.variacion * (coa.porc_partic_coas/100) as reserva,
		   rec.no_reclamo,
		   emi.no_poliza,
		   mae.no_tranrec,
		   mae.anular_nt,
		   mae.cod_tipotran,
		   tra.nombre as tipo_tran
	  from cglresumen res
	 inner join cglcuentas cgl on res_cuenta = cta_cuenta
	  left join recasien asi on asi.sac_notrx = res_notrx and asi.cuenta = res_cuenta and asi.centro_costo = res_ccosto
	  left join rectrmae mae on mae.no_tranrec = asi.no_tranrec
	  left join recrcmae rec on rec.no_reclamo = mae.no_reclamo
	  left join reccoas coa on coa.no_reclamo = rec.no_reclamo and coa.cod_coasegur = '036'
	  left join rectitra tra on tra.cod_tipotran = mae.cod_tipotran
	  left join emipomae emi on emi.no_poliza = rec.no_poliza
	  left join prdramo ram on ram.cod_ramo = emi.cod_ramo
	  left join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	  left join cligrupo grp on grp.cod_grupo = emi.cod_grupo	  
	 where res_fechatrx between _fecha_desde and _fecha_hasta
	   and (res_cuenta like '541%' or res_cuenta like '221%' or res_cuenta like '419%')
	   and res_origen = 'REC'
	union
	select res_origen,
		   res_fechatrx,
		   res_cuenta,
		   cta_nombre,
		   asi.debito,
		   asi.credito,
		   ram.cod_ramo,
		   ram.nombre as ramo,
		   sub.cod_subramo,
		   sub.nombre as subramo,
		   grp.cod_grupo,
		   grp.nombre as grupo,
		   emi.no_documento,
		   emi.vigencia_inic,
		   emi.vigencia_final,
		   emi.nueva_renov,
		   mae.numrecla,
		   mae.transaccion,
		   mae.fecha as fecha_trx,
		   rec.fecha_reclamo,
		   rec.fecha_siniestro,
		   mae.fecha_pagado,
		   mae.monto * (coa.porc_partic_coas/100)  as mto_mov,
		   mae.variacion * (coa.porc_partic_coas/100) as reserva,
		   rec.no_reclamo,
		   emi.no_poliza,
		   mae.no_tranrec,
		   mae.anular_nt,
		   mae.cod_tipotran,
		   tra.nombre as tipo_tran
	  from cglresumen res
	 inner join cglcuentas cgl on res_cuenta = cta_cuenta
	  left join cobasien asi on asi.sac_notrx = res_notrx and asi.cuenta = res_cuenta and asi.centro_costo = res_ccosto
	  left join cobredet cob on cob.no_remesa = asi.no_remesa and cob.renglon = asi.renglon
	  left join rectrmae mae on mae.no_tranrec = cob.no_tranrec
	  left join recrcmae rec on rec.no_reclamo = mae.no_reclamo
	  left join reccoas coa on coa.no_reclamo = rec.no_reclamo and coa.cod_coasegur = '036'
	  left join rectitra tra on tra.cod_tipotran = mae.cod_tipotran
	  left join emipomae emi on emi.no_poliza = rec.no_poliza
	  left join prdramo ram on ram.cod_ramo = emi.cod_ramo
	  left join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
	  left join cligrupo grp on grp.cod_grupo = emi.cod_grupo
	  left join emipoagt agt on agt.no_poliza = emi.no_poliza
	  left join agtagent cor on cor.cod_agente = agt.cod_agente
	  left join agtvende zon on zon.cod_vendedor = cor.cod_vendedor
	 where res_fechatrx between _fecha_desde and _fecha_hasta
	   and (res_cuenta like '541%' or res_cuenta like '221%' or res_cuenta like '419%')
	   and res_origen = 'COB')

	if _no_tranrec is null then
		let _pagado_neto = 0.00;
		let _pagado_cedido = 0.00;
		let _reserva_ret = 0.00;
		let _reserva_cedida = 0.00;		
	else
		select sum(cob.monto * (rea.porc_partic_prima/100)),
			   sum(cob.variacion * (rea.porc_partic_prima/100))
		  into _pagado_neto,
			   _reserva_ret
		  from rectrcob cob
		 inner join prdcober mae on mae.cod_cobertura = cob.cod_cobertura
		 inner join rectrrea rea on rea.no_tranrec = cob.no_tranrec and rea.cod_cober_reas = mae.cod_cober_reas
		 where cob.no_tranrec = _no_tranrec
		   and rea.tipo_contrato = 1;
		
		if _pagado_neto is null then
			let _pagado_neto = 0.00;
		end if
		if _reserva_ret is null then
			let _reserva_ret = 0.00;
		end if
		
		let _reserva_cedida = _reserva - _reserva_ret;
		let _pagado_cedido = _mto_mov - _pagado_neto;		
	end if
	
	call sp_niif13(_no_poliza,_no_reclamo,_no_tranrec,1)
	returning _error,_error_isam,_error_desc,_desc_clasif,_categoria_contable,_segm_triangulo;
	
	insert into tmp_mov_trxs(
	res_origen,			
	res_fechatrx,     
	cuenta,
	nom_cuenta,
	debito,           
	credito,
	cod_ramo,
	nom_ramo,
	cod_subramo,
	nom_subramo,    
	cod_grupo,
	nom_grupo,         
	no_documento,
	vigencia_inic,    
	vigencia_final,
	nueva_renov,      
	numrecla,          
	transaccion,      
	fecha_trx,
	fecha_reclamo,
	fecha_siniestro,
	fecha_pagado,
	mto_mov,
	pagado_neto,
	pagado_cedido,
	reserva,
	reserva_ret,
	reserva_cedida,
	no_reclamo,      
	no_poliza,      
	no_tranrec,      
	anular_nt,      
	cod_tipotran,
	tipotran,          
	desc_clasif,       
	categoria_contable,
	segm_triangulo)
	values(
	_res_origen,			
   _res_fechatrx,       
   _cuenta,             
   _nom_cuenta,         
   _debito,             
   _credito,            
   _cod_ramo,           
   _nom_ramo,           
   _cod_subramo,        
   _nom_subramo,        
   _cod_grupo,			
   _nom_grupo,          
   _no_documento,       
   _vigencia_inic,      
   _vigencia_final,     
   _nueva_renov,        
   _numrecla,           
   _transaccion,        
   _fecha_trx,          
   _fecha_reclamo,      
   _fecha_siniestro,
   _fecha_pagado,
   _mto_mov,
   _pagado_neto,
   _pagado_cedido,
   _reserva,
   _reserva_ret,
   _reserva_cedida,
   _no_reclamo,
   _no_poliza,
   _no_tranrec,
   _anular_nt,
   _cod_tipotran,
   _tipotran,
   _desc_clasif,
   _categoria_contable,
   _segm_triangulo);
end foreach
end
end procedure;