-- Generacion de Registros Contables de la Remesa Plan 3 en 1 Tecnica de seguros

-- Creado    : 25/04/2016 - Autor: Federico Coronado

-- SIS v.2.0 - sp_cob29 -- DEIVID, S.A.

drop procedure sp_par203_3en1;

create procedure "informix".sp_par203_3en1(a_no_remesa char(10), a_no_poliza char(10), a_cuenta_banco char(25), a_cod_lider char(3), a_tipo_remesa char(1), _monto_banco dec(16,2))
returning integer,
		  char(100);

define _tipo_mov         	char(1);  
define _renglon          	smallint; 
define _cuenta           	char(25); 
define _cuenta_visa       	char(25); 
define _debito           	dec(16,2);
define _credito          	dec(16,2);
define _prima_neta       	dec(16,2);
define _prima_neta_original dec(16,2);
define _resultado1 			dec(16,2);          
define _resultado2 			dec(16,2);
define _resultado3 			dec(16,2);
define _resultado4 			dec(16,2);
define _resultado5 			dec(16,2);
define _resultado6 			dec(16,2);
define _porc_auto           dec(16,2);
define _cod_tipoprod     	char(3);  
define _tipo_produccion  	smallint; 
define _no_poliza        	char(10); 
define _monto_descontado	dec(16,2);
define _no_documento     	char(30);
define _no_reclamo       	char(10);
define _porc_partic      	dec(7,4);
define _monto			 	dec(16,2);
define _monto_original      dec(16,2);
define _fecha_param			date;
define _fecha				date;
define _valor_pago      	dec(16,2);
define _cod_banco    		char(3);
define _cod_chequera   		char(3);
define _cod_banco_visa    	char(3);
define _cod_compania 		char(3);
define _cod_sucursal 		char(3);
define _date_posteo  		date;
define _periodo      		char(7);

define _prima_suscrita     	dec(16,2);
define _comis_manual     	dec(16,2);
define _suma_comision		dec(16,2);
define _porc_partic_coas    decimal(7,4);
define _porc_partic_coas2   decimal(7,4);
define _cod_coasegur 		char(3);
define _porc_comis_agt   	decimal(5,2);
define _porc_partic_agt	 	decimal(5,2);
define _cod_auxiliar 		char(5);
define _cod_agente	 		char(5);
define _tipo_agente			char(1);
define _cantidad			smallint;
define _auxiliar	 		char(5);

define _impuesto			dec(16,2);
define _impuesto_original 	dec(16,2);
define _suma_impuesto		dec(16,2);
define _cant_impuestos		smallint;
define _cod_impuesto		char(3);
define _cuenta_inc			char(25);
define _cuenta_dan			char(25);
define _factor_impuesto	 	dec(5,2);
define _cod_ramo			char(3);
define _cod_subramo			char(3);
define _user_added			char(8);

define _error				integer;
define _error_2      		integer;
define _error_desc   		char(50);

define ll_renglon          	smallint; 
define ld_diferencia	 	dec(16,2);

define ls_renglon          	char(5); 
define ls_diferencia	 	char(16);

define _coas_por_pagar		dec(16,2);
define _impuesto_suscrito   dec(16,2);
define _no_cambio			smallint;
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_contrato		char(5);
define _bouquet				smallint;
define _porc_partic_prima	dec(9,6);
define _porc_cont_partic 	dec(5,2);
define _porc_comis_ase   	dec(5,2);
define _tiene_comis_rea	 	smallint;
define _consolida_mayor	 	smallint;
define _cod_origen_aseg	  	char(3);
define _monto_reas		 	dec(16,2);

define _adelanto_comis		smallint;

define _cod_abogado         char(3);
define _porc_comis			dec(5,2);
define _cedula				varchar(30);
define _nombre_abogado		varchar(50);
define _cod_cliente         char(10);
define _honorario        	dec(16,2);
define _mensaje             char(250);
define _porc_proporcion     dec(16,4);
define _cod_origen          char(3);
define _v                   smallint;


set isolation to dirty read;

--set debug file to "sp_par203_3en1.trc";
--trace on;

begin

on exception set _error, _error_2, _error_desc 
 	return _error, trim(_error_desc) || " " || _renglon;
end exception           

