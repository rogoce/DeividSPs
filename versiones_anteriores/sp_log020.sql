-- pool endosos
-- Creado		: 04/04/2017	- Autor: Henry Giron.

drop procedure sp_log020;		  
create procedure "informix".sp_log020(a_sucursal char(350), a_estatus smallint)
returning varchar(50) As n_corredor,
		  char(10) As no_poliza,
		  char(8) As user_added,   
		  char(20) As no_documento,    
		  date As fecha_imprimio,   
		  date As vigencia_inic,   
		  date As vigencia_final,   
		  dec(16,2) As saldo,   
		  char(10) As no_factura,   
		  char(5) As cod_agente,
		  varchar(100) As n_cliente,
		  char(10) As cod_contratante,  
		  smallint As estado_log,
		  char(3) As cod_sucursal	,  		  		  		  		   
		  smallint As imprimir,
		  char(100) As sucursal,
		  varchar(50) As nom_acreedor,
		  date As fecha_added,   
		  SMALLINT As cnt_copias,
		  CHAR(5) As cod_acreedor,
		  SMALLINT As leasing,
		  smallint As can_uni,
		  char(3) As cod_vendedor,		  
		  char(3) As Tipo_Endoso,
		  char(5) As no_endoso,
		  smallint As estado_pro,
		  smallint As imprimir_val;


define _n_cliente       	varchar(100);
define _n_corredor      	varchar(50);
define _nom_acreedor		varchar(50);

define _no_poliza2      	char(10);	 
define _cod_contratante 	char(10);	 
define _fil_suc				char(3);
define _cod_depto			char(3);
define _sucursal        	char(3);
define _cod_ramo        	char(3);
define _suc_prom        	char(3);
define _tipo				char(1);
define _saldo				dec(16,2);
define _estatus         	smallint;
define _can_uni				smallint;
define _cnt_acre			smallint;
define _cnt_uni				integer;
define _saldo_porc      	integer;
define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_leasing         char(10);
define _no_unidad			char(5);

define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_documento		char(20);
define _user_added			char(8);
define _fecha_added			date;
define _cod_sucursal		char(3);
define _no_factura			char(10);
define _imprimir			smallint;
define _imprimir_val		smallint;
define _user_facturo		char(8);
define _cod_endomov			char(3);
define _cod_tipocan			char(3);
define _user_imprimio		char(8);
define _fecha_imprimio		date;
define _user_elimino		char(8);
define _fecha_elimino		date;
define _cod_cliente			char(10);
define _cod_agente			char(5);
define _cod_acreedor		char(5);
define _cod_vendedor		char(3);
define _leasing				smallint;
define _estado_pro			smallint;
define _estado_log			smallint;
define _cnt_copias          SMALLINT;
define _bandera_acreedor    smallint;
define _desc_suc		    char(100);
define _fecha_actual		date;
define _cant_fact      smallint;
define _cnt                 smallint;

let _fecha_actual	= sp_sis26();


set isolation to dirty read;

--set debug file to "sp_log020.trc";
let _imprimir_val = 0;
let _leasing = 0;
let _estado_pro = 0;
let _estado_log= 0;	
let _saldo = 0.00;
let _bandera_acreedor = 0;

if a_sucursal = '*;' then		
	let _bandera_acreedor = 1;
end if
	
if a_sucursal in ('*','*;') then	

	if a_sucursal = '*;' then
		let a_sucursal = '001';
		let _bandera_acreedor = 1;
	else
		let a_sucursal = '';--'006';
	end if
	
	foreach
		select codigo_agencia 
		  into _cod_sucursal 
		  from insagen   
		 where sucursal_promotoria <> '001' 
		
		if a_sucursal = '' or a_sucursal is null then 
			let a_sucursal = trim(a_sucursal) || trim(_cod_sucursal); 
		else 
			let a_sucursal = trim(a_sucursal) || ',' || trim(_cod_sucursal); 
		end if 
	end foreach 
	
	let a_sucursal = trim(a_sucursal) || ';';  
	let _tipo = sp_sis04(a_sucursal); -- Separa los valores del String 
else
	let _tipo = sp_sis04(a_sucursal); -- Separa los valores del String 
end if

--trace on;
let _bandera_acreedor = _bandera_acreedor ;
let a_estatus = a_estatus;
--trace off;
	 
