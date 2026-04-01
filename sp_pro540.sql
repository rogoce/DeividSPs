-- Procedure que crea el nuevo ramo de automovil flotas

-- Creado    : 02/06/2014 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_pro540;

create procedure "informix".sp_pro540()
returning integer,
		  char(100);

define _cod_cobertura		char(5);
define _cod_cober_flotas	char(5);
define _cod_cober_reas		char(3);
define _cod_cober_reas_flot	char(3);

define _cod_ramo			char(3);
define _cod_subramo			char(3);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

begin work;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

let _cod_ramo = "023";

foreach
 select cod_cobertura,
        cod_cober_reas
   into _cod_cobertura,
        _cod_cober_reas
   from prdcober
  where cod_cobertura in ("00102", "00103", "00104", "00107", "00108", "00113", "00117", "00118", "00119", "00120", "00123", "00907", "00901", "00902", "00903", "00904", "01145")

	let _cod_cober_flotas = sp_sis13("001", "PAR", "02", "par_cob_ramo");

	if _cod_cober_reas = "002" then
		let _cod_cober_reas_flot = "033";
	else
		let _cod_cober_reas_flot = "034";
	end if
	 
	insert into prdcober
	select _cod_cober_flotas,
		   "023",
		   _cod_cober_reas_flot,
		   nombre,
		   desc_limite1,
		   desc_limite2,
		   "informix",
		   today,
		   causa_siniestro,
		   relac_inundacion
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	insert into deivid_tmp:tmp_cober_flotas
	values (_cod_cobertura, _cod_cober_reas_flot);

end foreach

-- Impuestos por Subramo

foreach 
 select cod_subramo
   into _cod_subramo
   from prdsubra
  where cod_ramo = _cod_ramo

	insert into prdimsub
	values (_cod_ramo, _cod_subramo, "001");

	insert into prdimsub
	values (_cod_ramo, _cod_subramo, "002");

end foreach

end

--rollback work;
commit work;

return 0, "Actualizacion Exitosa";

end procedure 
