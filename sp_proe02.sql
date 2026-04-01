-- Procedimiento para actualizar los valores en las unidades
-- f_emision_act_unidad
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 20/08/2003 - Autor: Amado Perez M. -- Se incluye lo del calculo del impuesto para salud...
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe02;
CREATE PROCEDURE sp_proe02(a_poliza CHAR(10), a_unidad CHAR(5), a_cia CHAR(3))
			RETURNING   INTEGER   -- _error

DEFINE li_tipo_ramo, li_meses	INTEGER;
DEFINE _error, li_tipopro		INTEGER;
DEFINE ls_ramo, ls_perpago  	CHAR(3);
DEFINE ls_impuesto, ls_tipopro	CHAR(3);
DEFINE ls_ase_lider				CHAR(3);

DEFINE ld_prima		   		DECIMAL(16,2);
DEFINE ld_descuento		   	DECIMAL(16,2);
DEFINE ld_recargo		   	DECIMAL(16,2);
DEFINE ld_prima_neta		DECIMAL(16,2);
DEFINE ld_prima_anual		DECIMAL(16,2);
DEFINE ld_suma_asegurada	DECIMAL(16,2);
DEFINE ld_impuesto		   	DECIMAL(16,2);
DEFINE ld_impuesto1		   	DECIMAL(16,2);
DEFINE ld_prima_bruta		DECIMAL(16,2);
DEFINE ld_prima_total		DECIMAL(16,2);
DEFINE ld_depen		   		DECIMAL(16,2);
DEFINE ld_suscrita       	DECIMAL(16,2);
DEFINE ld_retenida			DECIMAL(16,2);
DEFINE ld_prima_vida        DECIMAL(16,2);
DEFINE ld_gastos		    DECIMAL(16,2);
DEFINE ld_recargo_depend    DECIMAL(16,2);

DEFINE ld_porc_coaseg		DECIMAL(16,4);
DEFINE ld_porc_impuesto		DECIMAL(16,4);
define _cod_ramo_uni  		char(3);
define ld_impuesto_uni		DECIMAL(16,2);			

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET ld_prima 				= 0.00;
LET ld_descuento			= 0.00;
LET ld_recargo				= 0.00;
LET ld_prima_neta			= 0.00;
LET ld_prima_anual			= 0.00;
LET ld_suma_asegurada		= 0.00;
LET ld_impuesto				= 0.00;
LET ld_prima_bruta			= 0.00;
LET ld_prima_total 			= 0.00;
LET ld_depen			 	= 0.00;
LET ld_suscrita			 	= 0.00;
LET ld_retenida			 	= 0.00;
LET ld_prima_vida		 	= 0.00;
LET ld_gastos			 	= 0.00;


--SET DEBUG FILE TO "sp_proe02.trc";      
--TRACE ON;                                                                     

-- Buscar Tipo de Ramo
Select cod_ramo,
	   cod_perpago,
	   cod_tipoprod,
	   gastos
  Into ls_ramo,
  	   ls_perpago,
  	   ls_tipopro,
	   ld_gastos
  From emipomae
 Where no_poliza = a_poliza;

if ld_gastos is null then
	let ld_gastos = 0.00;
end if

Select tipo_produccion 
  Into li_tipopro
  From emitipro
 Where cod_tipoprod = ls_tipopro;
 
Select cobperpa.meses 
  Into li_meses
  from cobperpa
 Where cobperpa.cod_perpago = ls_perpago;

if li_meses = 0 then
	if ls_perpago = '008' then
		let li_meses = 12; 	   	
	else
		let li_meses = 1;
	end if
end if

Select prdramo.ramo_sis 
  Into li_tipo_ramo
  From prdramo
 Where prdramo.cod_ramo = ls_ramo;

Select SUM(emipocob.prima),
	   SUM(emipocob.descuento),
	   SUM(emipocob.recargo),  
	   SUM(emipocob.prima_neta),
	   SUM(prima_vida)
  Into ld_prima, 
  	   ld_descuento,
  	   ld_recargo,
  	   ld_prima_neta,
  	   ld_prima_vida
  From emipocob
 Where emipocob.no_poliza = a_poliza
   And emipocob.no_unidad = a_unidad;
	 
If ld_prima_vida is null Then
	let ld_prima_vida = 0.00;
End If

-- Calcular Impuesto
If li_tipo_ramo = 5 Then
	FOREACH
		 Select emipolim.cod_impuesto,
		 		(prdimpue.factor_impuesto * (Sum(emipouni.prima_neta))/100)
		   Into ls_impuesto,
		   		ld_impuesto1
		   From emipolim, prdimpue, emipouni
		  Where emipolim.no_poliza = a_poliza
		    And emipouni.no_poliza = emipolim.no_poliza
			And emipouni.no_unidad = a_unidad
		    And prdimpue.cod_impuesto = emipolim.cod_impuesto
		 group by emipolim.cod_impuesto, prdimpue.factor_impuesto

		LET ld_impuesto = ld_impuesto + ld_impuesto1;

		Update emipolim
	       Set monto        = monto + ld_impuesto1
		 Where no_poliza    = a_poliza
		   And cod_impuesto = ls_impuesto;
			
		LET ld_impuesto1 = 0.00;
	END FOREACH
Else
	FOREACH
		 Select emipolim.cod_impuesto,
		 		(prdimpue.factor_impuesto * Sum(emipouni.prima_neta)/100)
		   Into ls_impuesto,
		        ld_impuesto1
		   From emipolim, prdimpue, emipouni
		  Where emipolim.no_poliza = a_poliza
		    And emipouni.no_poliza = emipolim.no_poliza
			And emipouni.no_unidad = a_unidad
		    And prdimpue.cod_impuesto = emipolim.cod_impuesto
		 group by emipolim.cod_impuesto, prdimpue.factor_impuesto

		LET ld_impuesto = ld_impuesto + ld_impuesto1;

		Update emipolim
	       Set monto        = monto + ld_impuesto1
		 Where no_poliza    = a_poliza
		   And cod_impuesto = ls_impuesto;
			
		LET ld_impuesto1 = 0.00;

	END FOREACH
