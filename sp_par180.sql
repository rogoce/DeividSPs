-- Procedimiento que crea los registros para programa de 3 opciones en renovacion por unidad.

-- CREADO: 14/11/2001 POR: Amado
-- CREADO: 26/11/2004 POR: Armando

drop procedure sp_pro82;

create procedure "informix".sp_pro82(
)

DEFINE r_anos          smallint;
DEFINE _valor          smallint;
DEFINE _porc_depre     DEC(5,2);
DEFINE _porc_depre_uni DEC(5,2);
DEFINE _porc_depre_pol DEC(5,2);
DEFINE _no_unidad      CHAR(5); 
DEFINE _cod_cobertura  CHAR(5); 
DEFINE _cod_producto   CHAR(5); 
DEFINE _valor_asignar  CHAR(1); 
DEFINE _cant_unidades  INTEGER;
DEFINE _cant  		   INTEGER;
DEFINE _cant1  		   INTEGER;
DEFINE _cant2  		   INTEGER;
DEFINE _suma_asegurada INTEGER;
DEFINE _no_motor       CHAR(30);
DEFINE _suma_decimal   DEC(16,2);
DEFINE _suma_difer	   DEC(16,2);
DEFINE _suma_ant	   DEC(16,2);
DEFINE _vigencia_inic  DATE;
DEFINE _vigencia_final DATE;
DEFINE _cod_pagador,_telefono1,_telefono2 CHAR(10);
DEFINE _no_poliza      CHAR(10);
DEFINE _limite_1       DEC(16,2);
DEFINE _limite_2       DEC(16,2);
DEFINE _prima_anual    DEC(16,2);
DEFINE _prima          DEC(16,2);
DEFINE _descuento      DEC(16,2);
DEFINE _recargo        DEC(16,2);
DEFINE _prima_neta	   DEC(16,2);
DEFINE _imp			   DEC(16,2);
define ld_imp_r		   DEC(16,2);
define ld_imp_1		   DEC(16,2);
define ld_imp_2		   DEC(16,2);
define ll_impuesto	   integer;	
DEFINE _unidad         CHAR(5);
DEFINE _tarifa, _factor_vigencia DEC(9,6);
DEFINE _deducible,_desc_limite1,_desc_limite2,_direccion_1,_direccion_2 CHAR(50);
DEFINE _direcc_cob1,_direcc_cob2 CHAR(50);
DEFINE _porc_descuento  DEC(5,2);
DEFINE _porc_descuento1 DEC(5,2);
DEFINE _porc_descuento2 DEC(5,2);

DEFINE li_dia,_orden   SMALLINT;
DEFINE li_mes		   SMALLINT;
DEFINE li_ano		   SMALLINT;
DEFINE ld_fecha_1_pago DATE;
DEFINE li_no_pagos	   SMALLINT;
DEFINE ls_cod_perpago  CHAR(3);
DEFINE li_meses		   SMALLINT;
define _cod_prod1	   CHAR(5);
define _cod_prod2	   CHAR(5);
define _cod_ruta	   char(5);
define _cantidad	   smallint;
					
--SET DEBUG FILE TO "sp_pro82.trc"; 
--trace on;

let _cant  = 0;
let _cant1 = 0;
let _cant2 = 0;

