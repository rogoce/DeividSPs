-- Reporte para obtener datade detalles del reclamo
-- creado   :20/05/2021 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_get_recnotas;

CREATE PROCEDURE "informix".sp_get_recnotas()
		RETURNING 	CHAR(10)  as no_reclamo,      							-- No_poliza
					DATETIME year to fraction(5) as fecha_nota,     						-- descripcion gestion
					varchar(250) as desc_nota,      							-- tipo_aviso
					date as fecha_aviso,
					char(8) as user_added,
                    smallint as flag_web_corr;					
      							--cod_pagador

DEFINE _no_reclamo  		  		CHAR(10);
DEFINE _fecha_nota					DATETIME year to fraction(5);
define _desc_nota        	        varchar(250);
define TempString               	varchar(250);
define _fecha_aviso                 date;
define _user_added                  char(8);
define _flag_web_corr               smallint;


SET ISOLATION TO DIRTY READ;
--SKIP 634593 FIRST 211536 
foreach
	select 	a.no_reclamo,
			b.fecha_nota,
			b.desc_nota,
			b.fecha_aviso,
			b.user_added,
			b.flag_web_corr
	  into	_no_reclamo,
			_fecha_nota,
			_desc_nota,
			_fecha_aviso,
			_user_added,
			_flag_web_corr
	  from migrarreclamos a inner join recnotas b on a.no_reclamo = b.no_reclamo
	order by 1,2
          let TempString = _desc_nota;
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
	  
	  


	  let _desc_nota = TempString;

	RETURN	_no_reclamo,
	        _fecha_nota,
			_desc_nota,
			_fecha_aviso,
			_user_added,
			_flag_web_corr
			WITH RESUME;
end foreach

END PROCEDURE;