-- Reporte para obtener datade detalles del reclamo
-- creado   :20/05/2021 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_get_rectrde2;

CREATE PROCEDURE "informix".sp_get_rectrde2()
		RETURNING 	char(10) as no_tranrec,
		            smallint  as renglon,
					CHAR(60) as desc_transaccion;     							-- descripcion gestion
					      							-- tipo_aviso
      							--cod_pagador

DEFINE _no_reclamo  		  		CHAR(10);
DEFINE _renglon						smallint;
define _desc_transaccion        	char(60);
define TempString               	char(60);
define _no_tranrec                  char(10);


SET ISOLATION TO DIRTY READ;
--SKIP 634593 FIRST 211536 
foreach
	select 	a.no_reclamo,
	        c.no_tranrec,
			c.renglon,
			c.desc_transaccion
	  into	_no_reclamo,
	        _no_tranrec,
			_renglon,
			_desc_transaccion
	  from migrarreclamos a 
	  inner join rectrmae b on a.no_reclamo = b.no_reclamo
	  inner join rectrde2 c on c.no_tranrec = b.no_tranrec
	order by 2,3
          let TempString = _desc_transaccion;
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
	  LET TempString =  REPLACE(TempString, '–', '');
	  
	  


	  let _desc_transaccion = TempString;

	RETURN	_no_tranrec,
			_renglon,
			_desc_transaccion			
			WITH RESUME;
end foreach

END PROCEDURE;