--****************************************************************
-- Procedimiento que Realiza la Renovacion Automatica de la Poliza
--****************************************************************
-- se copio del sp_pro281()
-- Creado    : 28/04/2009 - Autor: Armando Moreno M.
-- Modificado: 28/04/2009 - Autor: Armando Moreno M.

drop procedure sp_pro320b;

create procedure "informix".sp_pro320b(
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
define _vig_ini        date;
define _cnt            smallint;
define ld_prima		   DEC(16,2);
define _suma_porc_prima DEC(16,2);

SET DEBUG FILE TO "sp_pro320b.trc"; 
trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET LOCK MODE TO WAIT;


let _serie = null;

--buscar ruta  *******************
select serie,cod_ramo,vigencia_inic
  into _serie,_cod_ramo,_vig_ini
  from emipomae
 where no_poliza = "568521";

select count(*)
  into _cnt
  from rearumae
 where serie    = _serie
   and cod_ramo = _cod_ramo
   and activo   = 1;

if _cnt > 1 then	--llevar a excepcion de sistema, ya que hay mas de una ruta.

	return 1;
		
end if

if _cnt = 0 then	--llevar a excepcion de sistema, ya que no hay ruta.

	return 2;

end if

select cod_ruta
  into _cod_ruta
  from rearumae
 where serie    = _serie
   and cod_ramo = _cod_ramo
   and activo   = 1
   and _vig_ini between vig_inic and vig_final;

let _suma_porc_prima = 0;

select sum(porc_partic_prima)
  into _suma_porc_prima
  from rearucon
 where cod_ruta = _cod_ruta;

if _suma_porc_prima = 0 then --Todos los Porcentajes en cero.

	return 3;

end if

foreach

  SELECT no_unidad
	INTO _no_unidad
    FROM emipouni
   WHERE no_poliza = "568521"

  foreach
		select cod_contrato,
		       orden,
			   porc_partic_suma,
			   porc_partic_prima
		  into _cod_contrato,
		       _orden,
			   _porc_suma,
			   _porc_prima
		  from rearucon
		 where cod_ruta = _cod_ruta
		   and porc_partic_suma <> 0
           and porc_partic_prima <> 0

		let _fronting  = 0;
		let _fronting2 = 0;

	    select tipo_contrato,
	           fronting
	      into _tipo_contrato,
		       _fronting
	      from reacomae
	     where cod_contrato = _cod_contrato;

	  foreach

		  select fronting
		    into _fronting2
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

	  end foreach
	  
	  foreach	   --Para sacar la cobertura de reaseguro

		Select Sum(e.prima_neta),
			   p.cod_cober_reas
		  Into ld_prima,
			   _cod_cober_reas
		  From emipocob e, prdcober p
		 Where e.no_poliza     = "568521"
		   And e.no_unidad     = _no_unidad
		   And e.cod_cobertura = p.cod_cobertura
		 Group By p.cod_cober_reas
	    	

		  Insert Into emifacon(no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_ruta,porc_partic_prima,porc_partic_suma,suma_asegurada,prima)
		  Values (v_poliza_nuevo, "00000",_no_unidad,_cod_cober_reas,_orden,_cod_contrato,_cod_ruta,_porc_prima,_porc_suma,0.00, 0.00);

	  end foreach

  end foreach

end foreach


RETURN 0;
END

end procedure;