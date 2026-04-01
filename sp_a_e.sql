-- POLIZAS VIGENTES 
--
   DROP procedure sp_a_e;
   CREATE procedure sp_a_e()
   RETURNING char(10) as no_poliza;
   
    DEFINE _no_poliza,_no_remesa	CHAR(10);
	define _valor,_renglon smallint;
	define _mensaje char(250);

let _mensaje = '';
--Arregla emireaco
foreach
	select distinct no_poliza
	  into _no_poliza
	  from cobredet c, movim_tec_pri_tt m
	 where c.no_remesa = m.no_remesa
	   and c.renglon = m.renglon
	   and m.flag in(1,2,4)
	   
	let _valor = sp_arregla_emireaco_auto(_no_poliza, 1);
	
	return _no_poliza with resume;

end foreach

--Arregla cobreaco
foreach
	select distinct no_remesa,renglon
	  into _no_remesa,_renglon
	  from movim_tec_pri_tt
	 where flag in(1,2,4)
  order by no_remesa,renglon
  
  call sp_sis171bk(_no_remesa,_renglon) returning _valor, _mensaje; 
  
end foreach

Return 0;
END PROCEDURE;
