

-- Creado: 08/05/2013 - Autor: Armando Moreno M.

drop procedure sp_sis405a;
create procedure sp_sis405a()
returning decimal(16,2),decimal(16,2);
--returning smallint,decimal(16,2),decimal(16,2),smallint,decimal(16,2);


define _no_reclamo       char(10);
define _no_pagos         smallint;
define _pagos            smallint;
define _prima_bruta      dec(16,2);
define _pagado           dec(16,2);
define _pagado_neto,_siniestro2,_siniestro3     dec(16,2);
define _cant_pag,_pagos_faltan,_cnt3 smallint;
define _tipo_mov         	   char(1);

set isolation to dirty read;

let _siniestro2 = 0.00;
let _siniestro3 = 0.00;

foreach

	SELECT t.no_reclamo, t.pagado_neto
	  INTO _no_reclamo,_pagado_neto
	  FROM tmp_sinis t, reacomae r
	 where r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato not in ('3','1')
	   and r.serie = 2011
	   and t.cod_ramo in('001')

		select count(*)
		  into _cnt3 
		  from recrccob r, prdcober p
		 where r.cod_cobertura = p.cod_cobertura
	   	   and r.no_reclamo    = _no_reclamo
		   and p.relac_inundacion = 1;

	if _cnt3 > 0 then
		let _siniestro2 = _siniestro2 + _pagado_neto;
	end if

end foreach

foreach

	SELECT t.no_reclamo, t.pagado_neto
	  INTO _no_reclamo,_pagado_neto
	  FROM tmp_sinis t, reacomae r
	 where r.cod_contrato = t.cod_contrato
	   and t.seleccionado = 1
	   and t.tipo_contrato not in ('3','1')
	   and r.serie = 2011
	   and t.cod_ramo in('003')

		select count(*)
		  into _cnt3 
		  from recrccob r, prdcober p
		 where r.cod_cobertura = p.cod_cobertura
	   	   and r.no_reclamo    = _no_reclamo
		   and p.relac_inundacion = 1;

	if _cnt3 > 0 then
		let _siniestro3 = _siniestro3 + _pagado_neto;
	end if

end foreach


return _siniestro2,_siniestro3;

end procedure