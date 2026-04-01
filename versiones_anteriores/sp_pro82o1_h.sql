-- Procedimiento que Retorna la Depreciacion por Unidad

-- Creado    : 18/05/2001 - Autor: Demetrio Hurtado Almanza  
-- Modificado: 18/05/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_prod_ren_sel_de_pol_a_ren - DEIVID, S.A.

DROP PROCEDURE sp_pro82o;

CREATE PROCEDURE "informix".sp_pro82o(a_no_poliza CHAR(10))
RETURNING DEC(16,2)		 ;	

DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cod_tipoveh		CHAR(3);
DEFINE _uso_auto		CHAR(1);
DEFINE _no_motor		CHAR(30);
DEFINE _nombre_marca	CHAR(50);
DEFINE _nombre_modelo	CHAR(50);
DEFINE _nombre_tipoveh	CHAR(50);
DEFINE _porc_depre		DEC(16,2);
DEFINE _suma_asegurada  DEC(16,2);
DEFINE _cod_marca		CHAR(5);
DEFINE _cod_modelo		CHAR(5);
define _nuevo           smallint;
define _no_documento  	char(20);
define _cod_subramo, _cod_ramo     char(3);

define _resultado		     integer;
define _ano_auto		     integer;
define _ano_actual		     smallint;
let _porc_depre	= 0.00;
let a_no_poliza = trim(a_no_poliza);

SELECT no_documento,cod_ramo
  INTO _no_documento,_cod_ramo
  FROM emipomae
 WHERE no_poliza = a_no_poliza;	

if _cod_ramo not in ('023','020','002') then	
	return 0.00  WITH RESUME;
else		 
			 
	FOREACH
	 SELECT no_unidad,
			suma_asegurada		
	   INTO _no_unidad,
			_suma_asegurada		
	   FROM emipouni
	  WHERE no_poliza = a_no_poliza
	  

		SELECT porc_depreciacion
		  INTO _porc_depre
		  FROM emirepod
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_depre IS NULL THEN
			LET _porc_depre = 0;
			INSERT INTO emirepod
			VALUES (a_no_poliza, _no_unidad, 0.00);
		END IF
		
		SELECT no_motor,
			   cod_tipoveh,
			   uso_auto
		  INTO _no_motor,
			   _cod_tipoveh,
			   _uso_auto
		  FROM emiauto
		 WHERE no_poliza = a_no_poliza
		   AND no_unidad = _no_unidad;

		SELECT cod_marca,
			   cod_modelo
		  INTO _cod_marca,
			   _cod_modelo
		  FROM emivehic
		 WHERE no_motor = _no_motor;

		SELECT nombre
		  INTO _nombre_marca
		  FROM emimarca
		 WHERE cod_marca = _cod_marca;

		SELECT nombre
		  INTO _nombre_modelo
		  FROM emimodel
		 WHERE cod_modelo = _cod_modelo;

		SELECT nombre
		  INTO _nombre_tipoveh
		  FROM emitiveh
		 WHERE cod_tipoveh = _cod_tipoveh;
		 
		select nuevo
		  into _nuevo
		  from emivehic
		 where no_motor = _no_motor;
		--- 
		{
		let _ano_actual = year(current); --year(v_vigen_ini);


		select no_motor,
			   uso_auto,
			   cod_tipoveh
		  into _no_motor,
			   _uso_auto,
			   _cod_tipoveh
		  from emiauto
		 where no_poliza = v_poliza
		   and no_unidad = _no_unidad;

		let _resultado = 0;

		select ano_auto,nuevo
		  into _ano_auto,_nuevo
		  from emivehic
		 where no_motor = _no_motor;
		 
		let _resultado = _ano_actual - _ano_auto;

		if (_resultado <= 0) or (_resultado = 1) then
			let _resultado = 1;
		else
			if _nuevo <> 1 then
				let _resultado = _resultado + 1;
			end if	
		end if	
		
		select porc_depre
		  into _porc_depre
		  from emidepre
		 where uso_auto  = _uso_auto
		   and _resultado between ano_desde and ano_hasta;	
	}
		---		   
		 
		 {
		 TIPO VEHICULO	003 TAXIS
		 USO	COMERCIAL – C
		 CONDICION	NUEVO	USADO
		 % DEPRECIACION	20	15			 
		 }
		 
		 if _cod_tipoveh = '003' then
			if _uso_auto = 'C' then
				if _nuevo = 1 then
					let _porc_depre	= 20;	
				else
					let _porc_depre	= 15;							
				end if	

			end if
		 end if 	 


		RETURN _porc_depre		   
			   WITH RESUME;
				
	END FOREACH
end if
END PROCEDURE;
