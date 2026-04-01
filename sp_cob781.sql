--*****************************************************************
-- Procedimiento polizas vigentes forma de pago ACH en ALL BANK
--*****************************************************************
-- Execute procedure sp_cob781("001","001","22/01/2020","005")
-- Creado    : 22/01/2020      -- Autor: Henry Giron

DROP PROCEDURE sp_cob781;
create procedure "informix".sp_cob781(
a_cia		char(3),
a_agencia	char(3),
a_fecha_actual	date,
a_forma_pago	char(3))
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
		char(30) as banco,
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
define _cod_banco          char(3);
define _nom_banco          char(30);

--set debug file to "sp_cob781.trc";
--trace on;	
set isolation to dirty read; 
--drop table if exists temp_perfil;
let _cod_acreedor = ""; 
let _debe = 0.00;
LET v_filtros = ""; 
let _nom_banco = '';
let _cia = '001'; 
let _agencia = '001'; 
let _fecha_gestion = current;
let _fecha_hasta = current; 
let _fecha_desde = a_fecha_actual;
-- call sp_cob356b(a_fecha_actual, a_dias_sin_pago) returning _error, _error_desc; 

-- drop table if exists tmp_codigos;
-- drop table if exists tmp_codigos_zona;

--CALL sp_pro03(a_cia,a_agencia,a_fecha_actual,"*")  RETURNING v_filtros;      -- Vigentes
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
        WHERE seleccionado = 1  	
		
		let _por_vencer = 0;
		let _exigible = 0;
		let _corriente = 0;
		let _monto_30 = 0;
		let _monto_60 = 0;
		let _monto_90 = 0;
		let _monto_120 = 0;
		let _monto_150 = 0;
		let _monto_180 = 0;
		let _saldo_total = 0;			

				
	
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
	 	 	 
	if trim(_cod_formapag) <> trim(a_forma_pago) then
		continue foreach;
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
	   
	{IF _estatus_poliza <> 1 THEN -- solo vigente
		continue foreach;
	END IF}
	
	let _cnt = 0;
	select count(*)
	  into _cnt
	  from cobcutas c, cobcuhab h
	 where trim(c.no_cuenta) = trim(h.no_cuenta)
     --  and h.cod_banco = '205' --ALL BANK   (SOLO ACH)
       and c.no_documento = _no_documento;
	   
	  if _cnt is null then 
	     let _cnt = 0; 
	 end if 	   
	   
	  IF _cnt = 0 THEN -- solo  205 -ALL BANK
		 continue foreach;
	 END IF  
	 
   foreach
	select h.cod_banco
	  into _cod_banco
	  from cobcutas c, cobcuhab h
	 where trim(c.no_cuenta) = trim(h.no_cuenta)      
       and c.no_documento = _no_documento
	   
	select trim(nombre)
	  into _nom_banco
	  from chqbanco
	 where cod_banco = _cod_banco;	   
	 exit foreach;
	 
	 let _nom_banco = trim(_nom_banco)||' ('||trim(_cod_banco)||')';
	   
	   end foreach

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
			   _cod_formapag,
			   _zona_ventas,
			   _zona_cobros,
			   _nom_banco,
			   _estatus_char
			   with resume; 			   

end foreach

	 


END PROCEDURE                                                                                                                                                                                       
