-- Procedimiento para reporte de auditoria 
-- Creado    : 20/06/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web54;		
create procedure "informix".sp_web54()
returning	varchar(10) as No_Cotizacion,					--1
            varchar(20) as No_Inspeccion,					--2
            varchar(50)	as Asegurado,						--3
            char(3)	as Origen,								--4
            varchar(50) as Corredor,						--5
            integer as Ano,									--6
            varchar(5) as Cod_Marca,						--7
            varchar(50) as Nombre_Marca,					--8
            varchar(5) as Cod_Modelo,						--9
            varchar(50) as Nombre_Modelo,					--10
			varchar(15)as No_poliza,						--11
			date as vigencia_inicial,						--12
			date as vigencia_final,							--13
			integer as no_pagos,							--14
			dec(16,2) as suma_asegurada,					--15
			dec(16,2) as prima,								--16
			dec(16,2) as descuento,							--17
			dec(16,2) as porcentaje_comision,				--18
			varchar(50) as Nombre_coasegurador,				--19
			dec(16,2) as coaseguro_asumido,					--20
			dec(16,2) as coaseguro_cedido,			        --21
		    VARCHAR(50) AS cobertura_1,						--22
		    DEC(16,2) AS limite_1_1,                        --23
		    DEC(16,2) AS limite_2_1,                        --24
		    VARCHAR(50) AS deducible_1,                     --25
		    VARCHAR(50) AS cobertura_2,                     --26
		    DEC(16,2) AS limite_1_2,                        --27
		    DEC(16,2) AS limite_2_2,                        --28
		    VARCHAR(50) AS deducible_2,                     --29
		    VARCHAR(50) AS cobertura_3,                     --30
		    DEC(16,2) AS limite_1_3,                        --31
		    DEC(16,2) AS limite_2_3,                        --32
		    VARCHAR(50) AS deducible_3,                     --33
		    VARCHAR(50) AS cobertura_4,                     --34
		    DEC(16,2) AS limite_1_4,                        --35
		    DEC(16,2) AS limite_2_4,                        --36
		    VARCHAR(50) AS deducible_4,                     --37
		    VARCHAR(50) AS cobertura_5,                     --38
		    DEC(16,2) AS limite_1_5,                        --39
		    DEC(16,2) AS limite_2_5,                        --40
		    VARCHAR(50) AS deducible_5,                     --41
		    VARCHAR(50) AS cobertura_6,                     --42
		    DEC(16,2) AS limite_1_6,                        --43
		    DEC(16,2) AS limite_2_6,                        --44
		    VARCHAR(50) AS deducible_6,                     --45
		    VARCHAR(50) AS cobertura_7,                     --46
		    DEC(16,2) AS limite_1_7,                        --47
		    DEC(16,2) AS limite_2_7,                        --48
		    VARCHAR(50) AS deducible_7,                     --49
		    VARCHAR(50) AS cobertura_8,                     --50
		    DEC(16,2) AS limite_1_8,                        --51
		    DEC(16,2) AS limite_2_8,                        --52
		    VARCHAR(50) AS deducible_8,                     --53
		    VARCHAR(50) AS cobertura_9,                     --54
		    DEC(16,2) AS limite_1_9,                        --55
		    DEC(16,2) AS limite_2_9,                        --56
		    VARCHAR(50) AS deducible_9,                     --57
		    VARCHAR(50) AS cobertura_10,                    --58
		    DEC(16,2) AS limite_1_10,                       --59
		    DEC(16,2) AS limite_2_10,                       --60
		    VARCHAR(50) AS deducible_10,                    --61
		    CHAR(5) AS cod_producto,                        --70
		    VARCHAR(50) AS producto;                         --71
			
