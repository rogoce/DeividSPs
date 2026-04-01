-- Procedimiento que muestra la informacio de la no facturacion de salud para auditoria

-- Creado Por: Demetrio Hurtado Almanza

drop procedure sp_aud31;

create procedure "informix".sp_aud31(a_ano char(4))
returning char(20),
          char(7),
		  char(50),
		  char(50),
		  char(30),
		  smallint,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  date,
		  dec(16,2),
		  dec(16,2);

define _no_documento	char(20);
define _razon			char(50);

define _no_poliza		char(10);
define _no_reclamo		char(10);
define _no_unidad		char(5);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _cod_cliente		char(10);
define _periodo			char(7);

define _nombre_subramo	char(50);
define _cedula			char(30);
define _fecha_nac		date;
define _edad			smallint;
define _prima_neta_m	dec(16,2);
define _prima_neta_a	dec(16,2);
define _suma_asegurada	dec(16,2);
define _monto			dec(16,2);
define _siniestros		dec(16,2);
define _prima_pagada	dec(16,2);

foreach
 select no_documento,
        razon,
		periodo
   into _no_documento,
        _razon,
		_periodo
   from prdsalex
  where periodo[1,4] = a_ano
--    and periodo = "2012-09"

	let _no_poliza = sp_sis21(_no_documento);

	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
		
	-- Siniestros Pagados

	let _siniestros = 0.00;

	foreach
	 select no_reclamo
	   into _no_reclamo
	   from recrcmae
	  where	no_poliza = _no_poliza

		foreach
		 select monto
		   into _monto
		   from rectrmae
		  where	no_reclamo   = _no_reclamo
		    and cod_tipotran = "004"
			and actualizado  = 1
			and periodo[1,4] >= "2009"
			and periodo[1,4] <= "2012"

			let _siniestros = _siniestros + _monto;

		end foreach

	end foreach

	-- Prima Pagada

	select sum(monto)
	  into _prima_pagada
	  from cobredet
	 where no_poliza    = _no_poliza
	   and tipo_mov     in ("P", "N")
	   and actualizado  = 1
	   and periodo[1,4] >= "2009"
	   and periodo[1,4] <= "2012";

	foreach
	 select cod_asegurado,
	        suma_asegurada,
			prima_asegurado,
			no_unidad
	   into _cod_cliente,
	        _suma_asegurada,
			_prima_neta_m,
			_no_unidad
	   from emipouni
	  where no_poliza = _no_poliza

		select cedula,
		       fecha_aniversario
		  into _cedula,
		       _fecha_nac
		  from cliclien
		 where cod_cliente = _cod_cliente; 	
		 
		let _edad = sp_sis78(_fecha_nac);		  
	  
		let _prima_neta_a = _prima_neta_m * 12;

		return _no_documento,
		       _periodo,
			   _razon,
		       _nombre_subramo,
		       _cedula,
			   _edad,
			   _prima_neta_m, 
			   _prima_neta_a,
			   _suma_asegurada,
			   _fecha_nac,
			   _siniestros,
			   _prima_pagada
			   with resume;

	end foreach 	
	

end foreach

end procedure