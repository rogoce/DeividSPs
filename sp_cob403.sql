-- Procedimiento que genera reporte de polizas con 25 dias sin gestion
-- Creado    : 21/08/2017 -- Henry Giron
-- Execute procedure sp_cob403('21/07/2017',25)
drop procedure sp_cob403;
create procedure sp_cob403(a_fecha_actual date, a_dias_sin_pago	integer)
returning varchar(20) as Poliza,
		varchar(100) as Nombre_Cliente,
		varchar(30) as Ramo,
		varchar(50) as Subramo,
		varchar(30) as Forma_Pago,
		varchar(100) as Corredor,
		varchar(100) as Nombre_Corredor,
		varchar(100) as Acreedor,
		smallint as Leasing,
		date as Vigencia_Inicial,
		date as Vigencia_Final,
		dec(10,2) as Prima_Bruta,
		dec(10,2) as Por_Vencer,  
		dec(10,2) as Exigible, 
		dec(10,2) as Corriente, 
		dec(10,2) as Monto_30, 
		dec(10,2) as Monto_60, 
		dec(10,2) as Monto_90,
		dec(16,2) as Saldo,
		varchar(20) as New_Ren,
		varchar(100) as Zona_Venta,
		varchar(100) as Zona_Cobros,
		smallint as Dias_sin_pago,
		char(7) as estatus;


-- Actualizar Polizas Nuevas
define _nombre_corredor		varchar(100);
define _nombre_acreedor		varchar(100);
define _nombre_cliente		varchar(100);
define _nombre_zona			varchar(100);
define _zona_cobros			varchar(100);
define _zona_ventas			varchar(100);
define _cod_agente			varchar(100);
define _error_desc			varchar(100);
define _nombre_forma_pag	varchar(30);
define _nombre_ramo			varchar(30);
define _estado				varchar(20);
define _no_documento		varchar(20);
define _cod_acreedor		varchar(10);
define _cod_pagador			varchar(10);
define _no_poliza			varchar(10);
define _periodo				char(7);
define _cod_vendedor		char(3);
define _cod_formapag		char(3);
define _cod_ramo			char(3);
define _tipo_vendedor		char(1);
define _nueva_renov			char(1);
define _tipo				char(1);
define _saldo_total			dec(10,2); 
define _prima_bruta			dec(10,2);
define _por_vencer			dec(10,2);   
define _corriente			dec(10,2); 
define _monto_180			dec(10,2); 
define _monto_150			dec(10,2); 
define _monto_120			dec(10,2); 
define _monto_90			dec(10,2); 
define _monto_60			dec(10,2); 
define _monto_30			dec(10,2); 
define _exigible			dec(10,2);
define _debe			    dec(10,2);
define _dias_sin_gestar		smallint; 
define _error				integer;
define _cnt					integer;
define _fecha_anulacion		date;
define _vigencia_final		date;
define _fecha_inicio        date;
define _vigencia_inic		date;
define _fecha_resta			date;
define _fecha_desde			date;

define _cod_grupo          CHAR(5);
define v_filtros           CHAR(255);
define _nombre_grupo       varchar(50);
define _cliente_vip        char(3);
define _nombre_subramo     varchar(50);
define _cod_subramo        char(3);
define _leasing            smallint;
define _cod_zona		   char(3);	
define _cia     		   char(3);	
define _agencia 		   char(3);	
define _fecha_hasta        date;
define _estatus_char	   char(7); 
define _estatus_poliza     smallint; 
define _fecha_gestion      date;
define _cod_tipoprod		char(3);

--set debug file to "sp_cob403.trc";
--trace on;	
set isolation to dirty read; 

let _cod_acreedor = ""; 
let _debe = 0.00;
LET v_filtros = ""; 
let _cia = '001'; 
let _agencia = '001'; 
let _fecha_gestion = current;
let _fecha_hasta = current; 
let _fecha_desde = a_fecha_actual -  a_dias_sin_pago units day;  
-- call sp_cob356b(a_fecha_actual, a_dias_sin_pago) returning _error, _error_desc; 
drop table if exists temp_perfil;
-- drop table if exists tmp_codigos;
-- drop table if exists tmp_codigos_zona;

CALL sp_pro03(_cia,_agencia,a_fecha_actual,"*")  RETURNING v_filtros;      -- Vigentes
CALL sp_pro03h(_cia,_agencia,a_fecha_actual,"018;")  RETURNING v_filtros;  -- Salud -Vencidas
call sp_sis39(a_fecha_actual) returning _periodo;						
--trace on;	 
let _fecha_hasta = _fecha_hasta; 
let _fecha_desde = _fecha_desde;  

