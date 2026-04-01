--****************************************************************
-- Procedimiento que Realiza la Renovacion Automatica de la Poliza
--****************************************************************
-- se copio del sp_pro281()
-- Creado    : 28/04/2009 - Autor: Armando Moreno M.
-- Modificado: 28/04/2009 - Autor: Armando Moreno M.

--drop procedure sp_pro320cc;

create procedure "informix".sp_pro320cc(
v_usuario      char(8),
v_poliza       char(10),
v_poliza_nuevo char(10)) RETURNING INTEGER;

--- Actualizacion de Polizas

DEFINE r_anos          smallint;
DEFINE _porc_depre     DEC(5,2);
DEFINE _porc_depre_uni DEC(5,2);
DEFINE _porc_depre_pol DEC(5,2);
DEFINE _no_unidad      CHAR(5); 
DEFINE _cod_cobertura  CHAR(5); 
DEFINE _cod_producto   CHAR(5); 
DEFINE _valor_asignar  CHAR(1); 
DEFINE _cant_unidades  INTEGER; 
DEFINE _suma_asegurada INTEGER;
DEFINE _no_motor       CHAR(30);
DEFINE _suma_decimal   DEC(16,2);
DEFINE _suma_difer	   DEC(16,2);
DEFINE _vigencia_final DATE;
DEFINE li_dia		   SMALLINT;
DEFINE li_mes		   SMALLINT;
DEFINE li_ano		   SMALLINT;
DEFINE ld_fecha_1_pago DATE;
DEFINE li_no_pagos	   SMALLINT;
DEFINE ls_cod_perpago  CHAR(3);
DEFINE li_meses		   SMALLINT;
define _saldo_unidad   smallint;
define _porc_com       DEC(5,2);
define _cod_agt        char(5);
define _cod_rammo      char(3);
define _cod_ramo       char(3);
define _ramo_sis       smallint;
define _nounidad       char(5);
define _valor          integer;
define _error          integer;
define _serie          integer;
define _cod_ruta       char(5);
define _orden          integer;
define _cod_contrato   char(5);
define _porc_prima     DEC(10,4);
define _porc_suma      DEC(10,4);
define _cod_cober_reas char(3);
define _tipo_contrato  char(1);
DEFINE _suma           DEC(16,2);
define _no_cambio      smallint;
define _cod_prod       char(5);
define _r_anos         smallint;
define _cod_subramo    char(3);
define _tipo_agente    char(1);
define _aplica_imp     smallint;
define _cod_impuesto   char(3);
define _cod_origen     char(3);
define _canti          smallint;
define _cod_cont_fac   char(5);
define _fronting       smallint;
define _fronting2	   smallint;
define _vig_ini		   date;
define _cod_grupo      char(5);
define _suma_prb       dec(16,2);

--SET DEBUG FILE TO "sp_pro320c.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET LOCK MODE TO WAIT;


FOREACH

	 Select no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima
	   Into _no_unidad,
	        _cod_cober_reas,
			_orden,
			_cod_contrato,
			_porc_suma,
			_porc_prima
	   From emireaco
	  Where no_poliza = v_poliza
	    and no_cambio = 0

		let _fronting  = 0;
		let _fronting2 = 0;

	  select tipo_contrato,
	         fronting
	    into _tipo_contrato,
		     _fronting
	    from reacomae
	   where cod_contrato = _cod_contrato;

	 { foreach
			select cod_contrato
			  into _cod_contrato2
			  from rearucon
			 where cod_ruta = _cod_ruta}

		 foreach
			  select cod_contrato
			    into _cod_contrato
				from reacomae
			   where tipo_contrato = _tipo_contrato
			     and serie         = _serie
				 and fronting      = _fronting

			  exit foreach;

		 end foreach

--	  end foreach

{	  foreach

		  select cod_contrato,
		         fronting
		    into _cod_contrato,
			     _fronting2
			from reacomae
		   where tipo_contrato = _tipo_contrato
		     and serie         = _serie

		  if _fronting = 1 then
		  	if _fronting2 = 1 then
			else
				continue foreach;
			end if
		  else
		  	if _fronting2 = 0 then
			else
				continue foreach;
			end if
		  end if

		  exit foreach;

	  end foreach  	}

	Insert Into emifacon(no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_ruta,porc_partic_prima,porc_partic_suma,suma_asegurada,prima)
	Values (v_poliza_nuevo, "00000",_no_unidad,_cod_cober_reas,_orden,_cod_contrato,'00430',_porc_prima,_porc_suma,0.00, 0.00);

END FOREACH

	foreach

		select no_unidad,
		       suma_asegurada
		  into _no_unidad,
		       _suma_asegurada
		  from emipouni
		 where no_poliza = v_poliza_nuevo

	    call sp_pro323(v_poliza_nuevo,_no_unidad,_suma_asegurada,'001') returning _valor;
		if _valor <> 0 then
			return _valor;
		end if

	    call sp_proe02(v_poliza_nuevo,_no_unidad,'001') returning _valor;
		if _valor <> 0 then
			return _valor;
		end if

	end foreach

foreach
  SELECT no_unidad,
		 suma_asegurada
	INTO _no_unidad,
		 _suma
    FROM emipouni
   WHERE no_poliza = v_poliza_nuevo

end foreach

call sp_proe03(v_poliza_nuevo,'001') returning _valor;

RETURN _valor;
END

end procedure;