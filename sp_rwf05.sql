-- Marcar Reclamo y Poliza como Perdida Total
-- 
-- Creado    : 17/03/2004 - Autor: Demetrio Hurtado Almanza
-- Modificado: 17/03/2004 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_rwf04;

create procedure "informix".sp_rwf04(
a_numrecla    char(20)
a_tipo	      char(1),
a_cod_cliente char(10)
) returning integer;

define _no_poliza	char(10);
define _no_unidad	char(5);
define _no_reclamo  char(10);
define _error		integer;

begin work;

begin
on exception set _error 
	rollback work
 	return _error;         
end exception

select no_poliza,
       no_unidad,
	   no_reclamo
  into _no_poliza,
       _no_unidad,
	   _no_reclamo
  from recrcmae
 where numrecla = a_numrecla;

if a_tipo = "0" then

	update recrcmae
	   set perd_total = 1
	 where numrecla   = a_numrecla;

	update emipomae
	   set perd_total = 1
	 where no_poliza  = _no_poliza;

	update emipouni
	   set perd_total = 1
	 where no_poliza  = _no_poliza
	   and no_unidad  = _no_unidad;

elif a_tipo = "1" then

	update recterce
	   set perd_total     = 1,
	       estado_perdida = "PT"
     where no_reclamo     = _no_reclamo
	   and cod_tercero    = a_cod_cliente;


end if

end 

commit work;

end procedure
