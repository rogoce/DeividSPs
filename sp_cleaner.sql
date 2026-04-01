-- Reporte para Jesus
-- creado:	16/10/2023 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE "informix".sp_cleaner;

CREATE PROCEDURE "informix".sp_cleaner(a_desc_gestion varchar(100))
		RETURNING VARCHAR(100) as texto; 
		
	  define TempString               char(100);
	  
	  let TempString = a_desc_gestion;
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
	  
	  let a_desc_gestion = TempString;
	  
	  RETURN	a_desc_gestion;
END PROCEDURE;