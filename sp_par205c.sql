-- Procedure que genere el registro contable de las comisiones

-- Creado    : 15/03/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_che06 - DEIVID, S.A.

--drop procedure sp_par205c;

create procedure "informix".sp_par205c(a_no_requis char(10), a_fecha date)
returning integer,
          char(50);

define _cod_agente			char(10);
define _tipo_agente			char(1);
define _tipo_requis			char(1);
define _renglon				smallint;
define _no_poliza			char(10);
define _porc_partic_coas	decimal(7,4);
define _cod_coasegur 		char(3);
define _cod_lider	 		char(3);
define _cod_auxiliar 		char(5);
define _cod_ramo			char(3);
define _cod_subramo			char(3);

define _comision			dec(16,2);
define _monto				dec(16,2);
define _debito				dec(16,2);
define _credito				dec(16,2);
define _cuenta				char(25);
define _monto_ajuste		dec(16,2);
define _monto_comision		dec(16,2);

define _monto_banco			dec(16,2);
define _cod_banco			char(3);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _pagado              smallint;
define _no_requis           char(10);

--set debug file to "sp_par205.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select cod_agente,
       tipo_requis,
	   monto,
	   cod_banco,
	   pagado
  into _cod_agente,
       _tipo_requis,
	   _monto_banco,
	   _cod_banco,
	   _pagado
  from chqchmae
 where no_requis = a_no_requis;

select tipo_agente
  into _tipo_agente
  from agtagent
 where cod_agente = _cod_agente;

SELECT par_ase_lider
  INTO _cod_lider
  FROM parparam
 WHERE cod_compania = "001";

-- Comisiones por Pagar Auxiliar

delete from chqctaux where no_requis = a_no_requis;
delete from chqchcta where no_requis = a_no_requis;

if _tipo_agente = "A" THEN -- Agentes Normales

	let _monto_ajuste   = 0.00;
	let _monto_comision = 0.00;

 -- Buscando en chqcomis por el numero de requis

	foreach
	 select no_poliza,
	        comision
	   into _no_poliza,
	        _comision
	   from chqcomis
	  where no_requis = a_no_requis
	    and fecha_desde >= a_fecha
