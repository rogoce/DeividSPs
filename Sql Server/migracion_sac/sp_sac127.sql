drop procedure sp_sac127;

create procedure sp_sac127(
a_ano				smallint,
_cuenta_presupuesto	char(25),
_cuenta_suscrita	char(25),
_porc_individual	dec(16,2)
) returning integer,
            char(50);

define _ccosto	 char(3);
define _periodo	 smallint;
define _montomes dec(16,2);
define _cantidad smallint;

if _porc_individual = 0 then 
	return 0, "Actualizacion Exitosa";
end if
 
if _cuenta_presupuesto[1,3]	= "412" then

	select count(*)
	  into _cantidad
	  from sac001:cglcuentas
	 where cta_cuenta = _cuenta_presupuesto;

else

	select count(*)
	  into _cantidad
	  from sac:cglcuentas
	 where cta_cuenta = _cuenta_presupuesto;

end if

if _cantidad = 0 then
	return 1, "No Existe Cuenta " || _cuenta_presupuesto;
end if

foreach 
 select pre2_ccosto,
        pre2_periodo,
		pre2_montomes
   into _ccosto,
        _periodo,
		_montomes
   from sac:cglpre02
  where pre2_ano    = a_ano
    and pre2_cuenta = _cuenta_suscrita

	select count(*)
	  into _cantidad
	  from sac:cglpre01
	 where pre1_ano    = a_ano
	   and pre1_cuenta = _cuenta_presupuesto
	   and pre1_ccosto = _ccosto;

	if _cantidad = 0 then
		insert into sac:cglpre01
		values (a_ano, _cuenta_presupuesto, _ccosto, today, 0.00, "informix");
	end if

	let _montomes = _montomes * _porc_individual / 100;

	if _cuenta_presupuesto[1,1] = 5 or
	   _cuenta_presupuesto[1,1] = 6 then

		let _montomes = _montomes * - 1;

	end if

	insert into sac:cglpre02
	values (a_ano, _cuenta_presupuesto, _ccosto, _periodo, _montomes, 0.00);

end foreach      

return 0, "Actualizacion Exitosa";

end procedure
