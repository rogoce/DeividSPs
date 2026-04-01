-- Creado    : 28/04/2009 - Autor: Armando Moreno M.
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro321bk;
CREATE PROCEDURE sp_pro321bk(a_no_poliza CHAR(10), a_no_poliza_ant CHAR(10))
RETURNING  INTEGER;
		   
DEFINE _asegurado        CHAR(100);
DEFINE _ld_saldo		 DECIMAL(16,2);
DEFINE _ld_prima_nueva 	 DECIMAL(16,2);
DEFINE _ld_prima_deduc	 DECIMAL(16,2);
DEFINE _ld_deduc_nuevo	 varchar(50); --DECIMAL(16,2);
DEFINE _ld_deduc_anter	 varchar(50); --DECIMAL(16,2);
DEFINE _ld_prima_anter	 DECIMAL(16,2);
DEFINE _ld_tarifa        DECIMAL(16,2);
DEFINE _ld_descuento     DECIMAL(16,2);
DEFINE _ld_sum_aseg_1    DECIMAL(16,2);
DEFINE _ld_sum_aseg_2	 DECIMAL(16,2);
DEFINE _ld_nuevo_deduc	 DECIMAL(16,2);
DEFINE _ld_limite_1      DECIMAL(16,2);
DEFINE _ld_limite_2      DECIMAL(16,2);
DEFINE _ld_porc_desc     DECIMAL(16,2);
DEFINE _ld_porc_depr     DECIMAL(16,2);
DEFINE _rec_ded_col      DECIMAL(16,2);
DEFINE _rec_ded_com		 DECIMAL(16,2);
DEFINE _ld_vig_inici     DATE;
DEFINE _ld_vig_final	 DATE;
DEFINE _filtros          CHAR(255);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_grupo        CHAR(5);
DEFINE _cod_contratante  CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_cobertura    CHAR(5);
DEFINE _cobertura        CHAR(100);
DEFINE _cod_acreedor     CHAR(5);
DEFINE _acreedor  	     CHAR(100);
DEFINE _no_unidad        CHAR(5);
DEFINE _no_documento     CHAR(20);
DEFINE _vigencia_inic    DATE;
DEFINE _vigencia_final   DATE;
DEFINE _no_motor         CHAR(30);
DEFINE _cod_marca        CHAR(5);
DEFINE _cod_prod	     CHAR(5);
DEFINE _tipo_rec_col     CHAR(1);
DEFINE _tipo_rec_com     CHAR(1);
DEFINE _uso_auto         CHAR(1);
DEFINE _ld_identrec    	 SMALLINT;
DEFINE _ld_orden         SMALLINT;
DEFINE _ld_rec_existe    SMALLINT;
DEFINE _fecha_aud1       DATE;
DEFINE _fecha_aud2       DATE;
DEFINE _acep_desc        SMALLINT;
DEFINE _ano_actual       SMALLINT;
DEFINE _resultado        INTEGER;
DEFINE _ano_auto         INTEGER;
DEFINE _valor            INTEGER;
DEFINE _ld_recargo		 DECIMAL(16,2);
DEFINE _factor_imp		 DECIMAL(5,2);
define _cod_impuesto     char(3);
define _monto_impuesto	 DECIMAL(16,2);
define _ld_prima_bruta   DECIMAL(16,2);
define _error            integer;
define _retorno          smallint;
define _vig_ini          date;
define _no_doc			 char(20);
define _vig_fin_otr		 date;
define _no_unidad_otr	 char(5);

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION


SET ISOLATION TO DIRTY READ;

--*********************inicializa las variables********************--

let _ano_actual = year(current);

LET _ld_saldo       = 00.00;
LET _ld_prima_nueva = 00.00;
LET _ld_prima_deduc = 00.00;
LET _ld_deduc_nuevo = 00.00;
LET _ld_deduc_anter = 00.00;
LET _ld_prima_anter = 00.00;
LET _ld_tarifa      = 00.00;
LET _ld_descuento   = 00.00;

LET _ld_sum_aseg_1  = 00.00;
LET _ld_sum_aseg_2  = 00.00;

