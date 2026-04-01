-- Preliminar de la Generacion de los Lotes de las Cuentas para Ach

-- Creado    : 03/09/2001 - Autor: Armando Moreno
-- Modificado: 26/12/2001 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob70;

create procedure "informix".sp_cob70(
a_compania		char(3),
a_sucursal		char(3),
a_periodo		char(1)
) returning char(17),	--cuenta
			char(100),	--cuentahabiente
			char(20),	--poliza
			date,		--vig ini
			date,		--vig fin
			dec(16,2),	--monto
			dec(16,2),	--saldo
			char(3),	--procesar
			char(50),	--cia
			char(1),	--tipo_cuenta
			char(50),	--corredor
			char(50),	--nombre banco
			char(1),	--modificado
			char(1),    --tiene_cargo
			char(1),    --modo ach 1= normal, 2= rechazos
			decimal(16,2);

define _no_cuenta        char(17); 
define _monto            dec(16,2);
define _no_documento     char(20); 
define _vigencia_inic    date;
define _vigencia_final   date;
define _nombre           char(100);
define _cod_pagador      char(10);
define _saldo            dec(16,2);
define _procesar         char(3);
define _periodo_cta      char(7);  
define _periodo_today    char(7);  
define v_compania_nombre char(50); 
define _cod_banco		 char(3);
define _nombre_banco     char(50);
define _cod_ramo         char(3);
define _ramo_sis		 smallint;
define _tarjeta_errada   smallint;
define _cod_formapag	 char(3);
define _tipo_forma       smallint;
define _cantidad         smallint;
define _estatus_poliza	 char(1);
define _tipo_cuenta		 char(1);
define _no_poliza		 char(10);
define _cod_agente		 char(10);
define _mensaje				char(50);
define _nombre_agente		char(50);
define _excepcion			smallint;
define _colectivo			smallint;
define _ruta_numero			smallint;			
define v_por_vencer      dec(16,2);
define v_exigible        dec(16,2);
define v_corriente       dec(16,2);
define v_monto_30        dec(16,2);
define v_monto_60        dec(16,2);
define v_monto_90        dec(16,2);
define v_saldo           dec(16,2);
define v_periodo         char(7);
define v_fecha			 date;				
define _modificado		 char(1);
define _estatus_ach		 char(1);
define _rechazada_si	 smallint;
define _rechazada_no	 smallint;
define _rechazada		 smallint;
define _fecha_hoy        date;
define _tiene,_periodo2  char(1);
define _fecha_hasta     date;
define _fecha_inicio    date;
define _cargo			dec(16,2);
define _rech			smallint;
define _saber,_cnt      integer;
define _periodo         char(1);
define _fecha_1_pago	date;
define _nueva_renov     char(1);
define _ult_pago        dec(16,2);
define _valor           smallint;

-- Nombre de la Compania
set isolation to dirty read;

let  v_compania_nombre = sp_sis01(a_compania); 

let v_fecha = today;
let _rechazada = 0;

if month(v_fecha) < 10 then
	let v_periodo = year(v_fecha) || '-0' || month(v_fecha);
else
	let v_periodo = year(v_fecha) || '-' || month(v_fecha);
end if 
let _fecha_hoy    = today;

--set debug file to "sp_cob70.trc"; 
--trace on;                                                                

--drop table tmp_cuenta;

create temp table tmp_cuenta(
	no_cuenta		char(17),
	nombre			char(100),
	no_documento	char(20),
	vigencia_inic	date,
	vigencia_final	date,
	monto			dec(16,2),
	saldo			dec(16,2),
	procesar		char(3),
	cod_banco		char(3),
	tipo_cuenta		char(1),
	modificado      char(1),
	tiene_cargo     char(1),
	primary key (no_cuenta, no_documento)
) with no log;

if month(today) < 10 then
	let _periodo_today = year(today) || '-0' || month(today);
else
	let _periodo_today = year(today) || '-' || month(today);
end if

select estatus_ach
  into _estatus_ach
  from parparam
 where cod_compania = a_compania;

if _estatus_ach = "1" then
	let _rechazada_si = 1;
	let _rechazada_no = 0;
else
	let _rechazada_si = 1;
	let _rechazada_no = 1;
end if

