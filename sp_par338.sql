-- Procedimiento que Graba el Asiento del proceso de NIIF de primas no devengadas
-- Creado    : 05/08/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par338;		

create procedure "informix".sp_par338(
a_cuenta		char(25), 
a_debito		dec(16,2),
a_credito		dec(16,2),
a_tipo_comp		smallint,
a_periodo		char(7),
a_centro_costo	char(3),
a_fecha			date,
a_sac_notrx		integer
)

define _cantidad	smallint;

select count(*)
  into _cantidad
  from prdprinodeasie
 where fecha		= a_fecha
   and cuenta		= a_cuenta
   and tipo_comp	= a_tipo_comp;

if _cantidad = 0 then
	insert into prdprinodeasie(
			fecha,
			cuenta,
			debito,
			credito,
			tipo_comp,
			sac_notrx,
			periodo,
			centro_costo)
	values	(a_fecha,
			a_cuenta,
			a_debito,
			a_credito,
			a_tipo_comp,
			a_sac_notrx,
			a_periodo,
			a_centro_costo);
else
	update prdprinodeasie
	   set debito 	  = debito  + a_debito,
	       credito 	  = credito + a_credito
	 where fecha		= a_fecha
	   and cuenta		= a_cuenta
	   and tipo_comp	= a_tipo_comp;
end if

end procedure;
