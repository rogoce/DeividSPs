-- Procedimiento que trae las polizas para el cte. seleccionado.

-- Creado    : 7/04/2003 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob103;

create procedure sp_cob103(
a_compania 	   CHAR(3),
a_agencia      CHAR(3),
a_cod_cliente  CHAR(10),
a_dia          INT
)
returning char(20),  --_no_documento
       	  date,		 --vig ini
       	  date,		 --vig fin
	      char(3),	 --cod_ramo
	      smallint,  --estatus poliza
	      char(7),	 --periodo
	      char(3),	 --cod subramo
	      char(1),	 --gestion
		  char(50),  --ramo nombre
		  char(50),	 --subramo nombre
		  DEC(16,2), --apagar
		  DEC(16,2), --saldo
		  DEC(16,2), --exigible
		  DEC(16,2), --corriente 
		  DEC(16,2), --monto30
		  DEC(16,2), --monto60
		  DEC(16,2), --monto90
		  char(10),	 --no_poliza
		  DEC(16,2), --por vencer
		  char(100), --asegurado
		  smallint,  --seleccionar
		  char(50),
  		  DEC(16,2), --prima orig
		  char(50),  --agente
		  DEC(16,2), --exigible2
		  integer,   --ramosis
		  char(50);  --no_renov

define _no_poliza		char(10);
define _vigencia_inic 	date;
define _vigencia_final 	date;
define _no_documento    char(20);
define _cod_ramo		char(3);
define _cod_subramo	    char(3);
define _estatus_poliza  smallint;
define _ramo_sis		smallint;
define _gestion			char(1);
define _ramo_nom		char(50);
define _periodo,_peri	char(7);
define _subramo_nom		char(50);
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);
DEFINE v_exigible		DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_apagar			DEC(16,2);
DEFINE v_saldo			DEC(16,2);
DEFINE v_por_vencer		DEC(16,2);
define _prima_orig		DEC(16,2);
define _asegurado       char(100);
DEFINE _cod_contratante CHAR(10);
define _seleccionar 	smallint;
DEFINE _cod_acreedor    CHAR(5);
DEFINE _nombre_acreedor	CHAR(50);
DEFINE _no_unidad		CHAR(5);
define _nombre_agente	CHAR(50);
DEFINE _porcentaje      DEC(16,2);
define _cod_agente		CHAR(5);
--define _tipo_mov		CHAR(1);
define _no_pol_rec		CHAR(10);
define _no_reclamo		CHAR(10);
DEFINE _n_acreedor		  CHAR(50);
define _nn_acree          char(50);
define _nn                integer;
define _cade              char(1);
DEFINE _leasing           SMALLINT;
define _cod_no_renov	char(3);
define _no_renov		char(50);


set isolation to dirty read;

--SET DEBUG FILE TO "sp_cob33.trc";
--TRACE ON ;

--Armar varibale que contiene el periodo(aaaa-mm)
IF  MONTH(TODAY) < 10 THEN
	LET _mes_char = '0'||MONTH(TODAY);
ELSE
	LET _mes_char = MONTH(TODAY);
END IF

LET _ano_char   = YEAR(TODAY);
LET _periodo    = _ano_char || "-" || _mes_char;
let _prima_orig = 0;
let v_apagar    = 0.00;
LET v_por_vencer = 0;
LET v_exigible   = 0;
let v_corriente  = 0;
let v_monto_30   = 0;
LET v_monto_60   = 0;
LET v_monto_90	 = 0;
let v_saldo		 = 0;
let _cod_no_renov = '';
--let _no_poliza = "";
--let _nombre_agente = "";
--let _nombre_acreedor = "";
let _seleccionar = 0;

foreach
 select	no_documento,
		--tipo_mov,
		a_pagar
   into	_no_documento,
		--_tipo_mov,
		v_apagar
   from	caspoliza
  where	cod_cliente = a_cod_cliente

{ select	distinct no_documento
   into	_no_documento
   from	emipomae
  where	cod_pagador = a_cod_cliente}

