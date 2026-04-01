-- Seguro Obligatorio - APADEA 
-- Creado   :  26/10/2011 - Autor:  Giron Henry 
-- SIS v.2.0 d_- DEIVID, S.A.
-- execute procedure sp_pr100("001","001","2011-01","2011-01","020;")
DROP PROCEDURE sp_pr100;
CREATE PROCEDURE "informix".sp_pr100(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_ramo     CHAR(255) DEFAULT '*'
)
--RETURNING char(7),integer,dec(16,2),dec(16,2);
RETURNING CHAR(3),CHAR(100),char(4),smallint,char(50),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),CHAR(255);
--RETURNING char(4),smallint,char(50),dec(16,2),dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint,dec(16,2),smallint;

DEFINE _no_poliza    	CHAR(10); 
DEFINE _cod_ramo     	CHAR(3);  
DEFINE _cod_subramo  	CHAR(3);  
DEFINE _cod_grupo    	CHAR(5);  
DEFINE _doc_poliza   	CHAR(20); 
DEFINE _cod_sucursal 	CHAR(3);  
DEFINE _cod_coasegur 	CHAR(3);  
DEFINE _porcentaje   	DEC(16,4);
DEFINE _cod_agente   	CHAR(5);
DEFINE _cod_cliente  	CHAR(10); 
DEFINE _porc_comis_agt 	DEC(5,2);
DEFINE v_filtros     	CHAR(255);
DEFINE _count        	INTEGER;
DEFINE _contador     	INT;
define _cod_tipoprod	char(3);
DEFINE _periodo1        char(7);
DEFINE _periodo         char(7);
DEFINE _tipo            CHAR(01);
DEFINE _hay         	INTEGER;

SET ISOLATION TO DIRTY READ;   
-- Tabla Temporal
CREATE TEMP TABLE tmp_montos(
		no_poliza           CHAR(10)  NOT NULL,
		ramo	       		CHAR(3)   NOT NULL,
		periodo	       		CHAR(7)   NOT NULL,
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		incurrido_bruto     DEC(16,2) DEFAULT 0 NOT NULL,
		siniestro_pagado    DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL,
		tipo			    char(1)
		) WITH NO LOG;
CREATE INDEX xie01_tmp_montos ON tmp_montos(no_poliza,ramo,periodo);

CREATE TEMP TABLE tmp_apadea (
        ramo      CHAR(3) DEFAULT "000" NOT NULL,
        anio      CHAR(4) DEFAULT "1900" NOT NULL,
        renglon   INTEGER DEFAULT 0 NOT NULL,
        ene 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        feb 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        mar 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        abr 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        may 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        jun 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        jul 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        ago 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        sep 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        oct 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        nov 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        dic 	  DECIMAL(16,2) DEFAULT 0 NOT NULL,
        total     DECIMAL(16,2) DEFAULT 0 NOT NULL ) WITH NO LOG;
CREATE INDEX xie01_tmp_apadea ON tmp_apadea(ramo,anio,renglon);


BEGIN
DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);
DEFINE _prima_suscrita   DECIMAL(16,2);
-- Procesos v_filtros
LET _hay = 0;
LET v_filtros ="";
LET v_filtros = sp_preram4(a_compania,a_agencia,a_periodo1,a_periodo2);

