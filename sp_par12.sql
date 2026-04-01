-- Procedimiento para actualizar la suma y prima por unidad en el reaseguro
-- cuando se cambian los valores en emipocob
--
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par12;

CREATE PROCEDURE "informix".sp_par12(
a_poliza CHAR(10), 
a_endoso CHAR(5))
--RETURNING   INTEGER			 -- _error

DEFINE ls_contrato    CHAR(5);      
DEFINE ls_cober_reas  CHAR(5);      
DEFINE ls_unidad      CHAR(10);     
DEFINE li_orden       INTEGER;      
DEFINE _no_unidad     CHAR(5);      

DEFINE ld_suma        DECIMAL(16,2);
DEFINE ld_porc_suma   DECIMAL(16,2);
DEFINE ld_prima_rea   DECIMAL(16,2);

DEFINE ld_prima       DECIMAL(16,2);
DEFINE ld_porc_prima  DECIMAL(16,6);
DEFINE ld_suma_rea    DECIMAL(16,2);

DEFINE ld_porc_coaseg DECIMAL(16,4);
DEFINE ls_ase_lider   CHAR(3);
DEFINE _cod_compania  CHAR(3);
DEFINE ls_tipopro	  CHAR(3);
DEFINE li_tipopro	  INTEGER;

DEFINE _error         INTEGER;      
define _cantidad      integer;
DEFINE _serie         SMALLINT;
DEFINE _cod_ramo      CHAR(3);  
DEFINE _cod_ruta      CHAR(5);

BEGIN

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_par12.trc";      
--TRACE ON;                                                                     

LET	ld_prima_rea = 0.00;
LET	ld_suma_rea  = 0.00;
LET ld_prima     = 0.00;
LET ld_suma      = 0.00;
LET _error       = 0;

LET ld_porc_coaseg = 1;

Select cod_compania,
	   cod_tipoprod,
	   cod_ramo
  Into _cod_compania, 
  	   ls_tipopro,
	   _cod_ramo
  From emipomae
 Where no_poliza = a_poliza;

SELECT YEAR(vigencia_inic)
  INTO _serie
  FROM endedmae
 WHERE no_poliza = a_poliza
   AND no_endoso = a_endoso;

FOREACH
 SELECT cod_ruta
   INTO _cod_ruta
   FROM rearumae
  WHERE cod_ramo = _cod_ramo
    AND serie    = _serie
  ORDER BY cod_ruta
		EXIT FOREACH;
END FOREACH

Select tipo_produccion 
  Into li_tipopro
  From emitipro
 Where cod_tipoprod = ls_tipopro;

Select par_ase_lider 
  Into ls_ase_lider
  From parparam
 Where cod_compania = '001';

SELECT porc_partic_coas 
  Into ld_porc_coaseg
  FROM endcoama  
 WHERE no_poliza    = a_poliza
   AND no_endoso    = a_endoso
   AND cod_coasegur = ls_ase_lider;

IF ld_porc_coaseg IS NULL THEN
	LET ld_porc_coaseg = 100;
END IF

LET ld_porc_coaseg = ld_porc_coaseg / 100;

update emifacon 
   set prima     = 0
 WHERE no_poliza = a_poliza
   AND no_endoso = a_endoso;

