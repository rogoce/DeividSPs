/* Editar este archivo con codificación UTF-8 */

DROP PROCEDURE "informix".fun_quitar_acentos; 


CREATE PROCEDURE fun_quitar_acentos (CADENA lvarchar)
RETURNING lvarchar;
  DEFINE TempString lvarchar;
  DEFINE _cadena_esp, _cadena_rem char(24);
  DEFINE _caracter1,  _caracter2  char(1);
  DEFINE _i  integer;
  
 -- set debug file to "sp_quitar_acento.trc";
 -- trace on;
  
  LET TempString = CADENA;
  
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
  LET TempString =  REPLACE(TempString, 'ñ', 'n');
  LET TempString =  REPLACE(TempString, "Ñ", "N");
  LET TempString =  REPLACE(TempString, 'á', 'a');
  LET TempString =  REPLACE(TempString, 'é', 'e');
  LET TempString =  REPLACE(TempString, 'í', 'i');
  LET TempString =  REPLACE(TempString, 'ó', 'o');
  LET TempString =  REPLACE(TempString, 'ú', 'u');
  LET TempString =  REPLACE(TempString, 'Á', 'A');
  LET TempString =  REPLACE(TempString, 'É', 'E');
  LET TempString =  REPLACE(TempString, 'Í', 'I');
  LET TempString =  REPLACE(TempString, 'Ó', 'O');
  LET TempString =  REPLACE(TempString, 'Ú', 'U');
  LET TempString =  REPLACE(TempString, 'ç', 'c');
  LET TempString =  REPLACE(TempString, 'Ç', 'C');
  LET TempString =  REPLACE(TempString, 'Ä', 'A');
  LET TempString =  REPLACE(TempString, 'Ë', 'E');
  LET TempString =  REPLACE(TempString, 'Ï', 'I');
  LET TempString =  REPLACE(TempString, 'Ö', 'O');
  LET TempString =  REPLACE(TempString, 'Ü', 'U'); 
  LET TempString =  REPLACE(TempString, 'ä', 'A');
  LET TempString =  REPLACE(TempString, 'ë', 'E');
  LET TempString =  REPLACE(TempString, 'ï', 'I');
  LET TempString =  REPLACE(TempString, 'ö', 'O');
  LET TempString =  REPLACE(TempString, 'ü', 'U'); 
  
  LET TempString =  REPLACE(TempString, ",", " ");
  LET TempString =  REPLACE(TempString, ";", " ");
  LET TempString =  REPLACE(TempString, "|", " ");
  LET TempString =  REPLACE(TempString, "'", " ");
  LET TempString =  REPLACE(TempString, "!'", " ");
  LET TempString =  REPLACE(TempString, "$", " ");
  LET TempString =  REPLACE(TempString, "%", " ");
  LET TempString =  REPLACE(TempString, "&", " ");
  LET TempString =  REPLACE(TempString, "^", " ");
  LET TempString =  REPLACE(TempString, "'", "");
  LET TempString =  REPLACE(TempString, "Ã", "A");
  LET TempString =  REPLACE(TempString, ".", " ");
  LET TempString =  REPLACE(TempString, "?", "");
  LET TempString =  REPLACE(TempString, '"', ' ');
  
 
  RETURN TempString;
END PROCEDURE;