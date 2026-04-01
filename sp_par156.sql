-- Procedure para verificar las cuentas de comisiones de los registros contables

DROP PROCEDURE sp_par156;

CREATE PROCEDURE sp_par156(a_periodo CHAR(07))

RETURNING CHAR(10),
          CHAR(5),
          dec(16,2),
          dec(16,2);

define _monto_sac	dec(16,2);

   BEGIN

      DEFINE v_nopoliza                      CHAR(10);
      DEFINE v_noendoso,v_cod_contrato       CHAR(5);
      DEFINE v_cod_ramo,v_cobertura          CHAR(03);
      DEFINE v_desc_ramo,v_desc_cobertura,
             v_desc_contrato                 CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_descr_cia                     CHAR(50);
      DEFINE v_prima,v_prima1                DEC(16,2);
      DEFINE v_tipo_contrato                 SMALLINT;

	  define _porc_impuesto					 dec(16,2);
	  define _porc_comision					 dec(16,2);
	  define _cuenta						 char(25);
	  define _serie 						 smallint;
	  define _impuesto						 dec(16,2);
	  define _comision						 dec(16,2);
	  define _por_pagar						 dec(16,2);

	  CALL sp_pro34("001","001",a_periodo,a_periodo,"*", "*", "*", "*", "*", "*") RETURNING v_filtros;

      LET v_prima     = 0;
      LET v_descr_cia = sp_sis01("001");
    
      SET ISOLATION TO DIRTY READ;

      FOREACH WITH HOLD
	     SELECT z.no_poliza,
	     		z.no_endoso
           INTO v_nopoliza,
           		v_noendoso
           FROM temp_det z
          WHERE z.seleccionado = 1
		    and cod_ramo = "002"
		  group by 1, 2

			let _comision = 0.00;

           FOREACH
		    SELECT cod_cober_reas,
		    	   cod_contrato,
		    	   prima
              INTO v_cobertura,
              	   v_cod_contrato,
              	   v_prima1
              FROM emifacon
             WHERE no_poliza = v_nopoliza
               AND no_endoso = v_noendoso
               AND prima <> 0

            SELECT tipo_contrato,
			       serie
              INTO v_tipo_contrato,
			       _serie
              FROM reacomae
             WHERE cod_contrato = v_cod_contrato;

            IF v_tipo_contrato = 1 OR
			   v_tipo_contrato = 3 THEN
               CONTINUE FOREACH;
            ELSE
               LET v_prima = v_prima1;
            END IF
	
			Select porc_impuesto,
			       porc_comision,
				   cuenta
			  Into _porc_impuesto,
				   _porc_comision,
				   _cuenta
			  From reacocob
			 Where cod_contrato   = v_cod_contrato
			   And cod_cober_reas = v_cobertura;

				let _impuesto  = v_prima * _porc_impuesto / 100;
				let _comision  = _comision + v_prima * _porc_comision / 100;
				let _por_pagar = v_prima - _impuesto - _comision;


	      END FOREACH

		select sum(debito + credito)
		  into _monto_sac
		  from endasien
		 where no_poliza = v_nopoliza
		   and no_endoso = v_noendoso
		   and cuenta like "413%";

		if _monto_sac is null then
			let _monto_sac = 0.00;
		end if
		
		let _monto_sac = _monto_sac * -1;

		if _monto_sac <> _comision then

			 RETURN v_nopoliza,
			 		v_noendoso,
					_comision,
					_monto_sac 
			        WITH RESUME;

		end if

      END FOREACH

      DROP TABLE temp_det;

   END

END PROCEDURE
