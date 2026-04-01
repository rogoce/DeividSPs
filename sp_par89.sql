drop procedure sp_par89;

create procedure "informix".sp_par89()

define _no_poliza	char(10);

foreach
 select p.no_poliza
   into _no_poliza
   from emipomae p, emipouni u, emicupol c
  where p.no_poliza      = u.no_poliza
    and u.no_poliza      = c.no_poliza
    and u.no_unidad      = c.no_unidad
    and c.cod_ubica      = "002"
    and p.actualizado    = 1
    and p.cod_ramo       in ("001", "003")
    and p.estatus_poliza = 1
    and c.suma_incendio  <> u.suma_asegurada
--	and p.no_documento   = "0100-00030-02"

	delete from emicupol
	 where no_poliza = _no_poliza;

	execute procedure sp_amm6(_no_poliza);

end foreach

end procedure