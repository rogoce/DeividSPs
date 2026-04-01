select no_documento, p.fecha_aviso_canc, p.estatus_poliza, p.vigencia_final, c.nombre, a.nombre
from emipomae p, cliclien c, emipoagt g, agtagent a
where p.carta_aviso_canc = 1
and p.cod_contratante = c.cod_cliente
and p.no_poliza = g.no_poliza
and g.cod_agente = a.cod_agente
and p.estatus_poliza <> 2
and year(p.fecha_aviso_canc) = 2006
and year(p.vigencia_final) >= 2006
