-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo011;

create procedure "informix".sp_bo011()

define _cuenta		char(12);
define _cantidad	integer;

foreach
 select cta_cuenta
   into _cuenta
   from tmp_cuentas 

	select count(*)
	  into _cantidad
	  from ef_cglcuentas
	 where cta_cuenta = _cuenta;

	if _cantidad <> 0 then
		continue foreach;
	end if

	insert into ef_cglcuentas
	select cta_cuenta,
       	   cta_nombre,
	   	   cta_nomexten,
	   	   cta_tipo,
	   	   cta_subtipo,
	   	   cta_nivel,
	   	   cta_tippartida,
	   	   cta_recibe,
	   	   cta_histmes,
	   	   cta_histano,
	   	   cta_auxiliar,
	   	   cta_saldoprom,
	   	   cta_moneda,
	   	   "99999999",
		   referencia
	  from tmp_cuentas
	 where cta_cuenta = _cuenta;
  
end foreach

end procedure