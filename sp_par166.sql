-- Procedure para actualizar la fecha de nacimiento borrada

-- Creado    : 27/07/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_prod_sp_pro154_dw1 - DEIVID, S.A.

drop procedure sp_par166;

create procedure "informix".sp_par166(a_cod_cliente char(10))

define _fecha	date;

--return;

{
select fecha_aniversario
  into _fecha
  from cliclienbak
 where cod_cliente = a_cod_cliente;
}

let _fecha = null;

if _fecha is not null then
	
	update cliclien
	   set fecha_aniversario = _fecha
	 where cod_cliente       = a_cod_cliente;

else

	let _fecha = null;
	
	foreach
	 select fecha_aniversario
	   into _fecha
	   from clibitacora
	  where cod_cliente       = a_cod_cliente
	    and fecha_aniversario is not null
		exit foreach;
	end foreach

	if _fecha is not null then
		
		update cliclien
		   set fecha_aniversario = _fecha
		 where cod_cliente       = a_cod_cliente;

	end if

end if

end procedure