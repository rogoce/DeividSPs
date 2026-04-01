-- Reporte de los asientos para los cambios de contrato

-- Creado    : 22/01/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac238;

create procedure sp_sac238()
returning char(25),
          char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50),
		  char(7);

define _no_poliza			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_remesa			char(10);
define _no_registro		char(10);
define _renglon			integer;
define _no_endoso			char(5);
define _periodo			char(7);
define _periodo2			char(7);

define v_cuenta			char(25);	
define v_debito     		dec(16,2);
define v_credito    		dec(16,2);
define v_debito_2   		dec(16,2);
define v_credito_2  		dec(16,2);
define _diferencia  		dec(16,2);
define _diferencia2 		dec(16,2);
define v_tipo_comp			smallint;

define _origen      		smallint;

define v_comprobante  	char(50);
define v_nombre_cuenta	char(50);
define _cta_auxiliar		char(1);
define _cod_auxiliar		char(5);
define _nom_auxiliar		char(50);

create temp table tmp_comp_prod_50_50(
origen			 	smallint,
tipo_comprobante 	smallint,
periodo			 	char(7),
cuenta		   	 	char(25),
debito_1      	 	decimal(16,2) default 0,
credito_1	     	decimal(16,2) default 0,
debito_2      	 	decimal(16,2) default 0,
credito_2	     	decimal(16,2) default 0
) with no log;

create temp table tmp_comp_prod2_50_50(
origen			 	smallint,
tipo_comprobante	smallint,
periodo			 	char(7),
cuenta		   	 	char(25),
cod_auxiliar	 	char(5),
debito_1      	 	decimal(16,2) default 0,
credito_1	     	decimal(16,2) default 0,
debito_2      	 	decimal(16,2) default 0,
credito_2	     	decimal(16,2) default 0
) with no log;

set isolation to dirty read;

-- Cuentas

foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        sum(debito), 
        sum(credito)
   into _periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        v_debito, 
        v_credito
   from deivid:tmp_prod_50_50
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	insert into tmp_comp_prod_50_50(
	origen,
	tipo_comprobante,
	periodo,
	cuenta,   
	debito_1,	  
    credito_1
	)
	values(
	_origen,
	v_tipo_comp,
	_periodo,
	v_cuenta,  
	v_debito,
	v_credito
	);

end foreach

--{
foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        sum(debito), 
        sum(credito)
   into _periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        v_debito, 
        v_credito
   from deivid_tmp:tmp_prod_50_50
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	insert into tmp_comp_prod_50_50(
	origen,
	tipo_comprobante,
	periodo,
	cuenta,   
	debito_2,	  
    credito_2
	)
	values(
	_origen,
	v_tipo_comp,
	_periodo,
	v_cuenta,  
	v_debito,
	v_credito
	);

end foreach
--}

-- Auxiliares

foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        cod_auxiliar,
        sum(debito),
		sum(credito)
   into	_periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        _cod_auxiliar,
        v_debito,
		v_credito
   from deivid:tmp_prod2_50_50 
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	insert into tmp_comp_prod2_50_50(
	origen,
	tipo_comprobante,
	periodo,
	cuenta,
	cod_auxiliar,   
	debito_1,	  
    credito_1
	)
	values(
	_origen,
	v_tipo_comp,
	_periodo,
	v_cuenta,
	_cod_auxiliar,  
	v_debito,
	v_credito
	);

end foreach

--{
foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        cod_auxiliar,
        sum(debito),
		sum(credito)
   into	_periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        _cod_auxiliar,
        v_debito,
		v_credito
   from deivid_tmp:tmp_prod2_50_50 
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	insert into tmp_comp_prod2_50_50(
	origen,
	tipo_comprobante,
	periodo,
	cuenta,
	cod_auxiliar,   
	debito_2,	  
    credito_2
	)
	values(
	_origen,
	v_tipo_comp,
	_periodo,
	v_cuenta,
	_cod_auxiliar,  
	v_debito,
	v_credito
	);

end foreach
--}

-- Reporte

foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        sum(debito_1), 
        sum(credito_1),
        sum(debito_2), 
        sum(credito_2)
   into _periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        v_debito, 
        v_credito,
        v_debito_2, 
        v_credito_2
   from tmp_comp_prod_50_50
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	let _diferencia  = v_debito   - v_credito;
	let _diferencia2 = v_debito_2 - v_credito_2;

	select cta_nombre,
	       cta_auxiliar
	  into v_nombre_cuenta,
	       _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = v_cuenta;
		
	let v_comprobante = sp_sac11(_origen, v_tipo_comp); 

	return v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   _diferencia,
		   v_debito_2,
		   v_credito_2,
		   _diferencia2,
		   null,         
		   null,        
		   null,
		   null,         
		   v_comprobante,
		   _periodo
		   with resume;

	foreach
	 select cod_auxiliar,
	        sum(debito_1),
			sum(credito_1),
	        sum(debito_2),
			sum(credito_2)
	   into	_cod_auxiliar,
	        v_debito,
			v_credito,
	        v_debito_2,
			v_credito_2
	   from tmp_comp_prod2_50_50 
	  where	origen			 	= _origen
        and tipo_comprobante 	= v_tipo_comp
        and periodo			= _periodo
        and cuenta		   	 	= v_cuenta
	  group by cod_auxiliar

		select ter_descripcion
		  into _nom_auxiliar
		  from cglterceros
		 where ter_codigo = _cod_auxiliar;

		return _cod_auxiliar,			
			   _nom_auxiliar,  
			   null,         
			   null,        
			   null,
			   null,         
			   null,        
			   null,
			   v_debito,
			   v_credito,
			   v_debito_2,
			   v_credito_2,
			   v_comprobante,
			   _periodo
			   with resume;

	end foreach

end foreach

drop table tmp_comp_prod_50_50;
drop table tmp_comp_prod2_50_50;

end procedure 