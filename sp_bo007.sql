-- Cuando No existe Cobmoros lo crea
-- 
-- Creado    : 08/11/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 08/11/2004 - Autor: Demetrio Hurtado Almanza
--

--drop procedure sp_bo007;

create procedure "informix".sp_bo007(a_no_documento char(20), a_periodo char(7))

define _no_poliza	char(10);

--set debug file to "sp_bo007.trc"; 
--trace on;     

let _no_poliza = sp_sis21(a_no_documento);

insert into cobmoros(
no_documento,
periodo,
saldo,
por_vencer,
exigible,
corriente,
dias_30,
dias_60,
dias_90,
no_poliza,
saldo_neto,
por_vencer_neto,
exigible_neto,
corriente_neto,
dias_30_neto,
dias_60_neto,
dias_90_neto,
mayor_30,
mayor_60,
mayor_30_neto,
mayor_60_neto
)
values(
a_no_documento,
a_periodo,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
_no_poliza,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00
);

end procedure