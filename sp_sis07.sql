
drop procedure sp_sis07;

create procedure "informix".sp_sis07(v_poliza char(10),v_endoso char(5),v_factor decimal(9,6))
--}

RETURNING DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(5,2);

DEFINE   v_unidad          CHAR(5);
DEFINE   v_unidades        CHAR(5);
DEFINE   r_error           SMALLINT;
DEFINE   v_orden		   SMALLINT;
DEFINE   _cant             SMALLINT;
DEFINE   _cant1            SMALLINT;
DEFINE   r_descripcion     CHAR(30);
DEFINE   v_prima_suscrita  DECIMAL(16,2);
DEFINE   v_prima_retenida  DECIMAL(16,2);
DEFINE   v_descto          DECIMAL(5,2);
DEFINE   r_signo           DECIMAL(9,2);
DEFINE   v_factores        DECIMAL(9,4);
DEFINE   v_producto        CHAR(5);
DEFINE   v_tipocalc        CHAR(3);
DEFINE   v_cod_mov         CHAR(3);
DEFINE   v_cober_reas      CHAR(3);
DEFINE   v_tipo_mov	       SMALLINT;
DEFINE   v_tot_saldo       DECIMAL(16,2);
DEFINE   v_prima_total     DECIMAL(16,2);
DEFINE   r_prima_anual     DECIMAL(16,2);
DEFINE   v_prima           DECIMAL(16,2);
DEFINE   r_prima_neta      DECIMAL(16,2);
DEFINE   r_descuento       DECIMAL(16,2);
DEFINE   _descuento        DECIMAL(16,2);
DEFINE   r_recargo         DECIMAL(16,2);
DEFINE   v_saldo           DECIMAL(16,2);
DEFINE   v_prima_cob       DECIMAL(16,2);
DEFINE   v_acepta          SMALLINT;
DEFINE   v_suma_asegurada  DECIMAL(16,2);
DEFINE   v_descuento       DECIMAL(16,2);
DEFINE   v_recargo         DECIMAL(16,2);
DEFINE   v_impuesto        DECIMAL(16,4);
DEFINE   v_cober_total     DECIMAL(16,2);
DEFINE   v_cobertura       CHAR(5);
DEFINE   v_contrato        CHAR(5);
DEFINE   v_coasegur        CHAR(3);
DEFINE   v_impto           DECIMAL(9,6);
DEFINE   v_partic_suma     DECIMAl(9,6);
DEFINE   v_partic_prima    DECIMAL(9,6);
DEFINE   v_partic_reas     DECIMAL(9,6);
DEFINE   r_prima_cober     DECIMAL(16,2);
DEFINE   r_prima_unidad    DECIMAL(16,2);
DEFINE   v_prima_bruta     DECIMAL(16,2);
DEFINE   v_porc_descto     DECIMAL(16,4);
DEFINE   v_tot_descto      DECIMAL(16,2);
DEFINE   v_tot_recargo     DECIMAL(16,2);
DEFINE   v_prima_reaseguro DECIMAL(16,2);
DEFINE   v_suma_reaseguro  DECIMAL(16,2);
DEFINE   v_prima_reas      DECIMAL(16,2);
DEFINE   v_suma_reas       DECIMAL(16,2);
DEFINE   v_tot_bruta       DECIMAL(16,2);
DEFINE   _tot_reaseguro    DECIMAL(16,2);
DEFINE   _gastos           DECIMAL(16,2);
DEFINE   _cober            CHAR(5);
DEFINE 	 _tipo_produccion  SMALLINT;
DEFINE 	 _porc_coas        DEC(16,4);
DEFINE   _cod_compania     CHAR(3);
DEFINE   _cod_coasegur     CHAR(3);
DEFINE   _cod_ramo         CHAR(3);
DEFINE   _ramo_sis,_no_cambio SMALLINT;
DEFINE   _prima_salud      DEC(16,2);
DEFINE   _neta             DEC(16,2);
DEFINE   _acepta_descuento SMALLINT;
DEFINE   _no_documento	   CHAR(20);
DEFINE   _prima_neta       DEC(16,2);
DEFINE   _impuesto_tot     SMALLINT;
DEFINE   _cod_impuesto     CHAR(3);
DEFINE   _factor_impuesto  DECIMAL(5,2);
DEFINE	 _tiene_impuesto   SMALLINT;

DEFINE _cod_origen_i    CHAR(3); 
DEFINE _cod_ramo_i      CHAR(3);
DEFINE _cod_subramo_i   CHAR(3);
DEFINE _canti_i         SMALLINT;
DEFINE _aplica_imp_i    SMALLINT;
DEFINE _cod_impuesto_i  CHAR(3);
DEFINE _porct_imp_i		DECIMAL(9,6);
DEFINE _existe_imp_i	SMALLINT;
DEFINE _sum_imp			DECIMAL(16,2);
DEFINE _end_imp			SMALLINT;
DEFINE _cod_manzana     CHAR(15);


BEGIN

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