--        and fecha_genera >= '03/07/2006'
    
		select porc_partic_coas
		  into _porc_partic_coas
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_lider;
			
		if _porc_partic_coas is null then
			let _porc_partic_coas = 100;
		end if

		let _monto = _comision * _porc_partic_coas / 100;
		
		let _monto_ajuste   = _monto_ajuste   + _monto;
		let _monto_comision = _monto_comision + _comision;
		 
		-- Comision por Pagar

		let _debito  = 0.00;
		let _credito = 0.00;

		if _monto > 0 then
			let _debito  = _monto;
		else
			let _credito = _monto * -1;
		end if

		LET _cuenta = sp_sis15('CPCXPAUX', '03', _cod_agente);

		let _cod_auxiliar = sp_sis89(2, _cod_agente);
		call sp_par206(a_no_requis, _cuenta, _cod_auxiliar, _debito, _credito) returning _error, _error_desc;
		
		if _error <> 0 then 
			return _error, _error_desc;
		end if

		-- Coaseguro por Pagar

	   foreach	
		select cod_coasegur,
		       porc_partic_coas
		  into _cod_coasegur,
		       _porc_partic_coas
		  from emicoama
		 where no_poliza    =  _no_poliza
    	   and cod_coasegur <> _cod_lider

			let _debito  = 0.00;
			let _credito = 0.00;

			let _monto = _comision * _porc_partic_coas / 100;
			let _monto_ajuste = _monto_ajuste + _monto;

			if _monto > 0 then
				let _debito  = _monto;
			else
				let _credito = _monto * -1;
			end if

			Let _cuenta = sp_sis15("PPCOASXP", '01', _no_poliza);   

			let _cod_auxiliar = sp_sis89(1, _cod_coasegur);
			call sp_par206(a_no_requis, _cuenta, _cod_auxiliar, _debito, _credito) returning _error, _error_desc;
			
			if _error <> 0 then 
				return _error, _error_desc;
			end if

		end foreach

	end foreach

 -- Buscando en chqcomis anuladas y que aun no esta corregido
	If _tipo_requis <> "A" Then
		foreach
		 select no_poliza,
		        comision
		   into _no_poliza,
		        _comision
		   from chqcomis a, chqchmae b
		  where a.no_requis = b.no_requis
		    and a.cod_agente = _cod_agente
		    and a.no_requis <> a_no_requis
			and b.anulado = 1
			and a.no_requis is not null
		    
	--        and fecha_genera >= '03/07/2006'
	    
			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = _cod_lider;
				
			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if

			let _monto = _comision * _porc_partic_coas / 100;
			
			let _monto_ajuste   = _monto_ajuste   + _monto;
			let _monto_comision = _monto_comision + _comision;
			 
			-- Comision por Pagar

			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0 then
				let _debito  = _monto;
			else
				let _credito = _monto * -1;
			end if

			LET _cuenta = sp_sis15('CPCXPAUX', '03', _cod_agente);

			let _cod_auxiliar = sp_sis89(2, _cod_agente);
			call sp_par206(a_no_requis, _cuenta, _cod_auxiliar, _debito, _credito) returning _error, _error_desc;
			
			if _error <> 0 then 
				return _error, _error_desc;
			end if

			-- Coaseguro por Pagar

		   foreach	
			select cod_coasegur,
			       porc_partic_coas
			  into _cod_coasegur,
			       _porc_partic_coas
			  from emicoama
			 where no_poliza    =  _no_poliza
	    	   and cod_coasegur <> _cod_lider

				let _debito  = 0.00;
				let _credito = 0.00;

				let _monto = _comision * _porc_partic_coas / 100;
				let _monto_ajuste = _monto_ajuste + _monto;

				if _monto > 0 then
					let _debito  = _monto;
				else
					let _credito = _monto * -1;
				end if

				Let _cuenta = sp_sis15("PPCOASXP", '01', _no_poliza);   

				let _cod_auxiliar = sp_sis89(1, _cod_coasegur);
				call sp_par206(a_no_requis, _cuenta, _cod_auxiliar, _debito, _credito) returning _error, _error_desc;
				
				if _error <> 0 then 
					return _error, _error_desc;
				end if

			end foreach

		end foreach


	 -- Buscando en chqcomis requis que estan en nulo

		foreach
		 select no_poliza,
		        comision
		   into _no_poliza,
		        _comision
		   from chqcomis a
		  where a.cod_agente = _cod_agente
			and a.no_requis is null
		    
	--        and fecha_genera >= '03/07/2006'
	    
			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = _cod_lider;
				
			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if

			let _monto = _comision * _porc_partic_coas / 100;
			
			let _monto_ajuste   = _monto_ajuste   + _monto;
			let _monto_comision = _monto_comision + _comision;
			 
			-- Comision por Pagar

			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0 then
				let _debito  = _monto;
			else
				let _credito = _monto * -1;
			end if

			LET _cuenta = sp_sis15('CPCXPAUX', '03', _cod_agente);

			let _cod_auxiliar = sp_sis89(2, _cod_agente);
			call sp_par206(a_no_requis, _cuenta, _cod_auxiliar, _debito, _credito) returning _error, _error_desc;
			
			if _error <> 0 then 
				return _error, _error_desc;
			end if

			-- Coaseguro por Pagar

		   foreach	
			select cod_coasegur,
			       porc_partic_coas
			  into _cod_coasegur,
			       _porc_partic_coas
			  from emicoama
			 where no_poliza    =  _no_poliza
	    	   and cod_coasegur <> _cod_lider

				let _debito  = 0.00;
				let _credito = 0.00;

				let _monto = _comision * _porc_partic_coas / 100;
				let _monto_ajuste = _monto_ajuste + _monto;

				if _monto > 0 then
					let _debito  = _monto;
				else
					let _credito = _monto * -1;
				end if

				Let _cuenta = sp_sis15("PPCOASXP", '01', _no_poliza);   

				let _cod_auxiliar = sp_sis89(1, _cod_coasegur);
				call sp_par206(a_no_requis, _cuenta, _cod_auxiliar, _debito, _credito) returning _error, _error_desc;
				
				if _error <> 0 then 
					return _error, _error_desc;
				end if

			end foreach

		end foreach
	end if
 ----------------------------------------
	let _monto = _monto_comision - _monto_ajuste;

	if _monto <> 0.00 then

		let _debito  = _monto;
		let _credito = 0.00;

		LET _cuenta = sp_sis15('CPCXPAUX', '03', _cod_agente);

		let _cod_auxiliar = sp_sis89(2, _cod_agente);
		call sp_par206(a_no_requis, _cuenta, _cod_auxiliar, _debito, _credito) returning _error, _error_desc;

		if _error <> 0 then 
			return _error, _error_desc;
		end if

	end if

    foreach
		 select a.no_requis	   
		   into _no_requis
		   from chqcomis a, chqchmae b
		  where a.no_requis = b.no_requis
		    and a.cod_agente = _cod_agente
		    and a.no_requis <> a_no_requis
			and b.anulado = 1
			and a.no_requis is not null

		 update chqcomis 
		    set no_requis = a_no_requis
		  where cod_agente = _cod_agente
		    and no_requis  = _no_requis;

	 end foreach

	 update chqcomis 
	    set no_requis = a_no_requis
	  where cod_agente = _cod_agente
		and no_requis is null;
   
elif _tipo_agente = "E" THEN -- Agentes Especiales

	let _renglon = 0;

	foreach
	 select monto,
			cod_ramo
	   into _monto,
			_cod_ramo
	   from chqchagt
	  where no_requis = a_no_requis

		foreach
		 select cod_subramo
		   into _cod_subramo
		   from prdsubra
		  where cod_ramo = _cod_ramo
			exit foreach;
		end foreach

		-- Registros Contables de Honorarios por Pagar

		let _renglon = _renglon + 1 ;
		LET _cuenta  = sp_sis15('PPGHONXPCO', "04", "001", _cod_ramo, _cod_subramo);

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_monto,
		0
		);

	end foreach

end if

-- Registros Contables del Banco

-- Cuando es cheque la cuenta de banco se crea al imprimir los cheques en autorizacion

IF _tipo_requis <> "C" OR (_tipo_requis = "C" AND _pagado = 1) THEN		

	SELECT MAX(renglon)
	  INTO _renglon	
	  FROM chqchcta
	 WHERE no_requis = a_no_requis;

	IF _renglon IS NULL THEN
		LET _renglon = 0;
	END IF

	LET _renglon = _renglon + 1;

	LET _cuenta = sp_sis15('BACHEBL', '02', _cod_banco); -- Chequera Bancos Locales

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito
	)
	VALUES(
	a_no_requis,
	_renglon,
	_cuenta,
	0,
	_monto_banco
	);	  

END IF

end

return 0, "Actualizacion Exitosa";

end procedure