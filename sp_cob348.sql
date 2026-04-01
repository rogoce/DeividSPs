-- Procedure que valida la suma 100% de los contratos de las remesas.
drop procedure sp_cob348;
create procedure "informix".sp_cob348()
returning char(10),
          smallint,
		  dec(16,6),
		  smallint;

define _no_remesa	char(10);
define _porc_part	dec(16,6);
define _cantidad	smallint;
define _renglon		smallint;
define _periodo     char(7);

set isolation to dirty read;

select periodo_verifica
  into _periodo
  from emirepar;
foreach
	select no_remesa,
		   renglon
	  into _no_remesa,
		   _renglon
	  from sac999:reacomp
	 where sac_asientos = 0
	   and tipo_registro = 2
	   and periodo       = _periodo
	 group by no_remesa, renglon

	select sum(porc_proporcion * porc_partic_prima / 100),
		   count(distinct cod_cober_reas)
	  into _porc_part,
		   _cantidad
	  from cobreaco
	 where no_remesa = _no_remesa
	   and renglon = _renglon;

	if _cantidad = 0 or _porc_part <> 100 then
	
		return _no_remesa,
			   _renglon,
			   _porc_part,
			   _cantidad
			   with resume;

	end if
	
	if _porc_part <> 100 then
	
		if _cantidad = 1 then

			update cobreaco
			   set porc_proporcion	= 100
			 where no_remesa       	= _no_remesa
			   and renglon         	= _renglon;

			return _no_remesa,
				   _renglon,
				   _porc_part,
				   _cantidad
				   with resume;

		elif _cantidad = 2 and _porc_part = 200 then

			--{
			update cobreaco
			   set porc_proporcion	= 50
			 where no_remesa       	= _no_remesa
			   and renglon         	= _renglon;

			return _no_remesa,
				   _renglon,
				   _porc_part,
				   _cantidad
				   with resume;
			--}

		elif _cantidad = 3 then

			{
			update cobreaco
			   set porc_proporcion = 50
			 where no_remesa       = _no_remesa
			   and renglon         = _renglon;

			return _no_remesa,
				   _renglon,
				   _porc_part,
				   _cantidad
				   with resume;
			}
			
		end if
	end if	
end foreach

return "",
	   0,
	   0,
	   0;

end procedure;