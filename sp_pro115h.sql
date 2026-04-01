-- Procedimiento para traer a los corredores 
-- Creado    : 07/07/2016 - Autor: Henry Girón 
-- Modificado: 07/07/2001 - Autor: Henry Girón 
-- SIS v.2.0 - DEIVID, S.A. 

DROP PROCEDURE sp_pro115h; 
CREATE PROCEDURE "informix".sp_pro115h(a_no_documento CHAR(20)) 
  RETURNING INTEGER, 
   			CHAR(10);  

  DEFINE v_retorno		CHAR(10);
  DEFINE v_error        INTEGER;
  DEFINE _no_documento  CHAR(20);
  DEFINE _nombre, _nombre_par, _conyuge, _hijo1, _hijo2, _hijo3, _hijo4  CHAR(100); 
  DEFINE _placa         CHAR(10);
  DEFINE _no_motor      CHAR(30);
  DEFINE _cod_sucursal, _cod_parentesco CHAR(3);
  DEFINE _vigencia_inic DATE;
  DEFINE _no_unidad     CHAR(5);
  DEFINE _cant          SMALLINT;
  DEFINE _limite_1, _limite_2, _no_poliza CHAR(10);
  DEFINE _campo_documento  CHAR(20);
  DEFINE _cod_ramo, _cod_subramo CHAR(3);
  define a_fecha1 DATE;
  define a_fecha2 DATE;
  define _opcion char(2);
  DEFINE _hijo5, _hijo6, _hijo7, _hijo8 CHAR(50);
  DEFINE _plan			CHAR(50);
  DEFINE _beneficio1	CHAR(65);
  DEFINE _beneficio2	CHAR(65);
  DEFINE _beneficio3	CHAR(65);
  DEFINE _beneficio4	CHAR(65);
  DEFINE _periodo               CHAR(7);  
  DEFINE _producto_cartasal2    CHAR(5);
  DEFINE _prod_new     smallint;
  define _ano_char     CHAR(4);

  SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "sp_pro115h.trc"; 
--trace on;

--DELETE FROM fox_carnets;
--DELETE FROM fox_salud;

LET v_retorno = 'ERROR';
LET _nombre_par = '';
LET _conyuge = '';
LET _hijo1 = '';
LET _hijo2 = '';
LET _hijo3 = '';
LET _hijo4 = '';
LET _hijo5 = '';
LET _hijo6 = '';
LET _hijo7 = '';
LET _hijo8 = '';
let _opcion = '';
let _producto_cartasal2 = '';

let _no_poliza = sp_sis21(a_no_documento);

	-- Panama 1, Panama 2, Global, Colectivo, Especial, Vital
	FOREACH
		SELECT x.no_documento,
			   y.nombre,
			   v.vigencia_inic,
			   v.no_unidad,
			   x.no_poliza,
			   x.cod_subramo,
			   x.fecha_suscripcion,
			   z.plan,
			   z.beneficio1,
			   z.beneficio2,
			   z.beneficio3,
			   z.beneficio4
		  INTO _no_documento, 
			   _nombre, 
			   _vigencia_inic, 
			   _no_unidad, 
			   _no_poliza, 
			   _cod_subramo, 
			   a_fecha1,
			   _plan,
			   _beneficio1,
			   _beneficio2,
			   _beneficio3,
			   _beneficio4			   
		  FROM emipouni v, emipomae x, cliclien y , prdprod z, emicarnet u
		 WHERE v.no_poliza = x.no_poliza 
		   AND v.activo = 1 
		   AND y.cod_cliente = v.cod_asegurado 
		   AND x.actualizado = 1  
		   AND x.cod_ramo = '018' 
