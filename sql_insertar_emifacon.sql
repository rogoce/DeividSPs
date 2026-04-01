insert into emifacon
select no_poliza, '00001', '00006', cod_cober_reas, orden, cod_contrato, cod_ruta,
porc_partic_suma, porc_partic_prima, suma_asegurada, prima
from emifacon
where no_poliza = '54319'
and no_endoso = '00001'
and no_unidad = '00005';