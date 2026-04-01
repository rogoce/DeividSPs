-- Funcion que Obtiene los Codigos de un String y los Inserta en una tabla temporal (tmp_codigos)
-- Creado    : 17/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_html02;
create procedure "informix".sp_html02(a_num dec(16,2))
returning varchar(25);

define _codigo           char(25);      
define _char_1           char(1);
define _tipo             char(1);
define _contador         integer;    
define _tamano           smallint;
define _string           varchar(25);
define _string2          varchar(25);
define _num2             dec(16,2);
define i                 smallint;
define _cociente         smallint;
define _num3             int8;
define _coma_punto       char(1);

--set debug file to "sp_html2.trc";
--trace on;

let _num2 = a_num * 100;

let _num3 = _num2;

let _string = _num3;

let _tamano = length(_string);

LET _string2 = "";

LET i = 0;

WHILE (_tamano > 0) LOOP
   LET i = i + 1;   
   
   IF i = 3 THEN
	LET _coma_punto = '.';
   ELSE
	LET _coma_punto = ',';
   END IF
   
   LET _cociente = MOD(i,3);
   
   IF _cociente = 0 THEN
	LET _string2 = _coma_punto || _string2;
   END IF
   
   LET _string2 = SUBSTR(_string, _tamano, 1) || _string2;
   
   LET _tamano = _tamano - 1;

 --  IF i = 10 THEN EXIT;
 --  ELSE
 --  CONTINUE;
 --  END IF
END LOOP;

IF length(_string2) = 2 THEN
	LET _string2 = '0.' || _string2;
END IF
return _string2;
end procedure;