-- Procedimiento para renovar desde la pagina web polizas sobat.
-- creado    : 30/04/2021 - Autor: Roman Gordon--
-- Sis v.2.0 - Deivid, s.a.

drop procedure sp_web64;
create procedure "informix".sp_web64(v_usuario char(8), v_poliza char(10), v_cod_grupo char(5))
RETURNING SMALLINT, CHAR(100),char(10);

define _mensaje			char(100);
define _valor           SMALLINT;
define v_poliza_nuevo 	char(10);
define _cod_compania    char(3);
define _periodo         char(7);
define _no_documento	char(20);

--SET DEBUG FILE TO "sp_web64.trc";
--TRACE ON;

let _cod_compania = '001';

call sp_sis13 (_cod_compania, 'PRO', '02', 'par_no_poliza') returning v_poliza_nuevo;

call sp_pro320c(v_usuario,v_poliza,v_poliza_nuevo) returning _valor,_mensaje;  

if _valor <> 0 then
	return _valor,_mensaje,'';
end if

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = _cod_compania;

-- Actualizacion de Polizas

update emipomae
   set periodo        = _periodo,
   	   cod_grupo 	  = v_cod_grupo
 where no_poliza      = v_poliza_nuevo;

call sp_sis17 (v_poliza_nuevo) returning _valor;

if _valor <> 0 then
	return _valor,_mensaje,'';
end if

Update emirepo
	Set estatus   = 5,
		 renovar   = 1
 Where no_poliza = v_poliza;

Update hemirepo
	Set estatus_final = 3
 Where no_poliza = v_poliza;
 
Update emipomae
	Set renovada  = 1
 Where no_poliza = v_poliza;

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = v_poliza_nuevo;

call sp_sis157(v_poliza_nuevo,v_poliza,_no_documento,v_usuario)returning _valor;

if _valor <> 0 then
	return _valor,_mensaje,'';
end if

return _valor,_mensaje,v_poliza_nuevo;

end procedure;