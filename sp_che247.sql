-- Genera Cheque ACH -- Banisi
-- Creado    : 15/04/2011 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE sp_che247;
CREATE PROCEDURE sp_che247(a_origen char(1), a_pagado  smallint) 
RETURNING  char(5),					--cod_agente		
		   decimal(16,2),			--monto			
		   char(30),				--cedula			
		   char(1),					--tipo_cuenta		
		   char(18),				--cod_cuenta		
		   integer,					--ruta_numero		
		   char(10),				--no_requis		
		   integer,					--pagado			
		   integer,					--no_cheque		
		   char(7),					--periodo			
		   date,					--fecha_impresion
		   char(50),				--e_mail 			
		   char(100),				--a_nombre_de		
		   smallint,				--cnt			
		   smallint,				--ver			
		   decimal(16,2);			--monto_cta	

DEFINE 	_a_nombre_de		char(100);
DEFINE 	_e_mail 			char(50);
DEFINE 	_cedula			    char(30);
DEFINE 	_cod_cuenta		    char(18);
DEFINE 	_no_requis		    char(10);
DEFINE 	_no_requis2		    char(10);
DEFINE 	_periodo			char(7);
DEFINE 	_cod_agente		    char(5);
DEFINE  _numrecla           char(2);
DEFINE 	_tipo_cuenta		char(1);
DEFINE 	_monto_cta		    dec(16,2);
DEFINE 	_monto			    dec(16,2);
DEFINE  _monto_req          dec(16,2);
DEFINE 	_cnt				smallint;
DEFINE 	_ver				smallint;
DEFINE 	_ruta_numero		integer;
DEFINE 	_pagado			    integer;
DEFINE 	_no_cheque		    integer;
DEFINE 	_fecha_impresion	date;
DEFINE  _origen_orig     	char(1);
DEFINE  _transaccion    	char(10);
DEFINE  _cant               smallint;
  

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

CREATE TEMP TABLE tmp_cta(cod_cuenta char(18)) WITH NO LOG;

let _origen_orig = a_origen;

if a_origen = "B" then
	let a_origen = "3";
end if

FOREACH
	SELECT chqchmae.cod_agente,
		   chqchmae.monto,
		   cliclien.cedula,
		   cliclien.tipo_cuenta,
		   cliclien.cod_cuenta,
		   chqbanco.ruta_numero,
		   chqchmae.no_requis,
		   chqchmae.pagado,
		   chqchmae.no_cheque,
		   chqchmae.periodo,
		   chqchmae.fecha_impresion,
		   cliclien.e_mail,
		   chqchmae.a_nombre_de
	  INTO _cod_agente,
		   _monto,
		   _cedula,
		   _tipo_cuenta,
		   _cod_cuenta,
		   _ruta_numero,
		   _no_requis,
		   _pagado,
		   _no_cheque,
		   _periodo,
		   _fecha_impresion,
		   _e_mail,
		   _a_nombre_de
	  FROM chqchmae, cliclien, chqbanco
	 WHERE (cliclien.cod_cliente = chqchmae.cod_cliente)
	   and (chqbanco.cod_banco = '295')
	   and ((chqchmae.origen_cheque = a_origen)
	   AND (chqchmae.cod_banco = '295')
	   AND (chqchmae.cod_chequera = '045')
	   AND (chqchmae.tipo_requis = 'A')
	   AND (chqchmae.pagado = a_pagado)
	   AND (chqchmae.autorizado = 1 )
	   AND (chqchmae.en_firma = 2)
--	   AND (chqchmae.pre_autorizado = 1)
	   AND (chqchmae.aut_imp_tec = 1))
	 order by 5,2 Desc
	 
	let _cant = 0; 

	FOREACH
		SELECT numrecla
		  INTO _numrecla
		  FROM chqchrec
		 WHERE no_requis = _no_requis
		EXIT FOREACH;
	END FOREACH
	
	-- Buscando pago a subrogaciones
	let _cant = sp_rec315(_no_requis);	

	if _origen_orig = "Z" then
		if _numrecla[1,2] not in ('02','20','23') then
			continue foreach;
		end if
		if _cant <> 0 then
			continue foreach;
		end if
	elif _origen_orig = "S" then
		if _numrecla[1,2] not in ('02','20','23') then
			continue foreach;
		end if
		if _cant = 0 then
			continue foreach;
		end if
--	elif a_opc = 2 then
--		if _numrecla[1,2] <> '18' then
--			continue foreach;
--		end if
	end if

	let _cnt = 0;
	let _ver = 0;
	let _monto_cta = 0;
	let _monto_req = 0;

	select count(*)
	  into _cnt
	  from tmp_cta
	 where cod_cuenta = _cod_cuenta;

--let _cnt = 1; 

	if _cnt = 0 then
		FOREACH
			SELECT chqchmae.no_requis,
			       chqchmae.monto
			  INTO _no_requis2,
			       _monto_req
			  FROM chqchmae, cliclien
			 WHERE (cliclien.cod_cliente = chqchmae.cod_cliente )
			   and ((chqchmae.origen_cheque = a_origen )
			   AND (chqchmae.cod_banco = '295')
			   AND (chqchmae.cod_chequera = '045')
			   AND (chqchmae.tipo_requis = 'A' )
			   AND (chqchmae.pagado = a_pagado )
			   AND (chqchmae.autorizado = 1 )
			   AND (chqchmae.en_firma = 2) 
--			   AND (chqchmae.pre_autorizado = 1)
			   AND (chqchmae.aut_imp_tec = 1))
			   
			let _cant = 0;			   

			FOREACH
				SELECT numrecla
				  INTO _numrecla
				  FROM chqchrec
				 WHERE no_requis = _no_requis2
				EXIT FOREACH;
			END FOREACH

			-- Buscando pago a subrogaciones
			let _cant = sp_rec315(_no_requis2);

			if _origen_orig = "Z" then
				if _numrecla[1,2] not in ('02','20','23') then
					continue foreach;
				end if
				if _cant <> 0 then
					continue foreach;
				end if
			elif _origen_orig = "S" then
				if _numrecla[1,2] not in ('02','20','23') then
					continue foreach;
				end if
				if _cant = 0 then
					continue foreach;
				end if
				
		--	elif a_opc = 2 then
		--		if _numrecla[1,2] <> '18' then
		--			continue foreach;
		--		end if
			end if

			LET _monto_cta = _monto_cta + _monto_req;
		END FOREACH
	  

		INSERT INTO tmp_cta( cod_cuenta )
		VALUES ( _cod_cuenta );

		let _ver = 1;
	end if

--		  if _cnt = 1 then			 
--			 let _ver = 1;
--			 let _monto_cta = _monto;
--		  end if

	RETURN	_cod_agente,
			_monto,
			_cedula,
			_tipo_cuenta,
			_cod_cuenta,
			_ruta_numero,
			_no_requis,
			_pagado,
			_no_cheque,
			_periodo,
			_fecha_impresion,
			_e_mail,
			_a_nombre_de,
			_cnt,
			_ver,
			_monto_cta
			WITH RESUME;		      
END FOREACH;
DROP TABLE tmp_cta;
END PROCEDURE	  