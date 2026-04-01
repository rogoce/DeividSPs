-- Procedimiento que determina los valores para los deducibles para pasar a BO para el analisis de Deducibles

-- Creado    : 18/04/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo024;

CREATE PROCEDURE "informix".sp_bo024()
returning integer,
          char(50);

define _no_tranrec			char(10);
define _cod_cobertura		char(5);
define _cod_concepto		char(3);

define _monto				dec(16,2);
define _deduc_asegurado		dec(16,2);	
define _deduc_taller		dec(16,2);
define _deduc_descontado	dec(16,2);
define _deduc_devuelto		dec(16,2);

delete from deivid_bo:recdedco;

set isolation to dirty read;

-- Deducibles pagados por el cliente en caja

foreach
 select no_tranrec
   into _no_tranrec
   from rectrmae
  where cod_compania matches "*"
    and actualizado  = 1
    and cod_tipotran = "007"
    and periodo      matches "*"

	foreach
	 select cod_cobertura,
	        monto
	   into _cod_cobertura,
	        _monto
	   from rectrcob
	  where no_tranrec = _no_tranrec

		insert into deivid_bo:recdedco(
		no_tranrec,
		cod_cobertura,
		deduc_asegurado,
		deduc_taller,
		deduc_descontado,
		deduc_devuelto,
		deduc_pagado
		) 
		values(
		_no_tranrec, 
		_cod_cobertura, 
		0.00, 
		0.00, 
		0.00, 
		0.00,
		_monto
		);

	end foreach

end foreach

-- Deducibles relacionados con los pagos

foreach
 select no_tranrec
   into _no_tranrec
   from rectrmae
  where cod_compania matches "*"
    and actualizado  = 1
    and cod_tipotran = "004"
    and periodo      matches "*"

	let _cod_cobertura = null;

	foreach
	 select cod_cobertura
	   into _cod_cobertura
	   from rectrcob
	  where no_tranrec = _no_tranrec
	    and monto      <> 0
		exit foreach;
	end foreach

	if _cod_cobertura is null then

		foreach
		 select cod_cobertura
		   into _cod_cobertura
		   from rectrcob
		  where no_tranrec = _no_tranrec
			exit foreach;
		end foreach

	end if

	-- Cobertura Otros para cuando No Encuentra Cobertura
	
	if _cod_cobertura is null then
		let _cod_cobertura = "00105"; 
	end if
 
	insert into deivid_bo:recdedco(
	no_tranrec,
	cod_cobertura,
	deduc_asegurado,
	deduc_taller,
	deduc_descontado,
	deduc_devuelto,
	deduc_pagado
	) 
	values(
	_no_tranrec, 
	_cod_cobertura, 
	0.00, 
	0.00, 
	0.00, 
	0.00,
	0.00
	);

	foreach
	 select cod_concepto,
	        monto
	   into _cod_concepto,
	        _monto
	   from rectrcon
	  where no_tranrec   = _no_tranrec
	    and cod_concepto in ("004", "005", "006", "008")

		let _deduc_asegurado  = 0.00;   	
		let _deduc_taller	  = 0.00;	   
		let _deduc_descontado = 0.00;  
		let _deduc_devuelto	  = 0.00;	   

		if _cod_concepto = "004" then
			let _deduc_asegurado  = _monto;   	
		elif _cod_concepto = "005" then
			let _deduc_taller	  = _monto;	   
		elif _cod_concepto = "006" then
			let _deduc_descontado = _monto; 
		elif _cod_concepto = "008" then
			let _deduc_devuelto	  = _monto;   
		end if

		update deivid_bo:recdedco
		   set deduc_asegurado  = deduc_asegurado  + _deduc_asegurado,
			   deduc_taller     = deduc_taller     + _deduc_taller,
			   deduc_descontado = deduc_descontado + _deduc_descontado,
			   deduc_devuelto   = deduc_devuelto   + _deduc_devuelto
	     where no_tranrec       = _no_tranrec
		   and cod_cobertura    = _cod_cobertura;

	end foreach

end foreach

return 0, "Actualizacion Exitosa";

end procedure
