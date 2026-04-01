-- Procedimiento que Crea el Historico de Polizas
-- 
-- Creado    : 09/11/2004 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis64bk;		
CREATE PROCEDURE "informix".sp_sis64bk(a_no_documento CHAR(20))
returning smallint;

define _cantidad	smallint;

select count(*)
  into _cantidad
  from emipoliza
 where no_documento = a_no_documento;

if _cantidad = 0 then

	insert into emipoliza(
	no_documento
	)
	values(
	a_no_documento
	);

end if
return 0;
end procedure
