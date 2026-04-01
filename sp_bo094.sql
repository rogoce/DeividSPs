-- Procedure que carga el acumulado de presupuesto para indicadores
-- 
-- Creado    : 31/03/2016 - Autor: Jorge Contreras
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo094;		

create procedure "informix".sp_bo094()
returning smallint, varchar(30);


define v_cod_cod_ramo		char(3);
define v_periodo			char(7);
define v_ventas_total		dec(16,2);
define v_ramo    			varchar(50);
define v_ventas_acumulado	dec(16,2);

set isolation to dirty read;

--set debug file to "sp_bo094.trc";
--trace on;
/*
insert into presupuesto(cod_ramo,periodo,ventas_nuevas,ventas_renovadas,ventas_total)
select cod_ramo,
       periodo,
       sum(ventas_nuevas),
       sum(ventas_renovadas),
       sum(ventas_total)
from preventas
where periodo in('2025-01','2025-02','2025-03','2025-04','2025-05','2025-06','2025-07','2025-08','2025-09','2025-10','2025-11','2025-12')
group by cod_ramo, periodo;
*/
foreach
	select cod_ramo,
	       periodo,
		   ventas_total,
		   ramo
	  into v_cod_cod_ramo,
		   v_periodo,
		   v_ventas_total,
		   v_ramo
	  from presupuesto
	  where periodo[1,4] = '2025'
	  
	  /*if v_periodo = '2017-01' then 
	    let v_ventas_acumulado = 0;
	  end if*/
		
	  select sum(ventas_total)
	  into v_ventas_acumulado
      from presupuesto
      where cod_ramo = v_cod_cod_ramo
      and  periodo <= v_periodo
	  and periodo >= v_periodo[1,4]||'-01';
	  
	  select nombre
	  into v_ramo
	  from deivid:prdramo
	  where cod_ramo = v_cod_cod_ramo;

    update presupuesto
    set ventas_acumuladas = v_ventas_acumulado,
	    ramo = v_ramo
	where cod_ramo = v_cod_cod_ramo
    and  periodo = v_periodo;
	
		
end foreach

return 0,'Exito';
end procedure