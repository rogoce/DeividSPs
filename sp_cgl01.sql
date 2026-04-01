-- Procedure que Crea las Cuentas del Catalogo de Cuentas sin el guion

-- Creado    : 10/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par80;

create procedure sp_par80(a_producto_orig char(5)) 
returning integer,
          char(100),
          char(5);