FOREACH
	SELECT	tipo_mov,
			prima_neta,
			no_poliza,
			monto_descontado,
			renglon,
			doc_remesa,
			monto,
			no_reclamo,
			impuesto,
			cod_auxiliar,
			cod_agente
	INTO	_tipo_mov,
			_prima_neta_original,
			_no_poliza,
			_monto_descontado,
			_renglon,
			_no_documento,
			_monto_original,
			_no_reclamo,
			_impuesto_original,
			_auxiliar,
			_cod_agente
	 FROM	cobredet
	WHERE	no_remesa = a_no_remesa
	  and   no_poliza = a_no_poliza
	order by renglon

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;

	if _no_cambio is null then
		let _mensaje = 'No Existe Distribucion de Reaseguro para Esta Poliza: '|| trim(_no_documento) ||', Por Favor Verifique ...';
		return 1, _mensaje;
	end if
	
	call sp_sis188(_no_poliza) returning _error,_mensaje;
		foreach
			select no_unidad,
				   cod_ramo
			  into _no_unidad,
				   _cod_ramo
			  from emipouni 
			 where no_poliza = _no_poliza

			 let _resultado1 = 0;
			 let _resultado2 = 0;
			 let _resultado3 = 0;
			 let _resultado4 = 0;
			 let _resultado5 = 0;
			 let _resultado6 = 0;
			 let _porc_auto  = 0;
			 
			foreach
				select distinct(cod_cober_reas)
				  into _cod_cober_reas
				  from emireaco
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and no_cambio = _no_cambio
				
				select porc_cober_reas
				  into _porc_proporcion
				  from tmp_dist_rea
				 where cod_cober_reas = _cod_cober_reas;
				 
				 let _monto       = _monto_original;
				 let _resultado5  = (_porc_proporcion/100)*_monto;
				 let _resultado1  = _resultado5/1.05;
				 let _resultado2  = _resultado5 - _resultado1;
				 
				if _cod_ramo = '020' then
					let _porc_auto   = _resultado1 -(_resultado1 / 1.01);
					let _resultado1  = _resultado1 / 1.01;
					let _resultado2  = _resultado2 - _porc_auto;
				end if
				 
				 let _resultado3 = _resultado1 + _resultado3;
				 let _resultado4 = _resultado2 + _resultado4;
				 let _resultado6 = _resultado5 + _resultado6;	 
				 
			end foreach 
			 let _prima_neta = _resultado3;
			 let _impuesto   = _resultado4;
			 let _monto      = _resultado6;
	
			if _tipo_mov         = 'M' AND
			   _monto_descontado <> 0  THEN
				let _monto_banco = 0 - _monto_descontado;
			elif _tipo_mov       = 'X' then
				let _monto_banco = _prima_neta;
			else
				let _monto_banco = _monto - _monto_descontado;
			end if

			IF _tipo_mov in ('P', 'N') THEN -- Pago a Prima, Nota Credito

				SELECT cod_tipoprod,
					   cod_subramo,
					   cod_origen
				  INTO _cod_tipoprod,
					   _cod_subramo,
					   _cod_origen
				  FROM emipomae
				 WHERE no_poliza = _no_poliza;

				SELECT tipo_produccion
				  INTO _tipo_produccion
				  FROM emitipro
				 WHERE cod_tipoprod = _cod_tipoprod;

				select porc_partic_coas
				  into _porc_partic_coas
				  from emicoama
				 where no_poliza    = _no_poliza
				   and cod_coasegur = a_cod_lider;
				
				if _porc_partic_coas is null then
					let _porc_partic_coas = 100;
				end if

				let _prima_suscrita    = _prima_neta * _porc_partic_coas / 100;
				let _impuesto_suscrito = _impuesto   * _porc_partic_coas / 100;

				-- Banco
				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Prima por Cobrar

				IF _tipo_produccion = 3 THEN 
					LET _cuenta = sp_sis15('PACXCC', '04', _cod_origen,_cod_ramo,_cod_subramo);  -- Coaseguro Minoritario
				ELIF _tipo_produccion = 4 THEN 
					LET _cuenta = sp_sis15('PAPXCRA', '04', _cod_origen,_cod_ramo,_cod_subramo);  -- Reaseguro Asumido
				ELSE						 
					LET _cuenta = sp_sis15('PAPXCSD', '04', _cod_origen,_cod_ramo,_cod_subramo);  -- Produccion Directa
				END IF

				IF _tipo_mov = 'P' THEN
					LET _debito  = 0;
					LET _credito = _prima_neta;
				ELSE
					LET _debito  = _prima_neta * -1;
					LET _credito = 0;
				END IF

				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);	 --asiento de la remesa

				-- Auxiliar para Reaseguro Asumido

				if _tipo_produccion = 4 then

					select cod_coasegur
					  into _cod_coasegur
					  from emiciara
					 where no_poliza    = _no_poliza;

					select cod_auxiliar
					  into _cod_auxiliar
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					if _cod_auxiliar is null then

						if _cod_coasegur is null then
							return 1, "La Poliza " || _no_documento || " No Tiene Informacion de Reas. Asumido";
						else
							return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
						end if

					end if

					CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

				end if
			
				if _impuesto <> 0.00 then

					let _suma_impuesto = 0.00;

					foreach	
					 select cod_impuesto
					   into _cod_impuesto
					   from emipolim
					  where no_poliza = _no_poliza

						select factor_impuesto,
							   cta_incendio,
							   cta_danos
						  into _factor_impuesto,
							   _cuenta_inc,
							   _cuenta_dan
						  from prdimpue
						 where cod_impuesto = _cod_impuesto;
								
						let _monto = _prima_suscrita * _factor_impuesto / 100;

						let _suma_impuesto = _suma_impuesto + _monto;
						let _suma_impuesto = _suma_impuesto -_porc_auto;

						If _cod_ramo in ("001", "003") then       -- Incendio, Multiriesgos
							Let _cuenta = sp_sis15(_cuenta_inc); 
						else								      -- Otros Ramos
							Let _cuenta = sp_sis15(_cuenta_dan); 
						end If

						if _monto <> 0.00 Then

							let _debito  = 0.00;
							let _credito = 0.00;

							if _tipo_mov = 'P' then
								Let _credito = _monto;
							else
								Let _debito  = _monto * -1;
							end if
				
							CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

						end If

					end foreach
					/*solo para las polizas del ramo combinado cuando la unidad es la soda para incliur el 0.01*/
					if _cod_ramo = '020' then
						--let _suma_impuesto = 0.00;
						select factor_impuesto,
							   cta_incendio,
							   cta_danos
						  into _factor_impuesto,
							   _cuenta_inc,
							   _cuenta_dan
						  from prdimpue
						 where cod_impuesto = '002';
								
						let _monto = _porc_auto;

						Let _cuenta = sp_sis15(_cuenta_dan); 

						if _monto <> 0.00 Then

							let _debito  = 0.00;
							let _credito = 0.00;

							if _tipo_mov = 'P' then
								Let _credito = _monto;
							else
								Let _debito  = _monto * -1;
							end if
				
							CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

						end If
					end if

					-- Diferencia en la Multiplicacion por la separacion del impuesto
					
					if _impuesto_suscrito <> _suma_impuesto then

						let _monto   = _impuesto_suscrito - _suma_impuesto;
						let _debito  = 0.00;
						let _credito = 0.00;

						if _tipo_mov = 'P' then
							let _credito = _monto;
						else
							let _debito  = _monto * -1;
						end if

						call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

					end if

				end If

			-- Provision de Comision y Comision por Pagar (Auxiliar)

			if _tipo_produccion in (1, 2, 3) then

				foreach
				 select	porc_comis_agt,
						porc_partic_agt,
						cod_agente,
						monto_man
				   into	_porc_comis_agt,
						_porc_partic_agt,
						_cod_agente,
						_comis_manual
				   from cobreagt
				  where	no_remesa = a_no_remesa
					and renglon   = _renglon
		
					select tipo_agente
					  into _tipo_agente
					  from agtagent
					 where cod_agente = _cod_agente;

					if _tipo_agente = "O" then -- Oficina 
						continue foreach;
					end if

					let _cod_auxiliar = "A" || _cod_agente[2,5]; -- En SAC no alcanza para poner los 5 digitos

					if _porc_comis_agt <> 0 THEN

						let _monto = _prima_suscrita * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);

						if a_tipo_remesa = "B" then
							let _monto = _comis_manual;
						end if

						if _monto <> 0.00 Then

							-- Provision de Comision

							Let _debito  = 0.00;
							Let _credito = 0.00;

							IF _tipo_mov = 'P' THEN
								LET _debito  = _monto;
							ELSE
								LET _credito = _monto * -1;
							END IF

							Let _cuenta    = sp_sis15('PPCOMXPCO', '04', _cod_origen,_cod_ramo,_cod_subramo); 
							CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

						end if

						let _monto = _prima_neta * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);

						if a_tipo_remesa = "B" then
							let _monto = _comis_manual;
						end if

						if _monto <> 0.00 Then

							-- Comision por Pagar Auxiliar

							Let _debito  = 0.00;
							Let _credito = 0.00;

							IF _tipo_mov = 'P' THEN
								Let _credito = _monto;
							else
								Let _debito  = _monto * -1;
							end if

							Let _cuenta    = sp_sis15('CPCXPAUX', '04', _cod_origen,_cod_ramo,_cod_subramo);  
							CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
							CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

							-- Adelanto de Comision

							select count(*)
							  into _adelanto_comis
							  from cobadeco
							 where no_documento = _no_documento 					
							   and cod_agente   = _cod_agente;

							if _adelanto_comis = 1 then

								-- Comision por Pagar Auxiliar

								let _debito  = 0.00;
								let _credito = 0.00;

								if _tipo_mov = 'P' THEN
									let _debito  = _monto;
								else
									let _credito = _monto * -1;
								end if

								let _cuenta    = sp_sis15('CPCXPAUX', '04', _cod_origen,_cod_ramo,_cod_subramo); 
								call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
								call sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

								-- Cuenta de Adelanto de Comisiones

								let _debito  = 0.00;
								let _credito = 0.00;

								if _tipo_mov = 'P' then
									let _credito = _monto;
								else
									let _debito  = _monto * -1;
								end if

								let _cuenta    = sp_sis15('CPCADECOM', '04', _cod_origen,_cod_ramo,_cod_subramo);  
								call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
								call sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

							end if
						end if
					end if

						-- Comision Descontada 

						If _monto_descontado <> 0.00 Then

							-- Comision por Pagar Auxiliar

							let _monto = _comis_manual;
						
							let _cuenta = sp_sis15('CPCXPAUX', '04', _cod_origen,_cod_ramo,_cod_subramo);  -- Comision por Pagar

							let _debito  = 0;
							let _credito = 0;

							if _tipo_mov = 'P' THEN
								let _debito  = _monto;
							else
								let _credito = _monto * -1;
							end if

							call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
							call sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

						end if
				end foreach

				-- Cuentas para coaseguro mayoritario (Coaseguro por Pagar)

				foreach	
					select porc_partic_coas,
						   cod_coasegur
					  into _porc_partic_coas2,
						   _cod_coasegur
					  from emicoama
					 where no_poliza    = _no_poliza
					   and cod_coasegur <> a_cod_lider

					select cod_auxiliar
					  into _cod_auxiliar
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					if _cod_auxiliar is null then
						return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
					end if

					-- Coaseguro Diferido

					let _coas_por_pagar  = _prima_neta * _porc_partic_coas2 / 100;

					let _monto   = _coas_por_pagar;
					Let _debito  = 0.00;
					Let _credito = 0.00;

					IF _tipo_mov = 'P' THEN
						LET _debito  = _monto;
						LET _credito = 0;
					ELSE
						LET _debito  = 0;
						LET _credito = _monto * -1;
					END IF

					Let _cuenta = sp_sis15("PPCOAMDIF", '04', _cod_origen,_cod_ramo,_cod_subramo);    
					CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
					CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

					-- Coaseguro por Pagar
					let _suma_impuesto = 0.00;

					if _impuesto <> 0.00 then

						foreach	
						 select cod_impuesto
						   into _cod_impuesto
						   from emipolim
						  where no_poliza = _no_poliza

							select factor_impuesto
							  into _factor_impuesto
							  from prdimpue
							 where cod_impuesto = _cod_impuesto;
									
							let _monto = _coas_por_pagar * _factor_impuesto / 100;

							let _suma_impuesto = _suma_impuesto + _monto;

						end Foreach

					end If

					let _suma_comision = 0.00;

					foreach
						 select	porc_comis_agt,
								porc_partic_agt,
								cod_agente
						   Into	_porc_comis_agt,
								_porc_partic_agt,
								_cod_agente
						   From cobreagt
						  Where	no_remesa = a_no_remesa
							and renglon   = _renglon
				
						 select tipo_agente
						   into _tipo_agente
						   from agtagent
						  where cod_agente = _cod_agente;

						if _tipo_agente = "O" then -- Agentes Oficina
							continue foreach;
						end if

						if _porc_comis_agt <> 0 THEN
							let _monto = _coas_por_pagar * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
							let _suma_comision = _suma_comision + _monto;
						end if

					end foreach

					let _coas_por_pagar  = _coas_por_pagar + _suma_impuesto - _suma_comision;

					let _monto   = _coas_por_pagar;
					Let _debito  = 0.00;
					Let _credito = 0.00;

					IF _tipo_mov = 'P' THEN
						LET _debito  = 0;
						LET _credito = _monto;
					ELSE
						LET _debito  = _monto * -1;
						LET _credito = 0;
					END IF

						let _cuenta = sp_sis15("PPCOASXP", '04', _cod_origen,_cod_ramo,_cod_subramo);    
						call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
						call sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

				end foreach

				-- Cuadre de asientos por coaseguro mayoritario
				if _tipo_produccion = 2 then

					select SUM(debito - credito)
					  into _monto
					  from cobasien
					 where no_remesa = a_no_remesa
					   and renglon   = _renglon;

					if _monto <> 0 then

						let _debito  = 0.00;
						let _credito = 0.00;

						if _tipo_mov = 'P' THEN
							let _credito = _monto;
						else
							let _debito  = _monto * -1;
						end if

						call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
						call sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

					end if
				end if
			end if

			ELIF _tipo_mov = 'X' THEN -- Eliminacion de centavos

				SELECT cod_tipoprod,
					   cod_subramo
				  INTO _cod_tipoprod,
					   _cod_subramo
				  FROM emipomae
				 WHERE no_poliza = _no_poliza;

				SELECT tipo_produccion
				  INTO _tipo_produccion
				  FROM emitipro
				 WHERE cod_tipoprod = _cod_tipoprod;

				select porc_partic_coas
				  into _porc_partic_coas
				  from emicoama
				 where no_poliza    = _no_poliza
				   and cod_coasegur = a_cod_lider;
				
				if _porc_partic_coas is null then
					let _porc_partic_coas = 100;
				end if

				let _prima_suscrita    = _prima_neta * _porc_partic_coas / 100;
				let _impuesto_suscrito = _impuesto   * _porc_partic_coas / 100;

				-- Banco
				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				if _tipo_produccion <> 2 then

					CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				end if

				-- Prima por Cobrar

				IF _tipo_produccion = 3 THEN 
					LET _cuenta = sp_sis15('PACXCC', '04', _cod_origen,_cod_ramo,_cod_subramo);  -- Coaseguro Minoritario
				ELIF _tipo_produccion = 4 THEN 
					LET _cuenta = sp_sis15('PAPXCRA', '04', _cod_origen,_cod_ramo,_cod_subramo); -- Reaseguro Asumido
				ELSE						 
					LET _cuenta = sp_sis15('PAPXCSD', '04', _cod_origen,_cod_ramo,_cod_subramo); -- Produccion Directa
				END IF

				if _monto > 0 then
				   LET _debito  = 0;
				   LET _credito = _prima_neta;
				else
				   LET _debito  = _prima_neta * -1;
				   LET _credito = 0;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);	 --asiento de la remesa

				-- Auxiliar para Reaseguro Asumido

				if _tipo_produccion = 4 then

					select cod_coasegur
					  into _cod_coasegur
					  from emiciara
					 where no_poliza    = _no_poliza;

					select cod_auxiliar
					  into _cod_auxiliar
					  from emicoase
					 where cod_coasegur = _cod_coasegur;

					if _cod_auxiliar is null then

						if _cod_coasegur is null then
							return 1, "La Poliza " || _no_documento || " No Tiene Informacion de Reas. Asumido";
						else
							return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
						end if

					end if

					CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

				end if
			
				-- Provision de Comision y Comision por Pagar (Auxiliar)

				if _tipo_produccion in (1, 2, 3) then
				  
					-- Cuentas para coaseguro mayoritario (Coaseguro por Pagar)

				   foreach	
						select porc_partic_coas,
							   cod_coasegur
						  into _porc_partic_coas2,
							   _cod_coasegur
						  from emicoama
						 where no_poliza    = _no_poliza
						   and cod_coasegur <> a_cod_lider

						select cod_auxiliar
						  into _cod_auxiliar
						  from emicoase
						 where cod_coasegur = _cod_coasegur;

						if _cod_auxiliar is null then
							return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
						end if

						-- Coaseguro Diferido

						let _coas_por_pagar  = _prima_neta * _porc_partic_coas2 / 100;

						let _monto   = _coas_por_pagar;
						Let _debito  = 0.00;
						Let _credito = 0.00;

						IF _prima_neta > 0 THEN
							LET _debito  = _monto;
							LET _credito = 0;
						ELSE
							LET _debito  = 0;
							LET _credito = _monto * -1;
						END IF

						Let _cuenta = sp_sis15("PPCOAMDIF", '04', _cod_origen,_cod_ramo,_cod_subramo);   
						CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
						CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

						-- Coaseguro por Pagar

						let _suma_impuesto = 0.00;
						let _impuesto = 0.00;

					end foreach

				if _tipo_produccion = 2 then

					select porc_partic_coas
					  into _porc_partic_coas2
					  from emicoama
					 where no_poliza    = _no_poliza
					   and cod_coasegur = a_cod_lider;

					let _coas_por_pagar  = _prima_neta * _porc_partic_coas2 / 100;
					let _monto   = _coas_por_pagar;
					Let _debito  = 0.00;
					Let _credito = 0.00;

					IF _prima_neta >= 0 THEN
						LET _debito  = _monto;
						LET _credito = 0;
					ELSE
						LET _debito  = 0;
						LET _credito = _monto * -1;
					END IF

					CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				end if
					-- Cuadre de asientos por coaseguro mayoritario
				if _tipo_produccion = 2 then

					select SUM(debito - credito)
					  into _monto
					  from cobasien
					 where no_remesa = a_no_remesa
					   and renglon   = _renglon;

					if _monto <> 0 then

						let _debito  = 0.00;
						let _credito = 0.00;

						if _monto > 0 THEN
							let _credito = _monto;
						else
							let _debito  = _monto * -1;
						end if

						call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
						call sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);
					end if
				end if		

				end if

			ELIF _tipo_mov = 'C' THEN -- Comision Descontada

				-- Banco

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Comision por Pagar

				LET _cuenta  = sp_sis15('CPCXPAUX',  '03'); 

				IF _monto > 0 THEN
					LET _debito  = 0;
					LET _credito = _monto;
				ELSE
					LET _debito  = _monto * -1;
					LET _credito = 0;
				END IF

				if _auxiliar is null then
					let _auxiliar = "A" || _cod_agente[2,5]; -- En SAC no alcanza para poner los 5 digitos
				end if

				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _auxiliar, _debito, _credito);

			ELIF _tipo_mov = 'M' THEN -- Afectacion Catalogo

				if a_tipo_remesa = "T" then
					let _monto_banco = _prima_neta;
				end if
				-- Banco
				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Catalogo

				LET _cuenta = _no_documento;

				IF _monto > 0 THEN

					IF _monto_descontado <> 0 THEN
						LET _debito  = _monto;
						LET _credito = 0;
					ELSE
						LET _debito  = 0;
						LET _credito = _monto;
					END IF

					if a_tipo_remesa = "T" then	--remesa de elim de cent.
						select sum(prima_neta)
						  into _credito
						  from cobredet
						 where no_remesa = a_no_remesa
						   and tipo_mov  = "M";

						if _credito < 0 then
							let _credito = _credito * -1;
						end if
						let _debito = 0;
					end if

				ELSE

					IF _monto_descontado <> 0 THEN
						LET _debito  = 0;
						LET _credito = _monto * -1;
					ELSE
						LET _debito  = _monto * -1;
						LET _credito = 0;
					END IF

					if a_tipo_remesa = "T" then	--remesa de elim de cent.
						select sum(prima_neta)
						  into _debito
						  from cobredet
						 where no_remesa = a_no_remesa
						   and tipo_mov  = "M";

						if _debito < 0 then
							let _debito = _debito * -1;
						end if
						let _credito = 0;
					end if

				END IF

				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				if _auxiliar is not null then
					call sp_sis86(a_no_remesa, _renglon, _cuenta, _auxiliar, _debito, _credito);
				end if

			ELIF _tipo_mov = 'D' THEN -- Pago de Deducible

				SELECT no_poliza
				  INTO _no_poliza
				  FROM recrcmae
				 WHERE no_reclamo = _no_reclamo;

				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = _no_poliza;

				SELECT tipo_produccion
				  INTO _tipo_produccion
				  FROM emitipro
				 WHERE cod_tipoprod = _cod_tipoprod;

				-- Banco

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Deducible

				IF   _tipo_produccion = 4 THEN -- Reaseguro Asumido

					LET  _cuenta  = sp_sis15('SGPDDRA', '04', _cod_origen,_cod_ramo,_cod_subramo); 
					LET  _debito  = 0;
					LET  _credito = _monto;
					CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				ELIF _tipo_produccion = 2 THEN -- Coaseguro Mayoritario

					SELECT porc_partic_coas
					  INTO _porc_partic
					  FROM reccoas
					 WHERE no_reclamo   = _no_reclamo
					   AND cod_coasegur = a_cod_lider;
					 
					IF _porc_partic IS NULL THEN
						LET _porc_partic = 100;
					END IF
					 
					LET _valor_pago = _monto;

					LET  _monto   = _valor_pago / 100 * _porc_partic; 
					LET  _cuenta  = sp_sis15('SGPDDSD', '04', _cod_origen,_cod_ramo,_cod_subramo);  
					LET  _debito  = 0;
					LET  _credito = _monto;
					CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				   foreach
					SELECT porc_partic_coas,
						   cod_coasegur
					  INTO _porc_partic,
						   _cod_coasegur
					  FROM reccoas
					 WHERE no_reclamo   =  _no_reclamo
					   AND cod_coasegur <> a_cod_lider
					 
						select cod_auxiliar
						  into _cod_auxiliar
						  from emicoase
						 where cod_coasegur = _cod_coasegur;

						if _cod_auxiliar is null then
							return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
						end if

						IF _porc_partic IS NULL THEN
							LET _porc_partic = 100;
						END IF

						LET  _monto   = _valor_pago / 100 * _porc_partic; 

						LET  _cuenta  = sp_sis15('SARXCC', '04', _cod_origen,_cod_ramo,_cod_subramo);  
						LET  _debito  = 0;
						LET  _credito = _monto;
						CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
						CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

					end foreach

				ELSE						   -- Sin Coaseguro, Coas. Minoritario

					LET  _cuenta  = sp_sis15('SGPDDSD', '04', _cod_origen,_cod_ramo,_cod_subramo);  
					LET  _debito  = 0;
					LET  _credito = _monto;
					CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				END IF

			ELIF _tipo_mov = 'S' THEN -- Pago de Salvamento

				SELECT no_poliza
				  INTO _no_poliza
				  FROM recrcmae
				 WHERE no_reclamo = _no_reclamo;

				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = _no_poliza;

				SELECT tipo_produccion
				  INTO _tipo_produccion
				  FROM emitipro
				 WHERE cod_tipoprod = _cod_tipoprod;

				-- Banco

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Salvamento

				IF   _tipo_produccion = 2 THEN -- Coaseguro Mayoritario

					SELECT porc_partic_coas
					  INTO _porc_partic
					  FROM reccoas
					 WHERE no_reclamo   = _no_reclamo
					   AND cod_coasegur = a_cod_lider;
					 
					IF _porc_partic IS NULL THEN
						LET _porc_partic = 100;
					END IF
					 
					LET _valor_pago = _monto;

					LET  _monto   = _valor_pago / 100 * _porc_partic; 
					LET  _cuenta  = sp_sis15('SISAL', '04', _cod_origen,_cod_ramo,_cod_subramo);  
					LET  _debito  = 0;
					LET  _credito = _monto;
					CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
					 
				   foreach
					SELECT porc_partic_coas,
						   cod_coasegur
					  INTO _porc_partic,
						   _cod_coasegur
					  FROM reccoas
					 WHERE no_reclamo   =  _no_reclamo
					   AND cod_coasegur <> a_cod_lider
					 
						select cod_auxiliar
						  into _cod_auxiliar
						  from emicoase
						 where cod_coasegur = _cod_coasegur;

						if _cod_auxiliar is null then
							return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
						end if

						IF _porc_partic IS NULL THEN
							LET _porc_partic = 100;
						END IF

						LET  _monto   = _valor_pago / 100 * _porc_partic; 

						LET  _cuenta  = sp_sis15('SARXCC', '04', _cod_origen,_cod_ramo,_cod_subramo); 
						LET  _debito  = 0;
						LET  _credito = _monto;
						CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
						CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

					end foreach

				ELSE						   -- Sin Coaseguro, Coas. Minoritario

					LET  _cuenta  = sp_sis15('SISAL', '04', _cod_origen,_cod_ramo,_cod_subramo);  
					LET  _debito  = 0;
					LET  _credito = _monto;
					CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				END IF

			ELIF _tipo_mov = 'R' THEN -- Pago de Recupero

				SELECT no_poliza
				  INTO _no_poliza
				  FROM recrcmae
				 WHERE no_reclamo = _no_reclamo;

				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = _no_poliza;

				SELECT tipo_produccion
				  INTO _tipo_produccion
				  FROM emitipro
				 WHERE cod_tipoprod = _cod_tipoprod;

				-- Banco

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Recupero

				IF   _tipo_produccion = 2 THEN -- Coaseguro Mayoritario

					SELECT porc_partic_coas
					  INTO _porc_partic
					  FROM reccoas
					 WHERE no_reclamo   = _no_reclamo
					   AND cod_coasegur = a_cod_lider;
					 
					IF _porc_partic IS NULL THEN
						LET _porc_partic = 100;
					END IF
					 
					LET _valor_pago = _monto;

					LET  _monto   = _valor_pago / 100 * _porc_partic; 
					LET  _cuenta  = sp_sis15('SIREC', '04', _cod_origen,_cod_ramo,_cod_subramo); 
					LET  _debito  = 0;
					LET  _credito = _monto;
					CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
					 
				   foreach
					SELECT porc_partic_coas,
						   cod_coasegur
					  INTO _porc_partic,
						   _cod_coasegur
					  FROM reccoas
					 WHERE no_reclamo   =  _no_reclamo
					   AND cod_coasegur <> a_cod_lider
					 
						select cod_auxiliar
						  into _cod_auxiliar
						  from emicoase
						 where cod_coasegur = _cod_coasegur;

						if _cod_auxiliar is null then
							return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
						end if

						IF _porc_partic IS NULL THEN
							LET _porc_partic = 100;
						END IF

						LET  _monto   = _valor_pago / 100 * _porc_partic; 

						LET  _cuenta  = sp_sis15('SARXCC', '04', _cod_origen,_cod_ramo,_cod_subramo);  
						LET  _debito  = 0;
						LET  _credito = _monto;
						CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
						CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

					end foreach

				ELSE						   -- Sin Coaseguro, Coas. Minoritario

					LET  _cuenta  = sp_sis15('SIREC', '04', _cod_origen,_cod_ramo,_cod_subramo);  
					LET  _debito  = 0;
					LET  _credito = _monto;
					CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				END IF

			ELIF _tipo_mov = 'L' THEN -- Cobros Legales

				-- Caja

				let ls_renglon    = _renglon;

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Ingreso por Cobros Legales

				LET  _cuenta   = sp_sis15('CICOBLEG');
				
				if _monto_banco > 0 then
					LET  _debito   = 0;
					LET  _credito  = _monto_banco;
				else
					LET  _debito   = _monto_banco * -1;
					LET  _credito  = 0;
				end if

				let  _auxiliar = "G0001";

				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				call sp_sis86(a_no_remesa, _renglon, _cuenta, _auxiliar, _debito, _credito);

				-- Cuentas de Orden (80005)

				if _monto_banco > 0 then
					LET _debito  = 0;
					LET _credito = _monto_banco;
				else
					LET _debito  = _monto_banco * -1;
					LET _credito = 0;
				end if

				let _cuenta = sp_sis15('PCANCOBL8');
				call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				-- Cuentas de Orden (90005)

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				let _cuenta = sp_sis15('PCANCOBL9');
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				-- Calcular el Honorario del Abogado

				SELECT cod_abogado
				  INTO _cod_abogado
				  FROM coboutleg
				 WHERE no_documento = _no_documento;

				if _cod_abogado is null then
				
					SELECT cod_abogado
					  INTO _cod_abogado
					  FROM coboutlegh
					 WHERE no_documento = _no_documento;
					 
					if _cod_abogado is null then
						return 1, "No Existe Codigo del Abogado - Cobros Legales " || a_no_remesa || " Renglon #: " || ls_renglon;
					end if	

				end if
			
				SELECT porc_comis,
					   cedula,
					   nombre_abogado
				  INTO _porc_comis,
					   _cedula,
					   _nombre_abogado
				  FROM recaboga
				 WHERE cod_abogado = _cod_abogado;

			{	if _porc_comis is null or _porc_comis = 0 then	-- Ya esto no va segun lo acordado en la reunion del 27/02/2013
				
					return 1, "No Existe % Comision del Abogado - Cobros Legales " || a_no_remesa || " Renglon #: " || ls_renglon;

				end if
			  }
				let _honorario = _monto_banco * _porc_comis / 100;


				if _cedula is null or trim(_cedula) = ""  then
				
					return 1, "Abogado con cedula en nulo o en blanco - Cobros Legales " || a_no_remesa || " Renglon #: " || ls_renglon;

				end if

				-- Determinar el codigo del auxiliar

				let _cod_cliente = sp_par332(_cedula, _nombre_abogado, _user_added);
				let _auxiliar    = sp_sac203(_cod_cliente);
				
				if _honorario > 0 then
					LET _debito  = _honorario;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _honorario * -1;
				end if

				let _cuenta = sp_sis15('CICOBLEG'); 
				call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				call sp_sis86(a_no_remesa, _renglon, _cuenta, _auxiliar, _debito, _credito);

				-- Cuentas Por Pagar a los Abogados

				if _honorario > 0 then
					LET _debito  = 0;
					LET _credito = _honorario;
				else
					LET _debito  = _honorario * -1;
					LET _credito = 0;
				end if

				let _cuenta = sp_sis15('CCXPABOLEG');
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				call sp_sis86(a_no_remesa, _renglon, _cuenta, _auxiliar, _debito, _credito);

			ELIF _tipo_mov = 'K' THEN -- Devolucion de Primas por Cancelacion

				-- Caja

				let ls_renglon    = _renglon;

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Devolucion por Poliza Cancelada

				LET  _cuenta   = sp_sis15('PCANDEVPR');
				
				if _monto_banco > 0 then
					LET  _debito   = 0;
					LET  _credito  = _monto_banco;
				else
					LET  _debito   = _monto_banco * -1;
					LET  _credito  = 0;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			ELIF _tipo_mov = 'E' THEN -- Crear Prima en Suspenso

				-- Caja

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Prima en Suspenso

				LET  _cuenta  = sp_sis15('CPCPES'); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			ELIF _tipo_mov = 'A' THEN -- Aplicar Prima en Suspenso

				-- Caja

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				call sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Prima en Suspenso

				LET  _cuenta  = sp_sis15('CPAPES'); 
				LET  _debito  = _monto * -1;
				LET  _credito = 0;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			ELIF _tipo_mov = 'T' THEN -- Aplicar Reclamos

				select no_poliza
				  into _no_poliza
				  from recrcmae
				 where no_reclamo = _no_reclamo;

				select cod_tipoprod
				  into _cod_tipoprod
				  from emipomae
				 where no_poliza = _no_poliza;

				select tipo_produccion
				  into _tipo_produccion
				  from emitipro
				 where cod_tipoprod = _cod_tipoprod;

				-- Reclamos por Pagar

				IF _fecha > _fecha_param THEN
					LET  _cuenta  = sp_sis15('BCXPP'); 
				ELSE
					LET  _cuenta  = sp_sis15('BCXPPV'); 
				END IF

				IF _monto > 0 THEN
					LET  _debito  = _monto;
					LET  _credito = 0;
				ELSE
					LET  _debito  = 0;
					LET  _credito = _monto * -1;
				END IF

				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				-- Contrapartida	

				IF _monto > 0 THEN
					LET  _debito  = 0;
					LET  _credito = _monto;
				ELSE
					LET  _debito  = _monto * -1;
					LET  _credito = 0;
				END IF

				if _tipo_produccion = 3 THEN -- Coaseguro Minoritario

					let _cuenta = sp_sis15('RPRCXA'); -- Reclamos de Coaseguro por Aplicar
					call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
					call sp_sis86(a_no_remesa, _renglon, _cuenta, _auxiliar, _debito, _credito);

				else

					let _cuenta = a_cuenta_banco; -- Caja
					call sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				end if

			ELIF _tipo_mov = 'O' THEN -- Deuda Agente

				-- Banco

				if _monto_banco > 0 then
					LET _debito  = _monto_banco;
					LET _credito = 0;
				else
					LET _debito  = 0;
					LET _credito = _monto_banco * -1;
				end if

				CALL sp_sis16(a_no_remesa, _renglon, a_cuenta_banco, _debito, _credito);

				-- Deuda del Agente

				LET _cuenta  = _no_documento;
				LET _debito  = 0;
				LET _credito = _monto;

				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

				if _auxiliar is not null then
					call sp_sis86(a_no_remesa, _renglon, _cuenta, _auxiliar, _debito, _credito);
				end if

			END IF
		--return 1, "";
		end foreach --emipouni
		drop table tmp_dist_rea;
END FOREACH
end
return 0, "Actualizacion Exitosa";

end procedure