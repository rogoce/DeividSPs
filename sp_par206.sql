-- Procedure que genere el registro contable de las comisiones

-- Creado    : 15/03/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_par205 - DEIVID, S.A.

drop procedure sp_par206;

create procedure "informix".sp_par206(
a_no_requis char(10),
a_cuenta	char(25),
a_cod_aux	char(5),
a_debito	dec(16,2),
a_credito	dec(16,2)
) returning integer,
            char(50);

define _cantidad	smallint;
define _renglon		smallint;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select count(*)
  into _cantidad
  from chqchcta
 where no_requis = a_no_requis
   and cuenta    = a_cuenta;

if _cantidad = 0 then

	select max(renglon)
	  into _renglon
	  from chqchcta
	 where no_requis = a_no_requis;

    if _renglon Is Null then
		let _renglon = 0; 
	end if

	let _renglon = _renglon + 1;

	insert into	chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito
	)
	values(
	a_no_requis,
	_renglon,
	a_cuenta,
	a_debito,
	a_credito
	);

else

	select renglon
	  into _renglon
	  from chqchcta
	 where no_requis = a_no_requis
	   and cuenta    = a_cuenta;

	update chqchcta
	   set debito    = debito  + a_debito,
		   credito   = credito + a_credito
	 where no_requis = a_no_requis
	   and renglon   = _renglon;

end if

if a_cod_aux is not null then

	call sp_par207(a_no_requis, _renglon, a_cuenta, a_cod_aux, a_debito, a_credito) returning _error, _error_desc;

	if _error <> 0 then 
		return _error, _error_desc;
	end if

end if

end

return 0, "Actualizacion Exitosa";

end procedure