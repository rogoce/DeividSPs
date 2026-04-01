-- Procedumiento para actualizar la suma y prima por unidad en el reaseguro
-- cuando se cambian los valores en emipocob
--
-- Creado    : 23/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 23/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 28/05/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 11/01/2002 - Autor: Armando Moreno.  --
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe24;

CREATE PROCEDURE "informix".sp_proe24(a_poliza CHAR(10), a_unidad CHAR(10))
RETURNING   INTEGER			 -- _error

DEFINE ls_contrato    CHAR(5);      
DEFINE ls_cober_reas  CHAR(5);      
DEFINE ls_unidad      CHAR(10);     
DEFINE li_orden       INTEGER;      

DEFINE ld_suma        DECIMAL(16,2);
DEFINE ld_porc_suma   DECIMAL(16,4);
DEFINE ld_prima_rea   DECIMAL(16,2);

DEFINE ld_prima       DECIMAL(16,2);
DEFINE ld_porc_prima  DECIMAL(16,4);
DEFINE ld_suma_rea    DECIMAL(16,2);

DEFINE ld_porc_coaseg DECIMAL(16,4);
DEFINE ls_ase_lider   CHAR(3);
DEFINE _cod_compania  CHAR(3);
DEFINE ls_tipopro,ls_cob_rea	  CHAR(3);
DEFINE li_tipopro	  INTEGER;

DEFINE _error         INTEGER;      

BEGIN

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_proe23.trc";      
--TRACE ON;                                                                     

LET	ld_prima_rea = 0.00;
LET	ld_suma_rea  = 0.00;
LET ld_prima     = 0.00;
LET ld_suma      = 0.00;
LET _error       = 0;

LET ld_porc_coaseg = 1;

Select cod_compania,
	   cod_tipoprod
  Into _cod_compania, 
  	   ls_tipopro
  From emipomae
 Where no_poliza = a_poliza;

Select tipo_produccion 
  Into li_tipopro
  From emitipro
 Where cod_tipoprod = ls_tipopro;

If li_tipopro = 2 Then

	Select par_ase_lider 
	  Into ls_ase_lider
	  From parparam
	 Where cod_compania = _cod_compania;
 
	SELECT porc_partic_coas 
	  Into ld_porc_coaseg
	  FROM emicoama  
	 WHERE no_poliza    = a_poliza
	   AND cod_coasegur = ls_ase_lider;

	LET ld_porc_coaseg = ld_porc_coaseg / 100;

End If

Select suma_asegurada
  Into ld_suma
  From emipouni
 Where no_poliza = a_poliza
   And no_unidad = a_unidad;

FOREACH	
	Select Sum(e.prima_neta),
		   p.cod_cober_reas
	  Into ld_prima,
		   ls_cob_rea
	  From emipocob e, prdcober p
	 Where e.no_poliza = a_poliza
	   And e.no_unidad = a_unidad
	   And e.cod_cobertura = p.cod_cobertura
	 Group By p.cod_cober_reas


	LET ld_suma  = ld_suma  * ld_porc_coaseg;
	LET ld_prima = ld_prima * ld_porc_coaseg;

	FOREACH
		Select Distinct 
		       emifacon.orden, 
		       emifacon.cod_cober_reas, 
		       emifacon.cod_contrato,
		       (emifacon.porc_partic_suma), 
		       (emifacon.porc_partic_prima)
		  Into li_orden, 
		  	   ls_cober_reas, 
		  	   ls_contrato, 
		  	   ld_porc_suma, 
		  	   ld_porc_prima	  
		  from emifacon
		 Where emifacon.no_poliza 	   = a_poliza
		   and emifacon.no_endoso      = '00000'
		   and emifacon.no_unidad 	   = a_unidad
		   and emifacon.cod_cober_reas = ls_cob_rea
		   and (emifacon.porc_partic_prima > 0 OR 
		        emifacon.porc_partic_suma  > 0)

		LET ld_suma_rea  = ld_porc_suma  * ld_suma  / 100;
		LET ld_prima_rea = ld_porc_prima * ld_prima / 100;

		Update emifacon
		   Set suma_asegurada 	= ld_suma_rea,
		       prima			= ld_prima_rea
		 Where no_poliza    	= a_poliza
		   And no_endoso    	= '00000'
		   And no_unidad		= a_unidad
		   And cod_cober_reas	= ls_cober_reas
		   And orden        	= li_orden
		   And cod_contrato	    = ls_contrato;
			
		LET ld_prima_rea = 0.00;
		LET ld_suma_rea  = 0.00;

	END FOREACH
END FOREACH
RETURN _error;

END

END PROCEDURE;