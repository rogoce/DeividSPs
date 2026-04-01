-- Procedimiento que genera los registros contables de las incobrables
-- 
-- Creado     : 24/10/2002 - Autor: Marquelda Valdelamar
-- Modificado :	27/10/2002 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par127;		

CREATE PROCEDURE "informix".sp_par127()
returning char(20),
          char(5),
          char(3),
          smallint,
          char(5),
          char(50),
		  dec(9,6),
		  dec(9,6);
          		  	
DEFINE _no_documento		CHAR(20); 
DEFINE _no_poliza       	CHAR(10); 
DEFINE _no_unidad       	CHAR(5); 
define _no_cambio			smallint;

define _cod_cober_reas		char(3);
define _orden				smallint;
define _cod_contrato		char(5);
define _porc_partic_suma	dec(9,6);
define _porc_partic_prima	dec(9,6);		
define _nombre_contrato		char(50);
define _cantidad			smallint;

foreach
 select no_documento
   into _no_documento
   from cobinc04

	let _no_poliza = sp_sis21(_no_documento);
	
	foreach
	 select no_unidad
	   into _no_unidad	 
	   from emipouni
	  where no_poliza = _no_poliza

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

{
		 select count(*)
		   into _cantidad	 
		   from emireaco
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
			and no_cambio = _no_cambio;

		if _cantidad = 0 then

			return _no_poliza,
			       _no_unidad,
				   "000",
				   0,
				   "00000",
				   "No Tiene Reaseguro",
				   0.00,
				   0.00
				   with resume;

		end if

		continue foreach;
}

{
		foreach
		 select cod_cober_reas,
				sum(porc_partic_suma),
				sum(porc_partic_prima)
		   into _cod_cober_reas,
				_porc_partic_suma,
				_porc_partic_prima
		   from emireaco
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
			and no_cambio = _no_cambio
		  group by 1

			if _porc_partic_suma  <> 100 or 
			   _porc_partic_prima <> 100 then

				return _no_poliza,
				       _no_unidad,
					   "000",
					   0,
					   "00000",
					   "No Tiene Reaseguro",
					   _porc_partic_suma,
					   _porc_partic_prima
					   with resume;

			end if

		end foreach

		continue foreach;
}

		foreach
		 select cod_cober_reas,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima
		   into _cod_cober_reas,
				_orden,
				_cod_contrato,
				_porc_partic_suma,
				_porc_partic_prima
		   from emireaco
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad
			and no_cambio = _no_cambio
		  order by 1, 2

			select nombre
			  into _nombre_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			return _no_documento,
			       _no_unidad,
				   _cod_cober_reas,
				   _orden,
				   _cod_contrato,
				   _nombre_contrato,
				   _porc_partic_suma,
				   _porc_partic_prima
				   with resume;

		end foreach

	end foreach

end foreach

end procedure