define _no_cotizacion		varchar(10);
define _no_inspeccion		varchar(20);
define _asegurado			varchar(50);
define _origen				char(3);
define _corredor			varchar(50);
define _ano					integer;
define _cod_marca			varchar(5);
define _nombre_marca		varchar(50);
define _cod_modelo			varchar(5);
define _nombre_modelo		varchar(50);
define _no_documento        varchar(15);
define _vigencia_inicial    date;
define _vigencia_final      date;
define _nombre              varchar(50);
define _nombre_corredor     varchar(50);
define _no_pagos             integer;
define _cod_contratante		varchar(50);
define _no_poliza           varchar(10);
define _nombre_asegurado    varchar(50);
define _cod_agente          varchar(5);
define _suma_asegurada		dec(16,2);
define _prima_suscrita		dec(16,2);
define _porc_comis_agt		dec(16,2);
define _nombre_coasegur     varchar(50);
define _coaseguro_asumido	dec(16,2); 
define _coaseguro_cedido	dec(16,2);  
define _porc_partic_ancon 	dec(16,2);
define _cod_coasegur		dec(16,2);  
define _porc_descuento      dec(16,2);  
DEFINE _cod_cobertura       VARCHAR(50);
define _nombre_cobertura    varchar(50);
DEFINE _cobertura_1         VARCHAR(50);
DEFINE _limite_1_1          DEC(16,2);
DEFINE _limite_2_1          DEC(16,2);
DEFINE _deducible_1         VARCHAR(50);
DEFINE _cobertura_2         VARCHAR(50);
DEFINE _limite_1_2          DEC(16,2);
DEFINE _limite_2_2          DEC(16,2);
DEFINE _deducible_2         VARCHAR(50);
DEFINE _cobertura_3         VARCHAR(50);
DEFINE _limite_1_3          DEC(16,2);
DEFINE _limite_2_3          DEC(16,2);
DEFINE _deducible_3         VARCHAR(50);
DEFINE _cobertura_4         VARCHAR(50);
DEFINE _limite_1_4          DEC(16,2);
DEFINE _limite_2_4          DEC(16,2);
DEFINE _deducible_4         VARCHAR(50);
DEFINE _cobertura_5         VARCHAR(50);
DEFINE _limite_1_5          DEC(16,2);
DEFINE _limite_2_5          DEC(16,2);
DEFINE _deducible_5         VARCHAR(50);
DEFINE _cobertura_6         VARCHAR(50);
DEFINE _limite_1_6          DEC(16,2);
DEFINE _limite_2_6          DEC(16,2);
DEFINE _deducible_6         VARCHAR(50);
DEFINE _cobertura_7         VARCHAR(50);
DEFINE _limite_1_7          DEC(16,2);
DEFINE _limite_2_7          DEC(16,2);
DEFINE _deducible_7         VARCHAR(50);
DEFINE _cobertura_8         VARCHAR(50);
DEFINE _limite_1_8          DEC(16,2);
DEFINE _limite_2_8          DEC(16,2);
DEFINE _deducible_8         VARCHAR(50);
DEFINE _cobertura_9         VARCHAR(50);
DEFINE _limite_1_9          DEC(16,2);
DEFINE _limite_2_9          DEC(16,2);
DEFINE _deducible_9         VARCHAR(50);
DEFINE _cobertura_10         VARCHAR(50);
DEFINE _limite_1_10          DEC(16,2);
DEFINE _limite_2_10          DEC(16,2);
DEFINE _deducible_10         VARCHAR(50);
DEFINE _cobertura_11         VARCHAR(50);
DEFINE _limite_1_11          DEC(16,2);
DEFINE _limite_2_11          DEC(16,2);
DEFINE _deducible_11         VARCHAR(50);
DEFINE _cobertura_12         VARCHAR(50);
DEFINE _limite_1_12          DEC(16,2);
DEFINE _limite_2_12          DEC(16,2);
define _deducible_12         dec(16,2);
define _cod_producto         varchar(5); 
define _nombre_producto      varchar(50);  
define _no_unidad            varchar(5);  
define _contador              smallint;    
DEFINE _limite_1          		DEC(16,2);
DEFINE _limite_2          		DEC(16,2);
DEFINE _deducible         		VARCHAR(50); 

let _no_unidad = '00001';