-- if _tipo_mov <> "R" then
	 LET _no_poliza = sp_sis21(_no_documento); --trae ult. vigencia de la poliza.

	 select vigencia_inic,
			vigencia_final,
			cod_ramo,
			estatus_poliza,
			periodo,
			cod_subramo,
			gestion,
			cod_contratante,
			prima_bruta,
			leasing,
			cod_no_renov
	   into	_vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_estatus_poliza,
			_peri,
			_cod_subramo,
			_gestion,
			_cod_contratante,
			_prima_orig,
			_leasing,
			_cod_no_renov
	   from	emipomae
	  where	no_poliza = _no_poliza;

	

	-- Selecciona el Primer Acreedor de la Poliza
		LET _nombre_acreedor = '... SIN ACREEDOR ...';
		LET _cod_acreedor    = '';

  {		FOREACH
		 SELECT	cod_acreedor,
				no_unidad
		   INTO	_cod_acreedor,
				_no_unidad
		   FROM emipoacr
		  WHERE	no_poliza = _no_poliza
		  ORDER BY no_unidad

			IF _cod_acreedor IS NOT NULL THEN
				SELECT nombre
				  INTO _nombre_acreedor
				  FROM emiacre
				 WHERE cod_acreedor = _cod_acreedor;

				EXIT FOREACH;
			END IF
		END FOREACH
 }

		let _no_renov = '';

		select nombre
		  into _no_renov
		  from eminoren
		 where cod_no_renov = _cod_no_renov;

        let _n_acreedor = '';

		select count(distinct n.nombre)
		  into _nn
		  from  emipoacr e, emiacre n
		 where e.cod_acreedor = n.cod_acreedor
		   and e.no_poliza = _no_poliza;

		if _nn > 1 then
			let _cade = ", ";
		else
			let _cade = "";
		end if

		foreach
			select distinct n.nombre
			  into _nn_acree
			  from  emipoacr e, emiacre n
			 where e.cod_acreedor = n.cod_acreedor
			   and e.no_poliza = _no_poliza

			let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

		end foreach

		if _nn > 1 then
		   let _n_acreedor[1,1] = "";
		end if


		foreach
			select distinct n.nombre
			  into _nn_acree
			  from  emipoacr e, emiacre n
			 where e.cod_acreedor = n.cod_acreedor
			   and e.no_poliza = _no_poliza

			let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

		end foreach

		if _nn > 1 then
		   let _n_acreedor[1,1] = "";
		end if

	    if _n_acreedor is null or trim(_n_acreedor) = "" then
			let _n_acreedor = '... SIN ACREEDOR ...';
		end if

	    if _leasing = 1 then   -- Cuando la poliza es leasing el acreedor se busca en la unidad Caso 06731
			
				select count(distinct n.nombre)
				  into _nn
				  from  emipouni e, cliclien n
				 where e.cod_asegurado = n.cod_cliente
				   and e.no_poliza = _no_poliza;

			if _nn > 1 then
				if _n_acreedor = '... SIN ACREEDOR ...' then
					let _n_acreedor = '';
				end if
                
				let _cade = ", ";
			else
				let _cade = "";
			end if

			foreach
				select distinct n.nombre
				  into _nn_acree
				  from  emipouni e, cliclien n
				 where e.cod_asegurado = n.cod_cliente
				   and e.no_poliza = _no_poliza

				let _n_acreedor = trim(_n_acreedor) || _cade || trim(_nn_acree);

			end foreach

			if _nn > 1 then
			   let _n_acreedor[1,1] = "";
			end if
		end if


		let _cod_agente = null;

		FOREACH 
			 SELECT	cod_agente,
					porc_partic_agt
			   INTO	_cod_agente,
					_porcentaje
			   FROM emipoagt
			  WHERE	no_poliza = _no_poliza
			  ORDER BY porc_partic_agt desc

				EXIT FOREACH;
		END FOREACH

		SELECT nombre
		  INTO _nombre_agente
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		If _gestion Is Null Then
			Let _gestion = "P";
		End If

		select nombre,
			   ramo_sis
		  into _ramo_nom,
			   _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_contratante;

		select nombre
		  into _subramo_nom
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;

		CALL sp_cob33(
			 a_compania,
			 a_agencia,
			 _no_documento,
			 _periodo,
			 today
			 ) RETURNING v_por_vencer,
					     v_exigible,  
					     v_corriente, 
					     v_monto_30,  
					     v_monto_60,  
					     v_monto_90,
					     v_saldo
					     ;
		let v_apagar = v_exigible;
		let _seleccionar = 0;

		if _ramo_sis = 5 then --salud
			CALL sp_cob33c(
				 a_compania,
				 a_agencia,
				 _no_documento,
				 _periodo,
				 today
				 ) RETURNING v_por_vencer,
						     v_exigible,  
						     v_corriente, 
						     v_monto_30,  
						     v_monto_60,  
						     v_monto_90,
						     v_saldo
						     ;

			let v_apagar = v_exigible;

			if v_monto_30 > 0 or v_monto_60 > 0 or v_monto_90 > 0 then
				let _seleccionar = 1;
			end if
		elif _ramo_sis = 6 then --vida individual
			if v_monto_60 > 0 then
				let _seleccionar = 1;				
			end if
		else
			if v_monto_90 > 0 then
				let _seleccionar = 1;
			end if
		end if
-- else
	{select nombre
	  into _asegurado
	  from cliclien
	 where cod_cliente = a_cod_cliente;

	select no_reclamo
	  into _no_reclamo
	  from recrecup
	 where numrecla = _no_documento;

	select no_poliza
	  into _no_pol_rec
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select  vigencia_inic,
			vigencia_final,
			cod_ramo,
			estatus_poliza,
			periodo,
			cod_subramo,
			gestion
	   into	_vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_estatus_poliza,
			_peri,
			_cod_subramo,
			_gestion
	   from	emipomae
	  where	no_poliza = _no_pol_rec;

		select nombre,
			   ramo_sis
		  into _ramo_nom,
			   _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		select nombre
		  into _subramo_nom
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;

 end if}
	return _no_documento,
	       _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza,
		   _peri,
		   _cod_subramo,
		   _gestion,
		   _ramo_nom,
		   _subramo_nom,
		   v_apagar,
		   v_saldo,
		   v_exigible,  
		   v_corriente, 
		   v_monto_30,  
		   v_monto_60,  
		   v_monto_90,
		   _no_poliza,
		   v_por_vencer,
		   _asegurado,
		   _seleccionar,
		   trim(_n_acreedor), --_nombre_acreedor,
		   _prima_orig,
		   _nombre_agente,
		   v_exigible,
		   _ramo_sis,
		   _no_renov
		   with resume;
end foreach
end procedure