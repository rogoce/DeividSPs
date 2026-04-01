-- Creacion Inicial de Datos para los Cobros Automaticos
-- 
-- Creado    : 07/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob102;

create procedure sp_cob102(
a_cod_cliente 	char(10), 
a_dia1 			char(3), 
a_dia2 			char(3),
a_no_documento	char(20)
)

define _dia1	smallint;

set isolation to dirty read;
foreach
	select dia_cobros1
	  into _dia1
	  from cascliente
	 where cod_cliente = a_cod_cliente
	exit foreach;
end foreach
if _dia1 is null then

	insert into cascliente(
	cod_cliente,
	dia_cobros1,
	dia_cobros2,
	cod_cobrador,
	procesado,
	fecha_ult_pro,
	cod_gestion,
	dia_cobros3,
	cod_cobrador_ant,
	ultima_gestion,
	cod_campana
	)
	values(
	a_cod_cliente,
	a_dia1,
	a_dia2,
	null,
	0,
	today,
	null,
	0,
	null,
	"Llamada Entrante ...",
	'00001'
	);

else

	if a_dia1 <> 0 then

		if _dia1 > a_dia1 then
		
			update cascliente
			   set dia_cobros1 = a_dia1,
			       dia_cobros2 = a_dia2
			 where cod_cliente = a_cod_cliente;	

		end if
	
	end if
	
end if

let _dia1 = null;

select dia_cobros1
  into _dia1
  from caspoliza
 where no_documento = a_no_documento;

if _dia1 is null then

	insert into caspoliza(
	no_documento,
	cod_cliente,
	dia_cobros1,
	dia_cobros2
	)
	values(
	a_no_documento,
	a_cod_cliente,
	a_dia1,
	a_dia2
	);

end if

end procedure