if _estatus_ach = "1" then	--proceso normal

	update cobcutas
	   set rechazada = 0
	 where periodo   = a_periodo;

	--**********************************************************
	--polizas con forma de pago ach y no tienen cuentas creadas
	foreach                 

	 select p.no_documento    
	   into	_no_documento  
	   from emipomae p, cobforpa f       
	  where	p.actualizado  = 1
	    and p.cod_formapag = f.cod_formapag
		and f.tipo_forma   = 4      --ach
	  group by p.no_documento 

		foreach
		 select cod_formapag,
				vigencia_inic,
				vigencia_final,
				cod_pagador,
				estatus_poliza
		   into	_cod_formapag,
				_vigencia_inic,
				_vigencia_final,
				_cod_pagador,
				_estatus_poliza
		   from	emipomae
		  where	no_documento = _no_documento
		    and actualizado  = 1
		  order by vigencia_final desc
			exit foreach;
		end foreach

		select tipo_forma
		  into _tipo_forma
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		if _tipo_forma <> 4 then  --4 es db-ach del 15 y del 30
			continue foreach;
		end if

		if _estatus_poliza = '2' or	   --cancelada
		   _estatus_poliza = '4' then  --anulada
			continue foreach;
		end if

		let _monto = null;

	   foreach	
		select monto
		  into _monto
		  from cobcutas
		 where no_documento = _no_documento
			exit foreach;
	   end foreach

		if _monto is null then
			call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
				returning   v_por_vencer,
							v_exigible,
							v_corriente,
							v_monto_30,
							v_monto_60,
							v_monto_90,
							_saldo;
		 	select nombre                      
			  into _nombre                     
		 	  from cliclien                    
		 	 where cod_cliente = _cod_pagador;

			insert into tmp_cuenta
			values(
			'',
			_nombre,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			0.00,
			_saldo,
			'006',
			'',
			'',
			'',
			''
			);
		end if
	end foreach

	--polizas que tienen cuenta y su forma de pago no es con ach
	let _colectivo = 0;

	foreach
	 select c.no_documento,
	        h.no_cuenta,
	        h.tipo_cuenta,
			h.cod_pagador,
			c.monto,
			h.cod_banco,
			c.colectivo
	   into	_no_documento,
	        _no_cuenta,
			_tipo_cuenta,
			_cod_pagador,
			_monto,
			_cod_banco,
			_colectivo
	   from cobcutas c, cobcuhab h
	  where	trim(c.no_cuenta) = trim(h.no_cuenta)
	  	and c.periodo in (a_periodo, "3")

		let _cod_formapag = null;

		if _colectivo is null then
			let _colectivo = 0;
		end if

		let _no_cuenta = trim(_no_cuenta);

		foreach
			select cod_formapag,
				   vigencia_inic,
				   vigencia_final
			  into _cod_formapag,
			  	   _vigencia_inic,
			  	   _vigencia_final
			  from emipomae
			 where no_documento = _no_documento
			   and actualizado  = 1
			 order by vigencia_final desc
			exit foreach;
		end foreach

		if _cod_formapag is null then
			continue foreach;
		end if

	  	select tipo_forma                
	  	  into _tipo_forma
	  	  from cobforpa                       
	  	 where cod_formapag = _cod_formapag;  

	 	select nombre                      
		  into _nombre                     
	 	  from cliclien
	 	 where cod_cliente = _cod_pagador;

		if _tipo_forma <> 4 then
			call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
				returning   v_por_vencer,
							v_exigible,
							v_corriente,
							v_monto_30,
							v_monto_60,
							v_monto_90,
							_saldo;

			if _colectivo = 0 then 
				begin
					on exception in(-239)
					end exception
					insert into tmp_cuenta
					values(
					_no_cuenta,
					_nombre,
					_no_documento,
					_vigencia_inic,
					_vigencia_final,
					_monto,
					_saldo,
					'007',
					_cod_banco,
					_tipo_cuenta,
					'',
					''
					);
				end
			else
				begin
					on exception in(-239)
					end exception
					insert into tmp_cuenta
					values(
					_no_cuenta,
					_nombre,
					_no_documento,
					_vigencia_inic,
					_vigencia_final,
					_monto,
					_saldo,
					'000',
					_cod_banco,
					_tipo_cuenta,
					'',
					''
					);
				end
			end if
		end if
	end foreach 

	-- Polizas que tienen banco y no tienen No. de ruta.

	foreach 

	 select c.no_documento,
	        h.no_cuenta,
	        h.tipo_cuenta,
			h.cod_pagador,
			c.monto,
			h.cod_banco
	   into	_no_documento,
	        _no_cuenta,
			_tipo_cuenta,
			_cod_pagador,
			_monto,
			_cod_banco
	   from cobcutas c, cobcuhab h
	  where	c.periodo in(a_periodo,"3")
	    and trim(c.no_cuenta) = trim(h.no_cuenta)

		let _no_cuenta = trim(_no_cuenta);

		foreach
		 select vigencia_inic,
				vigencia_final
		   into	_vigencia_inic,
				_vigencia_final
		   from	emipomae
		  where	no_documento = _no_documento
		    and actualizado  = 1
		  order by vigencia_final desc
			exit foreach;
		end foreach

		if _cod_banco is null then
			continue foreach;
		end if

		let _ruta_numero = null;

	 	 select ruta_numero
		   into	_ruta_numero
		   from chqbanco
		  where	cod_banco = _cod_banco;

	 	select nombre                      
		  into _nombre                     
	 	  from cliclien                    
	 	 where cod_cliente = _cod_pagador;

		if _ruta_numero is null or _ruta_numero = 0 then
			call sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
				returning   v_por_vencer,
							v_exigible,
							v_corriente,
							v_monto_30,
							v_monto_60,
							v_monto_90,
							_saldo;

			begin
			on exception in(-239)
			end exception
				insert into tmp_cuenta
				values(
				_no_cuenta,
				_nombre,
				_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_monto,
				_saldo,
				'010',
				_cod_banco,
				_tipo_cuenta,
				'',
				''
				);
			end
		end if
	end foreach 
