-- Informe Estadístico Mensual
-- Genera Información de Póliza Vencidas 
-- Creado    : 21/06/2021 - Autor: Amado Perez
 

DROP PROCEDURE sp_pro568dd;
CREATE PROCEDURE sp_pro568dd(a_periodo1 char(7), a_periodo2 char(7), a_origen CHAR(3) DEFAULT '%') 
RETURNING  smallint ;		   

	DEFINE _fecha1  		 DATE;
	DEFINE _fecha2	 		 DATE;  
	DEFINE _mes1     		 SMALLINT;
	DEFINE _mes2     	     SMALLINT;
	DEFINE _ano1     	     SMALLINT;
	DEFINE _ano2     		 SMALLINT;
	DEFINE _cod_ramo         CHAR(3);
	DEFINE _cod_subramo      CHAR(3);
	DEFINE _cnt_vencidas     INTEGER;
	DEFINE _nueva_renov      CHAR(1);
	DEFINE _no_poliza        CHAR(10);
	DEFINE _cantidad         INTEGER;

	SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;
{
	-- Descomponer los periodos en fechas
	LET _ano1 = a_periodo1[1,4];
	LET _mes1 = a_periodo1[6,7];
	
	LET _ano2 = a_periodo2[1,4];
	LET _mes2 = a_periodo2[6,7];

	LET _fecha1 = MDY(_mes1,1,_ano1);

	IF _mes2 = 12 THEN
	   LET _mes2 = 1;
	   LET _ano2 = _ano2 + 1;
	ELSE
		LET _mes2 = _mes2 + 1;
	END IF
	LET _fecha2 = MDY(_mes2,1,_ano2);
	LET _fecha2 = _fecha2 - 1;
}	

	-- Descomponer los periodos en fechas
	LET _ano1 = a_periodo1[1,4];
	LET _mes1 = a_periodo1[6,7];
	
	LET _mes1 = _mes1 - 1;
	
	IF _mes1 = 0 THEN
		LET _mes1 = 12;
		LET _ano1 = _ano1 - 1;
	END IF
	
	LET _ano2 = a_periodo2[1,4];
	LET _mes2 = a_periodo2[6,7];

	LET _fecha1 = MDY(_mes1,1,_ano1);

	LET _fecha2 = MDY(_mes2,1,_ano2);
	LET _fecha2 = _fecha2 - 1;

	FOREACH
		SELECT cod_ramo, 
			   cod_subramo,
			   nueva_renov,
               no_poliza			   
		  INTO _cod_ramo,
			   _cod_subramo,
			   _nueva_renov,
			   _no_poliza
		  FROM tmp_vence
         WHERE seleccionado = 1
	  
--		IF _cod_ramo = '020' OR _cod_ramo = '023' THEN
--			LET _cod_ramo = '002';
--		END IF

		IF _cod_ramo = '021' THEN
			LET _cod_ramo = '001';
		END IF
	  
		IF _cod_ramo = "019" and _nueva_renov = "N" THEN 
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo     = _cod_ramo
			   AND cod_subramo  = "001";
		END IF	

		IF _cod_ramo = "019" AND _nueva_renov = "R" THEN
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo     = _cod_ramo
			   AND cod_subramo  = "002";		
		END IF
		
		IF _cod_ramo = '004' OR _cod_ramo = '018' THEN
			select count(*)
			  into _cantidad
			  from emipouni
			 where no_poliza = _no_poliza;
			 
			IF _cantidad > 1 then
				UPDATE ramosubr
				   SET cnt_vencidas = cnt_vencidas + 1
				 WHERE cod_ramo     = _cod_ramo
				   AND cod_subramo     = "002";
			ELSE
				UPDATE ramosubr
				   SET cnt_vencidas = cnt_vencidas + 1
				 WHERE cod_ramo     = _cod_ramo
				   AND cod_subramo     = "001";		
			END IF			 
		END IF
		
		IF _cod_ramo = "014" OR _cod_ramo = "013" THEN	--car y montaje
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
 	         WHERE cod_ramo        = '010'
		       AND cod_subramo     = "001";
		END IF
		
		IF _cod_ramo = "010" THEN --equipo electronico
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = '010'
			   AND cod_subramo     = "002";
		END IF
		
		IF _cod_ramo = "012" THEN	--calderas
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = '010'
			   AND cod_subramo     = "003";
		END IF
		
		IF _cod_ramo = "011" THEN	--rotura de maquinaria
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = '010'
			   AND cod_subramo     = "004";
		END IF
		
		IF _cod_ramo = "022" THEN	--equipo pesado
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = '010'
			   AND cod_subramo     = "005";
		END IF
		
		IF _cod_ramo = "007" THEN	--vidrios
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = '010'
			   AND cod_subramo     = "006";
		END IF
		
		IF _cod_ramo = "008" THEN
			IF _cod_subramo = "002" OR _cod_subramo = "003" OR _cod_subramo = "018" THEN
				UPDATE ramosubr
			       SET cnt_vencidas = cnt_vencidas + 1
				 WHERE cod_ramo        = _cod_ramo
				   AND cod_subramo     = "001";
			else
				UPDATE ramosubr
			       SET cnt_vencidas = cnt_vencidas + 1
				 WHERE cod_ramo        = _cod_ramo
				   AND cod_subramo     = "002";
			end if
		END IF  
		
		if _cod_ramo = '009' and _cod_subramo in('001','002','006','009') then -- Se agregó el subramo 009 10-08-2022 ID de la solicitud	# 4243
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
		end if
		
		if _cod_ramo = '009' and _cod_subramo = '003' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
		end if
		
		if _cod_ramo = '009' and _cod_subramo in ('004', '008') then --> Se incluye el subramo 008 MARINE CARGO STP
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "004";
		end if
			  
		if _cod_ramo = '001' and _cod_subramo = '001' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
		end if

		if _cod_ramo = '001' and _cod_subramo = '002' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
		end if
	  
		if _cod_ramo = '001' and _cod_subramo in ('003','004','006','007') then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "003";
		end if

		if _cod_ramo = '003' and _cod_subramo = '001' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
		end if
		
		if _cod_ramo = '003' and _cod_subramo <> '001' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
		end if

		if _cod_ramo = '017' and _cod_subramo = '001' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
		end if
		
		if _cod_ramo = '017' and _cod_subramo = '002' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
		end if
		
		if _cod_ramo = '005' and _cod_subramo = '001' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
		end if
		
		if _cod_ramo = '016' and _cod_subramo <> '007' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
		end if

		if _cod_ramo = '016' and _cod_subramo = '017' then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "002";
		end if
		
		if _cod_ramo in ('006','015','027','026') then	
			UPDATE ramosubr
			   SET cnt_vencidas = cnt_vencidas + 1
			 WHERE cod_ramo        = _cod_ramo
			   AND cod_subramo     = "001";
		end if


		IF _cod_ramo in ('002','020','023') THEN
		  IF (_cod_ramo = '002' AND _cod_subramo IN ('001','003','011','015','016')) OR (_cod_ramo = '020' AND _cod_subramo IN ('001','003')) OR (_cod_ramo = '023' AND _cod_subramo IN ('001','006','007')) THEN
				UPDATE ramosubr
				   SET cnt_vencidas = cnt_vencidas + 1
				 WHERE cod_ramo        = '002'
				   AND cod_subramo     = "001";
		  else
				UPDATE ramosubr
				   SET cnt_vencidas = cnt_vencidas + 1
				 WHERE cod_ramo        = '002'
				   AND cod_subramo     = "002";
		  end if
		END IF

		
	END FOREACH
	return 0;
END PROCEDURE	  