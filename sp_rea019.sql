-- Verificacion de reacomp vs produccion
--
-- Creado    : 06/08/2010 - Autor: Demetrio Hurtado Almanza
--
drop procedure sp_rea019;

create procedure "informix".sp_rea019() 
returning char(20),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  smallint,
		  dec(16,6);

define _no_poliza		char(10);
define _no_endoso		char(5);
define _periodo			char(7);
define _monto_reas		dec(16,2);
define _monto_prod		dec(16,2);

define _no_registro		char(10);

define _cantidad		smallint;
define _cod_ramo		char(3);
define _porc_partic		dec(16,6);
define _no_50			smallint;
define _no_unidad		char(5);

set isolation to dirty read; 

let _periodo = "2010-07";

foreach
 select no_poliza,
        no_endoso,
		no_registro
   into _no_poliza,
        _no_endoso,
		_no_registro
   from sac999:reacomp
  where tipo_registro = 1
    and periodo       = _periodo

	select cod_ramo 
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo not in ("002", "020") then
		continue foreach;
	end if

	select sum(debito - credito)
	  into _monto_reas
	  from sac999:reacompasie
	 where no_registro = _no_registro
	   and cuenta like "511%";

	if _monto_reas is null then
		let _monto_reas = 0;
	end if

	select sum(e.prima),
	       sum(porc_partic_prima)
	  into _monto_prod,
	       _porc_partic
	  from emifacon e, reacomae r
	 where e.no_poliza     = _no_poliza
	   and e.no_endoso     = _no_endoso
	   and e.cod_contrato  = r.cod_contrato
	   and r.tipo_contrato <> 1;

	if _monto_prod is null then
		let _monto_prod = 0;
	end if

{
	let _no_50 = 0;

   foreach	
	select sum(porc_partic_prima),
	       no_unidad
	  into _porc_partic,
	       _no_unidad
	  from emifacon e, reacomae r
	 where e.no_poliza     = _no_poliza
	   and e.no_endoso     = _no_endoso
	   and e.cod_contrato  = r.cod_contrato
	   and r.tipo_contrato <> 1
	 group by no_unidad

		if _porc_partic <> 50 then 
			let _no_50 = 1;
			exit foreach;
		end if
		
	end foreach
}

--	if _no_50 = 1 then 
--	if _monto_prod <> _monto_reas then

		select count(*)
		  into _cantidad
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		return _no_poliza,
		       _no_endoso,
			   _monto_reas,
			   _monto_prod,
			   _cantidad,
			   _porc_partic
			   with resume;

--	end if

end foreach

end procedure;
