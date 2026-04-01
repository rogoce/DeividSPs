-- Reporte para el jefe jesus
-- creado   :20/04/2021 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_jcobgesti;

CREATE PROCEDURE "informix".sp_jcobgesti(a_ano integer)
		RETURNING 	CHAR(10) as no_poliza,      							-- No_poliza
					DATETIME YEAR TO FRACTION (5) as fecha_gestion,      	-- fecha_gestion
					CHAR(612) as desc_gestion,     							-- descripcion gestion
					char(8) as user_added,   	   								-- usuario
					CHAR(20) as no_documento,      							-- no_documento
					DATE as  fecha_aviso,          							-- fecha aviso
					smallint as tipo_aviso,      							-- tipo_aviso
					char(3) as cod_gestion,       							-- cod_gestion
					char(10) as cod_pagador;       							--cod_pagador

DEFINE _no_poliza  		  		CHAR(10);
DEFINE _fecha_gestion           DATETIME YEAR TO FRACTION (5);
DEFINE _user_added				char(8);
DEFINE _no_documento			char(20);
DEFINE _fecha_aviso				date;
DEFINE _tipo_aviso				smallint;
DEFINE _cod_gestion				char(3);
DEFINE _cod_pagador				char(10);
define _desc_gestion            char(612);
define TempString               char(612);


SET ISOLATION TO DIRTY READ;
--SKIP 634593 FIRST 211536 
foreach
	select 	a.no_poliza,
			fecha_gestion,
			desc_gestion,
			user_added,
			no_documento,
			fecha_aviso,
			tipo_aviso,
			cod_gestion,
			cod_pagador
	  into	_no_poliza,
			_fecha_gestion,
			_desc_gestion,
			_user_added,
			_no_documento,
			_fecha_aviso,
			_tipo_aviso,
			_cod_gestion,
			_cod_pagador
	  from migrarpolizas a inner join cobgesti b on a.no_poliza = b.no_poliza
--	 from cobgesti
  --  where year(fecha_gestion) = a_ano
	--WHERE date(fecha_gestion) >= '01/01/2019' and date(fecha_gestion) <= '31/12/2019'
 --and month(fecha_gestion) = '01'
-- and  day(fecha_gestion) = '18'
 --and no_documento = '2319-00043-01'
	--where no_documento = '2317-00077-01'
	--and date(fecha_gestion) = '18/07/2019'
	order by 2
          let TempString = _desc_gestion;
          LET TempString =  REPLACE(TempString, "AUTOMÃTICO", "AUTOMÁTICO");
          LET TempString =  REPLACE(TempString, 'Ã', 'A');
		  LET TempString =  REPLACE(TempString, 'Â€Š', 'E');
          LET TempString =  REPLACE(TempString, 'à', 'a');
	  LET TempString =  REPLACE(TempString, 'è', 'e');
	  LET TempString =  REPLACE(TempString, 'ì', 'i');
	  LET TempString =  REPLACE(TempString, 'ò', 'o');
	  LET TempString =  REPLACE(TempString, 'ù', 'u');
	  LET TempString =  REPLACE(TempString, 'À', 'A');
	  LET TempString =  REPLACE(TempString, 'È', 'E');
	  LET TempString =  REPLACE(TempString, 'Ì', 'I');
	  LET TempString =  REPLACE(TempString, 'Ò', 'O');
	  LET TempString =  REPLACE(TempString, 'Ù', 'U');
	  {LET TempString =  REPLACE(TempString, 'ñ', 'n');
	  LET TempString =  REPLACE(TempString, 'Ñ', 'n');
	  LET TempString =  REPLACE(TempString, 'á', 'a');
	  LET TempString =  REPLACE(TempString, 'é', 'e');
	  LET TempString =  REPLACE(TempString, 'í', 'i');
	  LET TempString =  REPLACE(TempString, 'ó', 'o');
	  LET TempString =  REPLACE(TempString, 'ú', 'u');
	  LET TempString =  REPLACE(TempString, 'Á', 'A');
	  LET TempString =  REPLACE(TempString, 'É', 'E');
	  LET TempString =  REPLACE(TempString, 'Í', 'I');
	  LET TempString =  REPLACE(TempString, 'Ó', 'O');
	  LET TempString =  REPLACE(TempString, 'Ú', 'U');}
	  LET TempString =  REPLACE(TempString, 'ç', 'c');
	  LET TempString =  REPLACE(TempString, 'Ç', 'C');
	  LET TempString =  REPLACE(TempString, '…', '...');
	  LET TempString =  REPLACE(TempString, '“', ' ');
	  LET TempString =  REPLACE(TempString, '”', ' ');
	  LET TempString =  REPLACE(TempString, "'", ' ');
	  LET TempString =  REPLACE(TempString, '"', ' ');
	  LET TempString =  REPLACE(TempString, '’', ' ');
	  LET TempString =  REPLACE(TempString, '–', ' ');
	  LET TempString =  REPLACE(TempString, '•', ' ');
	  LET TempString =  REPLACE(TempString, 'Ã', 'A');
	  LET TempString =  REPLACE(TempString, 'â', 'a');
	  LET TempString =  REPLACE(TempString, 'ê', 'e');
	  LET TempString =  REPLACE(TempString, 'î', 'i');
	  LET TempString =  REPLACE(TempString, 'ô', 'o');
	  LET TempString =  REPLACE(TempString, 'û', 'u');
	  LET TempString =  REPLACE(TempString, 'Â', 'A');
	  LET TempString =  REPLACE(TempString, 'Ê', 'E');
	  LET TempString =  REPLACE(TempString, 'Î', 'I');
	  LET TempString =  REPLACE(TempString, 'Ô', 'O');
	  LET TempString =  REPLACE(TempString, 'Û', 'U');
	  LET TempString =  REPLACE(TempString, 'Õ', 'O');
	  LET TempString =  REPLACE(TempString, 'ƒ', '');
	  LET TempString =  REPLACE(TempString, 'º', '');
	  LET TempString =  REPLACE(TempString, '¡', '');
	  LET TempString =  REPLACE(TempString, ',', '');
	  LET TempString =  REPLACE(TempString, ':', '');
	  LET TempString =  REPLACE(TempString, '<', '');
	  LET TempString =  REPLACE(TempString, '>', '');
	  LET TempString =  REPLACE(TempString, '—', '-');
	  LET TempString =  REPLACE(TempString, '‘', '');
	  LET TempString =  REPLACE(TempString, '™', '');
	  LET TempString =  REPLACE(TempString, '_', '');
	  LET TempString =  REPLACE(TempString, ';', '');
	  
	  


	  let _desc_gestion = TempString;

	RETURN	_no_poliza,
			_fecha_gestion,
			_desc_gestion,
			_user_added,
			_no_documento,
			_fecha_aviso,
			_tipo_aviso,
			_cod_gestion,
			_cod_pagador
			WITH RESUME;
end foreach

END PROCEDURE;