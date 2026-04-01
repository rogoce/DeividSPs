-- Procedure que genere el registro contable de las comisiones

-- Creado    : 15/03/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_par205 - DEIVID, S.A.

--drop procedure sp_par207;

create procedure "informix".sp_par207(
a_no_requis char(10),
a_renglon	smallint,
a_cuenta	char(25),
a_cod_aux	char(5),
a_debito	dec(16,2),
a_credito	dec(16,2)
) returning integer,
            char(50);

define _cantidad	smallint;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select count(*)
  into _cantidad
  from chqctaux
 where no_requis    = a_no_requis
   and renglon      = a_renglon
   and cuenta       = a_cuenta
   and cod_auxiliar = a_cod_aux;

if _cantidad = 0 then

	insert into	chqctaux(
	no_requis,
	renglon,
	cuenta,
	cod_auxiliar,
	debito,
	credito
	)
	values(
	a_no_requis,
	a_renglon,
	a_cuenta,
	a_cod_aux,
	a_debito,
	a_credito
	);

else

	update chqctaux
	   set debito       = debito  + a_debito,
		   credito      = credito + a_credito
	 where no_requis    = a_no_requis
	   and renglon      = a_renglon
	   and cuenta       = a_cuenta
	   and cod_auxiliar = a_cod_aux;

end if

end

return 0, "Actualizacion Exitosa";

end procedure