end if

--***********************************
-- Procesa Todas las Cuentas para ACH
let _cargo = 0;

FOREACH
 SELECT h.no_cuenta,
		c.monto,
		c.cargo_especial,
		c.no_documento,
		h.cod_pagador,
		h.cod_banco,
        h.tipo_cuenta,
		c.rechazada,
		c.excepcion,
		c.modificado,
		c.periodo,
		c.periodo2,
		c.fecha_hasta,
		c.fecha_inicio
   INTO _no_cuenta,
		_monto,
		_cargo,
		_no_documento,
		_cod_pagador,
		_cod_banco,
		_tipo_cuenta,
		_rechazada,
		_excepcion,
		_modificado,
		_periodo,
		_periodo2,
		_fecha_hasta,
		_fecha_inicio
   FROM cobcutas c, cobcuhab h
  WHERE trim(c.no_cuenta) = trim(h.no_cuenta)
    AND c.periodo   in(a_periodo,"3")
	AND c.rechazada in (_rechazada_si, _rechazada_no)

	let _no_cuenta = trim(_no_cuenta);

	if _fecha_inicio is null then
		let _fecha_inicio = v_fecha;
	end if
	if a_periodo = _periodo then

		if _periodo2 is null then 		--Esto es para el cargo adicional.
			let _periodo2 = "0";
		end if
		let _tiene = "";
		if _fecha_hasta is not null then
			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then --ok
					let _tiene = "1";
					if _periodo = _periodo2 then   -- se debe sumar el cargo al monto
						let _monto = _monto + _cargo;
					end if
				end if
			end if
		end if
	else
		--Esto es para el cargo adicional.

		if _periodo2 is null then
			let _periodo2 = "0";
		end if
		let _tiene = "";
		if _fecha_hasta is not null then

			if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
				if _fecha_inicio <= _fecha_hoy then --ok
					let _tiene = "1";
					if a_periodo = _periodo2 then   -- se debe sumar el cargo al monto
						if _cargo > 0 then
							let _monto = _cargo;
						else
							continue foreach;
						end if
					else
						continue foreach;
					end if
				else
					continue foreach;
				end if
			else
				continue foreach;	
			end if
		else
			if _periodo = '3' then	  --Ambas quincenas
			else
				continue foreach;
			end if
		end if
	end if

	if _modificado is null then
		let _modificado = "";
	end if
	if _tiene is null then
		let _tiene = "";
	end if
	LET _vigencia_inic  = NULL;
	LET _vigencia_final = NULL;

	LET _no_poliza = sp_sis21(_no_documento);

	SELECT vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   estatus_poliza,
		   fecha_primer_pago,
		   nueva_renov
	  INTO _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza,
		   _fecha_1_pago,
		   _nueva_renov
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	FOREACH
	 SELECT	vigencia_inic,
			vigencia_final,
			cod_ramo,
			estatus_poliza,
			fecha_primer_pago,
		    nueva_renov
	   INTO	_vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_estatus_poliza,
		    _fecha_1_pago,
		    _nueva_renov
	   FROM	emipomae
	  WHERE	no_documento = _no_documento
	    AND actualizado  = 1
	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
	END FOREACH

	LET _saldo = NULL;

	CALL sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		RETURNING   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;

	SELECT ramo_sis
	  INTO _ramo_sis
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	if _monto <= 0 then
		let _excepcion = 1;
	end if

	IF _saldo IS NULL THEN
		LET _procesar = '009'; 	--POLIZAS ERRADAS
	ELIF _fecha_1_pago > today and _nueva_renov = "N" then
		LET _procesar = '004';
	ELIF _fecha_1_pago > today and _nueva_renov = "R" and v_exigible = 0 then
		LET _procesar = '004';
	ELIF _excepcion = 1 THEN
		LET _procesar = '040';	--EXCEPCIONES
	ELIF _saldo <= 0 THEN
		IF _estatus_poliza = '2' OR
		   _estatus_poliza = '4' THEN
			LET _procesar = '035';	  --POLIZAS CANCELADAS
		ELSE
			LET _procesar = '020';    --SALDOS NEGATIVOS
		END IF
    ELIF _monto > _saldo THEN	      --CARGO MAYOR AL SALDO
		   LET _procesar = '100';
		   LET _monto = _saldo;
	ELIF _rechazada = 1 THEN
		if _estatus_ach = "1" then	--PROCESO NORMAL
			LET _procesar = '003';	--CUENTA RECHAZADA
			update cobcuhab
			   set rechazada  = 0
			 where trim(no_cuenta) = _no_cuenta;
		else
			IF _saldo <= 0 THEN
				IF _estatus_poliza = '2' OR
				   _estatus_poliza = '4' THEN
					LET _procesar = '035';
				ELSE
					LET _procesar = '020';
				END IF
			ELSE
			   LET _procesar = '100';
			END IF
			if _monto > _saldo THEN
				LET _procesar = '100';
			    LET _monto = _saldo;
			end if
		end if
	ELSE
		LET _procesar = '100';
	END IF

	IF _procesar = '100' THEN
		CALL sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
			RETURNING   v_por_vencer,
						v_exigible,
						v_corriente,
						v_monto_30,
						v_monto_60,
						v_monto_90,
						_saldo;

		IF _monto < v_exigible THEN
			LET _procesar = '090';
			LET _saldo    = v_exigible;
		END IF

	END IF

 	SELECT nombre                      
	  INTO _nombre                     
 	  FROM cliclien                    
 	 WHERE cod_cliente = _cod_pagador;

	 SELECT count(*)
	   INTO	_cnt
	   FROM	cobcutas
	  WHERE	no_documento = _no_documento;

	IF _cnt > 1 then
		LET _procesar = '001';
        UPDATE tmp_cuenta
	       SET procesar        = _procesar
    	 WHERE trim(no_cuenta) = _no_cuenta
           AND no_documento    = _no_documento;
	END IF

	BEGIN
		ON EXCEPTION IN(-239)
	       UPDATE tmp_cuenta
	          SET modificado      = _modificado,
			      tiene_cargo     = _tiene
    	    WHERE trim(no_cuenta) = _no_cuenta
        	  AND no_documento    = _no_documento;

		END EXCEPTION
		INSERT INTO tmp_cuenta
		VALUES(
		_no_cuenta,
		_nombre,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_monto,
		_saldo,
		_procesar,
		_cod_banco,
		_tipo_cuenta,
		_modificado,
		_tiene
		);
	END   		   	
