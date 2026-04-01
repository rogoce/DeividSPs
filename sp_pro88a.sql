-- Estado de Cuenta Trimestra de Factultativos

-- Creado    : 17/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/02/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_prod_sp_pro88_dw1 - DEIVID, S.A.

--drop procedure sp_pro88;
Create procedure sp_pro88(
a_compania	   CHAR(3),
a_ano	       SMALLINT,
a_cod_coasegur CHAR(3),
a_cod_ramo     CHAR(3),
a_trimestre	   SMALLINT)

DEFINE ls_ano			CHAR(4);
DEFINE ls_periodo1		CHAR(7);
DEFINE ls_periodo2		CHAR(7);
DEFINE ls_cod_rease 	CHAR(3);
DEFINE ls_no_poliza		CHAR(10);
DEFINE ls_no_endoso		CHAR(5);

DEFINE ld_prima			DEC(16,2);
DEFINE ld_comision		DEC(16,2);
DEFINE ld_impuesto 		DEC(16,2);
DEFINE ld_porc_comision	DEC(16,2);
DEFINE ld_porc_impuesto	DEC(16,2);

Create temp table tmp_estcufa(
	cod_reasegurador	CHAR(3),
	ano					SMALLINT,
	trimestre			SMALLINT,
	primas				DEC(16,2) DEFAULT 0.00,
	reserva_devuelta	DEC(16,2) DEFAULT 0.00,
	int_reserva_dev		DEC(16,2) DEFAULT 0.00,
	imp_int_res_dev		DEC(16,2) DEFAULT 0.00,
	comision			DEC(16,2) DEFAULT 0.00,
	impuestos			DEC(16,2) DEFAULT 0.00,
	sobrecomision		DEC(16,2) DEFAULT 0.00,
	siniestro_pagado	DEC(16,2) DEFAULT 0.00,
	siniestro_contado	DEC(16,2) DEFAULT 0.00,
	reserva_retenida	DEC(16,2) DEFAULT 0.00,
	saldo_reases		DEC(16,2) DEFAULT 0.00
	) RETURNING CHAR(50),  -- Nombre Cia aseguradora
	          	CHAR(20),  -- Ramo
			  	CHAR(30),  -- tipo Contrato
			  	DEC(16,2), -- porcentaje de participacion
			  	CHAR(20),  -- trimestre
			  	CHAR(4),   -- ano
			  	CHAR(50),  -- cuentas
			  	DEC(16,2)  -- monto debito
			  	DEC(16,2)  -- monto credito
			    CHAR(50),  -- Nombre Compania
			    CHAR(255); -- Filtros

--Datos Generales
	SELECT nombre
	  INTO _nombre_coasegur
	  FROM emicoase
	 WHERE cod_coasegur = a_cod_coasegur;

	SELECT nombre
	  INTO _nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = a_cod_ramo;

-- Contrato
	SELECT cod_contrato,
	       porc_partic_suma,
		   porc_partic_prima,
	  INTO _cod_contrato
	       _porc_partic_suma,
		   _porc_partic_prima
	  FROM emireaco
	 WHERE cod_coasegur = a_cod_coasegur
	   AND no_poliza    = _no_poliza
	   AND no_unidad    = _no_unidad;

-- Facultativo
	SELECT cod_contrato,
	       porc_partic_suma,
		   porc_partic_prima,
	  INTO _cod_contrato
	       _porc_partic_reas,
		   _porc_comis_fac
	  FROM emireafa
	 WHERE cod_coasegur = a_cod_coasegur
	   AND no_poliza    = _no_poliza
	   AND no_unidad    = _no_unidad;

	LET ls_ano = a_ano;

	IF   a_trimestre = 1 then
		LET ls_periodo1 = ls_ano || "-01";
		LET ls_periodo2 = ls_ano || "-03";
	ELIF a_trimestre = 2 then
		LET ls_periodo1 = ls_ano || "-04";
		LET ls_periodo2 = ls_ano || "-06";
	ELIF a_trimestre = 3 then
		LET ls_periodo1 = ls_ano || "-07";
		LET ls_periodo2 = ls_ano || "-09";
	ELSE 
		LET ls_periodo1 = ls_ano || "-10";
		LET ls_periodo2 = ls_ano || "-12";
	END IF

	DELETE FROM reaestfa
	      WHERE trimestre = a_trimestre
	        AND ano       = a_ano;

-- Primas Suscritas, Comision, Impuestos

	FOREACH
	 SELECT	no_poliza,
	        no_endoso
	   INTO	ls_no_poliza,
	        ls_no_endoso
	   FROM endedmae
	  WHERE cod_compania = a_compania
		AND actualizado  = 1
		AND periodo     >= ls_periodo1
	    AND periodo     <= ls_periodo2

		FOREACH
		 SELECT cod_coasegur,
				prima,
				porc_comis_fac,
				porc_impuesto
		   INTO ls_cod_rease,
				ld_prima,
				ld_porc_comision,
				ld_porc_impuesto
		   FROM emifafac
		  WHERE no_poliza = ls_no_poliza
		    AND no_endoso = ls_no_endoso 	

			IF ld_porc_comision Is Null then
				LET ld_porc_comision = 0;
			END IF
			
			IF ld_porc_impuesto Is Null then
				LET ld_porc_impuesto = 0;
			END IF

			LET ld_comision	= ld_prima / 100 * ld_porc_comision;
			LET ld_impuesto	= ld_prima / 100 * ld_porc_impuesto;

			Insert Into tmp_estcufa(
			cod_reasegurador,	
			ano,					
			trimestre,			
			primas,				
			comision,			
			impuestos			
			)
			Values(
			ls_cod_rease,
			a_ano,
			a_trimestre,
			ld_prima,
			ld_comision,
			ld_impuesto
			);		

		END FOREACH
	END FOREACH

BEGIN
	DEFINE ld_prima_debe	    DEC(16,2);
	DEFINE ld_prima_haber	    DEC(16,2);
	DEFINE ld_reserva_dev_debe	DEC(16,2);
	DEFINE ld_reserva_dev_haber	DEC(16,2);
	DEFINE ld_interes_debe	    DEC(16,2);
	DEFINE ld_interes_haber	    DEC(16,2);
	DEFINE ld_imp_interes_debe	DEC(16,2);
	DEFINE ld_imp_interes_haber	DEC(16,2);
	DEFINE ld_comision_debe	    DEC(16,2);
	DEFINE ld_comision_haber	DEC(16,2);
	DEFINE ld_impuesto_debe	    DEC(16,2);
	DEFINE ld_impuesto_haber	DEC(16,2);

-- Arma el Estado de Cuenta

FOREACH
 SELECT cod_reasegurador,
		Sum(primas),				
		Sum(reserva_devuelta),	
		Sum(int_reserva_dev),		
		Sum(imp_int_res_dev),		
		Sum(comision),			
		Sum(impuestos),			
		Sum(sobrecomision),		
		Sum(siniestro_pagado),	
		Sum(siniestro_contado),
		Sum(reserva_retenida)	

END 

END PROCEDURE