-- Procedimiento que Carga la Descripcion de la Transaccion
-- de Pago para los Reclamos de Salud

-- Creado    : 09/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/01/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

--DROP PROCEDURE sp_rec62a;

CREATE PROCEDURE "informix".sp_rec62a(
a_no_reclamo	char(10),
a_cod_cobertura	char(5)
)

define _renglon			integer;
define _cod_reclamante	char(10);
define _cod_icd			char(10);
define _cod_cpt			char(10);
define _fecha_siniestro	char(10);
define _numrecla		char(20);
define _no_poliza		char(10);
define _nombre_icd		char(100);
define _nombre_cpt		char(100);
define _no_documento	char(20);
define _nombre_recla	char(100);
define _descripcion		char(60);
define _fecha_factura	char(10);
define _no_factura		char(10);

SET ISOLATION TO DIRTY READ;

select count(*)
  into _renglon
  from recrccob
 where no_reclamo    = a_no_reclamo
   and cod_cobertura = a_cod_cobertura;

if _renglon > 0 then
	return;
end if


insert into recrccob(
no_reclamo,
cod_cobertura,
estimado,
deducible,
reserva_inicial,
reserva_actual,
pagos,
salvamento,
recupero,
deducible_pagado,
deducible_devuel
)
values(
a_no_reclamo,
a_cod_cobertura,
0,0,0,0,0,0,0,0,0
);

END PROCEDURE