END FOREACH

--RECHAZADAS DE QUINCENA ANTERIOR, COLOCARLAS DENTRO DEL PROCESO NORMAL

if _estatus_ach = "1" then --proceso normal

	FOREACH

		select no_cuenta, cod_pagador, monto, no_documento
		  into _no_cuenta, _cod_pagador, _monto, _no_documento
		  from cobcutmp
		 where rechazado = 1

		let _no_cuenta = trim(_no_cuenta);

    let _procesar = '002';

	CALL sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
		RETURNING   v_por_vencer,
					v_exigible,
					v_corriente,
					v_monto_30,
					v_monto_60,
					v_monto_90,
					_saldo;

		 SELECT count(*)
		   INTO	_cnt
		   FROM cobcutas
		  WHERE	trim(no_cuenta) = _no_cuenta
		    AND no_documento    = _no_documento;

		if _cnt = 0 then
			delete from cobcutmp
			 where trim(no_cuenta) = _no_cuenta
			   and no_documento    = _no_documento;
		end if

		let _no_cuenta = trim(_no_cuenta);

		 SELECT tipo_cuenta,
				cod_banco
		   INTO	_tipo_cuenta,
				_cod_banco
		   FROM cobcuhab
		  WHERE	trim(no_cuenta) = _no_cuenta;

		FOREACH
		 SELECT vigencia_inic,
				vigencia_final,
				estatus_poliza
		   INTO	_vigencia_inic,
				_vigencia_final,
				_estatus_poliza
		   FROM	emipomae
		  WHERE	no_documento = _no_documento
		    AND actualizado  = 1
		  ORDER BY vigencia_final DESC
			EXIT FOREACH;
		END FOREACH

		IF _saldo <= 0 THEN
			IF _estatus_poliza = '2' OR
			   _estatus_poliza = '4' THEN
				LET _procesar = '035';
			ELSE
				LET _procesar = '020';
			END IF
		end if

	   	SELECT nombre                      
		  INTO _nombre                     
	 	  FROM cliclien                    
	 	 WHERE cod_cliente = _cod_pagador;

		BEGIN
			ON EXCEPTION IN(-239)
			END EXCEPTION
			INSERT INTO tmp_cuenta
			VALUES(
			_no_cuenta,				 
			_nombre,				 
			_no_documento,			 
			_vigencia_inic,			 
			_vigencia_final,		 
			_monto,					 
			0,						 
			_procesar,					 
			_cod_banco,				 
			_tipo_cuenta,			 	
			'',
			''						 
			);						 
		END
									 
		UPDATE cobcutas
		   SET rechazada       = 0
		 WHERE trim(no_cuenta) = _no_cuenta
		   AND no_documento    = _no_documento; 


	END FOREACH

