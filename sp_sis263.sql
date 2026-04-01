-- Procedure para validar fecha aniversario y sexo de clos asegurados para las polizas de vida
-- Armando Moreno M. 02/12/2024


drop procedure sp_sis263;
create procedure sp_sis263(a_no_poliza char(10))
returning integer;


define _cod_asegurado char(10);
define _sexo		  char(1);
define _fecha_aniv    date;
define _error,_edad	  integer;

begin

let _error = 0;
foreach
	select cod_asegurado
	  into _cod_asegurado
	  from emipouni
	 where no_poliza = a_no_poliza 
  	
	select fecha_aniversario,
	       sexo
      into _fecha_aniv,
	       _sexo 
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	 
	if _fecha_aniv is null then
		let _error = 336;
	end if
	
	let _edad = sp_sis78(_fecha_aniv);
	if _edad >= 0 and _edad <= 120 then
	else
		let _error = 337;
	end if
	
	if trim(_sexo) not in('F','M') then
		let _error = 338;
	end if
end foreach
end 
return _error;
end procedure