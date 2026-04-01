-- Polizas - Busqueda de Impuesto por Unidad

-- Creado    : 31/08/2004 - Autor: Amado Perez  
			    
--drop procedure sp_proe34;

create procedure "informix".sp_proe34(a_no_poliza char(10), a_no_unidad char(5), a_tipo_ramo smallint)
returning char(3),
		  dec(16,2);

define v_cod_impuesto		char(3);
define v_impuesto  	        dec(16,3);
define v_impuesto_tot       dec(16,3);

SET ISOLATION TO DIRTY READ;

let v_impuesto_tot = 0;

If a_tipo_ramo = 5 Then 
	FOREACH
		 Select emipolim.cod_impuesto, (prdimpue.factor_impuesto * (Sum(emipouni.prima_neta)-Sum(emipouni.prima_vida))/100)
		   Into v_cod_impuesto, v_impuesto_tot
			From emipolim, prdimpue, emipouni
		  Where emipolim.no_poliza = a_no_poliza
			 And emipouni.no_poliza = emipolim.no_poliza
			 And emipouni.no_unidad = a_no_unidad
			 And prdimpue.cod_impuesto = emipolim.cod_impuesto
		 group by emipolim.cod_impuesto, prdimpue.factor_impuesto

	   --Let v_impuesto_tot = v_impuesto_tot + v_impuesto;
       return v_cod_impuesto,
              Round(v_impuesto_tot,2) WITH RESUME;
   END FOREACH

Else
	FOREACH	WITH HOLD
		 Select emipolim.cod_impuesto, (prdimpue.factor_impuesto * Sum(emipouni.prima_neta)/100)
		   Into v_cod_impuesto, v_impuesto_tot
			From emipolim, prdimpue, emipouni
		  Where emipolim.no_poliza = a_no_poliza
			 And emipouni.no_poliza = emipolim.no_poliza
			 And emipouni.no_unidad = a_no_unidad
			 And prdimpue.cod_impuesto = emipolim.cod_impuesto
		 group by emipolim.cod_impuesto, prdimpue.factor_impuesto

	  --	Let v_impuesto_tot = v_impuesto_tot + v_impuesto;

       return v_cod_impuesto,
              Round(v_impuesto_tot,2) WITH RESUME;
	END FOREACH
End If

end procedure;
