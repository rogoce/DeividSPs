-- Procedimiento que Graba el Asiento del Reclamo

-- Creado    : 22/01/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/01/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par73;		

create procedure "informix".sp_par73(
a_no_tranrec 	char(10), 
a_cuenta     	char(25), 
a_debito     	dec(16,2),
a_credito    	dec(16,2),
a_tipo_comp	 	smallint,
a_periodo	 	char(7),
a_centro_costo	char(3),
a_fecha			date
)

define _cantidad	smallint;

select count(*)
  into _cantidad
  from recasien
 where no_tranrec = a_no_tranrec
   and cuenta 	  = a_cuenta
   and tipo_comp  = a_tipo_comp;

if _cantidad = 0 then

	insert into recasien(
	no_tranrec,
	cuenta,
	debito,
	credito,
	tipo_comp,
	periodo,
	centro_costo,
	fecha
	)
	values(
	a_no_tranrec,
	a_cuenta,
	a_debito,
	a_credito,
	a_tipo_comp,
	a_periodo,
	a_centro_costo,
	a_fecha
	);

else

	update recasien
	   set debito 	  = debito  + a_debito,
	       credito 	  = credito + a_credito
	 where no_tranrec = a_no_tranrec
	   and cuenta 	  = a_cuenta
	   and tipo_comp  = a_tipo_comp;

end if

end procedure;
