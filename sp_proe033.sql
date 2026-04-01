-- Procedimiento para actualizar los valores de emipomae
-- f_emision_act_primas
--
-- Creado    : 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 21/08/2003 - Autor: Amado Perez, ** Calculo especial para las polizas de Salud **
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe033;

CREATE PROCEDURE "informix".sp_proe033(
a_poliza CHAR(10), 
a_cia CHAR(3)
) RETURNING   INTEGER;   -- _error

DEFINE li_tipo_ramo, li_meses	   INTEGER;
DEFINE li_count					   INTEGER;
DEFINE li_tiene_gastos			   INTEGER;
DEFINE _error, li_tipopro		   INTEGER;
DEFINE li_uno, li_ramo_sys		   INTEGER;
DEFINE ls_ramo, ls_perpago  	   CHAR(3);
DEFINE ls_impuesto, ls_tipopro	   CHAR(3);
DEFINE ls_ase_lider, ls_cod_ramo   CHAR(3);
DEFINE ls_cod_subramo,ls_cod_gasto CHAR(3);

DEFINE ld_prima		   		DECIMAL(16,2);
DEFINE ld_prima_vida   		DECIMAL(16,2);
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
DEFINE ld_retenida       	DECIMAL(16,2);
DEFINE ld_gastos	       	DECIMAL(16,2);
DEFINE ld_imp_total       	DECIMAL(16,4);

DEFINE ld_porc_coaseg		DECIMAL(16,4);
DEFINE ld_porc_impuesto		DECIMAL(16,4);

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
LET ld_suscrita			 	= 0.00;
LET ld_retenida			 	= 0.00;
LET ld_gastos			 	= 0.00;
Let li_tiene_gastos         = 0;

-- Calcular Primas (Neta-Bruta), impuesto, recargo, descuento, Suma Asegurada
Select SUM(emipouni.prima), SUM(emipouni.descuento), SUM(emipouni.recargo), 
 	   SUM(emipouni.prima_neta), SUM(emipouni.impuesto), SUM(emipouni.prima_bruta),
	   SUM(emipouni.suma_asegurada), SUM(prima_vida)
  Into ld_prima, ld_descuento, ld_recargo, ld_prima_neta, ld_impuesto, ld_prima_bruta, 
       ld_suma_asegurada, ld_prima_vida
  From emipouni
 Where emipouni.no_poliza = a_poliza;
 

-- Buscar Tipo de Ramo, Periodo de Pago y Tipo de Produccion
Select cod_tipoprod,
	   cod_ramo,
	   cod_subramo,
	   tiene_gastos
  Into ls_tipopro,
  	   ls_cod_ramo,
	   ls_cod_subramo,
	   li_tiene_gastos
  From emipomae
 Where no_poliza = a_poliza;

Select ramo_sis
  into li_ramo_sys
  From prdramo
 Where cod_ramo = ls_cod_ramo;

if li_tiene_gastos = 1 then	 --fianzas
	Select count(*)
	  into li_count
	  From prdgasub
	 Where cod_ramo    = ls_cod_ramo
	   and cod_subramo = ls_cod_subramo;

	if li_count > 0 then
		Select cod_gasto
		  into ls_cod_gasto
		  From prdgasub
		 Where cod_ramo    = ls_cod_ramo
		   and cod_subramo = ls_cod_subramo;

		Select monto
		  into ld_gastos
		  From prdgasma
		 Where cod_gasto = ls_cod_gasto;
    end if
else
	LET ld_gastos = 0.00;
end if

Select emitipro.tipo_produccion Into li_tipopro
  From emitipro
 Where emitipro.cod_tipoprod = ls_tipopro;

LET ld_imp_total = 0.00;
LET li_uno = 1;

-- Calcular Impuestos para emipolim
IF li_ramo_sys = 5 THEN
	FOREACH
		 Select emipolim.cod_impuesto, (prdimpue.factor_impuesto * (Sum(emipouni.prima_neta)-Sum(emipouni.prima_vida))/100)
		   Into ls_impuesto, ld_impuesto1
		   From emipolim, prdimpue, emipouni
		  Where emipolim.no_poliza = a_poliza
		    And emipouni.no_poliza = emipolim.no_poliza
		    And prdimpue.cod_impuesto = emipolim.cod_impuesto
		 group by emipolim.cod_impuesto, prdimpue.factor_impuesto
		 
		If li_uno = 1 Then
		   Update emipolim
		      Set monto = 0.00
		    Where no_poliza = a_poliza;
			LET li_uno = 0;
		End If

		Update emipolim
		   Set monto = ld_impuesto1
		 Where no_poliza 	= a_poliza
		   And cod_impuesto = ls_impuesto;
			
		LET ld_imp_total = ld_imp_total + ld_impuesto1;
	END FOREACH