FOREACH
 SELECT no_unidad,
        suma_asegurada
   INTO _no_unidad,
        ld_suma
   FROM endeduni
  WHERE no_poliza = a_poliza
    AND no_endoso = a_endoso

	LET ld_suma = ld_suma  * ld_porc_coaseg;

   foreach
	select sum(e.prima_neta),
	       cod_cober_reas
	  Into ld_prima,
	       ls_cober_reas
	  From endedcob	e, prdcober c
	 Where e.no_poliza      = a_poliza
	   And e.no_endoso      = a_endoso
	   And e.no_unidad      = _no_unidad
	   AND e.cod_cobertura  = c.cod_cobertura
	 group by cod_cober_reas

		LET ld_prima = ld_prima * ld_porc_coaseg;

		select count(*)
		  into _cantidad
		  from emifacon
		 where no_poliza 	  = a_poliza
		   and no_endoso      = a_endoso
		   and no_unidad 	  = _no_unidad
		   and cod_cober_reas = ls_cober_reas;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		if _cantidad = 0 then

			insert into emifacon
			select a_poliza,
			       a_endoso,
				   _no_unidad,
				   ls_cober_reas,
				   orden,
				   cod_contrato,
				   cod_ruta,
				   porc_partic_suma,
				   porc_partic_prima,
				   ((porc_partic_suma/100)  * ld_suma),
				   ((porc_partic_prima/100) * ld_prima)
			  from emigloco
			 where no_poliza = a_poliza
			   and no_endoso = a_endoso;

			select count(*)
			  into _cantidad
			  from emifacon
			 where no_poliza 	  = a_poliza
			   and no_endoso      = a_endoso
			   and no_unidad 	  = _no_unidad
			   and cod_cober_reas = ls_cober_reas;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			if _cantidad = 0 then
				
				if _cod_ramo = '018' then

					insert into emifacon
					select a_poliza,
					       a_endoso,
						   _no_unidad,
						   ls_cober_reas,
						   orden,
						   cod_contrato,
						   cod_ruta,
						   porc_partic_suma,
						   porc_partic_prima,
						   ((porc_partic_suma/100)  * ld_suma), 
						   ((porc_partic_prima/100) * ld_prima)
					  from rearucon
					 where cod_ruta = _cod_ruta;

				else
					insert into emifacon
					select a_poliza,
					       a_endoso,
						   _no_unidad,
						   ls_cober_reas,
						   orden,
						   cod_contrato,
						   cod_ruta,
						   porc_partic_suma,
						   porc_partic_prima,
						   ((porc_partic_suma/100)  * ld_suma),
						   ((porc_partic_prima/100) * ld_prima)
					  from emifacon
					 where no_poliza      = a_poliza
					   and no_endoso      = a_endoso
					   and no_unidad 	  = _no_unidad
					   and cod_cober_reas <> ls_cober_reas;
				end if

			end if

		else

			FOREACH
			 Select orden,
			        (emifacon.porc_partic_prima/100), 
			        (emifacon.porc_partic_prima/100)
			   Into li_orden,
			   		ld_porc_suma, 
			   		ld_porc_prima	  
			   from emifacon
			  Where no_poliza 	   = a_poliza
			    and no_endoso      = a_endoso
			    and no_unidad 	   = _no_unidad
				and cod_cober_reas = ls_cober_reas

				LET ld_prima_rea = ld_porc_prima * ld_prima;

				IF ld_prima_rea IS NULL THEN
					LET ld_prima_rea = 0;
				END IF

				Update emifacon
				   Set prima		  = ld_prima_rea
				 Where no_poliza      = a_poliza
				   And no_endoso      = a_endoso
				   And no_unidad	  = _no_unidad
				   And cod_cober_reas = ls_cober_reas
				   And orden          = li_orden;

				LET ld_prima_rea = 0.00;
				LET ld_suma_rea  = 0.00;

			END FOREACH

		end if

		Select sum(prima)
		  Into ld_prima_rea
		  from emifacon
		 Where no_poliza 	  = a_poliza
		   and no_endoso      = a_endoso
		   and no_unidad 	  = _no_unidad
		   and cod_cober_reas = ls_cober_reas;

		if ld_prima_rea <> ld_prima then

			let ld_prima_rea = ld_prima_rea - ld_prima;
			
			select min(orden)
			  Into li_orden
			  from emifacon
			 Where no_poliza 	  = a_poliza
			   and no_endoso      = a_endoso
			   and no_unidad 	  = _no_unidad
			   and cod_cober_reas = ls_cober_reas;

			Update emifacon
			   Set prima		  = prima - ld_prima_rea
			 Where no_poliza      = a_poliza
			   And no_endoso      = a_endoso
			   And no_unidad	  = _no_unidad
			   And cod_cober_reas = ls_cober_reas
			   And orden          = li_orden;
					
		end if

	end foreach

END FOREACH

foreach
 select no_unidad
   into	_no_unidad
   from	emifacon
  WHERE no_poliza = a_poliza
    AND no_endoso = a_endoso
  group by no_unidad

	select count(*)
	  into _cantidad
	  from endeduni
	 WHERE no_poliza = a_poliza
       AND no_endoso = a_endoso
	   and no_unidad = _no_unidad;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad = 0 then
		delete from emifacon
		 WHERE no_poliza = a_poliza
    	   AND no_endoso = a_endoso
	   	   and no_unidad = _no_unidad;
	end if

end foreach

--RETURN _error;

END

END PROCEDURE;