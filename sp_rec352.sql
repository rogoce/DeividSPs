-- Procedimiento retorna si se puee hacer el pago a tercero del reclmo de Salud 018

-- Creado    : 19/05/2006 - Autor: Armando Moreno.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_rec352;

CREATE PROCEDURE "informix".sp_rec352(a_no_reclamo	char(10))
returning smallint;

define _existe		    integer;

SET ISOLATION TO DIRTY READ;

let _existe = 0;

--Return _existe;

select count(*)
  into _existe
  from recrccob a, prdcober b
 where a.cod_cobertura = b.cod_cobertura
   and a.no_reclamo = a_no_reclamo
   and b.paga_tercero_salud = 1;

if _existe is null then
	let _existe= 0;
end if

Return _existe;

END PROCEDURE