--Filtro por Ramo
IF a_ramo <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_ramo);
	LET _tipo     = sp_sis04(a_ramo); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
	    -- Primas Suscritas
		FOREACH 
		 SELECT a.prima_suscrita,		
		 		a.no_poliza,
				a.periodo,
				b.cod_ramo
		   INTO	_prima_suscrita,
				_no_poliza,
				_periodo,
				_cod_ramo
		   FROM endedmae a, emipomae b 
		  WHERE a.cod_compania = a_compania
		    AND a.actualizado  = 1
			AND a.cod_compania = b.cod_compania
		    AND b.actualizado  = 1
			AND a.no_poliza    = b.no_poliza
		    AND a.periodo      >= a_periodo1 
		    AND a.periodo      <= a_periodo2
	        AND b.cod_ramo IN(SELECT codigo FROM tmp_codigos)

				INSERT INTO tmp_montos(
				no_poliza, 
				ramo,
				periodo,          
				prima_suscrita,
				tipo
				)
				VALUES(
				_no_poliza,
				_cod_ramo,
				_periodo,
				_prima_suscrita,
				"1"
				);

		END FOREACH	  
		-- Incurrido Bruto 
		FOREACH
			SELECT (a.pagado_bruto + a.reserva_bruto),
				   (a.pagado_neto  + a.reserva_neto),
				   a.periodo,
				   a.cod_ramo
			  INTO _incurrido_bruto,
			       _siniestro_pagado,
				   _periodo,
				   _cod_ramo
			  FROM tmp_incurrid a
			 WHERE a.periodo      >= a_periodo1 
			   AND a.periodo      <= a_periodo2
	           AND a.cod_ramo IN(SELECT codigo FROM tmp_codigos)

			INSERT INTO tmp_montos(
			no_poliza,
			ramo,  
			periodo,         
			incurrido_bruto,     
			siniestro_pagado,
			tipo
			)
			VALUES(
			_no_poliza,
			_cod_ramo,
			_periodo,
			_incurrido_bruto,     
			_siniestro_pagado,
			"2"
			);

		END FOREACH


	ELSE
	    -- Primas Suscritas
		FOREACH 
		 SELECT a.prima_suscrita,		
		 		a.no_poliza,
				a.periodo,
				b.cod_ramo
		   INTO	_prima_suscrita,
				_no_poliza,
				_periodo,
				_cod_ramo
		   FROM endedmae a, emipomae b 
		  WHERE a.cod_compania = a_compania
		    AND a.actualizado  = 1
			AND a.cod_compania = b.cod_compania
		    AND b.actualizado  = 1
			AND a.no_poliza    = b.no_poliza
		    AND a.periodo      >= a_periodo1 
		    AND a.periodo      <= a_periodo2
	        AND b.cod_ramo NOT IN(SELECT codigo FROM tmp_codigos)

				INSERT INTO tmp_montos(
				no_poliza, 
				ramo,
				periodo,          
				prima_suscrita,
				tipo
				)
				VALUES(
				_no_poliza,
				_cod_ramo,
				_periodo,
				_prima_suscrita,
				"1"
				);

		END FOREACH	  
		-- Incurrido Bruto 
		FOREACH
			SELECT (a.pagado_bruto + a.reserva_bruto),
				   (a.pagado_neto  + a.reserva_neto),
				   a.periodo,
				   a.cod_ramo
			  INTO _incurrido_bruto,
			       _siniestro_pagado,
				   _periodo,
				   _cod_ramo
			  FROM tmp_incurrid a
			 WHERE a.periodo      >= a_periodo1 
			   AND a.periodo      <= a_periodo2
	           AND a.cod_ramo NOT IN(SELECT codigo FROM tmp_codigos)

			INSERT INTO tmp_montos(
			no_poliza,
			ramo,  
			periodo,         
			incurrido_bruto,     
			siniestro_pagado,
			tipo
			)
			VALUES(
			_no_poliza,
			_cod_ramo,
			_periodo,
			_incurrido_bruto,     
			_siniestro_pagado,
			"2"
			);

		END FOREACH


	END IF
	DROP TABLE tmp_codigos;
ELSE
	-- Primas Suscritas
	FOREACH 
	 SELECT a.prima_suscrita,		
	 		a.no_poliza,
			a.periodo,
			b.cod_ramo
	   INTO	_prima_suscrita,
			_no_poliza,
			_periodo,
			_cod_ramo
	   FROM endedmae a, emipomae b 
	  WHERE a.cod_compania = a_compania
	    AND a.actualizado  = 1
		AND a.cod_compania = b.cod_compania
	    AND b.actualizado  = 1
		AND a.no_poliza    = b.no_poliza
	    AND a.periodo      >= a_periodo1 
	    AND a.periodo      <= a_periodo2

			INSERT INTO tmp_montos(
			no_poliza, 
			ramo,
			periodo,          
			prima_suscrita,
			tipo
			)
			VALUES(
			_no_poliza,
			_cod_ramo,
			_periodo,
			_prima_suscrita,
			"1"
			);

	END FOREACH	 
	-- Incurrido Bruto 
	FOREACH
		SELECT (a.pagado_bruto + a.reserva_bruto),
			   (a.pagado_neto  + a.reserva_neto),
			   a.periodo,
			   a.cod_ramo
		  INTO _incurrido_bruto,
		       _siniestro_pagado,
			   _periodo,
			   _cod_ramo
		  FROM tmp_incurrid a
		 WHERE a.periodo      >= a_periodo1 
		   AND a.periodo      <= a_periodo2

		INSERT INTO tmp_montos(
		no_poliza,
		ramo,  
		periodo,         
		incurrido_bruto,     
		siniestro_pagado,
		tipo
		)
		VALUES(
		_no_poliza,
		_cod_ramo,
		_periodo,
		_incurrido_bruto,     
		_siniestro_pagado,
		"2"
		);

	END FOREACH

