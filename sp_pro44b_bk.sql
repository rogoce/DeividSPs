-- Procedimiento para la impresion de Notas del Facultativo
--
-- Creado    : 30/01/2000 - Autor: Edgar E. Cano G.
-- Modificado: 30/01/2000 - Autor: Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro44b;
CREATE PROCEDURE "informix".sp_pro44b(a_poliza CHAR(10), a_endoso CHAR(5))
			RETURNING   CHAR(3),			-- ls_coasegur
						CHAR(40),			-- ls_nom_coase
						CHAR(10),			-- ls_cod_cliente
						CHAR(100),			-- ls_nom_cli
						CHAR(20),			-- ls_no_documento
						DATE,				-- ldt_vini
						DATE,				-- ldt_vfin
						DECIMAL(16,2),		-- ld_suma_total
						DECIMAL(16,2),		-- ld_suma_rea
						DECIMAL(16,2),		-- ld_prima_total
						DECIMAL(16,2),		-- ld_prima_rea
						DECIMAL(16,2),		-- ld_comision
						DECIMAL(16,4),		-- ld_porc_comision
						DECIMAL(16,2),		-- ld_saldo
						CHAR(10),			-- ls_factura
						CHAR(10),			-- ls_no_cesion
						CHAR(60),			-- ls_fecha_letra
						CHAR(3),			-- ls_ramo
						CHAR(30),			-- ls_nom_ramo
						INTEGER,			-- li_tipo_ramo
						DECIMAL(16,2),		-- ld_porc_impuesto
						DECIMAL(16,2)		-- ld_impuesto

DEFINE ls_coasegur	 		CHAR(3);
DEFINE ls_cod_cliente		CHAR(10);
DEFINE ls_nom_cli			CHAR(100);
DEFINE ls_nom_coase			CHAR(40);
DEFINE ls_no_documento		CHAR(20);
DEFINE ls_no_cesion			CHAR(10);
DEFINE ls_unidad			CHAR(10);
DEFINE ls_factura			CHAR(10);
DEFINE ls_fecha_letra		CHAR(60);
DEFINE ls_ramo				CHAR(3);
DEFINE ls_nom_ramo			CHAR(30);
DEFINE ldt_vini, ldt_vfin	DATE;
DEFINE ldt_fecha_emision	DATE;
DEFINE ld_suma_total		DEC(16,2);
DEFINE ld_prima_total		DEC(16,2);
DEFINE ld_suma_rea			DEC(16,2);
DEFINE ld_prima_rea			DEC(16,2);
DEFINE ld_comision			DEC(16,2);
DEFINE ld_impuesto			DEC(16,2);
DEFINE ld_saldo				DEC(16,2);
DEFINE ld_porc_reas			DEC(16,4);
DEFINE ld_porc_comision		DEC(16,4);
DEFINE ld_porc_impuesto		DEC(16,4);

DEFINE li_tipo_ramo			INT;
DEFINE li_ramo_sis			INT;

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

Select endedmae.no_documento, endedmae.suma_asegurada,
       endedmae.vigencia_inic, endedmae.vigencia_final,
	   endedmae.prima_suscrita, endedmae.no_factura, endedmae.fecha_emision
  Into ls_no_documento, ld_suma_total, ldt_vini, ldt_vfin, 
       ld_prima_total, ls_factura, ldt_fecha_emision
  From endedmae
 Where endedmae.no_poliza = a_poliza
   And endedmae.no_endoso = a_endoso;

Select emipomae.cod_ramo
  Into ls_ramo
  From emipomae
 Where no_poliza = a_poliza;

{
	SELECT X.cod_coasegur, X.porc_partic_reas, X.porc_comis_fac,
		   X.porc_impuesto
    	   sum(X.suma_asegurada), Sum(X.prima), Sum(X.no_cesion), Sum(X.no_unidad)
	  INTO ls_coasegur, ld_porc_reas, ld_porc_comision, ld_porc_impuesto
	       ld_suma_rea, ld_prima_rea, ls_no_cesion, ls_unidad
      FROM emifafac X
     WHERE X.no_poliza = a_poliza
       AND X.no_endoso = a_endoso
	GROUP BY X.cod_coasegur, X.cod_coasegur, X.porc_partic_reas, X.porc_comis_fac
    ORDER BY X.cod_coasegur
}

FOREACH
	SELECT emifafac.cod_coasegur, emifafac.porc_partic_reas, emifafac.porc_comis_fac,
	       emifafac.porc_impuesto, emifafac.no_cesion,
           (emifafac.porc_comis_fac * Sum(emifafac.prima)/100),
		   (emifafac.porc_impuesto * Sum(emifafac.prima)/100),
    	   sum(emifafac.suma_asegurada), Sum(emifafac.prima)
	  INTO ls_coasegur, ld_porc_reas, ld_porc_comision, ld_porc_impuesto, ls_no_cesion,
	       ld_comision, ld_impuesto, ld_suma_rea, ld_prima_rea
      FROM emifafac emifafac
     WHERE emifafac.no_poliza = a_poliza
       AND emifafac.no_endoso = a_endoso
	GROUP BY emifafac.cod_coasegur, emifafac.porc_partic_reas, 
	         emifafac.porc_comis_fac, emifafac.porc_impuesto, emifafac.no_cesion
    ORDER BY emifafac.cod_coasegur

	If ld_comision Is Null Then
	   Let ld_comision = 0.00;
	End If
	
	If ld_impuesto Is Null Then
	   Let ld_impuesto = 0.00;
	End If

	LET ld_saldo	= ld_prima_rea - ld_comision - ld_impuesto;

	SELECT Unique endeduni.cod_cliente, cliclien.nombre
	  INTO ls_cod_cliente, ls_nom_cli
	  FROM cliclien, endeduni
	 WHERE endeduni.no_poliza 	= a_poliza
	   AND endeduni.no_endoso 	= a_endoso
	   AND cliclien.cod_cliente = endeduni.cod_cliente;

	Select emicoase.nombre
	  Into ls_nom_coase
	  From emicoase
	 Where emicoase.cod_coasegur = ls_coasegur;

    Select prdramo.nombre, prdtiram.tipo_ramo, prdramo.ramo_sis
	  Into ls_nom_ramo, li_tipo_ramo, li_ramo_sis
	  From prdramo, prdtiram
	 Where prdramo.cod_ramo = ls_ramo
	   And prdtiram.cod_tiporamo = prdramo.cod_tiporamo;

	If ldt_fecha_emision IS NULL Then
	   LET ldt_fecha_emision = Today;
	End If
	Call sp_sis20(ldt_fecha_emision) RETURNING ls_fecha_letra;

    If li_ramo_sis = 2 Then
	   LET ld_suma_rea = ld_suma_rea / 2;
    End If

	RETURN ls_coasegur, ls_nom_coase, ls_cod_cliente, ls_nom_cli, 
		   ls_no_documento, ldt_vini, ldt_vfin,
	       ld_suma_total, ld_suma_rea, ld_prima_total, ld_prima_rea,
		   ld_comision, ld_porc_comision, ld_saldo, ls_factura,
		   ls_no_cesion, ls_fecha_letra, ls_ramo, 
		   ls_nom_ramo, li_tipo_ramo, ld_porc_impuesto, ld_impuesto WITH RESUME; 
END FOREACH
END
END PROCEDURE;