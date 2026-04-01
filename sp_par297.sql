-- Procedimiento que Graba el Asiento de Reaseguro

-- Creado    : 06/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par297;		

create procedure "informix".sp_par297(
a_no_registro	char(10), 
a_cuenta    	char(25), 
a_debito    	dec(16,2),
a_credito   	dec(16,2),
a_tipo_comp		smallint,
a_periodo		char(7),
a_centro_costo	char(3),
a_fecha			date
)

define _cantidad	smallint;

select count(*)
  into _cantidad
  from sac999:reacompasie
 where no_registro = a_no_registro
   and cuenta 	   = a_cuenta
   and tipo_comp   = a_tipo_comp;

if _cantidad = 0 then

	insert into sac999:reacompasie(
	no_registro,
	cuenta,
	debito,
	credito,
	tipo_comp,
	periodo,
	centro_costo,
	fecha
	)
	values(
	a_no_registro,
	a_cuenta,
	a_debito,
	a_credito,
	a_tipo_comp,
	a_periodo,
	a_centro_costo,
	a_fecha
	);

else

	update sac999:reacompasie
	   set debito 	   = debito  + a_debito,
	       credito 	   = credito + a_credito
	 where no_registro = a_no_registro
	   and cuenta 	   = a_cuenta
	   and tipo_comp   = a_tipo_comp;

end if

end procedure;
