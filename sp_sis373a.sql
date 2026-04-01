-- Procedimiento que Realiza la Busqueda de la firma si lleva o no la poliza a imprimir

-- Creado    : 03/04/2003 - Autor: Amado Perez  
-- Modificado: 02/09/2008 - Autor: Amado Perez -- Se modifica la manera de asignar las firmas, ahora sera por limites del ramo

drop procedure sp_sis373;

create procedure "informix".sp_sis373(a_poliza CHAR(10), a_endoso CHAR(5))
 RETURNING CHAR(25), CHAR(20), integer,char(30);
--}
DEFINE _firma          CHAR(25);
DEFINE _ls_autoriza    CHAR(20);
DEFINE _ls_cotizacion  CHAR(10);
DEFINE _li_cotizacion  INT;
DEFINE _linea_rapida   INT;
DEFINE _user_added     CHAR(10);
DEFINE _descripcion    CHAR(30);
DEFINE _cod_ramo       CHAR(3);
DEFINE _cod_subramo    CHAR(3);
DEFINE _cod_endomov    CHAR(3);
DEFINE _cod_sucursal   CHAR(3);
DEFINE _nueva_renov    CHAR(1);
DEFINE _suma_asegurada DEC(16,2);
DEFINE _limite_firma   DEC(16,2);
DEFINE _prima_suscrita DEC(16,2);
DEFINE _ramo_sis       SMALLINT;
DEFINE _cod_grupo      CHAR(5);
DEFINE _no_documento   CHAR(20);
DEFINE _wf_firma_aprob CHAR(20);

--SET DEBUG FILE TO "sp_sis373.trc"; 
					--trace on;


--IF a_endoso <> '00000' THEN
--    RETURN "","",0,"";
--END IF
set isolation to dirty read;

let _linea_rapida = 0;
let _descripcion = "";
let _firma = "";
let _wf_firma_aprob = "";

IF a_endoso = '00000' THEN
	FOREACH WITH HOLD
		SELECT cod_ramo,
		       cod_subramo,
			   nueva_renov,
			   suma_asegurada,
		       cotizacion,
			   linea_rapida,
			   user_added,
			   cod_sucursal,
			   cod_grupo,
			   no_documento,
			   wf_firma_aprob
		  INTO _cod_ramo,   
		       _cod_subramo,
			   _nueva_renov,
			   _suma_asegurada,
		       _ls_cotizacion,
			   _linea_rapida,
			   _user_added,
			   _cod_sucursal,
			   _cod_grupo,
			   _no_documento,
			   _wf_firma_aprob
		  FROM emipomae
		 WHERE no_poliza = a_poliza
	--	   AND nueva_renov = 'N'	 > Se quita esta condicion para la nueva validacion de firmas 3-9-2008 Amado<


