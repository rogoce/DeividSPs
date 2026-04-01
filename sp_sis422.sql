-- Procedimiento que Crea la poliza de salud en tabla chqcomsa para pago en proceso de comisiones del bono de $100 por cada 4 polizas emitidas
-- 
-- Creado    : 08/04/2015 - Autor: Armando Moreno M.

DROP PROCEDURE sp_sis422;		

CREATE PROCEDURE "informix".sp_sis422(a_no_documento CHAR(20),aa_no_poliza char(10))

define _cantidad	smallint;
define _cod_agente  char(5);
define _tipo_agente char(1);

select count(*)
  into _cantidad
  from chqcomsa
 where no_documento = a_no_documento;


 if _cantidad = 0 then

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = aa_no_poliza
		 
		 select tipo_agente
		   into _tipo_agente
		   from agtagent
		  where cod_agente = _cod_agente;
 		  
		if _tipo_agente = 'O' then
			continue foreach;
		end if	
		 
		insert into chqcomsa(
		no_documento,
		fecha_emision,
		fecha_comision,
		estatus,
		cod_agente
		)
		values(
		a_no_documento,
		today,
		null,
		'1',
		_cod_agente
		);
	end foreach	
end if

end procedure
