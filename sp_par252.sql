-- Procedimiento que Graba el Asiento del auxiliar de reclamos

-- Creado    : 16/08/2007 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/08/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par252;		

create procedure "informix".sp_par252(
a_no_tranrec	char(10), 
a_cuenta    	char(25), 
a_tipo_comp		smallint,
a_debito    	dec(16,2),
a_credito   	dec(16,2),
a_cod_aux		char(5),
a_periodo	 	char(7),
a_centro_costo	char(3),
a_fecha			date
)

define _cantidad	smallint;

select count(*)
  into _cantidad
  from recasiau
 where no_tranrec   = a_no_tranrec
   and cuenta	    = a_cuenta
   and tipo_comp    = a_tipo_comp
   and cod_auxiliar = a_cod_aux;

if _cantidad <> 0 then

	update recasiau
	   set debito 	    = debito  + a_debito,
	       credito 	    = credito + a_credito
	 where no_tranrec   = a_no_tranrec
	   and cuenta	    = a_cuenta
	   and tipo_comp    = a_tipo_comp
	   and cod_auxiliar = a_cod_aux;

else

	insert into recasiau(
	no_tranrec,
	cuenta,
	tipo_comp,
	cod_auxiliar,
	debito,
	credito,
	periodo,
	centro_costo,
	fecha
	)
	values(
	a_no_tranrec,
	a_cuenta,
	a_tipo_comp,
	a_cod_aux,
	a_debito,
	a_credito,
	a_periodo,
	a_centro_costo,
	a_fecha
	);

end if

select count(*)
  into _cantidad
  from cglauxiliar
 where aux_cuenta  = a_cuenta
   and aux_tercero = a_cod_aux;

if _cantidad = 0 then

	insert into cglauxiliar(
	aux_cuenta,
	aux_tercero,
	aux_pctreten,
	aux_saldoret,
	aux_corriente,
	aux_30dias,
	aux_60dias,
	aux_90dias,
	aux_120dias,
	aux_150dias,
	aux_ultimatrx,
	aux_ultimodcmto,
	aux_observacion
	)
	values(
	a_cuenta,
	a_cod_aux,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	"",
	"",
	""
	);

end if

end procedure;