foreach
  select no_poliza,   
         no_endoso,   
         no_documento,   
         user_facturo,   
         fecha_added,   
         cod_sucursal,   
         no_factura,   
         imprimir,   
         user_facturo,   
         cod_endomov,   
         cod_tipocan,   
         user_imprimio,   
         fecha_imprimio,   
         user_elimino,   
         fecha_elimino,   
         cod_cliente,   
         cod_agente,   
         cod_acreedor,   
         cod_vendedor,   
         leasing,   
         estado_pro,   
         estado_log  
   into _no_poliza,
		_no_endoso,
		_no_documento,
		_user_added,
		_fecha_added,
		_cod_sucursal,
		_no_factura,
		_imprimir,
		_user_facturo,
		_cod_endomov,
		_cod_tipocan,
		_user_imprimio,
		_fecha_imprimio,
		_user_elimino,
		_fecha_elimino,
		_cod_cliente,
		_cod_agente,
		_cod_acreedor,
		_cod_vendedor,
		_leasing,
		_estado_pro,
		_estado_log 
    from endpool0 
   where estado_pro  in ( a_estatus,0,1,2,5) 
     and estado_log  in ( a_estatus,0,1,2,3) --,5,8) 
   
   if _bandera_acreedor = 1 then 
		
		let _cant_fact = 0; 		
		
		select count(*) 
		into _cant_fact 
		from logcaja0
		where numero = _no_factura
		  and fecha_recibe is  null
		  and activo not in (4); 
		
		if _cant_fact is null then 
			let _cant_fact = 0; 
		end if 	  		

		if _cant_fact = 0 then
			continue foreach;
		end if
			

	else
		let _cant_fact = 0; 		
		
		select count(*) 
		into _cant_fact 
		from logcaja0
		where numero = _no_factura
		  and fecha_adicion is null
		  and activo not in (4); 
		
		if _cant_fact is null then 
			let _cant_fact = 0; 
		end if 	  		

		if _cant_fact = 0 then
			continue foreach;
		end if
		

		
   end if   
   {
   	if _cod_endomov = "002" then  -- las cancelaciones no seran tomadas en este pool, se manejarna en el pool de cancelaciones. 
		continue foreach;		
	end if
	}
 	if _cod_endomov in ('002','017','018','024','025','026','028','030','031','033','034')  then  -- JEPEREZ 21/08/2020. 
		continue foreach;		
	end if    

	let _no_poliza2 = sp_sis21(_no_documento);	

	select cod_contratante,
           vigencia_inic,
		   vigencia_final,
		   sucursal_origen,
		   cod_ramo,
		   leasing
  	  into _cod_contratante,
	       _vigencia_inic,
		   _vigencia_final,
		   _sucursal,
		   _cod_ramo,
		   _leasing
  	  from emipomae
     where no_poliza = _no_poliza2;
	
	let _cod_acreedor = '';
	let _nom_acreedor = ''; 
	
  	if _sucursal = '010' then
		let _sucursal = '001';
	end if
		
	foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza2

		select nombre
		  into _nom_acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor;

		exit foreach;
	end foreach
	
	if _cod_acreedor is null or _cod_acreedor = '' then
	    if _leasing = 1 then
			foreach
				select no_unidad
				  into _no_unidad
				  from emipouni
				 where no_poliza = _no_poliza2
			 exit foreach;
			end foreach
			
			select cod_asegurado
			  into _cod_leasing
			  from emipouni
			 where no_poliza = _no_poliza2
               and no_unidad = _no_unidad;
			   
		   select nombre
			 into _nom_acreedor
			 from cliclien
			where cod_cliente = _cod_leasing;
		else	   
			let _cod_acreedor = '';
		end if
	end if
	
		let _desc_suc = ""; 
	select sucursal_promotoria, descripcion 
	  into _suc_prom, _desc_suc 
	  from insagen
	 where codigo_agencia  = _sucursal
	   and codigo_compania = '001';
	
	{
	if _cod_ramo <> "008" then  --fianzas si se imprime en casa matriza siempre.
		if _suc_prom not in (select codigo from tmp_codigos) then 
			continue foreach;
		end if
	end if
	}

	select nombre
	  into _n_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre,
	       cod_vendedor
 	  into _n_corredor,
		   _cod_vendedor
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	 select count(*)
	   into _cnt_uni 
	   from emipouni
	  where no_poliza = _no_poliza;
	  
	  if _cnt_uni > 2 then 
		let _can_uni = 1; 
	  else
		let _can_uni = 0;
	  end if 
	  
    let _cnt_copias = 0;   
   CALL sp_sis389(_no_poliza) RETURNING _cnt_copias;	  	  
   
	let _cnt = 0;
	select count(*)
	  into _cnt
	  from emiacre
	 where activo = 1 and email is not null
	   and cod_acreedor = _cod_acreedor;

	if _cnt is null then
		let _cnt = 0;
	end if
	   
	if _cnt = 0 then
 	    let _imprimir_val = 0;
	else
		let _imprimir_val = 1;  -- condicion de si no esta completo con el correo no se envia. JEPEREZ 01/10/2020.
	end if         
   
   --LET _no_poliza = sp_sis21(_no_documento);       

	return _n_corredor,				
   		   _no_poliza,				
   		   _user_added,   			  
		   _no_documento,   			  
		   _fecha_imprimio ,   		  
		   _vigencia_inic,   		
		   _vigencia_final,   		
		   _saldo,   				
		   _no_factura,   			
		   _cod_agente,				
		   _n_cliente,				
		   _cod_contratante,			  
		   _estado_log,					  
		   _sucursal,
		   _imprimir,
		   _desc_suc,
		   _nom_acreedor,
		   _fecha_added,
		   _cnt_copias,
		   _cod_acreedor,
		   _leasing,
           _can_uni,
		   _cod_vendedor,
           _cod_endomov,
           _no_endoso,
           _estado_pro,
           _imprimir_val		   
		   with resume;		   
end foreach
drop table tmp_codigos;
end procedure	