set isolation to dirty read;
--set debug file to "sp_rec206.trc";
--trace on;
foreach
	select no_cotizacion,
		   no_inspeccion, 
		   asegurado,
		   origen,
		   corredor,
		   ano,
		   cod_marca,
		   nombre_marca,
		   cod_modelo,
		   nombre_modelo
	  into _no_cotizacion,
		   _no_inspeccion,
		   _asegurado,
		   _origen,
		   _corredor,
		   _ano,
		   _cod_marca,
		   _nombre_marca,
		   _cod_modelo,
		   _nombre_modelo
	  from  deivid_web:auditoria_insp
	  order by no_cotizacion desc
	  
	let _no_poliza 			= "";
	let _no_documento		= "";
	let _vigencia_inicial	= "";
	let _vigencia_final		= "";
	let _no_poliza			= "";
	let _cod_contratante	= "";
	let _no_pagos			= "";
	let _nombre_corredor    = "";
	let _suma_asegurada		= "";
	let _prima_suscrita		= "";			
	let _porc_comis_agt	    = "";
	let _nombre_coasegur    = "";
	let _coaseguro_asumido  = "";
	let _coaseguro_cedido   = ""; 
	let _porc_partic_ancon  = "";
	let _cod_coasegur       = "";
	let _porc_descuento     = "";
	let _cod_cobertura		= "";
	

	  select no_documento,
			 vigencia_inic,
			 vigencia_final,
			 no_poliza,
			 cod_contratante,
			 no_pagos,
			 suma_asegurada,
			 prima_suscrita
	    into _no_documento,
		     _vigencia_inicial,
			 _vigencia_final,
			 _no_poliza,
			 _cod_contratante,
			 _no_pagos,
			 _suma_asegurada,
			 _prima_suscrita
		from emipomae
	   where cotizacion = _no_cotizacion
	     and fecha_suscripcion between '01/03/2019' and '31/05/2019' 
		 and actualizado = 1;
	
		if _cod_contratante is not null or _cod_contratante <> '' then
			select nombre
			  into _asegurado
			  from cliclien
			 where cod_cliente = _cod_contratante;
		end if
		
		if _no_poliza is not null or _no_poliza <> '' then
			foreach
				select cod_agente,
					   porc_comis_agt
				  into _cod_agente,
				       _porc_comis_agt
				  from emipoagt
				 where no_poliza = _no_poliza
				--exit foreach;
			--end foreach
			
			select nombre
			  into _corredor
			  from agtagent
			 where cod_agente = _cod_agente;
			--end if
			
			select cod_coasegur,
			       porc_partic_ancon
			  into _cod_coasegur,
				   _porc_partic_ancon
			  from emicoami
			 where no_poliza  = _no_poliza;
			
			SELECT sum(porc_descuento)
			  INTO _porc_descuento
			  FROM emiunide
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = _no_unidad;		
			
			select cod_producto
			  into _cod_producto
			  from emipouni
			 where no_poliza 	= _no_poliza
			   and no_unidad    = _no_unidad;
			
			SELECT nombre
			  INTO _nombre_producto
			  FROM prdprod
			 WHERE cod_producto = _cod_producto;
			
			if _cod_coasegur is not null or _cod_coasegur <> '' then
			
				select nombre 
				  into _nombre_coasegur
   				  from emicoase
				 where cod_coasegur = _cod_coasegur;
				
				let _coaseguro_asumido = _porc_partic_ancon;
				let _coaseguro_cedido  = 100 - _porc_partic_ancon; 
			else
				let _coaseguro_asumido = 100;
				let _coaseguro_cedido  = 0; 
			end if
			
			LET _contador = 1;
			LET _cobertura_1 = null;
			LET _limite_1_1 = 0;
			LET _limite_2_1 = 0;
			LET _deducible_1 = null;
			LET _cobertura_2 = null;
			LET _limite_1_2 = 0;
			LET _limite_2_2 = 0;
			LET _deducible_2 = null;
			LET _cobertura_3 = null;
			LET _limite_1_3 = 0;
			LET _limite_2_3 = 0;
			LET _deducible_3 = null;
			LET _cobertura_4 = null;
			LET _limite_1_4 = 0;
			LET _limite_2_4 = 0;
			LET _deducible_4 = null;
			LET _cobertura_5 = null;
			LET _limite_1_5 = 0;
			LET _limite_2_5 = 0;
			LET _deducible_5 = null;
			LET _cobertura_6 = null;
			LET _limite_1_6 = 0;
			LET _limite_2_6 = 0;
			LET _deducible_6 = null;
			LET _cobertura_7 = null;
			LET _limite_1_7 = 0;
			LET _limite_2_7 = 0;
			LET _deducible_7 = null;
			LET _cobertura_8 = null;
			LET _limite_1_8 = 0;
			LET _limite_2_8 = 0;
			LET _deducible_8 = null;
			LET _cobertura_9 = null;
			LET _limite_1_9 = 0;
			LET _limite_2_9 = 0;
			LET _deducible_9 = null;
			LET _cobertura_10 = null;
			LET _limite_1_10 = 0;
			LET _limite_2_10 = 0;
			LET _deducible_10 = null;
			LET _cobertura_11 = null;
			LET _limite_1_11 = 0;
			LET _limite_2_11 = 0;
			LET _deducible_11 = null;
			LET _cobertura_12 = null;
			LET _limite_1_12 = 0;
			LET _limite_2_12 = 0;
			LET _deducible_12 = null;

            FOREACH
				SELECT cod_cobertura,
				       limite_1,
					   limite_2,
					   deducible
				  INTO _cod_cobertura,
				       _limite_1,
					   _limite_2,
					   _deducible
				  FROM emipocob
				 WHERE no_poliza = _no_poliza
				   AND no_unidad = _no_unidad
				ORDER BY orden
				   
			   SELECT nombre
                 INTO _nombre_cobertura
				 FROM prdcober
				WHERE cod_cobertura = _cod_cobertura;
			
               IF _contador = 1 THEN			
				LET _cobertura_1 = _nombre_cobertura;
				LET _limite_1_1 = _limite_1;
				LET _limite_2_1 = _limite_2;
				LET _deducible_1 = _deducible;
               ELIF _contador = 2 THEN			
				LET _cobertura_2 = _nombre_cobertura;
				LET _limite_1_2 = _limite_1;
				LET _limite_2_2 = _limite_2;
				LET _deducible_2 = _deducible;
               ELIF _contador = 3 THEN			
				LET _cobertura_3 = _nombre_cobertura;
				LET _limite_1_3 = _limite_1;
				LET _limite_2_3 = _limite_2;
				LET _deducible_3 = _deducible;
               ELIF _contador = 4 THEN			
				LET _cobertura_4 = _nombre_cobertura;
				LET _limite_1_4 = _limite_1;
				LET _limite_2_4 = _limite_2;
				LET _deducible_4 = _deducible;
               ELIF _contador = 5 THEN			
				LET _cobertura_5 = _nombre_cobertura;
				LET _limite_1_5 = _limite_1;
				LET _limite_2_5 = _limite_2;
				LET _deducible_5 = _deducible;
               ELIF _contador = 6 THEN			
				LET _cobertura_6 = _nombre_cobertura;
				LET _limite_1_6 = _limite_1;
				LET _limite_2_6 = _limite_2;
				LET _deducible_6 = _deducible;
               ELIF _contador = 7 THEN			
				LET _cobertura_7 = _nombre_cobertura;
				LET _limite_1_7 = _limite_1;
				LET _limite_2_7 = _limite_2;
				LET _deducible_7 = _deducible;
               ELIF _contador = 8 THEN			
				LET _cobertura_8 = _nombre_cobertura;
				LET _limite_1_8 = _limite_1;
				LET _limite_2_8 = _limite_2;
				LET _deducible_8 = _deducible;
				LET _cobertura_9 = _nombre_cobertura;
               ELIF _contador = 9 THEN			
				LET _limite_1_9 = _limite_1;
				LET _limite_2_9 = _limite_2;
				LET _deducible_9 = _deducible;
               ELIF _contador = 10 THEN			
				LET _cobertura_10 = _nombre_cobertura;
				LET _limite_1_10 = _limite_1;
				LET _limite_2_10 = _limite_2;
				LET _deducible_10 = _deducible;
               ELIF _contador = 11 THEN			
				LET _cobertura_11 = _nombre_cobertura;
				LET _limite_1_11 = _limite_1;
				LET _limite_2_11 = _limite_2;
				LET _deducible_11 = _deducible;
               ELIF _contador = 12 THEN			
				LET _cobertura_12 = _nombre_cobertura;
				LET _limite_1_12 = _limite_1;
				LET _limite_2_12 = _limite_2;
				LET _deducible_12 = _deducible;
			   END IF 
			   LET _contador = _contador + 1;
            END FOREACH		

			
			return _no_cotizacion,			--1
				   _no_inspeccion,			--2
				   _asegurado,				--3
				   _origen,					--4
				   _corredor,				--5
				   _ano,					--6
				   _cod_marca,				--7
				   _nombre_marca,			--8
				   _cod_modelo,				--9
				   _nombre_modelo,			--10
				   _no_documento,		   	--11
				   _vigencia_inicial,		--12
				   _vigencia_final,			--13
				   _no_pagos,		   		--14
				   _suma_asegurada,			--15
				   _prima_suscrita,			--16
				   _porc_descuento,			--17
				   _porc_comis_agt,			--18
				   _nombre_coasegur,        --19
				   _coaseguro_asumido,      --20
				   _coaseguro_cedido,       --21
				   _cobertura_1,            --22
				   _limite_1_1,             --23
				   _limite_2_1,             --24
				   _deducible_1,			--25
				   _cobertura_2,			--26
				   _limite_1_2,				--27
				   _limite_2_2,				--28
				   _deducible_2,			--29
				   _cobertura_3,			--30
				   _limite_1_3,				--31
				   _limite_2_3,				--32
				   _deducible_3,			--33
				   _cobertura_4,			--34
				   _limite_1_4,				--35
				   _limite_2_4,				--36
				   _deducible_4,			--37
				   _cobertura_5,			--38
				   _limite_1_5,				--39
				   _limite_2_5,				--40
				   _deducible_5,			--41
				   _cobertura_6,			--42
				   _limite_1_6,				--43
				   _limite_2_6,				--44
				   _deducible_6,			--45
				   _cobertura_7,			--46
				   _limite_1_7,				--47
				   _limite_2_7,				--48
				   _deducible_7,			--49
				   _cobertura_8,			--50
				   _limite_1_8,				--51
				   _limite_2_8,				--52
				   _deducible_8,			--53
				   _cobertura_9,			--54
				   _limite_1_9,				--55
				   _limite_2_9,				--56
				   _deducible_9,			--57
				   _cobertura_10,			--58
				   _limite_1_10,			--59
				   _limite_2_10,			--60
				   _deducible_10,			--61
				   _cod_producto,			--70
				   _nombre_producto			--71
				   with resume;
			end foreach
		else
			return _no_cotizacion,			--1
				   _no_inspeccion,			--2
				   _asegurado,				--3
				   _origen,					--4
				   _corredor,				--5
				   _ano,					--6
				   _cod_marca,				--7
				   _nombre_marca,			--8
				   _cod_modelo,				--9
				   _nombre_modelo,			--10
				   _no_documento,		   	--11
				   _vigencia_inicial,		--12
				   _vigencia_final,			--13
				   _no_pagos,		   		--14
				   _suma_asegurada,			--15
				   _prima_suscrita,			--16
				   _porc_descuento,			--17
				   _porc_comis_agt,         --18
				   "",                      --19
				   "",						--20
				   "",						--21
				   "",            			--22
				   "",             			--23
				   "",             			--24
				   "",						--25
				   "",						--26
				   "",						--27
				   "",						--28
				   "",						--29
				   "",						--30
				   "",						--31
				   "",						--32
				   "",						--33
				   "",						--34
				   "",						--35
				   "",						--36
				   "",						--37
				   "",						--38
				   "",						--39
				   "",						--40
				   "",						--41
				   "",						--42
				   "",						--43
				   "",						--44
				   "",						--45
				   "",						--46
				   "",						--47
				   "",						--48	
				   "",						--49
				   "",						--50
				   "",						--51
				   "",						--52
				   "",						--53
				   "",						--54
				   "",						--55
				   "",						--56
				   "",						--57
				   "",						--58
				   "",						--59
				   "",						--60
				   "",						--61
				   "",						--70
				   ""						--71
					with resume;
		end if
end foreach

end procedure