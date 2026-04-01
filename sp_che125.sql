-- Procedimiento que busca si se imprime el finiquito

-- Creado    : 29/03/2011 - Autor: Amado Perez
-- Copia del sp_che67

 drop procedure sp_che125;

create procedure sp_che125(a_no_requis char(10))
 returning char(2);

define _cod_tipopago    char(3);
define _transaccion		char(10);
define _no_tranrec      char(10);
define _cant            smallint;
define _ramo            char(2);

SET ISOLATION TO DIRTY READ;

select count(*)
  into _cant
  from chqchrec
 where no_requis = a_no_requis;

if _cant > 0 then

	foreach
	 select	numrecla[1,2]
	   into	_ramo
	   from	chqchrec
	  where no_requis = a_no_requis

	 return _ramo;

	 exit foreach;    
	   
	end foreach
 end if

end procedure
