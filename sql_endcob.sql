select no_unidad, cod_cobertura, prima_anual, prima_sin_descto, prima, descuento, recargo, factor, limite_inic, deducible 
--select sum(prima_anual), sum(prima_sin_descto), sum(prima)
from endcob
where no_poliza = 30946
and no_endoso = 0
{
--update endedcob
--set prima_anual = prima
select * --no_poliza, no_endoso
from endedcob
where (prima_anual = 0
           or  prima = 0
or  prima_neta = 0
--and year(date_added) = 2001
--and factor_vigencia = 1
--group by no_poliza, no_endoso
order  by no_poliza, no_endoso
}