-- Procedure que genera los asientos contables para los cheques
--
-- Creado el: 16/12/2008 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/09/2013 - Autor: Roman Gordón	-- Se Agrego el procedure sp_sis171a para llenar Chqreaco y chqreafa  
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par2763en1;
create procedure sp_par2763en1(
a_no_requis	  	char(10),
a_origen_cheque	char(1),
a_no_poliza     char(10)
) returning integer,
			char(50);

-- Variables Generales

define _cuenta			char(25);
define _cuenta_banco	char(25);
define _renglon			integer;
define _debito      	dec(16,2);
define _credito     	dec(16,2);
define _centro_costo	char(3);
define _cod_banco		char(3);
define _cod_chequera	char(3);
define _cod_origen		char(3);
define _cta_chequera  	smallint;
define _monto  	    	dec(16,2);
define _fecha_impresion	date;
define _bono_salud      smallint;

-- Otros Cheques

define _centro_costo2	char(3);
define _monto_cheque   	dec(16,2);

-- Devolucion de Primas

define _no_poliza		CHAR(10);
define _no_documento	char(20);
define _prima_bruta     DEC(16,2);
define _prima_neta      DEC(16,2);
define _cod_tipoprod    CHAR(3);  
define _cod_ramo		char(3);
define _tipo_produccion	smallint; 
define _impuesto	    DEC(16,2);
define _suma_impuesto	DEC(16,2);
define _cant_impuestos	integer;
define _cod_impuesto	char(3);
define _factor_impuesto	dec(5,2);
define _cuenta_inc	   	char(25);
define _cuenta_dan	   	char(25);
define _porc_comis_agt  dec(5,2);
define _porc_partic_agt	dec(5,2);
define _prima_suscrita  dec(16,2);

-- Cheques de Reclamos

define _transaccion		char(10);
define _no_tranrec		char(10);

-- Cheques de Comisiones

define _monto_ajuste		dec(16,2);
define _monto_comision		dec(16,2);
define _comision			dec(16,2);
define _porc_partic_coas	decimal(7,4);
define _cod_agente			char(10);
define _tipo_agente			char(1);
define _tipo_requis			char(1);
define _cod_coasegur 		char(3);
define _cod_lider	 		char(3);
define _cod_auxiliar 		char(5);
define _cod_subramo			char(3);
define _adelanto_comis		smallint;
define _comision_ganada		dec(16,2);
define _comision_saldo		dec(16,2);
define _prima_chqcomis		dec(16,2);
define _cta_auxiliar        char(1);
define _resultado1 			dec(16,2);          
define _resultado2 			dec(16,2);
define _resultado3 			dec(16,2);
define _resultado4 			dec(16,2);
define _resultado5 			dec(16,2);
define _resultado6 			dec(16,2);
define _prima_neta2         dec(16,2);
define _no_cambio           smallint;
define _cod_cober_reas      char(3);
define _no_unidad           char(5);
define _porc_proporcion     dec(16,4);
define _porc_auto           dec(16,2);
define _monto_original      dec(16,2);

-- Variables de Error

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Cuenta del Banco

select cod_banco,
       cod_chequera,
	   monto,
	   centro_costo,
	   fecha_impresion
  into _cod_banco,
       _cod_chequera,
	   _monto_cheque,
	   _centro_costo2,
	   _fecha_impresion
  from chqchmae
 where no_requis = a_no_requis;

select cod_origen,
	   cta_chequera
  into _cod_origen,
	   _cta_chequera
  from chqbanco
 where cod_banco = _cod_banco;

if _cod_origen = '001' then
	if _cta_chequera = 1 then
		let _cuenta_banco = sp_sis15('BACHEQL', '02', _cod_banco, _cod_chequera); -- Chequera Bancos Locales
	else
		let _cuenta_banco = sp_sis15('BACHEBL', '02', _cod_banco); -- Chequera Bancos Locales
	end if
else
	let _cuenta_banco = sp_sis15('BACHEBE', '02', _cod_banco); -- Chequera Bancos Extranjeros
end if

-- Registros Contables

--delete from chqctaux where no_requis = a_no_requis;
--delete from chqchcta where no_requis = a_no_requis;