END IF
DROP TABLE tmp_incurrid;
END

BEGIN

DEFINE _incurrido_bruto  DECIMAL(16,2);		   
DEFINE _siniestro_pagado DECIMAL(16,2);		   
DEFINE _prima_suscrita   DECIMAL(16,2);		   
DEFINE _prima_pagada     DECIMAL(16,2);
DEFINE _cant_poliza      integer;
DEFINE _periodo          char(7);
DEFINE _anio     		 DECIMAL(16,2);  
DEFINE _renglon  		 DECIMAL(16,2);  
DEFINE _ene 	 		 DECIMAL(16,2);  
DEFINE _feb 	 		 DECIMAL(16,2);
DEFINE _mar 	 		 DECIMAL(16,2);  
DEFINE _abr 	 		 DECIMAL(16,2);  
DEFINE _may 	 		 DECIMAL(16,2);  
DEFINE _jun 	 		 DECIMAL(16,2);
DEFINE _jul 	 		 DECIMAL(16,2);  
DEFINE _ago 	 		 DECIMAL(16,2);  
DEFINE _sep 	 		 DECIMAL(16,2);  
DEFINE _oct 	 		 DECIMAL(16,2);
DEFINE _nov 	 		 DECIMAL(16,2);  
DEFINE _dic 	 		 DECIMAL(16,2);  
DEFINE _total    		 DECIMAL(16,2);  
DEFINE _desc_renglon   	 CHAR(50); 
DEFINE _desc_ramo   	 CHAR(100); 
DEFINE _cod_ramo   	     CHAR(3); 

DEFINE _i_ene 	 		 smallint;  
DEFINE _i_feb 	 		 smallint;
DEFINE _i_mar 	 		 smallint;  
DEFINE _i_abr 	 		 smallint;  
DEFINE _i_may 	 		 smallint;  
DEFINE _i_jun 	 		 smallint;
DEFINE _i_jul 	 		 smallint;  
DEFINE _i_ago 	 		 smallint;  
DEFINE _i_sep 	 		 smallint;  
DEFINE _i_oct 	 		 smallint;
DEFINE _i_nov 	 		 smallint;  
DEFINE _i_dic 	 		 smallint; 

LET _ene   = 0;	
LET _feb   = 0;	
LET _mar   = 0;	
LET _abr   = 0;	
LET _may   = 0;	
LET _jun   = 0;	
LET _jul   = 0;	
LET _ago   = 0;	
LET _sep   = 0;	
LET _oct   = 0;	
LET _nov   = 0;	
LET _dic   = 0;	
LET _total = 0;

LET _i_ene = 0;	
LET _i_feb = 0;	
LET _i_mar = 0;	
LET _i_abr = 0;	
LET _i_may = 0;	
LET _i_jun = 0;	
LET _i_jul = 0;	
LET _i_ago = 0;	
LET _i_sep = 0;	
LET _i_oct = 0;	
LET _i_nov = 0;	
LET _i_dic = 0;	

LET _desc_renglon = "";
LET _desc_ramo = "";

FOREACH 
 SELECT SUM(prima_suscrita),
        SUM(prima_pagada),		
		SUM(incurrido_bruto),
		SUM(siniestro_pagado),
		periodo,
		ramo
   INTO	_prima_suscrita,
		_prima_pagada,
		_incurrido_bruto,
		_siniestro_pagado,
		_periodo,
		_cod_ramo
   FROM tmp_montos
  GROUP BY ramo,periodo
  ORDER BY ramo asc,periodo asc


	SELECT COUNT(no_poliza)
	  INTO _cant_poliza
      FROM tmp_montos  
     WHERE periodo = _periodo 
       AND tipo = 1;

