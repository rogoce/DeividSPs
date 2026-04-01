
DROP procedure sp_jean11b;
CREATE procedure sp_jean11b(a_no_poliza char(10))
RETURNING integer;

DEFINE _no_poliza    CHAR(10);
define _no_unidad       char(5);
define _suma_unidad,_suma_35   dec(16,2);


foreach
	select e.no_poliza
	  into _no_poliza
	  from emipomae e, emipocob b
	 where e.no_poliza = b.no_poliza
	   and e.actualizado = 1
	   --and e.no_poliza = a_no_poliza
	   and e.cod_ramo = '019'
	   and b.cod_cobertura = '00988'
	   and e.estatus_poliza = 1
	   and b.prima_neta <> 0
	 order by e.estatus_poliza,b.prima_neta
	
	select suma_asegurada,
	       no_unidad
	  into _suma_unidad,
	       _no_unidad
	  from emipouni
	 where no_poliza = _no_poliza;
	 
	let _suma_35 = 0;
	let _suma_35 = _suma_unidad *35/100;
	
	update emipocob
	   set limite_1 = _suma_35
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura = '00988';
	   
end foreach
return 0;
END PROCEDURE;