select max(renglon)
  into _renglon
  from chqchcta
 where no_requis = a_no_requis;
 
 if _renglon is null then
	let _renglon = 0;
end if

	select par_ase_lider
	  into _cod_lider
	  from parparam
	 where cod_compania = "001";

	--Llenar Chqreaco y chqreafa  
{	call sp_sis171a(a_no_requis) returning _error,_error_desc;
	if _error <> 0 then
		return _error,_error_desc;
	end if
}	
	let _prima_neta2 = 0;
	foreach
		select no_poliza,
			   monto,
			   prima_neta,
			   no_documento
		  into _no_poliza,
			   _prima_bruta,
			   _prima_neta,
			   _no_documento
		  from chqchpol
		 where no_requis = a_no_requis
		   and no_poliza = a_no_poliza
		 
		 let _monto_original = 0;
		 
		call sp_sis188(_no_poliza) returning _error,_error_desc;
		select max(no_cambio)
		  into _no_cambio
		  from emireaco
		 where no_poliza = _no_poliza;

		select cod_tipoprod,
		       cod_ramo,
			   cod_origen,
			   cod_subramo
		  into _cod_tipoprod,
		       _cod_ramo,
			   _cod_origen,
			   _cod_subramo
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		let _prima_neta2 = _prima_neta;
		call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

		select tipo_produccion
		  into _tipo_produccion
		  from emitipro
		 where cod_tipoprod = _cod_tipoprod;

		-- Prima Neta
        foreach
			select cod_ramo,
			       no_unidad
			  into _cod_ramo,
				   _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza

			 let _resultado1 = 0;
			 let _resultado2 = 0;
			 let _resultado3 = 0;
			 let _resultado4 = 0;
			 let _resultado5 = 0;
			 let _resultado6 = 0;
			 let _porc_auto  = 0;
		
			if _tipo_produccion = 3 then 
				let _cuenta = sp_sis15('PACXCC',  '01', _no_poliza); -- Coaseguro Minoritario
			else
				let _cuenta = sp_sis15('PAPXCSD', '04', _cod_origen,_cod_ramo,_cod_subramo);
			end if
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
				 
				 let _monto       = _prima_bruta;
				 let _resultado5  = (_porc_proporcion/100)*_monto;
				 let _resultado1  = _resultado5/1.05;
				 let _resultado2  = _resultado5 - _resultado1;
			 
				if _cod_ramo = '020' then
					let _porc_auto   = _resultado1 -(_resultado1 / 1.01);
					let _resultado1  = _resultado1 / 1.01;
				end if
			 
				 let _resultado3 = _resultado1 + _resultado3;
				 let _resultado4 = _resultado2 + _resultado4;
				 let _resultado6 = _resultado5 + _resultado6;	 
			 
			end foreach
			
			let _prima_neta = _resultado3;
			let _impuesto   = _resultado4;
			let _monto      = _resultado6;
			let _monto_original = _monto_original + _monto;
			
				let _renglon = _renglon + 1;
				let _debito  = _prima_neta;
				let _credito = 0.00;

				insert into chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito,
				centro_costo,
				no_poliza
				)
				values(
				a_no_requis,
				_renglon,
				_cuenta,
				_debito,
				0,
				_centro_costo,
				_no_poliza
				);
		
		-- Impuestos


		if _impuesto <> 0.00 then

			-- Afectar el Impuesto

			let _suma_impuesto = 0.00;

			 select count(*)
			   into _cant_impuestos
			   from emipolim
			  where no_poliza = _no_poliza;

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
					    
				if _cant_impuestos = 1 then
					let _monto = _impuesto;
				else
					let _monto = _prima_neta * _factor_impuesto / 100;
				end if

				let _suma_impuesto = _suma_impuesto + _monto;

				If _cod_ramo in ("001", "003") then       -- Incendio, Multiriesgos
					Let _cuenta = sp_sis15(_cuenta_inc); 
				else								      -- Otros Ramos
					Let _cuenta = sp_sis15(_cuenta_dan); 
				end If

				let _debito  = _monto;
				let _credito = 0.00;
				let _renglon = _renglon + 1;

				INSERT INTO chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito,
				centro_costo,
				no_poliza
				)
				VALUES(
				a_no_requis,
				_renglon,
				_cuenta,
				_debito,
				0,
				_centro_costo,
				_no_poliza
				);

			end Foreach
			/*solo para las polizas del ramo combinado cuando la unidad es la soda para incliur el 0.01*/
			if _cod_ramo = '020' then
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

				let _debito  = _monto;
				let _credito = 0.00;
				let _renglon = _renglon + 1;

				INSERT INTO chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito,
				centro_costo,
				no_poliza
				)
				VALUES(
				a_no_requis,
				_renglon,
				_cuenta,
				_debito,
				0,
				_centro_costo,
				_no_poliza
				);
			end if

			-- Diferencia en la Multiplicacion por la separacion del impuesto

			if _impuesto <> _suma_impuesto then

				let _debito  = _impuesto - _suma_impuesto;
				let _credito = 0.00;
				
				update chqchcta
				   set debito    = debito  + _debito,
				       credito   = credito + _credito
				 where no_requis = a_no_requis
				   and renglon   = _renglon;

			end if

	    end If
		end foreach
		---------------------------------------------------------------------------------------
		
		-- Provision de Comision y Comision por Pagar (Auxiliar)

		if _tipo_produccion in (1, 2, 3) then
		
			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = _cod_lider;
			
			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if

			let _prima_suscrita = _prima_neta2 * _porc_partic_coas / 100;

			foreach
			 select	porc_comis_agt,
					porc_partic_agt,
					cod_agente
			   into	_porc_comis_agt,
					_porc_partic_agt,
					_cod_agente
			   from chqchpoa
			  where	no_requis    = a_no_requis
			    and no_documento = _no_documento
	
				select tipo_agente
				  into _tipo_agente
				  from agtagent
				 where cod_agente = _cod_agente;

				if _tipo_agente = "O" then -- Oficina
					continue foreach;
				end if

				if _porc_comis_agt = 0 THEN
					continue foreach;
				end if

				let _monto = _prima_suscrita * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);

				if _monto = 0.00 Then
					continue foreach;
				end if

				let _cod_auxiliar = "A" || _cod_agente[2,5]; -- En SAC no alcanza para poner los 5 digitos

				-- Provision de Comision

				Let _debito  = 0.00;
				Let _credito = 0.00;

				IF _monto >= 0 THEN
					LET _credito = _monto;
				ELSE
					LET _credito = _monto * -1;
				END IF

				let _cuenta  = sp_sis15('PPCOMXPCO', '01', _no_poliza); 
				let _renglon = _renglon + 1;

				INSERT INTO chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito,
				centro_costo,
				no_poliza
				)
				VALUES(
				a_no_requis,
				_renglon,
				_cuenta,
				_debito,
				_credito,
				_centro_costo,
				_no_poliza
				);

				-- Comisiones por Pagar Auxiliar

				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto >= 0 then
					Let _debito  = _monto;
				else
					Let _debito  = _monto * -1;
				end if

				let _cuenta  = sp_sis15('CPCXPAUX', '01', _no_poliza); 
				let _renglon = _renglon + 1;

				INSERT INTO chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito,
				centro_costo,
				no_poliza,
				cod_auxiliar
				)
				VALUES(
				a_no_requis,
				_renglon,
				_cuenta,
				_debito,
				_credito,
				_centro_costo,
				_no_poliza,
				_cod_auxiliar
				);

				insert into	chqctaux(
				no_requis,
				renglon,
				cuenta,
				cod_auxiliar,
				debito,
				credito,
				centro_costo
				)
				values(
				a_no_requis,
				_renglon,
				_cuenta,
				_cod_auxiliar,
				_debito,
				_credito,
				_centro_costo
				);

			end foreach
		end if		
	-- Cuenta del Banco

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo,
		no_poliza
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0,
		_prima_bruta,
		_centro_costo,
		_no_poliza
		);
	drop table tmp_dist_rea;
	end foreach
end 

return 0, "Actualizacion Exitosa ...";

end procedure
