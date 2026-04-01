-- Reporte de Recibos por Remesa - Cobros Moviles
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob18_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cdm002;

CREATE PROCEDURE "informix".sp_cdm002() 
  RETURNING integer;	-- Renglon


define _id_cliente		 char(30);
DEFINE _cant		 	 integer;	

SET ISOLATION TO DIRTY READ;
-- Nombre de la Compania

-- Lectura de la Tabla de Remesas

let _cant = 0;

foreach

 SELECT id_cliente
   INTO _id_cliente
   FROM cdmclientes
  WHERE id_usuario = 21
    and prog       = 'N'
    and tipocliente <> 1


 SELECT count(*)
   INTO _cant
   FROM cdmcuentas
  WHERE id_usuario = 21
    and id_cliente = _id_cliente;

if _cant = 0 then

	delete FROM cdmclientes
	 WHERE id_usuario = 21
       and id_cliente = _id_cliente;

end if

end foreach

return _cant;

END PROCEDURE;

