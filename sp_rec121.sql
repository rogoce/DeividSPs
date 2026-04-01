-- Procedimiento que Busca el banco y chequera dado el ramo de excepcion

-- Creado    : 19/05/2006 - Autor: Armando Moreno.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_rec121;

CREATE PROCEDURE "informix".sp_rec121(a_no_reclamo	char(10))
returning char(3),char(3);

define _no_poliza		char(10);
define _cod_ramo        char(3);
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _existe		    integer;

SET ISOLATION TO DIRTY READ;

select no_poliza
  into _no_poliza
  from recrcmae
 where no_reclamo = a_no_reclamo;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

select count(*)
  into _existe
  from chqbanch
 where cod_ramo = _cod_ramo
   and cod_banco = '001';

if _existe > 0 then
else
	let _cod_ramo = '*';	
end if

select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = _cod_ramo
   and cod_banco = '001';

Return _cod_banco,_cod_chequera;

END PROCEDURE
