-- Procedimiento que actualiza la division de cobros en polizas 
-- Creado     :	22/08/2011 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_armando4;
create procedure sp_armando4(a_no_documento char(20))
returning	integer,
			char(50);

define _error_desc		char(50);
define _cod_agente		char(10);
define _no_poliza		char(10);
define _cod_tipoprod	char(3);
define _cobra_poliza	char(1);
define _cod_formapag	char(3);
define _cod_cobrador	char(3);
define _cantidad,_cnt		integer;
define _error			integer;
define _error_isam		integer;
define _fronting		smallint;
define _dos_anos        date;

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_cob287.trc";
--trace on;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _cantidad = 0;

let _dos_anos = current - 2 units year;

foreach
	select no_poliza,
		   cod_formapag,
		   fronting,
		   cod_tipoprod
	  into _no_poliza,
		   _cod_formapag,
		   _fronting,
		   _cod_tipoprod
	  from emipomae
	 where actualizado = 1
	   and no_documento = a_no_documento
--	   and (estatus_poliza = 1
--	    or vigencia_inic >= _dos_anos)

	let _cantidad = _cantidad + 1;
	let _cnt   = 0;
	select count(*)
	  into _cnt
	  from emipoagt
	 where no_poliza  = _no_poliza;
	 
	if _cnt > 1 then
		foreach
			select e.cod_agente,a.cod_cobrador
			  into _cod_agente,_cod_cobrador
			  from emipoagt e, agtagent a
			 where e.cod_agente = a.cod_agente
			   and e.no_poliza  = _no_poliza
			 order by e.porc_partic_agt desc
			 
			if _cod_cobrador = '217' then
			else
				exit foreach;
			end if

		end foreach
	else
	    foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza  = _no_poliza
			 order by porc_partic_agt desc
			exit foreach;
		end foreach
	end if

	select cod_cobrador
	  into _cod_cobrador
	  from agtagent
	 where cod_agente = _cod_agente;

	select cobra_poliza
	  into _cobra_poliza
	  from cobdivco
	 where cod_formapag = _cod_formapag
	   and cod_cobrador = _cod_cobrador;

	if _cobra_poliza is null then
		let _cobra_poliza = "6";
	end if

	if _fronting =  1 and _cod_formapag <> "085" then

		let _cod_formapag = "085";
		let _cobra_poliza = "1";

		update emipomae
		   set cod_formapag = _cod_formapag
		 where no_poliza    = _no_poliza;
	end if

	if _fronting =  0 and _cod_formapag = "085" then

		let _cod_formapag = "006";
		let _cobra_poliza = "2";

	end if

	if _cod_cobrador = "217" and _cod_formapag = "008" then
		let _cod_formapag = "006";
		let _cobra_poliza = "2";

	end if

	-- Coaseguro Minoritario
	if _cod_tipoprod = "002" and _cod_formapag <> "084" then 

		let _cod_formapag = "084";
		let _cobra_poliza = "3";

	end if

	-- No es Coaseguro Minoritario
	if _cod_tipoprod <> "002" and _cod_formapag = "084"  then 

		let _cod_formapag = "006";
		let _cobra_poliza = "2";

	end if
end foreach
end

return 0, _cantidad || " " || _cod_agente;

end procedure;