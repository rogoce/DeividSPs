-- pool endosos
-- Creado		: 04/04/2017	- Autor: Henry Giron.

drop procedure sp_log020em;		  
create procedure "informix".sp_log020em(a_sucursal char(350), a_estatus smallint,a_desde date,a_hasta date)
	returning 	varchar(255) as filtro;


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
define _cant_fact           smallint;
define _n_ramo      	    varchar(50);
define _cedula     	        varchar(50);
define _email       	    varchar(100);
define _tipo_endoso    	    varchar(50);

drop table if exists tmp_codigos;	
drop table if exists temp_acreedor;	
create temp table temp_acreedor (
                no_documento  char(20),
				n_ramo        varchar(50), 
				no_factura    char(10),
				n_cliente     varchar(100),
				cedula        varchar(50),
				n_corredor     varchar(50),
				vigencia_inic  date,
				vigencia_final  date,
				nom_acreedor  varchar(50),
				cod_acreedor  char(20),
				email        varchar(100),
				tipo_endoso  varchar(50) ,no_poliza    char(10),no_endoso    char(5) 
) with no log;

let _fecha_actual	= sp_sis26();


set isolation to dirty read;

--set debug file to "sp_log020.trc";


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
drop table if exists tmp_endpool0;
select *
   from endpool0  
     where estado_pro  in ( a_estatus,0,1,2,5) 
     and estado_log  in ( a_estatus,0,1,2,3) --,5,8)
  into temp tmp_endpool0;	 
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
    from tmp_endpool0 
   where estado_pro  in ( a_estatus,0,1,2,5) 
     and estado_log  in ( a_estatus,0,1,2,3) --,5,8) 
	-- and fecha_added >= a_desde	 and fecha_added <= a_hasta
	 --and (cod_acreedor <>"" or leasing = 1) 
   
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
   
   	if _cod_endomov = "002" then  -- las cancelaciones no seran tomadas en este pool, se manejarna en el pool de cancelaciones. 
		continue foreach;		
	end if
	
	if _cod_endomov in ('002','017','018','024','025','026','028','030')  then  -- JEPEREZ 21/08/2020. 
		continue foreach;		
	end if   
	
	if _cod_endomov in ('007','008','014','016','0','021','022','023','027','029','033','034')  then  -- JEPEREZ 09/09/2021.# 1483
		continue foreach;
	end if	

	let _no_poliza2 = sp_sis21(_no_documento);	

	select cod_contratante,
           vigencia_inic,
		   vigencia_final,
		   sucursal_origen,
		   cod_ramo,
		   leasing,
		   fecha_suscripcion
  	  into _cod_contratante,
	       _vigencia_inic,
		   _vigencia_final,
		   _sucursal,
		   _cod_ramo,
		   _leasing,
		   _fecha_added
  	  from emipomae
     where no_poliza = _no_poliza2;
	 
	 	if _fecha_added >= a_desde and _fecha_added <= a_hasta  then  --15112022
		else
			continue foreach;
		end if	 								   
	
	let _cod_acreedor = '';
	let _nom_acreedor = ''; 
	let _email = ''; 
	
  	if _sucursal = '010' then
		let _sucursal = '001';
	end if
		
	foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza2

		select nombre,email
		  into _nom_acreedor,_email
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
			   
		   select nombre,e_mail
			 into _nom_acreedor,_email
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

	select nombre, cedula
	  into _n_cliente, _cedula
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
   
   --LET _no_poliza = sp_sis21(_no_documento); 

	select nombre
	  into _n_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;   
	 
	select nombre
	  into _tipo_endoso
	  from endtimov
	 where cod_endomov = _cod_endomov;   

	if trim(_cod_acreedor) = ''  then --or _leasing <> 1
		continue foreach;
	end if
		
	insert into temp_acreedor
		values( _no_documento,   
		_n_ramo,
		_no_factura,   
		_n_cliente,
		_cedula,
		_n_corredor,
		_vigencia_inic,   
		_vigencia_final,
		_nom_acreedor,
		_cod_acreedor,
		_email,
		_tipo_endoso ,_no_poliza,_no_endoso
		);	

	   
end foreach
drop table if exists tmp_codigos;	

return 'Exito';
end procedure	