End If

LET ld_impuesto = 0.00;

IF li_tipo_ramo = 5 THEN
	Select Sum(prdimpue.factor_impuesto * (ld_prima_neta))/100
	  Into ld_impuesto
	  From emipolim, prdimpue, emipouni
	 Where emipolim.no_poliza = a_poliza
	   And emipouni.no_poliza = emipolim.no_poliza
	   And emipouni.no_unidad = a_unidad
	   And prdimpue.cod_impuesto = emipolim.cod_impuesto;
ELSE
	Select Sum(prdimpue.factor_impuesto * emipouni.prima_neta)/100
	  Into ld_impuesto
	  From emipolim, prdimpue, emipouni
	 Where emipolim.no_poliza = a_poliza
	   And emipouni.no_poliza = emipolim.no_poliza
	   And emipouni.no_unidad = a_unidad
	   And prdimpue.cod_impuesto = emipolim.cod_impuesto;
	   
	if ls_ramo = '024' then
		select cod_ramo
  		  into _cod_ramo_uni 
		  from emipouni
		 where no_poliza = a_poliza
           and no_unidad = a_unidad;
		if _cod_ramo_uni = '020' then
			Select Sum(1 * emipouni.prima_neta)/100
			  Into ld_impuesto_uni
			  From emipolim, prdimpue, emipouni
			 Where emipolim.no_poliza = a_poliza
			   And emipouni.no_poliza = emipolim.no_poliza
			   And emipouni.no_unidad = a_unidad
			   And prdimpue.cod_impuesto = emipolim.cod_impuesto;
			let ld_impuesto = ld_impuesto + ld_impuesto_uni;
		end if
	end if
	   
END IF

IF ld_impuesto IS NULL Then
	LET ld_impuesto = 0.00;	
END IF

LET ld_prima_bruta = ld_prima_neta + ld_impuesto;

If ld_prima IS NULL Then
   LET ld_prima = 0.00;
End If
If ld_descuento IS NULL Then
   LET ld_descuento = 0.00;
End If
If ld_recargo IS NULL Then
   LET ld_recargo = 0.00;
End If
If ld_prima_neta IS NULL Then
   LET ld_prima_neta = 0.00;
End If
If ld_prima_anual IS NULL Then
   LET ld_prima_anual = 0.00;
End If
If ld_impuesto IS NULL Then
   LET ld_impuesto = 0.00;
End If
If ld_prima_bruta IS NULL Then
   LET ld_prima_bruta = 0.00;
End If
If ld_prima_vida is null Then
	let ld_prima_vida = 0.00;
End If

If li_tipopro <> 2 And li_tipopro Is Not Null Then
	LET ld_suscrita = ld_prima_neta;
	LET ld_retenida = ld_prima_neta;
Else
   If li_tipopro = 2 Then
--	 La suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
--	 campo - Aseguradora Lider

	 Select par_ase_lider 
	   Into ls_ase_lider
	   From parparam
	  Where cod_compania = a_cia;
	 
	 SELECT emicoama.porc_partic_coas
	   Into ld_porc_coaseg
	   FROM emicoama  
	  WHERE emicoama.no_poliza    = a_poliza
	   	AND emicoama.cod_coasegur = ls_ase_lider;
	
	 LET ld_suscrita = (ld_prima_neta * ld_porc_coaseg) / 100;
   End If
End If

-- Calcular Retencion

Select SUM(emifacon.prima) 
  Into ld_retenida
  From emifacon, reacomae
 Where emifacon.no_poliza     = a_poliza
   And emifacon.no_endoso     = '00000'
   and emifacon.no_unidad     = a_unidad
   And reacomae.cod_contrato  = emifacon.cod_contrato
   And reacomae.tipo_contrato = 1;
 
If ld_retenida Is Null Then
	LET ld_retenida = ld_prima_neta;
End If

If li_tipo_ramo = 5 Then
	Select Sum(emidepen.prima) Into ld_depen
	  From emidepen
	 Where emidepen.no_poliza = a_poliza
	   And emidepen.no_unidad = a_unidad
	   And emidepen.activo = 1;			  -- Estaba trayendo el monto a pesar de estar inactivo Amado 26/10/2010 CASO: 09248 USER: GPEREZ PC: CMEMIS06 
	
	If ld_depen IS NULL Then
	   LET ld_depen = 0.00;
	End If

	LET ld_prima_total = ld_prima + ld_depen;
	LET ld_recargo = ld_recargo;
--	LET ld_prima_total = ld_prima_total * li_meses;
End If

Update emipouni
   Set prima 				= ld_prima, 
       descuento			= ld_descuento,
  	   recargo				= ld_recargo,
  	   prima_neta 			= ld_prima_neta,
  	   prima_bruta			= ld_prima_bruta,
  	   impuesto 			= ld_impuesto,
 --	   prima_total			= ld_prima_total,
       prima_total			= prima_asegurado * li_meses,
  	   prima_suscrita   	= ld_suscrita,
  	   prima_retenida   	= ld_retenida,
	   prima_vida           = ld_prima_vida,
	   gastos				= ld_gastos
 Where emipouni.no_poliza  	= a_poliza
   And emipouni.no_unidad 	= a_unidad;

RETURN 0;
END
END PROCEDURE;