--   RETURN _periodo,_cant_poliza,_prima_suscrita,_incurrido_bruto with resume;  	

		select count(*)
		  into _hay
		  from tmp_apadea
		 where anio = _periodo[1,4] and ramo = _cod_ramo;

		if _hay = 0 then
			insert into tmp_apadea(ramo,anio,renglon,ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total)
			values (_cod_ramo,_periodo[1,4],1,_ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total);
			insert into tmp_apadea(ramo,anio,renglon,ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total)
			values (_cod_ramo,_periodo[1,4],2,_ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total);
			insert into tmp_apadea(ramo,anio,renglon,ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total)
			values (_cod_ramo,_periodo[1,4],3,_ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total);
		end if 

		if _periodo[6,7] = "01" then
			update tmp_apadea
			   set ene         = ene + _cant_poliza    , total = total + _cant_poliza    			 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo											 
			   and renglon     = 1 ; 
			update tmp_apadea
			   set ene         = ene + _prima_suscrita , total = total + _prima_suscrita 			 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo											 
			   and renglon     = 2 ; 
			update tmp_apadea
			   set ene         = ene + _incurrido_bruto, total = total + _incurrido_bruto			 
			 where anio        = _periodo[1,4]  and ramo = _cod_ramo											 
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "02" then
			update tmp_apadea
			   set feb         = feb + _cant_poliza		 , total = total + _cant_poliza    		 	
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set feb         = feb + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set feb         = feb + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "03" then
			update tmp_apadea
			   set mar         = mar + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set mar         = mar + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set mar         = mar + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "04" then
			update tmp_apadea
			   set abr         = abr + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set abr         = abr + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set abr         = abr + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "05" then
			update tmp_apadea
			   set may         = may + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set may         = may + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set may         = may + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "06" then
			update tmp_apadea
			   set jun         = jun + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set jun         = jun + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set jun         = jun + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "07" then
			update tmp_apadea
			   set jul         = jul + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set jul         = jul + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set jul         = jul + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "08" then
			update tmp_apadea
			   set ago         = ago + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set ago         = ago + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set ago         = ago + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "09" then
			update tmp_apadea
			   set sep         = sep + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set sep         = sep + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set sep         = sep + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "10" then
			update tmp_apadea
			   set oct         = oct + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set oct         = oct + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set oct         = oct + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "11" then
			update tmp_apadea
			   set nov         = nov + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set nov         = nov + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set nov         = nov + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		elif _periodo[6,7] = "12" then
			update tmp_apadea
			   set dic         = dic + _cant_poliza		 , total = total + _cant_poliza    
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 1 ; 
			update tmp_apadea
			   set dic         = dic + _prima_suscrita	 , total = total + _prima_suscrita 
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 2 ; 
			update tmp_apadea
			   set dic         = dic + _incurrido_bruto	 , total = total + _incurrido_bruto
			 where anio        = _periodo[1,4] and ramo = _cod_ramo
			   and renglon     = 3 ; 
		end if 
END FOREACH

FOREACH 
 SELECT ene,
		feb,
		mar,
		abr,
		may,
		jun,
		jul,
		ago,
		sep,
		oct,
        nov,
		dic,
		total,
		anio,   
		renglon,
		ramo		 		
   INTO	_ene,
   		_feb,
   		_mar,
   		_abr,
   		_may,
   		_jun,
   		_jul,
   		_ago,
		_sep,
		_oct,
		_nov,
		_dic,
		_total,
		_anio,  
		_renglon,
		_cod_ramo		   
   FROM tmp_apadea
  ORDER BY ramo asc,anio asc,renglon asc

		if _renglon = 1 then
			let _desc_renglon = "No. Poliza : ";
		elif _renglon = 2 then
			let _desc_renglon = "Primas     : ";
		elif _renglon = 3 then
			let _desc_renglon = "Siniestros : ";
		end if

		SELECT nombre
		  INTO _desc_ramo
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

    RETURN _cod_ramo,_desc_ramo,_anio,_renglon,_desc_renglon,_total,_ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,v_filtros with resume;  	
--    RETURN _anio,_renglon,_desc_renglon,_total,_ene,_i_ene,_feb,_i_feb,_mar,_i_mar,_abr,_i_abr,_may,_i_may,_jun,_i_jun,_jul,_i_jul,_ago,_i_ago,_sep,_i_sep,_oct,_i_oct,_nov,_i_nov,_dic,_i_dic, with resume; 


END FOREACH

END 
DROP TABLE tmp_montos;
DROP TABLE tmp_apadea;


END PROCEDURE;




	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   