BEGIN
	delete from emireau2
     where no_poliza = v_poliza
	   and no_unidad = a_unidad;

		SELECT vigencia_final
		  INTO a_vigencia_final
		  FROM emipomae
		 WHERE no_poliza = v_poliza;

		LET _vigencia_inic  =  a_vigencia_final;
		LET _vigencia_final = a_vigencia_final + 1 UNITS YEAR;

		SELECT cod_pagador
		  INTO _cod_pagador 
		  FROM emipomae
		 WHERE no_poliza = v_poliza;

		SELECT direccion_1,
		       direccion_2,
			   telefono1,
			   telefono2
		  INTO _direccion_1,   
		       _direccion_2,
			   _telefono1,
			   _telefono2
		  FROM cliclien
		 WHERE cod_cliente = _cod_pagador;

		SELECT direccion_1,
		       direccion_2
		  INTO _direcc_cob1,
		       _direcc_cob2
		  FROM emidirco
		 WHERE no_poliza = v_poliza;

			-- Calculo de la Depreciacion de la unidad

			let _porc_depre_pol = a_porc_depre_pol;

				SELECT cod_producto,
					   suma_asegurada,
					   impuesto,
					   cod_ruta
				  INTO _cod_producto,
					   _suma_decimal,
					   _imp,
					   _cod_ruta
				  FROM emipouni
				 WHERE no_poliza = v_poliza
				   AND no_unidad = a_unidad;

				if _cod_producto is null then	--estan insertando una unidad
					SELECT cod_producto,
						   suma_aseg
					  INTO _cod_producto,
						   _suma_decimal
					  FROM emireaut
					 WHERE no_poliza = v_poliza
					   AND no_unidad = a_unidad;

					let _imp = null;
				end if

				let _suma_ant = _suma_decimal;

				LET _porc_depre = _porc_depre_pol;

				IF a_porc_depre_pol <> 0.00 THEN
					LET _suma_asegurada = _suma_decimal * (1 - _porc_depre/100);
					LET _suma_decimal   = _suma_decimal * (1 - _porc_depre/100);
				ELSE
					LET _suma_asegurada = _suma_decimal;
				END IF

				LET _suma_difer = _suma_decimal - _suma_asegurada;

				IF _suma_difer >= 0.5 THEN
					LET _suma_asegurada = _suma_asegurada + 1;
				END IF

				if _cod_ruta is null then
					let _suma_asegurada = _suma_ant;
					let _suma_ant       = 0.00;
				end if

				Select sum(p.factor_impuesto)
				  Into ll_impuesto
				  From emipolim e, prdimpue p
				 Where e.no_poliza    = v_poliza
				   And p.cod_impuesto = e.cod_impuesto;

				if ll_impuesto is null then
					let ll_impuesto = 0;
				end if

				let _cod_prod1 = null;
				let _cod_prod2 = null;

				select ((sum(prima_neta_o) * ll_impuesto) / 100),
					   ((sum(prima_neta_1) * ll_impuesto) / 100),
					   ((sum(prima_neta_2) * ll_impuesto) / 100)
				  into ld_imp_r,
					   ld_imp_1,
					   ld_imp_2
				  from emireau1
				 where no_poliza = v_poliza
				   and no_unidad = a_unidad;

			   foreach	
					select cod_product1,
						   cod_product2
					  into _cod_prod1,
						   _cod_prod2
					  from emireau1
					 where no_poliza = v_poliza
					   and no_unidad = a_unidad
				  exit foreach;
			   end foreach	

				UPDATE emireaut
				   SET suma_aseg          = _suma_asegurada,
					   suma_aseg_anterior = _suma_ant,
					   impuesto_o		  = _imp,
					   impuesto_r         =	ld_imp_r,
					   impuesto_1         =	ld_imp_1,
					   impuesto_2         =	ld_imp_2,
					   cod_product1       = _cod_prod1,
					   cod_product2       =	_cod_prod2,
					   porc_depreciacion  = a_porc_depre_pol
				 WHERE no_poliza          = v_poliza
				   and no_unidad          = a_unidad;

				INSERT INTO emireau2(
				no_poliza,
				no_unidad ,
				cod_cobertura,
				orden,
				chek_o,
				limite_1_o,
				limite_2_o,
				prima_anual_o,
				prima_o,
				descuento_o,
				recargo_o,
				prima_neta_o,
				chek_1,
				limite_1_1,
				limite_2_1,
				prima_anual_1,
				prima_1,
				descuento_1,
				recargo_1,
				prima_neta_1,
				chek_2,
				limite_1_2,
				limite_2_2,
				prima_anual_2,
				prima_2,
				descuento_2,
				recargo_2,
				prima_neta_2,
				deducible_o,
				deducible_1,
				deducible_2,
				limite_1_3,
				limite_2_3,
				prima_anual_3,
				prima_3,
				descuento_3,
				recargo_3,
				prima_neta_3,
				deducible_3,
				requerida_1,
				requerida_2,
				factor_vigencia,
				desc_limite1,
				desc_limite2,
				requerida_0)
				select
					no_poliza,
					no_unidad,
					cod_cobertura,
					orden,
					chek_o,
					limite_1_o,
					limite_2_o,
					prima_anual_o,
					prima_o,
					descuento_o,
					recargo_o,
					prima_neta_o,
					chek_1,
					limite_1_1,			
					limite_2_1,
					prima_anual_1,
					prima_1,
					descuento_1,
					recargo_1,
					prima_neta_1,
					chek_2,
					limite_1_2,
					limite_2_2,
					prima_anual_2,
					prima_2,
					descuento_2,
					recargo_2,
					prima_neta_2,
					deducible_o,
					deducible_1,
					deducible_2,
					limite_1_3,
					limite_2_3,
					prima_anual_3,
					prima_3,
					descuento_3,
					recargo_3,
					prima_neta_3,
					deducible_3,
					requerida_1,
					requerida_2,
					factor_vigencia,
					desc_limite1,
					desc_limite2,
					requerida_0
				  from emireau1
				 where no_poliza = v_poliza
				   and no_unidad = a_unidad;

END
end procedure;

