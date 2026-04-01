-- Procedimiento que devuelve el orden de una ubicacion de cumulos
--
-- Creado    : 25/04/2013 - Autor: Armando Moreno
-- Modificado: 25/04/2013 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis184;

CREATE PROCEDURE "informix".sp_sis184(_cod_ubica char(3))
RETURNING smallint;

DEFINE _orden  	smallint;


if _cod_ubica = '001' then
   let _orden = 1;
elif _cod_ubica = '006' then
   let _orden = 2;
elif _cod_ubica = '007' then
   let _orden = 3;
elif _cod_ubica = '002' then
   let _orden = 4;
elif _cod_ubica = '008' then
   let _orden = 5;
elif _cod_ubica = '003' then
   let _orden = 6;
elif _cod_ubica = '004' then
   let _orden = 7;
elif _cod_ubica = '005' then
   let _orden = 8;
else
   let _orden = 99;
end if

RETURN _orden;

END PROCEDURE;