drop procedure sp_rec82;

create procedure sp_rec82()
returning smallint,
          char(50);

define _cantidad	smallint;

 select count(*)
   into _cantidad
   from recrcmae r, emipomae p
  where r.no_poliza   = p.no_poliza
	and p.cod_ramo    = "002"
	and r.no_motor    is null
	and r.actualizado = 1;

if _cantidad = 0 then
	return 0,
	       "Reclamos Correctos";
else
	return 1,
	       "Falta Numero de Motor";
end if

end procedure