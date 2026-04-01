-- Reporte de Totales de Cuentas para una Remesa
-- 
-- Creado    : 30/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_rem_consulta_asientos - DEIVID, S.A.

drop procedure sp_cob227;

create procedure "informix".sp_cob227(a_compania char(3), a_remesa char(10))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  DATE,		 -- Fecha
		  CHAR(7),	 -- Periodo
		  CHAR(50),	 -- Compania
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  char(10);

define v_cuenta			 char(25);
define v_nombre_cuenta   char(50);
define v_monto           dec(16,2);
define v_debito          dec(16,2);
define v_credito         dec(16,2);
define v_fecha           date;
define v_periodo		 char(7);
define v_compania_nombre char(50); 

define _cod_auxiliar	 char(5);
define _nombre_auxiliar	 char(50);
define _debito_aux       dec(16,2);
define _credito_aux      dec(16,2);
define _cta_auxiliar	 char(1);
define _tipo_cta		 char(1);
define _actualizado 	 smallint;

define _error			 integer;
define _error_desc   	 char(50);
define _tipo_remesa      char(1);

-- Nombre de la Compania

set isolation to dirty read;

let  v_compania_nombre = sp_sis01(a_compania); 
let _error = 0;

-- Lectura de la Tabla de Remesas

select fecha,
	   periodo,
	   actualizado,
	   tipo_remesa
  into v_fecha,
	   v_periodo,
	   _actualizado,
	   _tipo_remesa
  from cobremae
 where no_remesa = a_remesa;	   	

if _actualizado = 0 then

	call sp_par203z(a_remesa) returning _error, _error_desc;

end if


foreach
 
 select sum(debito),
 		sum(credito),
		cuenta
   into	v_debito,
        v_credito,
		v_cuenta	 		
   from cobasien
  where no_remesa = a_remesa
  group by cuenta
  order by cuenta

	let v_monto = v_debito - v_credito;

	if v_monto > 0 then
		let _tipo_cta = "D";
	else
		let _tipo_cta = "C";
	end if

	if _tipo_remesa = "B" then --tipo coas. minoritario
	else
		let v_debito  = 0;
		let v_credito = 0;

		if _tipo_cta = "D" then
			let v_debito  = v_monto;
		else
			let v_credito = v_monto * -1;
		end if
	end if

	select cta_nombre,
	       cta_auxiliar
	  into v_nombre_cuenta,
	       _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = v_cuenta;

	return v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_fecha,          
		   v_periodo,		
		   v_compania_nombre,
		   null,
		   null,
		   _tipo_cta,
		   a_remesa
		   with resume;	 	
	{		   
	if _cta_auxiliar is null then
		let _cta_auxiliar = "S";
	end if

	if _cta_auxiliar = "S" then

		foreach
		 select cod_auxiliar,
		        sum(debito),
			    sum(credito)
		   into _cod_auxiliar,
		        _debito_aux,
			    _credito_aux
		   from cobasiau
		  where no_remesa = a_remesa
		    and cuenta    = v_cuenta
		  group by cod_auxiliar 	
		  order by cod_auxiliar 	

			select ter_descripcion
			  into _nombre_auxiliar
			  from cglterceros
			 where ter_codigo = _cod_auxiliar;
		
			RETURN _cod_auxiliar,			
				   _nombre_auxiliar,  
				   null,         
				   null,        
				   v_fecha,          
				   v_periodo,		
				   v_compania_nombre,
				   _debito_aux,
				   _credito_aux
				   WITH RESUME;	 		
	
		end foreach

	end if 
	}

end foreach

if _actualizado = 0 then

	delete from cobasiau where no_remesa = a_remesa;
	delete from cobasien where no_remesa = a_remesa;

end if

if _error <> 0 then

	let _tipo_cta = "D";
	let v_cuenta  = _error;

	return v_cuenta,			
		   _error_desc,  
		   0.00,         
		   0.00,        
		   v_fecha,          
		   v_periodo,		
		   v_compania_nombre,
		   null,
		   null,
		   _tipo_cta,
		   a_remesa
		   with resume;	 	

end if

end procedure;
