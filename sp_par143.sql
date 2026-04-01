-- Procedimiento que genera los registros contables de las incobrables
-- 
-- Creado     : 24/10/2002 - Autor: Marquelda Valdelamar
-- Modificado :	27/10/2002 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_par143;		

CREATE PROCEDURE "informix".sp_par143()
RETURNING CHAR(20),
		  char(50),
		  char(50),	
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(10),
		  char(3),
		  char(50);	
		  		  	
DEFINE _no_documento     CHAR(20); 
DEFINE a_no_poliza       CHAR(10); 
DEFINE _cuenta           CHAR(25);
DEFINE _debito           DEC(16,2);
DEFINE _credito          DEC(16,2);
DEFINE _tipo_comp        SMALLINT;

DEFINE _prima_bruta  	 DEC(16,2);
DEFINE _impuesto		 DEC(16,2);
DEFINE _prima_neta  	 DEC(16,2);
DEFINE _prima_suscrita	 DEC(16,2);
DEFINE _coas_x_pagar	 DEC(16,2);
DEFINE _comision		 DEC(16,2);
DEFINE _impuesto_2		 DEC(16,2);
DEFINE _retencion		 DEC(16,2);
DEFINE _reserva			 DEC(16,2);
DEFINE _reas_cedido		 DEC(16,2);
DEFINE _impuesto_recup	 DEC(16,2);
DEFINE _comision_reas	 DEC(16,2);
DEFINE _reas_x_pagar	 DEC(16,2);

DEFINE _saldo90     	 DEC(16,2);
DEFINE _saldo120     	 DEC(16,2);
define _tipo			 char(1);
define _tipo_nombre		 char(10);

DEFINE _suma_impuesto	 DEC(16,2);

DEFINE _cod_impuesto	 CHAR(3);
DEFINE _cod_tipoprod	 CHAR(3);
DEFINE _tipo_produccion  SMALLINT;
DEFINE _monto			 DEC(16,2);
DEFINE _monto2			 DEC(16,2);
DEFINE _monto3			 DEC(16,2);
DEFINE _monto4			 DEC(16,2);

DEFINE _factor_impuesto	 DEC(5,2);

DEFINE _cod_ramo         CHAR(3);
DEFINE _nombre_ramo  	 CHAR(50);
DEFINE _cod_cliente      CHAR(10);
DEFINE _nombre_cliente 	 CHAR(50);
DEFINE _cod_agente       CHAR(5);
DEFINE _nombre_agente  	 CHAR(50);

DEFINE _porc_comis_agt   DECIMAL(5,2);
DEFINE _porc_partic_agt	 DECIMAL(5,2);
DEFINE _cuenta_inc       CHAR(25);
DEFINE _cuenta_dan       CHAR(25);
DEFINE _ramo_sis		 SMALLINT;
DEFINE _cod_contrato	 CHAR(5);
DEFINE _tipo_contrato    SMALLINT;
DEFINE _cod_cober_reas   CHAR(3);
DEFINE _cuenta_cat       CHAR(25);   
DEFINE _cod_lider		 CHAR(3);
DEFINE _cod_compania	 CHAR(3);
DEFINE _error_cod		 INTEGER;
DEFINE _error_desc		 CHAR(100);
DEFINE _imp_gob          SMALLINT;
DEFINE _no_unidad		 CHAR(5);
DEFINE _orden			 SMALLINT;
DEFINE _porc_reser_est   DECIMAL(5,2);  -- Porcentaje de Reserva Estadistica
DEFINE _porc_reser_cat   DECIMAL(5,2);	-- Porcentaje de Reserva Catastrofica
DEFINE _cod_origen		 CHAR(3);
DEFINE _aplica_impuesto  SMALLINT;
DEFINE _cant_impuestos   SMALLINT;

define _debito_sus		 dec(16,2);
define _credito_sus		 dec(16,2);
define _cod_endomov		 char(3);
define _tiene_impuesto	 smallint;

DEFINE _prima_sus_uno	 DEC(16,2);
DEFINE _prima_sus_dos	 DEC(16,2);
define _cant_unidades	 smallint;
define _no_cambio		 smallint;

define _porc_partic_suma	dec(9,6);
define _porc_partic_prima	dec(9,6);		
define _porc_partic_reas	dec(9,6);		

