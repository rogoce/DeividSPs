--Para reasegurar polizas grandes

DROP PROCEDURE sp_sis411bk;
CREATE PROCEDURE sp_sis411bk(a_no_poliza char(10), a_no_endoso char(10)) 
returning smallint;

define _no_documento	char(20);
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_emision	date;
define _cant_uni		integer;
define _porcentaje,_prima_neta		dec(16,2);
define _prima			dec(16,2);
define _suma_asegurada  dec(16,2);
define _error			integer;
define _no_unidad		char(5);
define _no_endoso		char(5);
define _no_endoso0		char(5);
define _cod_descuen		char(3);
define v_prima_uni    	dec(16,2);
define r_descripcion    char(50);

--set debug file to "sp_par32.trc";
--trace on;

{update emipomae
   set actualizado = 0
 where no_poliza = a_no_poliza;
}
let _prima_neta = 0.00;
let _error = 0;

foreach with hold 
	select no_unidad,suma_asegurada,prima_neta
	  into _no_unidad,_suma_asegurada,_prima_neta
	  from emipouni
	 where no_poliza = a_no_poliza
	   --and no_unidad > '00115'
	 
	{update emifacon
	   set suma_asegurada = _suma_asegurada,
	   porc_partic_suma = 100,
	   porc_partic_prima = 100,
	   prima = _prima_neta
	where no_poliza = a_no_poliza
	  and no_endoso = '00000'
	  and no_unidad = _no_unidad;}
	  
	--let _error = sp_proe04cam(a_no_poliza, _no_unidad, _suma_asegurada,'001'); --reaseguro
	let _error = sp_proe04xx(a_no_poliza, _no_unidad, _suma_asegurada,'001');	 --reaseguro
	--let _error = sp_proe04amm(a_no_poliza, _no_unidad, _suma_asegurada,'001');	 --reaseguro para usarse con poliza 1610-00462-01
	--let _error = sp_proe03(a_no_poliza,'001');								 --emipomae

--	call sp_pro462a(a_no_poliza, '00000', _no_unidad) RETURNING	_error, r_descripcion, v_prima_uni, v_prima_uni, v_prima_uni, v_prima_uni, v_prima_uni,
--																v_prima_uni, v_prima_uni, v_prima_uni, v_prima_uni;

end foreach

--call sp_pro4611a(a_no_poliza,'00000') RETURNING _error,r_descripcion,v_prima_uni,v_prima_uni,v_prima_uni,v_prima_uni,v_prima_uni,v_prima_uni,v_prima_uni, 
--												  v_prima_uni,v_prima_uni;

let _error = sp_proe03(a_no_poliza,'001');								     --emipomae

{update endedmae
   set sac_asientos = 0
 where no_poliza = a_no_poliza
   and no_endoso = '00000';

update sac999:reacomp
   set sac_asientos = 0
 where no_poliza = a_no_poliza
   and no_endoso = '00000';
}
--Esto es para endosos
{foreach with hold
	select no_unidad,suma_asegurada
	  into _no_unidad,_suma_asegurada
	  from endeduni
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   and no_unidad > '00031'

	--let _error = sp_proe04bb(a_no_poliza, _no_unidad, _suma_asegurada,a_no_endoso);
	let _error = sp_proe04b_am(a_no_poliza, _no_unidad, _suma_asegurada,a_no_endoso);

end foreach}

return _error;									   

END PROCEDURE 									   