--		   AND x.cod_subramo in ('007','008','009','010','011','016','018') 
		   AND x.cod_subramo in ('007','008','009','010','011','013','015','016','017','020','018')
		   AND v.no_poliza = _no_poliza 
	       AND z.cod_producto = v.cod_producto
           AND u.cod_carnet = z.cod_carnet
	   
		   -- AND x.fecha_suscripcion >= a_fecha1 
		   -- AND x.fecha_suscripcion <= a_fecha2

		LET _cant = 0;

		LET _limite_1 = '';
		LET _limite_2 = '';
		LET _nombre_par = '';
		LET _conyuge = '';
		LET _hijo1 = '';
		LET _hijo2 = '';
		LET _hijo3 = '';
		LET _hijo4 = '';
		let _prod_new = 0;
	--	trace on;
		let _periodo = sp_sis39(_vigencia_inic);
		let _ano_char = year(current); 
		let _periodo  = _ano_char || "-" || _periodo[6,7];		
		
		SELECT count(*)
		  INTO _prod_new
		  FROM emicartasal2
		 WHERE no_documento = a_no_documento
		   AND periodo = _periodo;				
		   
		   if _prod_new > 0 or _prod_new is not null then
		
		SELECT cod_producto
		  INTO _producto_cartasal2
		  FROM emicartasal2
		 WHERE no_documento = a_no_documento
		   AND periodo = _periodo;				   
		   
		SELECT plan,
			   beneficio1,
			   beneficio2,
			   beneficio3,
			   beneficio4
		  INTO _plan,
			   _beneficio1,
			   _beneficio2,
			   _beneficio3,
			   _beneficio4	
 		  FROM prdprod 
		 WHERE cod_producto = _producto_cartasal2 ;
		 
		 end if

		IF _cod_subramo = '009' THEN
			SELECT limite_1,  
				   limite_2 
			  INTO _limite_1,
				   _limite_2
			  FROM emipocob  
			 WHERE no_poliza = _no_poliza 
			   AND no_unidad = _no_unidad
			   AND cod_cobertura = '00570';
		END IF
