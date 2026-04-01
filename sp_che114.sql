-- Procedimiento que busca si se imprime el finiquito
-- Creado    : 23/03/2010 - Autor: Amado Perez
-- Copia del sp_che67

 drop procedure sp_che114;

create procedure sp_che114(a_no_requis char(10))
 returning char(10),
		   char(3);

define _transaccion		char(10);
define _no_tranrec      char(10);
define _cod_tipopago    char(3);
define _ramo            char(2);
define _cant            smallint;

SET ISOLATION TO DIRTY READ;

select count(*)
  into _cant
  from chqchrec
 where no_requis = a_no_requis;

if _cant > 0 then
	foreach
		select transaccion,
			   numrecla[1,2]
		  into _transaccion,
			   _ramo
		  from chqchrec
		 where no_requis = a_no_requis

		if _ramo = "02" OR _ramo = "20" OR _ramo = "23" OR _ramo = "16" OR _ramo = "19" then
			select no_tranrec,
				   cod_tipopago
			  into _no_tranrec,
				   _cod_tipopago
			  from rectrmae
			 where transaccion = _transaccion;

			if _cod_tipopago IN ('003','004') then
				return _no_tranrec,
					   _cod_tipopago;
			end if
		end if
		exit foreach;
	end foreach
end if
end procedure
