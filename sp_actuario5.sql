--crear emifacon para facturacion mensual salud que no se crearon.

DROP procedure sp_actuario5;
CREATE procedure "informix".sp_actuario5()

 RETURNING CHAR(20),CHAR(10),char(5),DEC(16,2),DEC(16,2),dec(16,2),char(5);


define _tot_prima_ret dec(16,2);
define _no_endoso     char(5);
define _no_poliza     char(10);
define _total_prima_ret  dec(16,2);
define _cod_contrato    char(5);
define _prima_contrato  dec(16,2);
define _tipo_contrato   smallint;
define _no_doc          char(20);
define _prima_suscrita  dec(16,2);
define _no_unidad       char(5);
define _cantidad        smallint;
define _prima_ret       dec(16,2);

FOREACH WITH HOLD

  SELECT e.no_poliza,	
         e.no_endoso, 	
         e.prima_retenida,
		 e.no_documento,
		 e.prima_suscrita
    INTO _no_poliza,		         
         _no_endoso, 	
         _total_prima_ret,
		 _no_doc,
		 _prima_suscrita
    FROM endedmae e, emipomae r
   WHERE e.no_poliza = r.no_poliza
     and e.periodo BETWEEN '2009-08' AND '2009-08'
     AND e.actualizado = 1
	 and r.cod_ramo = '018'
	 order by e.no_poliza, e.no_endoso

--	 and e.cod_endomov = '014'

	let _tot_prima_ret = 0;
	let _cantidad      = 0;
	let _prima_ret     = 0;

		select sum(prima_retenida)
		  into _prima_ret
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

	if _prima_ret <> _total_prima_ret then

	         RETURN _no_doc, _no_poliza, _no_endoso, _total_prima_ret,_tot_prima_ret,_prima_ret,'' WITH RESUME;
	end if	

{  	foreach

		select no_unidad,
		       prima_retenida
		  into _no_unidad,
		       _prima_ret
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		 order by no_unidad

		  SELECT count(*)
		    INTO _cantidad
		    FROM emifacon
		   WHERE no_poliza = _no_poliza
		     AND no_endoso = _no_endoso
			 AND no_unidad = _no_unidad; 

		  if _cantidad > 0 then
		  else
			  INSERT INTO emifacon(
			  no_poliza,
			  no_endoso,
			  no_unidad,
			  cod_cober_reas,
			  orden,
			  cod_contrato,
			  porc_partic_prima,
			  porc_partic_suma,
			  suma_asegurada,
			  prima
			  )
			  VALUES(
			  _no_poliza,
			  _no_endoso,
			  _no_unidad,
			  '019',
			  1,
			  '00577',
			  100,
			  100,
			  0,
			  _prima_ret
			  ); 

	         RETURN _no_doc, _no_poliza, _no_endoso, _total_prima_ret,_tot_prima_ret,_prima_ret,_no_unidad WITH RESUME;
		  end if


	  	FOREACH

		  SELECT cod_contrato,
		         prima
		    INTO _cod_contrato,		         
		         _prima_contrato
		    FROM emifacon
		   WHERE no_poliza = _no_poliza
		     AND no_endoso = _no_endoso
			 AND no_unidad = _no_unidad


		  SELECT tipo_contrato
		    INTO _tipo_contrato
		    FROM reacomae
		   WHERE cod_contrato = _cod_contrato;

			IF _tipo_contrato = 1 THEN 	-- Retencion
				let _tot_prima_ret = _tot_prima_ret + _prima_contrato;
			else
				CONTINUE FOREACH;
			END IF

		END FOREACH

		if _tot_prima_ret = 0 then

		         RETURN _no_doc, _no_poliza, _no_endoso, _total_prima_ret,_tot_prima_ret,_prima_suscrita,_no_unidad WITH RESUME;

		end if 
		
	end foreach	}

END FOREACH
END PROCEDURE