ELSE
	FOREACH
		 Select emipolim.cod_impuesto, (prdimpue.factor_impuesto * Sum(emipouni.prima_neta)/100)
		   Into ls_impuesto, ld_impuesto1
		   From emipolim, prdimpue, emipouni
		  Where emipolim.no_poliza = a_poliza
		    And emipouni.no_poliza = emipolim.no_poliza
		    And prdimpue.cod_impuesto = emipolim.cod_impuesto
		 group by emipolim.cod_impuesto, prdimpue.factor_impuesto
		 
		If li_uno = 1 Then
		   Update emipolim
		      Set monto = 0.00
		    Where no_poliza = a_poliza;
			LET li_uno = 0;
		End If

		Update emipolim
		   Set monto = ld_impuesto1
		 Where no_poliza 	= a_poliza
		   And cod_impuesto = ls_impuesto;
			
		LET ld_imp_total = ld_imp_total + ld_impuesto1;
	END FOREACH
END IF

-- Cargar Impuesto para emipomae
IF li_ramo_sys = 5 THEN
	Select Sum(prdimpue.factor_impuesto * (emipouni.prima_neta-emipouni.prima_vida))/100
	  Into ld_impuesto
	  From emipolim, prdimpue, emipouni
	 Where emipolim.no_poliza = a_poliza
	   And emipouni.no_poliza = emipolim.no_poliza
	   And prdimpue.cod_impuesto = emipolim.cod_impuesto;
ELSE
	Select Sum(prdimpue.factor_impuesto * emipouni.prima_neta)/100
	  Into ld_impuesto
	  From emipolim, prdimpue, emipouni
	 Where emipolim.no_poliza = a_poliza
	   And emipouni.no_poliza = emipolim.no_poliza
	   And prdimpue.cod_impuesto = emipolim.cod_impuesto;
END IF
	 
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
If ld_impuesto IS NULL Or ld_impuesto = 0 Then
   LET ld_impuesto = ld_imp_total;
End If
If ld_prima_bruta IS NULL Then
   LET ld_prima_bruta = 0.00;
End If
If ld_suscrita IS NULL Then
   LET ld_suscrita = 0.00;
End If
If ld_retenida IS NULL Then
   LET ld_retenida = 0.00;
End If
If ld_gastos IS NULL Then
   LET ld_gastos = 0.00;
End If

LET ld_prima_bruta = ld_prima_neta + ld_impuesto + ld_gastos;

If li_tipopro <> 2 And li_tipopro Is Not Null Then
	LET ld_suscrita = ld_prima_neta;
	LET ld_retenida = ld_prima_neta;
Else
   If li_tipopro = 2 Then
--	 La suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
--	 campo - Aseguradora Lider

	 Select par_ase_lider Into ls_ase_lider
	   From parparam
	  Where cod_compania = a_cia;
	 
	 SELECT emicoama.porc_partic_coas Into ld_porc_coaseg
	   FROM emicoama  
	  WHERE emicoama.no_poliza = a_poliza
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
   And reacomae.cod_contrato  = emifacon.cod_contrato
   And reacomae.tipo_contrato = 1;
 
If ld_retenida Is Null Then
	LET ld_retenida = 0.00;
End If

-- Calcular Suscrita

Select SUM(emifacon.prima) 
  Into ld_suscrita
  From emifacon
 Where emifacon.no_poliza     = a_poliza
   And emifacon.no_endoso     = '00000';
 
If ld_suscrita Is Null Then
	LET ld_suscrita = 0.00;
End If

Update emipomae
   Set prima 				= ld_prima, 
	   descuento			= ld_descuento,
	   recargo				= ld_recargo,
	   prima_neta 			= ld_prima_neta,
	   prima_bruta			= ld_prima_bruta,
	   suma_asegurada 		= ld_suma_asegurada,
	   impuesto 			= ld_impuesto,
	   prima_suscrita		= ld_suscrita,
	   prima_retenida		= ld_retenida,
	   gastos				= ld_gastos
 Where emipomae.no_poliza   = a_poliza;

RETURN 0;
END
END PROCEDURE;

