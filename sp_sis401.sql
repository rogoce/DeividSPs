--****************************************************************
-- Procedimiento que crea el reaseguro para una renovacion manual especial
--****************************************************************

-- Creado    : 12/12/2012 - Autor: Armando Moreno M.
-- Modificado: 12/12/2012 - Autor: Armando Moreno M.

drop procedure sp_sis401;

create procedure "informix".sp_sis401(
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
define _cnt            smallint;
define _vig_fin        date;
define _no_documento   char(20);
define _mes            smallint;
define _anno           smallint;


--SET DEBUG FILE TO "sp_pro320c.trc"; 
--trace on;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET LOCK MODE TO WAIT;


--buscar ruta
select cod_ramo,vigencia_inic,no_documento
  into _cod_ramo,_vig_ini,_no_documento
  from emipomae
 where no_poliza = v_poliza_nuevo;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

select count(*)
  into _cnt
  from rearumae
 where cod_ramo = _cod_ramo
   and activo   = 1
   and _vig_ini between vig_inic and vig_final;

if _cnt = 0 then
	return 2;
end if

foreach

	select cod_ruta,serie
	  into _cod_ruta,_serie
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and activo   = 1
 	   and _vig_ini between vig_inic and vig_final

	exit foreach;

end foreach

let _cod_cober_reas = '015';

if _no_documento = '1610-00462-01' then --poliza del MINSA, no lleva impuesto.

	delete from emipolim
	where no_poliza = v_poliza_nuevo;

end if

FOREACH

	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = v_poliza_nuevo

	foreach
			select cod_contrato,
			       porc_partic_prima,
				   porc_partic_suma,
				   orden
			  into _cod_contrato,
			       _porc_prima,
				   _porc_suma,
				   _orden
			  from rearucon
			 where cod_ruta = _cod_ruta
		       and porc_partic_prima <> 0
			   and porc_partic_suma <> 0


		Insert Into emifacon(no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_ruta,porc_partic_prima,porc_partic_suma,suma_asegurada,prima)
		Values (v_poliza_nuevo, "00000",_no_unidad,_cod_cober_reas,_orden,_cod_contrato,_cod_ruta,_porc_prima,_porc_suma,0.00, 0.00);

	end foreach

END FOREACH

if _ramo_sis <> 1 then
	foreach

		select no_unidad,
		       suma_asegurada
		  into _no_unidad,
		       _suma_asegurada
		  from emipouni
		 where no_poliza = v_poliza_nuevo

	    call sp_pro323(v_poliza_nuevo,_no_unidad,_suma_asegurada,'001') returning _valor; --actualiza emifacon
		if _valor <> 0 then
			return _valor;
		end if

	    call sp_proe02(v_poliza_nuevo,_no_unidad,'001') returning _valor;  --actualiza la emipouni (unidades)
		if _valor <> 0 then
			return _valor;
		end if

	end foreach
end if

call sp_proe03(v_poliza_nuevo,'001') returning _valor;	 --actualiza emipomae

RETURN _valor;
END

end procedure;