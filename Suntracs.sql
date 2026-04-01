select p.no_documento, u.cod_asegurado, c.nombre
from emipouni u, emipomae p, cliclien c
where u.no_poliza = p.no_poliza
and u.cod_producto = "00870"
and u.cod_asegurado = c.cod_cliente
and estatus_poliza = 1
group by 1, 2, 3
order by 3, 1, 2

