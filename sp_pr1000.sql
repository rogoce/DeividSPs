-- Pool de cancelacion - solo impresion 
-- Creado		: 18/11/2010 - Autor: Henry Giron.
-- Modificado	: 07/02/2012 - Autor: Roman Gordon	**Se Agrego al acreedor para aplicarlo al ordenamiento del datawindow
-- Modificado	: 23/03/2017 - Autor: Henry Giron. Condicion de copias por acreedor y leasing, filtro x fecha 

drop procedure sp_pr1000;
create procedure "informix".sp_pr1000(a_sucursal char(3), a_estatus char(1))
returning varchar(50),	--_n_corredor,
		  char(10),		--_no_poliza,
		  char(8),		--_user_added,   
		  char(20),		--_no_documento,    
		  date,			--_fecha_selec,   
		  date,			--_vigencia_inic,   
		  date,			--_vigencia_final,   
		  dec(16,2),	--_saldo,   
		  char(10),		--_no_factura,   
		  char(5),		--_cod_agente,
		  varchar(100),	--_n_cliente,
		  char(10),		--_cod_contratante  
		  char(1),		--_estatus
		  char(3),		--_cod_sucursal	  		  		  		  		   
		  smallint,		--_imprimir
          char(15),		--_no_aviso
          integer,		--_no_renglon
		  char(100),	--_sucursal
		  varchar(50),  --_nom_acreedor
		  date,
		  SMALLINT,
		  CHAR(5),
		  SMALLINT;	-- _fecha_adicion

define _n_cliente		varchar(100);
define _n_corredor		varchar(50);
define _nom_acreedor	varchar(50);
define _desc_suc		char(100);
define _no_documento	char(20);
define _no_aviso		char(15);
define _cod_contratante	char(10);
define _no_poliza		char(10);	
define _user_cancela	char(8);
define _no_factura		char(10);
define _cod_agente		char(5);
define _cod_acreedor	char(5);
define _no_endoso		char(5);
define _sucursal		char(3);
define _cod_ramo		char(3);
define _suc_prom		char(3);
define _cod_sucursal	char(3);
define _estatus			char(1); 
define _fecha_cancela	date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_hoy		date;
define _saldo_cancelado	dec(16,5);
define _saldo			dec(16,2);
define _imprimir_log	smallint;
define _saldo_porc		integer; 
define _renglon			integer;

define _leasing         SMALLINT;
define _cnt_acre        SMALLINT;
define _fecha_adicion   date;
define _fecha_imprimio  date;
define _cnt_copias      SMALLINT;


let _fecha_hoy = current;
set isolation to dirty read; 

foreach
	select no_poliza,
	       user_cancela, 
	       no_documento, 
	       fecha_cancela, 
	       vigencia_inic, 
	       vigencia_final, 
	       saldo, 
	       cod_agente, 
	       estatus, 
	       no_aviso, 
	       renglon, 
	       no_factura, 
	       no_endoso, 
	       saldo_cancelado, 
		   cod_contratante, 
		   cod_ramo, 
		   nombre_cliente, 
		   nombre_agente, 
		   imprimir_log 
	  into _no_poliza, 
		   _user_cancela,  
		   _no_documento, 
		   _fecha_cancela, 
		   _vigencia_inic, 
		   _vigencia_final, 
		   _saldo, 
		   _cod_agente, 
		   _estatus, 
		   _no_aviso, 
		   _renglon, 
		   _no_factura, 
		   _no_endoso, 
		   _saldo_cancelado, 
		   _cod_contratante, 
		   _cod_ramo, 
		   _n_cliente, 
		   _n_corredor, 
		   _imprimir_log 
	  from avisocanc 
     where estatus in ('Z') 
       and (imprimir_log = 0 or imprimir_log is null) 
	   
		if _no_factura is null then   
			continue foreach; 
		end if 	   
	   
   select date_added --fecha_emision
     into _fecha_adicion 
     from endedmae 
    where no_factura  = _no_factura;	   
	
	if _fecha_adicion is null then 
		let _fecha_adicion = null; 
	end if 	

	select sucursal_origen,leasing 
	  into _sucursal,_leasing
	  from emipomae 
	 where no_poliza = _no_poliza;  

	let _desc_suc = ""; 
	
	select sucursal_promotoria,descripcion  
	  into _suc_prom, _desc_suc 
	  from insagen  
	 where codigo_agencia  = _sucursal  
	   and codigo_compania = '001';  

	if a_sucursal = "001" and _suc_prom in ("004","006","001") then 
	else 
		if a_sucursal <> _suc_prom then   
			continue foreach; 
		end if  
	end if 
	let _cnt_acre = 0;
	
	--incluye solo acredor hipotecario
	select count(distinct n.nombre)
	  into _cnt_acre
	  from emipoacr e, emiacre n
	 where e.cod_acreedor = n.cod_acreedor
	   and e.no_poliza = _no_poliza;	   
	   
	if _leasing = 0 and _cnt_acre = 0 then 
		continue foreach;    -- si no es leasing ,ni banco  no va al pool de cancelación
	end if	   

