-- crear registros para programa de opciones en renovacion por primera vez.

-- CREADO: 		26/11/2004 POR: Armando
-- modificado:	13/01/2005 POR: Armando

--drop procedure sp_pro82ebk;

create procedure "informix".sp_pro82ebk(
v_usuario 			char(8),
v_poliza 			char(10),
a_no_documento 		char(20),
a_vigencia_final 	date,
a_porc_depre_pol 	dec(5,2)
)
returning char(5),		--cod_producto
       	  char(10),		--_no_poliza
	      char(5),		--no_unidad
		  dec(16,2), 	--suma depreciada
		  integer;		--saber si se han usado los descuentos en las opciones

--- Actualizacion de Polizas

DEFINE r_anos          smallint;
DEFINE _porc_depre     DEC(5,2);
DEFINE _porc_depre_uni DEC(5,2);
DEFINE _porc_depre_pol DEC(5,2);
DEFINE _no_unidad      CHAR(5); 
DEFINE _cod_cobertura  CHAR(5); 
DEFINE _cod_producto   CHAR(5); 
DEFINE _valor_asignar  CHAR(1); 
DEFINE _cant_unidades  INTEGER;
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
define ld_imp_3		   DEC(16,2);
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
define _tipo_incendio  smallint;
define _cod_prod1	   CHAR(5);
define _cod_prod2	   CHAR(5);	
define _cantidad	   smallint;
define _cod_tipoprod   char(3);
					
BEGIN
	SELECT vigencia_final,
		   cod_pagador,
		   cod_tipoprod	
	  INTO a_vigencia_final,
		   _cod_pagador,
		   _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = v_poliza;

	LET _vigencia_inic  =  a_vigencia_final;
	LET _vigencia_final = a_vigencia_final + 1 UNITS YEAR;

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

	Select sum(p.factor_impuesto)
	  Into ll_impuesto
	  From emipolim e, prdimpue p
	 Where e.no_poliza    = v_poliza
	   And p.cod_impuesto = e.cod_impuesto;

	if ll_impuesto is null then
		let ll_impuesto = 0;
	end if

	foreach
		 SELECT cod_producto,
				no_unidad,
				suma_asegurada,
				tipo_incendio
		   INTO _cod_producto,
			    _no_unidad,
				_suma_decimal,
				_tipo_incendio
		   FROM emipouni
		  WHERE no_poliza = v_poliza

		 let _suma_asegurada = _suma_decimal;

				let _cod_prod1 = null;
				let _cod_prod2 = null;

				select ((sum(prima_neta_o) * ll_impuesto) / 100),
					   ((sum(prima_neta_1) * ll_impuesto) / 100),
					   ((sum(prima_neta_2) * ll_impuesto) / 100),
					   ((sum(prima_neta_3) * ll_impuesto) / 100)
				  into ld_imp_r,
					   ld_imp_1,
					   ld_imp_2,
					   ld_imp_3
				  from emireau1
				 where no_poliza = v_poliza
				   and no_unidad = _no_unidad;

		insert into emireaut(
		no_poliza,
		cod_asegurado,
		vigencia_inic,
		vigencia_final,
		suma_aseg,
		estatus_ren,
		cod_producto,
		cod_product1,
		cod_product2,
		opcion_final,
		user_added,
		no_documento,
		direccion_1,
		direccion_2,
		telefono1,
		telefono2,
		direcc_cob1,
		direcc_cob2,
		suma_aseg_anterior,
		porc_depreciacion,
		impuesto_o,
		impuesto_r,
		impuesto_1,
		impuesto_2,
		no_unidad,
		cod_no_renov,
		cod_tipoprod,
		tipo_incendio
		)
		values (v_poliza,
			   _cod_pagador,
		       _vigencia_inic,
		       _vigencia_final,
			   _suma_asegurada,
			   1,
			   _cod_producto,
			   null,
			   null,
			   9,
		       v_usuario,
			   a_no_documento,
			   _direccion_1,
			   _direccion_2,
			   _telefono1,
			   _telefono2,
			   _direcc_cob1,
			   _direcc_cob2,
			   _suma_asegurada,
			   a_porc_depre_pol,
			   ld_imp_3,
			   ld_imp_r,
			   ld_imp_1,
			   ld_imp_2,
			   _no_unidad,
			   null,
			   _cod_tipoprod,
			   _tipo_incendio
			   );

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
			desc_limite2)
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
				desc_limite2
			  from emireau1
			 where no_poliza = v_poliza
			   and no_unidad = _no_unidad;
	end foreach

  foreach
	SELECT no_unidad,
		   cod_producto
	  INTO _no_unidad,
		   _cod_producto
	  FROM emireaut
	 WHERE no_poliza = v_poliza
	 order by 1

	  exit foreach;
  end foreach

	return _cod_producto,
	       v_poliza,					  
		   _no_unidad, 
		   0,
		   0;
END

end procedure;