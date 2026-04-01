-- Procedure que Crea un registro en la cuenta auxiliar

-- Creado    : 17/11/2009 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sac136;

create procedure sp_sac136(
a_cuenta	char(25),
a_auxiliar	char(5)
) returning integer,
		    char(100);

define _cantidad	integer;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(100);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select count(*)
  into _cantidad
  from cglauxiliar
 where aux_cuenta  = a_cuenta
   and aux_tercero = a_auxiliar;

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
	a_auxiliar,
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

end

return 0, "Actualizacion Exitosa";

end procedure
