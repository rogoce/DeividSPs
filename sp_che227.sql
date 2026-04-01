-- Procedimiento que Realiza la insercion de la nva. requisicion a partir de la que se anulo

-- Creado    : 10/05/2006 - Autor: Armando Moreno M.
-- mod		 : 01/08/2006
-- mod       : 08/07/2009   Amado Perez -- Se agrego codigo para cuando son auto y soda
-- mod       : 16/11/2010	Amado Perez -- Se agrego codigo para cuando son requisiciones de origen "S" Devolucion de Primas
-- Amado en caso que haya algun cambio en este procedure se de replicar a este otro sp_che208

drop procedure sp_che227;
create procedure "informix".sp_che227(a_valor_ant       char(10))
RETURNING   	  INTEGER;

define _error 		   	  integer;
define _error_desc		  char(100);
define _no_cheque	   	  integer;
define _transaccion	   	  char(10);
define _fecha_actual   	  date;
define v_periodo	   	  char(7);
define _origen_cheque  	  char(1);
define _renglon		   	  smallint;
define _firma_electronica smallint;
define _autorizado		  smallint;
define _cod_banco	   	  char(3);
define _cod_chequera   	  char(3);
define _numrecla	   	  char(18);
define _cod_cte_chq       char(10);
define _cod_cte_rec		  char(10);
define _flag,_cnt	          smallint;
define _autorizado_por    char(8);
define _cant_dias         integer;

define _fecha_reclamo     date;

--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET LOCK MODE TO WAIT;

let _fecha_actual = CURRENT;
select count(*)
  into _cnt
  from chqchrec
 where no_requis = a_valor_ant;
 
if _cnt is null then
	let _cnt = 0;
end if
if _cnt > 0 then
else
	return 0;
end if
foreach

	select numrecla
	  into _numrecla
	  from chqchrec
	 where no_requis = a_valor_ant

	select fecha_reclamo
	  into _fecha_reclamo
	  from recrcmae
	 where numrecla = _numrecla
       and actualizado = 1;
	   
	let _cant_dias = _fecha_actual - _fecha_reclamo;
	let _flag = 0;
	if _cant_dias >= 365 then
		let _flag = 1;
		exit foreach;
	end if
	   
end foreach

if _flag = 1 then
	return 1;
end if

return 0;
END
end procedure