end if

UPDATE cobcutas
   SET procesar = 0
 WHERE periodo  in(a_periodo,"3");

select count(*)
  into _saber
  from cobcutas
 where periodo   = a_periodo
   and rechazada = 1;

FOREACH
 SELECT no_cuenta,
		nombre,
		no_documento,
		vigencia_inic,
		vigencia_final,
		monto,
		saldo,
		procesar,
		cod_banco,
		tipo_cuenta,
		modificado,
		tiene_cargo
   INTO _no_cuenta,
		_nombre,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_monto,
		_saldo,
		_procesar,
		_cod_banco,
		_tipo_cuenta,
		_modificado,
		_tiene
   FROM tmp_cuenta
  ORDER BY procesar, nombre

	let _no_cuenta = trim(_no_cuenta);

	SELECT nombre
	  INTO _nombre_banco
	  FROM chqbanco
	 WHERE cod_banco = _cod_banco;

	if _estatus_ach = "2" then	--Modo Rechazadas
		if _saber = 0 then      --No hay poliza rechazada
		else
			select rechazada
			  into _rech
			  from cobcutas
			 where trim(no_cuenta) = _no_cuenta
			   and no_documento	   = _no_documento;

			if _rech = 1 then
					CALL sp_cob33(a_compania, a_sucursal, _no_documento, v_periodo, v_fecha)
					RETURNING   v_por_vencer,
								v_exigible,
								v_corriente,
								v_monto_30,
								v_monto_60,
								v_monto_90,
								_saldo;

					FOREACH
					 SELECT estatus_poliza
					   INTO	_estatus_poliza
					   FROM	emipomae
					  WHERE	no_documento = _no_documento
					    AND actualizado  = 1
					  ORDER BY vigencia_final DESC
						EXIT FOREACH;
					END FOREACH

					IF _saldo <= 0 THEN
						IF _estatus_poliza = '2' OR
						   _estatus_poliza = '4' THEN
							LET _procesar = '035';
						ELSE
							LET _procesar = '020';
						END IF
					end if
			else
				let _procesar = '040'; --Excepciones
			end if
		end if
	end if

	IF _procesar = '100' OR	   --cuentas normales
	   _procesar = '090' OR	   --cargo menor exigible
	   _procesar = '002' OR	   --rechazos quincena anterior y pasan a proceso normal
	   _procesar = '000' THEN  --colectivos
		UPDATE cobcutas
		   SET procesar     = 1
		 WHERE trim(no_cuenta) = _no_cuenta
		   AND no_documento    = _no_documento; 
	ELSE
		UPDATE cobcutas
		   SET procesar        = 0
		 WHERE trim(no_cuenta) = _no_cuenta
		   AND no_documento    = _no_documento; 
	END IF

	LET _no_poliza = sp_sis21(_no_documento);

	let _ult_pago = 0;
	call sp_sis395(_no_documento) returning _valor, _mensaje,_ult_pago;

	FOREACH
	 SELECT cod_agente
	   INTO _cod_agente
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	SELECT nombre
	  INTO _nombre_agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	RETURN _no_cuenta,
		   _nombre,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _monto,
		   _saldo,
		   _procesar,
		   v_compania_nombre,
		   _tipo_cuenta,
		   _nombre_agente,
		   _nombre_banco,
		   _modificado,
		   _tiene,
		   _estatus_ach,
		   _ult_pago
		   WITH RESUME;
END FOREACH

COMMIT WORK;
       	   	
DROP TABLE tmp_cuenta;

END PROCEDURE;
