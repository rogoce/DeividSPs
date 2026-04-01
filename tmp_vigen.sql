--{
select t.no_poliza, t.no_unidad, t.cantidad, p.periodo, p.vigencia_inic, p.vigencia_final, p.fecha_cancelacion, u.fecha_emision, p.no_documento
from tmp_vigen t, emipomae p, emipouni u
where t.no_poliza = p.no_poliza
and t.no_poliza = u.no_poliza
and t.no_unidad = u.no_unidad
and t.cantidad = 1
--and p.periodo <> "2001-02"
--and no_unidad = "00085"
--group by no_poliza, no_unidad
order by 3
--}
{
select no_documento
from emipomae
where no_poliza = "61139"
--}