-- Procedimiento que verifica que cuadre el detalle y el saldo de los auxiliares

-- Creado    : 09/09/2008 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac88;

create procedure sp_sac88(
a_tipo_resumen	char(2),
a_cuenta	  	char(25),
a_cod_auxiliar	char(5),
a_ano		  	smallint
) returning smallint,
			char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define i	smallint;

insert into cglsaldoaux
values (a_tipo_resumen, a_cuenta, a_cod_auxiliar, a_ano, 0.00);

for i = 1 to 14

	insert into cglsaldoaux1
	values (a_tipo_resumen, a_cuenta, a_cod_auxiliar, a_ano, i, 0.00, 0.00, 0.00);

end for

return 0, "Actualizacion Exitosa";

end procedure
