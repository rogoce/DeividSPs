-- Simulacion
-- Procedimiento que Graba el Asiento de Reaseguro

-- Creado    : 10/09/2012 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sim006;		

create procedure "informix".sp_sim006(
a_no_registro	char(10), 
a_cuenta    	char(25), 
a_debito    	dec(16,2),
a_credito   	dec(16,2),
a_tipo_comp		smallint,
a_cod_auxiliar	char(5),
a_periodo		char(7),
a_centro_costo	char(3),
a_fecha			date
)

define _cantidad	smallint;

select count(*)
  into _cantidad
  from sac999:sreacompasiau
 where no_registro  = a_no_registro
   and cuenta 	    = a_cuenta
   and tipo_comp    = a_tipo_comp
   and cod_auxiliar = a_cod_auxiliar;

if _cantidad = 0 then

	insert into sac999:sreacompasiau(
	no_registro,
	cuenta,
	debito,
	credito,
	tipo_comp,
	cod_auxiliar,
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
	a_cod_auxiliar,
	a_periodo,
	a_centro_costo,
	a_fecha
	);

else

	update sac999:sreacompasiau
	   set debito 	    = debito  + a_debito,
	       credito 	    = credito + a_credito
	 where no_registro  = a_no_registro
	   and cuenta 	    = a_cuenta
	   and tipo_comp    = a_tipo_comp
	   and cod_auxiliar = a_cod_auxiliar;

end if

end procedure;