--trace off;
		FOREACH 
			SELECT x.nombre,  
				   y.cod_parentesco  
			  INTO _nombre_par, 
				   _cod_parentesco 
			  FROM cliclien x, emidepen y  
			 WHERE x.cod_cliente = y.cod_cliente 
			   AND y.no_poliza = _no_poliza 
			   AND y.no_unidad = _no_unidad 
			   AND y.activo = 1 

			   IF _cod_parentesco = '001' THEN 
				  LET _conyuge	=  _nombre_par;  
			   ELSE 
				  LET _cant = _cant + 1; 
				  IF _cant = 1 THEN 
					 LET _hijo1 = _nombre_par; 
				  ELIF _cant = 2 THEN 
					 LET _hijo2 = _nombre_par; 
				  ELIF _cant = 3 THEN 
					 LET _hijo3 = _nombre_par; 
				  ELIF _cant = 4 THEN
					 LET _hijo4 = _nombre_par; 
				  ELIF _cant = 5 THEN 
					 LET _hijo5 = _nombre_par; 
				  ELIF _cant = 6 THEN 
					 LET _hijo6 = _nombre_par; 
				  ELIF _cant = 7 THEN 
					 LET _hijo7 = _nombre_par; 
				  ELIF _cant = 8 THEN 
					 LET _hijo8 = _nombre_par; 
				  END IF
			   END IF

		END FOREACH

		BEGIN
			ON EXCEPTION IN(-239,-268)
				--CONTINUE FOREACH;				
				update fox_hech_sal 
				   set impreso = 0
				 where poliza = _no_documento;
			END EXCEPTION
			INSERT INTO fox_hech_sal(
			   poliza,
			   efectiva,
			   asegurado,
			   conyugue,
			   hijo1,
			   hijo2,
			   hijo3,
			   hijo4,
			   limite1,
			   limite2,
			   unidad
			   )
			   VALUES(
			   _no_documento,
			   _vigencia_inic,
			   _nombre,
			   _conyuge,
			   _hijo1,
			   _hijo2,
			   _hijo3,
			   _hijo4,
			   _limite_1,
			   _limite_2,
			   _no_unidad
			   );
		END

		BEGIN 
		ON EXCEPTION SET v_error 
			IF 	v_error <> -268 AND v_error <> -239 THEN 
			   UPDATE fox_salud
			      SET poliza = _no_documento,
					  efectiva = _vigencia_inic,
					  asegurado = _nombre,
					  conyuge = _conyuge,
					  hijo1 = _hijo1,
					  hijo2 = _hijo2,
					  hijo3 = _hijo3,
					  hijo4 = _hijo4,
					  limite1 = _limite_1,
					  limite2 = _limite_2,
					  unidad = _no_unidad,
					  cod_subramo = _cod_subramo,
					  impreso = 0,
					  hijo5 = _hijo5,
					  hijo6 = _hijo6,
					  hijo7 = _hijo7,
					  hijo8 = _hijo8,
					  beneficio1 = _beneficio1,
					  beneficio2 = _beneficio2,
					  beneficio3 = _beneficio3,
					  beneficio4 = _beneficio4,
					  plan       = _plan 
			    WHERE poliza = _no_documento 
			      AND unidad = _no_unidad; 
		   --		RETURN v_error,
		   --		       trim(v_retorno); 
		   
	   
			END IF	        
		END EXCEPTION
			INSERT INTO fox_salud(
			   poliza,
			   efectiva,
			   asegurado,
			   conyuge,
			   hijo1,
			   hijo2,
			   hijo3,
			   hijo4,
			   limite1,
			   limite2,
			   unidad,
			   cod_subramo,
			   hijo5,
			   hijo6,
			   hijo7,
			   hijo8,
			   plan,
			   beneficio1,
			   beneficio2,
			   beneficio3,
			   beneficio4
			   )
			   VALUES(
			   _no_documento,
			   _vigencia_inic,
			   _nombre,
			   _conyuge,
			   _hijo1,
			   _hijo2,
			   _hijo3,
			   _hijo4,
			   _limite_1,
			   _limite_2,
			   _no_unidad,
			   _cod_subramo,
			   _hijo5,
			   _hijo6,
			   _hijo7,
			   _hijo8,
			   _plan,
			   _beneficio1,
			   _beneficio2,
			   _beneficio3,
			   _beneficio4			   			   
			   );
		END

	END FOREACH


	-- Dependientes nuevos activos y no activos

	FOREACH 
		SELECT no_poliza, 
			   no_unidad 
		  INTO _no_poliza, 
			   _no_unidad 
		  FROM emidepen 
		 WHERE ((date_added >= a_fecha1) 
			OR (no_activo_desde >= a_fecha1)) 
		   and no_poliza = _no_poliza
	  GROUP BY no_poliza, no_unidad

		 SELECT no_documento,
				cod_ramo,
				cod_subramo
		   INTO _no_documento,
				_cod_ramo,
				_cod_subramo
		   FROM emipomae
		  WHERE no_poliza = _no_poliza
			AND actualizado = 1
			AND cod_ramo = '018'
			-- AND cod_subramo IN ('007','008','009','010','011','016','018')
			AND cod_subramo IN ('007','008','009','010','011','013','015','016','017','020','018'); 

		 LET _campo_documento = NULL;
		 LET _limite_1 = '';
		 LET _limite_2 = '';
		 LET _nombre_par = '';
		 LET _conyuge = '';
		 LET _hijo1 = '';
		 LET _hijo2 = '';
		 LET _hijo3 = '';
		 LET _hijo4 = '';

		 SELECT poliza
		   INTO _campo_documento
		   FROM fox_salud
		  WHERE poliza = _no_documento
			AND unidad = _no_unidad;

		 IF _campo_documento IS NOT NULL THEN
			CONTINUE FOREACH;
		 END IF

		SELECT y.nombre,
			   v.vigencia_inic
		  INTO _nombre,
			   _vigencia_inic
		  FROM emipouni v, cliclien y
		 WHERE v.activo = 1 
		   AND y.cod_cliente = v.cod_asegurado 
		   AND v.no_poliza = _no_poliza
		   AND v.no_unidad = _no_unidad;

		IF _cod_subramo = '009' THEN
			SELECT limite_1,  
				   limite_2 
			  INTO _limite_1,
				   _limite_2
			  FROM emipocob  
			 WHERE no_poliza = _no_poliza 
			   AND no_unidad = _no_unidad
			   AND cod_cobertura = '00570';
		END IF

		LET _cant = 0;

		FOREACH
			SELECT x.nombre, 
				   y.cod_parentesco 
			  INTO _nombre_par,
				   _cod_parentesco
			  FROM cliclien x, emidepen y 
			 WHERE x.cod_cliente = y.cod_cliente
			   AND y.no_poliza = _no_poliza 
			   AND y.no_unidad = _no_unidad
			   AND y.activo = 1

			   IF _cod_parentesco = '001' THEN
				  LET _conyuge	=  _nombre_par;
			   ELSE
				  LET _cant = _cant + 1;
				  IF _cant = 1 THEN
					 LET _hijo1 = _nombre_par;
				  ELIF _cant = 2 THEN
					 LET _hijo2 = _nombre_par;
				  ELIF _cant = 3 THEN
					 LET _hijo3 = _nombre_par;
				  ELIF _cant = 4 THEN
					 LET _hijo4 = _nombre_par; 
				  ELIF _cant = 5 THEN 
					 LET _hijo5 = _nombre_par; 
				  ELIF _cant = 6 THEN 
					 LET _hijo6 = _nombre_par; 
				  ELIF _cant = 7 THEN 
					 LET _hijo7 = _nombre_par; 
				  ELIF _cant = 8 THEN 
					 LET _hijo8 = _nombre_par; 			   
					END IF
			   END IF

		END FOREACH

		BEGIN
		ON EXCEPTION SET v_error
			IF 	v_error <> -268 AND v_error <> -239 THEN
			   UPDATE fox_salud
			      SET poliza = _no_documento,
					  efectiva = _vigencia_inic,
					  asegurado = _nombre,
					  conyuge = _conyuge,
					  hijo1 = _hijo1,
					  hijo2 = _hijo2,
					  hijo3 = _hijo3,
					  hijo4 = _hijo4,
					  limite1 = _limite_1,
					  limite2 = _limite_2,
					  unidad = _no_unidad,
					  cod_subramo = _cod_subramo,
					  impreso = 0,
					  hijo5 = _hijo5,
					  hijo6 = _hijo6,
					  hijo7 = _hijo7,
					  hijo8 = _hijo8,
					  beneficio1 = _beneficio1,
					  beneficio2 = _beneficio2,
					  beneficio3 = _beneficio3,
					  beneficio4 = _beneficio4,
					  plan       = _plan		   					  
			    WHERE poliza = _no_documento
			      AND unidad = _no_unidad;
		   --		RETURN v_error,
		   --		       trim(v_retorno);
		   

			END IF	        
		END EXCEPTION
			INSERT INTO fox_salud(
			   poliza,
			   efectiva,
			   asegurado,
			   conyuge,
			   hijo1,
			   hijo2,
			   hijo3,
			   hijo4,
			   limite1,
			   limite2,
			   unidad,
			   cod_subramo,
			   hijo5,
			   hijo6,
			   hijo7,
			   hijo8,
			   plan,
			   beneficio1,
			   beneficio2,
			   beneficio3,
			   beneficio4			   			   
			   )
			   VALUES(
			   _no_documento,
			   _vigencia_inic,
			   _nombre,
			   _conyuge,
			   _hijo1,
			   _hijo2,
			   _hijo3,
			   _hijo4,
			   _limite_1,
			   _limite_2,
			   _no_unidad,
			   _cod_subramo,
			   _hijo5,
			   _hijo6,
			   _hijo7,
			   _hijo8,
			   _plan,
			   _beneficio1,
			   _beneficio2,
			   _beneficio3,
			   _beneficio4			   			   
			   );
		END
	END FOREACH


--trace off;

LET v_retorno = "EXITO";

RETURN 0, trim(v_retorno);


END PROCEDURE

