-- Procedimiento que muestra la ultima Distribucion de Reaseguro Individual para contratos Facultativos--
-- Creado:     27/01/2012 - Autor Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro357;
create procedure "informix".sp_pro357(a_no_poliza char(10), a_no_unidad char(5),a_cod_cober_reas char(3),a_orden smallint, a_cod_contrato char(5))
returning   char(10),		--a_no_poliza,
			char(5),		--_no_endoso
			char(5),		--a_no_unidad,
			char(3),		--a_cod_cober_reas,
			smallint,		--a_orden,
			char(5),		--a_cod_contrato,	
			char(3),		--_cod_coasegur,
			decimal(9,6),	--_porc_partic_reas,
			decimal(7,4),	--_porc_comis_fac,	
			decimal(5,2),	--_porc_impuesto,
			decimal(16,2),	--_suma_asegurada,
			decimal(16,2),	--_prima,
			smallint,		--_impreso
			date,			--_fecha_impresion,
			char(10)		--_no_cesion

define _no_endoso			char(5);
define _cod_coasegur		char(3);
define _no_cesion			char(10);
define _prima		   		decimal(16,2);
define _suma_asegurada		decimal(16,2);
define _prima_tot	   		decimal(16,2);
define _suma_asegurada_tot	decimal(16,2);
define _porc_partic_reas	decimal(9,6);
define _porc_comis_fac		decimal(7,4);
define _porc_impuesto		decimal(5,2);
define _impreso				smallint;
define _no_cambio			smallint;
define _fecha_impresion		date;

set isolation to dirty read;

let	_prima_tot 			= 0;
let _suma_asegurada_tot	= 0;


select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

foreach
	select porc_partic_reas,
		   porc_comis_fac,
		   porc_impuesto,
		   cod_coasegur
	  into _porc_partic_reas,
		   _porc_comis_fac,
		   _porc_impuesto,		   
		   _cod_coasegur
	  from emireafa
	 where no_poliza 		= a_no_poliza
	   and no_unidad 		= a_no_unidad
	   and no_cambio 		= _no_cambio
	   and cod_cober_reas	= a_cod_cober_reas
	   and orden			= a_orden
	   and cod_contrato		= a_cod_contrato

	
{	select sum(suma_asegurada),
	 	   sum(prima)
	  into _suma_asegurada,
	 	   _prima
	  from emifafac
	 where no_poliza 		= a_no_poliza
	   and no_unidad 		= a_no_unidad
	   and no_cambio 		= _no_cambio
	   and cod_cober_reas	= a_cod_cober_reas
	   and cod_contrato		= a_cod_contrato}

	foreach
		select impreso,
			   fecha_impresion,
			   no_cesion,
			   no_endoso,
			   suma_asegurada,
			   prima
		  into _impreso,
			   _fecha_impresion,
			   _no_cesion,
			   _no_endoso,
			   _suma_asegurada,
			   _prima
		  from emifafac
		 where no_poliza 		= a_no_poliza
		   and no_unidad 		= a_no_unidad
		   and cod_cober_reas	= a_cod_cober_reas
		   and cod_contrato		= a_cod_contrato
		   and orden			= a_orden
		 order by no_endoso asc

		let	_prima_tot 			= _prima_tot + _prima;
		let _suma_asegurada_tot	= _suma_asegurada_tot + _suma_asegurada; 

	end foreach

	return a_no_poliza,
		   _no_endoso,
		   a_no_unidad,
		   a_cod_cober_reas,
		   a_orden,
		   a_cod_contrato,	
		   _cod_coasegur,
		   _porc_partic_reas,
		   _porc_comis_fac,	
		   _porc_impuesto,
		   _suma_asegurada_tot,
		   _prima_tot,
		   _impreso,
		   _fecha_impresion,
		   _no_cesion with resume;

end foreach
end procedure;
