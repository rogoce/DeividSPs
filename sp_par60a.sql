-- Procedimiento que Graba el Asiento de la Factura

-- Creado    : 25/10/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 25/10/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par60a;		

create procedure "informix".sp_par60a(
a_no_poliza	char(10), 
a_no_endoso char(5), 
a_cuenta    char(25), 
a_debito    dec(16,2),
a_credito   dec(16,2),
a_tipo_comp	smallint)

begin
on exception in(-268)

	update dep_endasien
	   set debito 	 = debito  + a_debito,
	       credito 	 = credito + a_credito
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   and cuenta 	 = a_cuenta
	   and tipo_comp = a_tipo_comp;

end exception

	insert into dep_endasien(
			no_poliza,
			no_endoso,
			cuenta,
			debito,
			credito,
			tipo_comp)
	values(	a_no_poliza,
			a_no_endoso,
			a_cuenta,
			a_debito,
			a_credito,
			a_tipo_comp);
end
end procedure;