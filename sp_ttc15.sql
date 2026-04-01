-- Determina los registros en cobreaco que no tienen 100

drop procedure sp_ttc15;

create procedure "informix".sp_ttc15()
returning char(10),
          smallint,
		  smallint,
		  dec(16,2);

define _no_remesa	char(10);
define _renglon		smallint;
define _porc_prop	dec(16,2);
define _cantidad	smallint;

foreach
 SELECT no_remesa, 
        renglon
   into _no_remesa,
        _renglon
   FROM movim_tec_pri_tt
  WHERE COD_SITUACION = 13
	AND FLAG IN(1,2,4)
  group by 1, 2

	select count(*),
	       sum(porc_proporcion)
	  into _cantidad,
	       _porc_prop
	  from cobreaco
	 where no_remesa = _no_remesa
	   and renglon = _renglon;
	   
--	if _cantidad = 1 and _porc_prop <> 100 then

--		update cobreaco
--		   set porc_proporcion = 100
--		 where no_remesa       = _no_remesa
--		   and renglon         = _renglon;

		return _no_remesa,
		       _renglon,
			   _cantidad,
			   _porc_prop
			   with resume;

--	end if

end foreach

return "0",   
        0,
		0,
		0;

end procedure