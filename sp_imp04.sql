-- Procedimiento que muestra la ultima Distribucion de Reaseguro individual--
-- Creado:     27/01/2012 - Autor Roman Gordon

-- copia del sp_pro356 para la impresion Autor: Federico Coronado 14/12/2012
-- Adaptado para que el sistema lea desde las tablas de emision
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_imp04;
create procedure "informix".sp_imp04(a_no_poliza char(10), a_no_unidad char(5))
			returning   char(10),   
						char(5),
						char(3),
						char(5),
						decimal(10,4),
						decimal(10,4),
						decimal(16,2),
						decimal(16,2),
						smallint,
						smallint,
						char(25),
						char(25);

define _cod_cober_reas		char(3);
define _cod_contrato		char(5);
define _cod_ruta			char(5);
define _reacomae_nombre     char(25);
define _reacobre_nombre     char(25);
define _prima		   		decimal(16,2);
define _suma_asegurada		decimal(16,2);
define _porc_partic_prima	decimal(10,4);
define _porc_partic_suma	decimal(10,4);
define _orden				smallint;
define _no_cambio			smallint;
define _ajustar				smallint;

set isolation to dirty read;

select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

foreach
	select cod_cober_reas,
		   orden,
		   porc_partic_suma,
		   porc_partic_prima,
		   cod_contrato
	  into _cod_cober_reas,
		   _orden,
		   _porc_partic_suma,
		   _porc_partic_prima,
		   _cod_contrato
	  from emireaco
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad
	   and no_cambio = _no_cambio

	select sum(a.suma_asegurada),
		   sum(a.prima),
		   max(a.cod_ruta)
	  into _suma_asegurada,
		   _prima,
		   _cod_ruta
	  from emifacon a, endedmae	b
	 where a.no_poliza      = b.no_poliza
	   and a.no_endoso      = b.no_endoso
	   and b.actualizado    = 1
	   and a.no_poliza		= a_no_poliza
	   and a.no_unidad		= a_no_unidad
	   and a.cod_cober_reas	= _cod_cober_reas
	   and a.cod_contrato	= _cod_contrato;
	   
	SELECT reacomae.nombre
	into _reacomae_nombre
	from reacomae 
	where cod_contrato = _cod_contrato;
	
	SELECT reacobre.nombre
	into _reacobre_nombre
	from reacobre 
	where cod_cober_reas = _cod_cober_reas;

	return a_no_poliza,
		   a_no_unidad,
		   _cod_cober_reas,
		   _cod_contrato,
		   _porc_partic_suma,	
		   _porc_partic_prima,
		   _suma_asegurada,
		   _prima,
		   0,
		   _orden,
		   _reacomae_nombre,
           _reacobre_nombre	with resume;

end foreach
end procedure;