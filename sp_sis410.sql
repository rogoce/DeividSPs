  
--drop procedure sp_sis410;

create procedure "informix".sp_sis410(a_anno integer)
returning char(20),
          integer,integer,datetime year to fraction(5);


define _cod_entrada		char(10);

define i			    integer;
define _no_rec_fin      integer;
define _cuantos,_cuantos1 integer;
define _fecha           datetime year to fraction(5);


define _cod_entrada_min   char(10);

set isolation to dirty read;


foreach
 select cod_entrada
   into _cod_entrada_min
   from atcdocma
  where year(fecha) = a_anno
  order by cod_entrada

  exit foreach;
end foreach

let _cuantos = 0;

foreach
 select cod_entrada,fecha
   into _cod_entrada,_fecha
   from atcdocma
  where year(fecha) = a_anno
  order by cod_entrada

  if (_cod_entrada - _cod_entrada_min) > 1 then

     let _cuantos = (_cod_entrada - _cod_entrada_min) - 1;

	 FOR i = 1 TO _cuantos

		 return "Falta Bloque: ", _cod_entrada_min + 1,_cuantos,_fecha with resume;

		 let _cod_entrada_min = _cod_entrada_min + 1;

	 END FOR

	 let _cod_entrada_min = _cod_entrada;
	 let _cuantos = 0;
  else

	 let _cod_entrada_min = _cod_entrada;
  end if
	
end foreach


Return "",0,0,_fecha;

end procedure