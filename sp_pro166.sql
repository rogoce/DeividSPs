DROP PROCEDURE sp_pro166;

CREATE PROCEDURE sp_pro166()
returning char(10),
          char(5),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(7),
		  char(10);

define _periodo			char(7);
define _periodo2		char(7);
DEFINE v_nopoliza       CHAR(10);
DEFINE v_noendoso		CHAR(5);
define v_cod_contrato   CHAR(5);
DEFINE v_prima		    DEC(16,2);
DEFINE v_prima2		    DEC(16,2);
DEFINE _tipo_contrato	SMALLINT;
define _cod_ramo		char(3);
define _cod_cober_reas	char(3);
define _cod_coasegur	char(3);
define _consolida_mayor	smallint;
define _no_factura		char(10);
define _no_unidad		char(5);
define _orden			smallint;

define _porc_partic		dec(5,2);
define _cod_traspaso	CHAR(5);
define _traspaso		smallint;

DEFINE v_filtros        CHAR(255);

SET ISOLATION TO DIRTY READ;

let _periodo2 = "2009-01";

create temp table temp_asien(
no_poliza	char(10),
no_endoso	char(5),
prima1		dec(16,2),
prima2		dec(16,2)
) with no log;

create temp table temp_periodo(
periodo	char(7)
) with no log;

foreach
 select e.periodo
   INTO _periodo
   from endedmae e, endasien a
  where e.no_poliza   = a.no_poliza
    and e.no_endoso   = a.no_endoso
    and a.tipo_comp   = 9
    and a.cuenta       like "511%"
    and e.periodo     >= _periodo2
	and e.sac_asientos = 2
  group by e.periodo
  order by e.periodo
  	
		insert into temp_periodo
		values (_periodo);

end foreach

foreach
 select periodo
   into _periodo
   from temp_periodo

	FOREACH
	 SELECT no_poliza,
	        no_endoso
	   INTO v_nopoliza,
	        v_noendoso
	   FROM endedmae
	  WHERE periodo      = _periodo
        and actualizado  = 1
	    and sac_asientos = 2

		FOREACH
		 SELECT cod_contrato,
	       	    prima,
				cod_cober_reas,
				no_unidad,
				orden
		   INTO v_cod_contrato,
		        v_prima,
				_cod_cober_reas,
				_no_unidad,
				_orden
		   FROM emifacon
		  WHERE no_poliza = v_nopoliza
		    AND no_endoso = v_noendoso
		    AND prima     <> 0

			select traspaso
			  into _traspaso
			  from reacocob
			 where cod_contrato   = v_cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			Select tipo_contrato,
				   cod_traspaso
			  Into _tipo_contrato,
				   _cod_traspaso
			  From reacomae
			 Where cod_contrato = v_cod_contrato;

			if _traspaso = 1 then

				let v_cod_contrato = _cod_traspaso;

				Select tipo_contrato
				  Into _tipo_contrato
				  From reacomae
				 Where cod_contrato = v_cod_contrato;

			end if

			if _tipo_contrato = 3 then

				Foreach
				 Select cod_coasegur,
				        prima
				   Into _cod_coasegur,
				        v_prima
				   From emifafac
				  Where no_poliza      = v_nopoliza
				    And no_endoso      = v_noendoso
					And no_unidad      = _no_unidad
					And cod_cober_reas = _cod_cober_reas
					And orden		   = _orden
					
					select consolida_mayor
					  into _consolida_mayor
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					if _consolida_mayor is null then
						let _consolida_mayor = 0;
					end if

					if _consolida_mayor = 0 then
						CONTINUE FOREACH;
					end if

					insert into temp_asien
					values (v_nopoliza, v_noendoso, v_prima, 0);

				end foreach

			else

			   foreach	
				select cod_coasegur,
				       porc_cont_partic
				  into _cod_coasegur,
				       _porc_partic
				  from reacoase
				 where cod_contrato   = v_cod_contrato
				   and cod_cober_reas = _cod_cober_reas

					select consolida_mayor
					  into _consolida_mayor
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					if _consolida_mayor is null then
						let _consolida_mayor = 0;
					end if

					if _consolida_mayor = 0 then
						CONTINUE FOREACH;
					end if

					insert into temp_asien
					values (v_nopoliza, v_noendoso, v_prima * _porc_partic / 100, 0);

				end foreach

			end if

		END FOREACH

	END FOREACH

	foreach
	 select a.no_poliza,
	        a.no_endoso,
  		    (a.debito + a.credito)
	   INTO v_nopoliza,
	        v_noendoso,
			v_prima
	   from endedmae e, endasien a
	  where e.no_poliza    = a.no_poliza
	    and e.no_endoso    = a.no_endoso
	    and a.tipo_comp    = 9
	    and e.periodo      = _periodo
	    and a.cuenta       like "511%"
	    and e.sac_asientos = 2

			insert into temp_asien
			values (v_nopoliza, v_noendoso, 0, v_prima);

	end foreach

	foreach
	 select no_poliza,
	        no_endoso,
		    sum(prima1),
			sum(prima2)
	   INTO v_nopoliza,
	        v_noendoso,
			v_prima,
			v_prima2
	   from temp_asien
	  group by 1, 2
	  order by 1, 2

		if v_prima <> v_prima2 then 

			select no_factura
			  into _no_factura
			  from endedmae
			 where no_poliza = v_nopoliza
			   and no_endoso = v_noendoso;

			return v_nopoliza,
	        	   v_noendoso,
				   v_prima,
				   v_prima2,
				   (v_prima - v_prima2),
				   _periodo,
				   _no_factura
				   with resume;
		end if

	end foreach

	delete from temp_asien;

end foreach

return "00000",
       "00000",
       0.00,
       0.00,
       0.00,
	   "",
	   ""
       with resume;

DROP TABLE temp_asien;
DROP TABLE temp_periodo;

END PROCEDURE