------------------------------------------------------------------------------
--                          Tipos de Comprobantes
------------------------------------------------------------------------------
-- 1. Prima Suscrita     
-- 2. Comisiones		 
-- 3. Reaseguro Cedido	 
-- 4. Reaseguro Asumido         
-- 5. Reaseguro Retrocedido	  
-- 6. Reserva Estadistica
-- 7. Reserva Catastrofica
-- 8. Exceso de Perdida
------------------------------------------------------------------------------

--Set Debug File To "sp_par123.trc";
--trace on;

Set Isolation To Dirty Read;

SELECT par_ase_lider
  INTO _cod_lider
  FROM parparam
 WHERE cod_compania = "001";

-- Generacion de Registros Contables de los Incobrables

foreach
 select no_documento,
        saldo,
		saldo_90,
		saldo_120,
		tipo
   into _no_documento,
        _prima_bruta,
		_saldo90,
		_saldo120,
		_tipo
   from cob90d04
  order by tipo

	let a_no_poliza  = sp_sis21(_no_documento);
	let _cod_endomov = "011";	
--	let _prima_bruta = _prima_bruta * -1;
		
	SELECT cod_ramo,
		   cod_origen,
		   cod_tipoprod,
		   tiene_impuesto,
		   cod_contratante	
	  INTO _cod_ramo,
		   _cod_origen,
		   _cod_tipoprod,
		   _tiene_impuesto,
		   _cod_cliente	
	  FROM emipomae
	 WHERE no_poliza = a_no_poliza;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;
	 
	 foreach
	  select cod_agente
	    into _cod_agente
	    from emipoagt
	   where no_poliza = a_no_poliza
	   	exit foreach;
	end foreach
	
	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente; 	     	

	-- Determinacion del Impuesto

	if _tiene_impuesto = 1 then

		Let _suma_impuesto = 0.00;

		Foreach	
		 Select cod_impuesto
		   Into _cod_impuesto
		   From emipolim
		  Where no_poliza = a_no_poliza

			Select factor_impuesto
			  Into _factor_impuesto
			  From prdimpue
			 Where cod_impuesto = _cod_impuesto;
				    
			Let _suma_impuesto = _suma_impuesto  + (_factor_impuesto / 100);

		End Foreach

		let _prima_neta = _prima_bruta / (1 + _suma_impuesto);

	else

		let _prima_neta = _prima_bruta;

	end if

	let _impuesto = _prima_bruta - _prima_neta;

	-- Determinacion de la Prima Suscrita

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	If _tipo_produccion = 2 THEN -- Coaseguro Mayoritario

		select sum(porc_partic_coas)
		  into _porc_partic_agt
		  from emicoama
		 where no_poliza     = a_no_poliza
    	   and cod_coasegur  = _cod_lider;

		IF _porc_partic_agt IS NULL THEN
			LET _porc_partic_agt = 0;
		END IF

    	Let _prima_suscrita = (_prima_neta * _porc_partic_agt / 100);

	else

    	Let _prima_suscrita = _prima_neta;

	end if

	SELECT ramo_sis,
	       imp_gob,
		   nombre
	  INTO _ramo_sis,
	       _imp_gob,
		   _nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT aplica_impuesto
	  INTO _aplica_impuesto
	  FROM parorig
	 WHERE cod_origen = _cod_origen;

	let _porc_reser_est = 1;
	let _porc_reser_cat = 1;

	let _porc_reser_est = _porc_reser_est/100;
	let _porc_reser_cat = _porc_reser_cat/100;

	-- Comprobante de Prima Suscrita

	let _coas_x_pagar = 0.00;

	If _tipo_produccion = 2 THEN -- Coaseguro Mayoritario

		select sum(porc_partic_coas)
		  into _porc_partic_agt
		  from emicoama
		 where no_poliza     = a_no_poliza
    	   and cod_coasegur <> _cod_lider;

		IF _porc_partic_agt IS NULL THEN
			LET _porc_partic_agt = 0;
		END IF

		-- Coaseguro por Pagar

    	Let _monto = (_prima_neta * _porc_partic_agt / 100);

	    -- Calculo del impuesto

		If _tiene_impuesto = 1 then

			Let _suma_impuesto = 0.00;

			Foreach	
			 Select cod_impuesto
			   Into _cod_impuesto
			   From emipolim
			  Where no_poliza = a_no_poliza

				Select factor_impuesto
				  Into _factor_impuesto
				  From prdimpue
				 Where cod_impuesto = _cod_impuesto;
					    
				Let _monto2        = _monto * _factor_impuesto / 100;
				Let _suma_impuesto = _suma_impuesto  + _monto2;

			End Foreach

			let _monto = _monto + _suma_impuesto;

		end if

		let _coas_x_pagar = _monto;

	end if

	    -- Calculo del impuesto
{
	If _impuesto <> 0.00 then

		Let _suma_impuesto = 0.00;

		 Select count(*)
		   Into _cant_impuestos
		   From emipolim
		  Where no_poliza = a_no_poliza;

		Foreach	
		 Select cod_impuesto
		   Into _cod_impuesto
		   From emipolim
		  Where no_poliza = a_no_poliza

			Select factor_impuesto,
			       cta_incendio,
				   cta_danos
			  Into _factor_impuesto,
			       _cuenta_inc,
				   _cuenta_dan
			  From prdimpue
			 Where cod_impuesto = _cod_impuesto;
				    
			if _cant_impuestos = 1 then
				let _monto = _impuesto;
			else
				let _monto = _prima_suscrita * _factor_impuesto / 100;
			end if

			Let _suma_impuesto = _suma_impuesto + _monto;

			If _ramo_sis = 2 or
			   _ramo_sis = 8 then
				Let _cuenta = sp_sis15(_cuenta_inc); 
			Else
				Let _cuenta = sp_sis15(_cuenta_dan); 
			End If

			If _monto <> 0.00 Then

				Let _monto   = _monto * -1;
				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto > 0.00 then
					Let _debito  = _monto;
				else
					Let _credito = _monto;
				end if

				Let _tipo_comp = 1;
				CALL sp_par124(_no_documento, _cuenta, _debito, _credito, _tipo_comp);

			End If

		End Foreach

		if _cod_tipoprod = "001"  and 
		   _cod_endomov  <> "014" then

			select sum(debito + credito)
			  into _monto
			  from cobincas
			 where no_documento = _no_documento;

			let _monto = _monto * -1;

			If _monto <> 0.00 Then

				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _impuesto > 0.00 then -- Valores al Credito
					Let _credito = _monto;
				else
					Let _debito  = _monto;
				end if

				Let _tipo_comp = 1;
				CALL sp_par124(_no_documento, _cuenta, _debito, _credito, _tipo_comp);

			End If

		end if

		if _cod_tipoprod = "005"  or 
		   _cod_tipoprod = "002"  then

			if _cod_endomov  <> "014" then

				let _cuenta = _cuenta;
				let _suma_impuesto = _suma_impuesto;
				let _impuesto = _impuesto;

				Let _monto = (_suma_impuesto - _impuesto);

				If _monto <> 0.00 Then

					Let _debito  = 0.00;
					Let _credito = 0.00;

					if _impuesto > 0.00 then -- Valores al Credito
						Let _credito = _monto;
					else
						Let _debito  = _monto;
					end if

					Let _tipo_comp = 1;
					CALL sp_par124(_no_documento, _cuenta, _debito, _credito, _tipo_comp);

				End If

			end if

		end if

     End If
}
	-- Comprobante de Comisiones

	let _comision = 0.00;

    Foreach 
	 Select	porc_comis_agt,
			porc_partic_agt
	   Into	_porc_comis_agt,
			_porc_partic_agt
	   From emipoagt
	  Where	no_poliza = a_no_poliza

		Let _monto    = _prima_suscrita * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
		let _comision = _comision + _monto;

    End Foreach

	let _impuesto_2  = 0.00;

	If _aplica_impuesto = 1 Then -- Verifica si a la Poliza se le Aplican los Impuestos (Exterior No Llevan) 

		If _imp_gob = 1 Then -- Verifica si al Ramo se le Aplican los Impuestos

			Foreach
			 Select factor,
			        cta_debito,
					cta_credito
			   Into _factor_impuesto,
					_cuenta_inc,
					_cuenta_dan
			   From parimpgo

				Let _monto       = _prima_suscrita * _factor_impuesto / 100;
				let _impuesto_2  = _impuesto_2 + _monto;
				 				
			End Foreach

		End If

	End If

    -- Comprobante de Reaseguro Cedido

	select count(*)
	  into _cant_unidades
	  From emipouni
	 Where no_poliza = a_no_poliza;

	let _prima_sus_uno  = _prima_suscrita / _cant_unidades;
	let _prima_sus_dos  = _prima_sus_uno;
	let _monto          = _prima_sus_uno * _cant_unidades;
	let _monto2	        = _prima_suscrita - _monto;
	let _prima_sus_uno  = _prima_sus_uno + _monto2;

	let _cant_unidades  = 0;
	let _retencion      = 0.00;
	let _reserva		= 0.00;
	let _reas_cedido	= 0.00;
	let _impuesto_recup	= 0.00;
	let _comision_reas	= 0.00;
	let _reas_x_pagar	= 0.00;

	Foreach
	 select no_unidad
	   into _no_unidad
	   From emipouni
	  Where no_poliza = a_no_poliza

		let _cant_unidades = _cant_unidades + 1;

		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad;

		foreach
		 select cod_cober_reas
		   into _cod_cober_reas
		   from emireaco
		  where no_poliza = a_no_poliza
		    and no_unidad = _no_unidad
			and no_cambio = _no_cambio
		  order by 1
			exit foreach;		
		end foreach

		Foreach
		 Select cod_contrato,
				cod_cober_reas,
				orden,
				porc_partic_suma,
				porc_partic_prima
		   Into _cod_contrato,
				_cod_cober_reas,
				_orden,
				_porc_partic_suma,
				_porc_partic_prima
		   From emireaco
		  Where no_poliza      = a_no_poliza
		    and no_unidad      = _no_unidad
			and no_cambio      = _no_cambio
			and cod_cober_reas = _cod_cober_reas

			if _cant_unidades = 1 then
				let _monto = _prima_sus_uno * _porc_partic_prima / 100;
			else
				let _monto = _prima_sus_dos * _porc_partic_prima / 100;
			end if

			Select tipo_contrato,
			       porc_impuesto
			  Into _tipo_contrato,
			       _factor_impuesto
			  From reacomae
			 Where cod_contrato = _cod_contrato;

			If _tipo_contrato = 1 Then

				-- Reservas Estadisticas y Catastroficas
				
				let _retencion = _retencion + _monto;
				let _monto3    = _monto * _porc_reser_est;
				let _reserva   = _reserva + _monto3;

			Else

				Select porc_impuesto,
				       porc_comision,
					   cuenta
				  Into _factor_impuesto,
					   _porc_comis_agt,
					   _cuenta_cat
				  From reacocob
				 Where cod_contrato   = _cod_contrato
				   And cod_cober_reas = _cod_cober_reas;

				-- Reaseguro Cedido

				Let _monto3      = _monto;
				let _reas_cedido = _reas_cedido + _monto;
				 
				-- Para los Contratos Facultativos

				If _tipo_contrato = 3 Then

					Foreach
					 Select porc_partic_reas,
					        porc_impuesto,
							porc_comis_fac
					   Into _porc_partic_reas,
							_factor_impuesto,
					   		_porc_comis_agt
					   From emireafa
					  Where no_poliza      = a_no_poliza
						And no_unidad      = _no_unidad
						and no_cambio      = _no_cambio
						And cod_cober_reas = _cod_cober_reas
						And orden		   = _orden

						let _monto4 = _monto * _porc_partic_reas / 100;
						 
						-- Comision Ganada

						Let _monto2 = _monto4 * _porc_comis_agt / 100;
						let _comision_reas = _comision_reas + _monto2;
						Let _monto3  = _monto3 - _monto2;

						-- Impuesto Recuperado

						Let _monto2 = _monto4 * _factor_impuesto / 100;
						let _impuesto_recup = _impuesto_recup + _monto2;
						Let _monto3  = _monto3 - _monto2;

					End Foreach

				Else

					-- Comision Ganada

					Let _monto2 = _monto * _porc_comis_agt / 100;
					let _comision_reas = _comision_reas + _monto2;
					Let _monto3  = _monto3 - _monto2;

					-- Impuesto Recuperado

					Let _monto2 = _monto * _factor_impuesto / 100;
					let _impuesto_recup = _impuesto_recup + _monto2;
					Let _monto3  = _monto3 - _monto2;

				end if
			
				let _reas_x_pagar = _reas_x_pagar + _monto3;

			End If

		End Foreach

	End Foreach

	if _tipo = 1 then
		let _tipo_nombre = "Directo";
	else
		let _tipo_nombre = "Coaseguro";
	end if

	return _no_documento,
		   _nombre_cliente,
		   _nombre_agente,
	       _prima_bruta,
		   _impuesto,
		   _prima_neta,
		   _prima_suscrita,
		   _coas_x_pagar,
		   _comision,
		   _impuesto_2,
		   _retencion,
		   _reserva,
		   _reas_cedido,
		   _impuesto_recup,
		   _comision_reas,
		   _reas_x_pagar,
		   _saldo90,
           _saldo120,
		   _tipo_nombre,	
		   _cod_ramo,
		   _nombre_ramo
		   with resume;

end foreach

END PROCEDURE;
