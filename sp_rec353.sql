-- Procedimiento retorna si se puee hacer el pago a tercero del reclmo de Salud 018

-- Creado    : 19/05/2006 - Autor: Armando Moreno.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_rec353;

CREATE PROCEDURE sp_rec353(a_no_tranrec	char(10))
returning smallint,
          varchar(100);

define _existe		    integer;

SET ISOLATION TO DIRTY READ;

let _existe = 0;

--Return _existe, "";

select count(*)
  into _existe
  from rectrcob a, prdcober b
 where a.cod_cobertura = b.cod_cobertura
   and a.no_tranrec = a_no_tranrec
   and a.monto <> 0
   and b.paga_tercero_salud = 1;

if _existe is null then
	let _existe= 0;
end if

if _existe = 0 then
	Return _existe, "No se puede realizar el pago porque no se afecta la cobertura que lo permita";
else
	Return _existe, "";
end if

END PROCEDURE
