
DROP PROCEDURE sp_arregla_data5;
CREATE PROCEDURE sp_arregla_data5(a_cod_ramo char(2),a_periodo char(7), a_opc smallint default 0)
RETURNING CHAR(7)  as periodo,
          char(10) as no_poliza,
		  char(5)  as no_endoso,
		  char(5)  as no_unidad, 
		  char(10) as no_factura;


DEFINE _no_unidad,_no_endoso		CHAR(5);
DEFINE _no_documento    char(20);
define _no_poliza,_no_factura       char(10);
define _cnt,_cnt2,_valor,_no_cambio		smallint;
define _suma_unidad     dec(16,2);

SET ISOLATION TO DIRTY READ;

BEGIN

foreach
	select no_poliza,
	       no_endoso,
		   no_factura,
		   no_documento
	  into _no_poliza,
		   _no_endoso,
		   _no_factura,
		   _no_documento
	  from endedmae
	 where actualizado = 1
	   and periodo = a_periodo
	   and no_documento[1,2] = a_cod_ramo
	   and prima_neta <> 0
	   --and cod_endomov <> '005' --ELIMINACION DE UNIDADES
	 order by no_documento

	let _cnt  = 0;
	let _cnt2 = 0;
	let _no_unidad = null;
	foreach
		select distinct no_unidad
		  into _no_unidad
		  from endedcob e, prdcober p
		 where e.cod_cobertura = p.cod_cobertura
		   and e.no_poliza = _no_poliza
		   and e.no_endoso = _no_endoso
		   and e.prima_neta <> 0
		   and p.cod_cober_reas = '047'
		   
		select count(*)
		  into _cnt
		  from emifacon
		 where no_poliza = _no_poliza
           and no_endoso = _no_endoso
           and no_unidad = _no_unidad
           and cod_cober_reas = '047';

		if _cnt > 0 then
			continue foreach;
		else	--LA COBERTURA DE REASEGURO NO ESTA EN EMIFACON
			let _suma_unidad = 0;
			
			select suma_asegurada
			  into _suma_unidad
			  from endeduni
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and no_unidad = _no_unidad;
			   
			select max(no_cambio)
			  into _no_cambio
			  from emireaco
			 where no_poliza = _no_poliza;
			
			select count(*)
			  into _cnt2
			  from emireaco
			 where no_poliza = _no_poliza
			   and no_cambio = _no_cambio
			   and cod_cober_reas = '047';

			if a_opc <> 0 then
				if _cnt2 > 0 then	--LA COBERTURA DE REASEGURO ESTA EN EMIREACO, PERO NO EN EMIFACON, SE CREA EMIFACON
					delete from emigloco
	                 where no_poliza = _no_poliza
                       and no_endoso = _no_endoso;
					let _valor = sp_proe04b(_no_poliza,_no_unidad,_suma_unidad, _no_endoso);
				else	--LA COBERTURA DE REASEGURO NO ESTA EN EMIREACO NI EN EMIFACON, SE CREA EN EMIREACO Y LUEGO EN EMIFACON
					let _valor = sp_arregla_emireaco_auto(_no_poliza, 1);
					
					delete from emigloco
	                 where no_poliza = _no_poliza
                       and no_endoso = _no_endoso;
					let _valor = sp_proe04b(_no_poliza,_no_unidad,_suma_unidad, _no_endoso);
				end if
			end if
			   
			return a_periodo,_no_poliza,_no_endoso,_no_unidad,_no_factura with resume;
		end if
	end foreach
end foreach
return a_periodo,'','','','FIN';
END
END PROCEDURE;