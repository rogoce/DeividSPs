-- crear registro para cuando insertan una unidad

-- CREADO: 		16/08/2005 POR: Armando
-- modificado:	16/08/2005 POR: Armando

drop procedure sp_pro82j;

create procedure "informix".sp_pro82j(
v_usuario 			char(8),
v_poliza 			char(10),
a_no_documento 		char(20),
a_vigencia_final 	date,
a_suma_asegurada 	integer,
a_no_unidad			char(5)
)
returning integer;

--- Actualizacion de Polizas

DEFINE _cod_producto   CHAR(5); 
DEFINE _valor_asignar  CHAR(1); 
DEFINE _error		   INTEGER;
DEFINE _suma_asegurada INTEGER;
DEFINE _vigencia_inic  DATE;
DEFINE _vigencia_final DATE;
DEFINE _cod_pagador,_telefono1,_telefono2 CHAR(10);
define ll_impuesto	   integer;	
DEFINE _direccion_1,_direccion_2 CHAR(50);
DEFINE _direcc_cob1,_direcc_cob2 CHAR(50);
define _cod_prod1	   CHAR(5);
define _cod_prod2	   CHAR(5);	
define _cod_tipoprod   char(3);
					
BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

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

	let _cod_prod1    = null;
	let _cod_prod2    = null;
	--let _cod_producto = "00312";

	foreach
		SELECT cod_producto
		  INTO _cod_producto
		  FROM emireaut
		 WHERE no_poliza = v_poliza
		exit foreach;
	end foreach

	SELECT direccion_1,
	       direccion_2
	  INTO _direcc_cob1,
	       _direcc_cob2
	  FROM emidirco
	 WHERE no_poliza = v_poliza;

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
		cod_tipoprod
		)
		values (v_poliza,
			   _cod_pagador,
		       _vigencia_inic,
		       _vigencia_final,
			   a_suma_asegurada,
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
			   a_suma_asegurada,
			   0,
			   0,
			   0,
			   0,
			   0,
			   a_no_unidad,
			   null,
			   _cod_tipoprod
			   );
return 0;
END

end procedure;