--		LET _li_cotizacion = _ls_cotizacion;

	    SELECT ramo_sis 
		  INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

	{	SELECT TRIM(userautoriza)
		  INTO _ls_autoriza
		  FROM wf_cotizacion
		 WHERE nrocotizacion = _li_cotizacion;

		SELECT firma
		  INTO _firma
		  FROM wf_firmas
		 WHERE usuario = _ls_autoriza;

	    LET _firma = "C:\DEIVID\" || _firma;
	}
	-->** Se cambio para que traiga la firma del Sr. Chamorro -- 03/01/2008 **<--

		SELECT valor_parametro 
		  INTO _ls_autoriza
		  FROM inspaag
		 WHERE codigo_parametro = "firma_autorizada"
		   AND codigo_agencia   = _cod_sucursal;

	-->**<--

	    IF _ls_autoriza IS NULL THEN   --si no encuentra la firma, se pone la de csa matriz

			SELECT valor_parametro 
			  INTO _ls_autoriza
			  FROM inspaag
			 WHERE codigo_parametro = "firma_autorizada"
			   AND codigo_agencia   = '001';
		    
			--LET _ls_autoriza = "";
	    END IF

	    IF _wf_firma_aprob IS NULL THEN
			LET _wf_firma_aprob = "";
	    END IF

 	    IF _no_documento = '1610-00462-01' THEN -->CASO: 10082 USER: GPEREZ - QUE LOS CERTIFICADOS TRAIGAN FIRMA AUTOMATICA MINSA
		   RETURN "",
				  _ls_autoriza,
				  0,
				  "";
		END IF
	 
		if _wf_firma_aprob <> "" then
		    LET _ls_autoriza = _wf_firma_aprob;
		end if

		if _linea_rapida = 1 then
  --		let _ls_autoriza = "VIELKAR";
  --		let _ls_autoriza = trim(_ls_autoriza);
			select descripcion
			  into _descripcion
			  from insuser
			 where usuario = _user_added;
			let _firma = trim(_user_added);
		end if

		if _descripcion is null then
			let _descripcion = "";
		end if

		IF _ramo_sis = 3 THEN  --> Todos los ramos excepto fianzas
		    LET _ls_autoriza = "";
			LET _descripcion = "";	
		END IF	

	   {	if _ramo_sis = 7 and _cod_grupo = '01016' then
		else
		 --> Logica para la validacion de las firmas segun limites 3-9-2008 Amado <--
			IF _ramo_sis = 1 OR _nueva_renov = "R" THEN	   --> Si el ramo es automovil o es renovacion
				IF _nueva_renov = "R" THEN
					IF _ramo_sis = 3 THEN  --> Todos los ramos excepto fianzas
					    LET _ls_autoriza = "";
						LET _descripcion = "";	
					END IF	
				END IF
			ELSE						 --> No es ni automovil ni renovacion
			    LET _limite_firma = 0;

			    SELECT limite_firma		 --> Busca el limite por ramo si el limite es mayor que la suma asegurada
				  INTO _limite_firma
				  FROM prdramo
				 WHERE cod_ramo = _cod_ramo
				   AND limite_firma >= _suma_asegurada;


			    IF _limite_firma = 0 OR _limite_firma IS NULL THEN
				    LET _ls_autoriza = "";
					LET _descripcion = "";	
				ELSE
			    	IF _ramo_sis = 8 THEN                                       --> Si es Multiriesgo
						IF _cod_subramo <> "001" AND _cod_subramo <> "002" THEN	--> Si es diferente de Residencial y Comercial
						    LET _ls_autoriza = "";
							LET _descripcion = "";	
						END IF  
					END IF
				END IF
			END IF
		end if } 

		RETURN _firma,
		       _ls_autoriza,
			   _linea_rapida,
			   _descripcion
			   WITH RESUME;

	END FOREACH
ELSE
	FOREACH WITH HOLD	
		SELECT cod_endomov,
		       prima_suscrita,
			   wf_firma_aprob,
			   cod_sucursal
		  INTO _cod_endomov,
		       _prima_suscrita,
			   _wf_firma_aprob,
			   _cod_sucursal
		  FROM endedmae
		 WHERE no_poliza = a_poliza
		   AND no_endoso = a_endoso

        SELECT cod_ramo
		  INTO _cod_ramo
		  FROM emipomae
		 WHERE no_poliza = a_poliza;

	    SELECT ramo_sis 
		  INTO _ramo_sis
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		SELECT valor_parametro 						  --> Se busca quien firma
		  INTO _ls_autoriza
		  FROM inspaag
		 WHERE codigo_parametro = "firma_autorizada"
 		   AND codigo_agencia   = _cod_sucursal; 

	    IF _ls_autoriza IS NULL THEN   --si no encuentra la firma, se pone la de csa matriz

			SELECT valor_parametro 
			  INTO _ls_autoriza
			  FROM inspaag
			 WHERE codigo_parametro = "firma_autorizada"
			   AND codigo_agencia   = '001';
		    
			--LET _ls_autoriza = "";
	    END IF

	    IF _wf_firma_aprob IS NULL THEN
			LET _wf_firma_aprob = "";
	    END IF

		if _wf_firma_aprob <> "" then
		    LET _ls_autoriza = _wf_firma_aprob;
		end if

		IF _ramo_sis = 3 THEN      --> Todos los ramos excepto fianzas
		    LET _ls_autoriza = "";
		END IF				

		RETURN "",
		       _ls_autoriza,
			   0,
			   _descripcion
			   WITH RESUME;

	END FOREACH
END IF

end procedure;