foreach	 
       SELECT distinct y.no_poliza,
       		  y.no_documento
         INTO _no_poliza,
         	  _no_documento
         FROM temp_perfil y
        WHERE seleccionado = 1  -- and y.no_documento in ('0215-01941-03','0214-01261-03','0615-00109-01')		
		
	    select nueva_renov, vigencia_inic, vigencia_final, cod_tipoprod 	
	      into _nueva_renov, _vigencia_inic, _vigencia_final, _cod_tipoprod 		  
		  from emipomae
		 where no_poliza = _no_poliza;	 			 

		-- No Incluye Coaseguro Minoritario SD#7282 ENILDA 31/07/2023 HG
		if _cod_tipoprod = '002'  then   
		   continue foreach;
		end if	
		
		if _nueva_renov = 'N' then
			continue foreach;
		else
			let _estado = "Renovadas";
		end if		
		
	--let _no_poliza = sp_sis21(_no_documento);	
		call sp_cob245(
		 "001",
		 "001",	
		 _no_documento,
		 _periodo,
		 a_fecha_actual)
			returning	_por_vencer,      
						_exigible,         
						_corriente,        
						_monto_30,         
						_monto_60,         
						_monto_90,
						_monto_120,
						_monto_150,
						_monto_180,
						_saldo_total;
						
	if _exigible <= 0 then
		continue foreach;
	end if			
	
    drop table if exists tmp_cobgesti;
	select *
      from cobgesti  
	 where fecha_gestion >= _fecha_desde and fecha_gestion <= _fecha_hasta 
	   and no_documento = _no_documento
	  into temp tmp_cobgesti;
  
	let _cnt = 0; 	   
	let _dias_sin_gestar = 0;
	select count(*)
	  into _cnt
	  from tmp_cobgesti;
	  
	if _cnt is null then
		let _cnt = 0; 	   
	end if			  	
	  
	if _cnt > 0 then 
	
		--foreach
		--select a_fecha_actual - date(fecha_gestion)
		--  into _dias_sin_gestar
		--  from tmp_cobgesti
		--  order by fecha_gestion desc
		--  exit foreach;		   
		--end foreach		
		
	--	Se deben excluir como gestión las siguientes: 
		delete from tmp_cobgesti
		where (desc_gestion like ('%RECHAZO ACH:%'))                    --	§ Rechazo de ACH - sp_cob83
		   or (desc_gestion like ('%RECHAZO VISA:%'))	                --	§ Rechazo de TCR - sp_cob50
		   or (desc_gestion like ('%PAGO EFECTUADO%'))                  --	§ Pago de póliza - sp_cob753bk
		   or (desc_gestion like ('%SE EMITIO AVISO DE CANCELACION%'))  --	§ Avisos de Cancelación - w_avisocanc_proc
		   or (desc_gestion like ('%SE HA DEJADO DE FACTURAR LA POLIZA%')) -- and tipo_aviso = 17)                 -- § Facturación Detenida - sp_cob271
		   or (cod_gestion in ('020','027','058') and desc_gestion like ('% ESTADO DE CUENTA DE LA POLIZA%')) -- § Estado de Cuentas 1 - Call Center
		   or (desc_gestion like ('% ESTADO DE CUENTA DE LA POLIZA%')); --	§ Estado de Cuentas 2 - Otros

		select count(*)
		  into _cnt
		  from tmp_cobgesti;
		  
		if _cnt is null then
			let _cnt = 0; 	   
		end if				   
	end if	  	
	
	if _cnt > 0 then
		continue Foreach;
	end if			

    select max(date(fecha_gestion))
      into _fecha_gestion
	  from cobgesti
	 where fecha_gestion < _fecha_desde 
	   and fecha_gestion  >= _vigencia_inic  -- CASO:11/12/2017 ASTANCIO y ENILDA
	   and no_documento = _no_documento;
	 
	let _dias_sin_gestar = a_fecha_actual - _fecha_gestion;
	
	if _dias_sin_gestar <=  a_dias_sin_pago then
		continue Foreach;
	end if	
	let _debe = 0;
	let _debe = _corriente  + _monto_30 + _monto_60;
	
	if _exigible <= _debe then
		continue foreach;
	end if		
	
	select cod_pagador,
		   cod_ramo,
		   cod_formapag,
		   vigencia_inic,
		   vigencia_final,
		   prima_bruta,
		   nueva_renov,
		   cod_grupo,
		   cod_subramo,
		   leasing
	  into _cod_pagador,
		   _cod_ramo,
		   _cod_formapag,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_bruta,
		   _nueva_renov,
		   _cod_grupo,
		   _cod_subramo,
		   _leasing
	  from emipomae
	 where no_poliza = _no_poliza;	 	

	 	  -- let _dias_sin_gestar = 0;
	      -- let _fecha_inicio = '01/01/2014';
{	   
		foreach
		select distinct a_fecha_actual - e.fecha_primer_pago
		  into _dias_sin_gestar
		  from emiletra l, emipomae e
		 where e.no_poliza = l.no_poliza
		   and e.vigencia_inic >= _fecha_inicio
		   and l.no_documento = _no_documento
		   and e.cod_ramo = _cod_ramo
		   and a_fecha_actual - e.fecha_primer_pago >=  a_dias_sin_pago
		   and l.pagada = 0
		   and l.no_letra = 1
		   and l.monto_letra <> 0
		   --and l.monto_pag = 0 
           and e.estatus_poliza = 1		   
		  exit foreach;		   
		end foreach	
}   					  
		
		if _dias_sin_gestar is null then 
			let _dias_sin_gestar = 0;
		end if	
		if _dias_sin_gestar = 0 then
			continue Foreach;
		end if		

	select trim(nombre)
	  into _nombre_forma_pag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select trim(nombre)
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_pagador;
	let _cliente_vip = '';
    select count(*) into _cnt from clivip where cod_cliente = _cod_pagador;
	if _cnt is null then 
		let _cnt = 0;
	end if
	if _cnt > 0 then
		let _cliente_vip = 'VIP';
	end if
	select trim(nombre)
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	select trim(nombre)
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach

	select trim(nombre),
		   cod_vendedor
	  into _nombre_corredor,
		   _cod_vendedor
	  from agtagent
	 where cod_agente = _cod_agente;

	let _cnt = 0;
	
 --zona_ventas
	select trim(nombre)
	  into _zona_ventas
	  from agtvende 
	 where cod_vendedor = _cod_vendedor;
	let _cod_acreedor   = "";
	foreach
		select x.cod_acreedor
		  into _cod_acreedor
		  from emipoacr x, emipouni e
		 where x.no_poliza = e.no_poliza
		   and x.no_unidad = e.no_unidad
		   and e.no_poliza = _no_poliza
		 exit foreach;
	end foreach

	select trim(nombre)
	  into _nombre_acreedor
	  from emiacre
	 where cod_acreedor = _cod_acreedor;
	 
	-- Zona de Cobros
	select cod_cobrador
	  into _cod_zona
	  from agtagent
	 where cod_agente = _cod_agente;

	select trim(nombre)
	  into _zona_cobros
	  from cobcobra
	 where cod_cobrador = _cod_zona  
	   and activo = 1;	
	   
	select estatus_poliza	
	  into _estatus_poliza
	  from emipomae 
	 where no_poliza = _no_poliza;

	   let _estatus_char = null;

       if _estatus_poliza = 1 then
		let _estatus_char = 'VIGENTE'; 
	   elif _estatus_poliza = 2 then
 		let _estatus_char = 'CANCELADA'; 
	   elif _estatus_poliza = 3 then
 		let _estatus_char = 'VENCIDA'; 
	   elif _estatus_poliza = 4 then
 		let _estatus_char = 'ANULADA'; 
	   end if 
				
			return _no_documento,
			   _nombre_cliente,
			   _nombre_ramo,
			   _nombre_subramo,
			   _nombre_forma_pag,
			   _cod_agente,
			   _nombre_corredor,
			   _nombre_acreedor,
			   _leasing,
			   _vigencia_inic,
			   _vigencia_final,
			   _prima_bruta,
			   _por_vencer,  
			   _exigible,    
			   _corriente,   
			   _monto_30,    
			   _monto_60,    
			   _monto_90,
			   _saldo_total,
			   _estado,
			   _zona_ventas,
			   _zona_cobros,
			   _dias_sin_gestar,
			   _estatus_char
			   with resume; 			   
	
		--drop table if exists tmp_cobgesti;

end foreach

drop table if exists temp_perfil;
--drop table if exists tmp_codigos;
--drop table if exists tmp_codigos_zona;
--drop table if exists tmp_cobgesti;
end procedure;