--	if _cod_ramo <> "008" then  -- fianzas si se imprime en casa matriz a siempre. 
--	end if   
	if _imprimir_log is null then 
		let _imprimir_log = 0; 
	end if 

	let _cod_acreedor = ''; 
	let _nom_acreedor = ''; 
	
	foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza

		select nombre
		  into _nom_acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor;

		exit foreach;
	end foreach
    let _cnt_copias = 0;   
   CALL sp_sis389(_no_poliza) RETURNING _cnt_copias;	   	

	return _n_corredor,				
   		   _no_poliza,				
   		   _user_cancela,   			  
		   _no_documento,   			  
		   _fecha_cancela,   		  
		   _vigencia_inic,   		
		   _vigencia_final,   		
		   _saldo,   				
		   _no_factura,   			
		   _cod_agente,				
		   _n_cliente,				
		   _cod_contratante,			  
		   _estatus,					  
		   _sucursal,
		   _imprimir_log,
		   _no_aviso,
		   _renglon,
		   _desc_suc,
		   _nom_acreedor,
		   _fecha_adicion,
		   _cnt_copias,
		   _cod_acreedor,
		   _leasing   -- se adiciono para filtro y # copias
		   with resume;

end foreach
--- se anexo al pool endoso de cancelacion falta de pago sin avisos de cancelacion
foreach
	select no_poliza,
	       user_facturo, --user_cancela,
	       no_documento,
	       fecha_added, --fecha_cancela,
	       current, --vigencia_inic,
	       current, --vigencia_final,
	       0, --saldo,
	       cod_agente,
	       'E', --estatus,
	       '00000', --no_aviso,
	       0, --renglon,
	       no_factura,
	       no_endoso,
	       0, --saldo_cancelado,
	       cod_cliente, --cod_contratante,
	       '', -- cod_ramo,
	       '', -- nombre_cliente,
		'', -- nombre_agente,
		   0, --imprimir_log
		   fecha_imprimio
	  into _no_poliza, 
		   _user_cancela,  
		   _no_documento, 
		   _fecha_cancela, 
		   _vigencia_inic, 
		   _vigencia_final, 
		   _saldo, 
		   _cod_agente, 
		   _estatus, 
		   _no_aviso, 
		   _renglon, 
		   _no_factura, 
		   _no_endoso, 
		   _saldo_cancelado, 
		   _cod_contratante, 
		   _cod_ramo, 
		   _n_cliente, 
		   _n_corredor, 
		   _imprimir_log,
		   _fecha_imprimio
     from endpool0
    where cod_endomov = '002'
	--and no_factura in ('01-1919136','01-1919156')
     --and estado_log = 0  and estado_pro = 0
	   and estado_pro <> 2 and estado_log  <> 4
     --and fecha_added < fecha_imprimio
     and month(fecha_added) = month(current)
     --and user_imprimio is not null
	   
		if _no_factura is null then   
			continue foreach; 
		end if 	   			
	   
   select date_added --fecha_emision
     into _fecha_adicion 
     from endedmae 
    where no_factura  = _no_factura;	   
	
	 if _fecha_adicion < _fecha_imprimio then --and _user_elimino is not null and _estado_pro in (1) or  _estado_log in (2) then  
		continue foreach;		
	end if	
	
    select nombre 
	  into _n_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;	
	 
	select nombre
 	  into _n_corredor
	  from agtagent
	 where cod_agente = _cod_agente;	 
	
	if _fecha_adicion is null then 
		let _fecha_adicion = null; 
	end if 	

	select sucursal_origen,leasing 
	  into _sucursal,_leasing
	  from emipomae 
	 where no_poliza = _no_poliza;  

	let _desc_suc = ""; 
	
	select sucursal_promotoria,descripcion  
	  into _suc_prom, _desc_suc 
	  from insagen  
	 where codigo_agencia  = _sucursal  
	   and codigo_compania = '001';  

	if a_sucursal = "001" and _suc_prom in ("004","006","001") then 
	else 
		if a_sucursal <> _suc_prom then   
			continue foreach; 
		end if  
	end if 
	let _cnt_acre = 0;
	
	--incluye solo acredor hipotecario
	select count(distinct n.nombre)
	  into _cnt_acre
	  from emipoacr e, emiacre n
	 where e.cod_acreedor = n.cod_acreedor
	   and e.no_poliza = _no_poliza;	   
	   
	if _leasing = 0 and _cnt_acre = 0 then 
		continue foreach;    -- si no es leasing ,ni banco  no va al pool de cancelación
	end if	   

--	if _cod_ramo <> "008" then  -- fianzas si se imprime en casa matriz a siempre. 
--	end if   
	if _imprimir_log is null then 
		let _imprimir_log = 0; 
	end if 

	let _cod_acreedor = ''; 
	let _nom_acreedor = ''; 
	
	foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza

		select nombre
		  into _nom_acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor;

		exit foreach;
	end foreach
    let _cnt_copias = 0;   
   CALL sp_sis389(_no_poliza) RETURNING _cnt_copias;	   	
   if _cnt_copias is null or _cnt_copias = 0 then
      let _cnt_copias = 1;
   end if

	return _n_corredor,				
   		   _no_poliza,				
   		   _user_cancela,   			  
		   _no_documento,   			  
		   _fecha_cancela,   		  
		   _vigencia_inic,   		
		   _vigencia_final,   		
		   _saldo,   				
		   _no_factura,   			
		   _cod_agente,				
		   _n_cliente,				
		   _cod_contratante,			  
		   _estatus,					  
		   _sucursal,
		   _imprimir_log,
		   _no_aviso,
		   _renglon,
		   _desc_suc,
		   _nom_acreedor,
		   _fecha_adicion,
		   _cnt_copias,
		   _cod_acreedor,
		   _leasing   -- se adiciono para filtro y # copias
		   with resume;

end foreach
end procedure	