LET _ld_nuevo_deduc = 00.00;

LET _ld_limite_1    = 00.00;
LET _ld_limite_2    = 00.00;  
LET _ld_porc_desc   = 00.00;
LET _ld_porc_depr   = 00.00;


LET _rec_ded_col    = 00.00;
LET _rec_ded_com    = 00.00;

LET _ld_identrec    = 0;
LET _ld_orden       = 0;
LET _ld_rec_existe  = 0;
let _ld_recargo     = 0;
LET _acep_desc      = 0;
let _monto_impuesto = 0;
let _ld_prima_bruta = 0;
let _no_doc			= null;
let	_vig_fin_otr	= null;	
let	_no_unidad_otr	= null;


--SET DEBUG FILE TO "sp_pro321.trc"; 
--TRACE ON;                                                                

SELECT cod_ramo, year(vigencia_inic),vigencia_inic
  INTO _cod_ramo, _ano_actual, _vig_ini
  FROM emipomae
 WHERE no_poliza = a_no_poliza;

FOREACH

    SELECT no_unidad
      INTO _no_unidad
      FROM emipouni
     WHERE no_poliza = a_no_poliza

    LET _ld_sum_aseg_2 = 00.00;

    SELECT suma_asegurada,
	       cod_producto
      INTO _ld_sum_aseg_2,
	       _cod_prod
      FROM emipouni
     WHERE no_poliza = a_no_poliza
       AND no_unidad = _no_unidad;

 	LET _ld_prima_nueva = 00.00;
	LET _ld_descuento   = 00.00;
	LET _ld_porc_depr   = 00.00;

    SELECT no_motor,
           uso_auto
   	  INTO _no_motor,
   	       _uso_auto
   	  FROM emiauto
     WHERE no_poliza = a_no_poliza
   	   AND no_unidad = _no_unidad;

	let _resultado = 0;

	Select ano_auto
	  Into _ano_auto
	  From emivehic
	 Where no_motor = _no_motor;

	let _resultado = _ano_actual - _ano_auto;

	if (_resultado <= 0) or (_resultado = 1) then
		let _resultado = 1;
	else
		let _resultado = _resultado + 1;
	end if

   --*** porcentaje de depreciacion
   let _retorno = sp_pro511(a_no_poliza_ant, _no_unidad, _cod_prod); --> Endoso Beneficio Ancon Plus, si retorna 1 no debe depreciar

   if _retorno = 0 then
	   SELECT porc_depre
	     INTO _ld_porc_depr
	  	 FROM emidepre
	 	WHERE uso_auto  = _uso_auto
	   	  AND _resultado between ano_desde and ano_hasta;
   else
	   LET _ld_porc_depr = 0;
   end if

	--******* Calcula la Nueva Suma Asegurada
	IF 	_ld_sum_aseg_2 IS NULL THEN
		LET _ld_sum_aseg_2  = 0;
	END IF

	LET _ld_sum_aseg_1 = _ld_sum_aseg_2 - (_ld_sum_aseg_2 *  (_ld_porc_depr/100));

	SELECT cod_marca
  	  INTO _cod_marca
  	  FROM emivehic
 	 WHERE no_motor = _no_motor;

	call sp_proe23(a_no_poliza,_no_motor,_vig_ini) RETURNING _error, _no_doc,_vig_fin_otr,_no_unidad_otr;	 --07/08/2013
	if _error <> 0 then
		return 3;
	end if

	FOREACH

	   SELECT cod_cobertura
	     INTO _cod_cobertura
	   	 FROM emipocob
	    WHERE no_poliza = a_no_poliza
	      AND no_unidad = _no_unidad

	    LET _ld_prima_deduc = 00.00;
	    LET _ld_prima_anter = 00.00;
	    LET _ld_deduc_nuevo = 00.00;
	    LET _ld_deduc_anter = 00.00;
	    LET _ld_limite_1    = 00.00;
	    LET _ld_limite_2    = 00.00;
		    	      	          	   
	   SELECT deducible,
	          prima_neta, 
	          limite_1,
	   	      limite_2,
			  orden
		 INTO _ld_deduc_anter,
	   	      _ld_prima_anter,
			  _ld_limite_1,
			  _ld_limite_2,
			  _ld_orden
		 FROM emipocob
	    WHERE no_poliza     = a_no_poliza
	      AND no_unidad     = _no_unidad
	      AND cod_cobertura = _cod_cobertura;

		if _ld_deduc_anter is null then
			let _ld_deduc_anter = 0;
		end if
		--//dos lineas quitar  Armando
		call sp_pro51t(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _ld_sum_aseg_1) returning _ld_tarifa;       --prima anual
		call sp_pro51e(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _ld_sum_aseg_1) returning _ld_prima_deduc;	--prima neta
	  	CALL sp_pro51u(a_no_poliza, _cod_prod, _cod_ramo, _no_unidad,  _cod_cobertura,  _cod_marca, _ld_sum_aseg_1, _ld_tarifa, _uso_auto) RETURNING _ld_deduc_nuevo;	--deducible
		
		IF _ld_deduc_nuevo = 00.00 or _ld_deduc_nuevo is null THEN
		   LET _ld_deduc_nuevo = _ld_deduc_anter;
		END IF
		   
	   {UPDATE emipocob
	   	  SET deducible   = _ld_deduc_nuevo
	    WHERE no_poliza     = a_no_poliza
	      AND no_unidad     = _no_unidad
	      AND cod_cobertura = _cod_cobertura;}
		  
		--//quitar este update y poner el de arriba Armando
		update emipocob
		   set deducible     = _ld_deduc_nuevo,
			   prima_neta    = _ld_prima_deduc,
			   limite_1	     = _ld_limite_1,
			   limite_2	     = _ld_limite_2,
			   prima_anual   = _ld_tarifa,
			   prima		 = _ld_tarifa
		 where no_poliza     = a_no_poliza
		   and no_unidad     = _no_unidad
		   and cod_cobertura = _cod_cobertura;

    END FOREACH

	select sum(prima),
	       sum(prima_neta),
		   sum(descuento),
		   sum(recargo)
	  into _ld_tarifa,
		   _ld_prima_deduc,
		   _ld_descuento,
		   _ld_recargo
	  from emipocob
	 WHERE no_poliza = a_no_poliza
	   AND no_unidad = _no_unidad;

	--****Actualizar valores de impuesto****

	foreach
		select cod_impuesto
		  into _cod_impuesto
		  from emipolim
		 where no_poliza = a_no_poliza

		select factor_impuesto
		  into _factor_imp
		  from prdimpue
		 where cod_impuesto = _cod_impuesto;

		update emipolim
		   set monto        = (_ld_prima_deduc * _factor_imp) / 100
		 where no_poliza    = a_no_poliza
		   and cod_impuesto = _cod_impuesto;

	end foreach

	select sum(monto)
	  into _monto_impuesto
	  from emipolim
	 where no_poliza    = a_no_poliza;

	if _monto_impuesto is null then
		let _monto_impuesto = 0;
	end if

	let _ld_prima_bruta = 0;
	let _ld_prima_bruta = _ld_prima_deduc + _monto_impuesto;
	if _ld_sum_aseg_1 is null then
		let _ld_sum_aseg_1 = 0;
	end if	

    call sp_pro323(a_no_poliza,_no_unidad, _ld_sum_aseg_1,'001') returning _valor;	--actualiza emifacon

	--****Actualizar valores de unidad****

	UPDATE emipouni
	   SET suma_asegurada = _ld_sum_aseg_1,
	       prima          = _ld_tarifa,
		   prima_neta     = _ld_prima_deduc,
		   descuento      = _ld_descuento,
		   recargo        = _ld_recargo,
		   impuesto       = _monto_impuesto,
		   prima_bruta    = _ld_prima_bruta
	 WHERE no_poliza      = a_no_poliza
	   AND no_unidad      = _no_unidad;

	UPDATE emivehic
	   SET valor_auto = _ld_sum_aseg_1
	 WHERE no_motor   = _no_motor;

END FOREACH
return 0;
END
END PROCEDURE;




	