SELECT t.tipo_produccion,
	   p.cod_compania,
	   p.cod_ramo
  INTO _tipo_produccion,
	   _cod_compania,
	   _cod_ramo
  FROM emipomae	p, emitipro t
 WHERE p.no_poliza    = v_poliza
   AND p.cod_tipoprod = t.cod_tipoprod;

SELECT ramo_sis
  INTO _ramo_sis
  FROM prdramo
 WHERE cod_ramo = _cod_ramo;

IF _tipo_produccion = 2 THEN

	SELECT par_ase_lider
	  INTO _cod_coasegur
	  FROM parparam
	 WHERE cod_compania = _cod_compania;

	SELECT porc_partic_coas
	  INTO _porc_coas
	  FROM emicoama
	 WHERE no_poliza    = v_poliza
	   AND cod_coasegur = _cod_coasegur;
ELSE
	LET _porc_coas = 100;
END IF


--SET DEBUG FILE TO "sp_pro493.trc";
--TRACE ON;



 {	select prima_neta
	  into r_prima_neta
	  from endedmae
	 where no_poliza = v_poliza
	   and no_endoso = v_endoso;

	select sum(prima_neta)
	  into r_prima_cober
	  from endedcob
	 where no_poliza = v_poliza
	   and no_endoso = v_endoso;

	let r_prima_anual = r_prima_cober - r_prima_neta;

	if r_prima_anual <> 0 then

		if r_prima_anual > 0 then
			let v_descto = -0.01;
		else
			let v_descto = +0.01;
		end if

	 	-- Ajuste de la Prima Neta En Coberturas y Unidades

		foreach

			 select no_unidad,
			        cod_cobertura
			   into v_unidad,
			        v_cobertura
			   from	endedcob
	          where no_poliza  = v_poliza
	            and no_endoso  = v_endoso
				and prima_neta <> 0.00

				update endedcob
				   set prima_neta    = prima_neta + v_descto,
				       prima         = prima      + v_descto
		         where no_poliza     = v_poliza
	    		   and no_endoso     = v_endoso
				   and no_unidad     = v_unidad
				   and cod_cobertura = v_cobertura;

				let r_prima_anual = r_prima_anual + v_descto;

				if r_prima_anual = 0 then
					exit foreach;
				end if

		end foreach

		foreach
		 select sum(prima_neta),
		        no_unidad
		   into r_prima_cober,
		        v_unidad
		   from endedcob
          where no_poliza = v_poliza
    		and no_endoso = v_endoso
		  group by no_unidad

			update endeduni
			   set prima_neta = r_prima_cober
             where no_poliza  = v_poliza
    		   and no_endoso  = v_endoso
			   and no_unidad  = v_unidad;

		end foreach
 }
		-- Ajuste de Prima Suscrita en Unidades y Reaseguro

		foreach
		 select prima_neta,
		        prima_suscrita,
		        no_unidad
		   into r_prima_cober,
		        r_prima_unidad,
		        v_unidad
		   from endeduni
          where no_poliza = v_poliza
    		and no_endoso = v_endoso

			let r_prima_neta = r_prima_cober * _porc_coas / 100;

			if r_prima_neta <> r_prima_unidad then

				update endeduni
				   set prima_suscrita = r_prima_neta
		         where no_poliza      = v_poliza
    		       and no_endoso      = v_endoso
				   and no_unidad      = v_unidad;

				select sum(prima)
				  into r_prima_unidad
				  from emifacon
		         where no_poliza = v_poliza
			       and no_endoso = v_endoso
			       and no_unidad = v_unidad;

				let r_prima_anual = r_prima_neta - r_prima_unidad;

				
	   			foreach
			 	 select x.cod_cober_reas, 
			 	        x.orden, 
			 	        x.cod_contrato
			       into v_cober_reas, 
			       		v_orden, 
			       		v_contrato 
			       from emifacon x
			      where x.no_poliza = v_poliza
			        and x.no_endoso = v_endoso
			        and x.no_unidad = v_unidad

				      update emifacon
				         set emifacon.prima          = emifacon.prima + r_prima_anual
				       where emifacon.no_poliza      = v_poliza
				         and emifacon.no_endoso      = v_endoso
				         and emifacon.no_unidad      = v_unidad
				         and emifacon.cod_cober_reas = v_cober_reas
				         and emifacon.orden          = v_orden;

						exit foreach;

				end foreach

			end if

		end foreach

	   foreach	
		select no_unidad,
			   sum(emifacon.prima) 
		  into v_unidad,
		  	   v_prima_retenida
		  from emifacon, reacomae
		 where emifacon.no_poliza     = v_poliza
		   and emifacon.no_endoso     = v_endoso
		   and emifacon.cod_contrato  = reacomae.cod_contrato
		   and reacomae.tipo_contrato = "1"
		 group by no_unidad
		 order by no_unidad

			if v_prima_retenida is null Then
			  let v_prima_retenida = 0.00;
			end if

			update endeduni
			   set prima_retenida = v_prima_retenida
	         where no_poliza      = v_poliza
		       and no_endoso      = v_endoso
			   and no_unidad      = v_unidad;

		end foreach
		--}

	--end if

RETURN r_prima_neta, r_prima_cober,r_prima_anual,0;

END

end procedure;