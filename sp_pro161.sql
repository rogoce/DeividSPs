

drop procedure sp_pro161;

create procedure "informix".sp_pro161()
returning smallint,
          char(50);

define _no_poliza	char(10);
define _no_unidad	char(5);
define _no_endoso	char(5);
define _cantidad	smallint;
define _cuenta		smallint;

let _no_poliza = "187421";
let _cuenta    = 0;

foreach
 select no_endoso,
        no_unidad
   into _no_endoso,
        _no_unidad
   from endeduni
  where no_poliza = _no_poliza

	select count(*)
	  into _cantidad
	  from endedcob
	 where no_poliza     = _no_poliza
	   and no_endoso     = _no_endoso
	   and no_unidad     = _no_unidad
	   and cod_cobertura = "00452";

	if _cantidad <> 0 then
		continue foreach;
	end if

	let _cuenta = _cuenta + 1;

	insert into endedcob
	select
	no_poliza,
	no_endoso,
	no_unidad,
	"00452",
	5,
	tarifa,
	deducible,
	limite_1,
	limite_2,
	prima_anual,
	prima,
	descuento,
	recargo,
	prima_neta,
	date_added,
	date_changed,
	desc_limite1,
	desc_limite2,
	factor_vigencia,
	opcion
	 from endedcob
	where no_poliza     = _no_poliza
	  and no_endoso     = _no_endoso
	  and no_unidad     = _no_unidad
	  and cod_cobertura = "00481";

end foreach

{
foreach
 select no_unidad
   into _no_unidad
   from emipouni
  where no_poliza = _no_poliza

	select count(*)
	  into _cantidad
	  from emipocob
	 where no_poliza     = _no_poliza
	   and no_unidad     = _no_unidad
	   and cod_cobertura = "00452";

	if _cantidad <> 0 then
		continue foreach;
	end if

	let _cuenta = _cuenta + 1;

	insert into emipocob
	select no_poliza,
	no_unidad,
	"00452",
	5,
	tarifa,
	deducible,
	limite_1,
	limite_2,
	prima_anual,
	prima,
	descuento,
	recargo,
	prima_neta,
	date_added,
	date_changed,
	factor_vigencia,
	desc_limite1,
	desc_limite2,
	prima_vida,
	prima_vida_orig
	 from emipocob
	where no_poliza     = _no_poliza
	  and no_unidad     = _no_unidad
	  and cod_cobertura = "00473";

end foreach
}

return _cuenta, " Registros procesados";

end procedure