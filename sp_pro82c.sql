-- Procedimiento que crea los registros para tabla emirenco, la cual contiene los valores de la opcion escogida por unidad.

-- CREADO: 11/01/2005 POR: Armando Moreno.

drop procedure sp_pro82c;

create procedure "informix".sp_pro82c(
v_poliza 			char(10),
a_opcion			integer default 0
)
returning integer, char(50);

define _fecha		  date;
define r_error        SMALLINT;
define r_descripcion  CHAR(50);
define _no_unidad     CHAR(5);
DEFINE ls_cober_reas		CHAR(3);
DEFINE ls_contrato, ls_ruta	CHAR(5);
DEFINE ld_porc_suma, ld_porc_prima  DECIMAL(10,4);
DEFINE ld_suma				DECIMAL(16,2); 
DEFINE ld_letra				DECIMAL(16,2);
DEFINE li_orden, li_return, ll_rea_glo 	INTEGER;
DEFINE li_tipo_ramo, li_meses	INTEGER;
DEFINE _error, li_tipopro		INTEGER;
DEFINE li_uno					INTEGER;
DEFINE _cuantos					INTEGER;
DEFINE ls_ramo, ls_perpago  	CHAR(3);
DEFINE ls_impuesto, ls_tipopro	CHAR(3);
DEFINE ls_ase_lider				CHAR(3);
DEFINE a_suma		   		DECIMAL(16,2);
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
DEFINE ld_suscrita       	DECIMAL(16,2);
DEFINE ld_retenida       	DECIMAL(16,2);
DEFINE ld_imp_total       	DECIMAL(16,2);
DEFINE ld_porc_coaseg		DECIMAL(16,4);
DEFINE ld_porc_impuesto		DECIMAL(16,4);

let _fecha = sp_sis26();

BEGIN

ON EXCEPTION SET r_error
 	RETURN r_error, "Ocurrio un error al insertar emirenco Unidad:" || _no_unidad;
END EXCEPTION

SET ISOLATION TO DIRTY READ;
LET r_error = 0;
LET r_descripcion = 'RENOVACION EXITOSA...';

--SET DEBUG FILE TO "sp_pro82c.trc";
--TRACE ON;


delete from emirenco
 where no_poliza = v_poliza;

foreach
  SELECT no_unidad,
		 opcion_final,
		 suma_aseg
	INTO _no_unidad,
	  	 a_opcion,
		 a_suma
    FROM emireaut
   WHERE no_poliza = v_poliza

  if a_opcion = 9 then
 	RETURN 1, "NO HA SELECCIONADO LA OPCION PARA LA UNIDAD: " || _no_unidad;
  end if

  SELECT count(*)
	INTO _cuantos
    FROM emirerea
   WHERE no_poliza = v_poliza
     and no_unidad = _no_unidad;

  if _cuantos = 0 then
 	RETURN 1, "NO HA INGRESADO EL REASEGURO PARA LA UNIDAD: " || _no_unidad;
  end if

  if a_opcion = 0 then	--renovacion
	INSERT INTO emirenco(
	no_poliza,
	no_unidad,
	cod_cobertura,
	orden,
	tarifa,
	deducible,
	limite_1,
	limite_2,
	prima_anual,
	prima,
	descuento,
	recargo,
	prima_neta,
	date_added,
	date_changed,
	factor_vigencia,
	desc_limite1,
	desc_limite2,
	prima_vida,
	prima_vida_orig)
	select
		no_poliza,
		no_unidad,
		cod_cobertura,
		orden,
		0,
		deducible_o,
		limite_1_o,
		limite_2_o,
		prima_anual_o,
		prima_o,
		descuento_o,
		recargo_o,
		prima_neta_o,
		_fecha,
		_fecha,
		factor_vigencia,
		desc_limite1,
		desc_limite2,
		0,
		0
	  from emireau2
	 where no_poliza = v_poliza
	   and no_unidad = _no_unidad
	   and chek_o    = 1;
  end if

  if a_opcion = 1 then	--opcion 1
	INSERT INTO emirenco(
	no_poliza,
	no_unidad,
	cod_cobertura,
	orden,
	tarifa,
	deducible,
	limite_1,
	limite_2,
	prima_anual,
	prima,
	descuento,
	recargo,
	prima_neta,
	date_added,
	date_changed,
	factor_vigencia,
	desc_limite1,
	desc_limite2,
	prima_vida,
	prima_vida_orig)
	select
		no_poliza,
		no_unidad,
		cod_cobertura,
		orden,
		0,
		deducible_1,
		limite_1_1,
		limite_2_1,
		prima_anual_1,
		prima_1,
		descuento_1,
		recargo_1,
		prima_neta_1,
		_fecha,
		_fecha,
		factor_vigencia,
		desc_limite1,
		desc_limite2,
		0,
		0
	  from emireau2
	 where no_poliza = v_poliza
	   and no_unidad = _no_unidad
	   and chek_1    = 1;
  end if

  if a_opcion = 2 then	--opcion 2
	INSERT INTO emirenco(
	no_poliza,
	no_unidad,
	cod_cobertura,
	orden,
	tarifa,
	deducible,
	limite_1,
	limite_2,
	prima_anual,
	prima,
	descuento,
	recargo,
	prima_neta,
	date_added,
	date_changed,
	factor_vigencia,
	desc_limite1,
	desc_limite2,
	prima_vida,
	prima_vida_orig)
	select
		no_poliza,
		no_unidad,
		cod_cobertura,
		orden,
		0,
		deducible_2,
		limite_1_2,
		limite_2_2,
		prima_anual_2,
		prima_2,
		descuento_2,
		recargo_2,
		prima_neta_2,
		_fecha,
		_fecha,
		factor_vigencia,
		desc_limite1,
		desc_limite2,
		0,
		0
	  from emireau2
	 where no_poliza = v_poliza
	   and no_unidad = _no_unidad
	   and chek_2    = 1;
  end if
end foreach
return r_error,r_descripcion;
END
end procedure;
