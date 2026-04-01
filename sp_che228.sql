-- Procedimiento que Realiza la insercion de la nva. requisicion a partir de la que se anulo

-- Creado    : 10/05/2006 - Autor: Armando Moreno M.
-- mod		 : 01/08/2006
-- mod       : 08/07/2009   Amado Perez -- Se agrego codigo para cuando son auto y soda
-- mod       : 16/11/2010	Amado Perez -- Se agrego codigo para cuando son requisiciones de origen "S" Devolucion de Primas
-- Amado en caso que haya algun cambio en este procedure se de replicar a este otro sp_che208

drop procedure sp_che228;
create procedure "informix".sp_che228()
RETURNING char(10),char(50),char(10),INTEGER,integer,date,date,decimal(16,2),char(19);

define _cod_cliente char(10);
define _no_requis   char(10);
define _no_cheque,_no_cheque_ant,_cnt integer;
define _monto      dec(16,2);
define _n_cliente  char(50);
define _fecha_anulado,_fecha_impresion date;
define _numrecla     char(19);

--SET DEBUG FILE TO "sp_che50.trc"; 
--trace on;

BEGIN

SET LOCK MODE TO WAIT;

CREATE TEMP TABLE tmp_imp(
	no_requis		CHAR(10),
	no_cheque		integer,
	cod_cliente		char(10),
	no_cheque_ant		integer
	) WITH NO LOG;

foreach

	select cod_cliente,
		   monto
	  into _cod_cliente,
		   _monto
	  from chqchmae
	 where periodo >= "2014-01"
	   and pagado = 0
	   and origen_cheque = '3'
	   and no_cheque_ant is not null
       and monto <> 0
	   
	select count(*)
	  into _cnt
   	  from chqchmae
	 where cod_cliente   = _cod_cliente
	   and origen_cheque = '3'
	   and monto         = _monto;
	   
	if _cnt >= 3 then
		foreach
			select no_requis,
			       no_cheque,
				   no_cheque_ant
			  into _no_requis,
			       _no_cheque,
				   _no_cheque_ant
			  from chqchmae
			 where cod_cliente   = _cod_cliente
			   and origen_cheque = '3'
			   and monto         = _monto
			   
			insert into tmp_imp(no_requis,no_cheque,cod_cliente,no_cheque_ant)
			values(_no_requis,_no_cheque,_cod_cliente,_no_cheque_ant);
		end foreach
	end if
	   
end foreach

foreach
	select cod_cliente,no_requis,no_cheque,no_cheque_ant
	  into _cod_cliente,_no_requis,_no_cheque,_no_cheque_ant
	  from tmp_imp
	  order by cod_cliente,_no_cheque_ant
	  
	select nombre
      into _n_cliente
      from cliclien
     where cod_cliente = _cod_cliente;
	 
	select monto,fecha_impresion, fecha_anulado
	  into _monto,_fecha_impresion,_fecha_anulado
	  from chqchmae
	 where no_requis = _no_requis;
	let _numrecla = ''; 
    foreach
	 select numrecla
	   into _numrecla
	   from chqchrec
	  where no_requis = _no_requis
	  
	  exit foreach;
	end foreach
	  
	  return _cod_cliente,_n_cliente,_no_requis,_no_cheque,_no_cheque_ant,_fecha_impresion,_fecha_anulado,_monto,_numrecla with resume;
	       
end foreach

END
end procedure